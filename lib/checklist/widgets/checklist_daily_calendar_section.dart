import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../calendrier/calendrier_utils.dart' as cal;
import '../../l10n/app_localizations.dart';
import '../../trade/trade_journal_helper.dart';
import '../../trade/trade_journal_scope.dart';
import '../checklist_page_controller.dart';
import 'checklist_daily_mini_calendar.dart';
import 'checklist_daily_unchecked_card.dart';

/// Calendrier + carte « non cochés » pour le jour sélectionné.
class ChecklistDailyCalendarSection extends StatefulWidget {
  const ChecklistDailyCalendarSection({
    super.key,
    required this.controller,
  });

  final ChecklistPageController controller;

  @override
  State<ChecklistDailyCalendarSection> createState() =>
      _ChecklistDailyCalendarSectionState();
}

class _ChecklistDailyCalendarSectionState
    extends State<ChecklistDailyCalendarSection> {
  late DateTime _selectedDay;

  static DateTime _todayDateOnly() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _todayDateOnly();
  }

  void _onDaySelected(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    if (d.isAfter(_todayDateOnly())) return;
    setState(() => _selectedDay = d);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final titleStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF9CA3AF),
      letterSpacing: 1.2,
      decoration: TextDecoration.none,
      decorationThickness: 0,
    );

    return ListenableBuilder(
      listenable: TradeJournalScope.of(context),
      builder: (context, _) {
        final trades = activeJournalTradesOrDemo(context);
        final tradeCountByDay = cal.countTradesByEntryDay(trades);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.calendarDays,
                  size: 16,
                  color: Color(0xFF6B6B6B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.checklistDailyCalendarTitle,
                    style: titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final sideBySide = constraints.maxWidth >= 520;
                final calendar = ChecklistDailyMiniCalendar(
                  controller: widget.controller,
                  trades: trades,
                  selectedDay: _selectedDay,
                  onDaySelected: _onDaySelected,
                );
                final uncheckedCard = ChecklistDailyUncheckedCard(
                  controller: widget.controller,
                  selectedDay: _selectedDay,
                  tradeCountByDay: tradeCountByDay,
                );

                if (sideBySide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: calendar),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: uncheckedCard),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    calendar,
                    const SizedBox(height: 12),
                    uncheckedCard,
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
