import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../strategie/strategie_mes_regles_storage.dart';
import '../strategie/widgets/strategie_setup_card.dart';
import '../strategie/widgets/strategie_setup_tag_format.dart';
import 'ajouter_trade_feedback_category_buttons.dart';

/// Ligne « point à revoir » : un id stable + le libellé affiché (un élément / tag).
class StrategieFeedbackCheckItem {
  const StrategieFeedbackCheckItem({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

List<StrategieFeedbackCheckItem> strategieFeedbackItemsFromDisplay(
  String idPrefix,
  String display,
) {
  final tags = strategieSetupDisplayToTags(display);
  if (tags.isEmpty) return const [];
  return [
    for (var i = 0; i < tags.length; i++)
      StrategieFeedbackCheckItem(
        id: '${idPrefix}_$i',
        label: tags[i],
      ),
  ];
}

List<AjouterTradeFeedbackCategory> strategieFeedbackCategoriesFor({
  required AppLocalizations l,
  required Locale locale,
  required StrategieSetupCardData? data,
}) {
  final categories = <AjouterTradeFeedbackCategory>[];
  final regles = StrategieMesReglesStore.rulesForLocale(locale);
  if (regles.isNotEmpty) {
    categories.add(
      AjouterTradeFeedbackCategory(
        id: 'mes_regles',
        title: l.ajouterTradeStrategieGoldRules,
        items: [
          for (var i = 0; i < regles.length; i++)
            AjouterTradeFeedbackItem(id: 'mes_regles_$i', label: regles[i]),
        ],
      ),
    );
  }

  if (data == null) return categories;

  void addSetupSection(
    String categoryId,
    String title,
    String idPrefix,
    String display,
  ) {
    final items = strategieFeedbackItemsFromDisplay(idPrefix, display);
    if (items.isEmpty) return;
    categories.add(
      AjouterTradeFeedbackCategory(
        id: categoryId,
        title: title,
        items: [
          for (final it in items)
            AjouterTradeFeedbackItem(id: it.id, label: it.label),
        ],
      ),
    );
  }

  addSetupSection(
    'setup_timeframes',
    l.strategieTimeframes,
    'setup_timeframes',
    data.timeframes,
  );
  addSetupSection(
    'setup_indicateurs',
    l.strategieIndicators,
    'setup_indicateurs',
    data.indicateurs,
  );
  addSetupSection(
    'setup_pattern',
    l.ajouterTradeStrategieRowPattern,
    'setup_pattern',
    data.pattern,
  );
  addSetupSection(
    'setup_signal',
    l.ajouterTradeStrategieRowSignal,
    'setup_signal',
    data.signalText,
  );
  for (var i = 0; i < data.ruleBlocks.length; i++) {
    addSetupSection(
      'setup_rule_$i',
      data.ruleBlocks[i].heading,
      'setup_rule_$i',
      data.ruleBlocks[i].body,
    );
  }
  return categories;
}

/// Contenu déroulant : bravo / liste de contrôle « non respect » selon le % stratégie.
class AjouterTradeStrategieFeedbackRetroactionBody extends StatelessWidget {
  const AjouterTradeStrategieFeedbackRetroactionBody({
    super.key,
    required this.p,
    required this.data,
    required this.nonRespectSelection,
    required this.onToggleNonRespect,
  });

  final int p;
  final StrategieSetupCardData? data;
  final Set<String> nonRespectSelection;
  final ValueChanged<String> onToggleNonRespect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    if (p >= 100) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        decoration: BoxDecoration(
          color: DashboardTokens.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: DashboardTokens.accent.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          l.ajouterTradeStrategieFeedbackBravo,
          style: const TextStyle(
            color: DashboardTokens.accent,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      );
    }

    if (p >= 95) {
      return Text(
        l.ajouterTradeFeedbackAlmost100,
        style: const TextStyle(
          color: DashboardTokens.muted,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          height: 1.35,
        ),
      );
    }

    final regles = StrategieMesReglesStore.rulesForLocale(locale);
    final categories = strategieFeedbackCategoriesFor(
      l: l,
      locale: locale,
      data: data,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.ajouterTradeStrategieFeedbackWhichMissed,
          style: TextStyle(
            color: DashboardTokens.negative.withValues(alpha: 0.92),
            fontWeight: FontWeight.w800,
            fontSize: 11,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.ajouterTradeFeedbackTickEach,
          style: const TextStyle(
            color: DashboardTokens.muted,
            fontWeight: FontWeight.w600,
            fontSize: 10,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        if (categories.isEmpty && regles.isEmpty && data == null)
          Text(
            l.ajouterTradeStrategiePickStrategyHint,
            style: const TextStyle(
              color: DashboardTokens.muted,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.35,
            ),
          )
        else
          AjouterTradeFeedbackCategoryButtons(
            categories: categories,
            selectedIds: nonRespectSelection,
            onToggle: onToggleNonRespect,
          ),
      ],
    );
  }
}
