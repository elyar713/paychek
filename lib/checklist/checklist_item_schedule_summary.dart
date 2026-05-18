import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'checklist_item_schedule.dart';

/// Libellé minuscule au-dessus d’une ligne checklist (fréquence · jour/date · heure).
String checklistItemScheduleSummaryLine(
  BuildContext context,
  ChecklistItemSchedule schedule,
) {
  return checklistItemScheduleSummaryText(
    Localizations.localeOf(context),
    AppLocalizations.of(context)!,
    schedule,
  );
}

/// Même résumé pour export PDF (sans [BuildContext]).
String checklistItemScheduleSummaryText(
  Locale locale,
  AppLocalizations l,
  ChecklistItemSchedule schedule,
) {
  final localeTag = locale.toString();
  final time = schedule.warningTime ?? const TimeOfDay(hour: 9, minute: 0);
  final timeStr = _formatHm(time);

  String weekdayShort(int weekday) {
    final refMonday = DateTime(2024, 1, 1);
    final d = refMonday.add(Duration(days: weekday - 1));
    return DateFormat.E(localeTag).format(d).replaceAll('.', '');
  }

  String weekdayLong(int weekday) {
    final refMonday = DateTime(2024, 1, 1);
    final d = refMonday.add(Duration(days: weekday - 1));
    return DateFormat.EEEE(localeTag).format(d);
  }

  switch (schedule.displayMode) {
    case ChecklistScheduleMode.daily:
      return '${l.checklistScheduleModeDaily} · $timeStr';
    case ChecklistScheduleMode.weekly:
      final w = schedule.weekday ?? DateTime.now().weekday;
      final resolved = ChecklistItemSchedule.resolvedDate(schedule);
      final dayLabel = weekdayLong(w);
      if (resolved != null) {
        final dateMini = DateFormat.MMMd(localeTag).format(resolved);
        return '${l.checklistScheduleModeWeekly} · $dayLabel · $dateMini · $timeStr';
      }
      return '${l.checklistScheduleModeWeekly} · $dayLabel · $timeStr';
    case ChecklistScheduleMode.specificDate:
      final d = schedule.specificDate;
      if (d == null) {
        return '${l.checklistScheduleModeSpecificDate} · $timeStr';
      }
      final dateStr = DateFormat.yMMMd(localeTag).format(d);
      final wd = weekdayShort(d.weekday);
      return '$dateStr ($wd) · $timeStr';
  }
}

String _formatHm(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
