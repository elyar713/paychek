part of 'performance_export_pdf.dart';

PdfColor _cGreen() => PdfColor.fromInt(0xFF10B981);
PdfColor _cRed() => PdfColor.fromInt(0xFFEF4444);
PdfColor _cRedDark() => PdfColor.fromInt(0xFF991B1B);
PdfColor _cRedBg() => PdfColor.fromInt(0xFFFFE4E4);
PdfColor _cOrange() => PdfColor.fromInt(0xFFF59E0B);
PdfColor _cGrey() => PdfColor.fromInt(0xFF6B7280);

pw.Widget _sectionTitle(String t) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6, top: 4),
    child: pw.Text(
      _pdfText(t),
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blueGrey800,
        letterSpacing: 0.5,
      ),
    ),
  );
}

pw.Widget _card({
  required List<pw.Widget> children,
  double topPadding = 0,
}) {
  return pw.Container(
    margin: pw.EdgeInsets.only(top: topPadding),
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(12),
      color: PdfColors.grey50,
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    ),
  );
}

String _wrTradeStr(Locale locale, double wr, int n) {
  final w = performanceTradeWordPlural(locale.languageCode, n);
  if (n <= 0) return '0 $w';
  final wrPct = '${(wr * 100).round()}% WR';
  return '$wrPct ($n $w)';
}

pw.Widget _pdfBulletLine(String text, {bool warningStyle = false}) {
  final plain = _pdfText(text);
  if (warningStyle) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: pw.BoxDecoration(
          color: _cRedBg(),
          border: pw.Border.all(color: _cRedDark(), width: 0.8),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '! ',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _cRedDark(),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                plain,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey900,
                  height: 1.35,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('- ', style: pw.TextStyle(color: _cRedDark(), fontWeight: pw.FontWeight.bold)),
        pw.Expanded(
          child: pw.Text(
            plain,
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey900, height: 1.3),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _mindsetFooter(Locale locale, double wrP, int nP, double wrF, int nF) {
  if (nP < 2 || nF < 2) {
    return pw.Text(
      _pdfText(
        _p(
          locale,
          'Comparer Principe / Feeling avec assez de trades pour une lecture fiable.',
          'Compare Principle / Feeling once you have enough trades for a reliable reading.',
          'Compara Principio / Feeling con bastantes trades para una lectura fiable.',
          'Vergleichen Sie Prinzip / Feeling mit genügend Trades für eine belastbare Lesart.',
          'Compare Princípio / Feeling com trades suficientes para leitura confiável.',
          '충분한 트레이드가 모이면 원칙/느낌 비교가 의미 있습니다.',
        ),
      ),
      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
    );
  }
  final betterLbl = wrP >= wrF
      ? _p(locale, 'Principe', 'Principle', 'Principio', 'Prinzip', 'Princípio', '원칙')
      : _p(locale, 'Feeling', 'Feeling', 'Feeling', 'Feeling', 'Feeling', '느낌');
  return pw.Text(
    _pdfText(
      _p(
        locale,
        'Meilleur WR sur "$betterLbl".',
        'Higher WR on "$betterLbl".',
        'Mejor WR en "$betterLbl".',
        'Hohe WR bei "$betterLbl".',
        'Melhor WR em "$betterLbl".',
        '"$betterLbl"에서 WR이 더 높습니다.',
      ),
    ),
    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic),
  );
}
