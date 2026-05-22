import 'dart:convert';

import 'package:flutter/material.dart';

import 'analyse_report_snapshot.dart';

const _jsonV = 1;

int _argb(Color c) {
  final a = (c.a * 255.0).round() & 0xFF;
  final r = (c.r * 255.0).round() & 0xFF;
  final g = (c.g * 255.0).round() & 0xFF;
  final b = (c.b * 255.0).round() & 0xFF;
  return (a << 24) | (r << 16) | (g << 8) | b;
}

Color _color(Object? v) {
  if (v is int) return Color(v);
  if (v is num) return Color(v.toInt());
  return const Color(0xFF777777);
}

Map<String, dynamic> encodeAnalyseReportSnapshot(AnalyseReportSnapshot s) {
  return <String, dynamic>{
    'v': _jsonV,
    'actif': s.actif,
    'sousTitre': s.sousTitre,
    'biasLabel': s.biasLabel,
    'biasBg': _argb(s.biasBg),
    'biasFg': _argb(s.biasFg),
    'globalConfidencePercent': s.globalConfidencePercent,
    'globalConfidenceColor': _argb(s.globalConfidenceColor),
    'confluenceScore': s.confluenceScore,
    'smcObExtras': s.smcObExtras,
    'smcFvgExtras': s.smcFvgExtras,
    'smcLiquidityExtras': s.smcLiquidityExtras,
    'contexteTfLine': s.contexteTfLine,
    'phaseLabel': s.phaseLabel,
    'phaseBg': _argb(s.phaseBg),
    'phaseFg': _argb(s.phaseFg),
    'trendLabel': s.trendLabel,
    'trendBg': _argb(s.trendBg),
    'trendFg': _argb(s.trendFg),
    'contexteDateLabel': s.contexteDateLabel,
    'structureTf': s.structureTf,
    'chartisme': s.chartisme,
    'support': s.support,
    'resistance': s.resistance,
    'structureSupportTested': s.structureSupportTested,
    'structureResistanceTested': s.structureResistanceTested,
    'structureExtraSupports': [
      for (final e in s.structureExtraSupports ?? const [])
        <String, dynamic>{
          'priceLabel': e.priceLabel,
          'tenueLabel': e.tenueLabel,
        },
    ],
    'structureExtraResistances': [
      for (final e in s.structureExtraResistances ?? const [])
        <String, dynamic>{
          'priceLabel': e.priceLabel,
          'tenueLabel': e.tenueLabel,
        },
    ],
    'noteContexte': s.noteContexte,
    'noteStructure': s.noteStructure,
    'indicatorsTf': s.indicatorsTf,
    'indicateursOutils': s.indicateursOutils,
    'noteIndicators': s.noteIndicators,
    'smcOb': s.smcOb,
    'smcFvg': s.smcFvg,
    'smcLiq': s.smcLiq,
    'smcFibPrice': s.smcFibPrice,
    'smcFibOteLabel': s.smcFibOteLabel,
    'noteSmc': s.noteSmc,
    'poc': s.poc,
    'vah': s.vah,
    'val': s.val,
    'noteVolume': s.noteVolume,
    'volumeProfileTf': s.volumeProfileTf,
    'volumeProfileZoneActive': s.volumeProfileZoneActive,
    'volumeProfileZoneFrom': s.volumeProfileZoneFrom,
    'volumeProfileZoneTo': s.volumeProfileZoneTo,
    'gaugeFeuille': s.gaugeFeuille,
    'gaugeStructure': s.gaugeStructure,
    'gaugeIndicators': s.gaugeIndicators,
    'gaugeSmc': s.gaugeSmc,
    'gaugeImpactFeuille': s.gaugeImpactFeuille,
    'gaugeImpactStructure': s.gaugeImpactStructure,
    'gaugeImpactIndicators': s.gaugeImpactIndicators,
    'gaugeImpactSmc': s.gaugeImpactSmc,
    'gaugeContextEnabled': s.gaugeContextEnabled,
    'gaugeStructureEnabled': s.gaugeStructureEnabled,
    'gaugeIndicatorsEnabled': s.gaugeIndicatorsEnabled,
    'gaugeSmcEnabled': s.gaugeSmcEnabled,
    'gaugeVolumeProfileEnabled': s.gaugeVolumeProfileEnabled,
    'contexteCopies': [
      for (final c in s.contexteCopies ?? const [])
        <String, dynamic>{
          'biasLabel': c.biasLabel,
          'biasBg': _argb(c.biasBg),
          'biasFg': _argb(c.biasFg),
          'contexteTfLine': c.contexteTfLine,
          'trendLabel': c.trendLabel,
          'trendBg': _argb(c.trendBg),
          'trendFg': _argb(c.trendFg),
          'phaseLabel': c.phaseLabel,
          'phaseBg': _argb(c.phaseBg),
          'phaseFg': _argb(c.phaseFg),
        },
    ],
    'structureCopies': [
      for (final c in s.structureCopies ?? const [])
        <String, dynamic>{
          'structureTf': c.structureTf,
          'chartisme': c.chartisme,
          'support': c.support,
          'resistance': c.resistance,
          'structureSupportTested': c.structureSupportTested,
          'structureResistanceTested': c.structureResistanceTested,
          'structureExtraSupports': [
            for (final e in c.structureExtraSupports)
              <String, dynamic>{
                'priceLabel': e.priceLabel,
                'tenueLabel': e.tenueLabel,
              },
          ],
          'structureExtraResistances': [
            for (final e in c.structureExtraResistances)
              <String, dynamic>{
                'priceLabel': e.priceLabel,
                'tenueLabel': e.tenueLabel,
              },
          ],
        },
    ],
    'indicatorsCopies': [
      for (final c in s.indicatorsCopies ?? const [])
        <String, dynamic>{
          'indicatorsTf': c.indicatorsTf,
          'indicateursOutils': c.indicateursOutils,
          'noteIndicators': c.noteIndicators,
        },
    ],
    'smcCopies': [
      for (final c in s.smcCopies ?? const [])
        <String, dynamic>{
          'smcOb': c.smcOb,
          'smcFvg': c.smcFvg,
          'smcLiq': c.smcLiq,
          'smcFibPrice': c.smcFibPrice,
          'smcFibOteLabel': c.smcFibOteLabel,
          'noteSmc': c.noteSmc,
        },
    ],
  };
}

AnalyseReportStructureExtraLine _extraLine(Map<String, dynamic> m) {
  return AnalyseReportStructureExtraLine(
    priceLabel: m['priceLabel'] as String? ?? '',
    tenueLabel: null,
  );
}

AnalyseReportContexteCopy _ctxCopy(Map<String, dynamic> m) {
  return AnalyseReportContexteCopy(
    biasLabel: m['biasLabel'] as String? ?? '',
    biasBg: _color(m['biasBg']),
    biasFg: _color(m['biasFg']),
    contexteTfLine: m['contexteTfLine'] as String? ?? '',
    trendLabel: m['trendLabel'] as String? ?? '',
    trendBg: _color(m['trendBg']),
    trendFg: _color(m['trendFg']),
    phaseLabel: m['phaseLabel'] as String? ?? '',
    phaseBg: _color(m['phaseBg']),
    phaseFg: _color(m['phaseFg']),
  );
}

AnalyseReportStructureCopy _structCopy(Map<String, dynamic> m) {
  return AnalyseReportStructureCopy(
    structureTf: m['structureTf'] as String? ?? '',
    chartisme: m['chartisme'] as String? ?? '',
    support: m['support'] as String? ?? '',
    resistance: m['resistance'] as String? ?? '',
    structureSupportTested: m['structureSupportTested'] as bool? ?? false,
    structureResistanceTested: m['structureResistanceTested'] as bool? ?? false,
    structureExtraSupports: [
      for (final e in (m['structureExtraSupports'] as List<dynamic>? ?? const []))
        _extraLine(Map<String, dynamic>.from(e as Map)),
    ],
    structureExtraResistances: [
      for (final e in (m['structureExtraResistances'] as List<dynamic>? ?? const []))
        _extraLine(Map<String, dynamic>.from(e as Map)),
    ],
  );
}

AnalyseReportIndicatorsCopy _indCopy(Map<String, dynamic> m) {
  return AnalyseReportIndicatorsCopy(
    indicatorsTf: m['indicatorsTf'] as String? ?? '',
    indicateursOutils: m['indicateursOutils'] as String? ?? '',
    noteIndicators: m['noteIndicators'] as String? ?? '',
  );
}

AnalyseReportSmcCopy _smcCopy(Map<String, dynamic> m) {
  return AnalyseReportSmcCopy(
    smcOb: m['smcOb'] as String? ?? '',
    smcFvg: m['smcFvg'] as String? ?? '',
    smcLiq: m['smcLiq'] as String? ?? '',
    smcFibPrice: m['smcFibPrice'] as String? ?? '',
    smcFibOteLabel: m['smcFibOteLabel'] as String? ?? '',
    noteSmc: m['noteSmc'] as String? ?? '',
  );
}

List<AnalyseReportStructureExtraLine>? _extrasList(List<dynamic>? raw) {
  if (raw == null || raw.isEmpty) return null;
  return [
    for (final e in raw) _extraLine(Map<String, dynamic>.from(e as Map)),
  ];
}

AnalyseReportSnapshot decodeAnalyseReportSnapshot(Map<String, dynamic> m) {
  List<T>? listCopy<T>(String key, T Function(Map<String, dynamic>) f) {
    final raw = m[key] as List<dynamic>?;
    if (raw == null || raw.isEmpty) return null;
    return [for (final e in raw) f(Map<String, dynamic>.from(e as Map))];
  }

  return AnalyseReportSnapshot(
    actif: m['actif'] as String? ?? '',
    sousTitre: m['sousTitre'] as String? ?? '',
    biasLabel: m['biasLabel'] as String? ?? '',
    biasBg: _color(m['biasBg']),
    biasFg: _color(m['biasFg']),
    globalConfidencePercent: (m['globalConfidencePercent'] as num?)?.round() ?? 0,
    globalConfidenceColor: _color(m['globalConfidenceColor']),
    confluenceScore: (m['confluenceScore'] as num?)?.round() ??
        (m['globalConfidencePercent'] as num?)?.round() ??
        0,
    smcObExtras: [
      for (final e in (m['smcObExtras'] as List<dynamic>? ?? const []))
        e.toString(),
    ],
    smcFvgExtras: [
      for (final e in (m['smcFvgExtras'] as List<dynamic>? ?? const []))
        e.toString(),
    ],
    smcLiquidityExtras: [
      for (final e in (m['smcLiquidityExtras'] as List<dynamic>? ?? const []))
        e.toString(),
    ],
    contexteTfLine: m['contexteTfLine'] as String? ?? '',
    phaseLabel: m['phaseLabel'] as String? ?? '',
    phaseBg: _color(m['phaseBg']),
    phaseFg: _color(m['phaseFg']),
    trendLabel: m['trendLabel'] as String? ?? '',
    trendBg: _color(m['trendBg']),
    trendFg: _color(m['trendFg']),
    contexteDateLabel: m['contexteDateLabel'] as String?,
    structureTf: m['structureTf'] as String? ?? '',
    chartisme: m['chartisme'] as String? ?? '',
    support: m['support'] as String? ?? '',
    resistance: m['resistance'] as String? ?? '',
    structureSupportTested: m['structureSupportTested'] as bool?,
    structureResistanceTested: m['structureResistanceTested'] as bool?,
    structureExtraSupports: _extrasList(m['structureExtraSupports'] as List<dynamic>?),
    structureExtraResistances:
        _extrasList(m['structureExtraResistances'] as List<dynamic>?),
    noteContexte: m['noteContexte'] as String?,
    noteStructure: m['noteStructure'] as String?,
    indicatorsTf: m['indicatorsTf'] as String? ?? '',
    indicateursOutils: m['indicateursOutils'] as String? ?? '',
    noteIndicators: m['noteIndicators'] as String? ?? '',
    smcOb: m['smcOb'] as String? ?? '',
    smcFvg: m['smcFvg'] as String? ?? '',
    smcLiq: m['smcLiq'] as String? ?? '',
    smcFibPrice: m['smcFibPrice'] as String? ?? '',
    smcFibOteLabel: m['smcFibOteLabel'] as String? ?? '',
    noteSmc: m['noteSmc'] as String? ?? '',
    poc: m['poc'] as String? ?? '',
    vah: m['vah'] as String? ?? '',
    val: m['val'] as String? ?? '',
    noteVolume: m['noteVolume'] as String? ?? '',
    volumeProfileTf: m['volumeProfileTf'] as String?,
    volumeProfileZoneActive: m['volumeProfileZoneActive'] as bool?,
    volumeProfileZoneFrom: m['volumeProfileZoneFrom'] as String?,
    volumeProfileZoneTo: m['volumeProfileZoneTo'] as String?,
    gaugeFeuille: (m['gaugeFeuille'] as num?)?.round() ?? 45,
    gaugeStructure: (m['gaugeStructure'] as num?)?.round() ?? 45,
    gaugeIndicators: (m['gaugeIndicators'] as num?)?.round() ?? 45,
    gaugeSmc: (m['gaugeSmc'] as num?)?.round() ?? 45,
    gaugeImpactFeuille: (m['gaugeImpactFeuille'] as num?)?.round() ?? 25,
    gaugeImpactStructure: (m['gaugeImpactStructure'] as num?)?.round() ?? 25,
    gaugeImpactIndicators: (m['gaugeImpactIndicators'] as num?)?.round() ?? 25,
    gaugeImpactSmc: (m['gaugeImpactSmc'] as num?)?.round() ?? 25,
    gaugeContextEnabled: m['gaugeContextEnabled'] as bool? ?? true,
    gaugeStructureEnabled: m['gaugeStructureEnabled'] as bool? ?? true,
    gaugeIndicatorsEnabled: m['gaugeIndicatorsEnabled'] as bool? ?? true,
    gaugeSmcEnabled: m['gaugeSmcEnabled'] as bool? ?? true,
    gaugeVolumeProfileEnabled: m['gaugeVolumeProfileEnabled'] as bool? ?? true,
    contexteCopies: listCopy('contexteCopies', _ctxCopy),
    structureCopies: listCopy('structureCopies', _structCopy),
    indicatorsCopies: listCopy('indicatorsCopies', _indCopy),
    smcCopies: listCopy('smcCopies', _smcCopy),
  );
}

bool analyseSnapshotsEqualForStar(AnalyseReportSnapshot a, AnalyseReportSnapshot b) {
  return jsonEncode(encodeAnalyseReportSnapshot(a)) ==
      jsonEncode(encodeAnalyseReportSnapshot(b));
}
