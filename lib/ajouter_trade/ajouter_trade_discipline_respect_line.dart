import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';

/// Petit texte gris : niveau de respect + aperçu des éléments non respectés.
class AjouterTradeDisciplineRespectLine extends StatelessWidget {
  const AjouterTradeDisciplineRespectLine({
    super.key,
    required this.respectPercent,
    required this.nonRespectIds,
    required this.labelForId,
    this.mutedStyle,
  });

  final double respectPercent;
  final Set<String> nonRespectIds;
  final String Function(String id) labelForId;
  final TextStyle? mutedStyle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final base = mutedStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DashboardTokens.muted,
              fontSize: 10,
              height: 1.35,
            ) ??
        const TextStyle(
          color: DashboardTokens.muted,
          fontSize: 10,
          height: 1.35,
        );
    final ids = nonRespectIds.toList()..sort();
    final labels = <String>[];
    for (var i = 0; i < ids.length && labels.length < 3; i++) {
      final x = labelForId(ids[i]).trim();
      if (x.isNotEmpty) labels.add(x);
    }
    final more = ids.length > labels.length ? ' (+${ids.length - labels.length})' : '';
    final nonRespectText = labels.isEmpty
        ? ''
        : l.ajouterTradeDisciplineRespectNonList(labels.join(', '), more);

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        '${l.ajouterTradeDisciplineRespectBase(respectPercent.round())}$nonRespectText',
        style: base.copyWith(
          color: DashboardTokens.muted.withValues(alpha: 0.92),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
