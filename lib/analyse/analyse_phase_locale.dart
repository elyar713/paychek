import 'package:flutter/material.dart';

import 'analyse_models.dart';

String _quin(
  Locale locale,
  String fr,
  String en,
  String es,
  String de,
  String pt,
  String ko,
) {
  final code = locale.languageCode.toLowerCase();
  if (code == 'fr') return fr;
  if (code == 'es') return es;
  if (code == 'de') return de;
  if (code == 'pt') return pt;
  if (code == 'ko') return ko;
  return en;
}

/// Libellé court de phase (contexte marché), aligné sur les puces Analyse.
String analysePhaseLabelForLocale(AnalysePhase p, Locale locale) => switch (p) {
      AnalysePhase.accumulation => _quin(
          locale,
          'Accumulation',
          'Accumulation',
          'Acumulación',
          'Akkumulation',
          'Acumulação',
          '축적',
        ),
      AnalysePhase.impulsion => _quin(
          locale,
          'Impulsion',
          'Impulse',
          'Impulso',
          'Impuls',
          'Impulso',
          '충격',
        ),
      AnalysePhase.distribution => _quin(
          locale,
          'Distribution',
          'Distribution',
          'Distribución',
          'Distribution',
          'Distribuição',
          '분산',
        ),
    };

/// Reconnaissance tolérante des libellés déjà figés (FR/EN/DE/ES, toute casse).
AnalysePhase? analysePhaseFromStoredLabel(String stored) {
  final u = stored.trim().toUpperCase();
  if (u.isEmpty || u == '—') return null;
  if (u.contains('IMPULS')) return AnalysePhase.impulsion;
  if (u.contains('DISTRIB')) return AnalysePhase.distribution;
  if (u.contains('ACCUM')) return AnalysePhase.accumulation;
  return null;
}

/// Réaffiche une phase stockée dans un snapshot avec la [locale] courante.
String localizeStoredAnalysePhase(String stored, Locale locale) {
  final e = analysePhaseFromStoredLabel(stored);
  if (e != null) return analysePhaseLabelForLocale(e, locale).toUpperCase();
  return stored;
}
