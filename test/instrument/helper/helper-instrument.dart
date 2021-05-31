import 'dart:ui';

import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/player/current_timer.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:cuacfm/utils/notification_subscription_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockTranslations extends Mock implements CuacLocalization {}

class MockNotifcationSubscription extends Mock
    implements NotificationSubscriptionContract {}

class MockConnection extends Mock implements ConnectionContract {}

class MockPlayer extends Mock implements CurrentPlayerContract {}

class MockCurrentTimerContract extends Mock implements CurrentTimerContract{}

void mockTranslationsWithLocale() {
  Injector.appInstance.registerSingleton<CuacLocalization>(
      () => CuacLocalization(Locale('en', 'US')),
      override: true);
}

Widget startWidget(Widget widgetToStart) {
  FlutterError.onError = null;
  var size = Size(768, 1024);
  return MaterialApp(
      home: MediaQuery(data: MediaQueryData(size: size), child: widgetToStart));
}

void printMessages(List list) {
  list.forEach((data) {
    print(data.toString());
  });
}

void getTranslations() {
  MockTranslations translations = MockTranslations();
  Injector.appInstance
      .registerSingleton<CuacLocalization>(() => translations, override: true);
  when(translations.translate(any)).thenReturn("");
  when(translations.getTranslations(any)).thenReturn("");
  when(translations.translateMap(any)).thenReturn(Map.identity());
}

typedef Callback(MethodCall call);

setupCloudFirestoreMocks([Callback customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': {},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }

    if (customHandlers != null) {
      customHandlers(call);
    }

    return null;
  });
}
