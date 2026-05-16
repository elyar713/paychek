import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../dashboard_tokens.dart';

/// Mini-grille du mois (navigation, sélection d’un jour) pour la carte « This week ».
class DashboardMiniMonthCalendar extends StatefulWidget {
  const DashboardMiniMonthCalendar({
    super.key,
    required this.selected,
    required this.onDaySelected,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onDaySelected;

  @override
  State<DashboardMiniMonthCalendar> createState() =>
      _DashboardMiniMonthCalendarState();
}

class _DashboardMiniMonthCalendarState extends State<DashboardMiniMonthCalendar> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(widget.selected.year, widget.selected.month);
  }

  @override
  void didUpdateWidget(covariant DashboardMiniMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _focusedMonth = DateTime(widget.selected.year, widget.selected.month);
    }
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  int _leadingBlankDays(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final firstColDart =
        loc.firstDayOfWeekIndex == 0 ? 7 : loc.firstDayOfWeekIndex;
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    return ((first.weekday - firstColDart) % 7 + 7) % 7;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.yMMM(locale).format(_focusedMonth);
    final loc = MaterialLocalizations.of(context);
    final narrow = loc.narrowWeekdays;
    final firstIdx = loc.firstDayOfWeekIndex;
    final weekdayOrder = List<String>.generate(7, (i) {
      final idx = (firstIdx + i) % 7;
      return narrow[idx];
    });

    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final leading = _leadingBlankDays(context);
    final totalCells = leading + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final sel = DateTime(
      widget.selected.year,
      widget.selected.month,
      widget.selected.day,
    );

    const headerStyle = TextStyle(
      color: DashboardTokens.onMatteEmphasis,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    const dowStyle = TextStyle(
      color: DashboardTokens.labelGrey,
      fontSize: 7,
      fontWeight: FontWeight.w600,
    );
    const dayStyle = TextStyle(
      color: DashboardTokens.muted,
      fontSize: 8,
      fontWeight: FontWeight.w500,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _MiniNavIcon(icon: Icons.chevron_left, onTap: _prevMonth),
            Expanded(
              child: Text(
                monthLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: headerStyle,
              ),
            ),
            _MiniNavIcon(icon: Icons.chevron_right, onTap: _nextMonth),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: weekdayOrder
              .map(
                (w) => Expanded(
                  child: Center(
                    child: Text(w, style: dowStyle),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 2),
        for (int r = 0; r < rows; r++)
          SizedBox(
            height: 18,
            child: Row(
              children: List.generate(7, (c) {
                final cellIndex = r * 7 + c;
                final dayNum = cellIndex - leading + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                final d = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month,
                  dayNum,
                );
                final isSel = d.year == sel.year &&
                    d.month == sel.month &&
                    d.day == sel.day;
                final isToday = d == todayNorm;

                Color fg = DashboardTokens.muted;
                if (isSel) {
                  fg = DashboardTokens.titleGold;
                } else if (isToday) {
                  fg = DashboardTokens.onMatteEmphasis;
                }

                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onDaySelected(d),
                      borderRadius: BorderRadius.circular(4),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 1,
                          ),
                          decoration: isSel
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: DashboardTokens.titleGold
                                        .withValues(alpha: 0.85),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                )
                              : null,
                          child: Text(
                            '$dayNum',
                            style: dayStyle.copyWith(color: fg),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _MiniNavIcon extends StatelessWidget {
  const _MiniNavIcon({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          icon,
          size: 16,
          color: DashboardTokens.labelGrey,
        ),
      ),
    );
  }
}
