import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/translations/localizations_delegate.dart';
import 'package:cuacfm/ui/home/home_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder =
      (FlutterErrorDetails details) => errorScreen(details.exception);
  DependencyInjector().loadModules();
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.recordFlutterError(details);
  };
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseInAppMessaging firebaseInAppMessaging = FirebaseInAppMessaging();
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
        const Locale('pt','PT')
      ],
      localizationsDelegates: [
        LocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      localeResolutionCallback: (Locale locale, Iterable<Locale> supportedLocales) {
        if(locale!=null) {
          for (Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode ||
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
        primaryColorBrightness: Brightness.light,
      ),
      darkTheme: ThemeData(primaryColorBrightness: Brightness.dark,
        canvasColor: Colors.black,primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Benvida a CUAC FM'),
    );
  }
}

Widget errorScreen(dynamic detailsException) {
  var _localization = Injector.appInstance.getDependency<CuacLocalization>();
  return Scaffold(
      appBar: AppBar(
        backgroundColor: Injector.appInstance.getDependency<RadiocomColorsConract>().white,
        title: Text(SafeMap.safe(_localization.translateMap('error'),
            ["title"])),
      ),
      body: Container(
          color: Injector.appInstance.getDependency<RadiocomColorsConract>().white,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Foundation.kReleaseMode
                ? Center(
                    child: Text(SafeMap.safe(_localization.translateMap('error'),
                        ["message"]),
                        style: TextStyle(fontSize: 24.0)))
                : SingleChildScrollView(
                    child: Text('Exeption Details:\n\n$detailsException')),
          )));
}