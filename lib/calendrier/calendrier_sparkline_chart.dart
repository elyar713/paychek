import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/capital_evolution_computed.dart';
import '../dashboard/widgets/dashboard_cumulative_sparkline.dart';
import '../l10n/app_localizations.dart';
import '../shared/month_detail_expandable_card.dart';
import '../trade/trade_models.dart';
import 'calendrier_constants.dart';
import 'calendrier_month_pills.dart';
import 'calendrier_utils.dart';

/// Panneau droit : courbe cumulée, stats, carte détail du mois (sans pilules de mois).
class CalendrierPerformancePanel extends StatelessWidget {
  const CalendrierPerformancePanel({
    super.key,
    required this.pnlByDay,
    required this.daysInMonth,
    required this.capSymbol,
    required this.focusedMonth,
    required this.tradeCountByDay,
    required this.allTrades,
    required this.initialCapital,
    required this.monthlyObjective,
    this.onExportMonthPdf,
    this.onTradeSelected,
    this.liteInteractionLocked = false,
    this.onLiteInteractionLockedTap,
  });

  final Map<int, double> pnlByDay;
  final int daysInMonth;
  final String capSymbol;
  final DateTime focusedMonth;
  final Map<int, int> tradeCountByDay;
  final List<TradeListItem> allTrades;
  final double? initialCapital;
  final double? monthlyObjective;
  final Future<void> Function()? onExportMonthPdf;
  final void Function(TradeListItem)? onTradeSelected;
  final bool liteInteractionLocked;
  final VoidCallback? onLiteInteractionLockedTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final curve = CapitalEvolutionComputed.forFocusedCalendarMonth(
      allTrades,
      focusedMonth,
    );

    final onOpen =
        (onTradeSelected == null || liteInteractionLocked)
            ? null
            : (String id) {
                for (final t in allTrades) {
                  if (t.id == id) {
                    onTradeSelected!(t);
                    return;
                  }
                }
              };

    var bestDay = 0.0;
    var tradingDays = 0;
    var totalPnL = 0.0;

    for (final entry in pnlByDay.entries) {
      final pnl = entry.value;
      if (pnl > bestDay) bestDay = pnl;
      if (pnl != 0) {
        tradingDays++;
        totalPnL += pnl;
      }
    }

    final averagePnL = tradingDays > 0 ? totalPnL / tradingDays : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.calCumulativePerformanceTitle,
          style: GoogleFonts.inter(
            color: kWeekdayColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          decoration: BoxDecoration(
            color: kCalCardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kCalCardBorderResolved),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardCumulativeSparkline(
                spots: curve.spots,
                spotContexts: curve.spotContexts,
                minY: curve.minY,
                maxY: curve.maxY,
                height: 86,
                currencySymbol: capSymbol,
                onOpenTradeById: onOpen,
                onInteractionLockedTap: liteInteractionLocked
                    ? onLiteInteractionLockedTap
                    : null,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1',
                    style: GoogleFonts.inter(
                      color: kWeekdayColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(daysInMonth / 2).round()}',
                    style: GoogleFonts.inter(
                      color: kWeekdayColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$daysInMonth',
                    style: GoogleFonts.inter(
                      color: kWeekdayColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _calSparklineStatCard(l.calBestDay, bestDay, capSymbol),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _calSparklineStatCard(
                l.calTradingDays,
                tradingDays.toDouble(),
                '',
                isCount: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _calSparklineStatCard(
                l.calAverageShort,
                averagePnL,
                capSymbol,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            try {
              return MonthDetailExpandableCard(
                monthStart: focusedMonth,
                monthTrades: allTrades
                    .where(
                      (t) =>
                          t.entreeAt.year == focusedMonth.year &&
                          t.entreeAt.month == focusedMonth.month,
                    )
                    .toList(),
                currencySymbol: capSymbol,
                initialCapital: initialCapital,
                onExportPdf: onExportMonthPdf ?? () async {},
                onTradeSelected: liteInteractionLocked ? null : onTradeSelected,
                onExpandHeaderLockedTap: liteInteractionLocked
                    ? onLiteInteractionLockedTap
                    : null,
              );
            } catch (e) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kCalCardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kCalCardBorderResolved),
                ),
                child: Text(
                  l.calChartError(e.toString()),
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

Widget _calSparklineStatCard(
  String label,
  double value,
  String symbol, {
  bool isCount = false,
}) {
  final valueColor =
      isCount ? Colors.white : (value >= 0 ? kGainText : kLossText);

  final displayValue =
      isCount
          ? value.toInt().toString()
          : formatMoneyWithCurrencySymbol(value, symbol);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: kCalCardSurface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kCalCardBorderResolved),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: kWeekdayColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayValue,
          style: GoogleFonts.inter(
            color: valueColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

/// Version « colonne unique » : panneau + pilules de navigation par mois.
class CalendrierSparklineChart extends StatelessWidget {
  const CalendrierSparklineChart({
    super.key,
    required this.pnlByDay,
    required this.daysInMonth,
    required this.capSymbol,
    required this.focusedMonth,
    required this.tradeCountByDay,
    required this.allTrades,
    required this.onMonthChanged,
    required this.initialCapital,
    required this.monthlyObjective,
    this.onExportMonthPdf,
    this.onTradeSelected,
  });

  final Map<int, double> pnlByDay;
  final int daysInMonth;
  final String capSymbol;
  final DateTime focusedMonth;
  final Map<int, int> tradeCountByDay;
  final List<TradeListItem> allTrades;
  final ValueChanged<DateTime> onMonthChanged;
  final double? initialCapital;
  final double? monthlyObjective;
  final Future<void> Function()? onExportMonthPdf;
  final void Function(TradeListItem)? onTradeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalendrierPerformancePanel(
          pnlByDay: pnlByDay,
          daysInMonth: daysInMonth,
          capSymbol: capSymbol,
          focusedMonth: focusedMonth,
          tradeCountByDay: tradeCountByDay,
          allTrades: allTrades,
          initialCapital: initialCapital,
          monthlyObjective: monthlyObjective,
          onExportMonthPdf: onExportMonthPdf,
          onTradeSelected: onTradeSelected,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: CalendrierMonthPills(
            allTrades: allTrades,
            currentMonth: focusedMonth,
            capSymbol: capSymbol,
            initialCapital: initialCapital,
            monthlyObjective: monthlyObjective,
            onMonthSelected: onMonthChanged,
          ),
        ),
      ],
    );
  }
}
