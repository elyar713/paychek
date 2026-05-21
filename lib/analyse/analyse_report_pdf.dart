import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/app_localizations.dart';
import '../shared/paychek_pdf_fonts.dart';
import '../shared/paychek_pdf_text.dart';
import 'analyse_report_label_locale.dart';
import 'analyse_report_pdf_copy.dart';
import 'analyse_report_pdf_platform.dart' as pdf_platform;
import 'analyse_report_snapshot.dart';

bool _pdfKo = false;

bool _koFor(String text) => _pdfKo || paychekPdfTextHasHangul(text);

String _norm(String? v) => paychekPdfNormalize(v);

pw.Widget _w(
  String? text, {
  bool bold = false,
  double fontSize = 9,
  PdfColor? color,
  double? height,
  double? letterSpacing,
  pw.FontStyle fontStyle = pw.FontStyle.normal,
  pw.TextAlign? textAlign,
}) {
  final t = _norm(text);
  return PaychekPdfFonts.text(
    t,
    preferHangulPrimary: _koFor(t),
    fontSize: fontSize,
    bold: bold,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
    textAlign: textAlign,
  );
}

/// Nom de fichier suggéré pour l’export / pièce jointe trade.
String analyseReportPdfFileName(AnalyseReportSnapshot s) {
  final raw = '${s.actif}_${s.sousTitre}'.trim();
  final cleaned = raw.replaceAll(RegExp(r'[<>:"/\\|?*\n\r]'), '_');
  final base = cleaned.length > 72 ? cleaned.substring(0, 72) : cleaned;
  return '${base.isEmpty ? 'analyse' : base}_rapport.pdf';
}

PdfColor _kGold() => PdfColor.fromInt(0xFFC9A227);
PdfColor _kGoldMuted() => PdfColor.fromInt(0xFF8B6914);

PdfColor _badgeBg(String biasLabel) {
  final b = biasLabel.toLowerCase();
  if (b.contains('achat') ||
      b.contains('long') ||
      b.contains('buy') ||
      b.contains('compra') ||
      b.contains('kauf') ||
      b.contains('매수')) {
    return PdfColor.fromInt(0xFF15803D);
  }
  if (b.contains('vente') ||
      b.contains('short') ||
      b.contains('sell') ||
      b.contains('venda') ||
      b.contains('verkauf') ||
      b.contains('매도')) {
    return PdfColor.fromInt(0xFFDC2626);
  }
  return PdfColors.grey700;
}

String _dashOr(String? v) {
  final a = _norm(v);
  return a.isEmpty ? '—' : a;
}

String _executiveParagraph(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
  AnalyseReportSnapshotLabels labels,
) {
  if (s.noteContexte.trim().isNotEmpty) {
    return s.noteContexte.trim();
  }
  final parts = <String>[];
  if (s.gaugeContextEnabled) {
    parts.add(
      copy.executiveContextLine(
        _dashOr(s.contexteTfLine),
        labels.trend(s.trendLabel),
        labels.phase(s.phaseLabel),
      ),
    );
  }
  if (s.gaugeStructureEnabled) {
    parts.add(
      copy.executiveStructureLine(
        _dashOr(s.structureTf),
        _dashOr(s.chartisme),
        _dashOr(s.support),
        _dashOr(s.resistance),
      ),
    );
  }
  if (parts.isEmpty) {
    return copy.executiveFallback(s.globalConfidencePercent);
  }
  return parts.join(' ');
}

String _footerNote(AnalyseReportSnapshot s, AnalyseReportPdfCopy copy) {
  final lowS = s.gaugeStructure < 55;
  final lowSmc = s.gaugeSmc < 55;
  if (lowS && lowSmc) return copy.footerNoteLowBoth();
  if (lowS || lowSmc) return copy.footerNoteLowOne();
  return copy.footerNoteDefault(s.gaugeImpactFeuille);
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

pw.Widget _pdfHeader(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
  AnalyseReportSnapshotLabels labels,
) {
  final bias = labels.bias(s.biasLabel);
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 14),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _w(s.actif, fontSize: 20, bold: true, color: PdfColors.grey900),
              pw.SizedBox(height: 4),
              _w(s.sousTitre, fontSize: 11, bold: true, color: _kGoldMuted()),
              pw.SizedBox(height: 6),
              _w(
                copy.analysisDateLabel(_dashOr(s.contexteDateLabel)),
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(
            color: _badgeBg(bias),
            borderRadius: pw.BorderRadius.circular(20),
          ),
          child: _w(
            '${copy.directionPrefix} : $bias',
            fontSize: 9,
            bold: true,
            color: PdfColors.white,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _confidenceDonut(AnalyseReportSnapshot s, AnalyseReportPdfCopy copy) {
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
            _w('$p%', fontSize: 16, bold: true, color: _kGold()),
            _w(
              copy.confidenceDonutLabel,
              fontSize: 7,
              bold: true,
              color: PdfColors.grey700,
              letterSpacing: 0.6,
            ),
          ],
        ),
      ),
    ),
  );
}

pw.Widget _executiveSummaryBlock(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
  AnalyseReportSnapshotLabels labels,
) {
  return _templateCard(
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _confidenceDonut(s, copy),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _w(
                  copy.executiveSummaryTitle,
                  fontSize: 11,
                  bold: true,
                  color: PdfColors.grey900,
                  letterSpacing: 0.8,
                ),
                pw.SizedBox(height: 8),
                _w(
                  _executiveParagraph(s, copy, labels),
                  fontSize: 9,
                  color: PdfColors.grey800,
                  height: 1.4,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _twoColumnTrendStructure(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
  AnalyseReportSnapshotLabels labels,
) {
  final left = <pw.Widget>[
    _w(
      copy.feuilleTendanceSection,
      fontSize: 10,
      bold: true,
      color: PdfColors.grey900,
      letterSpacing: 0.5,
    ),
    pw.SizedBox(height: 8),
    if (s.gaugeContextEnabled) ...[
      _kvPdf(copy.l.analyseTimeframeLabelShort, _dashOr(s.contexteTfLine)),
      _kvPdf(
        copy.l.analyseTrend,
        labels.trend(s.trendLabel),
        valueColor: PdfColors.green700,
      ),
      _kvPdf(copy.l.analysePhase, labels.phase(s.phaseLabel)),
      if (s.noteContexte.isNotEmpty) _italicNote(s.noteContexte),
    ] else
      _w(copy.sectionDisabled, fontSize: 9, color: PdfColors.grey600),
  ];

  final right = <pw.Widget>[
    _w(
      copy.structureTitle(s.structureTf),
      fontSize: 10,
      bold: true,
      color: PdfColors.grey900,
      letterSpacing: 0.5,
    ),
    pw.SizedBox(height: 8),
    if (s.gaugeStructureEnabled) ...[
      _kvPdf(copy.signalLastPoint, _dashOr(s.chartisme)),
      _kvPdf(
        copy.l.analyseSupport,
        '${_dashOr(s.support)}${_structureTestedSuffix(s.structureSupportTested, copy)}',
      ),
      _kvPdf(
        copy.l.analyseResistShort,
        '${_dashOr(s.resistance)}${_structureTestedSuffix(s.structureResistanceTested, copy)}',
      ),
      if (s.noteStructure.isNotEmpty) _italicNote(s.noteStructure),
    ] else
      _w(copy.sectionDisabled, fontSize: 9, color: PdfColors.grey600),
  ];

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(child: _templateCard(children: left)),
      pw.SizedBox(width: 10),
      pw.Expanded(child: _templateCard(children: right)),
    ],
  );
}

String _structureTestedSuffix(bool? tested, AnalyseReportPdfCopy copy) {
  if (tested != true) return '';
  return copy.testedSuffix();
}

pw.Widget _kvPdf(String k, String v, {PdfColor? valueColor}) {
  final key = _norm(k);
  final val = _norm(v);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 5),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$key : ',
            style: PaychekPdfFonts.style(
              text: '$key : ',
              preferHangulPrimary: _koFor(key),
              fontSize: 9,
              bold: true,
              color: PdfColors.grey800,
            ),
          ),
          pw.TextSpan(
            text: val,
            style: PaychekPdfFonts.style(
              text: val,
              preferHangulPrimary: _koFor(val),
              fontSize: 9,
              bold: true,
              color: valueColor ?? PdfColors.grey900,
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
    child: _w(
      text,
      fontSize: 8,
      color: PdfColors.grey600,
      fontStyle: pw.FontStyle.italic,
      height: 1.35,
    ),
  );
}

pw.Widget _toolsAndSmcWide(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
) {
  return _templateCard(
    children: [
      _w(
        copy.toolsSmcTitle,
        fontSize: 10,
        bold: true,
        color: PdfColors.grey900,
        letterSpacing: 0.6,
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _w(
                  copy.indicatorsTitle(s.indicatorsTf),
                  fontSize: 9,
                  bold: true,
                  color: PdfColors.grey800,
                ),
                pw.SizedBox(height: 4),
                if (s.gaugeIndicatorsEnabled)
                  _w(s.indicateursOutils, fontSize: 9, height: 1.35)
                else
                  _w(copy.sectionDisabled, fontSize: 9, color: PdfColors.grey600),
                if (s.noteIndicators.isNotEmpty) _italicNote(s.noteIndicators),
              ],
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _w(
                  copy.smcFluxTitle,
                  fontSize: 9,
                  bold: true,
                  color: PdfColors.grey800,
                ),
                pw.SizedBox(height: 4),
                if (s.gaugeSmcEnabled) ...[
                  _kvPdf(copy.l.analyseReportCellOrderBlock, _dashOr(s.smcOb)),
                  _kvPdf(copy.l.analyseReportCellFvg, _dashOr(s.smcFvg)),
                  _kvPdf(copy.l.analyseReportCellLiqPools, _dashOr(s.smcLiq)),
                  _kvPdf('Fib / OTE', _dashOr(s.smcFibOteLabel)),
                  _kvPdf(copy.fibPriceLabel, _dashOr(s.smcFibPrice)),
                ] else
                  _w(copy.sectionDisabled, fontSize: 9, color: PdfColors.grey600),
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

pw.Widget _confidenceSectionBlock(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
) {
  final impF = s.gaugeImpactFeuille;
  return _templateCard(
    children: [
      _w(
        copy.confidenceBySection(impF),
        fontSize: 10,
        bold: true,
        color: PdfColors.grey900,
        letterSpacing: 0.4,
      ),
      pw.SizedBox(height: 12),
      _confidenceRowPdf(copy.feuilleGaugeRow, s.gaugeFeuille),
      pw.SizedBox(height: 10),
      _confidenceRowPdf(copy.structureGaugeRow, s.gaugeStructure),
      pw.SizedBox(height: 10),
      _confidenceRowPdf(copy.indicatorsGaugeRow, s.gaugeIndicators),
      pw.SizedBox(height: 10),
      _confidenceRowPdf(copy.smcGaugeRow, s.gaugeSmc),
      pw.SizedBox(height: 10),
      _w(
        '* ${_footerNote(s, copy)}',
        fontSize: 8,
        color: PdfColors.grey600,
        fontStyle: pw.FontStyle.italic,
        height: 1.35,
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
          pw.Expanded(child: _w(label, fontSize: 9, color: PdfColors.grey800)),
          _w('$pct%', fontSize: 9, bold: true, color: _kGold()),
        ],
      ),
      pw.SizedBox(height: 4),
      _goldBar(pct),
    ],
  );
}

pw.Widget _volumeCard(AnalyseReportSnapshot s, AnalyseReportPdfCopy copy) {
  if (!s.gaugeVolumeProfileEnabled) return pw.SizedBox();
  return _templateCard(
    children: [
      _w(
        copy.l.analyseVolumeProfile,
        fontSize: 10,
        bold: true,
        color: PdfColors.grey900,
      ),
      pw.SizedBox(height: 8),
      if ((s.volumeProfileTf ?? '').trim().isNotEmpty)
        _kvPdf(copy.l.analyseTimeframeLabelShort, _dashOr(s.volumeProfileTf)),
      if (s.volumeProfileZoneActive == true) ...[
        _kvPdf(
          '${copy.l.analyseVolumeZoneLabel} (${copy.l.analyseVolumeZoneFrom})',
          _dashOr(s.volumeProfileZoneFrom),
        ),
        _kvPdf(
          '${copy.l.analyseVolumeZoneLabel} (${copy.l.analyseVolumeZoneTo})',
          _dashOr(s.volumeProfileZoneTo),
        ),
      ],
      _kvPdf(copy.l.analyseVolumePoc, _dashOr(s.poc)),
      _kvPdf(copy.l.analyseVolumeVah, _dashOr(s.vah)),
      _kvPdf(copy.l.analyseVolumeVal, _dashOr(s.val)),
      if (s.noteVolume.isNotEmpty) _italicNote(s.noteVolume),
    ],
  );
}

pw.Widget _pdfSectionTitle(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8, bottom: 6),
      child: _w(t, fontSize: 11, bold: true, color: PdfColors.blueGrey800),
    );

pw.Widget _pdfLine(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: _kvPdf(label, value),
    );

List<pw.Widget> _annexeBlocks(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
  AnalyseReportSnapshotLabels labels,
) {
  final out = <pw.Widget>[];

  if (s.contexteCopies != null && s.contexteCopies!.isNotEmpty) {
    out.add(_pdfSectionTitle(copy.annexeContexte()));
    for (final c in s.contexteCopies!) {
      out.add(
        _templateCard(
          children: [
            _pdfLine(copy.directionPrefix, labels.bias(c.biasLabel)),
            _pdfLine(copy.l.analyseTimeframeLabelShort, _dashOr(c.contexteTfLine)),
            _pdfLine(copy.l.analyseTrend, labels.trend(c.trendLabel)),
            _pdfLine(copy.l.analysePhase, labels.phase(c.phaseLabel)),
          ],
        ),
      );
    }
  }

  if (s.structureCopies != null && s.structureCopies!.isNotEmpty) {
    out.add(_pdfSectionTitle(copy.annexeStructure()));
    for (final c in s.structureCopies!) {
      out.add(
        _templateCard(
          children: [
            _pdfLine(copy.l.analyseTimeframeLabelShort, _dashOr(c.structureTf)),
            _pdfLine(copy.lastPointLabel, _dashOr(c.chartisme)),
            _pdfLine(copy.l.analyseSupport, _dashOr(c.support)),
            _pdfLine(copy.l.analyseResistShort, _dashOr(c.resistance)),
          ],
        ),
      );
    }
  }

  if (s.indicatorsCopies != null && s.indicatorsCopies!.isNotEmpty) {
    out.add(_pdfSectionTitle(copy.annexeIndicators()));
    for (final c in s.indicatorsCopies!) {
      out.add(
        _templateCard(
          children: [
            _pdfLine(copy.l.analyseTimeframeLabelShort, _dashOr(c.indicatorsTf)),
            _pdfLine(copy.toolsLabel, _dashOr(c.indicateursOutils)),
            if (c.noteIndicators.isNotEmpty) _italicNote(c.noteIndicators),
          ],
        ),
      );
    }
  }

  if (s.smcCopies != null && s.smcCopies!.isNotEmpty) {
    out.add(_pdfSectionTitle(copy.annexeSmc()));
    for (final c in s.smcCopies!) {
      out.add(
        _templateCard(
          children: [
            _pdfLine(copy.l.analyseReportCellOrderBlock, _dashOr(c.smcOb)),
            _pdfLine(copy.l.analyseReportCellFvg, _dashOr(c.smcFvg)),
            _pdfLine(copy.l.analyseReportCellLiqPools, _dashOr(c.smcLiq)),
            _pdfLine('Fib / OTE', _dashOr(c.smcFibOteLabel)),
            _pdfLine(copy.fibPriceLabel, _dashOr(c.smcFibPrice)),
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
  required Locale locale,
  required AppLocalizations l,
}) async {
  await PaychekPdfFonts.ensureLoaded();
  _pdfKo = locale.languageCode == 'ko';
  final pdfTheme = PaychekPdfFonts.theme();
  final copy = AnalyseReportPdfCopy(locale, l);
  final labels = AnalyseReportSnapshotLabels(locale);

  final doc = pw.Document(
    title: _norm(s.actif),
    author: 'Paychek',
    theme: pdfTheme,
  );

  final body = <pw.Widget>[
    pw.Container(
      color: PdfColors.grey100,
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _pdfHeader(s, copy, labels),
          _executiveSummaryBlock(s, copy, labels),
          _twoColumnTrendStructure(s, copy, labels),
          _toolsAndSmcWide(s, copy),
          _confidenceSectionBlock(s, copy),
          _volumeCard(s, copy),
        ],
      ),
    ),
    ..._annexeBlocks(s, copy, labels),
  ];

  if (imageBytes != null && imageBytes.isNotEmpty) {
    body.addAll([
      pw.SizedBox(height: 12),
      _pdfSectionTitle(copy.captureSection),
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
        theme: pdfTheme,
        buildBackground: (ctx) => pw.Container(color: PdfColors.grey50),
      ),
      build: (ctx) => body,
    ),
  );

  return doc.save();
}

Future<void> exportAnalyseReportPdf(
  BuildContext context, {
  required AnalyseReportSnapshot snapshot,
  Uint8List? imageBytes,
}) async {
  try {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final bytes = await buildAnalyseReportPdf(
      snapshot,
      imageBytes: imageBytes,
      locale: locale,
      l: l,
    );
    if (!context.mounted) return;
    final name = analyseReportPdfFileName(snapshot);

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
            AppLocalizations.of(context)!.exportPdfFailedWithError('$e'),
            style: const TextStyle(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
