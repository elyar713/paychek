import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mental_state_tokens.dart';

/// Anneau score global + libellé « STATE » + statut + sous-titre indicateurs.
class MentalStateOverallGauge extends StatelessWidget {
  const MentalStateOverallGauge({
    super.key,
    required this.score,
    required this.strokeColor,
    required this.centerTextColor,
    required this.gaugeBottomLabel,
    required this.statusLine,
    required this.basedOnLine,
    required this.statusColor,
    this.gaugeDiameter,
  });

  final double score;
  final Color strokeColor;
  final Color centerTextColor;
  /// e.g. STATE / ÉTAT — from [AppLocalizations.mentalGaugeStateLabel].
  final String gaugeBottomLabel;
  /// Ex. « En pleine forme » (couleur [statusColor]).
  final String statusLine;
  /// Ex. « Basé sur N indicateurs » (gris).
  final String basedOnLine;
  final Color statusColor;
  final double? gaugeDiameter;

  @override
  Widget build(BuildContext context) {
    final d = gaugeDiameter ?? MentalStateTokens.gaugeSize;
    final p = (score / 100).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: d,
          height: d,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(d),
                painter: MentalStateOverallGaugePainter(
                  progress: p,
                  strokeColor: strokeColor,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${score.round()}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: d >= 140 ? 34 : 32,
                      fontWeight: FontWeight.w700,
                      color: centerTextColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gaugeBottomLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF888888),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          statusLine,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: statusColor,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          basedOnLine,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B6B6B),
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class MentalStateOverallGaugePainter extends CustomPainter {
  MentalStateOverallGaugePainter({
    required this.progress,
    required this.strokeColor,
  });

  final double progress;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const stroke = 2.5;
    final r = size.shortestSide / 2 - stroke / 2;
    final bg = Paint()
      ..color = MentalStateTokens.trackBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(c, r, bg);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final fg = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant MentalStateOverallGaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.strokeColor != strokeColor;
}
