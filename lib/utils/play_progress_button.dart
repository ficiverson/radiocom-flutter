import 'package:flutter/material.dart';

class PlayProgressButton extends StatelessWidget {
  final double progress;
  final bool completed;
  final Widget child;
  final double size;
  final Color color;

  const PlayProgressButton({
    Key? key,
    required this.progress,
    required this.completed,
    required this.child,
    required this.color,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final value = completed ? 1.0 : progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 2.5,
              backgroundColor: color.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
