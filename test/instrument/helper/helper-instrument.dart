import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/player/current_timer.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:cuacfm/utils/notification_subscription_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_mocks/firebase_core_mocks.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';

class MockTranslations extends Mock implements CuacLocalization {
  @override
  Map<String, dynamic> translateMap(String? key) => super.noSuchMethod(
        Invocation.method(#translateMap, [key]),
        returnValue: Map<String, dynamic>(),
      );
  @override
  String getTranslations(String? key) => super.noSuchMethod(
        Invocation.method(#getTranslations, [key]),
        returnValue: "",
      );
  @override
  String translate(String? key) =>
      super.noSuchMethod(Invocation.method(#translate, [key]), returnValue: "");
}

class MockNotifcationSubscription extends Mock
    implements NotificationSubscriptionContract {
  @override
  Future<void> subscribeToTopic(String? channelName) => super.noSuchMethod(
        Invocation.method(#subscribeToTopic, [channelName]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
  @override
  Future<void> unsubscribeFromTopic(String? channelName) => super.noSuchMethod(
        Invocation.method(#unsubscribeFromTopic, [channelName]),
        returnValue: Future.value(),
      );
  @override
  void getToken() => super.noSuchMethod(Invocation.method(#getToken, []));
  @override
  void setScreen(String name) =>
      super.noSuchMethod(Invocation.method(#setScreen, [name]));
}

class MockConnection extends Mock implements ConnectionContract {
  @override
  Future<bool> isConnectionAvailable() => super.noSuchMethod(
        Invocation.method(#isConnectionAvailable, []),
        returnValue: Future.value(true),
      );
}

class MockPlayer extends Mock implements CurrentPlayerContract {
  @override
  void restorePlayer(ConnectivityResult? connection) =>
      super.noSuchMethod(Invocation.method(#restorePlayer, [connection]));
  @override
  Future<bool> seek(Duration? position) => super.noSuchMethod(
        Invocation.method(#seek, [position]),
        returnValue: Future.value(),
      );
  @override
  Future<bool> setVolume(double? volume) => super.noSuchMethod(
        Invocation.method(#setVolume, [volume]),
        returnValue: Future.value(true),
      );
  @override
  Future<bool> play() => super.noSuchMethod(
        Invocation.method(#play, []),
        returnValue: Future.value(true),
      );
  @override
  Future<bool> stopAndPlay() => super.noSuchMethod(
        Invocation.method(#stopAndPlay, []),
        returnValue: Future.value(true),
      );
  @override
  void stop() => super.noSuchMethod(Invocation.method(#stop, []));
  @override
  Future resume() => super.noSuchMethod(
        Invocation.method(#resume, []),
        returnValue: Future.value(),
      );
  @override
  Future pause() => super.noSuchMethod(
        Invocation.method(#pause, []),
        returnValue: Future.value(),
      );
  @override
  bool isPlaying() =>
      super.noSuchMethod(Invocation.method(#isPlaying, []), returnValue: false);
  @override
  bool isStreamingAudio() => super.noSuchMethod(
        Invocation.method(#isStreamingAudio, []),
        returnValue: false,
      );
  @override
  bool isPaused() =>
      super.noSuchMethod(Invocation.method(#isPaused, []), returnValue: false);
  @override
  void release() => super.noSuchMethod(Invocation.method(#release, []));
  @override
  double getPlaybackRate() => super.noSuchMethod(
        Invocation.method(#getPlaybackRate, []),
        returnValue: 0.0,
      );
  @override
  void setPlaybackRate(double? playbackRate) =>
      super.noSuchMethod(Invocation.method(#release, [playbackRate]));

  @override
  bool isPodcast = false;
  @override
  String currentImage = "assets/graphics/cuac-logo.png";
  @override
  String currentSong = ":";
  @override
  Episode? episode;
  @override
  Duration duration = Duration(seconds: 0);
  @override
  Duration position = Duration(seconds: 0);
  @override
  AudioPlayerState playerState = AudioPlayerState.stop;
  @override
  double playbackRate = 1.0;
}

class MockCurrentTimerContract extends Mock implements CurrentTimerContract {
  @override
  void startTimer(Duration? time) =>
      super.noSuchMethod(Invocation.method(#release, [time]));
  @override
  void stopTimer() => super.noSuchMethod(Invocation.method(#stopTimer, []));
  @override
  bool isTimerRunning() => super.noSuchMethod(
        Invocation.method(#isTimerRunning, []),
        returnValue: true,
        returnValueForMissingStub: true,
      );
  @override
  int currentTime = 0;
}

void mockTranslationsWithLocale() {
  Injector.appInstance.registerSingleton<CuacLocalization>(
    () => CuacLocalization(Locale('en', 'US')),
    override: true,
  );
}

void ignoreOverflowErrors(
  FlutterErrorDetails details, {
  bool forceReport = false,
}) {
  bool ifIsOverflowError = false;
  bool isUnableToLoadAsset = false;

  var exception = details.exception;
  if (exception is FlutterError) {
    ifIsOverflowError = !exception.diagnostics.any(
      (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
    );
    isUnableToLoadAsset = !exception.diagnostics.any(
      (e) => e.value.toString().startsWith("Unable to load asset"),
    );
  }
  if (ifIsOverflowError || isUnableToLoadAsset) {
    debugPrint('Ignored Error');
  } else {
    FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  }
}

Widget startWidget(Widget widgetToStart) {
  FlutterError.onError = ignoreOverflowErrors;
  var size = Size(768, 1024);
  return MaterialApp(
    home: MediaQuery(data: MediaQueryData(size: size), child: widgetToStart),
  );
}

void printMessages(List list) {
  list.forEach((data) {
    print(data.toString());
  });
}

void getTranslations() {
  MockTranslations translations = MockTranslations();
  Injector.appInstance.registerSingleton<CuacLocalization>(
    () => translations,
    override: true,
  );
  when(translations.translate(any)).thenReturn("");
  when(translations.getTranslations(any)).thenReturn("");
  when(translations.translateMap(any)).thenReturn(Map.identity());
}

typedef Callback(MethodCall call);

setupCloudFirestoreMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
}
