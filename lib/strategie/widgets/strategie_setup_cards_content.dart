import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../strategie_tokens.dart';
import '../strategie_setups_store.dart';
import 'strategie_setup_card.dart';

/// Couleur titres blocs règles (maquette).
const Color strategieSetupRuleHeadingTan = Color(0xFFD4A574);

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
        StrategieSetupRuleBlock(
          icon: LucideIcons.crosshair,
          heading: 'PRECISE ENTRY',
          headingColor: strategieSetupRuleHeadingTan,
          body:
              'M15 candle close above the key level with above-average volume.',
        ),
        StrategieSetupRuleBlock(
          icon: LucideIcons.shield,
          heading: 'INVALIDATION (STOP LOSS)',
          headingColor: StrategieTokens.riskRed,
          body: 'Placed just below the breakout candle wick.',
        ),
        StrategieSetupRuleBlock(
          icon: LucideIcons.circleDot,
          heading: 'CIBLE (TAKE PROFIT)',
          headingColor: StrategieTokens.emerald,
          body: 'Next liquidity zone or major resistance (min RR 1:2).',
        ),
        StrategieSetupRuleBlock(
          icon: LucideIcons.lock,
          heading: 'GESTION (BREAKEVEN / PARTIELS)',
          headingColor: StrategieTokens.labelMuted,
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
        StrategieSetupRuleBlock(
          icon: LucideIcons.crosshair,
          heading: 'PRECISE ENTRY',
          headingColor: strategieSetupRuleHeadingTan,
          body: '—',
        ),
        StrategieSetupRuleBlock(
          icon: LucideIcons.shield,
          heading: 'INVALIDATION (STOP LOSS)',
          headingColor: StrategieTokens.riskRed,
          body: '—',
        ),
        StrategieSetupRuleBlock(
          icon: LucideIcons.circleDot,
          heading: 'CIBLE (TAKE PROFIT)',
          headingColor: StrategieTokens.emerald,
          body: '—',
        ),
        StrategieSetupRuleBlock(
          icon: LucideIcons.lock,
          heading: 'GESTION (BREAKEVEN / PARTIELS)',
          headingColor: StrategieTokens.labelMuted,
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
        StrategieSetupRuleBlock(
          icon: LucideIcons.crosshair,
          heading: 'PRECISE ENTRY',
          headingColor: strategieSetupRuleHeadingTan,
          body: 'Buy/Sell on the neckline retest (pullback).',
        ),
        StrategieSetupRuleBlock(
          icon: LucideIcons.shield,
          heading: 'INVALIDATION (STOP LOSS)',
          headingColor: StrategieTokens.riskRed,
          body: 'Above/below the last (right) shoulder.',
        ),
        StrategieSetupRuleBlock(
          icon: LucideIcons.circleDot,
          heading: 'CIBLE (TAKE PROFIT)',
          headingColor: StrategieTokens.emerald,
          body: 'Head-to-neck distance projected from the breakout point.',
        ),
        StrategieSetupRuleBlock(
          icon: LucideIcons.lock,
          heading: 'GESTION (BREAKEVEN / PARTIELS)',
          headingColor: StrategieTokens.labelMuted,
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
