import 'package:flutter/material.dart';

import 'analyse_controller.dart';
import 'analyse_models.dart';
import 'analyse_page_content_contexte_options.dart';
import 'analyse_phase_locale.dart';
import 'analyse_report_snapshot.dart';
import 'analyse_tokens.dart';

String _stripReportDash(String s) {
  final t = s.trim();
  if (t.isEmpty || t == '—') return '';
  return t;
}

AnalyseDirectionBias _biasFromReportLabel(String label) {
  return AnalyseTokens.directionBiasFromReportLabel(label);
}

ContextePick<AnalyseTimeframe> _htfPickFromReportLine(String line) {
  final t = line.trim();
  if (t.isEmpty || t == '—') {
    return const ContextePick.enumOf(AnalyseTimeframe.daily);
  }
  for (final e in AnalyseTimeframe.values) {
    if (ctxLabelHtf(e) == t) {
      return ContextePick.enumOf(e);
    }
  }
  return ContextePick.customLabel(t);
}

ContextePick<AnalyseLocalTrend> _trendPickFromReportLabel(String reportLabel) {
  final raw = reportLabel.trim();
  if (raw.isEmpty || raw == '—') {
    return const ContextePick.enumOf(AnalyseLocalTrend.haussiere);
  }
  final lower = raw.toLowerCase();
  if (lower.contains('haussier') || lower.contains('haussiere')) {
    return const ContextePick.enumOf(AnalyseLocalTrend.haussiere);
  }
  if (lower.contains('bullish') || lower.contains('alcista')) {
    return const ContextePick.enumOf(AnalyseLocalTrend.haussiere);
  }
  if (lower.contains('baissier') || lower.contains('baissiere')) {
    return const ContextePick.enumOf(AnalyseLocalTrend.baissiere);
  }
  if (lower.contains('bearish') || lower.contains('bajista')) {
    return const ContextePick.enumOf(AnalyseLocalTrend.baissiere);
  }
  if (lower.contains('range')) {
    return const ContextePick.enumOf(AnalyseLocalTrend.range);
  }
  if (lower.contains('ranging') || lower.contains('rango')) {
    return const ContextePick.enumOf(AnalyseLocalTrend.range);
  }
  for (final e in AnalyseLocalTrend.values) {
    if (ctxLabelTrend(e).toUpperCase() == raw.toUpperCase()) {
      return ContextePick.enumOf(e);
    }
  }
  return ContextePick.customLabel(raw);
}

ContextePick<AnalysePhase> _phasePickFromReportLabel(String reportLabel) {
  final u = reportLabel.trim();
  if (u.isEmpty || u == '—') {
    return const ContextePick.enumOf(AnalysePhase.impulsion);
  }
  final detected = analysePhaseFromStoredLabel(u);
  if (detected != null) {
    return ContextePick.enumOf(detected);
  }
  for (final p in AnalysePhase.values) {
    if (ctxLabelPhase(p, const Locale('fr')).toUpperCase() == u.toUpperCase()) {
      return ContextePick.enumOf(p);
    }
  }
  return ContextePick.customLabel(reportLabel.trim());
}

void _applyHtfToController(AnalyseController c, String line) {
  final t = line.trim();
  if (t.isEmpty || t == '—') return;
  for (final tf in AnalyseTimeframe.values) {
    if (ctxLabelHtf(tf) == t) {
      c.htfPick = ContextePick.enumOf(tf);
      return;
    }
  }
  c.addHtfCustomLabel(t);
}

void _applyChartTfLabel(
  AnalyseController c,
  String raw, {
  required void Function(String) registerAndSet,
  required void Function(String) setOnly,
}) {
  final t = _stripReportDash(raw);
  if (t.isEmpty) return;
  if (_structureChartTfLabels.contains(t)) {
    setOnly(t);
  } else {
    registerAndSet(t);
  }
}

void _applyTrendToController(AnalyseController c, String line) {
  final pick = _trendPickFromReportLabel(line);
  if (pick.isEnum) {
    c.localTrendPick = pick;
    return;
  }
  c.addTrendCustomLabel(pick.custom ?? '');
}

void _applyPhaseToController(AnalyseController c, String line) {
  final pick = _phasePickFromReportLabel(line);
  if (pick.isEnum) {
    c.phasePick = pick;
    return;
  }
  c.addPhaseCustomLabel(pick.custom ?? '');
}

void _applyContexteDate(AnalyseController c, String? label) {
  if (label == null) return;
  final t = label.trim();
  if (t.isEmpty || t == '—') return;
  final parts = t.split('/');
  if (parts.length != 3) return;
  final day = int.tryParse(parts[0].trim());
  final month = int.tryParse(parts[1].trim());
  final year = int.tryParse(parts[2].trim());
  if (day == null || month == null || year == null) return;
  c.contexteAnalyseDate = DateTime(year, month, day);
}

AnalyseContexteTendanceSnapshot _contexteSnapshotFromReportCopy(
  AnalyseReportContexteCopy copy,
) {
  final htfPick = _htfPickFromReportLine(copy.contexteTfLine);
  final trendPick = _trendPickFromReportLabel(copy.trendLabel);
  final phasePick = _phasePickFromReportLabel(copy.phaseLabel);
  final htfCustom =
      htfPick.isEnum ? <String>[] : <String>[htfPick.custom ?? ''];
  final trendCustom =
      trendPick.isEnum ? <String>[] : <String>[trendPick.custom ?? ''];
  final phaseCustom =
      phasePick.isEnum ? <String>[] : <String>[phasePick.custom ?? ''];
  return AnalyseContexteTendanceSnapshot(
    bias: _biasFromReportLabel(copy.biasLabel),
    htfVisibleEnums: Set<AnalyseTimeframe>.from(AnalyseTimeframe.values),
    htfCustomLabels: htfCustom,
    htfPick: htfPick,
    trendVisibleEnums: Set<AnalyseLocalTrend>.from(AnalyseLocalTrend.values),
    trendCustomLabels: trendCustom,
    trendPick: trendPick,
    phaseVisibleEnums: Set<AnalysePhase>.from(AnalysePhase.values),
    phaseCustomLabels: phaseCustom,
    phasePick: phasePick,
  );
}

String _structureTfFromReportValue(String raw) {
  final t = _stripReportDash(raw);
  if (t.isEmpty) return AnalyseStructureChartTf.h1.label;
  return t;
}

AnalyseStructureSnapshot _structureSnapshotFromReportCopy(
  AnalyseReportStructureCopy copy,
) {
  return AnalyseStructureSnapshot(
    structureTf: _structureTfFromReportValue(copy.structureTf),
    dernierPoint: _stripReportDash(copy.chartisme),
    structureTenue: AnalyseStructureTenue.tenu,
    structureSupportMaj: _stripReportDash(copy.support),
    structureResistanceMaj: _stripReportDash(copy.resistance),
    structureSupportTested: false,
    structureResistanceTested: false,
    extraSupports: const [],
    extraResistances: const [],
  );
}

List<String> _parseIndicateursToolNames(String raw) {
  final t = raw.trim();
  if (t.isEmpty || t == '—') return [];
  return [
    for (final part in raw.split(RegExp(r'\s*\+\s*')))
      if (part.trim().isNotEmpty) part.trim(),
  ];
}

AnalyseIndicatorsSnapshot _indicatorsSnapshotFromReportCopy(
  AnalyseReportIndicatorsCopy copy,
) {
  final tools = _parseIndicateursToolNames(copy.indicateursOutils);
  return AnalyseIndicatorsSnapshot(
    indicatorsTf: _structureTfFromReportValue(copy.indicatorsTf),
    indicatorNames: List<String>.from(tools),
    indicatorSetupSelected: List<String>.from(tools),
    extraFields: const [],
    notesIndicators: copy.noteIndicators,
  );
}

String? _fibLevelFromOteLabel(String oteRaw) {
  final ote = oteRaw.trim();
  if (ote.isEmpty) return null;
  if (!ote.toUpperCase().endsWith(' OTE')) return null;
  final level = ote.substring(0, ote.length - 4).trim();
  return level.isEmpty ? null : level;
}

Set<String> get _structureChartTfLabels => {
      for (final e in AnalyseStructureChartTf.values) e.label,
    };

void _applySmcMainFromReport(AnalyseController c, AnalyseReportSnapshot s) {
  final ob = _stripReportDash(s.smcOb);
  final presets = _structureChartTfLabels;
  if (ob.isNotEmpty && presets.contains(ob)) {
    c.smcTf = ob;
    c.smcZone = '';
  } else {
    c.smcTf = AnalyseStructureChartTf.h1.label;
    c.smcZone = ob;
  }
  c.smcFvg = _stripReportDash(s.smcFvg);
  c.smcLiquidityPools = _stripReportDash(s.smcLiq);
  c.smcFibPrice = _stripReportDash(s.smcFibPrice);
  c.smcFibLevel = _fibLevelFromOteLabel(s.smcFibOteLabel);
  c.notesSmc = s.noteSmc;
}

AnalyseSmcSnapshot _smcSnapshotFromReportCopy(AnalyseReportSmcCopy copy) {
  final ob = _stripReportDash(copy.smcOb);
  final presets = _structureChartTfLabels;
  final useTf = ob.isNotEmpty && presets.contains(ob);
  return AnalyseSmcSnapshot(
    smcTf: useTf ? ob : AnalyseStructureChartTf.h1.label,
    smcZone: useTf ? '' : ob,
    smcFvg: _stripReportDash(copy.smcFvg),
    smcLiquidityPools: _stripReportDash(copy.smcLiq),
    smcFibLevel: _fibLevelFromOteLabel(copy.smcFibOteLabel),
    smcFibPrice: _stripReportDash(copy.smcFibPrice),
    notesSmc: copy.noteSmc,
    extraFields: const [],
  );
}

/// Remplit le contrôleur à partir d’un rapport validé (icône crayon).
void applyAnalyseReportToController(
  AnalyseController c,
  AnalyseReportSnapshot s,
) {
  c.prepareContextePillsForApplyFromReport();
  c.preparePhasePillsForApplyFromReport();

  c.contextEnabled = s.gaugeContextEnabled;
  c.structureEnabled = s.gaugeStructureEnabled;
  c.indicatorsEnabled = s.gaugeIndicatorsEnabled;
  c.smcEnabled = s.gaugeSmcEnabled;
  c.volumeProfileEnabled = s.gaugeVolumeProfileEnabled;

  c.analyseActif = _stripReportDash(s.actif);
  c.nomAnalyse = _stripReportDash(s.sousTitre);
  c.bias = _biasFromReportLabel(s.biasLabel);
  _applyContexteDate(c, s.contexteDateLabel);
  _applyHtfToController(c, s.contexteTfLine);
  _applyTrendToController(c, s.trendLabel);
  _applyPhaseToController(c, s.phaseLabel);
  c.notesTimeframe = s.noteContexte;

  c.replaceContexteSnapshots([
    for (final copy in s.contexteCopies ?? const <AnalyseReportContexteCopy>[])
      _contexteSnapshotFromReportCopy(copy),
  ]);

  _applyChartTfLabel(
    c,
    s.structureTf,
    registerAndSet: c.addStructureTfCustom,
    setOnly: (v) => c.structureTf = v,
  );
  c.structureDernierPoint = _stripReportDash(s.chartisme);
  c.structureSupportMaj = _stripReportDash(s.support);
  c.structureResistanceMaj = _stripReportDash(s.resistance);
  c.structureSupportTested = false;
  c.structureResistanceTested = false;
  while (c.extraSupports.isNotEmpty) {
    c.removeExtraSupport(c.extraSupports.length - 1);
  }
  while (c.extraResistances.isNotEmpty) {
    c.removeExtraResistance(c.extraResistances.length - 1);
  }
  c.notesStructure = s.noteStructure;

  c.replaceStructureSnapshots([
    for (final copy in s.structureCopies ?? const <AnalyseReportStructureCopy>[])
      _structureSnapshotFromReportCopy(copy),
  ]);

  final tools = _parseIndicateursToolNames(s.indicateursOutils);
  if (tools.isEmpty) {
    c.replaceIndicatorsPaletteAndSetup(
      List<String>.from(kAnalyseDefaultEntrySignalLabels),
      Set<String>.from(kAnalyseDefaultEntrySignalLabels),
    );
  } else {
    c.replaceIndicatorsPaletteAndSetup(tools, tools.toSet());
  }
  _applyChartTfLabel(
    c,
    s.indicatorsTf,
    registerAndSet: c.addIndicatorsTfCustom,
    setOnly: (v) => c.indicatorsTf = v,
  );
  while (c.indicatorExtraFields.isNotEmpty) {
    c.removeIndicatorExtraField(c.indicatorExtraFields.length - 1);
  }
  c.notesIndicators = s.noteIndicators;

  c.replaceIndicatorsSnapshots([
    for (final copy
        in s.indicatorsCopies ?? const <AnalyseReportIndicatorsCopy>[])
      _indicatorsSnapshotFromReportCopy(copy),
  ]);

  _applySmcMainFromReport(c, s);
  for (var i = c.smcZoneExtras.length - 1; i >= 0; i--) {
    c.removeSmcZoneExtraAt(i);
  }
  for (final e in s.smcObExtras) {
    c.addSmcZoneExtra(e);
  }
  for (var i = c.smcFvgExtras.length - 1; i >= 0; i--) {
    c.removeSmcFvgExtraAt(i);
  }
  for (final e in s.smcFvgExtras) {
    c.addSmcFvgExtra(e);
  }
  for (var i = c.smcLiquidityExtras.length - 1; i >= 0; i--) {
    c.removeSmcLiquidityExtraAt(i);
  }
  for (final e in s.smcLiquidityExtras) {
    c.addSmcLiquidityExtra(e);
  }
  while (c.smcExtraFields.isNotEmpty) {
    c.removeSmcExtraFieldAt(c.smcExtraFields.length - 1);
  }

  c.replaceSmcSnapshots([
    for (final copy in s.smcCopies ?? const <AnalyseReportSmcCopy>[])
      _smcSnapshotFromReportCopy(copy),
  ]);

  c.volumeProfilePoc = _stripReportDash(s.poc);
  c.volumeProfileVah = _stripReportDash(s.vah);
  c.volumeProfileVal = _stripReportDash(s.val);
  c.notesVolumeProfile = s.noteVolume;
  final volTf = s.volumeProfileTf?.trim();
  if (volTf != null && volTf.isNotEmpty && volTf != '—' && volTf != '-') {
    _applyChartTfLabel(
      c,
      volTf,
      registerAndSet: c.addVolumeProfileTfCustom,
      setOnly: (v) => c.volumeProfileTf = v,
    );
  }
  c.volumeProfileZoneActive = s.volumeProfileZoneActive ?? false;
  c.volumeProfileZoneFrom = _stripReportDash(s.volumeProfileZoneFrom ?? '');
  c.volumeProfileZoneTo = _stripReportDash(s.volumeProfileZoneTo ?? '');

  c.restoreImpactsSnapshot(
    s.gaugeImpactFeuille,
    s.gaugeImpactStructure,
    s.gaugeImpactIndicators,
    s.gaugeImpactSmc,
  );
  c.confidenceFeuille = s.gaugeFeuille;
  c.confidenceStructure = s.gaugeStructure;
  c.confidenceIndicators = s.gaugeIndicators;
  c.confidenceSmc = s.gaugeSmc;
}
