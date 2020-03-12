package xyz.luan.audioplayers;

import com.app.cuacfm.MainActivity;
import com.app.cuacfm.R;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import androidx.annotation.ColorInt;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;
import androidx.palette.graphics.Palette;
import io.flutter.plugin.common.EventChannel;

public class AudioService extends Service {

	public static final int NOTIFICATION_ID = 1034;
	public static final String CHANNEL_ID = "audio_channel";
	public static final String EVENT_ID = "cuacfm.flutter.io/updateNotification";
	public static final String EVENT_ID_MAIN = "cuacfm.flutter.io/updateNotificationMain";
	public static final String EVENT_ID_PODCAST = "cuacfm.flutter.io/updateNotificationPodcastDetail";
	public static final String EVENT_ID_CONTROL_PODCAST = "cuacfm.flutter.io/updateNotificationPodcastControl";
	public static final String EVENT_ID_NEW_DETAIL = "cuacfm.flutter.io/updateNotificationNewDetail";

	private AudioBinder binder = new AudioBinder();
	private final Map<String, Player> mediaPlayers = new HashMap<>();

	private String title = "CUAC FM";
	private String subtitle = "Directo";
	private String image = "https://cuacfm.org/radioco/media/photos/cuac.png";
	static EventChannel.EventSink updateEvent;
	static EventChannel.EventSink updateEventMain;
	static EventChannel.EventSink updateEventPodcast;
	static EventChannel.EventSink updateEventPodcastControl;
	static EventChannel.EventSink updateEventNewDetail;

	public static void registerActivity(MainActivity activity) {
		new EventChannel(activity.getFlutterView(), EVENT_ID_NEW_DETAIL).setStreamHandler(
				new EventChannel.StreamHandler() {
					@Override
					public void onListen(Object args, final EventChannel.EventSink events) {
						updateEventNewDetail = events;
					}

					@Override
					public void onCancel(Object args) {

					}
				}
		);
		new EventChannel(activity.getFlutterView(), EVENT_ID_CONTROL_PODCAST).setStreamHandler(
				new EventChannel.StreamHandler() {
					@Override
					public void onListen(Object args, final EventChannel.EventSink events) {
						updateEventPodcastControl = events;
					}

					@Override
					public void onCancel(Object args) {

					}
				}
		);
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
			if (updateEventPodcastControl != null) {
				updateEventPodcastControl.success(true);
			}
			if (updateEventNewDetail != null) {
				updateEventNewDetail.success(true);
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

		new GeneratePictureStyleNotification(this, title, subtitle, image).execute();
	}

	public void setNotificationInfo(String title, String subtitle, String image) {
		this.title = title;
		this.subtitle = subtitle;
		this.image = image;

		new GeneratePictureStyleNotification(this, title, subtitle, image).execute();
	}

	public void removeNotifiction() {
		subtitle = "CUAC FM";
		title = "Directo";
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

	private class GeneratePictureStyleNotification extends AsyncTask<String, Void, Bitmap> {

		private Context context;
		private String title, subtitle, imageUrl;

		public GeneratePictureStyleNotification(Context context, String title, String subtitle, String imageUrl) {
			super();
			this.context = context;
			this.title = title;
			this.imageUrl = imageUrl;
			this.subtitle = subtitle;
		}

		@Override
		protected Bitmap doInBackground(String... params) {

			InputStream in;
			try {
				URL url = new URL(this.imageUrl);
				HttpURLConnection connection = (HttpURLConnection) url.openConnection();
				connection.setDoInput(true);
				connection.connect();
				in = connection.getInputStream();
				return BitmapFactory.decodeStream(in);
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		@Override
		protected void onPostExecute(Bitmap result) {

			super.onPostExecute(result);
			if (result == null) {
				Bitmap local = BitmapFactory.decodeResource(context.getResources(),
						R.drawable.splash);
				Palette.from(local).generate(new Palette.PaletteAsyncListener() {
					public void onGenerated(Palette p) {
						sendNotification(p.getDominantColor(ContextCompat.getColor(context, R.color.notification_background)), local);
					}
				});
			} else {
				Palette.from(result).generate(new Palette.PaletteAsyncListener() {
					public void onGenerated(Palette p) {
						sendNotification(p.getDominantColor(ContextCompat.getColor(context, R.color.notification_background)), result);
					}
				});
			}
		}

		void sendNotification(@ColorInt int color, Bitmap result) {
			// Create notification default intent.
			Intent intent = new Intent(context, MainActivity.class);
			PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, 0);

			final NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

			Intent stopIntent = new Intent(context, AudioService.class);
			stopIntent.setAction("ACTION.CLOSE_ACTION");
			PendingIntent closeIntent = PendingIntent.getService(context, 0, stopIntent, 0);

			NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
					.setStyle(
							new androidx.media.app.NotificationCompat.MediaStyle())
					.setSmallIcon(R.drawable.ic_notification)
					.setContentIntent(pendingIntent)
					.setContentTitle(title)
					.setContentText(subtitle)
					.setLargeIcon(result)
					.setColor(color)
					.addAction(R.drawable.ic_pause, getString(R.string.close_notification), closeIntent)
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
	}
}
