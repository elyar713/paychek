import 'dart:ui' show Locale;

import '../ajouter_trade/ajouter_trade_plan_analyse_feedback_items.dart';
import '../analyse/analyse_default_demo_seed.dart';
import '../analyse/analyse_report_snapshot.dart';
import '../l10n/app_localizations.dart';
import 'performance_trade_model.dart';

/// Index des lignes plan d'analyse (id → libellé) pour la carte Performance personnalisée.
class PerformanceCustomLensPlanIndex {
  const PerformanceCustomLensPlanIndex(this.labelsById);

  final Map<String, String> labelsById;

  String labelFor(String id) => labelsById[id] ?? id;

  Iterable<String> get ids => labelsById.keys;
}

void _absorbPlanReportRows(
  AnalyseReportSnapshot report,
  AppLocalizations l,
  Map<String, String> out,
) {
  for (final e in planAnalyseFeedbackEntriesFor(report, l)) {
    if (e is! PlanAnalyseFeedbackRow) continue;
    final h = (e.hint ?? '').trim();
    out[e.id] = h.isEmpty ? e.label : '${e.label} : $h';
  }
}

/// Union des lignes de tous les [planReport] des trades + rapport démo GOLD (structure complète).
PerformanceCustomLensPlanIndex buildPerformanceCustomLensPlanIndex({
  required List<Trade> trades,
  required AppLocalizations l,
  required Locale locale,
}) {
  final labels = <String, String>{};

  for (final t in trades) {
    final report = t.planReport;
    if (report != null) _absorbPlanReportRows(report, l, labels);
  }

  _absorbPlanReportRows(
    buildAnalyseDashboardPreviewSnapshot(locale: locale),
    l,
    labels,
  );

  return PerformanceCustomLensPlanIndex(labels);
}
