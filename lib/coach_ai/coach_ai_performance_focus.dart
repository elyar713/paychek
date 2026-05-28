import 'package:flutter/material.dart';

import '../performance/performance_discipline_rollups.dart';
import '../performance/performance_journal_adapter.dart';
import '../performance/performance_paychek_lens.dart';
import '../performance/performance_period_filter.dart';
import '../performance/performance_trade_metrics.dart';
import '../performance/performance_trade_model.dart';
import '../trade/trade_models.dart';
import 'coach_ai_performance_summary.dart';
import 'coach_ai_response_format.dart';

class PerformanceLensAxisSnapshot {
  const PerformanceLensAxisSnapshot({
    required this.label,
    required this.qualifiedCount,
    required this.totalCount,
    this.avgPercent,
    this.winrateOnQualified,
  });

  final String label;
  final int qualifiedCount;
  final int totalCount;
  final int? avgPercent;
  final int? winrateOnQualified;
}

class PerformanceOvertradingBucketSnapshot {
  const PerformanceOvertradingBucketSnapshot({
    required this.label,
    required this.winratePercent,
    required this.tradeCount,
    required this.dayCount,
  });

  final String label;
  final int winratePercent;
  final int tradeCount;
  final int dayCount;

  bool get hasData => tradeCount > 0;
}

/// Focus Performance (page Performance PAYCHEK), pas audit global 4 piliers.
abstract final class CoachAiPerformanceFocus {
  static PerformancePeriodFilter resolvePeriod(String question) {
    final q = question.toLowerCase();
    if (RegExp(r'ce mois|this month|mois en cours|current month|mensuel').hasMatch(q)) {
      return PerformancePeriodFilter.currentMonth;
    }
    if (RegExp(r'cette semaine|this week|7 jours|une semaine|semaine').hasMatch(q)) {
      return PerformancePeriodFilter.oneWeek;
    }
    if (RegExp(r"aujourd'hui|aujourdhui|today|du jour").hasMatch(q)) {
      return PerformancePeriodFilter.oneDay;
    }
    return PerformancePeriodFilter.all;
  }

  static String periodLabel(PerformancePeriodFilter period, String languageCode) {
    return switch (period) {
      PerformancePeriodFilter.currentMonth =>
        languageCode == 'fr' ? 'Ce mois' : 'This month',
      PerformancePeriodFilter.oneWeek =>
        languageCode == 'fr' ? '7 jours' : '7 days',
      PerformancePeriodFilter.oneDay =>
        languageCode == 'fr' ? "Aujourd'hui" : 'Today',
      _ => languageCode == 'fr' ? 'Tout l’historique' : 'All time',
    };
  }

  static List<TradeListItem> filterJournalItems(
    Iterable<TradeListItem> items,
    PerformancePeriodFilter period,
  ) {
    final list = items.toList();
    if (period == PerformancePeriodFilter.all) return list;
    final trades = performanceTradesFromJournal(list);
    final anchor = anchorDateForTrades(trades);
    final range = rangeForPeriod(period: period, anchor: anchor);
    return filterJournalItemsByRange(list, range);
  }

  static List<Trade> filterPerformanceTrades(
    Iterable<TradeListItem> items,
    PerformancePeriodFilter period,
  ) {
    return performanceTradesFromJournal(filterJournalItems(items, period));
  }

  static bool isLensQuestion(String question) {
    final q = question.toLowerCase();
    if (RegExp(r'comment|how to|où |ou |where |configurer|modifier|engrenage|⚙').hasMatch(q)) {
      return false;
    }
    return RegExp(
      r'paychek lens|\blens\b|score discipline|discipline score|'
      r'trades non renseign|non renseignés|œil|oeil|\beye\b',
    ).hasMatch(q);
  }

  static bool isOvertradingQuestion(String question) {
    final q = question.toLowerCase();
    if (RegExp(r'comment|how to|où |ou |where ').hasMatch(q)) return false;
    return RegExp(
      r'overtrad|over.?trad|trop de trade|trop trade|'
      r'volume.{0,25}jour|trades?.{0,12}(par|\/| per ) jour|'
      r'journée.{0,20}volume|journal.{0,15}volume',
    ).hasMatch(q);
  }

  static Future<Map<String, dynamic>> summaryContextToJson(
    Iterable<TradeListItem> items,
    String languageCode,
    String question, {
    bool briefFollowUp = false,
  }) async {
    final period = resolvePeriod(question);
    final filtered = filterJournalItems(items, period);
    final split = CoachAiPerformanceSummary.build(filtered);
    final perfTrades = performanceTradesFromJournal(filtered);
    final roll = computeDisciplineRollups(perfTrades);
    final lens = buildPaychekLensSnapshot(
      perfTrades,
      locale: Locale(languageCode),
    );

    return <String, dynamic>{
      'coachInstructions': briefFollowUp
          ? CoachAiResponseFormat.performanceSummaryFollowUpInstructions(languageCode)
          : CoachAiResponseFormat.performanceSummaryInstructions(languageCode),
      'period': period.name,
      'periodLabel': periodLabel(period, languageCode),
      'performanceSplit': CoachAiPerformanceSummary.splitToJson(split),
      'paychekLens': <String, dynamic>{
        if (roll.hasData) 'compositeDisciplinePercent': roll.compositeDisciplinePct.round(),
        'tradesWithAnyDiscipline': roll.countWithAnyDisciplineField,
        if (lens.insight != null && lens.insight!.isNotEmpty) 'insight': lens.insight,
      },
      'fillHintPath': languageCode == 'fr'
          ? 'Plus → Performance (filtre période en haut)'
          : 'More → Performance (period filter at top)',
    };
  }

  static Future<Map<String, dynamic>> lensContextToJson(
    Iterable<TradeListItem> items,
    String languageCode,
    String question, {
    bool briefFollowUp = false,
  }) async {
    final period = resolvePeriod(question);
    final perfTrades = filterPerformanceTrades(items, period);
    final roll = computeDisciplineRollups(perfTrades);
    final lens = buildPaychekLensSnapshot(
      perfTrades,
      locale: Locale(languageCode),
    );

    return <String, dynamic>{
      'coachInstructions': briefFollowUp
          ? CoachAiResponseFormat.performanceLensFollowUpInstructions(languageCode)
          : CoachAiResponseFormat.performanceLensInstructions(languageCode),
      'period': period.name,
      'periodLabel': periodLabel(period, languageCode),
      'tradeCount': lens.tradeCount,
      if (roll.hasData) 'compositeDisciplinePercent': roll.compositeDisciplinePct.round(),
      'axes': [
        for (final axis in lens.axes)
          <String, dynamic>{
            'label': axis.label,
            'qualifiedCount': axis.qualifiedCount,
            'totalCount': axis.totalCount,
            if (axis.avgPct != null) 'avgPercent': axis.avgPct!.round(),
            if (axis.winRateOnQualified != null)
              'winrateOnQualified': (axis.winRateOnQualified! * 100).round(),
            'missingCount': axis.missingCount,
          },
      ],
      if (lens.insight != null && lens.insight!.isNotEmpty) 'insight': lens.insight,
      'fillHintPath': languageCode == 'fr'
          ? 'Plus → Performance → Paychek Lens'
          : 'More → Performance → Paychek Lens',
    };
  }

  static Future<Map<String, dynamic>> overtradingContextToJson(
    Iterable<TradeListItem> items,
    String languageCode,
    String question, {
    bool briefFollowUp = false,
  }) async {
    final period = resolvePeriod(question);
    final perfTrades = filterPerformanceTrades(items, period);
    final buckets = dailyJournalVolumeBucketWinRatesLocalized(
      perfTrades,
      locale: Locale(languageCode),
    );

    PerformanceOvertradingBucketSnapshot? worst;
    for (final b in buckets) {
      if (b.tradeCount == 0) continue;
      final snap = PerformanceOvertradingBucketSnapshot(
        label: b.label,
        winratePercent: (b.winRate * 100).round(),
        tradeCount: b.tradeCount,
        dayCount: b.dayCount,
      );
      if (worst == null || snap.winratePercent < worst.winratePercent) {
        worst = snap;
      }
    }

    return <String, dynamic>{
      'coachInstructions': briefFollowUp
          ? CoachAiResponseFormat.performanceOvertradingFollowUpInstructions(languageCode)
          : CoachAiResponseFormat.performanceOvertradingInstructions(languageCode),
      'period': period.name,
      'periodLabel': periodLabel(period, languageCode),
      'buckets': [
        for (final b in buckets)
          <String, dynamic>{
            'label': b.label,
            'winratePercent': (b.winRate * 100).round(),
            'tradeCount': b.tradeCount,
            'dayCount': b.dayCount,
          },
      ],
      if (worst != null)
        'lowestWinrateBucket': <String, dynamic>{
          'label': worst.label,
          'winratePercent': worst.winratePercent,
          'tradeCount': worst.tradeCount,
        },
      'fillHintPath': languageCode == 'fr'
          ? 'Plus → Performance → Journée & volume'
          : 'More → Performance → Day & volume',
    };
  }

  static List<PerformanceOvertradingBucketSnapshot> overtradingSnapshots(
    Iterable<TradeListItem> items,
    String languageCode,
    String question,
  ) {
    final perfTrades = filterPerformanceTrades(items, resolvePeriod(question));
    return [
      for (final b in dailyJournalVolumeBucketWinRatesLocalized(
        perfTrades,
        locale: Locale(languageCode),
      ))
        PerformanceOvertradingBucketSnapshot(
          label: b.label,
          winratePercent: (b.winRate * 100).round(),
          tradeCount: b.tradeCount,
          dayCount: b.dayCount,
        ),
    ];
  }

  static List<PerformanceLensAxisSnapshot> lensAxisSnapshots(
    Iterable<TradeListItem> items,
    String languageCode,
    String question,
  ) {
    final perfTrades = filterPerformanceTrades(items, resolvePeriod(question));
    final lens = buildPaychekLensSnapshot(
      perfTrades,
      locale: Locale(languageCode),
    );
    return [
      for (final axis in lens.axes)
        PerformanceLensAxisSnapshot(
          label: axis.label,
          qualifiedCount: axis.qualifiedCount,
          totalCount: axis.totalCount,
          avgPercent: axis.avgPct?.round(),
          winrateOnQualified: axis.winRateOnQualified == null
              ? null
              : (axis.winRateOnQualified! * 100).round(),
        ),
    ];
  }

  static int? compositeDisciplinePercent(
    Iterable<TradeListItem> items,
    String question,
  ) {
    final roll = computeDisciplineRollups(
      filterPerformanceTrades(items, resolvePeriod(question)),
    );
    if (!roll.hasData) return null;
    return roll.compositeDisciplinePct.round();
  }
}
