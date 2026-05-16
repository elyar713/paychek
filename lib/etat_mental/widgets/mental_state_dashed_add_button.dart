import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MentalStateDashedAddButton extends StatelessWidget {
  const MentalStateDashedAddButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: _size,
          height: _size,
          child: CustomPaint(
            painter: _DashedCirclePainter(
              color: const Color(0xFF333333),
              strokeWidth: 1,
              dash: 4,
              gap: 3,
            ),
            child: const Center(
              child: Icon(LucideIcons.plus, size: 14, color: Color(0xFF777777)),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(inset, inset, size.width - strokeWidth, size.height - strokeWidth);
    final path = Path()..addOval(rect);
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final len = math.min(dash, metric.length - d);
        final extract = metric.extractPath(d, d + len);
        canvas.drawPath(
          extract,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth,
        );
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dash != dash ||
      oldDelegate.gap != gap;
}
