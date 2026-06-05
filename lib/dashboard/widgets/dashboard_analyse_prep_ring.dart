import 'package:flutter/material.dart';

import '../../analyse/analyse_prep_checks.dart';
import '../../analyse/analyse_report_snapshot.dart';
import '../../analyse/analyse_tokens.dart';
import 'donut_ring.dart';

/// Anneau routine pré-trade (carte Capital, rapport figé, etc.).
class DashboardAnalysePrepRing extends StatelessWidget {
  const DashboardAnalysePrepRing({
    super.key,
    required this.snapshot,
    this.size = 38,
    this.strokeWidth,
    this.ringColor,
    this.trackColor,
    this.onTap,
    this.centerSecondary,
  });

  final AnalyseReportSnapshot snapshot;
  final double size;
  final double? strokeWidth;
  final Color? ringColor;
  final Color? trackColor;
  final VoidCallback? onTap;
  final String? centerSecondary;

  @override
  Widget build(BuildContext context) {
    final applicable = applicablePrepCheckIdsFromSnapshot(snapshot);
    if (applicable.isEmpty) return const SizedBox.shrink();
    final prepPct = resolvePlanPrepCompletionPercent(snapshot);
    final secondary = centerSecondary?.trim();
    return DonutRing(
      progress: prepPct / 100,
      centerPrimary: '$prepPct%',
      centerSecondary: secondary,
      showInnerSecondary: secondary != null && secondary.isNotEmpty,
      size: size,
      strokeWidth: strokeWidth ?? (size > 44 ? 4 : 3),
      ringColor: ringColor ?? AnalyseTokens.accentGreen,
      trackColor: trackColor ?? const Color(0xFF2A2A2A),
      onTap: onTap,
    );
  }
}
