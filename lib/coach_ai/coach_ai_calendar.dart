import 'package:shared_preferences/shared_preferences.dart';

import '../calendrier/calendrier_utils.dart';
import '../checklist/checklist_page_controller.dart';
import '../etat_mental/mental_state_controller.dart';
import '../reglage/paychek_prefs_scope.dart';
import '../strategie/strategie_setup_usage_store.dart';
import '../trade/trade_models.dart';
import '../trade/trade_stats.dart';
import 'coach_ai_response_format.dart';

class CalendarTodaySnapshot {
  const CalendarTodaySnapshot({
    required this.dateLabel,
    this.tradesToday = 0,
    this.pnlToday = 0,
    this.winsToday = 0,
    this.lossesToday = 0,
    this.checklistPercent,
    this.checklistItemsDue = 0,
    this.mentalScore,
    this.setupsUsedToday = const [],
    this.monthPnl = 0,
    this.monthTrades = 0,
    this.monthWinratePercent = 0,
    this.monthlyObjective,
    this.objectiveProgressPercent,
    this.greenDaysThisMonth = 0,
    this.redDaysThisMonth = 0,
  });

  final String dateLabel;
  final int tradesToday;
  final double pnlToday;
  final int winsToday;
  final int lossesToday;
  final int? checklistPercent;
  final int checklistItemsDue;
  final int? mentalScore;
  final List<String> setupsUsedToday;
  final double monthPnl;
  final int monthTrades;
  final int monthWinratePercent;
  final double? monthlyObjective;
  final int? objectiveProgressPercent;
  final int greenDaysThisMonth;
  final int redDaysThisMonth;

  bool get hasActivityToday =>
      tradesToday > 0 ||
      (checklistPercent != null && checklistPercent! > 0) ||
      mentalScore != null ||
      setupsUsedToday.isNotEmpty;
}

class CalendarMonthSnapshot {
  const CalendarMonthSnapshot({
    required this.monthLabel,
    this.monthTrades = 0,
    this.monthPnl = 0,
    this.monthWinratePercent = 0,
    this.monthlyObjective,
    this.objectiveProgressPercent,
    this.greenDays = 0,
    this.redDays = 0,
    this.tradingDays = 0,
  });

  final String monthLabel;
  final int monthTrades;
  final double monthPnl;
  final int monthWinratePercent;
  final double? monthlyObjective;
  final int? objectiveProgressPercent;
  final int greenDays;
  final int redDays;
  final int tradingDays;
}

/// Calendrier PAYCHEK (synthèse jour / mois), pas audit discipline global.
abstract final class CoachAiCalendar {
  static const _kMonthlyObjectiveBase = 'calendrier_monthly_objective';

  static String get _monthlyObjectiveKey =>
      paychekScopedPrefsKey(_kMonthlyObjectiveBase);

  static String dateLabel(DateTime day) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(day.day)}/${two(day.month)}/${day.year}';
  }

  static String monthLabel(DateTime day, String languageCode) {
    const frMonths = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    if (languageCode == 'fr') {
      return '${frMonths[day.month - 1]} ${day.year}';
    }
    return '${day.month}/${day.year}';
  }

  static Future<double?> _loadMonthlyObjective() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_monthlyObjectiveKey);
  }

  static int? _objectiveProgressPercent(double monthPnl, double? objective) {
    if (objective == null || objective <= 0) return null;
    return ((100 * monthPnl) / objective).round().clamp(-999, 999);
  }

  static List<TradeListItem> _tradesInMonth(
    Iterable<TradeListItem> trades,
    DateTime ref,
  ) {
    return [
      for (final t in trades)
        if (t.entreeAt.year == ref.year && t.entreeAt.month == ref.month) t,
    ];
  }

  static ({int green, int red, int tradingDays}) _dayColorsInMonth(
    Iterable<TradeListItem> trades,
    DateTime ref,
  ) {
    final pnlByDay = netPnlByEntryDay(trades.toList());
    var green = 0;
    var red = 0;
    var tradingDays = 0;
    for (final e in pnlByDay.entries) {
      final y = e.key ~/ 10000;
      final m = (e.key % 10000) ~/ 100;
      if (y != ref.year || m != ref.month) continue;
      tradingDays++;
      if (e.value > 0) {
        green++;
      } else if (e.value < 0) {
        red++;
      }
    }
    return (green: green, red: red, tradingDays: tradingDays);
  }

  static Future<List<String>> _setupsUsedOnDay(DateTime day) async {
    await StrategieSetupUsageStore.ensureLoaded();
    final dk = dayKey(day);
    final out = <String>[];
    for (final e in StrategieSetupUsageStore.notifier.value.entries) {
      if (e.value.contains(dk)) out.add(e.key);
    }
    return out;
  }

  static bool isMonthCalendarQuestion(String question) {
    final q = question.toLowerCase();
    if (!RegExp(r'calendrier|calendar|objectif|mois|month').hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r'comment|how to|où |ou |where |configurer|modifier|engrenage|⚙|help',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(r"aujourd'hui|today|du jour").hasMatch(q) &&
        !RegExp(r'\b(mois|month|objectif|mensuel|monthly)\b').hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r'performance globale|bilan complet|70 trade|non.?respect|audit discipline|4 pilier',
    ).hasMatch(q)) {
      return false;
    }
    return RegExp(
      r'\b(mois|month|objectif|mensuel|monthly|progression|progres|ce mois|this month)\b',
    ).hasMatch(q);
  }

  static bool isTodayCalendarQuestion(String question) {
    if (isMonthCalendarQuestion(question)) return false;
    final q = question.toLowerCase();
    if (!RegExp(r'calendrier|calendar|ma journée|my day|journée trading').hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r'état mental|etat mental|mental state|checklist|analyse|analysis|strat(é|e)gie|strategy',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r'comment|how to|où |ou |where |configurer|modifier|engrenage|⚙',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r'performance globale|bilan complet|70 trade|non.?respect|audit discipline',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r"aujourd'hui|aujourdhui|today|du jour|ce matin|this morning|this evening",
    ).hasMatch(q)) {
      return true;
    }
    return RegExp(
      r"dis.?moi|montre|quelle est|quel est|what is|show me|mon calendrier|my calendar",
    ).hasMatch(q);
  }

  static Future<CalendarTodaySnapshot> buildTodaySnapshot(
    Iterable<TradeListItem> trades,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTrades = tradesOnCalendarDay(trades.toList(), today);

    var wins = 0;
    var losses = 0;
    var pnl = 0.0;
    for (final t in todayTrades) {
      pnl += t.gainAmount;
      if (t.gainAmount > 0) {
        wins++;
      } else if (t.gainAmount < 0) {
        losses++;
      }
    }

    final checklist = ChecklistPageController();
    await checklist.hydrateFromStorage();
    final checklistDue = checklist.totalItemsDueToday;
    final checklistPct = checklistDue > 0 ? checklist.completionPercentOnDay(today) : null;

    final mentalScore =
        MentalStateController.instance.overallScoreForCalendarDay(today)?.round();

    final setupsUsed = await _setupsUsedOnDay(today);

    final monthTrades = _tradesInMonth(trades, now);
    final monthPnl = monthTrades.fold<double>(0, (s, t) => s + t.gainAmount);
    final monthStats = computeTradeStats(monthTrades);
    final objective = await _loadMonthlyObjective();
    final dayColors = _dayColorsInMonth(trades, now);

    return CalendarTodaySnapshot(
      dateLabel: dateLabel(today),
      tradesToday: todayTrades.length,
      pnlToday: pnl,
      winsToday: wins,
      lossesToday: losses,
      checklistPercent: checklistPct,
      checklistItemsDue: checklistDue,
      mentalScore: mentalScore,
      setupsUsedToday: setupsUsed,
      monthPnl: monthPnl,
      monthTrades: monthTrades.length,
      monthWinratePercent: monthStats.winRatePctDisplay,
      monthlyObjective: objective,
      objectiveProgressPercent: _objectiveProgressPercent(monthPnl, objective),
      greenDaysThisMonth: dayColors.green,
      redDaysThisMonth: dayColors.red,
    );
  }

  static Future<CalendarMonthSnapshot> buildMonthSnapshot(
    Iterable<TradeListItem> trades,
    String languageCode,
  ) async {
    final now = DateTime.now();
    final monthTrades = _tradesInMonth(trades, now);
    final monthPnl = monthTrades.fold<double>(0, (s, t) => s + t.gainAmount);
    final monthStats = computeTradeStats(monthTrades);
    final objective = await _loadMonthlyObjective();
    final dayColors = _dayColorsInMonth(trades, now);

    return CalendarMonthSnapshot(
      monthLabel: monthLabel(now, languageCode),
      monthTrades: monthTrades.length,
      monthPnl: monthPnl,
      monthWinratePercent: monthStats.winRatePctDisplay,
      monthlyObjective: objective,
      objectiveProgressPercent: _objectiveProgressPercent(monthPnl, objective),
      greenDays: dayColors.green,
      redDays: dayColors.red,
      tradingDays: dayColors.tradingDays,
    );
  }

  static String todayCardTitle(String languageCode) {
    return switch (languageCode) {
      'en' => 'Calendar · today',
      'de' => 'Kalender · heute',
      'es' => 'Calendario · hoy',
      _ => 'Calendrier · aujourd’hui',
    };
  }

  static String monthCardTitle(String languageCode) {
    return switch (languageCode) {
      'en' => 'Calendar · month',
      'de' => 'Kalender · Monat',
      'es' => 'Calendario · mes',
      _ => 'Calendrier · mois',
    };
  }

  static Future<Map<String, dynamic>> todayContextToJson(
    Iterable<TradeListItem> trades,
    String languageCode, {
    bool briefFollowUp = false,
  }) async {
    final snap = await buildTodaySnapshot(trades);
    return <String, dynamic>{
      'coachInstructions': briefFollowUp
          ? CoachAiResponseFormat.calendarTodayFollowUpInstructions(languageCode)
          : CoachAiResponseFormat.calendarTodayInstructions(languageCode),
      'date': snap.dateLabel,
      'hasActivityToday': snap.hasActivityToday,
      'tradesToday': snap.tradesToday,
      'pnlToday': snap.pnlToday,
      'winsToday': snap.winsToday,
      'lossesToday': snap.lossesToday,
      if (snap.checklistPercent != null) 'checklistPercent': snap.checklistPercent,
      if (snap.checklistItemsDue > 0) 'checklistItemsDue': snap.checklistItemsDue,
      if (snap.mentalScore != null) 'mentalScore': snap.mentalScore,
      if (snap.setupsUsedToday.isNotEmpty) 'setupsUsedToday': snap.setupsUsedToday,
      'monthProgress': <String, dynamic>{
        'monthLabel': monthLabel(DateTime.now(), languageCode),
        'monthPnl': snap.monthPnl,
        'monthTrades': snap.monthTrades,
        'monthWinratePercent': snap.monthWinratePercent,
        if (snap.monthlyObjective != null) 'monthlyObjective': snap.monthlyObjective,
        if (snap.objectiveProgressPercent != null)
          'objectiveProgressPercent': snap.objectiveProgressPercent,
        'greenDays': snap.greenDaysThisMonth,
        'redDays': snap.redDaysThisMonth,
      },
      'fillHintPath': languageCode == 'fr'
          ? 'Accueil → Calendrier, ou onglet Calendrier → sélectionne le jour'
          : 'Home → Calendar, or Calendar tab → select the day',
    };
  }

  static Future<Map<String, dynamic>> monthContextToJson(
    Iterable<TradeListItem> trades,
    String languageCode, {
    bool briefFollowUp = false,
  }) async {
    final snap = await buildMonthSnapshot(trades, languageCode);
    return <String, dynamic>{
      'coachInstructions': briefFollowUp
          ? CoachAiResponseFormat.calendarMonthFollowUpInstructions(languageCode)
          : CoachAiResponseFormat.calendarMonthInstructions(languageCode),
      'monthLabel': snap.monthLabel,
      'monthTrades': snap.monthTrades,
      'monthPnl': snap.monthPnl,
      'monthWinratePercent': snap.monthWinratePercent,
      if (snap.monthlyObjective != null) 'monthlyObjective': snap.monthlyObjective,
      if (snap.objectiveProgressPercent != null)
        'objectiveProgressPercent': snap.objectiveProgressPercent,
      'greenDays': snap.greenDays,
      'redDays': snap.redDays,
      'tradingDays': snap.tradingDays,
      'fillHintPath': languageCode == 'fr'
          ? 'Calendrier → ⚙ objectif mensuel (en haut)'
          : 'Calendar → ⚙ monthly goal (top)',
    };
  }
}
