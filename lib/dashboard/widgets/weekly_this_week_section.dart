import 'package:flutter/material.dart';

import '../../questionnaire/user_capital_scope.dart';
import '../../reglage/trading_week_scope.dart';
import '../../reglage/user_portfolio_scope.dart';
import '../../trade/trade_journal_helper.dart';
import '../../trade/trade_journal_scope.dart';
import '../../trade/trade_stats.dart';
import '../../l10n/app_localizations.dart';
import '../../trade/trade_week_utils.dart';
import '../dashboard_tokens.dart';

/// Contenu « This week » (résultat, winrate, barres) — sans cadre externe (carte [WebDashboardPairedCard]).
class WeeklyThisWeekSection extends StatelessWidget {
  const WeeklyThisWeekSection({super.key});

  static String _formatSignedMoney(double v, String currencySymbol) {
    final s = v >= 0 ? '+' : '';
    return '$s${v.toStringAsFixed(2).replaceAll('.', ',')} $currencySymbol';
  }

  @override
  Widget build(BuildContext context) {
    final store = TradeJournalScope.of(context);
    final capStore = UserCapitalScope.of(context);
    final pf = UserPortfolioScope.of(context);
    final tradingWeek = TradingWeekScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([store, capStore, pf, tradingWeek]),
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        final dayShort = [
          l.dashboardWeekdayShortMon,
          l.dashboardWeekdayShortTue,
          l.dashboardWeekdayShortWed,
          l.dashboardWeekdayShortThu,
          l.dashboardWeekdayShortFri,
          l.dashboardWeekdayShortSat,
          l.dashboardWeekdayShortSun,
        ];
        final sym = pf.effectiveCurrencySymbol(capStore);
        final allRaw = activeJournalTradesOrDemo(context);
        final days = tradeCurrentWeekDaysLocal(
          tradingDaysPerWeek: tradingWeek.tradingDaysPerWeek,
        );
        final dayLabels = dayShort.sublist(0, days.length);
        final dailyNet = tradeDailyNetForDays(allRaw, days);
        final dailyCount = tradeDailyCountForDays(allRaw, days);
        final net = dailyNet.fold<double>(0.0, (a, b) => a + b);
        final weekTrades = tradesWithEntreeOnDays(allRaw, days);
        final winPct = computeTradeStats(weekTrades).winRatePctDisplay;

        final maxAbs = dailyNet
            .map((e) => e.abs())
            .fold<double>(0.0, (a, b) => a > b ? a : b);
        final denom = maxAbs <= 0 ? 1.0 : maxAbs;
        const maxBar = 56.0;

        final todayIdx = tradeTodayIndexInWeekDays(days);

        Color barFill(int i) {
          final v = i < dailyNet.length ? dailyNet[i] : 0.0;
          final traded = i < dailyCount.length && dailyCount[i] > 0;
          if (!traded) return const Color(0xFF333333);
          if (v < 0) return DashboardTokens.negative;
          if (v > 0) return DashboardTokens.accent;
          return DashboardTokens.muted;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.dashboardWeekThisWeek,
                        style: const TextStyle(
                          color: DashboardTokens.labelGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: l.dashboardWeekResultPrefix,
                              style: TextStyle(
                                  color: DashboardTokens.muted, fontSize: 13),
                            ),
                            TextSpan(
                              text: _formatSignedMoney(net, sym),
                              style: TextStyle(
                                color: net < 0
                                    ? DashboardTokens.negative
                                    : (net == 0
                                        ? DashboardTokens.onMatteEmphasis
                                        : DashboardTokens.accent),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l.winrate,
                      style:
                          TextStyle(color: DashboardTokens.muted, fontSize: 11),
                    ),
                    Text(
                      '$winPct%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: maxBar + 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(days.length, (i) {
                  final v = i < dailyNet.length ? dailyNet[i] : 0.0;
                  final traded = i < dailyCount.length && dailyCount[i] > 0;
                  final barH = traded
                      ? (maxBar * (v.abs() / denom)).clamp(6.0, maxBar)
                      : 6.0;
                  final isToday = todayIdx >= 0 && i == todayIdx;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: maxBar,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                height: barH,
                                decoration: BoxDecoration(
                                  color: barFill(i),
                                  borderRadius: BorderRadius.circular(6),
                                  border: isToday
                                      ? Border.all(
                                          color: DashboardTokens.titleGold
                                              .withValues(alpha: 0.85),
                                          width: 1.2,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dayLabels[i],
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? DashboardTokens.titleGold
                                  : DashboardTokens.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
