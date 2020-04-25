import 'dart:math';

import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

class Wave extends StatefulWidget {
  final Size size;
  final bool shouldAnimate;

  const Wave({Key key, @required this.size, @required this.shouldAnimate}) : super(key: key);

  @override
  WaveState createState() => WaveState();
}

class WaveState extends State<Wave> with SingleTickerProviderStateMixin {

  List<Offset> _points;
  AnimationController _controller;

  RadiocomColorsConract _colors;

  @override
  Widget build(BuildContext context) {
    _colors = Injector.appInstance.getDependency<RadiocomColorsConract>();
    if(widget.shouldAnimate){
      _controller.repeat();
    } else {
      _controller.stop();
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child){
        return ClipPath(
          clipper: WaveClipper(_controller.value, _points),
          child: Container(color:_colors.yellow, height: widget.size.height, width:widget.size.width),
        );
      },
    );
  }

  @override
  void initState(){
    super.initState();
    _controller =
        AnimationController(
          duration: const Duration(seconds: 2),
          vsync: this,
          upperBound: 2* pi
        );
    _initPoints();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }


  void _initPoints(){
    _points = [];
    Random r = Random();
    for(int i=0;i<widget.size.width;i++) {
      double x = i.toDouble();
      double y = r.nextDouble() * (widget.size.height);
      _points.add(Offset(x,y));
    }
  }
}

class WaveClipper extends CustomClipper<Path> {
  double _value;
  List<Offset> _wavePoints;

  WaveClipper(this._value,this._wavePoints);

  @override
  Path getClip(Size size) {
    var path = Path();
    _modulateRadom(size);
    path.addPolygon(_wavePoints, false);

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }


  _modulateRadom(Size size){
    final maxDiff = 3.0;
    Random r = Random();
    for(int i=0; i<size.width;i++){
      var point = _wavePoints[i];

      double diff = maxDiff - r.nextDouble() * maxDiff * 2.0;

      double newY = max(0.4, point.dy + diff);
      newY = min(size.height, newY);

      Offset newPoint = Offset(i.toDouble(),newY);
      _wavePoints[i] = newPoint;
    }
  }

}
