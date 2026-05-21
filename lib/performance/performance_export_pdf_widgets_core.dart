part of 'performance_export_pdf.dart';

// Palette Paychek (alignée stratégie / checklist).
final PdfColor _kPrimary = PdfColor.fromHex('0F172A');
final PdfColor _kAccent = PdfColor.fromHex('0D9488');
final PdfColor _kCardBg = PdfColor.fromHex('F8FAFC');
final PdfColor _kBorder = PdfColor.fromHex('E2E8F0');
final PdfColor _kMuted = PdfColor.fromHex('64748B');

PdfColor _cGreen() => PdfColor.fromHex('15803D');
PdfColor _cRed() => PdfColor.fromHex('DC2626');
PdfColor _cRedDark() => PdfColor.fromHex('991B1B');
PdfColor _cRedBg() => PdfColor.fromHex('FFF1F2');
PdfColor _cOrange() => PdfColor.fromHex('D97706');
PdfColor _cGrey() => PdfColor.fromHex('888888');

pw.Widget _sectionTitle(String t) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8, top: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 4,
          height: 16,
          decoration: pw.BoxDecoration(
            color: _kAccent,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _pdfW(
            t.toUpperCase(),
            bold: true,
            fontSize: 10,
            color: _kPrimary,
            letterSpacing: 0.7,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _card({
  required List<pw.Widget> children,
  double topPadding = 0,
  PdfColor? bg,
}) {
  return pw.Container(
    margin: pw.EdgeInsets.only(top: topPadding),
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _kBorder, width: 0.8),
      borderRadius: pw.BorderRadius.circular(10),
      color: bg ?? PdfColors.white,
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
  if (warningStyle) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: pw.BoxDecoration(
          color: _cRedBg(),
          border: pw.Border.all(color: _cRedDark(), width: 0.8),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfW('!', bold: true, fontSize: 10, color: _cRedDark()),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: _pdfW(
                text,
                bold: true,
                fontSize: 9,
                color: PdfColors.grey900,
                height: 1.35,
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
        _pdfW('•', bold: true, fontSize: 9, color: _kAccent),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: _pdfW(
            text,
            fontSize: 9,
            color: PdfColors.grey800,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _mindsetFooter(Locale locale, double wrP, int nP, double wrF, int nF) {
  if (nP < 2 || nF < 2) {
    return _pdfW(
      _p(
        locale,
        'Comparer Principe / Feeling avec assez de trades pour une lecture fiable.',
        'Compare Principle / Feeling once you have enough trades for a reliable reading.',
        'Compara Principio / Feeling con bastantes trades para una lectura fiable.',
        'Vergleichen Sie Prinzip / Feeling mit genügend Trades für eine belastbare Lesart.',
        'Compare Princípio / Feeling com trades suficientes para leitura confiável.',
        '충분한 트레이드가 모이면 원칙/느낌 비교가 의미 있습니다.',
      ),
      fontSize: 8,
      color: _kMuted,
    );
  }
  final betterLbl = wrP >= wrF
      ? _p(locale, 'Principe', 'Principle', 'Principio', 'Prinzip', 'Princípio', '원칙')
      : _p(locale, 'Feeling', 'Feeling', 'Feeling', 'Feeling', 'Feeling', '느낌');
  return _pdfW(
    _p(
      locale,
      'Meilleur WR sur "$betterLbl".',
      'Higher WR on "$betterLbl".',
      'Mejor WR en "$betterLbl".',
      'Hohe WR bei "$betterLbl".',
      'Melhor WR em "$betterLbl".',
      '"$betterLbl"에서 WR이 더 높습니다.',
    ),
    fontSize: 8,
    color: PdfColors.grey700,
    fontStyle: pw.FontStyle.italic,
  );
}
