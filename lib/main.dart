import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/ui/home/home_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';

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
  FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      checkerboardOffscreenLayers: false,
      title: 'CUAC FM',
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      theme: new ThemeData(
        canvasColor: Colors.white,
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
  return Scaffold(
      appBar: AppBar(
        backgroundColor: Injector.appInstance.getDependency<RadiocomColorsConract>().white,
        title: Text('Error'),
      ),
      body: Container(
          color: Injector.appInstance.getDependency<RadiocomColorsConract>().white,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Foundation.kReleaseMode
                ? Center(
                    child: Text('Whooops hubo un problema no esperado :(',
                        style: TextStyle(fontSize: 24.0)))
                : SingleChildScrollView(
                    child: Text('Exeption Details:\n\n$detailsException')),
          )));
}