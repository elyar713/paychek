import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../dashboard/evolution_spot.dart';
import 'paychek_web_tokens.dart';

/// Courbe lissée (spline) + dégradé sous la ligne pour l’évolution du capital (web).
class WebEvolutionSplineChart extends StatelessWidget {
  const WebEvolutionSplineChart({
    super.key,
    required this.spots,
    required this.minY,
    required this.maxY,
    this.height = 96,
  });

  final List<EvolutionSpot> spots;
  final double minY;
  final double maxY;
  final double height;

  @override
  Widget build(BuildContext context) {
    final mint = PaychekWebTokens.accentMint;

    if (spots.isEmpty) {
      return SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF0D0D0D),
          ),
        ),
      );
    }

    var flSpots = [
      for (final s in spots) FlSpot(s.x, s.y),
    ];
    if (flSpots.length == 1) {
      final only = flSpots.first;
      flSpots = [
        FlSpot(only.x - 0.5, only.y),
        FlSpot(only.x + 0.5, only.y),
      ];
    }

    final xs = flSpots.map((s) => s.x);
    final minX = xs.reduce(math.min);
    final maxX = xs.reduce(math.max);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(right: 4, top: 4, bottom: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LineChart(
            LineChartData(
              clipData: const FlClipData.all(),
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              backgroundColor: Colors.transparent,
              lineBarsData: [
                LineChartBarData(
                  spots: flSpots,
                  isCurved: true,
                  curveSmoothness: 0.4,
                  preventCurveOverShooting: true,
                  color: mint,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        mint.withValues(alpha: 0.42),
                        mint.withValues(alpha: 0.14),
                        mint.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ],
              lineTouchData: const LineTouchData(enabled: false),
            ),
            duration: Duration.zero,
          ),
        ),
      ),
    );
  }
}
