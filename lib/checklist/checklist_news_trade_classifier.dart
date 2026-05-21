import 'package:flutter/material.dart';

import 'checklist_item_schedule.dart';
import 'checklist_models.dart';
import 'checklist_page_controller.dart';
import 'checklist_prompts.dart';

/// Tags « Avant news » / « Après news » dérivés de la section checklist NEWS.
@immutable
class TradeNewsTimingFlags {
  const TradeNewsTimingFlags({
    required this.avantNews,
    required this.apresNews,
  });

  final bool avantNews;
  final bool apresNews;

  static const TradeNewsTimingFlags none = TradeNewsTimingFlags(
    avantNews: false,
    apresNews: false,
  );
}

/// Interrupteur NEWS on → calcul auto ; off → pas de calcul (valeurs manuelles / neutres).
bool checklistNewsSectionEnabled(List<ChecklistSectionData> sections) {
  for (final s in sections) {
    if (s.id == ChecklistPrompts.sectionIdNews) {
      return checklistSectionIsActive(s);
    }
  }
  return false;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Heure d’annonce pour le jour d’entrée du trade (date précise ou hebdo).
DateTime? _newsEventInstantOnEntryDay({
  required ChecklistItemSchedule schedule,
  required DateTime entryDay,
}) {
  final sched = ChecklistItemSchedule.effectiveSchedule(schedule);
  final day = _dateOnly(entryDay);
  final t = sched.warningTime ?? const TimeOfDay(hour: 9, minute: 0);

  switch (sched.displayMode) {
    case ChecklistScheduleMode.daily:
      return null;
    case ChecklistScheduleMode.specificDate:
      final d = sched.specificDate;
      if (d == null) return null;
      if (_dateOnly(d) != day) return null;
      return DateTime(day.year, day.month, day.day, t.hour, t.minute);
    case ChecklistScheduleMode.weekly:
      final w = sched.weekday;
      if (w == null || w < 1 || w > 7 || w != day.weekday) return null;
      return DateTime(day.year, day.month, day.day, t.hour, t.minute);
  }
}

/// Instants news du jour calendaire d’entrée (section NEWS active uniquement).
List<DateTime> newsEventInstantsOnEntryDay({
  required List<ChecklistSectionData> sections,
  required DateTime entreeAt,
}) {
  ChecklistSectionData? news;
  for (final s in sections) {
    if (s.id == ChecklistPrompts.sectionIdNews) {
      news = s;
      break;
    }
  }
  if (news == null || !checklistSectionIsActive(news)) {
    return const [];
  }

  final day = _dateOnly(entreeAt);
  final out = <DateTime>[];
  for (final item in news.items) {
    final sched = item.schedule;
    if (sched == null) continue;
    final instant = _newsEventInstantOnEntryDay(
      schedule: sched,
      entryDay: day,
    );
    if (instant != null) out.add(instant);
  }
  out.sort();
  return out;
}

/// Prochaine annonce du jour : avant → [avantNews]. Sinon (après la dernière) → [apresNews].
TradeNewsTimingFlags classifyTradeNewsTiming({
  required DateTime entreeAt,
  required List<ChecklistSectionData> sections,
}) {
  final instants = newsEventInstantsOnEntryDay(
    sections: sections,
    entreeAt: entreeAt,
  );
  if (instants.isEmpty) return TradeNewsTimingFlags.none;

  for (final eventAt in instants) {
    if (eventAt.isAfter(entreeAt)) {
      return const TradeNewsTimingFlags(avantNews: true, apresNews: false);
    }
  }
  return const TradeNewsTimingFlags(avantNews: false, apresNews: true);
}

TradeNewsTimingFlags classifyTradeNewsTimingFromController({
  required DateTime entreeAt,
  required ChecklistPageController checklist,
}) =>
    classifyTradeNewsTiming(
      entreeAt: entreeAt,
      sections: checklist.sections,
    );

/// Auto si section NEWS active ; sinon [manualFallback] (cases formulaire / import neutre).
TradeNewsTimingFlags resolveTradeNewsTimingFlags({
  required DateTime entreeAt,
  required List<ChecklistSectionData> sections,
  TradeNewsTimingFlags manualFallback = TradeNewsTimingFlags.none,
}) {
  if (!checklistNewsSectionEnabled(sections)) return manualFallback;
  return classifyTradeNewsTiming(entreeAt: entreeAt, sections: sections);
}

TradeNewsTimingFlags resolveTradeNewsTimingFlagsFromController({
  required DateTime entreeAt,
  required ChecklistPageController checklist,
  TradeNewsTimingFlags manualFallback = TradeNewsTimingFlags.none,
}) =>
    resolveTradeNewsTimingFlags(
      entreeAt: entreeAt,
      sections: checklist.sections,
      manualFallback: manualFallback,
    );
