import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../performance/performance_locale_copy.dart';

/// Libellés statiques du PDF rapport Analyse (6 langues + clés ARB).
class AnalyseReportPdfCopy {
  AnalyseReportPdfCopy(this.locale, this.l);

  final Locale locale;
  final AppLocalizations l;

  bool get koPrimary => locale.languageCode == 'ko';

  String _p(
    String fr,
    String en,
    String es,
    String de,
    String pt,
    String ko,
  ) =>
      performancePickLocale(locale, fr, en, es, de, pt, ko);

  String get directionPrefix => l.analyseDirectionLabel;

  String get confidenceDonutLabel => l.analyseConfidenceLevelTitle;

  String get executiveSummaryTitle => _p(
        'RÉSUMÉ EXÉCUTIF',
        'EXECUTIVE SUMMARY',
        'RESUMEN EJECUTIVO',
        'EXECUTIVE SUMMARY',
        'RESUMO EXECUTIVO',
        '요약',
      );

  String get feuilleTendanceSection => _p(
        'FEUILLE & TENDANCE',
        'SHEET & TREND',
        'HOJA Y TENDENCIA',
        'BLATT & TREND',
        'FOLHA E TENDÊNCIA',
        '시트 및 추세',
      );

  String structureTitle(String tf) =>
      '${l.analyseStructure} ${tf.trim().toUpperCase()}';

  String get sectionDisabled => _p(
        'Section désactivée.',
        'Section disabled.',
        'Sección desactivada.',
        'Abschnitt deaktiviert.',
        'Secção desativada.',
        '비활성화된 섹션.',
      );

  String get signalLastPoint => _p(
        'Signal / dernier point',
        'Signal / last point',
        'Señal / último punto',
        'Signal / letzter Punkt',
        'Sinal / último ponto',
        '신호 / 최근 포인트',
      );

  String get toolsSmcTitle => _p(
        'OUTILS TECHNIQUE & SMC',
        'TECHNICAL TOOLS & SMC',
        'HERRAMIENTAS TÉCNICAS Y SMC',
        'TECHNIK & SMC',
        'FERRAMENTAS TÉCNICAS E SMC',
        '기술 도구 및 SMC',
      );

  String indicatorsTitle(String tf) => _p(
        'Indicateurs $tf',
        'Indicators $tf',
        'Indicadores $tf',
        'Indikatoren $tf',
        'Indicadores $tf',
        '지표 $tf',
      );

  String get smcFluxTitle => _p(
        'Analyse SMC / Flux',
        'SMC / Flow analysis',
        'Análisis SMC / flujo',
        'SMC / Flow-Analyse',
        'Análise SMC / fluxo',
        'SMC / 흐름 분석',
      );

  String get fibPriceLabel => _p(
        'Prix Fib',
        'Fib price',
        'Precio Fib',
        'Fib-Preis',
        'Preço Fib',
        '피보나치 가격',
      );

  String confidenceBySection(int impact) => _p(
        'CONFIANCE PAR SECTION (IMPACT $impact% CHACUNE)',
        'CONFIDENCE BY SECTION ($impact% IMPACT EACH)',
        'CONFIANZA POR SECCIÓN ($impact% IMPACTO C/U)',
        'VERTRAUEN PRO ABSCHNITT ($impact% JE ABSCHNITT)',
        'CONFIANÇA POR SECÇÃO ($impact% CADA)',
        '섹션별 신뢰도 (각 $impact% 영향)',
      );

  String get feuilleGaugeRow => l.analyseFeuillePlanTitle;

  String get structureGaugeRow => l.analyseStructureSectionTitle;

  String get indicatorsGaugeRow => _p(
        'Indicateurs',
        'Indicators',
        'Indicadores',
        'Indikatoren',
        'Indicadores',
        '지표',
      );

  String get smcGaugeRow => _p(
        'SMC',
        'SMC',
        'SMC',
        'SMC',
        'SMC',
        'SMC',
      );

  String get captureSection => l.analyseReportScreenshotSectionTitle;

  String analysisDateLabel(String date) => _p(
        'Date de l\'analyse : $date',
        'Analysis date: $date',
        'Fecha del análisis: $date',
        'Analysedatum: $date',
        'Data da análise: $date',
        '분석일: $date',
      );

  String executiveFallback(int confidence) => _p(
        'Rapport Mon Analyse — confiance globale $confidence %.',
        'My Analysis report — overall confidence $confidence %.',
        'Informe Mi Análisis — confianza global $confidence %.',
        'Meine Analyse — Gesamtvertrauen $confidence %.',
        'Relatório Minha Análise — confiança global $confidence %.',
        '내 분석 보고서 — 전체 신뢰도 $confidence %.',
      );

  String executiveContextLine(String tf, String trend, String phase) => _p(
        'Analyse $tf : tendance $trend, phase $phase.',
        'Analysis $tf: $trend trend, $phase phase.',
        'Análisis $tf: tendencia $trend, fase $phase.',
        'Analyse $tf: Trend $trend, Phase $phase.',
        'Análise $tf: tendência $trend, fase $phase.',
        '분석 $tf: 추세 $trend, 단계 $phase.',
      );

  String executiveStructureLine(
    String tf,
    String chart,
    String support,
    String resist,
  ) =>
      _p(
        'Structure $tf — $chart. Supports / résistances : $support / $resist.',
        'Structure $tf — $chart. Support / resistance: $support / $resist.',
        'Estructura $tf — $chart. Soporte / resistencia: $support / $resist.',
        'Struktur $tf — $chart. Support / Widerstand: $support / $resist.',
        'Estrutura $tf — $chart. Suporte / resistência: $support / $resist.',
        '구조 $tf — $chart. 지지 / 저항: $support / $resist.',
      );

  String footerNoteLowBoth() => _p(
        'Note : la confiance structurelle et SMC reste modérée en attente d\'un retest confirmé du scénario.',
        'Note: structure and SMC confidence remain moderate pending a confirmed scenario retest.',
        'Nota: la confianza estructural y SMC sigue moderada a la espera de un retest confirmado.',
        'Hinweis: Struktur- und SMC-Vertrauen bleiben moderat bis ein bestätigter Retest.',
        'Nota: confiança estrutural e SMC permanecem moderadas até reteste confirmado.',
        '참고: 구조 및 SMC 신뢰도는 시나리오 재테스트 확인 전까지 보통 수준입니다.',
      );

  String footerNoteLowOne() => _p(
        'Note : une ou plusieurs sections affichent une confiance modérée — croiser avec le prix avant engagement.',
        'Note: one or more sections show moderate confidence — cross-check price before committing.',
        'Nota: una o más secciones muestran confianza moderada — contrastar con el precio.',
        'Hinweis: eine oder mehrere Sektionen mit moderatem Vertrauen — Preis prüfen.',
        'Nota: uma ou mais secções com confiança moderada — cruzar com o preço.',
        '참고: 일부 섹션의 신뢰도가 보통입니다 — 진입 전 가격을 확인하세요.',
      );

  String footerNoteDefault(int impact) => _p(
        'Note : confiance par section avec impact pondéré ($impact % / section active typique).',
        'Note: per-section confidence with weighted impact ($impact % / typical active section).',
        'Nota: confianza por sección con impacto ponderado ($impact % / sección activa).',
        'Hinweis: Vertrauen pro Abschnitt mit gewichtetem Impact ($impact %).',
        'Nota: confiança por secção com impacto ponderado ($impact %).',
        '참고: 섹션별 신뢰도 (가중 영향 $impact %).',
      );

  String testedSuffix() => ' (${l.analyseTestedTwice})';

  String annexeContexte() => _p(
        'Annexe — copies Feuille & tendance',
        'Appendix — Sheet & trend copies',
        'Anexo — copias Hoja y tendencia',
        'Anhang — Blatt- & Trend-Kopien',
        'Anexo — cópias Folha e tendência',
        '부록 — 시트 및 추세 복사',
      );

  String annexeStructure() => _p(
        'Annexe — copies Structure',
        'Appendix — Structure copies',
        'Anexo — copias Estructura',
        'Anhang — Struktur-Kopien',
        'Anexo — cópias Estrutura',
        '부록 — 구조 복사',
      );

  String annexeIndicators() => _p(
        'Annexe — copies Indicateurs',
        'Appendix — Indicator copies',
        'Anexo — copias Indicadores',
        'Anhang — Indikator-Kopien',
        'Anexo — cópias Indicadores',
        '부록 — 지표 복사',
      );

  String annexeSmc() => _p(
        'Annexe — copies SMC',
        'Appendix — SMC copies',
        'Anexo — copias SMC',
        'Anhang — SMC-Kopien',
        'Anexo — cópias SMC',
        '부록 — SMC 복사',
      );

  String get lastPointLabel => _p(
        'Dernier point',
        'Last point',
        'Último punto',
        'Letzter Punkt',
        'Último ponto',
        '최근 포인트',
      );

  String get toolsLabel => _p(
        'Outils',
        'Tools',
        'Herramientas',
        'Werkzeuge',
        'Ferramentas',
        '도구',
      );
}
