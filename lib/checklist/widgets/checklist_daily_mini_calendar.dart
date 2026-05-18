import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../calendrier/calendrier_utils.dart' as cal;
import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_month.dart';
import '../../trade/trade_models.dart';
import '../checklist_calendar_day_colors.dart';
import '../checklist_page_controller.dart';

/// Mini-calendrier : % checklist du jour + couleur du chiffre selon P&L.
class ChecklistDailyMiniCalendar extends StatefulWidget {
  const ChecklistDailyMiniCalendar({
    super.key,
    required this.controller,
    required this.trades,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final ChecklistPageController controller;
  final List<TradeListItem> trades;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  State<ChecklistDailyMiniCalendar> createState() =>
      _ChecklistDailyMiniCalendarState();
}

class _ChecklistDailyMiniCalendarState extends State<ChecklistDailyMiniCalendar> {
  late DateTime _month;

  static const _labelStyle = TextStyle(
    decoration: TextDecoration.none,
    decorationThickness: 0,
  );

  TextStyle get _monthStyle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF9CA3AF),
        letterSpacing: 0.6,
        decoration: TextDecoration.none,
        decorationThickness: 0,
      );

  TextStyle get _weekdayStyle => GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF5C5C5C),
        decoration: TextDecoration.none,
        decorationThickness: 0,
      );

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
  }

  bool get _canGoPrev => true;

  bool _canGoNext() {
    final cap = DateTime(DateTime.now().year, DateTime.now().month);
    final next = DateTime(_month.year, _month.month + 1);
    return next.year < cap.year ||
        (next.year == cap.year && next.month <= cap.month);
  }

  void _prev() => setState(() => _month = DateTime(_month.year, _month.month - 1));

  void _next() {
    if (_canGoNext()) {
      setState(() => _month = DateTime(_month.year, _month.month + 1));
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final narrow = loc.narrowWeekdays;
    final l = AppLocalizations.of(context)!;
    final pnlByDay = cal.netPnlByEntryDay(widget.trades);
    final tradeCountByDay = cal.countTradesByEntryDay(widget.trades);
    final today = _dateOnly(DateTime.now());

    return DefaultTextStyle(
      style: _labelStyle,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final c = widget.controller;
          final y = _month.year;
          final m = _month.month;
          final daysInMonth = _daysInMonth(y, m);
          final first = DateTime(y, m, 1);
          final firstColDart =
              loc.firstDayOfWeekIndex == 0 ? 7 : loc.firstDayOfWeekIndex;
          final leading = ((first.weekday - firstColDart) % 7 + 7) % 7;

          final cells = <Widget>[];
          for (var i = 0; i < leading; i++) {
            cells.add(const SizedBox(height: 40));
          }
          for (var day = 1; day <= daysInMonth; day++) {
            final date = DateTime(y, m, day);
            final isFuture = _dateOnly(date).isAfter(today);
            final dayOnly = _dateOnly(date);
            cells.add(
              _DayCell(
                date: date,
                today: today,
                isFuture: isFuture,
                isSelected: dayOnly == _dateOnly(widget.selectedDay),
                pct: c.completionPercentForCalendarDay(
                  date,
                  tradeCount: tradeCountByDay[cal.dayKey(date)] ?? 0,
                ),
                dayStyle: checklistCalendarDayStyle(
                  date: date,
                  pnlByDay: pnlByDay,
                  tradeCountByDay: tradeCountByDay,
                  hasChecklistChecked: c.hasChecklistCheckedOnDay(date),
                  isFuture: isFuture,
                ),
                onTap: isFuture ? null : () => widget.onDaySelected(date),
              ),
            );
          }
          while (cells.length % 7 != 0) {
            cells.add(const SizedBox(height: 40));
          }

          final rows = <Widget>[];
          for (var r = 0; r < cells.length ~/ 7; r++) {
            rows.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    for (var col = 0; col < 7; col++)
                      Expanded(child: cells[r * 7 + col]),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _canGoPrev ? _prev : null,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: _canGoPrev
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF3A3A3A),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${l.monthName(m)} $y',
                      textAlign: TextAlign.center,
                      style: _monthStyle,
                    ),
                  ),
                  IconButton(
                    onPressed: _canGoNext() ? _next : null,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: _canGoNext()
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF3A3A3A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Text(
                        narrow[i],
                        textAlign: TextAlign.center,
                        style: _weekdayStyle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              ...rows,
            ],
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.today,
    required this.isFuture,
    required this.isSelected,
    required this.pct,
    required this.dayStyle,
    this.onTap,
  });

  final DateTime date;
  final DateTime today;
  final bool isFuture;
  final bool isSelected;
  final int? pct;
  final ChecklistCalendarDayStyle dayStyle;
  final VoidCallback? onTap;

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  TextStyle _pctStyle(Color color) => GoogleFonts.inter(
        fontSize: 8,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.15,
        decoration: TextDecoration.none,
        decorationThickness: 0,
      );

  @override
  Widget build(BuildContext context) {
    final d = DateTime(date.year, date.month, date.day);
    final isToday = _sameDate(d, today);
    final showPct = !isFuture && pct != null;
    final labelColor = dayStyle.labelColor;

    final borderWidth = isSelected ? 1.25 : (isToday ? 1.1 : 0.85);

    BoxDecoration decoration;
    if (dayStyle.isEmpty) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: isSelected
            ? Border.all(
                color: const Color(0xFF6E6E6E).withValues(alpha: 0.65),
                width: borderWidth,
              )
            : null,
      );
    } else {
      final borderColor = isSelected
          ? dayStyle.borderColor.withValues(alpha: 1.0)
          : dayStyle.borderColor;
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: dayStyle.fillColor,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: DecoratedBox(
              decoration: decoration,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${date.day}',
                      style: cal.dayDigitsStyle(labelColor).copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
                      ),
                    ),
                    if (showPct) ...[
                      const SizedBox(height: 2),
                      Text('$pct%', style: _pctStyle(labelColor)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
