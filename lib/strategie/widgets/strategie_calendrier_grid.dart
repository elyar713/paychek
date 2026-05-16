import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../calendrier/calendrier_constants.dart';
import '../../calendrier/calendrier_utils.dart';
import '../../trade/trade_models.dart';
import '../strategie_calendrier_marks.dart' show buildStrategieCalendrierMarksForDay;
import 'strategie_calendrier_day_cell.dart';

/// Grille : points = stratégies **réellement tradées** ce jour (journal) + marques manuelles.
class StrategieCalendrierGrid extends StatelessWidget {
  const StrategieCalendrierGrid({
    super.key,
    required this.focusedMonth,
    required this.selected,
    required this.today,
    required this.journalTrades,
    required this.usageBySetupTitle,
    required this.selectedSetupTitle,
    required this.leadingBlankDays,
    required this.daysInMonth,
    required this.languageCode,
    required this.firstDayOfWeekIndex,
    required this.onDaySelected,
    required this.onToggleSelectedUsage,
    this.rowHeightFactor = 1.38,
  });

  final DateTime focusedMonth;
  final DateTime? selected;
  final DateTime today;

  /// Trades du portefeuille actif (même source qu’« Ajouter trade »).
  final List<TradeListItem> journalTrades;

  /// Marques manuelles (optionnel) — même structure que [StrategieSetupUsageStore].
  final Map<String, Set<int>> usageBySetupTitle;

  final String selectedSetupTitle;
  final int leadingBlankDays;
  final int daysInMonth;
  final String languageCode;
  final int firstDayOfWeekIndex;
  final ValueChanged<DateTime> onDaySelected;
  final void Function(DateTime day) onToggleSelectedUsage;

  final double rowHeightFactor;

  List<StrategieCalendrierDayMark> _marksForDayKey(int dayKey) {
    return buildStrategieCalendrierMarksForDay(
      forDayKey: dayKey,
      trades: journalTrades,
      usageByTitle: usageBySetupTitle,
    );
  }

  Map<int, double> _strategiePctByDayKey() {
    final sum = <int, double>{};
    final n = <int, int>{};
    for (final t in journalTrades) {
      final d = DateTime(t.entreeAt.year, t.entreeAt.month, t.entreeAt.day);
      final dk = dayKey(d);
      final v = t.strategiePct;
      // strategiePct est toujours défini dans TradeListItem, mais on garde un garde-fou.
      if (v.isNaN || v.isInfinite) continue;
      sum[dk] = (sum[dk] ?? 0) + v;
      n[dk] = (n[dk] ?? 0) + 1;
    }
    final out = <int, double>{};
    for (final e in sum.entries) {
      final count = n[e.key] ?? 0;
      if (count <= 0) continue;
      out[e.key] = e.value / count;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final totalCells = leadingBlankDays + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final todayDate = DateTime(today.year, today.month, today.day);
    final pctByDayKey = _strategiePctByDayKey();

    final weekdayStyle = GoogleFonts.inter(
      color: kWeekdayColor,
      fontSize: kWeekdayFontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.25,
      height: 1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(7, (i) {
            final idx = (firstDayOfWeekIndex + i) % 7;
            return Expanded(
              child: Center(
                child: Text(
                  weekdayOneLetter(idx, languageCode),
                  style: weekdayStyle,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cellW = (w - (kDayCellGap * 6)) / 7;
            final cellH = cellW * rowHeightFactor;
            final gridHeight =
                cellH * rowCount + (kDayCellGap * (rowCount - 1));
            return SizedBox(
              width: w,
              height: gridHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(rowCount, (row) {
                  final rowChildren = <Widget>[];
                  for (var col = 0; col < 7; col++) {
                    final i = row * 7 + col - leadingBlankDays;
                    Widget child;
                    if (i < 0 || i >= daysInMonth) {
                      child = SizedBox(
                        width: cellW,
                        height: cellH,
                      );
                    } else {
                      final day = i + 1;
                      final date = DateTime(
                        focusedMonth.year,
                        focusedMonth.month,
                        day,
                      );
                      final isSelected = selected != null &&
                          date.year == selected!.year &&
                          date.month == selected!.month &&
                          date.day == selected!.day;
                      final isFuture = date.isAfter(todayDate);
                      final isToday = date.year == todayDate.year &&
                          date.month == todayDate.month &&
                          date.day == todayDate.day;
                      final dk = dayKey(date);
                      final marks = _marksForDayKey(dk);
                      final pct = pctByDayKey[dk];

                      child = SizedBox(
                        width: cellW,
                        height: cellH,
                        child: StrategieCalendrierDayCell(
                          day: day,
                          date: date,
                          isSelected: isSelected,
                          isFuture: isFuture,
                          isToday: isToday,
                          marks: marks,
                          strategiePct: pct,
                          selectedSetupTitle: selectedSetupTitle,
                          onToggleSelectedUsage: () =>
                              onToggleSelectedUsage(date),
                          onSelectDay: () => onDaySelected(date),
                        ),
                      );
                    }
                    rowChildren.add(child);
                    if (col < 6) {
                      rowChildren.add(const SizedBox(width: kDayCellGap));
                    }
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: cellH,
                        child: Row(children: rowChildren),
                      ),
                      if (row < rowCount - 1)
                        const SizedBox(height: kDayCellGap),
                    ],
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}
