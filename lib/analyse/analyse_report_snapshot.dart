import 'package:flutter/material.dart';

import '../performance/performance_locale_copy.dart';
import 'analyse_controller.dart';
import 'analyse_models.dart';
import 'analyse_phase_locale.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_gauge.dart';

part 'analyse_report_snapshot_models.dart';
part 'analyse_report_snapshot_helpers.dart';

/// Données figées du rapport affiché après validation.
@immutable
class AnalyseReportSnapshot {
  const AnalyseReportSnapshot({
    required this.actif,
    required this.sousTitre,
    required this.biasLabel,
    required this.biasBg,
    required this.biasFg,
    required this.globalConfidencePercent,
    required this.globalConfidenceColor,
    required this.contexteTfLine,
    required this.phaseLabel,
    required this.phaseBg,
    required this.phaseFg,
    required this.trendLabel,
    required this.trendBg,
    required this.trendFg,
    /// Peut être null juste après un hot reload si un snapshot a été créé avant l’ajout du champ.
    this.contexteDateLabel,
    required this.structureTf,
    required this.chartisme,
    required this.support,
    required this.resistance,
    /// Peut être null juste après un hot reload si le snapshot date d’avant ces champs.
    this.structureSupportTested,
    this.structureResistanceTested,
    /// Null si snapshot créé avant cet ajout (ex. hot reload) — traiter comme liste vide.
    this.structureExtraSupports,
    this.structureExtraResistances,
    String? noteContexte,
    String? noteStructure,
    required this.indicatorsTf,
    required this.indicateursOutils,
    required this.noteIndicators,
    required this.smcOb,
    required this.smcFvg,
    required this.smcLiq,
    required this.smcFibPrice,
    required this.smcFibOteLabel,
    required this.noteSmc,
    required this.poc,
    required this.vah,
    required this.val,
    required this.noteVolume,
    this.volumeProfileTf,
    this.volumeProfileZoneActive,
    this.volumeProfileZoneFrom,
    this.volumeProfileZoneTo,
    required this.gaugeFeuille,
    required this.gaugeStructure,
    required this.gaugeIndicators,
    required this.gaugeSmc,
    required this.gaugeImpactFeuille,
    required this.gaugeImpactStructure,
    required this.gaugeImpactIndicators,
    required this.gaugeImpactSmc,
    required this.gaugeContextEnabled,
    required this.gaugeStructureEnabled,
    required this.gaugeIndicatorsEnabled,
    required this.gaugeSmcEnabled,
    /// Profil de volume : si false, la carte ne figure pas dans le rapport.
    required this.gaugeVolumeProfileEnabled,
    /// Peut être null juste après un hot reload si le snapshot date d’avant ce champ.
    this.contexteCopies,
    /// Null ou vide : pas de copies Structure dans le rapport.
    this.structureCopies,
    /// Copies de la section Indicateurs (TF + setup + notes par bloc).
    this.indicatorsCopies,
    /// Copies SMC & liquidité sous la zone principale.
    this.smcCopies,
  })  : _noteContexte = noteContexte,
        _noteStructure = noteStructure;

  final String actif;
  final String sousTitre;
  final String biasLabel;
  final Color biasBg;
  final Color biasFg;
  final int globalConfidencePercent;
  final Color globalConfidenceColor;

  final String contexteTfLine;
  final String phaseLabel;
  final Color phaseBg;
  final Color phaseFg;
  final String trendLabel;
  final Color trendBg;
  final Color trendFg;
  /// Date d’analyse (jj/mm/aaaa), même source que la feuille Tendance.
  final String? contexteDateLabel;

  final String structureTf;
  final String chartisme;
  final String support;
  final String resistance;

  final bool? structureSupportTested;
  final bool? structureResistanceTested;

  final List<AnalyseReportStructureExtraLine>? structureExtraSupports;
  final List<AnalyseReportStructureExtraLine>? structureExtraResistances;

  /// Stockage nullable : après hot reload, un snapshot créé avant le split contexte/structure
  /// peut avoir `null` ici — les getters exposent toujours une [String] sûre.
  final String? _noteContexte;
  final String? _noteStructure;

  String get noteContexte => _noteContexte ?? '';
  String get noteStructure => _noteStructure ?? '';

  final String noteIndicators;
  final String noteSmc;
  final String noteVolume;

  final String indicatorsTf;
  final String indicateursOutils;

  final String smcOb;
  final String smcFvg;
  final String smcLiq;
  final String smcFibPrice;
  final String smcFibOteLabel;

  final String poc;
  final String vah;
  final String val;

  final String? volumeProfileTf;
  final bool? volumeProfileZoneActive;
  final String? volumeProfileZoneFrom;
  final String? volumeProfileZoneTo;

  final int gaugeFeuille;
  final int gaugeStructure;
  final int gaugeIndicators;
  final int gaugeSmc;
  final int gaugeImpactFeuille;
  final int gaugeImpactStructure;
  final int gaugeImpactIndicators;
  final int gaugeImpactSmc;
  final bool gaugeContextEnabled;
  final bool gaugeStructureEnabled;
  final bool gaugeIndicatorsEnabled;
  final bool gaugeSmcEnabled;
  final bool gaugeVolumeProfileEnabled;

  /// Blocs « Copie 1, 2… » sous le contexte principal (vide si null ou liste vide).
  final List<AnalyseReportContexteCopy>? contexteCopies;

  /// Blocs Structure « Copie 1, 2… » sous la zone principale.
  final List<AnalyseReportStructureCopy>? structureCopies;

  /// Blocs Indicateurs « Copie 1, 2… » sous la zone principale.
  final List<AnalyseReportIndicatorsCopy>? indicatorsCopies;

  /// Blocs SMC « Copie 1, 2… » sous la zone principale.
  final List<AnalyseReportSmcCopy>? smcCopies;

  factory AnalyseReportSnapshot.fromController(
    AnalyseController c, {
    Locale? locale,
  }) {
    final loc = locale ?? WidgetsBinding.instance.platformDispatcher.locale;
    final p = computeAnalyseGlobalConfidencePercent(
      feuille: c.confidenceFeuille,
      structure: c.confidenceStructure,
      indicators: c.confidenceIndicators,
      smc: c.confidenceSmc,
      impactFeuille: c.impactFeuille,
      impactStructure: c.impactStructure,
      impactIndicators: c.impactIndicators,
      impactSmc: c.impactSmc,
      contextEnabled: c.contextEnabled,
      structureEnabled: c.structureEnabled,
      indicatorsEnabled: c.indicatorsEnabled,
      smcEnabled: c.smcEnabled,
    );
    final gColor = AnalyseTokens.confidenceColorForPercent(p);

    final (biasBg, biasFg) = _biasColors(c.bias);
    final htfLine = _htfPickLabel(c);

    final phaseStr = _phasePickLabel(c, loc);
    final trendStr = _trendPickLabel(c, loc);
    final (phBg, phFg) = _phasePillColors();
    final (trBg, trFg) = _trendPillColors(c);

    final fibLevel = c.smcFibLevel?.trim();
    final ote = (fibLevel != null && fibLevel.isNotEmpty)
        ? '$fibLevel OTE'
        : '';

    final mainIndicateursSelected = <String>[
      for (final n in c.indicators)
        if (c.indicatorSetupIsSelected(n)) n
    ];
    final tools = _reportIndicateursOutilsLine(mainIndicateursSelected);

    final indicatorsCopies = <AnalyseReportIndicatorsCopy>[
      for (final s in c.indicatorsSnapshots)
        AnalyseReportIndicatorsCopy(
          indicatorsTf: _orDash(s.indicatorsTf),
          indicateursOutils:
              _reportIndicateursOutilsLine(s.activeIndicatorSetup),
          noteIndicators: s.notesIndicators.trim(),
        ),
    ];

    final copies = <AnalyseReportContexteCopy>[
      for (final s in c.contexteSnapshots) _buildReportContexteCopy(s, loc),
    ];

    final structureCopies = <AnalyseReportStructureCopy>[
      for (final s in c.structureSnapshots)
        _reportStructureCopyFromSnapshot(s, loc),
    ];

    final smcCopies = <AnalyseReportSmcCopy>[
      for (final s in c.smcSnapshots)
        AnalyseReportSmcCopy(
          smcOb: _orDash(_smcObLineFromSnapshot(s)),
          smcFvg: _orDash(s.smcFvg),
          smcLiq: _orDash(s.smcLiquidityPools),
          smcFibPrice: _orDash(s.smcFibPrice),
          smcFibOteLabel: _smcFibOteLabelFromSnapshot(s),
          noteSmc: s.notesSmc.trim(),
        ),
    ];

    return AnalyseReportSnapshot(
      actif: _orDash(c.analyseActif),
      sousTitre: _orDash(c.nomAnalyse),
      biasLabel: _biasLabel(c.bias, loc),
      biasBg: biasBg,
      biasFg: biasFg,
      globalConfidencePercent: p,
      globalConfidenceColor: gColor,
      contexteTfLine: htfLine,
      phaseLabel: phaseStr.toUpperCase(),
      phaseBg: phBg,
      phaseFg: phFg,
      trendLabel: trendStr.toUpperCase(),
      trendBg: trBg,
      trendFg: trFg,
      contexteDateLabel: c.contexteAnalyseDateLabel,
      structureTf: _orDash(c.structureTf),
      chartisme: _orDash(c.structureDernierPoint),
      support: _orDash(c.structureSupportMaj),
      resistance: _orDash(c.structureResistanceMaj),
      structureSupportTested: c.structureSupportTested,
      structureResistanceTested: c.structureResistanceTested,
      structureExtraSupports: [
        for (final e in c.extraSupports) _reportStructureExtraLine(e, loc),
      ],
      structureExtraResistances: [
        for (final e in c.extraResistances) _reportStructureExtraLine(e, loc),
      ],
      noteContexte: c.notesTimeframe.trim(),
      noteStructure: c.notesStructure.trim(),
      indicatorsTf: _orDash(c.indicatorsTf),
      indicateursOutils: tools,
      noteIndicators: c.notesIndicators.trim(),
      smcOb: _orDash(_smcObLine(c)),
      smcFvg: _orDash(c.smcFvg),
      smcLiq: _orDash(c.smcLiquidityPools),
      smcFibPrice: _orDash(c.smcFibPrice),
      smcFibOteLabel: ote.isEmpty ? '' : ote,
      noteSmc: c.notesSmc.trim(),
      poc: _orDash(c.volumeProfilePoc),
      vah: _orDash(c.volumeProfileVah),
      val: _orDash(c.volumeProfileVal),
      noteVolume: c.notesVolumeProfile.trim(),
      volumeProfileTf: _orDash(c.volumeProfileTf),
      volumeProfileZoneActive: c.volumeProfileZoneActive,
      volumeProfileZoneFrom: c.volumeProfileZoneFrom.trim(),
      volumeProfileZoneTo: c.volumeProfileZoneTo.trim(),
      gaugeFeuille: c.confidenceFeuille,
      gaugeStructure: c.confidenceStructure,
      gaugeIndicators: c.confidenceIndicators,
      gaugeSmc: c.confidenceSmc,
      gaugeImpactFeuille: c.impactFeuille,
      gaugeImpactStructure: c.impactStructure,
      gaugeImpactIndicators: c.impactIndicators,
      gaugeImpactSmc: c.impactSmc,
      gaugeContextEnabled: c.contextEnabled,
      gaugeStructureEnabled: c.structureEnabled,
      gaugeIndicatorsEnabled: c.indicatorsEnabled,
      gaugeSmcEnabled: c.smcEnabled,
      gaugeVolumeProfileEnabled: c.volumeProfileEnabled,
      contexteCopies: copies,
      structureCopies: structureCopies,
      indicatorsCopies:
          indicatorsCopies.isEmpty ? null : indicatorsCopies,
      smcCopies: smcCopies.isEmpty ? null : smcCopies,
    );
  }
}
