part of 'analyse_report_snapshot.dart';

/// Une ligne « Copie N » contexte dans le rapport (mêmes champs que la feuille principale, sans date).
@immutable
class AnalyseReportContexteCopy {
  const AnalyseReportContexteCopy({
    required this.biasLabel,
    required this.biasBg,
    required this.biasFg,
    required this.contexteTfLine,
    required this.trendLabel,
    required this.trendBg,
    required this.trendFg,
    required this.phaseLabel,
    required this.phaseBg,
    required this.phaseFg,
  });

  final String biasLabel;
  final Color biasBg;
  final Color biasFg;
  final String contexteTfLine;
  final String trendLabel;
  final Color trendBg;
  final Color trendFg;
  final String phaseLabel;
  final Color phaseBg;
  final Color phaseFg;
}

/// Support / résistance **rajouté** (hors champs majeurs) dans le rapport.
@immutable
class AnalyseReportStructureExtraLine {
  const AnalyseReportStructureExtraLine({
    required this.priceLabel,
    this.tenueLabel,
  });

  final String priceLabel;
  /// `Tenu` / `Cassé`, ou null si aucune puce choisie.
  final String? tenueLabel;
}

/// Bloc « Copie N » Structure dans le rapport (même schéma que la zone principale).
@immutable
class AnalyseReportStructureCopy {
  const AnalyseReportStructureCopy({
    required this.structureTf,
    required this.chartisme,
    required this.support,
    required this.resistance,
    required this.structureSupportTested,
    required this.structureResistanceTested,
    required this.structureExtraSupports,
    required this.structureExtraResistances,
  });

  final String structureTf;
  final String chartisme;
  final String support;
  final String resistance;
  final bool structureSupportTested;
  final bool structureResistanceTested;
  final List<AnalyseReportStructureExtraLine> structureExtraSupports;
  final List<AnalyseReportStructureExtraLine> structureExtraResistances;
}

/// Bloc « Copie N » Indicateurs dans le rapport (timeframe + outils actifs + note).
@immutable
class AnalyseReportIndicatorsCopy {
  const AnalyseReportIndicatorsCopy({
    required this.indicatorsTf,
    required this.indicateursOutils,
    required this.noteIndicators,
  });

  final String indicatorsTf;
  final String indicateursOutils;
  final String noteIndicators;
}

/// Bloc « Copie N » SMC dans le rapport (mêmes champs que la zone principale + note).
@immutable
class AnalyseReportSmcCopy {
  const AnalyseReportSmcCopy({
    required this.smcOb,
    required this.smcFvg,
    required this.smcLiq,
    required this.smcFibPrice,
    required this.smcFibOteLabel,
    required this.noteSmc,
  });

  final String smcOb;
  final String smcFvg;
  final String smcLiq;
  final String smcFibPrice;
  final String smcFibOteLabel;
  final String noteSmc;
}
