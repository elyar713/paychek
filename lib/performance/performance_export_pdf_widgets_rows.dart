part of 'performance_export_pdf.dart';

pw.Widget _chipTag(String text, PdfColor fg) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey200,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Text(
      _pdfText(text),
      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: fg),
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
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(12),
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
            border: pw.Border.all(color: _cGreen(), width: 6),
          ),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  '$wrPct%',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
                pw.Text(
                  'WINRATE',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                    letterSpacing: 0.8,
                  ),
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
              pw.Text(
                _pdfText(sourceLine),
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 8),
              _legendRow(l.tradeFilterWinner, '${agg.wins}', _cGreen()),
              pw.SizedBox(height: 4),
              _legendRow(l.tradeFilterLoser, '${agg.losses}', _cRed()),
              pw.SizedBox(height: 4),
              _legendRow(l.tradeFilterBreakeven, '${agg.breakeven}', _cGrey()),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    _p(locale, 'TOTAL TRADES', 'TOTAL TRADES', 'TOTAL DE TRADES', 'TRADES GESAMT', 'TOTAL DE TRADES', '전체 트레이드'),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  pw.Text(
                    '${agg.total}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey900,
                    ),
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
        width: 6,
        height: 6,
        decoration: pw.BoxDecoration(color: dot, shape: pw.BoxShape.circle),
      ),
      pw.SizedBox(width: 8),
      pw.Text(
        _pdfText('$label $value'),
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
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
    padding: const pw.EdgeInsets.only(bottom: 5),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Text(
            _pdfText(label),
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900),
          ),
        ),
        pw.Text(
          _pdfText(right),
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: c),
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
        child: pw.Text(_pdfText(label), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900)),
      ),
      pw.Text(
        _pdfText(right),
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: color),
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
            child: pw.Text(
              _pdfText(title),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900),
            ),
          ),
          pw.Text(
            _wrTradeStr(locale, wr, n),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: barColor),
          ),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Container(
        height: 5,
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: pw.BorderRadius.circular(2),
        ),
        child: n == 0
            ? pw.SizedBox(height: 5)
            : pw.Row(
                children: [
                  pw.Expanded(
                    flex: (pct * 100).round().clamp(1, 100),
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        color: barColor,
                        borderRadius: pw.BorderRadius.circular(2),
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
              child: pw.Text(
                _pdfText(s.label),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900),
              ),
            ),
            pw.Text(
              n > 0 ? '${(s.winRate * 100).round()}% WR' : '—',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: barColor),
            ),
          ],
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Text(
            _pdfText(sub),
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 5,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: n == 0
              ? pw.SizedBox(height: 5)
              : pw.Row(
                  children: [
                    pw.Expanded(
                      flex: (pct * 100).round().clamp(1, 100),
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: barColor,
                          borderRadius: pw.BorderRadius.circular(2),
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
