import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';

/// Carte en tête de feuille : autorisation Feeling pour les blocs discipline.
class AjouterTradeDisciplineFeelingCard extends StatelessWidget {
  const AjouterTradeDisciplineFeelingCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: DashboardTokens.scaffoldMatte,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? DashboardTokens.titleGold.withValues(alpha: 0.55)
              : DashboardTokens.cardBoxBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DashboardTokens.negative.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 20,
              color: value ? DashboardTokens.negative : DashboardTokens.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.ajouterTradeDisciplineFeelingModeTitle,
                  style: textTheme.titleSmall?.copyWith(
                    color: DashboardTokens.onMatteEmphasis,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.ajouterTradeDisciplineFeelingAllowSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: DashboardTokens.muted,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: DashboardTokens.onMatteEmphasis,
            activeTrackColor: DashboardTokens.negative.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}

/// Ligne section + interrupteur (Stratégie, plan, etc.).
class AjouterTradeDisciplineSectionSwitchTile extends StatelessWidget {
  const AjouterTradeDisciplineSectionSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: DashboardTokens.cardBoxBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(
                          color: DashboardTokens.onMatteEmphasis,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: DashboardTokens.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: DashboardTokens.onMatteEmphasis,
                  activeTrackColor:
                      DashboardTokens.accent.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
