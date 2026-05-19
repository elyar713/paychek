import 'checklist_item_schedule.dart';
import 'checklist_models.dart';

/// Coches checklist liées au **jour d'échéance** (fin de période = 23:59:59.999 locale).
abstract final class ChecklistItemPeriod {
  ChecklistItemPeriod._();

  static DateTime dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  /// Fin du jour calendaire [day] (23:59:59.999 heure locale).
  static DateTime endOfCalendarDayLocal(DateTime day) {
    final d = dateOnly(day);
    return DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
  }

  static bool isAfterPeriodEnd(DateTime now, DateTime periodDay) =>
      now.isAfter(endOfCalendarDayLocal(periodDay));

  /// Dernier jour d'échéance ≤ aujourd'hui (date seule).
  static DateTime? lastDuePeriodDayOnOrBefore(
    ChecklistItemSchedule s,
    DateTime now,
  ) {
    final today = dateOnly(now);
    switch (s.displayMode) {
      case ChecklistScheduleMode.daily:
        return today;
      case ChecklistScheduleMode.weekly:
        final w = s.weekday;
        if (w == null || w < 1 || w > 7) return null;
        var d = today;
        while (d.weekday != w) {
          d = d.subtract(const Duration(days: 1));
        }
        return d;
      case ChecklistScheduleMode.specificDate:
        final raw = s.specificDate;
        if (raw == null) return null;
        final d = dateOnly(raw);
        if (d.isAfter(today)) return null;
        return d;
    }
  }

  /// Fenêtre encore ouverte pour cocher (jour d'échéance, avant minuit).
  static DateTime? openPeriodDay(ChecklistItemSchedule s, DateTime now) {
    final due = lastDuePeriodDayOnOrBefore(s, now);
    if (due == null) return null;
    if (!ChecklistItemSchedule.isDueOnDay(s, due)) return null;
    if (isAfterPeriodEnd(now, due)) return null;
    return due;
  }

  /// Coche valide pour la période courante (UI du jour).
  static bool isCompletedForSchedule(ChecklistItemData item, DateTime now) {
    if (!item.checked) return false;
    return isCompletedForCalendarDay(item, now);
  }

  /// Historique calendrier : s'appuie sur [ChecklistItemData.checkedAt] (conservé après minuit).
  static bool isCompletedForCalendarDay(ChecklistItemData item, DateTime day) {
    final at = item.checkedAt;
    if (at == null) return false;

    final s = ChecklistItemSchedule.effectiveSchedule(item.schedule);
    final checkDay = dateOnly(at.toLocal());
    final onDay = dateOnly(day);

    switch (s.displayMode) {
      case ChecklistScheduleMode.daily:
        return checkDay == onDay;
      case ChecklistScheduleMode.weekly:
        final occurrence = lastDuePeriodDayOnOrBefore(s, onDay);
        return occurrence != null && checkDay == occurrence;
      case ChecklistScheduleMode.specificDate:
        final raw = s.specificDate;
        if (raw == null) return false;
        return checkDay == dateOnly(raw);
    }
  }

  /// Échéance manquée : griser (hebdo / date précise), pas les tâches « tous les jours ».
  static bool isExpiredMissed(ChecklistItemData item, DateTime now) {
    if (isCompletedForSchedule(item, now)) return false;

    final s = ChecklistItemSchedule.effectiveSchedule(item.schedule);
    if (s.displayMode == ChecklistScheduleMode.daily) return false;

    final lastDue = lastDuePeriodDayOnOrBefore(s, now);
    if (lastDue == null) return false;
    if (!isAfterPeriodEnd(now, lastDue)) return false;
    if (openPeriodDay(s, now) != null) return false;
    return true;
  }

  /// Normalise l'état persisté (décoche si la période a tourné).
  static ChecklistItemData normalizeCheckedState(
    ChecklistItemData item,
    DateTime now,
  ) {
    if (!item.checked) return item;
    if (isCompletedForSchedule(item, now)) return item;
    // Conserver checkedAt pour le % calendrier des jours passés.
    return item.copyWith(checked: false);
  }
}
