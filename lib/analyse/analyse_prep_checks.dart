import 'analyse_controller.dart';
import 'analyse_default_demo_seed.dart';
import 'analyse_firestore_sync.dart';
import 'analyse_realtime_notifier.dart';
import 'analyse_report_snapshot.dart';
import 'analyse_report_snapshot_codec.dart';
import 'analyse_reports_storage.dart';
import 'analyse_starred_report_storage.dart';

/// Identifiants alignés sur [PlanAnalyseFeedbackRow] (plan d’analyse / CSV / discipline).
abstract final class AnalysePrepCheckIds {
  AnalysePrepCheckIds._();

  static const ctxTimeframe = 'ctx_timeframe';
  static const ctxBias = 'ctx_bias';
  static const ctxPhase = 'ctx_phase';
  static const ctxTrend = 'ctx_trend';
  static const ctxNote = 'ctx_note';
  static const structTf = 'struct_tf';
  static const structChartisme = 'struct_chartisme';
  static const structSupport = 'struct_support';
  static const structResistance = 'struct_resistance';
  static const structNote = 'struct_note';
  static const indTf = 'ind_tf';
  static const indOutils = 'ind_outils';
  static const indNote = 'ind_note';
  static const smcOb = 'smc_ob';
  static const smcFvg = 'smc_fvg';
  static const smcLiq = 'smc_liq';
  static const smcFibPrix = 'smc_fib_prix';
  static const smcOte = 'smc_ote';
  static const smcNote = 'smc_note';
  static const volPoc = 'vol_poc';
  static const volVah = 'vol_vah';
  static const volVal = 'vol_val';
  static const volNote = 'vol_note';
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
    if (s.noteContexte.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.ctxNote);
    }
    if (s.noteStructure.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.structNote);
    }
  }
  if (s.gaugeStructureEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.structTf,
      AnalysePrepCheckIds.structChartisme,
      AnalysePrepCheckIds.structSupport,
      AnalysePrepCheckIds.structResistance,
    ]);
  }
  if (s.gaugeIndicatorsEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.indTf,
      AnalysePrepCheckIds.indOutils,
      AnalysePrepCheckIds.indNote,
    ]);
  }
  if (s.gaugeSmcEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.smcOb,
      AnalysePrepCheckIds.smcFvg,
      AnalysePrepCheckIds.smcLiq,
      AnalysePrepCheckIds.smcFibPrix,
    ]);
    if (s.smcFibOteLabel.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.smcOte);
    }
    if (s.noteSmc.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.smcNote);
    }
  }
  if (s.gaugeVolumeProfileEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.volPoc,
      AnalysePrepCheckIds.volVah,
      AnalysePrepCheckIds.volVal,
    ]);
    if (s.noteVolume.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.volNote);
    }
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

/// % affiché sur la carte dashboard / routine (0 si rien n’est coché).
int resolvePlanPrepCompletionPercent(AnalyseReportSnapshot snapshot) {
  final applicable = applicablePrepCheckIdsFromSnapshot(snapshot);
  if (applicable.isEmpty) return 0;
  return prepCompletionPercent(
    applicableIds: applicable,
    checkedIds: snapshot.prepCheckedIds ?? const [],
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
  final applicable = applicablePrepCheckIdsFromSnapshot(fresh);
  final checked = fresh.prepCheckedIds ?? const [];
  if (applicable.isNotEmpty && checked.isNotEmpty) {
    return prepCompletionPercent(
      applicableIds: applicable,
      checkedIds: checked,
    );
  }
  return fresh.globalConfidencePercent;
}

bool snapshotIsPrepChecked(AnalyseReportSnapshot s, String id) =>
    (s.prepCheckedIds ?? const []).contains(id);

AnalyseReportSnapshot snapshotWithPrepCheckedIds(
  AnalyseReportSnapshot s,
  List<String> ids,
) {
  final m = encodeAnalyseReportSnapshot(s);
  m['prepCheckedIds'] = ids;
  return decodeAnalyseReportSnapshot(m);
}

AnalyseReportSnapshot snapshotTogglePrepCheck(
  AnalyseReportSnapshot s,
  String id,
) {
  final checked = Set<String>.from(s.prepCheckedIds ?? const []);
  if (checked.contains(id)) {
    checked.remove(id);
  } else {
    checked.add(id);
  }
  return snapshotWithPrepCheckedIds(s, checked.toList()..sort());
}

/// Met à jour la prépa sur disque (liste rapports + étoile dashboard) si le rapport existe.
Future<AnalyseReportSnapshot> persistAnalyseReportPrepToggle(
  AnalyseReportSnapshot current,
  String prepId,
) async {
  final updated = snapshotTogglePrepCheck(current, prepId);
  final stored = await AnalyseReportsStorage.loadAll();
  final idx = stored.indexWhere(
    (r) => analyseReportsMatchForPlanLink(r, current),
  );
  if (idx >= 0) {
    final list = List<AnalyseReportSnapshot>.from(stored);
    list[idx] = updated;
    await AnalyseReportsStorage.saveAll(list);
    AnalyseFirestoreSync.pushIfSignedIn();
  }
  final starred = await AnalyseStarredReportStorage.load();
  if (starred != null && analyseSnapshotsEqualForStar(starred, current)) {
    await AnalyseStarredReportStorage.save(updated);
  }
  AnalyseRealtimeNotifier.bumpReports();
  AnalyseRealtimeNotifier.bump();
  return updated;
}
