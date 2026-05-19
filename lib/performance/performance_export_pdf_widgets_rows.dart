part of 'performance_export_pdf.dart';

pw.Widget _chipTag(String text, PdfColor fg) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: pw.BoxDecoration(
      color: _kCardBg,
      border: pw.Border.all(color: _kBorder, width: 0.6),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: _pdfW(
      text,
      bold: true,
      fontSize: 8,
      color: fg,
    ),
  );
}

pw.Widget _headerWinrateRow(
  Locale locale,
  AppLocalizations l,
  int wrPct,
  TradeAggregates agg,
  String sourceLine,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _kBorder, width: 0.8),
      borderRadius: pw.BorderRadius.circular(10),
      color: PdfColors.white,
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 92,
          height: 92,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: _kAccent, width: 5),
          ),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                _pdfW(
                  '$wrPct%',
                  bold: true,
                  fontSize: 22,
                  color: _kPrimary,
                ),
                _pdfW(
                  'WINRATE',
                  bold: true,
                  fontSize: 7,
                  color: _kMuted,
                  letterSpacing: 0.9,
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _pdfW(
                sourceLine,
                fontSize: 10,
                color: PdfColors.grey800,
                height: 1.35,
              ),
              pw.SizedBox(height: 10),
              _legendRow(l.tradeFilterWinner, '${agg.wins}', _cGreen()),
              pw.SizedBox(height: 5),
              _legendRow(l.tradeFilterLoser, '${agg.losses}', _cRed()),
              pw.SizedBox(height: 5),
              _legendRow(l.tradeFilterBreakeven, '${agg.breakeven}', _cGrey()),
              pw.SizedBox(height: 10),
              pw.Container(height: 1, color: _kBorder),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _pdfW(
                    _p(locale, 'TOTAL TRADES', 'TOTAL TRADES', 'TOTAL DE TRADES', 'TRADES GESAMT', 'TOTAL DE TRADES', '전체 트레이드'),
                    bold: true,
                    fontSize: 8,
                    color: _kMuted,
                    letterSpacing: 0.7,
                  ),
                  _pdfW(
                    '${agg.total}',
                    bold: true,
                    fontSize: 14,
                    color: _kPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _legendRow(String label, String value, PdfColor dot) {
  return pw.Row(
    children: [
      pw.Container(
        width: 7,
        height: 7,
        decoration: pw.BoxDecoration(color: dot, shape: pw.BoxShape.circle),
      ),
      pw.SizedBox(width: 8),
      _pdfW(
        '$label $value',
        fontSize: 9,
        color: PdfColors.grey800,
      ),
    ],
  );
}

pw.Widget _horaireRow(Locale locale, String label, double wr, int count) {
  final c = count == 0 ? PdfColors.grey500 : (wr >= 0.5 ? _cGreen() : _cRed());
  final w = performanceTradeWordPlural(locale.languageCode, count);
  final right = count == 0
      ? '- · $count $w'
      : '${(wr * 100).round()}% WR · $count $w';
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: _pdfW(
            label,
            fontSize: 9,
            color: PdfColors.grey900,
          ),
        ),
        _pdfW(
          right,
          bold: true,
          fontSize: 9,
          color: c,
        ),
      ],
    ),
  );
}

pw.Widget _statPdfRow(Locale locale, String label, double wr, int n, PdfColor color) {
  final w = performanceTradeWordPlural(locale.languageCode, n);
  final right = n > 0 ? '${(wr * 100).round()}% WR · $n $w' : '— · $n $w';
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Expanded(
        child: _pdfW(
          label,
          fontSize: 10,
          color: PdfColors.grey900,
        ),
      ),
      _pdfW(
        right,
        bold: true,
        fontSize: 9,
        color: color,
      ),
    ],
  );
}

pw.Widget _discBar(Locale locale, String title, double wr, int n, PdfColor barColor) {
  final pct = n > 0 ? wr.clamp(0.0, 1.0) : 0.0;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: _pdfW(
              title,
              fontSize: 9,
              color: PdfColors.grey900,
            ),
          ),
          _pdfW(
            _wrTradeStr(locale, wr, n),
            bold: true,
            fontSize: 9,
            color: barColor,
          ),
        ],
      ),
      pw.SizedBox(height: 5),
      pw.Container(
        height: 6,
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: n == 0
            ? pw.SizedBox(height: 6)
            : pw.Row(
                children: [
                  pw.Expanded(
                    flex: (pct * 100).round().clamp(1, 100),
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        color: barColor,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: (100 - (pct * 100).round()).clamp(1, 100),
                    child: pw.Container(color: PdfColors.grey200),
                  ),
                ],
              ),
      ),
    ],
  );
}

pw.Widget _dailyJournalBucketRow(Locale locale, DailyJournalVolumeBucketStat s, int index) {
  final barColors = [_cGreen(), _cOrange(), _cRed()];
  final barColor = barColors[index.clamp(0, 2)];
  final n = s.tradeCount;
  final pct = n > 0 ? s.winRate.clamp(0.0, 1.0) : 0.0;
  final tw = performanceTradeWordPlural(locale.languageCode, n);
  final dw = performanceDayWordPlural(locale.languageCode, s.dayCount);
  final sub = n > 0 ? '$n $tw · ${s.dayCount} $dw' : '0 $tw · ${s.dayCount} $dw';

  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: _pdfW(
                s.label,
                bold: true,
                fontSize: 9,
                color: PdfColors.grey900,
              ),
            ),
            _pdfW(
              n > 0 ? '${(s.winRate * 100).round()}% WR' : '—',
              bold: true,
              fontSize: 9,
              color: barColor,
            ),
          ],
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: _pdfW(
            sub,
            fontSize: 7,
            color: _kMuted,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          height: 6,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: n == 0
              ? pw.SizedBox(height: 6)
              : pw.Row(
                  children: [
                    pw.Expanded(
                      flex: (pct * 100).round().clamp(1, 100),
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: barColor,
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: (100 - (pct * 100).round()).clamp(1, 100),
                      child: pw.Container(color: PdfColors.grey200),
                    ),
                  ],
                ),
        ),
      ],
    ),
  );
}
