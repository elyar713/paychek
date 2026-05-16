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
import 'dashboard_cumulative_sparkline.dart';
import 'dashboard_trade_extremes_row.dart';
import 'timeframe_pills.dart';

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

            final tradesLine = kIsWeb
                ? Text(
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
                  )
                : Text(
                    data.tradeCount == 1
                        ? l.dashboardTradeOne
                        : l.dashboardTradeCount(data.tradeCount),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: 11,
                          color: DashboardTokens.labelGrey,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ) ??
                        const TextStyle(
                          fontSize: 11,
                          color: DashboardTokens.labelGrey,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                  );

            Widget amountHeading() {
              if (kIsWeb) {
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
              final color = data.periodNet < 0
                  ? DashboardTokens.negative
                  : (data.periodNet == 0
                      ? DashboardTokens.onMatteEmphasis
                      : DashboardTokens.accent);
              return Text(
                formatMoneyWithCurrencySymbol(data.periodNet, sym),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  height: 1.05,
                ),
              );
            }

            return Container(
              width: double.infinity,
              padding: DashboardTokens.cardPadding,
              decoration: cardDecoration ?? DashboardTokens.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          kIsWeb
                              ? l.dashboardCapitalEvolutionTitle.toUpperCase()
                              : l.dashboardCapitalEvolutionTitle,
                          style: kIsWeb
                              ? GoogleFonts.plusJakartaSans(
                                  color: PaychekWebTokens.textGray500,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                )
                              : const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
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
                  SizedBox(height: kIsWeb ? 11 : 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 54,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            amountHeading(),
                            SizedBox(height: kIsWeb ? 6 : 5),
                            tradesLine,
                          ],
                        ),
                      ),
                      SizedBox(width: kIsWeb ? 8 : 6),
                      Expanded(
                        flex: 46,
                        child: DashboardTradeExtremesRow(
                          compact: true,
                          spacing: kIsWeb ? 6 : 8,
                          onOpenTradeById: onOpenTradeById,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: kIsWeb ? 10 : 11),
                  // Pas de [Expanded] ici quand parent = [IntrinsicHeight] (rangée Capital+Évolution web) :
                  // les flex sont exclus du calcul intrinsèque → hauteur 0 pour la courbe.
                  DashboardCumulativeSparkline(
                    spots: data.spots,
                    spotContexts: data.spotContexts,
                    minY: data.minY,
                    maxY: data.maxY,
                    height: kIsWeb ? 122 : 130,
                    currencySymbol: sym,
                    onOpenTradeById: onOpenTradeById,
                  ),
                  if (!kIsWeb) const SizedBox(height: 4),
                ],
              ),
            );
      },
    );
  }
}



