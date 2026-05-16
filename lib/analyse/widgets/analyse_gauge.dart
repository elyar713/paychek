import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../analyse_tokens.dart';

/// Confiance globale (même logique que [AnalyseGauge]).
int computeAnalyseGlobalConfidencePercent({
  required int feuille,
  required int structure,
  required int indicators,
  required int smc,
  required int impactFeuille,
  required int impactStructure,
  required int impactIndicators,
  required int impactSmc,
  required bool contextEnabled,
  required bool structureEnabled,
  required bool indicatorsEnabled,
  required bool smcEnabled,
}) {
  final f = feuille.clamp(0, 100);
  final s = structure.clamp(0, 100);
  final i = indicators.clamp(0, 100);
  final m = smc.clamp(0, 100);

  final wf = contextEnabled ? impactFeuille.clamp(0, 100) : 0;
  final ws = structureEnabled ? impactStructure.clamp(0, 100) : 0;
  final wi = indicatorsEnabled ? impactIndicators.clamp(0, 100) : 0;
  final wm = smcEnabled ? impactSmc.clamp(0, 100) : 0;

  final wSum = wf + ws + wi + wm;
  if (wSum > 0) {
    return ((f * wf + s * ws + i * wi + m * wm) / wSum).round().clamp(0, 100);
  }
  var sum = 0;
  var n = 0;
  if (contextEnabled) {
    sum += f;
    n++;
  }
  if (structureEnabled) {
    sum += s;
    n++;
  }
  if (indicatorsEnabled) {
    sum += i;
    n++;
  }
  if (smcEnabled) {
    sum += m;
    n++;
  }
  return n <= 0 ? 0 : (sum / n).round().clamp(0, 100);
}

class AnalyseGauge extends StatelessWidget {
  const AnalyseGauge({
    super.key,
    required this.feuille,
    required this.structure,
    required this.indicators,
    required this.smc,
    required this.impactFeuille,
    required this.impactStructure,
    required this.impactIndicators,
    required this.impactSmc,
    required this.contextEnabled,
    required this.structureEnabled,
    required this.indicatorsEnabled,
    required this.smcEnabled,
  });

  final int feuille;
  final int structure;
  final int indicators;
  final int smc;
  final int impactFeuille;
  final int impactStructure;
  final int impactIndicators;
  final int impactSmc;
  /// Sections « on » : seules elles entrent dans la confiance globale.
  final bool contextEnabled;
  final bool structureEnabled;
  final bool indicatorsEnabled;
  final bool smcEnabled;

  Color _colorFor(int p) => AnalyseTokens.confidenceColorForPercent(p);

  @override
  Widget build(BuildContext context) {
    final p = computeAnalyseGlobalConfidencePercent(
      feuille: feuille,
      structure: structure,
      indicators: indicators,
      smc: smc,
      impactFeuille: impactFeuille,
      impactStructure: impactStructure,
      impactIndicators: impactIndicators,
      impactSmc: impactSmc,
      contextEnabled: contextEnabled,
      structureEnabled: structureEnabled,
      indicatorsEnabled: indicatorsEnabled,
      smcEnabled: smcEnabled,
    );
    final color = _colorFor(p);

    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(110),
            painter: _GaugePainter(
              percent: p / 100.0,
              color: color,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$p%',
                style: const TextStyle(
                  color: AnalyseTokens.matteText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'CONFIANCE',
                style: TextStyle(
                  color: AnalyseTokens.muted2,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.percent,
    required this.color,
  });

  final double percent;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final stroke = 8.0;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF1B1B1B);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    const start = -math.pi / 2;
    const sweepMax = math.pi * 2;
    final rect = Rect.fromCircle(center: c, radius: r - stroke / 2);

    canvas.drawArc(rect, start, sweepMax, false, bg);
    canvas.drawArc(rect, start, sweepMax * percent.clamp(0.0, 1.0), false, fg);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percent != percent || oldDelegate.color != color;
  }
}

