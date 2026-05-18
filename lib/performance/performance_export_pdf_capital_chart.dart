part of 'performance_export_pdf.dart';

// Palette alignée dashboard / checklist PDF.
final PdfColor _kCapGrid = PdfColor.fromHex('E2E8F0');
final PdfColor _kCapMuted = PdfColor.fromHex('64748B');

class _CapitalChartModel {
  const _CapitalChartModel({
    required this.values,
    required this.xLabels,
    required this.minY,
    required this.maxY,
    required this.yTicks,
  });

  final List<double> values;
  final List<String> xLabels;
  final double minY;
  final double maxY;
  final List<double> yTicks;
}

_CapitalChartModel _buildCapitalChartModel(
  List<Trade> trades,
  double? initialCapital,
) {
  final sorted = [...trades]..sort((a, b) => a.sortKey.compareTo(b.sortKey));
  if (sorted.isEmpty) {
    final flat = initialCapital ?? 0.0;
    return _CapitalChartModel(
      values: [flat, flat],
      xLabels: ['—', '—'],
      minY: flat - 10,
      maxY: flat + 10,
      yTicks: [flat - 10, flat, flat + 10],
    );
  }

  final base = initialCapital ?? 0.0;
  var cum = 0.0;
  final values = <double>[base];
  final labels = <String>[_ddMm(sorted.first.sortKey)];

  for (final t in sorted) {
    cum += t.profit;
    values.add(base + cum);
    labels.add(_ddMm(t.sortKey));
  }

  var minY = values.reduce((a, b) => a < b ? a : b);
  var maxY = values.reduce((a, b) => a > b ? a : b);
  final span = (maxY - minY).abs();
  final pad = span < 1e-6 ? 12.0 : span * 0.12;
  minY -= pad;
  maxY += pad;

  return _CapitalChartModel(
    values: values,
    xLabels: labels,
    minY: minY,
    maxY: maxY,
    yTicks: _yTicks(minY, maxY, 4),
  );
}

String _ddMm(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

List<double> _yTicks(double minY, double maxY, int divisions) {
  if (motionless(minY, maxY)) {
    return [minY, (minY + maxY) / 2, maxY];
  }
  final range = maxY - minY;
  final rawStep = range / divisions;
  final step = _niceStep(rawStep);
  final start = (minY / step).floor() * step;
  final ticks = <double>[];
  for (var v = start; v <= maxY + step * 0.01; v += step) {
    if (v >= minY - step * 0.01) ticks.add(v);
  }
  if (ticks.length < 2) return [minY, maxY];
  return ticks;
}

bool motionless(double a, double b) => (a - b).abs() < 1e-9;

double _niceStep(double raw) {
  if (raw <= 0 || !raw.isFinite) return 1;
  final exp = (math.log(raw) / math.ln10).floor();
  final f = raw / math.pow(10, exp);
  double nice;
  if (f <= 1) {
    nice = 1;
  } else if (f <= 2) {
    nice = 2;
  } else if (f <= 5) {
    nice = 5;
  } else {
    nice = 10;
  }
  return nice * math.pow(10, exp);
}

String _formatYTick(double v) {
  final a = v.abs();
  if (a >= 1000) return v.round().toString();
  if (a >= 100) return v.round().toString();
  if (a >= 10) return v.toStringAsFixed(0);
  return v.toStringAsFixed(1);
}

pw.Widget _capitalEvolutionChartSection(
  Locale locale,
  AppLocalizations l,
  List<Trade> trades,
  double? initialCapital,
) {
  final model = _buildCapitalChartModel(trades, initialCapital);
  final title = _pdfText(l.dashboardCapitalEvolutionTitle.toUpperCase());
  final subtitle = _pdfText(
    _p(
      locale,
      'Capital cumule (profit + frais), ordre chronologique.',
      'Cumulative capital (profit + fees), chronological order.',
      'Capital acumulado (beneficio + comisiones), orden cronologico.',
      'Kumuliertes Kapital (Gewinn + Gebuehren), chronologisch.',
      'Capital acumulado (lucro + taxas), ordem cronologica.',
      '누적 자본(손익+수수료), 시간순.',
    ),
  );

  return pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      border: pw.Border.all(color: _kCapGrid),
      borderRadius: pw.BorderRadius.circular(12),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _kCapMuted,
            letterSpacing: 1.1,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          subtitle,
          style: pw.TextStyle(fontSize: 9, color: _kCapMuted),
        ),
        pw.SizedBox(height: 12),
        _capitalEvolutionChartSvg(model),
        if (trades.isEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              _pdfText(
                _p(
                  locale,
                  'Aucun trade sur la periode selectionnee.',
                  'No trades in the selected period.',
                  'Sin operaciones en el periodo seleccionado.',
                  'Keine Trades im gewaehlten Zeitraum.',
                  'Nenhum trade no periodo selecionado.',
                  '선택 기간에 트레이드 없음.',
                ),
              ),
              style: pw.TextStyle(fontSize: 8.5, color: _kCapMuted),
            ),
          ),
      ],
    ),
  );
}

pw.Widget _capitalEvolutionChartSvg(_CapitalChartModel model) {
  const chartW = 480.0;
  const chartH = 130.0;
  const padL = 36.0;
  const padR = 8.0;
  const padT = 8.0;
  const padB = 22.0;
  final plotW = chartW - padL - padR;
  final plotH = chartH - padT - padB;
  final n = model.values.length;
  if (n < 2) return pw.SizedBox(height: chartH);

  double xAt(int i) => padL + (i / (n - 1)) * plotW;

  double yAt(double v) {
    final t = (v - model.minY) / (model.maxY - model.minY);
    return padT + plotH - (t.clamp(0.0, 1.0) * plotH);
  }

  final gridLines = StringBuffer();
  for (final tick in model.yTicks) {
    final y = yAt(tick).toStringAsFixed(2);
    gridLines.writeln(
      '<line x1="$padL" y1="$y" x2="${padL + plotW}" y2="$y" stroke="#E2E8F0" stroke-width="1"/>',
    );
  }

  for (var i = 0; i < n; i++) {
    final x = xAt(i).toStringAsFixed(2);
    gridLines.writeln(
      '<line x1="$x" y1="$padT" x2="$x" y2="${padT + plotH}" stroke="#F1F5F9" stroke-width="1"/>',
    );
  }

  final area = StringBuffer();
  area.write('M ${xAt(0).toStringAsFixed(2)} ${(padT + plotH).toStringAsFixed(2)}');
  for (var i = 0; i < n; i++) {
    area.write(' L ${xAt(i).toStringAsFixed(2)} ${yAt(model.values[i]).toStringAsFixed(2)}');
  }
  area.write(' L ${xAt(n - 1).toStringAsFixed(2)} ${(padT + plotH).toStringAsFixed(2)} Z');

  final line = StringBuffer();
  for (var i = 0; i < n; i++) {
    final x = xAt(i).toStringAsFixed(2);
    final y = yAt(model.values[i]).toStringAsFixed(2);
    line.write(i == 0 ? 'M $x $y' : ' L $x $y');
  }

  final dots = StringBuffer();
  for (var i = 0; i < n; i++) {
    final x = xAt(i).toStringAsFixed(2);
    final y = yAt(model.values[i]).toStringAsFixed(2);
    dots.writeln(
      '<circle cx="$x" cy="$y" r="2.8" fill="#0F172A" stroke="#FFFFFF" stroke-width="1"/>',
    );
  }

  final yLabels = StringBuffer();
  for (final tick in model.yTicks) {
    final y = (yAt(tick) + 3).toStringAsFixed(2);
    yLabels.writeln(
      '<text x="${(padL - 4).toStringAsFixed(2)}" y="$y" text-anchor="end" font-size="7" fill="#64748B">${_formatYTick(tick)}</text>',
    );
  }

  final xLabels = StringBuffer();
  final step = n <= 12 ? 1 : (n / 12).ceil();
  for (var i = 0; i < n; i += step) {
    final x = xAt(i).toStringAsFixed(2);
    final y = (padT + plotH + 12).toStringAsFixed(2);
    xLabels.writeln(
      '<text x="$x" y="$y" text-anchor="middle" font-size="6.5" fill="#64748B">${_escapeXml(model.xLabels[i])}</text>',
    );
  }

  final svg =
      '''
<svg xmlns="http://www.w3.org/2000/svg" width="$chartW" height="$chartH" viewBox="0 0 $chartW $chartH">
  <rect x="0" y="0" width="$chartW" height="$chartH" fill="#FFFFFF" rx="6"/>
  $gridLines
  <path d="$area" fill="#E2E8F0" fill-opacity="0.85"/>
  <path d="$line" fill="none" stroke="#0F172A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  $dots
  $yLabels
  $xLabels
</svg>
''';

  return pw.SvgImage(svg: svg);
}

String _escapeXml(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
