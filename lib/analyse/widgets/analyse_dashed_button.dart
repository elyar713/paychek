import 'package:flutter/material.dart';

import '../analyse_tokens.dart';

class AnalyseDashedButton extends StatelessWidget {
  const AnalyseDashedButton({
    super.key,
    required this.label,
    required this.onTap,
    this.compact = false,
    /// Même hauteur fixe pour une paire côte à côte (ex. Support / Résistance).
    /// Ne pas utiliser [SizedBox.expand] ici : dans un [ListView], la hauteur est
    /// non bornée et provoquerait une erreur de layout (écran noir).
    this.fillExpandedSlot = false,
  });

  final String label;
  final VoidCallback onTap;
  /// Hauteur réduite (ex. ligne « + Ajouter Support »).
  final bool compact;
  final bool fillExpandedSlot;

  @override
  Widget build(BuildContext context) {
    final pad = compact
        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 10)
        : const EdgeInsets.symmetric(vertical: 14, horizontal: 14);
    final fs = compact ? 11.0 : 13.0;
    const compactPairH = 46.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusField),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFF2B2B2B),
            radius: AnalyseTokens.radiusField,
          ),
          child: Container(
            width: double.infinity,
            height: (compact && fillExpandedSlot) ? compactPairH : null,
            padding: pad,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AnalyseTokens.fieldBg,
              borderRadius: BorderRadius.circular(AnalyseTokens.radiusField),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: compact ? 2 : 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AnalyseTokens.muted,
                fontWeight: FontWeight.w700,
                fontSize: fs,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;

    const dash = 6.0;
    const gap = 5.0;
    final path = Path()..addRRect(r);
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        final len = (d + dash < m.length) ? dash : (m.length - d);
        canvas.drawPath(m.extractPath(d, d + len), p);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

