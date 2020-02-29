import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/ui/home/home_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) => errorScreen(details.exception);
  DependencyInjector().loadModules();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      checkerboardOffscreenLayers: false,
      title: 'CUAC FM',
      theme: new ThemeData(
        canvasColor: RadiocomColors.palidwhite,
        primarySwatch: Colors.grey,
        primaryColorBrightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: new MyHomePage(title: 'Benvida a CUAC FM'),
    );
  }
}

Widget errorScreen(dynamic detailsException) {
  return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Error'),
      ),
      body: Container(color: Colors.white, child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Foundation.kReleaseMode ? Center(child: Text('Whooops hubo un problema no esperado :(', style: TextStyle(fontSize: 24.0))) : SingleChildScrollView(child: Text('Exeption Details:\n\n$detailsException')),
      ))
  );
}

/*

migration steps:

- no connection handling
- loading states and error handling in a good way  in home:)
-refresh foreground/background

- put player from sonica

- podcast detail

- finish tab menu (contact, history, gallery?, social networks, maps, web, t&c licenses, pp)

*/