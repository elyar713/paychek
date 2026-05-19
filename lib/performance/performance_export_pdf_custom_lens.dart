part of 'performance_export_pdf.dart';

String _customLensDimensionPdfLabel(
  Locale locale,
  PerformanceCustomLensDimension dimension,
) {
  return switch (dimension) {
    PerformanceCustomLensDimension.etat => _p(
        locale,
        'État mental',
        'Mental state',
        'Estado mental',
        'Mental',
        'Estado mental',
        '멘탈',
      ),
    PerformanceCustomLensDimension.checklist => _p(
        locale,
        'Checklist',
        'Checklist',
        'Checklist',
        'Checkliste',
        'Checklist',
        '체크리스트',
      ),
    PerformanceCustomLensDimension.plan => _p(
        locale,
        'Analyse',
        'Analysis',
        'Análisis',
        'Analyse',
        'Análise',
        '분석',
      ),
    PerformanceCustomLensDimension.strategie => _p(
        locale,
        'Stratégie',
        'Strategy',
        'Estrategia',
        'Strategie',
        'Estratégia',
        '전략',
      ),
  };
}

List<pw.Widget> _customLensPdfSection({
  required Locale locale,
  required AppLocalizations l,
  required List<Trade> trades,
  required List<PerformanceCustomLensSavedCard> savedCards,
  required List<ChecklistSectionData> checklistSections,
}) {
  final cards = savedCards
      .where((c) => c.config.elementId.isNotEmpty)
      .toList()
      .reversed
      .toList();
  if (cards.isEmpty) return const [];

  final planIndex = buildPerformanceCustomLensPlanIndex(
    trades: trades,
    l: l,
    locale: locale,
  );
  String? strategieTitleHint;
  for (final t in trades) {
    if ((t.strategieTitle ?? '').isNotEmpty) {
      strategieTitleHint = t.strategieTitle;
      break;
    }
  }

  String txt(String fr, String en, String es, String de, String pt, String ko) =>
      _p(locale, fr, en, es, de, pt, ko);

  final blocks = <pw.Widget>[
    pw.SizedBox(height: 10),
    _sectionTitle(
      _p(
        locale,
        'ANALYSE PERSONNALISÉE',
        'CUSTOM ANALYSIS',
        'ANÁLISIS PERSONALIZADO',
        'PERSONALISIERTE ANALYSE',
        'ANÁLISE PERSONALIZADA',
        '맞춤 분석',
      ),
    ),
    pw.SizedBox(height: 4),
    _pdfW(
      _p(
        locale,
        'Cartes enregistrées depuis Performance (filtre période actif).',
        'Cards saved from Performance (current period filter).',
        'Tarjetas guardadas en Rendimiento (filtro de período activo).',
        'Gespeicherte Karten aus Performance (aktueller Periodenfilter).',
        'Cartões guardados em Performance (filtro de período ativo).',
        '퍼포먼스에서 저장한 카드(현재 기간 필터).',
      ),
      fontSize: 8,
      color: _kMuted,
      height: 1.35,
    ),
  ];

  for (final saved in cards) {
    final config = saved.config;
    final elementLabel = performanceCustomLensElementLabel(
      dimension: config.dimension,
      elementId: config.elementId,
      l: l,
      locale: locale,
      strategieTitleHint: strategieTitleHint,
      planIndex: planIndex,
      checklistSections: checklistSections,
    );
    final bands = performanceCustomLensBandStats(
      trades: trades,
      config: config,
      txt: txt,
    );

    blocks.add(pw.SizedBox(height: 8));
    blocks.add(
      _card(
        bg: _kCardBg,
        children: [
          _pdfW(
            elementLabel,
            bold: true,
            fontSize: 11,
            color: _kPrimary,
          ),
          pw.SizedBox(height: 4),
          _pdfW(
            _customLensDimensionPdfLabel(locale, config.dimension),
            fontSize: 8,
            color: _kMuted,
          ),
          pw.SizedBox(height: 10),
          for (var i = 0; i < bands.length; i++) ...[
            if (i > 0) pw.SizedBox(height: 8),
            _discBar(
              locale,
              bands[i].label,
              bands[i].winRate,
              bands[i].tradeCount,
              bands[i].hasData && bands[i].winRate >= 0.5 ? _cGreen() : _cOrange(),
            ),
          ],
        ],
      ),
    );
  }

  return blocks;
}
