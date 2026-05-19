import 'package:flutter/material.dart';

import '../performance/performance_locale_copy.dart';
import 'analyse_phase_locale.dart';

/// Réétiquette un biais figé (FR/EN/ES/DE/PT/KO…) selon la [locale] d’export.
String localizeStoredAnalyseBiasLabel(String stored, Locale locale) {
  final raw = stored.trim().toUpperCase();
  String p(String fr, String en, String es, String de, String pt, String ko) =>
      performancePickLocale(locale, fr, en, es, de, pt, ko);

  if (raw.isEmpty || raw == '—') return stored;

  if (raw == 'ACHAT' ||
      raw == 'BUY' ||
      raw == 'COMPRA' ||
      raw == 'KAUF' ||
      raw == '매수') {
    return p('ACHAT', 'BUY', 'COMPRA', 'KAUF', 'COMPRA', '매수');
  }
  if (raw == 'VENTE' ||
      raw == 'SELL' ||
      raw == 'VENTA' ||
      raw == 'VERKAUF' ||
      raw == 'VENDA' ||
      raw == '매도') {
    return p('VENTE', 'SELL', 'VENTA', 'VERKAUF', 'VENDA', '매도');
  }
  if (raw.contains('SURVEILL') ||
      raw == 'WATCH' ||
      raw == 'VIGILAR' ||
      raw == 'BEOBACHTEN' ||
      raw == 'OBSERVAR' ||
      raw.contains('관망')) {
    return p('À SURVEILLER', 'WATCH', 'VIGILAR', 'BEOBACHTEN', 'OBSERVAR', '관망');
  }
  return stored;
}

/// Réétiquette une tendance figée selon la [locale] d’export.
String localizeStoredAnalyseTrendLabel(String stored, Locale locale) {
  final raw = stored.trim().toLowerCase();
  if (raw.isEmpty || raw == '—') return stored;

  String p(String fr, String en, String es, String de, String pt, String ko) =>
      performancePickLocale(locale, fr, en, es, de, pt, ko);

  if (raw.contains('hauss') ||
      raw.contains('bullish') ||
      raw.contains('alcista') ||
      raw.contains('bullisch') ||
      raw.contains('alta') ||
      raw.contains('상승')) {
    return p('Haussière', 'Bullish', 'Alcista', 'Bullisch', 'Alta', '상승');
  }
  if (raw.contains('baiss') ||
      raw.contains('bearish') ||
      raw.contains('bajista') ||
      raw.contains('bärisch') ||
      raw.contains('baixa') ||
      raw.contains('하락')) {
    return p('Baissière', 'Bearish', 'Bajista', 'Bärisch', 'Baixa', '하락');
  }
  if (raw.contains('range') ||
      raw.contains('ranging') ||
      raw.contains('rango') ||
      raw.contains('seitw') ||
      raw.contains('lateral') ||
      raw.contains('횡보')) {
    return p('Range', 'Ranging', 'Rango', 'Seitwärts', 'Lateral', '횡보');
  }
  return stored;
}

/// Phase, tendance et biais d’un [AnalyseReportSnapshot] pour l’export PDF.
class AnalyseReportSnapshotLabels {
  const AnalyseReportSnapshotLabels(this.locale);

  final Locale locale;

  String bias(String stored) => localizeStoredAnalyseBiasLabel(stored, locale);

  String trend(String stored) => localizeStoredAnalyseTrendLabel(stored, locale);

  String phase(String stored) => localizeStoredAnalysePhase(stored, locale);
}
