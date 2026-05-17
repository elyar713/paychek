import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../questionnaire/user_capital_scope.dart';
import '../../reglage/trading_week_scope.dart';
import '../../reglage/user_portfolio_scope.dart';
import '../../trade/trade_journal_helper.dart';
import '../../trade/trade_journal_scope.dart';
import '../capital_evolution_computed.dart';
import '../dashboard_tokens.dart';
import 'dashboard_cumulative_sparkline.dart';
import 'dashboard_trade_extremes_row.dart';
import 'weekly_this_week_section.dart';

/// Courbe d’évolution + extrêmes (sans titre, montant ni compteur de trades).
class CapitalEvolutionChartSection extends StatelessWidget {
  const CapitalEvolutionChartSection({
    super.key,
    required this.timeframeIndex,
    required this.onOpenTradeById,
    this.sparklineHeight = 130,
    this.showTradeExtremes = true,
    this.extremesSpacing = 8,
  });

  final int timeframeIndex;
  final ValueChanged<String> onOpenTradeById;
  final double sparklineHeight;
  final bool showTradeExtremes;
  final double extremesSpacing;

  @override
  Widget build(BuildContext context) {
    final tradeStore = TradeJournalScope.of(context);
    final capStore = UserCapitalScope.of(context);
    final pf = UserPortfolioScope.of(context);
    final tradingWeek = TradingWeekScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([tradeStore, capStore, pf, tradingWeek]),
      builder: (context, _) {
        final allRaw = activeJournalTradesOrDemo(context);
        final data = CapitalEvolutionComputed.fromTrades(
          allRaw,
          timeframeIndex,
          tradingDaysPerWeek: tradingWeek.tradingDaysPerWeek,
        );
        final sym = pf.effectiveCurrencySymbol(capStore);

        final extremesRow = showTradeExtremes
            ? DashboardTradeExtremesRow(
                compact: true,
                mini: false,
                spacing: kIsWeb ? extremesSpacing : 10,
                onOpenTradeById: onOpenTradeById,
              )
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (kIsWeb && extremesRow != null) ...[
              extremesRow,
              const SizedBox(height: 11),
            ],
            DashboardCumulativeSparkline(
              spots: data.spots,
              spotContexts: data.spotContexts,
              minY: data.minY,
              maxY: data.maxY,
              height: sparklineHeight,
              currencySymbol: sym,
              onOpenTradeById: onOpenTradeById,
            ),
            if (!kIsWeb) ...[
              const SizedBox(height: 14),
              WeeklyThisWeekSection(
                compactOnly: true,
                compactStretchWidth: true,
                compactPart: WeeklyThisWeekCompactPart.barsOnly,
                onOpenTradeById: onOpenTradeById,
              ),
              if (extremesRow != null) ...[
                const SizedBox(height: 12),
                extremesRow,
              ],
            ],
          ],
        );
      },
    );
  }
}

/// Séparateur léger entre solde capital et courbe (mobile).
class CapitalEvolutionMergedDivider extends StatelessWidget {
  const CapitalEvolutionMergedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Divider(
          height: 1,
          thickness: 1,
          color: DashboardTokens.muted.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
