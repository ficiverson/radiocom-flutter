import 'dart:math';

import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

class EqualizerIcon extends StatefulWidget {
  final double size;
  final Color? color;

  const EqualizerIcon({Key? key, this.size = 24.0, this.color})
      : super(key: key);

  @override
  State<EqualizerIcon> createState() => _EqualizerIconState();
}

class _EqualizerIconState extends State<EqualizerIcon>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<double> _minHeights = [0.3, 0.2, 0.4];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (400 + i * 120)),
      )..repeat(reverse: true);
    });

    _animations = List.generate(3, (i) {
      return Tween<double>(begin: _minHeights[i], end: 1.0).animate(
        CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut),
      );
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RadiocomColorsConract colors =
        Injector.appInstance.get<RadiocomColorsConract>();
    final Color barColor = widget.color ?? colors.yellow;
    final double totalWidth = widget.size;
    final double barWidth = totalWidth * 0.22;
    final double gap = totalWidth * 0.08;
    final double maxHeight = widget.size;

    return AnimatedBuilder(
      animation: _controllers[0],
      builder: (_, __) {
        return SizedBox(
          width: totalWidth,
          height: maxHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (i) {
              return Container(
                width: barWidth,
                height: maxHeight * _animations[i].value,
                margin: EdgeInsets.symmetric(horizontal: gap / 2),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class Wave extends StatefulWidget {
  final Size size;
  final bool shouldAnimate;

  const Wave({Key? key, required this.size, required this.shouldAnimate})
      : super(key: key);

  @override
  WaveState createState() => WaveState();
}

class WaveState extends State<Wave> with SingleTickerProviderStateMixin {
  late List<Offset> _points;
  late AnimationController _controller;

  late RadiocomColorsConract _colors;

  @override
  Widget build(BuildContext context) {
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    if (widget.shouldAnimate) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ClipPath(
          clipper: WaveClipper(_points),
          child: Container(
              color: _colors.yellow,
              height: widget.size.height,
              width: widget.size.width),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(seconds: 2), vsync: this, upperBound: 2 * pi);
    _initPoints();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initPoints() {
    _points = [];
    Random r = Random();
    for (int i = 0; i < widget.size.width; i++) {
      double x = i.toDouble();
      double y = r.nextDouble() * (widget.size.height);
      _points.add(Offset(x, y));
    }
  }
}

class WaveClipper extends CustomClipper<Path> {
  List<Offset> _wavePoints;

  WaveClipper(this._wavePoints);

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

  _modulateRadom(Size size) {
    final maxDiff = 2.5;
    Random r = Random();
    for (int i = 0; i < size.width; i++) {
      var point = _wavePoints[i];
      double diff = maxDiff - r.nextDouble() * maxDiff * 2.0;

      double newY = max(0.2, point.dy + diff);
      newY = min(size.height, newY);

      Offset newPoint = Offset(i.toDouble(), newY);
      _wavePoints[i] = newPoint;
    }
  }
}
