import 'package:cuacfm/ui/home/homeView.dart';
import 'package:flutter/material.dart';

void main() {
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
        primarySwatch: Colors.orange,
        primaryColorBrightness: Brightness.light,
      ),
      home: new MyHomePage(title: 'Benvida a CUAC FM'),
    );
  }
}