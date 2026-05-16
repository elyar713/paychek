import 'package:flutter/material.dart';

/// Utilitaires date sans [DateUtils] Material — évite des erreurs JS (web) sur `DateUtils` non lié.
class MentalStateDateUtils {
  MentalStateDateUtils._();

  static DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  static int getDaysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  static bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Début / fin par défaut : journée civile complète (affichée 00:00–23:59).
  static const TimeOfDay kDefaultDayStart = TimeOfDay(hour: 0, minute: 0);
  static const TimeOfDay kDefaultDayEnd = TimeOfDay(hour: 23, minute: 59);

  /// Fenêtre **24 h** : [start] == [end] (ancien format) ou 00:00 → 23:59.
  static bool isTwentyFourHourWindow(TimeOfDay start, TimeOfDay end) {
    final sm = _toMin(start);
    final em = _toMin(end);
    if (sm == em) return true;
    return sm == 0 && em == _toMin(kDefaultDayEnd);
  }

  static DateTime _combineDayTime(DateTime dayMidnight, TimeOfDay t) =>
      DateTime(
        dayMidnight.year,
        dayMidnight.month,
        dayMidnight.day,
        t.hour,
        t.minute,
      );

  /// Période score [ws, we) — [we] exclus.
  ///
  /// * [isTwentyFourHourWindow] (00:00–23:59 ou [start] == [end]) → **24 h** à partir de [start].
  /// * [start] < [end] (minutes) → même jour civil.
  /// * [start] > [end] → passage minuit (ex. 22:00 → lendemain 06:00).
  static (DateTime ws, DateTime we) scoringWindowForAnchor(
    DateTime anchorMidnight,
    TimeOfDay start,
    TimeOfDay end,
  ) {
    final sm = _toMin(start);
    final em = _toMin(end);
    final day = dateOnly(anchorMidnight);
    final ws = _combineDayTime(day, start);
    if (isTwentyFourHourWindow(start, end)) {
      return (ws, ws.add(const Duration(days: 1)));
    }
    if (sm < em) {
      final we = _combineDayTime(day, end);
      return (ws, we);
    }
    final nextCal = day.add(const Duration(days: 1));
    final we = DateTime(
      nextCal.year,
      nextCal.month,
      nextCal.day,
      end.hour,
      end.minute,
    );
    return (ws, we);
  }

  /// Jour d’ancrage (minuit du jour de début de période) si [now] est dans une fenêtre, sinon null (entre deux fenêtres).
  static DateTime? anchorDateContaining(
    DateTime now,
    TimeOfDay start,
    TimeOfDay end,
  ) {
    final today = dateOnly(now);
    for (var back = 0; back < 3; back++) {
      final d = today.subtract(Duration(days: back));
      final (ws, we) = scoringWindowForAnchor(d, start, end);
      if (!now.isBefore(ws) && now.isBefore(we)) {
        return d;
      }
    }
    return null;
  }

  /// Prochaine fin de période (instant [we]) strictement après [now].
  static DateTime nextScoringPeriodEndAfter(
    DateTime now,
    TimeOfDay start,
    TimeOfDay end,
  ) {
    DateTime? best;
    final today = dateOnly(now);
    for (var i = 0; i < 14; i++) {
      final d = today.add(Duration(days: i));
      final (_, we) = scoringWindowForAnchor(d, start, end);
      if (we.isAfter(now) && (best == null || we.isBefore(best))) {
        best = we;
      }
    }
    return best ?? now.add(const Duration(days: 1));
  }

  /// En entre-deux : jour d’ancrage de la **prochaine** fenêtre qui commence (clé snapshot cohérente hors plage).
  static DateTime anchorDateForScoringKeyWhenGapped(
    DateTime now,
    TimeOfDay start,
    TimeOfDay end,
  ) {
    final today = dateOnly(now);
    for (var i = 0; i < 14; i++) {
      final d = today.add(Duration(days: i));
      final (ws, _) = scoringWindowForAnchor(d, start, end);
      if (ws.isAfter(now)) {
        return d;
      }
    }
    return today;
  }

  /// Quelle période vient de se terminer à l’instant [endInstant] (juste après la frontière).
  static DateTime? anchorDateForPeriodEndedAt(
    DateTime endInstant,
    TimeOfDay start,
    TimeOfDay end,
  ) {
    return anchorDateContaining(
      endInstant.subtract(const Duration(milliseconds: 2)),
      start,
      end,
    );
  }

  /// Date d’ancrage pour surligner le « jour » courant dans le mini-calendrier (plage ou prochaine plage).
  static DateTime liveScoreAnchorCalendarDate(
    DateTime now,
    TimeOfDay start,
    TimeOfDay end,
  ) {
    final inside = anchorDateContaining(now, start, end);
    if (inside != null) return inside;
    return anchorDateForScoringKeyWhenGapped(now, start, end);
  }

  // --- Ancienne API 24 h à partir d’une seule heure (conservée pour appels éventuels) ---

  /// Début de la période « score global / jour » : [dayStart] le même jour civil que [now], ou la veille si [now] est avant cette heure.
  static DateTime mentalDayAnchor(DateTime now, TimeOfDay dayStart) {
    final at = DateTime(
      now.year,
      now.month,
      now.day,
      dayStart.hour,
      dayStart.minute,
    );
    if (now.isBefore(at)) {
      return at.subtract(const Duration(days: 1));
    }
    return at;
  }

  /// Prochain instant où une nouvelle période 24 h commence (même heure que [dayStart]).
  static DateTime nextMentalDayBoundary(DateTime now, TimeOfDay dayStart) {
    return mentalDayAnchor(now, dayStart).add(const Duration(days: 1));
  }
}
