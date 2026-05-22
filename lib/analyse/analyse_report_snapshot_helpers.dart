part of 'analyse_report_snapshot.dart';

String _reportIndicateursOutilsLine(List<String> selected) {
  if (selected.isEmpty) return '—';
  return selected.join(' + ');
}

AnalyseReportStructureCopy _reportStructureCopyFromSnapshot(
  AnalyseStructureSnapshot s,
  Locale locale,
) {
  return AnalyseReportStructureCopy(
    structureTf: _orDash(s.structureTf),
    chartisme: _orDash(s.dernierPoint),
    support: _orDash(s.structureSupportMaj),
    resistance: _orDash(s.structureResistanceMaj),
    structureSupportTested: s.structureSupportTested,
    structureResistanceTested: s.structureResistanceTested,
    structureExtraSupports: _reportStructureExtraLines(s.extraSupports),
    structureExtraResistances: _reportStructureExtraLines(s.extraResistances),
  );
}

AnalyseReportContexteCopy _buildReportContexteCopy(
  AnalyseContexteTendanceSnapshot s,
  Locale locale,
) {
  final (biasBg, biasFg) = _biasColors(s.bias);
  final trendStr = _snapshotTrendPickLabel(s, locale);
  final (trBg, trFg) = _snapshotTrendPillColors(s);
  final phaseStr = _snapshotPhasePickLabel(s, locale);
  final (phBg, phFg) = _phasePillColors();
  return AnalyseReportContexteCopy(
    biasLabel: _biasLabel(s.bias, locale),
    biasBg: biasBg,
    biasFg: biasFg,
    contexteTfLine: _orDash(_snapshotHtfPickLine(s)),
    trendLabel: trendStr.toUpperCase(),
    trendBg: trBg,
    trendFg: trFg,
    phaseLabel: phaseStr.toUpperCase(),
    phaseBg: phBg,
    phaseFg: phFg,
  );
}

String _snapshotHtfPickLine(AnalyseContexteTendanceSnapshot s) {
  final p = s.htfPick;
  if (p.isEnum) return ctxLabelHtf(p.enumVal!);
  return p.custom?.trim().isNotEmpty == true ? p.custom!.trim() : '—';
}

String _snapshotPhasePickLabel(AnalyseContexteTendanceSnapshot s, Locale locale) {
  final p = s.phasePick;
  if (p.isEnum) return analysePhaseLabelForLocale(p.enumVal!, locale);
  return p.custom?.trim().isNotEmpty == true ? p.custom!.trim() : '—';
}

String _snapshotTrendPickLabel(AnalyseContexteTendanceSnapshot s, Locale locale) {
  final p = s.trendPick;
  if (p.isEnum) return _trendEnumLabel(p.enumVal!, locale);
  return p.custom?.trim().isNotEmpty == true ? p.custom!.trim() : '—';
}

(Color, Color) _snapshotTrendPillColors(AnalyseContexteTendanceSnapshot s) {
  final p = s.trendPick;
  if (p.isEnum) {
    return switch (p.enumVal!) {
      AnalyseLocalTrend.haussiere => (
          const Color(0xFF0F2418),
          AnalyseTokens.accentGreen,
        ),
      AnalyseLocalTrend.baissiere => (
          const Color(0xFF2A1010),
          AnalyseTokens.accentRed,
        ),
      AnalyseLocalTrend.range => (
          const Color(0xFF2A2210),
          AnalyseTokens.accentAmber,
        ),
    };
  }
  return (
    const Color(0xFF1A1A1A),
    AnalyseTokens.matteText,
  );
}

String _smcObLine(AnalyseController c) {
  final z = c.smcZone.trim();
  if (z.isNotEmpty) return z;
  return c.smcTf.trim();
}

String _smcObLineFromSnapshot(AnalyseSmcSnapshot s) {
  final z = s.smcZone.trim();
  if (z.isNotEmpty) return z;
  return s.smcTf.trim();
}

String _smcFibOteLabelFromSnapshot(AnalyseSmcSnapshot s) {
  final fibLevel = s.smcFibLevel?.trim();
  if (fibLevel != null && fibLevel.isNotEmpty) {
    return '$fibLevel OTE';
  }
  return '';
}

String _orDash(String s) {
  final t = s.trim();
  return t.isEmpty ? '—' : t;
}

String? _structureExtraTenueLabel(AnalyseStructureTenue? tenue) {
  if (tenue == null) return null;
  return switch (tenue) {
    AnalyseStructureTenue.tenu => 'Tenu',
    AnalyseStructureTenue.casse => 'Cassé',
  };
}

List<AnalyseReportStructureExtraLine> _reportStructureExtraLines(
  List<AnalyseStructureExtraLevel> levels,
) {
  return [
    for (final e in levels)
      if (e.price.trim().isNotEmpty)
        AnalyseReportStructureExtraLine(
          priceLabel: _orDash(e.price),
          tenueLabel: _structureExtraTenueLabel(e.tenue),
        ),
  ];
}

String _biasLabel(AnalyseDirectionBias b, Locale locale) => switch (b) {
      AnalyseDirectionBias.achat =>
        _txt(locale, 'ACHAT', 'BUY', 'COMPRA', 'KAUF', 'COMPRA', '매수'),
      AnalyseDirectionBias.vente =>
        _txt(locale, 'VENTE', 'SELL', 'VENTA', 'VERKAUF', 'VENDA', '매도'),
      AnalyseDirectionBias.surveiller =>
        _txt(
          locale,
          'À SURVEILLER',
          'WATCH',
          'VIGILAR',
          'BEOBACHTEN',
          'OBSERVAR',
          '관망',
        ),
    };

(Color, Color) _biasColors(AnalyseDirectionBias b) => switch (b) {
      AnalyseDirectionBias.achat => (
          const Color(0xFF0F2418),
          AnalyseTokens.accentGreen,
        ),
      AnalyseDirectionBias.vente => (
          const Color(0xFF2A1010),
          AnalyseTokens.accentRed,
        ),
      AnalyseDirectionBias.surveiller => (
          const Color(0xFF2A2210),
          AnalyseTokens.accentAmber,
        ),
    };

/// Timeframe **sélectionné** (puce Tendance / HTF), pas la liste des pilules visibles.
String _htfPickLabel(AnalyseController c) {
  final p = c.htfPick;
  if (p.isEnum) return ctxLabelHtf(p.enumVal!);
  return p.custom?.trim().isNotEmpty == true ? p.custom!.trim() : '—';
}

String _phasePickLabel(AnalyseController c, Locale locale) {
  final p = c.phasePick;
  if (p.isEnum) return analysePhaseLabelForLocale(p.enumVal!, locale);
  return p.custom?.trim().isNotEmpty == true ? p.custom!.trim() : '—';
}

String _trendPickLabel(AnalyseController c, Locale locale) {
  final p = c.localTrendPick;
  if (p.isEnum) return _trendEnumLabel(p.enumVal!, locale);
  return p.custom?.trim().isNotEmpty == true ? p.custom!.trim() : '—';
}

String _trendEnumLabel(AnalyseLocalTrend t, Locale locale) => switch (t) {
      AnalyseLocalTrend.haussiere =>
        _txt(locale, 'Haussière', 'Bullish', 'Alcista', 'Bullisch', 'Alta', '상승'),
      AnalyseLocalTrend.baissiere =>
        _txt(locale, 'Baissière', 'Bearish', 'Bajista', 'Bärisch', 'Baixa', '하락'),
      AnalyseLocalTrend.range =>
        _txt(locale, 'Range', 'Ranging', 'Rango', 'Seitwärts', 'Lateral', '횡보'),
    };

String _txt(
  Locale locale,
  String fr,
  String en,
  String es,
  String de,
  String pt, [
  String? ko,
]) =>
    performancePickLocale(locale, fr, en, es, de, pt, ko);

/// Aligné sur les puces « Phase actuelle » ([AnalyseTokens.chipPhaseSelected]).
(Color, Color) _phasePillColors() => (
      AnalyseTokens.chipPhaseSelected.withValues(alpha: 0.14),
      AnalyseTokens.chipPhaseSelected,
    );

(Color, Color) _trendPillColors(AnalyseController c) {
  final p = c.localTrendPick;
  if (p.isEnum) {
    return switch (p.enumVal!) {
      AnalyseLocalTrend.haussiere => (
          const Color(0xFF0F2418),
          AnalyseTokens.accentGreen,
        ),
      AnalyseLocalTrend.baissiere => (
          const Color(0xFF2A1010),
          AnalyseTokens.accentRed,
        ),
      AnalyseLocalTrend.range => (
          const Color(0xFF2A2210),
          AnalyseTokens.accentAmber,
        ),
    };
  }
  return (
    const Color(0xFF1A1A1A),
    AnalyseTokens.matteText,
  );
}
