import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../calendrier/calendrier_utils.dart';
import '../../questionnaire/user_capital_scope.dart';
import '../../reglage/trading_week_scope.dart';
import '../../reglage/user_portfolio_scope.dart';
import '../../trade/trade_journal_helper.dart';
import '../../trade/trade_journal_scope.dart';
import '../../trade/trade_stats.dart';
import '../../l10n/app_localizations.dart';
import '../../trade/trade_week_utils.dart';
import '../dashboard_tokens.dart';
import 'dashboard_trade_extremes_row.dart';

/// Barres semaine (carte évolution web) : slot jour / épaisseur barre / hauteur max.
const double kCompactWeekBarSlotWidth = 34.0;
const double kCompactWeekBarThickness = 14.0;
const double kCompactWeekBarMaxHeight = 50.0;

/// Sous-ensemble affiché en mode [compactOnly] (carte évolution capital web).
enum WeeklyThisWeekCompactPart {
  barsAndExtremes,
  barsOnly,
  extremesOnly,
}

/// Contenu « This week » — textes + barres, ou [compactOnly] : barres ± extrêmes journal.
class WeeklyThisWeekSection extends StatelessWidget {
  const WeeklyThisWeekSection({
    super.key,
    this.compactOnly = false,
    this.compactPart = WeeklyThisWeekCompactPart.barsAndExtremes,
    this.compactStretchWidth = false,
    this.includeTradeExtremes = false,
    this.onOpenTradeById,
  });

  final bool compactOnly;
  final WeeklyThisWeekCompactPart compactPart;

  /// Barres compactes sur toute la largeur (mobile sous la sparkline).
  final bool compactStretchWidth;

  /// Dans [compactOnly] : meilleur trade / grosse perte (sauf [compactPart] dédié).
  final bool includeTradeExtremes;
  final ValueChanged<String>? onOpenTradeById;

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
        final maxBar = compactOnly ? kCompactWeekBarMaxHeight : 56.0;

        final todayIdx = tradeTodayIndexInWeekDays(days);

        Color barFill(int i) {
          final v = i < dailyNet.length ? dailyNet[i] : 0.0;
          final traded = i < dailyCount.length && dailyCount[i] > 0;
          if (!traded) return const Color(0xFF333333);
          if (v < 0) return DashboardTokens.negative;
          if (v > 0) return DashboardTokens.accent;
          return DashboardTokens.muted;
        }

        final bars = _WeeklyThisWeekBars(
          daysLength: days.length,
          dayLabels: dayLabels,
          weekDays: days,
          dailyNet: dailyNet,
          dailyCount: dailyCount,
          maxBar: maxBar,
          denom: denom,
          todayIdx: todayIdx,
          barFill: barFill,
          dense: compactOnly,
          currencySymbol: sym,
        );

        if (compactOnly) {
          final showExtremes = includeTradeExtremes &&
              onOpenTradeById != null &&
              compactPart != WeeklyThisWeekCompactPart.barsOnly;
          final barsWidth = days.length * kCompactWeekBarSlotWidth;
          final barsBox = SizedBox(width: barsWidth, child: bars);
          final extremesBox = showExtremes
              ? DashboardTradeExtremesRow(
                  compact: true,
                  mini: true,
                  vertical: false,
                  spacing: 8,
                  onOpenTradeById: onOpenTradeById!,
                )
              : null;

          switch (compactPart) {
            case WeeklyThisWeekCompactPart.barsOnly:
              return compactStretchWidth
                  ? bars
                  : barsBox;
            case WeeklyThisWeekCompactPart.extremesOnly:
              return extremesBox ?? const SizedBox.shrink();
            case WeeklyThisWeekCompactPart.barsAndExtremes:
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  barsBox,
                  if (extremesBox != null) ...[
                    const SizedBox(width: 10),
                    extremesBox,
                  ],
                ],
              );
          }
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
            bars,
          ],
        );
      },
    );
  }
}

class _WeeklyThisWeekBars extends StatelessWidget {
  const _WeeklyThisWeekBars({
    required this.daysLength,
    required this.dayLabels,
    required this.weekDays,
    required this.dailyNet,
    required this.dailyCount,
    required this.maxBar,
    required this.denom,
    required this.todayIdx,
    required this.barFill,
    required this.currencySymbol,
    this.dense = false,
  });

  final int daysLength;
  final List<String> dayLabels;
  final List<DateTime> weekDays;
  final List<double> dailyNet;
  final List<int> dailyCount;
  final double maxBar;
  final double denom;
  final int todayIdx;
  final Color Function(int i) barFill;
  final String currencySymbol;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final labelGap = dense ? 5.0 : 6.0;
    final labelSize = dense ? 8.5 : 9.0;
    final padH = dense ? 2.0 : 3.0;
    final barThickness = dense ? kCompactWeekBarThickness : null;
    final minBarH = dense ? 8.0 : 6.0;
    final totalH = maxBar + labelGap + labelSize * 1.25 + 2;

    return SizedBox(
      height: totalH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(daysLength, (i) {
          final v = i < dailyNet.length ? dailyNet[i] : 0.0;
          final count = i < dailyCount.length ? dailyCount[i] : 0;
          final traded = count > 0;
          final barH = traded
              ? (maxBar * (v.abs() / denom)).clamp(minBarH, maxBar)
              : minBarH;
          final isToday = todayIdx >= 0 && i == todayIdx;
          final day = weekDays[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH),
              child: _WeekBarDaySlot(
                index: i,
                day: day,
                dayLabel: dayLabels[i],
                net: v,
                tradeCount: count,
                maxBar: maxBar,
                barHeight: barH,
                barThickness: barThickness,
                labelGap: labelGap,
                labelSize: labelSize,
                isToday: isToday,
                barColor: barFill(i),
                dense: dense,
                currencySymbol: currencySymbol,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Une colonne jour : barre + survol (web) / appui (mobile) → infobulle PnL + trades.
class _WeekBarDaySlot extends StatefulWidget {
  const _WeekBarDaySlot({
    required this.index,
    required this.day,
    required this.dayLabel,
    required this.net,
    required this.tradeCount,
    required this.maxBar,
    required this.barHeight,
    required this.barThickness,
    required this.labelGap,
    required this.labelSize,
    required this.isToday,
    required this.barColor,
    required this.dense,
    required this.currencySymbol,
  });

  final int index;
  final DateTime day;
  final String dayLabel;
  final double net;
  final int tradeCount;
  final double maxBar;
  final double barHeight;
  final double? barThickness;
  final double labelGap;
  final double labelSize;
  final bool isToday;
  final Color barColor;
  final bool dense;
  final String currencySymbol;

  @override
  State<_WeekBarDaySlot> createState() => _WeekBarDaySlotState();
}

class _WeekBarDaySlotState extends State<_WeekBarDaySlot> {
  bool _hovered = false;

  void _setHovered(bool v) {
    if (_hovered == v) return;
    setState(() => _hovered = v);
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.maxBar,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: widget.barThickness ?? double.infinity,
              height: widget.barHeight,
              decoration: BoxDecoration(
                color: widget.barColor,
                borderRadius: BorderRadius.circular(widget.dense ? 4 : 6),
                border: widget.isToday
                    ? Border.all(
                        color: DashboardTokens.titleGold.withValues(alpha: 0.85),
                        width: 1.2,
                      )
                    : null,
              ),
            ),
          ),
        ),
        SizedBox(height: widget.labelGap),
        Text(
          widget.dayLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: widget.labelSize,
            height: 1.1,
            fontWeight: FontWeight.w600,
            color: widget.isToday
                ? DashboardTokens.titleGold
                : DashboardTokens.muted,
          ),
        ),
      ],
    );

    return MouseRegion(
      cursor: SystemMouseCursors.help,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _setHovered(true),
        onPointerUp: (_) {
          if (!kIsWeb) {
            Future<void>.delayed(const Duration(milliseconds: 2200), () {
              if (mounted) _setHovered(false);
            });
          }
        },
        onPointerCancel: (_) => _setHovered(false),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            column,
            if (_hovered)
              Positioned(
                left: widget.dense ? -18 : -24,
                right: widget.dense ? -18 : -24,
                bottom: widget.maxBar + widget.labelGap - 2,
                child: _WeekBarHoverCard(
                  day: widget.day,
                  tradeCount: widget.tradeCount,
                  net: widget.net,
                  currencySymbol: widget.currencySymbol,
                  compact: widget.dense,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekBarHoverCard extends StatelessWidget {
  const _WeekBarHoverCard({
    required this.day,
    required this.tradeCount,
    required this.net,
    required this.currencySymbol,
    this.compact = false,
  });

  final DateTime day;
  final int tradeCount;
  final double net;
  final String currencySymbol;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final mat = MaterialLocalizations.of(context);
    final dayTitle = mat.formatCompactDate(day);
    final tradesLine = tradeCount == 1
        ? l.dashboardTradeOne
        : l.dashboardTradeCount(tradeCount);
    final pnlLine = formatMoneyWithCurrencySymbol(net, currencySymbol);
    final pnlColor = tradeCount == 0
        ? DashboardTokens.muted
        : (net < 0
            ? DashboardTokens.negative
            : (net > 0 ? DashboardTokens.accent : DashboardTokens.onMatteEmphasis));

    return Material(
      color: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xE6181820),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 6 : 8,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: compact ? 76 : 88,
              maxWidth: compact ? 160 : 200,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayTitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  tradesLine,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                ),
                if (tradeCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    pnlLine,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: pnlColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
