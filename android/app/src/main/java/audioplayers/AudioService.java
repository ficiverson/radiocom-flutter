package xyz.luan.audioplayers;

import com.ibizasonica.ibizasonica.MainActivity;
import com.ibizasonica.ibizasonica.R;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;

import java.util.HashMap;
import java.util.Map;

import androidx.core.app.NotificationCompat;
import io.flutter.plugin.common.EventChannel;

public class AudioService extends Service {

	public static final int NOTIFICATION_ID = 1034;
	public static final String CHANNEL_ID = "audio_channel";
	public static final String EVENT_ID = "ibizasonica.flutter.io/updateNotification";
	public static final String EVENT_ID_MAIN = "ibizasonica.flutter.io/updateNotificationMain";
	public static final String EVENT_ID_PODCAST = "ibizasonica.flutter.io/updateNotificationPodcastDetail";

	private AudioBinder binder = new AudioBinder();
	private final Map<String, Player> mediaPlayers = new HashMap<>();

	private String title = "Ibiza Sonica";
	private String subtitle = "Live";
	static EventChannel.EventSink updateEvent;
	static EventChannel.EventSink updateEventMain;
	static EventChannel.EventSink updateEventPodcast;

	public static void registerActivity(MainActivity activity) {
		new EventChannel(activity.getFlutterView(), EVENT_ID_PODCAST).setStreamHandler(
				new EventChannel.StreamHandler() {
					@Override
					public void onListen(Object args, final EventChannel.EventSink events) {
						updateEventPodcast = events;
					}

					@Override
					public void onCancel(Object args) {

					}
				}
		);
		new EventChannel(activity.getFlutterView(), EVENT_ID_MAIN).setStreamHandler(
				new EventChannel.StreamHandler() {
					@Override
					public void onListen(Object args, final EventChannel.EventSink events) {
						updateEventMain = events;
					}

					@Override
					public void onCancel(Object args) {

					}
				}
		);

		new EventChannel(activity.getFlutterView(), EVENT_ID).setStreamHandler(
				new EventChannel.StreamHandler() {
					@Override
					public void onListen(Object args, final EventChannel.EventSink events) {
						updateEvent = events;
					}

					@Override
					public void onCancel(Object args) {

					}
				}
		);
	}

	public static void stopComponent(Context context, Activity activity) {
		context.stopService(new Intent(activity, AudioService.class));
	}

	@Override
	public void onCreate() {
		super.onCreate();
		for (Player mediaPlayer : mediaPlayers.values()) {
			mediaPlayer.stop();
			mediaPlayer.release();
		}
		clearAllPlayers();
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		if (intent != null && intent.getAction() != null && intent.getAction().equals("ACTION.CLOSE_ACTION")) {
			clearAllPlayers();
			stopForeground(true);
			removeNotifiction();
			if (updateEvent != null) {
				updateEvent.success(true);
			}
			if (updateEventPodcast != null) {
				updateEventPodcast.success(true);
			}
			if (updateEventMain != null) {
				updateEventMain.success(true);
			}
		}
		return START_STICKY;
	}


	public void startForeground() {

		final NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

		if (Build.VERSION.SDK_INT >= 26) {
			String CHANNEL_ID = "audio_channel";
			NotificationChannel channel = new NotificationChannel(CHANNEL_ID,
					"Media player",
					NotificationManager.IMPORTANCE_DEFAULT);
			channel.setDescription(CHANNEL_ID);
			channel.setSound(null, null);
			notificationManager.createNotificationChannel(channel);
		}

		launchNotification(title, subtitle);
	}

	public void setNotificationInfo(String title, String subtitle) {
		this.title = title;
		this.subtitle = subtitle;

		launchNotification(title, subtitle);
	}

	private void launchNotification(String title, String subtitle) {

		// Create notification default intent.
		Intent intent = new Intent(this, MainActivity.class);
		PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 0);

		final NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

		Intent stopIntent = new Intent(this, AudioService.class);
		stopIntent.setAction("ACTION.CLOSE_ACTION");
		PendingIntent closeIntent = PendingIntent.getService(this, 0, stopIntent, 0);

		NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
				.setSmallIcon(R.drawable.ic_notification)
				.setContentIntent(pendingIntent)
				.setContentTitle(title)
				.setContentText(subtitle)
				.addAction(android.R.drawable.ic_menu_close_clear_cancel, getString(R.string.close_notification), closeIntent)
				.setPriority(NotificationCompat.PRIORITY_DEFAULT);

		Notification notification = null;
		if (Build.VERSION.SDK_INT >= 26) {
			builder.setChannelId(CHANNEL_ID);
			notification = builder.build();
			startForeground(NOTIFICATION_ID, notification);
		} else {
			notification = builder.build();
		}

		notificationManager.notify(NOTIFICATION_ID, notification);
	}

	public void removeNotifiction() {
		subtitle = "Ibiza Sonica";
		title = "Live";
		final NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
		notificationManager.cancel(NOTIFICATION_ID);
	}

	public void clearAllPlayers() {
		for (Player player : mediaPlayers.values()) {
			player.release();
		}
		mediaPlayers.clear();
	}

	@Override
	public IBinder onBind(Intent intent) {
		return binder;
	}

	public Map<String, Player> getPlayers() {
		return mediaPlayers;
	}

	@TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
	@Override
	public void onTaskRemoved(Intent rootIntent) {
		stopForeground(true);
		removeNotifiction();
		super.onTaskRemoved(rootIntent);
	}

	@Override
	public void onDestroy() {
		for (Player mediaPlayer : mediaPlayers.values()) {
			mediaPlayer.stop();
			mediaPlayer.release();
		}
		clearAllPlayers();
		stopForeground(true);
		removeNotifiction();
		super.onDestroy();
	}

	public class AudioBinder extends Binder {
		public AudioService getService() {
			return AudioService.this;
		}
	}
}
