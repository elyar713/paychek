import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_month.dart';
import '../mental_state_controller.dart';
import '../mental_state_date_utils.dart';
import '../mental_state_tokens.dart';

/// Mini-calendrier du mois avec % **score global** (anneau) par jour — historique local.
class MentalStateSleepMiniCalendar extends StatefulWidget {
  const MentalStateSleepMiniCalendar({
    super.key,
    required this.controller,
    this.onDayTap,
  });

  final MentalStateController controller;
  final void Function(DateTime date)? onDayTap;

  @override
  State<MentalStateSleepMiniCalendar> createState() =>
      _MentalStateSleepMiniCalendarState();
}

class _MentalStateSleepMiniCalendarState
    extends State<MentalStateSleepMiniCalendar> {
  late DateTime _month;

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

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final narrow = loc.narrowWeekdays;
    final l = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
        final y = _month.year;
        final m = _month.month;
        final daysInMonth = MentalStateDateUtils.getDaysInMonth(y, m);
        final first = DateTime(y, m, 1);
        final firstColDart =
            loc.firstDayOfWeekIndex == 0 ? 7 : loc.firstDayOfWeekIndex;
        final leading = ((first.weekday - firstColDart) % 7 + 7) % 7;
        final anchorMidnight = MentalStateDateUtils.liveScoreAnchorCalendarDate(
          DateTime.now(),
          c.mentalDayStart,
          c.mentalDayEnd,
        );
        final today = MentalStateDateUtils.dateOnly(anchorMidnight);

        final cells = <Widget>[];
        for (var i = 0; i < leading; i++) {
          cells.add(const SizedBox(height: 44));
        }
        for (var day = 1; day <= daysInMonth; day++) {
          final date = DateTime(y, m, day);
          cells.add(_DayCell(
            date: date,
            today: today,
            pct: c.overallScoreForCalendarDay(date),
            onTap: widget.onDayTap == null ? null : () => widget.onDayTap!(date),
          ));
        }
        while (cells.length % 7 != 0) {
          cells.add(const SizedBox(height: 44));
        }

        final rows = <Widget>[];
        for (var r = 0; r < cells.length ~/ 7; r++) {
          rows.add(
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(child: cells[r * 7 + c]),
              ],
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
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _canGoNext() ? _next : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C5C5C),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ...rows,
          ],
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.today,
    required this.pct,
    this.onTap,
  });

  final DateTime date;
  final DateTime today;
  final double? pct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = MentalStateDateUtils.dateOnly(date);
    final isFuture = d.isAfter(today);
    final isToday = MentalStateDateUtils.isSameDate(d, today);

    Color? pctColor;
    if (pct != null && !isFuture) {
      final s = pct!;
      if (s >= 70) {
        pctColor = MentalStateTokens.matteGreen;
      } else if (s >= 45) {
        pctColor = const Color(0xFFE5E5E5);
      } else {
        pctColor = MentalStateTokens.matteRed;
      }
    }

    return SizedBox(
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (!isFuture && onTap != null) ? onTap : null,
          borderRadius: BorderRadius.circular(6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: isToday
                  ? Border.all(
                      color: MentalStateTokens.matteGreen.withValues(alpha: 0.7),
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isFuture
                        ? const Color(0xFF3D3D3D)
                        : const Color(0xFFB5B5B5),
                  ),
                ),
                const SizedBox(height: 2),
                if (!isFuture && pct != null)
                  Text(
                    '${pct!.round()}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: pctColor,
                      height: 1,
                    ),
                  )
                else if (!isFuture)
                  Text(
                    '—',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A4A4A),
                      height: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
