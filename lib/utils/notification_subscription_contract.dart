import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationSubscriptionContract {
  Future<void> subscribeToTopic(String channelName);
  Future<void> unsubscribeFromTopic(String channelName);
}

class NotificationSubscription implements NotificationSubscriptionContract {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  Future<void> subscribeToTopic(String channelName) async {
    await _firebaseMessaging.subscribeToTopic(channelName);
  }

  @override
  Future<void>  unsubscribeFromTopic(String channelName) async {
    await _firebaseMessaging.unsubscribeFromTopic(channelName);
  }
}
