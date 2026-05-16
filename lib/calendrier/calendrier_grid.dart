import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'calendrier_constants.dart';
import 'calendrier_utils.dart';
import 'calendrier_day_cell.dart';

class CalendrierGrid extends StatelessWidget {
  const CalendrierGrid({
    super.key,
    required this.focusedMonth,
    required this.selected,
    required this.today,
    required this.pnlByDay,
    required this.tradeCountByDay,
    required this.leadingBlankDays,
    required this.daysInMonth,
    required this.languageCode,
    required this.firstDayOfWeekIndex,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime? selected;
  final DateTime today;
  final Map<int, double> pnlByDay;
  final Map<int, int> tradeCountByDay;
  final int leadingBlankDays;
  final int daysInMonth;
  final String languageCode;
  final int firstDayOfWeekIndex;
  final Function(DateTime) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final totalCells = leadingBlankDays + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final todayDate = DateTime(today.year, today.month, today.day);

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
            final cell = (w - (kDayCellGap * 6)) / 7;
            final gridHeight = cell * rowCount + (kDayCellGap * (rowCount - 1));
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
                      // Laisse le fond parent (page noire, carte web, etc.) — pas de pastille noire.
                      child = SizedBox(
                        width: cell,
                        height: cell,
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

                      child = SizedBox(
                        width: cell,
                        height: cell,
                        child: CalendrierDayCell(
                          day: day,
                          date: date,
                          isSelected: isSelected,
                          isFuture: isFuture,
                          isToday: isToday,
                          pnlByDay: pnlByDay,
                          tradeCountByDay: tradeCountByDay,
                          onTap: () => onDaySelected(date),
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
                        height: cell,
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
