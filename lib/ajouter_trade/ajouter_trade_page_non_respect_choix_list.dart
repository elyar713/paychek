import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_page_non_respect_labels.dart';

/// Liste des éléments stratégie cochés comme non respectés (sous la carte discipline).
class AjouterTradeNonRespectChoixList extends StatelessWidget {
  const AjouterTradeNonRespectChoixList({
    super.key,
    required this.ids,
    required this.strategieChoisie,
    required this.mutedStyle,
  });

  final Set<String> ids;
  final String strategieChoisie;
  final TextStyle? mutedStyle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    if (ids.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(
          l.ajouterTradeChoicesSaved,
          style: mutedStyle?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        for (final id in ids)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.close,
                  size: 14,
                  color: DashboardTokens.negative,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    labelForStrategieNonRespectId(
                      id,
                      strategieChoisie,
                      l: l,
                      locale: locale,
                    ),
                    style: mutedStyle?.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
