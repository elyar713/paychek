import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'analyse_report_pdf_platform.dart' as pdf_platform;
import 'analyse_report_snapshot.dart';

String _safePdfFileName(AnalyseReportSnapshot s) {
  final raw = '${s.actif}_${s.sousTitre}'.trim();
  final cleaned = raw.replaceAll(RegExp(r'[<>:"/\\|?*\n\r]'), '_');
  final base = cleaned.length > 72 ? cleaned.substring(0, 72) : cleaned;
  return '${base.isEmpty ? 'analyse' : base}_rapport.pdf';
}

/// Texte lisible avec la police PDF standard (Helvetica).
String _ascii(String? v) {
  var x = (v ?? '').trim();
  x = x.replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ');
  x = x.replaceAll('×', 'x');
  x = x.replaceAll(RegExp(r'[«»]'), '"');
  x = x.replaceAll(RegExp(r'[\u2018\u2019\u201A\u201B]'), "'");
  x = x.replaceAll(RegExp(r'[\u201C\u201D\u201E\u201F]'), '"');
  x = x.replaceAll(RegExp(r'[\u2013\u2014\u2212]'), '-');
  x = x.replaceAll('…', '...');
  x = x.replaceAll('•', '-');
  const map = <String, String>{
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'É': 'E',
    'à': 'a',
    'â': 'a',
    'À': 'A',
    'ù': 'u',
    'û': 'u',
    'Ù': 'U',
    'î': 'i',
    'ï': 'i',
    'Î': 'I',
    'ô': 'o',
    'ö': 'o',
    'Ô': 'O',
    'ç': 'c',
    'Ç': 'C',
    'œ': 'oe',
    'Œ': 'OE',
  };
  map.forEach((k, v2) => x = x.replaceAll(k, v2));
  final out = StringBuffer();
  for (final r in x.runes) {
    if (r <= 0x7F) {
      out.writeCharCode(r);
    } else {
      out.write('?');
    }
  }
  final t = out.toString().trim();
  return t.isEmpty ? '-' : t;
}

PdfColor _kGold() => PdfColor.fromInt(0xFFC9A227);
PdfColor _kGoldMuted() => PdfColor.fromInt(0xFF8B6914);
PdfColor _badgeBg(AnalyseReportSnapshot s) {
  final b = s.biasLabel.toLowerCase();
  if (b.contains('achat') || b.contains('long') || b.contains('buy')) {
    return PdfColor.fromInt(0xFF15803D);
  }
  if (b.contains('vente') || b.contains('short') || b.contains('sell')) {
    return PdfColor.fromInt(0xFFDC2626);
  }
  return PdfColors.grey700;
}

String _dashOr(String? v) {
  final a = _ascii(v);
  return a == '-' ? '-' : a;
}

String _executiveParagraph(AnalyseReportSnapshot s) {
  if (s.noteContexte.trim().isNotEmpty) {
    return s.noteContexte.trim();
  }
  final parts = <String>[];
  if (s.gaugeContextEnabled) {
    parts.add(
      'Analyse ${_ascii(s.contexteTfLine)} : tendance ${_ascii(s.trendLabel)}, phase ${_ascii(s.phaseLabel)}.',
    );
  }
  if (s.gaugeStructureEnabled) {
    parts.add(
      'Structure ${_ascii(s.structureTf)} - ${_ascii(s.chartisme)}. Supports / resistances : ${_ascii(s.support)} / ${_ascii(s.resistance)}.',
    );
  }
  if (parts.isEmpty) {
    return 'Rapport Mon Analyse - confiance globale ${s.globalConfidencePercent} %.';
  }
  return parts.join(' ');
}

String _footerNote(AnalyseReportSnapshot s) {
  final lowS = s.gaugeStructure < 55;
  final lowSmc = s.gaugeSmc < 55;
  if (lowS && lowSmc) {
    return 'Note : la confiance structurelle et SMC reste moderee en attente d\'un retest confirme du scenario.';
  }
  if (lowS || lowSmc) {
    return 'Note : une ou plusieurs sections affichent une confiance moderee - croiser avec le prix avant engagement.';
  }
  return 'Note : confiance par section avec impact pondere (${s.gaugeImpactFeuille} % / section active typique).';
}

pw.Widget _templateCard({required List<pw.Widget> children}) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12),
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(14),
      border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

pw.Widget _pdfHeader(AnalyseReportSnapshot s) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 14),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _ascii(s.actif).toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                _ascii(s.sousTitre),
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _kGoldMuted(),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                _ascii('Date de l\'analyse : ${_dashOr(s.contexteDateLabel)}'),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(
            color: _badgeBg(s),
            borderRadius: pw.BorderRadius.circular(20),
          ),
          child: pw.Text(
            _ascii('DIRECTION : ${s.biasLabel}'),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _confidenceDonut(AnalyseReportSnapshot s) {
  final p = s.globalConfidencePercent.clamp(0, 100);
  final rest = (100 - p).clamp(0, 100);
  final v1 = p <= 0 ? 0.001 : p.toDouble();
  final v2 = rest <= 0 ? 0.001 : rest.toDouble();

  return pw.SizedBox(
    width: 108,
    height: 108,
    child: pw.Chart(
      grid: pw.PieGrid(startAngle: -math.pi / 2),
      datasets: [
        pw.PieDataSet(
          value: v1,
          color: _kGold(),
          innerRadius: 30,
          legendPosition: pw.PieLegendPosition.none,
          drawBorder: false,
          borderColor: PdfColors.white,
        ),
        pw.PieDataSet(
          value: v2,
          color: PdfColors.grey300,
          innerRadius: 30,
          legendPosition: pw.PieLegendPosition.none,
          drawBorder: false,
          borderColor: PdfColors.white,
        ),
      ],
      overlay: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              '$p%',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: _kGold(),
              ),
            ),
            pw.Text(
              'CONFIANCE',
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

pw.Widget _executiveSummaryBlock(AnalyseReportSnapshot s) {
  return _templateCard(
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _confidenceDonut(s),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RESUME EXECUTIF',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                    letterSpacing: 0.8,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  _ascii(_executiveParagraph(s)),
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _twoColumnTrendStructure(AnalyseReportSnapshot s) {
  final left = <pw.Widget>[
    pw.Text(
      'FEUILLE & TENDANCE',
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey900,
        letterSpacing: 0.5,
      ),
    ),
    pw.SizedBox(height: 8),
    if (s.gaugeContextEnabled) ...[
      _kvPdf('Timeframe', _dashOr(s.contexteTfLine)),
      _kvPdf('Tendance', _dashOr(s.trendLabel), valueColor: PdfColors.green700),
      _kvPdf('Phase', _dashOr(s.phaseLabel)),
      if (s.noteContexte.isNotEmpty) _italicNote(s.noteContexte),
    ] else
      pw.Text(
        _ascii('Section desactivee.'),
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
      ),
  ];

  final right = <pw.Widget>[
    pw.Text(
      'STRUCTURE ${_ascii(s.structureTf).toUpperCase()}',
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey900,
        letterSpacing: 0.5,
      ),
    ),
    pw.SizedBox(height: 8),
    if (s.gaugeStructureEnabled) ...[
      _kvPdf('Signal / dernier point', _dashOr(s.chartisme)),
      _kvPdf(
        'Support',
        '${_dashOr(s.support)}${_structureTestedSuffix(s.structureSupportTested)}',
      ),
      _kvPdf(
        'Resistance',
        '${_dashOr(s.resistance)}${_structureTestedSuffix(s.structureResistanceTested)}',
      ),
      if (s.noteStructure.isNotEmpty) _italicNote(s.noteStructure),
    ] else
      pw.Text(
        _ascii('Section desactivee.'),
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
      ),
  ];

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: _templateCard(children: left),
      ),
      pw.SizedBox(width: 10),
      pw.Expanded(
        child: _templateCard(children: right),
      ),
    ],
  );
}

String _structureTestedSuffix(bool? tested) {
  if (tested == null) return '';
  return tested ? ' (Teste x2)' : '';
}

pw.Widget _kvPdf(String k, String v, {PdfColor? valueColor}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 5),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '${_ascii(k)} : ',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.TextSpan(
            text: _ascii(v),
            style: pw.TextStyle(
              fontSize: 9,
              color: valueColor ?? PdfColors.grey900,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Widget _italicNote(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 6),
    child: pw.Text(
      _ascii(text),
      style: pw.TextStyle(
        fontSize: 8,
        color: PdfColors.grey600,
        fontStyle: pw.FontStyle.italic,
        height: 1.35,
      ),
    ),
  );
}

pw.Widget _toolsAndSmcWide(AnalyseReportSnapshot s) {
  return _templateCard(
    children: [
      pw.Text(
        'OUTILS TECHNIQUE & SMC',
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey900,
          letterSpacing: 0.6,
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Indicateurs ${_ascii(s.indicatorsTf)}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (s.gaugeIndicatorsEnabled)
                  pw.Text(
                    _ascii(s.indicateursOutils),
                    style: const pw.TextStyle(fontSize: 9, height: 1.35),
                  )
                else
                  pw.Text(
                    _ascii('Section desactivee.'),
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                if (s.noteIndicators.isNotEmpty) _italicNote(s.noteIndicators),
              ],
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Analyse SMC / Flux',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (s.gaugeSmcEnabled) ...[
                  _kvPdf('Order block / zone', _dashOr(s.smcOb)),
                  _kvPdf('FVG', _dashOr(s.smcFvg)),
                  _kvPdf('Liquidite', _dashOr(s.smcLiq)),
                  _kvPdf('Fib / OTE', _dashOr(s.smcFibOteLabel)),
                  _kvPdf('Prix Fib', _dashOr(s.smcFibPrice)),
                ] else
                  pw.Text(
                    _ascii('Section desactivee.'),
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                if (s.noteSmc.isNotEmpty) _italicNote(s.noteSmc),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _goldBar(int percent) {
  final p = (percent / 100.0).clamp(0.0, 1.0);
  final f = (p * 100).round().clamp(0, 100);
  if (f <= 0) {
    return pw.Container(
      height: 6,
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(3),
      ),
    );
  }
  if (f >= 100) {
    return pw.Container(
      height: 6,
      decoration: pw.BoxDecoration(
        color: _kGold(),
        borderRadius: pw.BorderRadius.circular(3),
      ),
    );
  }
  return pw.Container(
    height: 6,
    decoration: pw.BoxDecoration(
      color: PdfColors.grey200,
      borderRadius: pw.BorderRadius.circular(3),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: f,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              color: _kGold(),
              borderRadius: pw.BorderRadius.circular(3),
            ),
          ),
        ),
        pw.Expanded(
          flex: 100 - f,
          child: pw.Container(color: PdfColors.grey200),
        ),
      ],
    ),
  );
}

pw.Widget _confidenceSectionBlock(AnalyseReportSnapshot s) {
  final impF = s.gaugeImpactFeuille;
  return _templateCard(
    children: [
      pw.Text(
        _ascii('CONFIANCE PAR SECTION (IMPACT $impF% CHACUNE)'),
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey900,
          letterSpacing: 0.4,
        ),
      ),
      pw.SizedBox(height: 12),
      _confidenceRowPdf('Feuille & Tendance', s.gaugeFeuille),
      pw.SizedBox(height: 10),
      _confidenceRowPdf('Structure', s.gaugeStructure),
      pw.SizedBox(height: 10),
      _confidenceRowPdf('Indicateurs', s.gaugeIndicators),
      pw.SizedBox(height: 10),
      _confidenceRowPdf('SMC', s.gaugeSmc),
      pw.SizedBox(height: 10),
      pw.Text(
        '* ${_ascii(_footerNote(s))}',
        style: pw.TextStyle(
          fontSize: 8,
          color: PdfColors.grey600,
          fontStyle: pw.FontStyle.italic,
          height: 1.35,
        ),
      ),
    ],
  );
}

pw.Widget _confidenceRowPdf(String label, int pct) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              _ascii(label),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
            ),
          ),
          pw.Text(
            '$pct%',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _kGold(),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 4),
      _goldBar(pct),
    ],
  );
}

pw.Widget _volumeCard(AnalyseReportSnapshot s) {
  if (!s.gaugeVolumeProfileEnabled) return pw.SizedBox();
  return _templateCard(
    children: [
      pw.Text(
        'PROFIL DE VOLUME',
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey900,
        ),
      ),
      pw.SizedBox(height: 8),
      if ((s.volumeProfileTf ?? '').trim().isNotEmpty)
        _kvPdf('TF', _dashOr(s.volumeProfileTf)),
      if (s.volumeProfileZoneActive == true) ...[
        _kvPdf('Zone (de)', _dashOr(s.volumeProfileZoneFrom)),
        _kvPdf('Zone (a)', _dashOr(s.volumeProfileZoneTo)),
      ],
      _kvPdf('POC', _dashOr(s.poc)),
      _kvPdf('VAH', _dashOr(s.vah)),
      _kvPdf('VAL', _dashOr(s.val)),
      if (s.noteVolume.isNotEmpty) _italicNote(s.noteVolume),
    ],
  );
}

pw.Widget _pdfSectionTitle(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8, bottom: 6),
      child: pw.Text(
        _ascii(t),
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey800,
        ),
      ),
    );

pw.Widget _pdfLine(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '${_ascii(label)} : ',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.TextSpan(
              text: _ascii(value),
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
    );

/// Blocs supplementaires (copies) - annexe.
List<pw.Widget> _annexeBlocks(AnalyseReportSnapshot s) {
  final out = <pw.Widget>[];

  if (s.contexteCopies != null && s.contexteCopies!.isNotEmpty) {
    out.add(_pdfSectionTitle('Annexe - copies Feuille & tendance'));
    for (var i = 0; i < s.contexteCopies!.length; i++) {
      final c = s.contexteCopies![i];
      out.add(
        _templateCard(
          children: [
            _pdfLine('Direction', c.biasLabel),
            _pdfLine('Timeframe', _dashOr(c.contexteTfLine)),
            _pdfLine('Tendance', _dashOr(c.trendLabel)),
            _pdfLine('Phase', _dashOr(c.phaseLabel)),
          ],
        ),
      );
    }
  }

  if (s.structureCopies != null && s.structureCopies!.isNotEmpty) {
    out.add(_pdfSectionTitle('Annexe - copies Structure'));
    for (var i = 0; i < s.structureCopies!.length; i++) {
      final c = s.structureCopies![i];
      out.add(
        _templateCard(
          children: [
            _pdfLine('Timeframe', _dashOr(c.structureTf)),
            _pdfLine('Dernier point', _dashOr(c.chartisme)),
            _pdfLine('Support', _dashOr(c.support)),
            _pdfLine('Resistance', _dashOr(c.resistance)),
          ],
        ),
      );
    }
  }

  if (s.indicatorsCopies != null && s.indicatorsCopies!.isNotEmpty) {
    out.add(_pdfSectionTitle('Annexe - copies Indicateurs'));
    for (final c in s.indicatorsCopies!) {
      out.add(
        _templateCard(
          children: [
            _pdfLine('Timeframe', _dashOr(c.indicatorsTf)),
            _pdfLine('Outils', _dashOr(c.indicateursOutils)),
            if (c.noteIndicators.isNotEmpty) _italicNote(c.noteIndicators),
          ],
        ),
      );
    }
  }

  if (s.smcCopies != null && s.smcCopies!.isNotEmpty) {
    out.add(_pdfSectionTitle('Annexe - copies SMC'));
    for (final c in s.smcCopies!) {
      out.add(
        _templateCard(
          children: [
            _pdfLine('Order block / zone', _dashOr(c.smcOb)),
            _pdfLine('FVG', _dashOr(c.smcFvg)),
            _pdfLine('Liquidite', _dashOr(c.smcLiq)),
            _pdfLine('Fib / OTE', _dashOr(c.smcFibOteLabel)),
            _pdfLine('Prix Fib', _dashOr(c.smcFibPrice)),
            if (c.noteSmc.isNotEmpty) _italicNote(c.noteSmc),
          ],
        ),
      );
    }
  }

  return out;
}

Future<Uint8List> buildAnalyseReportPdf(
  AnalyseReportSnapshot s, {
  Uint8List? imageBytes,
}) async {
  final doc = pw.Document(
    title: _ascii(s.actif),
    author: 'Mon Analyse',
  );

  final body = <pw.Widget>[
    pw.Container(
      color: PdfColors.grey100,
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _pdfHeader(s),
          _executiveSummaryBlock(s),
          _twoColumnTrendStructure(s),
          _toolsAndSmcWide(s),
          _confidenceSectionBlock(s),
          _volumeCard(s),
        ],
      ),
    ),
    ..._annexeBlocks(s),
  ];

  if (imageBytes != null && imageBytes.isNotEmpty) {
    body.addAll([
      pw.SizedBox(height: 12),
      _pdfSectionTitle('Capture'),
      pw.SizedBox(height: 6),
      pw.Image(
        pw.MemoryImage(imageBytes),
        width: 480,
        fit: pw.BoxFit.contain,
      ),
    ]);
  }

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 42, 36, 36),
        buildBackground: (ctx) => pw.Container(color: PdfColors.grey50),
      ),
      build: (ctx) => body,
    ),
  );

  return doc.save();
}

/// Export PDF : web (telechargement), bureau (Enregistrer sous), mobile (partage fichier).
Future<void> exportAnalyseReportPdf(
  BuildContext context, {
  required AnalyseReportSnapshot snapshot,
  Uint8List? imageBytes,
}) async {
  try {
    final bytes = await buildAnalyseReportPdf(
      snapshot,
      imageBytes: imageBytes,
    );
    if (!context.mounted) return;
    final name = _safePdfFileName(snapshot);

    final ok = await pdf_platform.trySaveReportPdfOnPlatform(
      bytes,
      name,
      shareContext: context,
    );
    if (!ok) {
      return;
    }
  } catch (e, st) {
    debugPrint('exportAnalyseReportPdf: $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de creer le PDF : $e',
            style: const TextStyle(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
