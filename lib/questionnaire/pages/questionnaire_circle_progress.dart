import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Anneau de progression circulaire (Profil, Global, etc.).
class QuestionnaireCircleProgress extends StatelessWidget {
  const QuestionnaireCircleProgress({
    super.key,
    required this.percentage,
    required this.label,
    this.size = 118,
    this.strokeWidth = 7,
    this.progressColor = Colors.white,
    this.trackColor = const Color(0x33FFFFFF),
  });

  /// 0–100
  final double percentage;
  final String label;
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final p = (percentage / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: _RingPainter(
                    progress: p,
                    strokeWidth: strokeWidth,
                    progressColor: progressColor,
                    trackColor: trackColor,
                  ),
                ),
                Text(
                  '${percentage.round()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: size * 0.17,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w300,
              fontSize: 13,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, progPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
