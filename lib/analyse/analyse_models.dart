import 'package:flutter/foundation.dart';

enum AnalysePhase { accumulation, impulsion, distribution }

enum AnalyseDirectionBias { achat, vente, surveiller }

enum AnalyseTimeframe { daily, h4, h1 }

enum AnalyseLocalTrend { haussiere, baissiere, range }

enum AnalyseStructureTenue { tenu, casse }

/// Valeur d’une pilule contexte : entrée **enum** ou **libellé personnalisé**.
@immutable
class ContextePick<T extends Enum> {
  const ContextePick.enumOf(this.enumVal) : custom = null;
  const ContextePick.customLabel(this.custom) : enumVal = null;

  final T? enumVal;
  final String? custom;

  bool get isEnum => enumVal != null;

  @override
  bool operator ==(Object other) {
    return other is ContextePick &&
        other.enumVal == enumVal &&
        other.custom == custom;
  }

  @override
  int get hashCode => Object.hash(enumVal, custom);
}

/// Instantané Tendance (duplication affichée sous les puces principales).
class AnalyseContexteTendanceSnapshot {
  const AnalyseContexteTendanceSnapshot({
    required this.bias,
    required this.htfVisibleEnums,
    required this.htfCustomLabels,
    required this.htfPick,
    required this.trendVisibleEnums,
    required this.trendCustomLabels,
    required this.trendPick,
    required this.phaseVisibleEnums,
    required this.phaseCustomLabels,
    required this.phasePick,
  });

  final AnalyseDirectionBias bias;
  final Set<AnalyseTimeframe> htfVisibleEnums;
  final List<String> htfCustomLabels;
  final ContextePick<AnalyseTimeframe> htfPick;
  final Set<AnalyseLocalTrend> trendVisibleEnums;
  final List<String> trendCustomLabels;
  final ContextePick<AnalyseLocalTrend> trendPick;
  final Set<AnalysePhase> phaseVisibleEnums;
  final List<String> phaseCustomLabels;
  final ContextePick<AnalysePhase> phasePick;

  AnalyseContexteTendanceSnapshot copyWith({
    AnalyseDirectionBias? bias,
    Set<AnalyseTimeframe>? htfVisibleEnums,
    List<String>? htfCustomLabels,
    ContextePick<AnalyseTimeframe>? htfPick,
    Set<AnalyseLocalTrend>? trendVisibleEnums,
    List<String>? trendCustomLabels,
    ContextePick<AnalyseLocalTrend>? trendPick,
    Set<AnalysePhase>? phaseVisibleEnums,
    List<String>? phaseCustomLabels,
    ContextePick<AnalysePhase>? phasePick,
  }) {
    return AnalyseContexteTendanceSnapshot(
      bias: bias ?? this.bias,
      htfVisibleEnums: htfVisibleEnums ?? this.htfVisibleEnums,
      htfCustomLabels: htfCustomLabels ?? this.htfCustomLabels,
      htfPick: htfPick ?? this.htfPick,
      trendVisibleEnums: trendVisibleEnums ?? this.trendVisibleEnums,
      trendCustomLabels: trendCustomLabels ?? this.trendCustomLabels,
      trendPick: trendPick ?? this.trendPick,
      phaseVisibleEnums: phaseVisibleEnums ?? this.phaseVisibleEnums,
      phaseCustomLabels: phaseCustomLabels ?? this.phaseCustomLabels,
      phasePick: phasePick ?? this.phasePick,
    );
  }
}

/// Niveau support / résistance ajouté en plus des champs « majeurs ».
class AnalyseStructureExtraLevel {
  AnalyseStructureExtraLevel({
    this.price = '',
    this.tenue,
  });

  String price;
  /// `null` : aucun choix (puces Tenu / Cassé grises).
  AnalyseStructureTenue? tenue;
}

/// Instantané Structure & chartisme (copie affichée avant les notes).
@immutable
class AnalyseStructureSnapshot {
  const AnalyseStructureSnapshot({
    required this.structureTf,
    required this.dernierPoint,
    required this.structureTenue,
    required this.structureSupportMaj,
    required this.structureResistanceMaj,
    required this.structureSupportTested,
    required this.structureResistanceTested,
    required this.extraSupports,
    required this.extraResistances,
  });

  final String structureTf;
  final String dernierPoint;
  final AnalyseStructureTenue? structureTenue;
  final String structureSupportMaj;
  final String structureResistanceMaj;
  final bool structureSupportTested;
  final bool structureResistanceTested;
  final List<AnalyseStructureExtraLevel> extraSupports;
  final List<AnalyseStructureExtraLevel> extraResistances;

  AnalyseStructureSnapshot copyWith({
    String? structureTf,
    String? dernierPoint,
    AnalyseStructureTenue? structureTenue,
    String? structureSupportMaj,
    String? structureResistanceMaj,
    bool? structureSupportTested,
    bool? structureResistanceTested,
    List<AnalyseStructureExtraLevel>? extraSupports,
    List<AnalyseStructureExtraLevel>? extraResistances,
  }) {
    return AnalyseStructureSnapshot(
      structureTf: structureTf ?? this.structureTf,
      dernierPoint: dernierPoint ?? this.dernierPoint,
      structureTenue: structureTenue ?? this.structureTenue,
      structureSupportMaj: structureSupportMaj ?? this.structureSupportMaj,
      structureResistanceMaj: structureResistanceMaj ?? this.structureResistanceMaj,
      structureSupportTested: structureSupportTested ?? this.structureSupportTested,
      structureResistanceTested:
          structureResistanceTested ?? this.structureResistanceTested,
      extraSupports: extraSupports ?? this.extraSupports,
      extraResistances: extraResistances ?? this.extraResistances,
    );
  }
}

/// Instantané Indicateurs (copie : TF + setup + champs libres + notes, **sans** confiance / impact).
@immutable
class AnalyseIndicatorsSnapshot {
  const AnalyseIndicatorsSnapshot({
    required this.indicatorsTf,
    required this.indicatorNames,
    this.indicatorSetupSelected,
    required this.extraFields,
    required this.notesIndicators,
  });

  final String indicatorsTf;
  final List<String> indicatorNames;
  /// Outils cochés dans le setup (ordre des puces). `null` = données anciennes ou hot reload
  /// avant ce champ → [activeIndicatorSetup] considère tous les [indicatorNames] comme cochés.
  final List<String>? indicatorSetupSelected;
  final List<String> extraFields;
  final String notesIndicators;

  /// Lecture sûre pour l’UI et le rapport (évite le crash si [indicatorSetupSelected] est null).
  List<String> get activeIndicatorSetup =>
      indicatorSetupSelected ?? List<String>.from(indicatorNames);

  AnalyseIndicatorsSnapshot copyWith({
    String? indicatorsTf,
    List<String>? indicatorNames,
    List<String>? indicatorSetupSelected,
    List<String>? extraFields,
    String? notesIndicators,
  }) {
    return AnalyseIndicatorsSnapshot(
      indicatorsTf: indicatorsTf ?? this.indicatorsTf,
      indicatorNames: indicatorNames ?? this.indicatorNames,
      indicatorSetupSelected:
          indicatorSetupSelected ?? this.indicatorSetupSelected,
      extraFields: extraFields ?? this.extraFields,
      notesIndicators: notesIndicators ?? this.notesIndicators,
    );
  }
}

/// Instantané SMC & liquidité (copie : champs + notes, **sans** confiance / impact).
@immutable
class AnalyseSmcSnapshot {
  const AnalyseSmcSnapshot({
    required this.smcTf,
    required this.smcZone,
    required this.smcFvg,
    required this.smcLiquidityPools,
    required this.smcFibLevel,
    required this.smcFibPrice,
    required this.notesSmc,
    this.extraFields = const [],
  });

  final String smcTf;
  final String smcZone;
  final String smcFvg;
  final String smcLiquidityPools;
  final String? smcFibLevel;
  final String smcFibPrice;
  final String notesSmc;
  final List<String> extraFields;

  AnalyseSmcSnapshot copyWith({
    String? smcTf,
    String? smcZone,
    String? smcFvg,
    String? smcLiquidityPools,
    String? smcFibPrice,
    String? notesSmc,
    String? smcFibLevel,
    List<String>? extraFields,
  }) {
    return AnalyseSmcSnapshot(
      smcTf: smcTf ?? this.smcTf,
      smcZone: smcZone ?? this.smcZone,
      smcFvg: smcFvg ?? this.smcFvg,
      smcLiquidityPools: smcLiquidityPools ?? this.smcLiquidityPools,
      smcFibLevel: smcFibLevel ?? this.smcFibLevel,
      smcFibPrice: smcFibPrice ?? this.smcFibPrice,
      notesSmc: notesSmc ?? this.notesSmc,
      extraFields: extraFields ?? this.extraFields,
    );
  }

  /// Remplace le niveau Fib (y compris `null` pour désélectionner une puce).
  AnalyseSmcSnapshot withFibLevel(String? level) {
    return AnalyseSmcSnapshot(
      smcTf: smcTf,
      smcZone: smcZone,
      smcFvg: smcFvg,
      smcLiquidityPools: smcLiquidityPools,
      smcFibLevel: level,
      smcFibPrice: smcFibPrice,
      notesSmc: notesSmc,
      extraFields: extraFields,
    );
  }
}

/// Timeframe (Structure & chartisme) — ordre d’affichage : M1 … **Monthly** en dernier.
enum AnalyseStructureChartTf {
  m1,
  m5,
  m15,
  m30,
  h1,
  twoHour,
  h4,
  daily,
  weekly,
  monthly,
}

extension AnalyseStructureChartTfX on AnalyseStructureChartTf {
  String get label => switch (this) {
        AnalyseStructureChartTf.m1 => 'M1',
        AnalyseStructureChartTf.m5 => 'M5',
        AnalyseStructureChartTf.m15 => 'M15',
        AnalyseStructureChartTf.m30 => 'M30',
        AnalyseStructureChartTf.h1 => 'H1',
        AnalyseStructureChartTf.twoHour => '2H',
        AnalyseStructureChartTf.h4 => 'H4',
        AnalyseStructureChartTf.daily => 'Daily',
        AnalyseStructureChartTf.weekly => 'Weekly',
        AnalyseStructureChartTf.monthly => 'Monthly',
      };
}

class AnalyseChipOption<T> {
  const AnalyseChipOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

