import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../questionnaire/user_capital_scope.dart';
import '../../reglage/trading_week_scope.dart';
import '../../reglage/user_portfolio_scope.dart';
import '../../trade/trade_journal_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../trade/trade_journal_scope.dart';
import '../../calendrier/calendrier_utils.dart';
import '../../web/paychek_web_tokens.dart';
import '../capital_evolution_computed.dart';
import '../dashboard_tokens.dart';
import 'capital_evolution_chart_section.dart';
import 'timeframe_pills.dart';
import 'weekly_this_week_section.dart';

class CapitalEvolutionCard extends StatelessWidget {
  const CapitalEvolutionCard({
    super.key,
    required this.timeframeIndex,
    required this.onTimeframeChanged,
    required this.onOpenTradeById,
    this.hideTimeframePills = false,
    this.cardDecoration,
    this.webPairStretch = false,
  });

  final int timeframeIndex;
  final ValueChanged<int> onTimeframeChanged;
  final ValueChanged<String> onOpenTradeById;
  final bool hideTimeframePills;
  final BoxDecoration? cardDecoration;

  /// Web : ligne jumelée Capital + Evolution — remplit la hauteur commune.
  final bool webPairStretch;

  @override
  Widget build(BuildContext context) {
    final tradeStore = TradeJournalScope.of(context);
    final capStore = UserCapitalScope.of(context);
    final pf = UserPortfolioScope.of(context);
    final tradingWeek = TradingWeekScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([tradeStore, capStore, pf, tradingWeek]),
      builder: (context, _) {
            final l = AppLocalizations.of(context)!;
            final tfLabels = [
              l.dashboardTfDay,
              l.dashboardTfWeek,
              l.dashboardTfMonth,
              l.dashboardTfAll,
            ];
            final allRaw = activeJournalTradesOrDemo(context);
            final data = CapitalEvolutionComputed.fromTrades(
              allRaw,
              timeframeIndex,
              tradingDaysPerWeek: tradingWeek.tradingDaysPerWeek,
            );
            final sym = pf.effectiveCurrencySymbol(capStore);

            final tradesLine = Text(
              l
                  .dashboardEvolutionTradesThisPeriod(data.tradeCount)
                  .toUpperCase(),
              maxLines: 2,
              style: GoogleFonts.plusJakartaSans(
                color: PaychekWebTokens.textGray500,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.95,
                height: 1.25,
              ),
            );

            Widget amountHeading() {
              return Text(
                formatMoneyWithCurrencySymbol(data.periodNet, sym),
                style: GoogleFonts.plusJakartaSans(
                  color: data.periodNet < 0
                      ? DashboardTokens.negative
                      : PaychekWebTokens.accentMint,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  height: 1.04,
                ),
              );
            }

            final chartSection = CapitalEvolutionChartSection(
              timeframeIndex: timeframeIndex,
              onOpenTradeById: onOpenTradeById,
              sparklineHeight: 122,
              showTradeExtremes: false,
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                // En scroll web, la hauteur parente est souvent non bornée : pas de
                // [Expanded] ni de `height: infinity` (assertion box.dart + écran noir).
                final stretchChart = webPairStretch &&
                    kIsWeb &&
                    constraints.hasBoundedHeight &&
                    constraints.maxHeight.isFinite;

                return Container(
                  width: double.infinity,
                  padding: DashboardTokens.cardPadding,
                  decoration: cardDecoration ?? DashboardTokens.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize:
                        stretchChart ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      if (kIsWeb) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                l.dashboardCapitalEvolutionTitle.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: PaychekWebTokens.textGray500,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            if (!hideTimeframePills)
                              TimeframePills(
                                labels: tfLabels,
                                selectedIndex: timeframeIndex,
                                onChanged: onTimeframeChanged,
                              ),
                          ],
                        ),
                        const SizedBox(height: 11),
                      ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  amountHeading(),
                                  const SizedBox(height: 6),
                                  tradesLine,
                                ],
                              ),
                              Expanded(
                                child: Align(
                                  alignment: const Alignment(-0.22, 1),
                                  child: WeeklyThisWeekSection(
                                    compactOnly: true,
                                    compactPart:
                                        WeeklyThisWeekCompactPart.barsOnly,
                                  ),
                                ),
                              ),
                              WeeklyThisWeekSection(
                                compactOnly: true,
                                compactPart:
                                    WeeklyThisWeekCompactPart.extremesOnly,
                                includeTradeExtremes: true,
                                onOpenTradeById: onOpenTradeById,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      if (stretchChart)
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, chartConstraints) {
                              final chartH = chartConstraints.maxHeight
                                  .clamp(72.0, double.infinity);
                              return CapitalEvolutionChartSection(
                                timeframeIndex: timeframeIndex,
                                onOpenTradeById: onOpenTradeById,
                                sparklineHeight: chartH,
                                showTradeExtremes: false,
                              );
                            },
                          ),
                        )
                      else
                        chartSection,
                    ],
                  ),
                );
              },
            );
      },
    );
  }
}



