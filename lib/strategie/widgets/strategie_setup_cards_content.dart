import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../strategie_tokens.dart';
import '../strategie_setups_store.dart';
import 'strategie_setup_card.dart';
import 'strategie_setup_rule_styles.dart';

/// Cartes par défaut « Setups & modèles » (SMC : corps « — » si non figé).
List<StrategieSetupCardData> strategieSetupDefaultCardDataList() {
  return [
    StrategieSetupCardData(
      title: 'Breakout with Volume',
      dotColor: StrategieTokens.emerald,
      timeframes: 'M15, H1',
      indicateurs: 'Volume, EMA 50',
      pattern: 'Consolidation below Resistance / Triangle',
      signalText: 'Resistance breakout with volume spike',
      signalColor: StrategieTokens.emerald,
      ruleBlocks: [
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.crosshair,
          heading: 'PRECISE ENTRY',
          body:
              'M15 candle close above the key level with above-average volume.',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.shield,
          heading: 'INVALIDATION (STOP LOSS)',
          body: 'Placed just below the breakout candle wick.',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.circleDot,
          heading: 'CIBLE (TAKE PROFIT)',
          body: 'Next liquidity zone or major resistance (min RR 1:2).',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.lock,
          heading: 'GESTION (BREAKEVEN / PARTIELS)',
          body: 'Once price reaches +1R profit, move SL to entry.',
        ),
      ],
    ),
    StrategieSetupCardData(
      title: 'SMC – Order Block',
      dotColor: const Color(0xFF42A5F5),
      timeframes: 'H4, M15',
      indicateurs: 'Liquidity Purge, FVG',
      pattern: 'Order Block',
      signalText: 'Price taps the H4 OB + M15 rejection',
      signalColor: const Color(0xFF42A5F5),
      ruleBlocks: [
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.crosshair,
          heading: 'PRECISE ENTRY',
          body: '—',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.shield,
          heading: 'INVALIDATION (STOP LOSS)',
          body: '—',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.circleDot,
          heading: 'CIBLE (TAKE PROFIT)',
          body: '—',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.lock,
          heading: 'GESTION (BREAKEVEN / PARTIELS)',
          body: '—',
        ),
      ],
    ),
    StrategieSetupCardData(
      title: 'Head and Shoulders (Pullback)',
      dotColor: const Color(0xFFFFB74D),
      timeframes: 'H1, M30',
      indicateurs: 'RSI Divergence, Volume',
      pattern: 'Head-Shoulders (Classic/Inverse)',
      signalText: 'Neckline breakout with volume',
      signalColor: const Color(0xFFFFB74D),
      ruleBlocks: [
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.crosshair,
          heading: 'PRECISE ENTRY',
          body: 'Buy/Sell on the neckline retest (pullback).',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.shield,
          heading: 'INVALIDATION (STOP LOSS)',
          body: 'Above/below the last (right) shoulder.',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.circleDot,
          heading: 'CIBLE (TAKE PROFIT)',
          body: 'Head-to-neck distance projected from the breakout point.',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.lock,
          heading: 'GESTION (BREAKEVEN / PARTIELS)',
          body: 'Take 50% partial at midpoint and move SL to breakeven.',
        ),
      ],
    ),
  ];
}

/// Carte dont [title] correspond au titre affiché, sinon `null`.
StrategieSetupCardData? strategieSetupCardDataPourTitre(String title) {
  final live = StrategieSetupsStore.notifier.value;
  for (final d in live) {
    if (d.title == title) return d;
  }
  for (final d in strategieSetupDefaultCardDataList()) {
    if (d.title == title) return d;
  }
  return null;
}

/// Cartes « Setups & modèles » — affichage seul (sans menu ⋮ section).
class StrategieSetupCardsContent extends StatelessWidget {
  const StrategieSetupCardsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = strategieSetupDefaultCardDataList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          StrategieSetupCard(
            title: cards[i].title,
            dotColor: cards[i].dotColor,
            timeframes: cards[i].timeframes,
            indicateurs: cards[i].indicateurs,
            pattern: cards[i].pattern,
            signalText: cards[i].signalText,
            signalColor: cards[i].signalColor,
            ruleBlocks: cards[i].ruleBlocks,
          ),
        ],
      ],
    );
  }
}
