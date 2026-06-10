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

/// Valeur vide ou placeholder rapport OLED (`—`).
bool analyseReportOledValueIsEmpty(String? raw) {
  final t = (raw ?? '').trim();
  return t.isEmpty || t == '—';
}

bool analyseReportSmcFieldIsEmpty(String main, List<String> extras) {
  if (!analyseReportOledValueIsEmpty(main)) return false;
  for (final e in extras) {
    if (!analyseReportOledValueIsEmpty(e)) return false;
  }
  return true;
}

/// Critères cochables visibles (générateur + rapport figé OLED).
List<String> _applicablePrepCheckIds({
  required bool contextEnabled,
  required bool structureEnabled,
  required bool indicatorsEnabled,
  required bool smcEnabled,
  required bool volumeEnabled,
  required String noteContexte,
  required String noteStructure,
  required String noteIndicators,
  required String noteSmc,
  required String noteVolume,
  required String smcFibOteLabel,
  required String structureTf,
  required String chartisme,
  required String support,
  required String resistance,
  required String indicatorsTf,
  required String indicateursOutils,
  required String smcOb,
  required List<String> smcObExtras,
  required String smcFvg,
  required List<String> smcFvgExtras,
  required String smcLiq,
  required List<String> smcLiqExtras,
  required String smcFibPrice,
  required String poc,
  required String vah,
  required String val,
}) {
  final ids = <String>[];
  if (contextEnabled) {
    ids.addAll([
      AnalysePrepCheckIds.ctxTimeframe,
      AnalysePrepCheckIds.ctxBias,
      AnalysePrepCheckIds.ctxTrend,
      AnalysePrepCheckIds.ctxPhase,
    ]);
    if (noteContexte.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.ctxNote);
    }
    if (noteStructure.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.structNote);
    }
  }
  if (structureEnabled) {
    if (!analyseReportOledValueIsEmpty(structureTf)) {
      ids.add(AnalysePrepCheckIds.structTf);
    }
    if (!analyseReportOledValueIsEmpty(chartisme)) {
      ids.add(AnalysePrepCheckIds.structChartisme);
    }
    if (!analyseReportOledValueIsEmpty(support)) {
      ids.add(AnalysePrepCheckIds.structSupport);
    }
    if (!analyseReportOledValueIsEmpty(resistance)) {
      ids.add(AnalysePrepCheckIds.structResistance);
    }
  }
  if (indicatorsEnabled) {
    if (!analyseReportOledValueIsEmpty(indicatorsTf)) {
      ids.add(AnalysePrepCheckIds.indTf);
    }
    if (!analyseReportOledValueIsEmpty(indicateursOutils)) {
      ids.add(AnalysePrepCheckIds.indOutils);
    }
    if (noteIndicators.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.indNote);
    }
  }
  if (smcEnabled) {
    if (!analyseReportSmcFieldIsEmpty(smcOb, smcObExtras)) {
      ids.add(AnalysePrepCheckIds.smcOb);
    }
    if (!analyseReportSmcFieldIsEmpty(smcFvg, smcFvgExtras)) {
      ids.add(AnalysePrepCheckIds.smcFvg);
    }
    if (!analyseReportSmcFieldIsEmpty(smcLiq, smcLiqExtras)) {
      ids.add(AnalysePrepCheckIds.smcLiq);
    }
    if (!analyseReportOledValueIsEmpty(smcFibPrice)) {
      ids.add(AnalysePrepCheckIds.smcFibPrix);
    }
    if (smcFibOteLabel.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.smcOte);
    }
    if (noteSmc.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.smcNote);
    }
  }
  if (volumeEnabled) {
    if (!analyseReportOledValueIsEmpty(poc)) {
      ids.add(AnalysePrepCheckIds.volPoc);
    }
    if (!analyseReportOledValueIsEmpty(vah)) {
      ids.add(AnalysePrepCheckIds.volVah);
    }
    if (!analyseReportOledValueIsEmpty(val)) {
      ids.add(AnalysePrepCheckIds.volVal);
    }
    if (noteVolume.trim().isNotEmpty) {
      ids.add(AnalysePrepCheckIds.volNote);
    }
  }
  return ids;
}

List<String> applicablePrepCheckIdsFromController(AnalyseController c) {
  final fibLevel = c.smcFibLevel?.trim() ?? '';
  final oteLabel =
      fibLevel.isNotEmpty ? '$fibLevel OTE' : '';
  return _applicablePrepCheckIds(
    contextEnabled: c.contextEnabled,
    structureEnabled: c.structureEnabled,
    indicatorsEnabled: c.indicatorsEnabled,
    smcEnabled: c.smcEnabled,
    volumeEnabled: c.volumeProfileEnabled,
    noteContexte: c.notesTimeframe,
    noteStructure: c.notesStructure,
    noteIndicators: c.notesIndicators,
    noteSmc: c.notesSmc,
    noteVolume: c.notesVolumeProfile,
    smcFibOteLabel: oteLabel,
    structureTf: c.structureTf,
    chartisme: c.structureDernierPoint,
    support: c.structureSupportMaj,
    resistance: c.structureResistanceMaj,
    indicatorsTf: c.indicatorsTf,
    indicateursOutils: [
      for (final n in c.indicators)
        if (c.indicatorSetupIsSelected(n)) n,
    ].join(' + '),
    smcOb: () {
      final z = c.smcZone.trim();
      return z.isNotEmpty ? z : c.smcTf.trim();
    }(),
    smcObExtras: c.smcZoneExtras,
    smcFvg: c.smcFvg,
    smcFvgExtras: c.smcFvgExtras,
    smcLiq: c.smcLiquidityPools,
    smcLiqExtras: c.smcLiquidityExtras,
    smcFibPrice: c.smcFibPrice,
    poc: c.volumeProfilePoc,
    vah: c.volumeProfileVah,
    val: c.volumeProfileVal,
  );
}

List<String> applicablePrepCheckIdsFromSnapshot(AnalyseReportSnapshot s) {
  return _applicablePrepCheckIds(
    contextEnabled: s.gaugeContextEnabled,
    structureEnabled: s.gaugeStructureEnabled,
    indicatorsEnabled: s.gaugeIndicatorsEnabled,
    smcEnabled: s.gaugeSmcEnabled,
    volumeEnabled: s.gaugeVolumeProfileEnabled,
    noteContexte: s.noteContexte,
    noteStructure: s.noteStructure,
    noteIndicators: s.noteIndicators,
    noteSmc: s.noteSmc,
    noteVolume: s.noteVolume,
    smcFibOteLabel: s.smcFibOteLabel,
    structureTf: s.structureTf,
    chartisme: s.chartisme,
    support: s.support,
    resistance: s.resistance,
    indicatorsTf: s.indicatorsTf,
    indicateursOutils: s.indicateursOutils,
    smcOb: s.smcOb,
    smcObExtras: s.smcObExtras,
    smcFvg: s.smcFvg,
    smcFvgExtras: s.smcFvgExtras,
    smcLiq: s.smcLiq,
    smcLiqExtras: s.smcLiquidityExtras,
    smcFibPrice: s.smcFibPrice,
    poc: s.poc,
    vah: s.vah,
    val: s.val,
  );
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
    AnalyseRealtimeNotifier.bumpReports();
    AnalyseRealtimeNotifier.bump();
  } else {
    final starred = await AnalyseStarredReportStorage.load();
    if (starred != null && analyseSnapshotsEqualForStar(starred, current)) {
      await AnalyseStarredReportStorage.save(updated);
      AnalyseRealtimeNotifier.bumpReports();
      AnalyseRealtimeNotifier.bump();
    }
  }
  return updated;
}
