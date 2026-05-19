import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../calendrier/calendrier_utils.dart' as cal;
import '../../l10n/app_localizations.dart';
import '../../l10n/checklist_localizations.dart';
import '../checklist_daily_day_snapshot.dart';
import '../checklist_page_controller.dart';
import '../checklist_tokens.dart';

/// Carte à droite du calendrier : critères non cochés pour le jour sélectionné.
class ChecklistDailyUncheckedCard extends StatelessWidget {
  const ChecklistDailyUncheckedCard({
    super.key,
    required this.controller,
    required this.selectedDay,
    required this.tradeCountByDay,
  });

  final ChecklistPageController controller;
  final DateTime selectedDay;
  final Map<int, int> tradeCountByDay;

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  String _formatDayHeader(AppLocalizations l, DateTime day) {
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${p2(day.day)}/${p2(day.month)}/${day.year}';
  }

  static List<({String sectionId, String sectionTitle, List<ChecklistUncheckedDayEntry> items})>
      _groupBySection(List<ChecklistUncheckedDayEntry> entries) {
    final order = <String>[];
    final map = <String, List<ChecklistUncheckedDayEntry>>{};
    for (final e in entries) {
      map.putIfAbsent(e.sectionId, () {
        order.add(e.sectionId);
        return <ChecklistUncheckedDayEntry>[];
      });
      map[e.sectionId]!.add(e);
    }
    return [
      for (final id in order)
        (
          sectionId: id,
          sectionTitle: map[id]!.first.sectionTitle,
          items: map[id]!,
        ),
    ];
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
    );

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final day = _dateOnly(selectedDay);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final isToday = day == today;
        final entries = controller.uncheckedEntriesForDay(day);
        final dueCount = controller.itemsDueOnDayCount(day);
        final tradeCount = tradeCountByDay[cal.dayKey(day)] ?? 0;
        final hasTrades = tradeCount > 0;
        final hasSnapshot = controller.hasSnapshotForDay(day);
        final hasActivity = hasTrades || hasSnapshot || dueCount > 0;

        final String emptyMessage;
        if (!hasActivity) {
          emptyMessage = l.checklistDailyUncheckedNoActivity;
        } else if (!isToday && hasTrades && !hasSnapshot) {
          emptyMessage = l.checklistDailyUncheckedNoHistory;
        } else if (entries.isNotEmpty) {
          emptyMessage = '';
        } else if (dueCount == 0) {
          emptyMessage = l.checklistDailyUncheckedNoDue;
        } else {
          emptyMessage = l.checklistDailyUncheckedAllDone;
        }

        final grouped = _groupBySection(entries);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: ChecklistTokens.cardBg,
            borderRadius: BorderRadius.circular(ChecklistTokens.cardRadius),
            border: Border.all(
              color: ChecklistTokens.sectionCardBorder,
              width: ChecklistTokens.sectionCardBorderWidth,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.listX,
                      size: 15,
                      color: const Color(0xFF8A8A8A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.checklistDailyUncheckedTitle,
                        style: titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDayHeader(l, day),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B6B6B),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                if (emptyMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      emptyMessage,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7A7A7A),
                        height: 1.35,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Scrollbar(
                      thumbVisibility: grouped.length > 3,
                      radius: const Radius.circular(4),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(right: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var s = 0; s < grouped.length; s++) ...[
                              if (s > 0) const SizedBox(height: 12),
                              _UncheckedSectionBlock(
                                sectionTitle: checklistSectionTitle(
                                  l,
                                  grouped[s].sectionId,
                                  grouped[s].sectionTitle,
                                ),
                                itemLabels: [
                                  for (final item in grouped[s].items)
                                    checklistItemLabel(
                                      l,
                                      item.itemId,
                                      item.itemLabel,
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UncheckedSectionBlock extends StatelessWidget {
  const _UncheckedSectionBlock({
    required this.sectionTitle,
    required this.itemLabels,
  });

  final String sectionTitle;
  final List<String> itemLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: ChecklistTokens.sectionTitleOnCardStyle.color,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < itemLabels.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              itemLabels[i],
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB0B0B0),
                height: 1.3,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
