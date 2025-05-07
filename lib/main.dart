import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/translations/localizations_delegate.dart';
import 'package:cuacfm/ui/home/home_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:injector/injector.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder =
      (FlutterErrorDetails details) => errorScreen(details.exception);
  DependencyInjector().loadModules();
  await Firebase.initializeApp();
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  //Setting SysemUIOverlay
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark));

  //Setting SystmeUIMode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top]);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Media player',
    androidNotificationOngoing: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseInAppMessaging firebaseInAppMessaging =
      FirebaseInAppMessaging.instance;
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      checkerboardOffscreenLayers: false,
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('es', 'ES'),
        const Locale('gl', 'ES'),
        const Locale('pt', 'PT')
      ],
      localizationsDelegates: [
        LocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        if (locale != null) {
          for (Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
        }
        return supportedLocales.first;
      },
      title: 'CUAC FM',
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      theme: new ThemeData(
          canvasColor: Colors.transparent,
          primarySwatch: Colors.grey,
          brightness: Brightness.light),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        canvasColor: Colors.black,
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Benvida a CUAC FM'),
    );
  }
}

Widget errorScreen(dynamic detailsException) {
  var _localization = Injector.appInstance.get<CuacLocalization>();
  return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Injector.appInstance.get<RadiocomColorsConract>().white,
        title:
            Text(SafeMap.safe(_localization.translateMap('error'), ["title"])),
      ),
      body: Container(
          color: Injector.appInstance.get<RadiocomColorsConract>().white,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Foundation.kReleaseMode
                ? Center(
                    child: Text(
                        SafeMap.safe(
                            _localization.translateMap('error'), ["message"]),
                        style: TextStyle(fontSize: 24.0)))
                : SingleChildScrollView(
                    child: Text('Exception Details:\n\n$detailsException')),
          )));
}
