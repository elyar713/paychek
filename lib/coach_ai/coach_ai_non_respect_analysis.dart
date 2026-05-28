import 'package:flutter/widgets.dart';

import '../ajouter_trade/ajouter_trade_page_non_respect_labels.dart';
import '../ajouter_trade/ajouter_trade_plan_analyse_feedback_items.dart';
import '../checklist/checklist_models.dart';
import '../l10n/app_localizations.dart';
import '../performance/performance_custom_lens_labels.dart';
import '../performance/performance_custom_lens_model.dart';
import '../performance/performance_custom_lens_plan.dart';
import '../trade/trade_models.dart';

class CoachNonRespectItemStats {
  const CoachNonRespectItemStats({
    required this.pillar,
    required this.itemId,
    required this.label,
    required this.count,
    required this.onClosedLosses,
    required this.onClosedWins,
    required this.lossRateWhenViolatedPercent,
    required this.pnlSumWhenViolated,
  });

  final String pillar;
  final String itemId;
  final String label;
  final int count;
  final int onClosedLosses;
  final int onClosedWins;
  final double lossRateWhenViolatedPercent;
  final double pnlSumWhenViolated;
}

class CoachNonRespectReport {
  const CoachNonRespectReport({
    required this.topItems,
    required this.totalViolationMarks,
    required this.tradesWithAnyViolation,
    required this.closedLossesWithViolation,
    required this.closedWinsWithViolation,
  });

  final List<CoachNonRespectItemStats> topItems;
  final int totalViolationMarks;
  final int tradesWithAnyViolation;
  final int closedLossesWithViolation;
  final int closedWinsWithViolation;
}

class _Agg {
  _Agg({
    required this.pillar,
    required this.itemId,
    required this.label,
  });

  final String pillar;
  final String itemId;
  String label;
  int count = 0;
  int onClosedLosses = 0;
  int onClosedWins = 0;
  double pnlSum = 0;
}

/// Agrège les points non-respect et leur corrélation avec les pertes.
abstract final class CoachAiNonRespectAnalysis {
  static bool isNonRespectQuestion(String question) {
    final q = question.toLowerCase();
    return RegExp(
      r'non.?respect|non respect|pas respect|'
      r'point.{0,20}respect|respect.{0,30}(perte|perd|loss)|'
      r'(perte|perd|loss).{0,30}respect|violation|écarter|ecarter',
    ).hasMatch(q);
  }

  static CoachNonRespectReport? buildReport(
    BuildContext context,
    Iterable<TradeListItem> trades,
  ) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final checklistSections = defaultNouveauTradeSections();
    final planLabels = _planLabelsFromTrades(trades, l, locale);
    final planIndex = PerformanceCustomLensPlanIndex(planLabels);

    final agg = <String, _Agg>{};
    var totalMarks = 0;
    final tradesWithViolation = <String>{};

    void mark(String pillar, String id, String label, TradeListItem t) {
      totalMarks++;
      tradesWithViolation.add(t.id);
      final key = '$pillar\u001E$id';
      final row = agg.putIfAbsent(
        key,
        () => _Agg(pillar: pillar, itemId: id, label: label),
      );
      row.count++;
      if (label.trim().isNotEmpty) row.label = label.trim();
      if (!t.isClosed) return;
      row.pnlSum += t.gainAmount;
      if (t.countsAsClosedLoss) {
        row.onClosedLosses++;
      } else if (t.countsAsClosedWin) {
        row.onClosedWins++;
      }
    }

    for (final t in trades) {
      for (final id in t.checklistNonRespectIds) {
        mark(
          'checklist',
          id,
          performanceCustomLensElementLabel(
            dimension: PerformanceCustomLensDimension.checklist,
            elementId: id,
            l: l,
            locale: locale,
            checklistSections: checklistSections,
          ),
          t,
        );
      }
      for (final id in t.planNonRespectIds) {
        mark(
          'analysisPlan',
          id,
          performanceCustomLensElementLabel(
            dimension: PerformanceCustomLensDimension.plan,
            elementId: id,
            l: l,
            locale: locale,
            planIndex: planIndex,
          ),
          t,
        );
      }
      for (final id in t.strategieNonRespectIds) {
        mark(
          'strategy',
          id,
          labelForStrategieNonRespectId(
            id,
            t.strategieTitle,
            l: l,
            locale: locale,
          ),
          t,
        );
      }
      for (final id in t.etatNonRespectIds) {
        mark(
          'mentalState',
          id,
          performanceCustomLensElementLabel(
            dimension: PerformanceCustomLensDimension.etat,
            elementId: id,
            l: l,
            locale: locale,
          ),
          t,
        );
      }
    }

    if (agg.isEmpty) return null;

    final items = agg.values.map((row) {
      final closed = row.onClosedLosses + row.onClosedWins;
      final lossRate = closed > 0 ? (row.onClosedLosses * 100 / closed) : 0.0;
      return CoachNonRespectItemStats(
        pillar: row.pillar,
        itemId: row.itemId,
        label: row.label,
        count: row.count,
        onClosedLosses: row.onClosedLosses,
        onClosedWins: row.onClosedWins,
        lossRateWhenViolatedPercent: double.parse(lossRate.toStringAsFixed(1)),
        pnlSumWhenViolated: double.parse(row.pnlSum.toStringAsFixed(2)),
      );
    }).toList()
      ..sort((a, b) {
        final byLoss = b.onClosedLosses.compareTo(a.onClosedLosses);
        if (byLoss != 0) return byLoss;
        return b.count.compareTo(a.count);
      });

    var closedLossesWithViolation = 0;
    var closedWinsWithViolation = 0;
    for (final t in trades) {
      if (!t.isClosed) continue;
      final has = t.checklistNonRespectIds.isNotEmpty ||
          t.planNonRespectIds.isNotEmpty ||
          t.strategieNonRespectIds.isNotEmpty ||
          t.etatNonRespectIds.isNotEmpty;
      if (!has) continue;
      if (t.countsAsClosedLoss) {
        closedLossesWithViolation++;
      } else if (t.countsAsClosedWin) {
        closedWinsWithViolation++;
      }
    }

    return CoachNonRespectReport(
      topItems: items.take(12).toList(),
      totalViolationMarks: totalMarks,
      tradesWithAnyViolation: tradesWithViolation.length,
      closedLossesWithViolation: closedLossesWithViolation,
      closedWinsWithViolation: closedWinsWithViolation,
    );
  }

  static Map<String, String> _planLabelsFromTrades(
    Iterable<TradeListItem> trades,
    AppLocalizations l,
    Locale locale,
  ) {
    final labels = <String, String>{};
    for (final t in trades) {
      final report = t.planReport;
      if (report == null) continue;
      for (final e in planAnalyseFeedbackEntriesFor(report, l)) {
        if (e is! PlanAnalyseFeedbackRow) continue;
        final h = (e.hint ?? '').trim();
        labels[e.id] = h.isEmpty ? e.label : '${e.label} : $h';
      }
    }
    return labels;
  }

  static String pillarLabel(String pillar) => switch (pillar) {
        'checklist' => 'Checklist',
        'analysisPlan' => 'Analyse',
        'strategy' => 'Stratégie',
        'mentalState' => 'État mental',
        _ => pillar,
      };

  static Map<String, dynamic> reportToJson(CoachNonRespectReport r) {
    return <String, dynamic>{
      'totalViolationMarks': r.totalViolationMarks,
      'tradesWithAnyViolation': r.tradesWithAnyViolation,
      'closedLossesWithViolation': r.closedLossesWithViolation,
      'closedWinsWithViolation': r.closedWinsWithViolation,
      'topViolations': [
        for (final v in r.topItems)
          <String, dynamic>{
            'pillar': v.pillar,
            'pillarLabel': pillarLabel(v.pillar),
            'itemId': v.itemId,
            'label': v.label,
            'count': v.count,
            'onClosedLosses': v.onClosedLosses,
            'onClosedWins': v.onClosedWins,
            'lossRateWhenViolatedPercent': v.lossRateWhenViolatedPercent,
            'pnlSumWhenViolated': v.pnlSumWhenViolated,
          },
      ],
      'note':
          'Chaque ligne = point coché « non respecté » sur un trade. '
          'lossRateWhenViolatedPercent = % de trades clôturés perdants parmi ceux où ce point était marqué.',
    };
  }
}
