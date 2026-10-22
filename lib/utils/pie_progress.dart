import 'dart:math' as math;
import 'package:flutter/material.dart';

class PieProgress extends StatelessWidget {
  final double progress;
  final bool completed;
  final double size;
  final Color color;

  const PieProgress({
    Key? key,
    required this.progress,
    required this.completed,
    required this.color,
    this.size = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final value = completed ? 1.0 : progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PiePainter(value, color)),
    );
  }
}

class _PiePainter extends CustomPainter {
  final double value;
  final Color color;

  _PiePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;

    final background = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, background);

    if (value > 0.0) {
      final fill = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, -math.pi / 2, value * 2 * math.pi, true, fill);
    }

    final border = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 0.5, border);
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.value != value || old.color != color;
}
