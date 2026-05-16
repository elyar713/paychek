import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard_tokens.dart';
import 'donut_ring.dart';

/// Grille 2Ã—2 : Psychologie, StratÃ©gie, Ratio R/R, Gain moyen.
class StatsGridSection extends StatelessWidget {
  const StatsGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.statsSectionTitle,
          style: const TextStyle(
            color: DashboardTokens.labelGrey,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.88,
          children: [
            _StatDonutCard(
              progress: 0.85,
              center: '85%',
              title: l.statsPsychology,
              subtitle: l.statsPsychSub,
            ),
            _StatDonutCard(
              progress: 0.70,
              center: '70%',
              title: l.statsStrategy,
              subtitle: l.statsStrategySub,
            ),
            _StatDonutCard(
              progress: 0.75,
              center: '1:2.5',
              title: l.statsRR,
              subtitle: null,
            ),
            _StatDonutCard(
              progress: 0.65,
              center: '180 â‚¬',
              title: l.statsAvgGain,
              subtitle: null,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatDonutCard extends StatelessWidget {
  const _StatDonutCard({
    required this.progress,
    required this.center,
    required this.title,
    this.subtitle,
  });

  final double progress;
  final String center;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: DashboardTokens.cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DonutRing(
            progress: progress,
            centerPrimary: center,
            centerSecondary: null,
            size: 82,
            strokeWidth: 6,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: DashboardTokens.muted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}



