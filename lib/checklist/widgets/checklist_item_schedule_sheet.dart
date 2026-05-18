import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../dashboard/dashboard_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../checklist_item_schedule.dart';
import '../checklist_tokens.dart';

/// Petit prompt : fréquence, date, jour de semaine, heure d’avertissement.
Future<ChecklistItemSchedule?> showChecklistItemScheduleSheet({
  required BuildContext context,
  required ChecklistItemSchedule initial,
}) {
  return showDialog<ChecklistItemSchedule>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => _ChecklistItemScheduleDialog(initial: initial),
  );
}

class _ChecklistItemScheduleDialog extends StatefulWidget {
  const _ChecklistItemScheduleDialog({required this.initial});

  final ChecklistItemSchedule initial;

  @override
  State<_ChecklistItemScheduleDialog> createState() =>
      _ChecklistItemScheduleDialogState();
}

class _ChecklistItemScheduleDialogState extends State<_ChecklistItemScheduleDialog> {
  late ChecklistItemSchedule _s;

  @override
  void initState() {
    super.initState();
    _s = widget.initial;
  }

  String _fmtDate(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(d);
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickSpecificDate() async {
    final now = DateTime.now();
    final initial = _s.specificDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: DashboardTokens.accent,
            surface: ChecklistTokens.cardBg,
            onSurface: DashboardTokens.onMatteEmphasis,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _s = _s
            .copyWith(
              mode: ChecklistScheduleMode.specificDate,
              specificDate: picked,
              clearWeekday: true,
            )
            .normalized();
      });
    }
  }

  Future<void> _pickWarningTime() async {
    final initial = _s.warningTime ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: DashboardTokens.accent,
            surface: ChecklistTokens.cardBg,
            onSurface: DashboardTokens.onMatteEmphasis,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _s = _s.copyWith(warningTime: picked));
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: DashboardTokens.muted,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.35,
        ),
      ),
    );
  }

  Widget _modeChip({
    required String label,
    required ChecklistScheduleMode mode,
  }) {
    final selected = _s.mode == mode;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (mode == ChecklistScheduleMode.daily) {
                _s = _s
                    .copyWith(
                      mode: mode,
                      clearWeekday: true,
                      clearSpecificDate: true,
                    )
                    .normalized();
              } else if (mode == ChecklistScheduleMode.weekly) {
                _s = _s
                    .copyWith(
                      mode: mode,
                      clearSpecificDate: true,
                      weekday: _s.weekday ?? DateTime.now().weekday,
                    )
                    .normalized();
              } else {
                _s = _s
                    .copyWith(
                      mode: mode,
                      clearWeekday: true,
                      specificDate: _s.specificDate ?? DateTime.now(),
                    )
                    .normalized();
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: selected
                  ? DashboardTokens.accent.withValues(alpha: 0.18)
                  : DashboardTokens.scaffoldMatte,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? DashboardTokens.accent.withValues(alpha: 0.55)
                    : ChecklistTokens.sectionCardBorder,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? DashboardTokens.accent
                    : DashboardTokens.onMatteEmphasis,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _weekdayShortLabels(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final refMonday = DateTime(2024, 1, 1); // lundi
    return List.generate(7, (i) {
      final d = refMonday.add(Duration(days: i));
      return DateFormat.E(locale).format(d).replaceAll('.', '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final resolved = ChecklistItemSchedule.resolvedDate(_s);
    final weekLabels = _weekdayShortLabels(context);

    return AlertDialog(
      backgroundColor: ChecklistTokens.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: ChecklistTokens.sectionCardBorder),
      ),
      titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      title: Text(
        l.checklistScheduleTitle,
        style: const TextStyle(
          color: DashboardTokens.onMatteEmphasis,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionTitle(l.checklistScheduleDefaultHeading),
              Row(
                children: [
                  _modeChip(
                    label: l.checklistScheduleModeDaily,
                    mode: ChecklistScheduleMode.daily,
                  ),
                  const SizedBox(width: 6),
                  _modeChip(
                    label: l.checklistScheduleModeWeekly,
                    mode: ChecklistScheduleMode.weekly,
                  ),
                  const SizedBox(width: 6),
                  _modeChip(
                    label: l.checklistScheduleModeSpecificDate,
                    mode: ChecklistScheduleMode.specificDate,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _sectionTitle(l.checklistScheduleUserDateHeading),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickSpecificDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: DashboardTokens.scaffoldMatte,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ChecklistTokens.sectionCardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 16,
                          color: DashboardTokens.muted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _s.specificDate != null
                                ? _fmtDate(context, _s.specificDate!)
                                : l.checklistSchedulePickDate,
                            style: TextStyle(
                              color: _s.isNonDailyDisplay
                                  ? ChecklistTokens.scheduleCustomSummary
                                  : DashboardTokens.muted,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _sectionTitle(l.checklistScheduleWeekHeading),
              if (_s.mode == ChecklistScheduleMode.weekly &&
                  resolved != null) ...[
                Text(
                  l.checklistScheduleNextOccurrence(_fmtDate(context, resolved)),
                  style: const TextStyle(
                    color: DashboardTokens.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Row(
                children: [
                  for (var w = 1; w <= 7; w++) ...[
                    if (w > 1) const SizedBox(width: 4),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _s = _s.copyWith(
                                mode: ChecklistScheduleMode.weekly,
                                weekday: w,
                                clearSpecificDate: true,
                              );
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _s.weekday == w &&
                                      _s.mode == ChecklistScheduleMode.weekly
                                  ? DashboardTokens.accent.withValues(alpha: 0.2)
                                  : DashboardTokens.scaffoldMatte,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _s.weekday == w &&
                                        _s.mode == ChecklistScheduleMode.weekly
                                    ? DashboardTokens.accent
                                    : ChecklistTokens.sectionCardBorder,
                              ),
                            ),
                            child: Text(
                              weekLabels[w - 1],
                              style: TextStyle(
                                color: _s.weekday == w &&
                                        _s.mode == ChecklistScheduleMode.weekly
                                    ? DashboardTokens.accent
                                    : DashboardTokens.onMatteEmphasis,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _sectionTitle(l.checklistScheduleWarningHeading),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickWarningTime,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: DashboardTokens.scaffoldMatte,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ChecklistTokens.sectionCardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          size: 16,
                          color: DashboardTokens.muted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _s.warningTime != null
                                ? _fmtTime(_s.warningTime!)
                                : l.checklistSchedulePickTime,
                            style: const TextStyle(
                              color: DashboardTokens.onMatteEmphasis,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _s.normalized()),
          child: Text(l.ok),
        ),
      ],
    );
  }
}
