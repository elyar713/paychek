import 'package:flutter/material.dart';

import '../../dashboard/dashboard_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../checklist_item_schedule.dart';
import '../checklist_tokens.dart';
import 'checklist_item_schedule_sheet.dart';

/// Icône calendrier pour le rappel d’une ligne checklist.
class ChecklistScheduleCalendarButton extends StatelessWidget {
  const ChecklistScheduleCalendarButton({
    super.key,
    required this.schedule,
    required this.onScheduleChanged,
  });

  final ChecklistItemSchedule schedule;
  final ValueChanged<ChecklistItemSchedule> onScheduleChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final iconColor = schedule.isNonDailyDisplay
        ? ChecklistTokens.scheduleCustomSummary
        : (schedule.warningTime != const TimeOfDay(hour: 9, minute: 0)
            ? DashboardTokens.accent
            : ChecklistTokens.sectionMenuIconColor);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final next = await showChecklistItemScheduleSheet(
            context: context,
            initial: schedule,
          );
          if (next != null) onScheduleChanged(next);
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: iconColor,
            semanticLabel: l.checklistScheduleCalendarTooltip,
          ),
        ),
      ),
    );
  }
}
