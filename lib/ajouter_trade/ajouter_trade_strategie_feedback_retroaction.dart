import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../strategie/strategie_mes_regles_storage.dart';
import '../strategie/widgets/strategie_setup_card.dart';
import '../strategie/widgets/strategie_setup_tag_format.dart';

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
    const labelStyle = TextStyle(
      color: DashboardTokens.labelGrey,
      fontWeight: FontWeight.w700,
      fontSize: 9,
      letterSpacing: 0.35,
      height: 1.2,
    );
    const bodyStyle = TextStyle(
      color: DashboardTokens.onMatteEmphasis,
      fontWeight: FontWeight.w600,
      fontSize: 11,
      height: 1.38,
    );

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
        StrategieFeedbackSectionHeader(l.ajouterTradeStrategieGoldRules, labelStyle, top: 4),
        for (var i = 0; i < regles.length; i++)
          StrategieFeedbackCheckRow(
            l: l,
            id: 'mes_regles_$i',
            label: regles[i],
            bodyStyle: bodyStyle,
            estNonRespecte: nonRespectSelection.contains('mes_regles_$i'),
            onToggle: onToggleNonRespect,
          ),
        if (data != null) ...[
          StrategieFeedbackSectionHeader(
            l.ajouterTradeStrategieSetupModelsWithTitle(data!.title),
            labelStyle,
          ),
          ..._setupTagSection(
            l: l,
            sectionTitle: l.strategieTimeframes,
            idPrefix: 'setup_timeframes',
            display: data!.timeframes,
            labelStyle: labelStyle,
            bodyStyle: bodyStyle,
            nonRespectSelection: nonRespectSelection,
            onToggle: onToggleNonRespect,
          ),
          ..._setupTagSection(
            l: l,
            sectionTitle: l.strategieIndicators,
            idPrefix: 'setup_indicateurs',
            display: data!.indicateurs,
            labelStyle: labelStyle,
            bodyStyle: bodyStyle,
            nonRespectSelection: nonRespectSelection,
            onToggle: onToggleNonRespect,
          ),
          ..._setupTagSection(
            l: l,
            sectionTitle: l.ajouterTradeStrategieRowPattern,
            idPrefix: 'setup_pattern',
            display: data!.pattern,
            labelStyle: labelStyle,
            bodyStyle: bodyStyle,
            nonRespectSelection: nonRespectSelection,
            onToggle: onToggleNonRespect,
          ),
          ..._setupTagSection(
            l: l,
            sectionTitle: l.ajouterTradeStrategieRowSignal,
            idPrefix: 'setup_signal',
            display: data!.signalText,
            labelStyle: labelStyle,
            bodyStyle: bodyStyle,
            nonRespectSelection: nonRespectSelection,
            onToggle: onToggleNonRespect,
          ),
          for (var i = 0; i < data!.ruleBlocks.length; i++)
            ..._setupTagSection(
              l: l,
              sectionTitle: data!.ruleBlocks[i].heading,
              idPrefix: 'setup_rule_$i',
              display: data!.ruleBlocks[i].body,
              labelStyle: labelStyle,
              bodyStyle: bodyStyle,
              nonRespectSelection: nonRespectSelection,
              onToggle: onToggleNonRespect,
            ),
        ] else ...[
          StrategieFeedbackSectionHeader(l.ajouterTradeStrategieSetupModels, labelStyle),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              l.ajouterTradeStrategiePickStrategyHint,
              style: const TextStyle(
                color: DashboardTokens.muted,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

List<Widget> _setupTagSection({
  required AppLocalizations l,
  required String sectionTitle,
  required String idPrefix,
  required String display,
  required TextStyle labelStyle,
  required TextStyle bodyStyle,
  required Set<String> nonRespectSelection,
  required ValueChanged<String> onToggle,
}) {
  final items = strategieFeedbackItemsFromDisplay(idPrefix, display);
  if (items.isEmpty) return const [];
  return [
    StrategieFeedbackSectionHeader(sectionTitle, labelStyle, top: 6),
    ..._checkRowsForItems(
      l: l,
      items: items,
      bodyStyle: bodyStyle,
      nonRespectSelection: nonRespectSelection,
      onToggle: onToggle,
    ),
  ];
}

List<Widget> _checkRowsForItems({
  required AppLocalizations l,
  required List<StrategieFeedbackCheckItem> items,
  required TextStyle bodyStyle,
  required Set<String> nonRespectSelection,
  required ValueChanged<String> onToggle,
}) {
  return [
    for (final item in items)
      StrategieFeedbackCheckRow(
        l: l,
        id: item.id,
        label: item.label,
        bodyStyle: bodyStyle,
        estNonRespecte: nonRespectSelection.contains(item.id),
        onToggle: onToggle,
      ),
  ];
}

class StrategieFeedbackSectionHeader extends StatelessWidget {
  const StrategieFeedbackSectionHeader(
    this.titre,
    this.labelStyle, {
    super.key,
    this.top = 12,
  });

  final String titre;
  final TextStyle labelStyle;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 5),
      child: Text(
        titre,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: labelStyle.copyWith(
          fontSize: 8.5,
          letterSpacing: 0.5,
          color: DashboardTokens.muted,
        ),
      ),
    );
  }
}

class StrategieFeedbackCheckRow extends StatelessWidget {
  const StrategieFeedbackCheckRow({
    super.key,
    required this.l,
    required this.id,
    required this.label,
    required this.bodyStyle,
    required this.estNonRespecte,
    required this.onToggle,
  });

  final AppLocalizations l;
  final String id;
  final String label;
  final TextStyle bodyStyle;
  final bool estNonRespecte;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final t = label.trim();
    if (t.isEmpty || t == '—') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onToggle(id),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 4, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1, right: 8),
                  child: Semantics(
                    label: l.ajouterTradeNonRespectedSemantic(t),
                    checked: estNonRespecte,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: estNonRespecte
                                ? DashboardTokens.negative.withValues(alpha: 0.95)
                                : DashboardTokens.cardBoxBorder,
                            width: 1.5,
                          ),
                          color: estNonRespecte
                              ? DashboardTokens.negative.withValues(alpha: 0.2)
                              : Colors.transparent,
                        ),
                        child: estNonRespecte
                            ? const Icon(
                                Icons.check,
                                size: 11,
                                color: DashboardTokens.negative,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    t,
                    style: bodyStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: estNonRespecte
                          ? DashboardTokens.negative.withValues(alpha: 0.92)
                          : bodyStyle.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
