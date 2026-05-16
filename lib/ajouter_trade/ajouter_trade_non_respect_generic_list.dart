import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';

/// Affiche une liste simple des choix cochés (non respectés), sous une case.
class AjouterTradeNonRespectGenericList extends StatelessWidget {
  const AjouterTradeNonRespectGenericList({
    super.key,
    required this.ids,
    required this.labelForId,
    required this.mutedStyle,
  });

  final Set<String> ids;
  final String Function(String id) labelForId;
  final TextStyle? mutedStyle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                    labelForId(id),
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

