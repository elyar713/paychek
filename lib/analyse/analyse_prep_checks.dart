import 'analyse_controller.dart';
import 'analyse_default_demo_seed.dart';
import 'analyse_report_snapshot.dart';

/// Identifiants alignés sur [PlanAnalyseFeedbackRow] (plan d’analyse / CSV / discipline).
abstract final class AnalysePrepCheckIds {
  AnalysePrepCheckIds._();

  static const ctxTimeframe = 'ctx_timeframe';
  static const ctxBias = 'ctx_bias';
  static const ctxPhase = 'ctx_phase';
  static const ctxTrend = 'ctx_trend';
  static const structTf = 'struct_tf';
  static const structSupport = 'struct_support';
  static const structResistance = 'struct_resistance';
  static const indTf = 'ind_tf';
  static const indOutils = 'ind_outils';
  static const smcOb = 'smc_ob';
  static const smcFvg = 'smc_fvg';
}

List<String> applicablePrepCheckIdsFromController(AnalyseController c) {
  final ids = <String>[];
  if (c.contextEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.ctxTimeframe,
      AnalysePrepCheckIds.ctxBias,
      AnalysePrepCheckIds.ctxTrend,
      AnalysePrepCheckIds.ctxPhase,
    ]);
  }
  if (c.structureEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.structTf,
      AnalysePrepCheckIds.structSupport,
      AnalysePrepCheckIds.structResistance,
    ]);
  }
  if (c.indicatorsEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.indTf,
      AnalysePrepCheckIds.indOutils,
    ]);
  }
  if (c.smcEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.smcOb,
      AnalysePrepCheckIds.smcFvg,
    ]);
  }
  return ids;
}

List<String> applicablePrepCheckIdsFromSnapshot(AnalyseReportSnapshot s) {
  final ids = <String>[];
  if (s.gaugeContextEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.ctxTimeframe,
      AnalysePrepCheckIds.ctxBias,
      AnalysePrepCheckIds.ctxTrend,
      AnalysePrepCheckIds.ctxPhase,
    ]);
  }
  if (s.gaugeStructureEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.structTf,
      AnalysePrepCheckIds.structSupport,
      AnalysePrepCheckIds.structResistance,
    ]);
  }
  if (s.gaugeIndicatorsEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.indTf,
      AnalysePrepCheckIds.indOutils,
    ]);
  }
  if (s.gaugeSmcEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.smcOb,
      AnalysePrepCheckIds.smcFvg,
    ]);
  }
  return ids;
}

int prepCompletionPercent({
  required Iterable<String> applicableIds,
  required Iterable<String> checkedIds,
}) {
  final applicable = applicableIds.toList();
  if (applicable.isEmpty) return 0;
  final checked = checkedIds.toSet();
  final done = applicable.where(checked.contains).length;
  return ((done / applicable.length) * 100).round().clamp(0, 100);
}

int resolvePlanPrepCompletionPercent(AnalyseReportSnapshot snapshot) {
  final applicable = applicablePrepCheckIdsFromSnapshot(snapshot);
  if (applicable.isEmpty) return snapshot.globalConfidencePercent;
  final checked = snapshot.prepCheckedIds ?? const [];
  if (checked.isEmpty) return snapshot.globalConfidencePercent;
  return prepCompletionPercent(
    applicableIds: applicable,
    checkedIds: checked,
  );
}

int controllerPrepCompletionPercent(AnalyseController c) {
  final applicable = applicablePrepCheckIdsFromController(c);
  return prepCompletionPercent(
    applicableIds: applicable,
    checkedIds: c.prepCheckedIds,
  );
}

/// % plan discipline (ajout manuel, CSV) : prépa cochée si dispo, sinon confiance.
int resolvePlanDisciplinePercent(
  AnalyseReportSnapshot? selected,
  List<AnalyseReportSnapshot> stored,
) {
  final fresh = findStoredAnalyseReportMatch(selected, stored) ?? selected;
  if (fresh == null) return 0;
  return resolvePlanPrepCompletionPercent(fresh);
}
