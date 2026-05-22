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

  String get globalConfidenceLabel => l.analyseSidebarConfidenceLabel;

  String get confluenceRingLabel => _p(
        'CONFLUENCE',
        'CONFLUENCE',
        'CONFLUENCIA',
        'KONFLUENZ',
        'CONFLUÊNCIA',
        '컨플루언스',
      );

  String confluenceStatusLabel(int score) {
    if (score > 70) {
      return _p('Setup Optimal', 'Setup Optimal', 'Setup óptimo', 'Setup optimal', 'Setup ótimo', '최적 셋업');
    }
    if (score > 40) {
      return _p('Setup Valide', 'Valid Setup', 'Setup válido', 'Gültiges Setup', 'Setup válido', '유효 셋업');
    }
    return _p('Risque Élevé', 'High Risk', 'Riesgo alto', 'Hohes Risiko', 'Risco elevado', '고위험');
  }

  String get sectionFundamental => _p(
        'FONDAMENTAL',
        'FUNDAMENTAL',
        'FUNDAMENTAL',
        'FUNDAMENTAL',
        'FUNDAMENTAL',
        '기본',
      );

  String get sectionZoneCle => _p(
        'ZONE CLÉ',
        'KEY ZONE',
        'ZONA CLAVE',
        'SCHLÜSSELZONE',
        'ZONA-CHAVE',
        '핵심 구간',
      );

  String get sectionEntry => _p(
        'ENTRÉE',
        'ENTRY',
        'ENTRADA',
        'EINSTIEG',
        'ENTRADA',
        '진입',
      );

  String get sectionSmc => 'SMC';

  String get sectionVolume => _p(
        'VOLUME PROFILE',
        'VOLUME PROFILE',
        'PERFIL DE VOLUMEN',
        'VOLUMENPROFIL',
        'PERFIL DE VOLUME',
        '볼륨 프로필',
      );

  String get signauxLabel => _p(
        'SIGNAUX',
        'SIGNALS',
        'SEÑALES',
        'SIGNALE',
        'SINAIS',
        '신호',
      );

  String get actionPlanLabel => _p(
        "PLAN D'ACTION",
        'ACTION PLAN',
        'PLAN DE ACCIÓN',
        'AKTIONSPLAN',
        'PLANO DE AÇÃO',
        '실행 계획',
      );

  String get notesMacroLabel => _p(
        'NOTES MACRO',
        'MACRO NOTES',
        'NOTAS MACRO',
        'MAKRO-NOTIZEN',
        'NOTAS MACRO',
        '매크로 메모',
      );

  String confidencePanelTitle(int impact) => _p(
        'CONFIANCE PAR SECTION',
        'CONFIDENCE BY SECTION',
        'CONFIANZA POR SECCIÓN',
        'VERTRAUEN PRO ABSCHNITT',
        'CONFIANÇA POR SECÇÃO',
        '섹션별 신뢰도',
      );

  String get brandFooter => 'PAYCHEK · MON ANALYSE';

  String get generatedBy => _p(
        'Rapport OLED',
        'OLED report',
        'Informe OLED',
        'OLED-Bericht',
        'Relatório OLED',
        'OLED 보고서',
      );

  String get sectionDisabled => _p(
        'Section désactivée.',
        'Section disabled.',
        'Sección desactivada.',
        'Abschnitt deaktiviert.',
        'Secção desativada.',
        '비활성화된 섹션.',
      );

  String get fibPriceLabel => _p(
        'Prix Fib',
        'Fib price',
        'Precio Fib',
        'Fib-Preis',
        'Preço Fib',
        '피보나치 가격',
      );

  String get feuilleGaugeRow => l.analyseFeuillePlanTitle;

  String get structureGaugeRow => l.analyseStructureSectionTitle;

  String get entryGaugeRow => _p(
        'Entrée',
        'Entry',
        'Entrada',
        'Einstieg',
        'Entrada',
        '진입',
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
