package xyz.luan.audioplayers;

import android.app.Service;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * Fork for audioplayers to update please take into account the service
 */
public class AudioplayersPlugin implements MethodCallHandler {

	private static final Logger LOGGER = Logger.getLogger(AudioplayersPlugin.class.getCanonicalName());
	private static AudioService audioService;
	private final MethodChannel channel;
	private final MethodChannel notificationChannel;
	private final Handler handler = new Handler();
	private Runnable positionUpdates;

	public static void registerWith(final Registrar registrar) {
		final MethodChannel channel = new MethodChannel(registrar.messenger(), "xyz.luan/audioplayers");
		final MethodChannel notificationChannel = new MethodChannel(registrar.messenger(), "ibizasonica.flutter.io/notificationInfo");
		channel.setMethodCallHandler(new AudioplayersPlugin(channel, notificationChannel));

		registrar.context().bindService(new Intent(registrar.activeContext().getApplicationContext(), AudioService.class), new ServiceConnection() {
			@Override
			public void onServiceConnected(ComponentName name, IBinder service) {
				audioService = ((AudioService.AudioBinder) service).getService();
			}

			@Override
			public void onServiceDisconnected(ComponentName name) {

			}
		}, Service.BIND_ABOVE_CLIENT);
	}

	private AudioplayersPlugin(final MethodChannel channel, final MethodChannel notificationChannel) {
		this.channel = channel;
		this.notificationChannel = notificationChannel;
		this.channel.setMethodCallHandler(this);
		this.notificationChannel.setMethodCallHandler(this);
	}

	@Override
	public void onMethodCall(final MethodCall call, final MethodChannel.Result response) {
		try {
			handleMethodCall(call, response);
		} catch (Exception e) {
			LOGGER.log(Level.SEVERE, "Unexpected error!", e);
			response.error("Unexpected error!", e.getMessage(), e);
		}
	}

	private void handleMethodCall(final MethodCall call, final MethodChannel.Result response) {
		final String playerId = call.argument("playerId");
		final String mode = call.argument("mode");
		Player player = null;
		if (!call.method.equals("notificationInfo")) {
			player = getPlayer(playerId, mode);
		}
		switch (call.method) {
			case "play": {
				final String url = call.argument("url");
				final double volume = call.argument("volume");
				final Integer position = call.argument("position");
				final boolean respectSilence = call.argument("respectSilence");
				final boolean isLocal = call.argument("isLocal");
				player.configAttributes(respectSilence);
				player.setVolume(volume);
				player.setUrl(url, isLocal);
				if (position != null && !mode.equals("PlayerMode.LOW_LATENCY")) {
					player.seek(position);
				}
				audioService.startForeground();
				player.play();
				break;
			}
			case "resume": {
				audioService.startForeground();
				player.play();
				break;
			}
			case "pause": {
				audioService.stopForeground(true);
				audioService.removeNotifiction();
				player.pause();
				break;
			}
			case "stop": {
				audioService.stopForeground(true);
				audioService.removeNotifiction();
				player.stop();
				break;
			}
			case "release": {
				audioService.stopForeground(true);
				audioService.removeNotifiction();
				player.release();
				break;
			}
			case "seek": {
				final Integer position = call.argument("position");
				player.seek(position);
				break;
			}
			case "setVolume": {
				final double volume = call.argument("volume");
				player.setVolume(volume);
				break;
			}
			case "setUrl": {
				final String url = call.argument("url");
				final boolean isLocal = call.argument("isLocal");
				player.setUrl(url, isLocal);
				break;
			}
			case "setReleaseMode": {
				final String releaseModeName = call.argument("releaseMode");
				final ReleaseMode releaseMode = ReleaseMode.valueOf(releaseModeName.substring("ReleaseMode.".length()));
				player.setReleaseMode(releaseMode);
				break;
			}
			case "notificationInfo": {
				String title = call.argument("notificationTitle");
				String subtitle = call.argument("notificationSubtitle");
				if (title != null && subtitle != null) {
					audioService.setNotificationInfo(title, subtitle);
				}
				break;
			}
			default: {
				response.notImplemented();
				return;
			}
		}
		response.success(1);
	}

	private Player getPlayer(String playerId, String mode) {
		if (!audioService.getPlayers().containsKey(playerId)) {
			Player player =
					mode.equalsIgnoreCase("PlayerMode.MEDIA_PLAYER") ?
							new WrappedMediaPlayer(this, playerId) :
							new WrappedSoundPool(this, playerId);
			audioService.clearAllPlayers();
			audioService.getPlayers().put(playerId, player);
		}
		return audioService.getPlayers().get(playerId);
	}

	public void handleIsPlaying(Player player) {
		startPositionUpdates();
	}

	public void handleCompletion(Player player) {
		channel.invokeMethod("audio.onComplete", buildArguments(player.getPlayerId(), true));
	}

	private void startPositionUpdates() {
		if (positionUpdates != null) {
			return;
		}
		positionUpdates = new UpdateCallback(audioService.getPlayers(), channel, handler, this);
		handler.post(positionUpdates);
	}

	private void stopPositionUpdates() {
		positionUpdates = null;
		handler.removeCallbacksAndMessages(null);
	}

	private static Map<String, Object> buildArguments(String playerId, Object value) {
		Map<String, Object> result = new HashMap<>();
		result.put("playerId", playerId);
		result.put("value", value);
		return result;
	}

	private static final class UpdateCallback implements Runnable {

		private final WeakReference<Map<String, Player>> mediaPlayers;
		private final WeakReference<MethodChannel> channel;
		private final WeakReference<Handler> handler;
		private final WeakReference<AudioplayersPlugin> audioplayersPlugin;

		private UpdateCallback(final Map<String, Player> mediaPlayers,
				final MethodChannel channel,
				final Handler handler,
				final AudioplayersPlugin audioplayersPlugin) {
			this.mediaPlayers = new WeakReference<>(mediaPlayers);
			this.channel = new WeakReference<>(channel);
			this.handler = new WeakReference<>(handler);
			this.audioplayersPlugin = new WeakReference<>(audioplayersPlugin);
		}

		@Override
		public void run() {
			final Map<String, Player> mediaPlayers = this.mediaPlayers.get();
			final MethodChannel channel = this.channel.get();
			final Handler handler = this.handler.get();
			final AudioplayersPlugin audioplayersPlugin = this.audioplayersPlugin.get();

			if (mediaPlayers == null || channel == null || handler == null || audioplayersPlugin == null) {
				if (audioplayersPlugin != null) {
					audioplayersPlugin.stopPositionUpdates();
				}
				return;
			}

			boolean nonePlaying = true;
			for (Player player : mediaPlayers.values()) {
				if (!player.isActuallyPlaying()) {
					continue;
				}
				try {
					nonePlaying = false;
					final String key = player.getPlayerId();
					final int duration = player.getDuration();
					final int time = player.getCurrentPosition();
					channel.invokeMethod("audio.onDuration", buildArguments(key, duration));
					channel.invokeMethod("audio.onCurrentPosition", buildArguments(key, time));
				} catch (UnsupportedOperationException e) {

				}
			}

			if (nonePlaying) {
				audioplayersPlugin.stopPositionUpdates();
			} else {
				handler.postDelayed(this, 200);
			}
		}
	}
}
