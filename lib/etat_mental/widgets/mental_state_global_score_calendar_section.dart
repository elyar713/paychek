import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../mental_state_controller.dart';
import 'mental_state_sleep_mini_calendar.dart';

ThemeData _mentalTimePickerTheme(BuildContext context) {
  final fg = WidgetStateColor.resolveWith(
    (s) => s.contains(WidgetState.selected) ? Colors.black : Colors.white,
  );
  final base = Theme.of(context);
  final helpCompact = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    height: 1.1,
    color: const Color(0xFF9CA3AF),
  );
  final hmDigits = GoogleFonts.plusJakartaSans(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineSmall: helpCompact,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: const Color(0xFF141416),
      hourMinuteTextColor: fg,
      dayPeriodTextColor: fg,
      hourMinuteTextStyle: hmDigits,
      dayPeriodTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      helpTextStyle: helpCompact,
      dialHandColor: const Color(0xFF22C55E),
      dialBackgroundColor: const Color(0xFF2A2A2E),
      dialTextColor: Colors.white,
      entryModeIconColor: const Color(0xFF9CA3AF),
    ),
  );
}

/// Carte sous « Suffisamment dormi » : mini-calendrier du **score global** (anneau), jour par jour.
class MentalStateGlobalScoreCalendarSection extends StatelessWidget {
  const MentalStateGlobalScoreCalendarSection({
    super.key,
    required this.controller,
    required this.titleStyle,
  });

  final MentalStateController controller;
  final TextStyle titleStyle;

  String _fmtHm(TimeOfDay t) {
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${p2(t.hour)}:${p2(t.minute)}';
  }

  Future<void> _openMentalDayWindowDialog(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    var start = controller.mentalDayStart;
    var end = controller.mentalDayEnd;

    final theme = Theme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1C),
          title: Text(
            l.mentalCalendarDayWindowDialogTitle,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l.mentalCalendarDayWindowStartLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                trailing: Text(
                  _fmtHm(start),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: start,
                    helpText: l.mentalCalendarDayStartDialogTitle,
                    builder: (c2, child) =>
                        Theme(data: _mentalTimePickerTheme(c2), child: child!),
                  );
                  if (t != null) setLocal(() => start = t);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l.mentalCalendarDayWindowEndLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                trailing: Text(
                  _fmtHm(end),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: end,
                    helpText: l.mentalCalendarDayEndDialogTitle,
                    builder: (c2, child) =>
                        Theme(data: _mentalTimePickerTheme(c2), child: child!),
                  );
                  if (t != null) setLocal(() => end = t);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel, style: theme.textTheme.labelLarge),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.ok, style: theme.textTheme.labelLarge),
            ),
          ],
        ),
      ),
    );
    if (ok == true && context.mounted) {
      await controller.setMentalDayWindow(start: start, end: end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final windowStyle = GoogleFonts.plusJakartaSans(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF8B8B8B),
      letterSpacing: 0.3,
    );
    final windowTagStyle = GoogleFonts.plusJakartaSans(
      fontSize: 9,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF6B6B6B),
      letterSpacing: 0.2,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.calendarDays,
              size: 16,
              color: Color(0xFF6B6B6B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l.mentalGlobalScoreCalendarTitle,
                style: titleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l.mentalCalendarDayWindowStartLabel,
                              style: windowTagStyle,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              controller.mentalDayStartTimeLabel(),
                              style: windowStyle,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                '·',
                                style: windowStyle.copyWith(fontSize: 9),
                              ),
                            ),
                            Text(
                              l.mentalCalendarDayWindowEndLabel,
                              style: windowTagStyle,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              controller.mentalDayEndTimeLabel(),
                              style: windowStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Tooltip(
                      message: l.mentalCalendarDayWindowSettingsTooltip,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      margin: const EdgeInsets.only(bottom: 4),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      verticalOffset: 10,
                      waitDuration: const Duration(milliseconds: 350),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        iconSize: 18,
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Color(0xFF8B8B8B),
                        ),
                        onPressed: () => _openMentalDayWindowDialog(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        MentalStateSleepMiniCalendar(
          controller: controller,
          onDayTap: (date) async {
            final l = AppLocalizations.of(context)!;
            final snap = controller.snapshotForCalendarDay(date);
            final pct = controller.overallScoreForCalendarDay(date);
            if (snap == null && pct == null) return;

            String p2(int v) => v.toString().padLeft(2, '0');
            final d = date;
            final title = '${p2(d.day)}/${p2(d.month)}/${d.year}';

            final sleep = (snap?['sleepValue'] as num?)?.toDouble();
            final selected = snap?['selectedEmotionIds'];
            final selectedIds = selected is List
                ? selected.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList()
                : <String>[];

            await showModalBottomSheet<void>(
              context: context,
              backgroundColor: const Color(0xFF141416),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (ctx) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${l.mentalGlobalScoreCalendarTitle}: ${(pct ?? 0).round()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE5E5E5),
                        ),
                      ),
                      if (sleep != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${l.mentalSleepEnough}: ${sleep.round()}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE5E5E5),
                          ),
                        ),
                      ],
                      if (selectedIds.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${l.mentalSectionEmotionHeading}: ${selectedIds.join(', ')}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l.ok,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
