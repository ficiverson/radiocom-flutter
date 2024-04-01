import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationSubscriptionContract {
  Future<void> subscribeToTopic(String channelName);
  Future<void> unsubscribeFromTopic(String channelName);
  void getToken();
  void setScreen(String name);
}

class NotificationSubscription implements NotificationSubscriptionContract {
  FirebaseMessaging? _firebaseMessaging;

  NotificationSubscription() {
    _firebaseMessaging = FirebaseMessaging.instance;
  }

  @override
  void getToken()  {
    _firebaseMessaging?.requestPermission(sound: true, badge: true, alert: true);
    _firebaseMessaging?.getToken().then((String? token) {
      print(token);
    });
  }

  @override
  Future<void> subscribeToTopic(String channelName) async {
    await _firebaseMessaging?.subscribeToTopic(channelName);
  }

  @override
  Future<void>  unsubscribeFromTopic(String channelName) async {
    await _firebaseMessaging?.unsubscribeFromTopic(channelName);
  }

  @override
  void setScreen(String name) {
    FirebaseAnalytics.instance.logScreenView(screenName: name);
  }
}
