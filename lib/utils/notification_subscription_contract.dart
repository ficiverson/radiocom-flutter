import 'package:flutter/foundation.dart' as Foundation;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationSubscriptionContract {
  Future<void> subscribeToTopic(String channelName);
  Future<void> unsubscribeFromTopic(String channelName);
  Future<bool> isSubscribed(String channelName);
  void getToken();
  void setScreen(String name);
}

class NotificationSubscription implements NotificationSubscriptionContract {

  NotificationSubscription();

  @override
  void getToken() {
    FirebaseMessaging.instance.getToken().then((token) {
      if (Foundation.kDebugMode) print('FCM token: $token');
    });
  }

  @override
  Future<void> subscribeToTopic(String channelName) async {
    final tag = _sanitizeTag(channelName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_$tag', true);
    await FirebaseMessaging.instance.subscribeToTopic(tag);
  }

  @override
  Future<void> unsubscribeFromTopic(String channelName) async {
    final tag = _sanitizeTag(channelName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_$tag', false);
    await FirebaseMessaging.instance.unsubscribeFromTopic(tag);
  }

  @override
  Future<bool> isSubscribed(String channelName) async {
    final tag = _sanitizeTag(channelName);
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notif_$tag') ?? false;
  }

  @override
  void setScreen(String name) {
    if (Foundation.kDebugMode) {
      print('Screen: $name');
    }
  }

  String _sanitizeTag(String input) {
    final sanitized = input.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return sanitized.substring(0, sanitized.length.clamp(0, 64));
  }
}
