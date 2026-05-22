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

/// Palette rapport PDF (thème clair).
abstract final class _OledPdf {
  static final bg = PdfColor.fromInt(0xFFFFFFFF);
  static final card = PdfColor.fromInt(0xFFFFFFFF);
  static final cardBorder = PdfColor.fromInt(0xFFE4E4E7);
  static final fieldBg = PdfColor.fromInt(0xFFF4F4F5);
  static final smcPanel = PdfColor.fromInt(0xFFEEF2FF);
  static final smcBorder = PdfColor.fromInt(0xFFC7D2FE);
  static final track = PdfColor.fromInt(0xFFE4E4E7);
  static final textPrimary = PdfColor.fromInt(0xFF18181B);
  static final zinc100 = textPrimary;
  static final zinc200 = PdfColor.fromInt(0xFF27272A);
  static final zinc400 = PdfColor.fromInt(0xFF52525B);
  static final zinc500 = PdfColor.fromInt(0xFF71717A);
  static final zinc600 = PdfColor.fromInt(0xFFA1A1AA);
  static final blue = PdfColor.fromInt(0xFF2563EB);
  static final indigo = PdfColor.fromInt(0xFF4F46E5);
  static final green = PdfColor.fromInt(0xFF059669);
  static final red = PdfColor.fromInt(0xFFDC2626);
  static final amber = PdfColor.fromInt(0xFFD97706);
  static final badgeBuyBg = PdfColor.fromInt(0xFFD1FAE5);
  static final badgeSellBg = PdfColor.fromInt(0xFFFEE2E2);
  static final badgeNeutralBg = fieldBg;

  static PdfColor confluence(int score) {
    if (score > 70) return green;
    if (score > 40) return amber;
    return red;
  }

  static PdfColor confidencePercent(int pct) {
    if (pct >= 70) return green;
    if (pct >= 45) return amber;
    return red;
  }

  static PdfColor fromFlutter(Color c) =>
      PdfColor.fromInt(0xFF000000 | (c.toARGB32() & 0xFFFFFF));
}

String analyseReportPdfFileName(AnalyseReportSnapshot s) {
  final raw = '${s.actif}_${s.sousTitre}'.trim();
  final cleaned = raw.replaceAll(RegExp(r'[<>:"/\\|?*\n\r]'), '_');
  final base = cleaned.length > 72 ? cleaned.substring(0, 72) : cleaned;
  return '${base.isEmpty ? 'analyse' : base}_rapport.pdf';
}

String _dashOr(String? v) {
  final a = _norm(v);
  return a.isEmpty ? '—' : a;
}

List<String> _lines(String main, List<String> extras) {
  final out = <String>[];
  final m = main.trim();
  if (m.isNotEmpty && m != '—') out.add(m);
  for (final e in extras) {
    final t = e.trim();
    if (t.isNotEmpty) out.add(t);
  }
  if (out.isEmpty) return const ['—'];
  return out;
}

PdfColor _biasBadgeBg(String biasLabel) {
  final b = biasLabel.toLowerCase();
  if (b.contains('achat') ||
      b.contains('long') ||
      b.contains('buy') ||
      b.contains('compra') ||
      b.contains('kauf') ||
      b.contains('매수')) {
    return _OledPdf.badgeBuyBg;
  }
  if (b.contains('vente') ||
      b.contains('short') ||
      b.contains('sell') ||
      b.contains('venda') ||
      b.contains('verkauf') ||
      b.contains('매도')) {
    return _OledPdf.badgeSellBg;
  }
  return _OledPdf.badgeNeutralBg;
}

PdfColor _biasBadgeFg(String biasLabel) {
  final b = biasLabel.toLowerCase();
  if (b.contains('achat') ||
      b.contains('long') ||
      b.contains('buy') ||
      b.contains('compra') ||
      b.contains('kauf') ||
      b.contains('매수')) {
    return _OledPdf.green;
  }
  if (b.contains('vente') ||
      b.contains('short') ||
      b.contains('sell') ||
      b.contains('venda') ||
      b.contains('verkauf') ||
      b.contains('매도')) {
    return _OledPdf.red;
  }
  return _OledPdf.textPrimary;
}

String _footerNote(AnalyseReportSnapshot s, AnalyseReportPdfCopy copy) {
  final lowS = s.gaugeStructure < 55;
  final lowSmc = s.gaugeSmc < 55;
  if (lowS && lowSmc) return copy.footerNoteLowBoth();
  if (lowS || lowSmc) return copy.footerNoteLowOne();
  return copy.footerNoteDefault(s.gaugeImpactFeuille);
}

pw.Widget _oledDivider() => pw.Container(
      height: 1,
      margin: const pw.EdgeInsets.symmetric(vertical: 12),
      color: _OledPdf.cardBorder,
    );

pw.Widget _oledCard({required List<pw.Widget> children}) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: _OledPdf.card,
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: _OledPdf.cardBorder, width: 0.8),
      boxShadow: const [
        pw.BoxShadow(
          color: PdfColor.fromInt(0x0F000000),
          blurRadius: 10,
          offset: PdfPoint(0, 2),
        ),
      ],
    ),
    padding: const pw.EdgeInsets.all(14),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

pw.Widget _sectionHeader({
  required String title,
  required PdfColor accent,
  int? confidencePct,
}) {
  return pw.Row(
    children: [
      pw.Container(
        width: 2,
        height: 14,
        decoration: pw.BoxDecoration(
          color: accent,
          borderRadius: pw.BorderRadius.circular(1),
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Expanded(
        child: _w(
          title,
          fontSize: 9,
          bold: true,
          color: accent,
          letterSpacing: 1.2,
        ),
      ),
      if (confidencePct != null)
        _w(
          '$confidencePct%',
          fontSize: 9,
          bold: true,
          color: _OledPdf.confidencePercent(confidencePct),
        ),
    ],
  );
}

pw.Widget _oledField({
  required String label,
  required String value,
  bool multiline = false,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _w(
        label,
        fontSize: 7,
        bold: true,
        color: _OledPdf.zinc500,
        letterSpacing: 0.8,
      ),
      pw.SizedBox(height: 3),
      pw.Container(
        padding: pw.EdgeInsets.symmetric(
          horizontal: 8,
          vertical: multiline ? 8 : 6,
        ),
        decoration: pw.BoxDecoration(
          color: _OledPdf.fieldBg,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: _OledPdf.cardBorder, width: 0.5),
        ),
        child: _w(
          _dashOr(value),
          fontSize: multiline ? 8.5 : 9,
          bold: true,
          color: _OledPdf.zinc100,
          height: multiline ? 1.35 : 1.2,
        ),
      ),
    ],
  );
}

pw.Widget _oledNote(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 6),
    child: pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _OledPdf.fieldBg,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _OledPdf.cardBorder, width: 0.5),
      ),
      child: _w(text, fontSize: 8, color: _OledPdf.zinc400, height: 1.4),
    ),
  );
}

pw.Widget _srLevel({
  required String prefix,
  required String price,
  required PdfColor accent,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: pw.BoxDecoration(
      color: _OledPdf.fieldBg,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: _OledPdf.cardBorder, width: 0.5),
    ),
    child: pw.Row(
      children: [
        _w(prefix, fontSize: 9, bold: true, color: accent),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: _w(_dashOr(price), fontSize: 9, bold: true, color: _OledPdf.textPrimary),
        ),
      ],
    ),
  );
}

pw.Widget _confluenceRing(AnalyseReportSnapshot s, AnalyseReportPdfCopy copy) {
  final score = s.confluenceScore.clamp(0, 100);
  final color = _OledPdf.confluence(score);
  final rest = (100 - score).clamp(0, 100);
  final v1 = score <= 0 ? 0.001 : score.toDouble();
  final v2 = rest <= 0 ? 0.001 : rest.toDouble();

  return pw.SizedBox(
    width: 72,
    height: 72,
    child: pw.Chart(
      grid: pw.PieGrid(startAngle: -math.pi / 2),
      datasets: [
        pw.PieDataSet(
          value: v1,
          color: color,
          innerRadius: 22,
          legendPosition: pw.PieLegendPosition.none,
          drawBorder: false,
        ),
        pw.PieDataSet(
          value: v2,
          color: _OledPdf.track,
          innerRadius: 22,
          legendPosition: pw.PieLegendPosition.none,
          drawBorder: false,
        ),
      ],
      overlay: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            _w('$score%', fontSize: 14, bold: true, color: _OledPdf.textPrimary),
            _w(
              copy.confluenceRingLabel,
              fontSize: 6,
              bold: true,
              color: _OledPdf.zinc500,
              letterSpacing: 0.8,
            ),
          ],
        ),
      ),
    ),
  );
}

pw.Widget _oledHero(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
  AnalyseReportSnapshotLabels labels,
) {
  final bias = labels.bias(s.biasLabel);

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _confluenceRing(s, copy),
      pw.SizedBox(width: 12),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _w(s.actif, fontSize: 18, bold: true, color: _OledPdf.textPrimary),
            pw.SizedBox(height: 3),
            _w(s.sousTitre, fontSize: 10, bold: true, color: _OledPdf.zinc200),
            pw.SizedBox(height: 4),
            _w(
              copy.analysisDateLabel(_dashOr(s.contexteDateLabel)),
              fontSize: 8,
              color: _OledPdf.zinc500,
            ),
            pw.SizedBox(height: 6),
            _w(
              copy.confluenceStatusLabel(s.confluenceScore),
              fontSize: 8,
              bold: true,
              color: _OledPdf.confluence(s.confluenceScore),
              letterSpacing: 0.4,
            ),
          ],
        ),
      ),
      if (s.gaugeContextEnabled)
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: _biasBadgeBg(bias),
            borderRadius: pw.BorderRadius.circular(16),
          ),
          child: _w(
            '${copy.directionPrefix} · $bias',
            fontSize: 8,
            bold: true,
            color: _biasBadgeFg(bias),
            letterSpacing: 0.3,
          ),
        ),
    ],
  );
}

pw.Widget _fundamentalSection(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
  AnalyseReportSnapshotLabels labels,
) {
  if (!s.gaugeContextEnabled) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(title: copy.sectionFundamental, accent: _OledPdf.blue),
        pw.SizedBox(height: 8),
        _w(copy.sectionDisabled, fontSize: 9, color: _OledPdf.zinc500),
      ],
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _sectionHeader(
        title: copy.sectionFundamental,
        accent: _OledPdf.blue,
        confidencePct: s.gaugeFeuille,
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _oledField(
              label: 'TIMEFRAME',
              value: s.contexteTfLine,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: _oledField(
              label: copy.l.analyseTrend.toUpperCase(),
              value: labels.trend(s.trendLabel),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: _oledField(
              label: copy.l.analysePhase.toUpperCase(),
              value: labels.phase(s.phaseLabel),
            ),
          ),
        ],
      ),
      if (s.noteStructure.trim().isNotEmpty) ...[
        pw.SizedBox(height: 8),
        _oledField(label: 'STRUCTURE', value: s.noteStructure, multiline: true),
      ],
      if (s.noteContexte.trim().isNotEmpty) ...[
        pw.SizedBox(height: 8),
        _oledField(label: copy.notesMacroLabel, value: s.noteContexte, multiline: true),
      ],
    ],
  );
}

pw.Widget _zoneCleSection(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
) {
  if (!s.gaugeStructureEnabled) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(title: copy.sectionZoneCle, accent: _OledPdf.indigo),
        pw.SizedBox(height: 8),
        _w(copy.sectionDisabled, fontSize: 9, color: _OledPdf.zinc500),
      ],
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _sectionHeader(
        title: copy.sectionZoneCle,
        accent: _OledPdf.indigo,
        confidencePct: s.gaugeStructure,
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _oledField(label: 'TIMEFRAME', value: s.structureTf)),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _oledField(label: 'CHARTISME', value: s.chartisme)),
        ],
      ),
      pw.SizedBox(height: 6),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _srLevel(
              prefix: 'S',
              price: s.support,
              accent: _OledPdf.green,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: _srLevel(
              prefix: 'R',
              price: s.resistance,
              accent: _OledPdf.red,
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _entrySection(AnalyseReportSnapshot s, AnalyseReportPdfCopy copy) {
  if (!s.gaugeIndicatorsEnabled) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(title: copy.sectionEntry, accent: _OledPdf.green),
        pw.SizedBox(height: 8),
        _w(copy.sectionDisabled, fontSize: 9, color: _OledPdf.zinc500),
      ],
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _sectionHeader(
        title: copy.sectionEntry,
        accent: _OledPdf.green,
        confidencePct: s.gaugeIndicators,
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _oledField(label: 'TIMEFRAME', value: s.indicatorsTf)),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: _oledField(label: copy.signauxLabel, value: s.indicateursOutils),
          ),
        ],
      ),
      if (s.noteIndicators.trim().isNotEmpty) ...[
        pw.SizedBox(height: 8),
        _oledField(
          label: copy.actionPlanLabel,
          value: s.noteIndicators,
          multiline: true,
        ),
      ],
    ],
  );
}

pw.Widget _smcPanel(AnalyseReportSnapshot s, AnalyseReportPdfCopy copy) {
  if (!s.gaugeSmcEnabled) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(title: copy.sectionSmc, accent: _OledPdf.indigo),
        pw.SizedBox(height: 8),
        _w(copy.sectionDisabled, fontSize: 9, color: _OledPdf.zinc500),
      ],
    );
  }

  final obLines = _lines(s.smcOb, s.smcObExtras);
  final fvgLines = _lines(s.smcFvg, s.smcFvgExtras);
  final liqLines = _lines(s.smcLiq, s.smcLiquidityExtras);

  pw.Widget smcGroup(String label, List<String> lines) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _w(label, fontSize: 7, bold: true, color: _OledPdf.indigo, letterSpacing: 0.5),
        pw.SizedBox(height: 4),
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) pw.SizedBox(height: 4),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: pw.BoxDecoration(
              color: _OledPdf.fieldBg,
              borderRadius: pw.BorderRadius.circular(5),
              border: pw.Border.all(color: _OledPdf.cardBorder, width: 0.4),
            ),
            child: _w(lines[i], fontSize: 8.5, color: _OledPdf.zinc200),
          ),
        ],
      ],
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _sectionHeader(
        title: copy.sectionSmc,
        accent: _OledPdf.indigo,
        confidencePct: s.gaugeSmc,
      ),
      pw.SizedBox(height: 8),
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _OledPdf.smcPanel,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: _OledPdf.smcBorder, width: 0.6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            smcGroup(copy.l.analyseReportCellOrderBlock, obLines),
            pw.SizedBox(height: 8),
            smcGroup(copy.l.analyseReportCellFvg, fvgLines),
            pw.SizedBox(height: 8),
            smcGroup(copy.l.analyseReportCellLiqPools, liqLines),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                if (s.smcFibOteLabel.trim().isNotEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: _OledPdf.fieldBg,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: _OledPdf.cardBorder),
                    ),
                    child: _w(s.smcFibOteLabel, fontSize: 8, bold: true, color: _OledPdf.zinc200),
                  ),
                if (s.smcFibOteLabel.trim().isNotEmpty) pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _w(
                    '${copy.fibPriceLabel} : ${_dashOr(s.smcFibPrice)}',
                    fontSize: 8.5,
                    color: _OledPdf.zinc200,
                  ),
                ),
              ],
            ),
            if (s.noteSmc.trim().isNotEmpty) ...[
              pw.SizedBox(height: 8),
              _oledNote(s.noteSmc),
            ],
          ],
        ),
      ),
    ],
  );
}

pw.Widget _volumeSection(AnalyseReportSnapshot s, AnalyseReportPdfCopy copy) {
  if (!s.gaugeVolumeProfileEnabled) return pw.SizedBox();

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _sectionHeader(title: copy.sectionVolume, accent: _OledPdf.zinc500),
      pw.SizedBox(height: 8),
      if ((s.volumeProfileTf ?? '').trim().isNotEmpty)
        _oledField(label: 'TIMEFRAME', value: s.volumeProfileTf!),
      if ((s.volumeProfileTf ?? '').trim().isNotEmpty) pw.SizedBox(height: 6),
      if (s.volumeProfileZoneActive == true) ...[
        pw.Row(
          children: [
            pw.Expanded(
              child: _oledField(
                label: '${copy.l.analyseVolumeZoneLabel} (${copy.l.analyseVolumeZoneFrom})',
                value: s.volumeProfileZoneFrom ?? '',
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _oledField(
                label: '${copy.l.analyseVolumeZoneLabel} (${copy.l.analyseVolumeZoneTo})',
                value: s.volumeProfileZoneTo ?? '',
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
      ],
      pw.Row(
        children: [
          pw.Expanded(child: _oledField(label: copy.l.analyseVolumePoc, value: s.poc)),
          pw.SizedBox(width: 6),
          pw.Expanded(child: _oledField(label: copy.l.analyseVolumeVah, value: s.vah)),
          pw.SizedBox(width: 6),
          pw.Expanded(child: _oledField(label: copy.l.analyseVolumeVal, value: s.val)),
        ],
      ),
      if (s.noteVolume.trim().isNotEmpty) _oledNote(s.noteVolume),
    ],
  );
}

pw.Widget _confidenceBar(int pct, PdfColor fill) {
  final f = (pct.clamp(0, 100) / 100 * 100).round();
  if (f <= 0) {
    return pw.Container(
      height: 5,
      decoration: pw.BoxDecoration(
        color: _OledPdf.track,
        borderRadius: pw.BorderRadius.circular(3),
      ),
    );
  }
  if (f >= 100) {
    return pw.Container(
      height: 5,
      decoration: pw.BoxDecoration(
        color: fill,
        borderRadius: pw.BorderRadius.circular(3),
      ),
    );
  }
  return pw.Container(
    height: 5,
    decoration: pw.BoxDecoration(
      color: _OledPdf.track,
      borderRadius: pw.BorderRadius.circular(3),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: f,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              color: fill,
              borderRadius: pw.BorderRadius.circular(3),
            ),
          ),
        ),
        pw.Expanded(flex: 100 - f, child: pw.SizedBox()),
      ],
    ),
  );
}

pw.Widget _confidenceRow(String label, int pct, PdfColor accent) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: _w(label, fontSize: 8, color: _OledPdf.zinc400)),
          _w(
            '$pct%',
            fontSize: 8,
            bold: true,
            color: _OledPdf.confidencePercent(pct),
          ),
        ],
      ),
      pw.SizedBox(height: 4),
      _confidenceBar(pct, accent),
    ],
  );
}

pw.Widget _confidencePanel(AnalyseReportSnapshot s, AnalyseReportPdfCopy copy) {
  final impF = s.gaugeImpactFeuille;
  final globalPct = s.globalConfidencePercent;
  final globalColor = _OledPdf.fromFlutter(s.globalConfidenceColor);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _sectionHeader(
        title: copy.confidencePanelTitle(impF),
        accent: _OledPdf.zinc400,
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _w(
            copy.globalConfidenceLabel,
            fontSize: 9,
            bold: true,
            color: _OledPdf.zinc400,
            letterSpacing: 0.4,
          ),
          _w(
            '$globalPct%',
            fontSize: 14,
            bold: true,
            color: globalColor,
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      _confidenceRow(copy.feuilleGaugeRow, s.gaugeFeuille, _OledPdf.blue),
      pw.SizedBox(height: 8),
      _confidenceRow(copy.structureGaugeRow, s.gaugeStructure, _OledPdf.indigo),
      pw.SizedBox(height: 8),
      _confidenceRow(copy.entryGaugeRow, s.gaugeIndicators, _OledPdf.green),
      pw.SizedBox(height: 8),
      _confidenceRow(copy.smcGaugeRow, s.gaugeSmc, _OledPdf.indigo),
      pw.SizedBox(height: 8),
      _w(
        '* ${_footerNote(s, copy)}',
        fontSize: 7,
        color: _OledPdf.zinc600,
        fontStyle: pw.FontStyle.italic,
        height: 1.35,
      ),
    ],
  );
}

pw.Widget _annexeTitle(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 8),
      child: _w(t, fontSize: 9, bold: true, color: _OledPdf.zinc400, letterSpacing: 0.6),
    );

pw.Widget _annexeCard(List<pw.Widget> rows) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 8),
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: _OledPdf.fieldBg,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: _OledPdf.cardBorder, width: 0.5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: rows,
    ),
  );
}

pw.Widget _annexeKv(String k, String v) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: _w(k, fontSize: 8, bold: true, color: _OledPdf.zinc500),
          ),
          pw.Expanded(
            child: _w(v, fontSize: 8, bold: true, color: _OledPdf.zinc200),
          ),
        ],
      ),
    );

List<pw.Widget> _annexeBlocks(
  AnalyseReportSnapshot s,
  AnalyseReportPdfCopy copy,
  AnalyseReportSnapshotLabels labels,
) {
  final out = <pw.Widget>[];

  void addCopies<T>({
    required String title,
    required List<T>? copies,
    required List<pw.Widget> Function(T c) build,
  }) {
    final list = copies;
    if (list == null || list.isEmpty) return;
    out.add(_annexeTitle(title));
    for (final c in list) {
      out.add(_annexeCard(build(c)));
    }
  }

  addCopies<AnalyseReportContexteCopy>(
    title: copy.annexeContexte(),
    copies: s.contexteCopies,
    build: (c) => [
      _annexeKv(copy.directionPrefix, labels.bias(c.biasLabel)),
      _annexeKv(copy.l.analyseTimeframeLabelShort, _dashOr(c.contexteTfLine)),
      _annexeKv(copy.l.analyseTrend, labels.trend(c.trendLabel)),
      _annexeKv(copy.l.analysePhase, labels.phase(c.phaseLabel)),
    ],
  );

  addCopies<AnalyseReportStructureCopy>(
    title: copy.annexeStructure(),
    copies: s.structureCopies,
    build: (c) => [
      _annexeKv(copy.l.analyseTimeframeLabelShort, _dashOr(c.structureTf)),
      _annexeKv(copy.lastPointLabel, _dashOr(c.chartisme)),
      _annexeKv(copy.l.analyseSupport, _dashOr(c.support)),
      _annexeKv(copy.l.analyseResistShort, _dashOr(c.resistance)),
    ],
  );

  addCopies<AnalyseReportIndicatorsCopy>(
    title: copy.annexeIndicators(),
    copies: s.indicatorsCopies,
    build: (c) => [
      _annexeKv(copy.l.analyseTimeframeLabelShort, _dashOr(c.indicatorsTf)),
      _annexeKv(copy.signauxLabel, _dashOr(c.indicateursOutils)),
      if (c.noteIndicators.trim().isNotEmpty)
        _annexeKv(copy.actionPlanLabel, c.noteIndicators),
    ],
  );

  addCopies<AnalyseReportSmcCopy>(
    title: copy.annexeSmc(),
    copies: s.smcCopies,
    build: (c) => [
      _annexeKv(copy.l.analyseReportCellOrderBlock, _dashOr(c.smcOb)),
      _annexeKv(copy.l.analyseReportCellFvg, _dashOr(c.smcFvg)),
      _annexeKv(copy.l.analyseReportCellLiqPools, _dashOr(c.smcLiq)),
      _annexeKv('Fib / OTE', _dashOr(c.smcFibOteLabel)),
      _annexeKv(copy.fibPriceLabel, _dashOr(c.smcFibPrice)),
      if (c.noteSmc.trim().isNotEmpty) _annexeKv('Note', c.noteSmc),
    ],
  );

  return out;
}

pw.Widget _pdfFooter(AnalyseReportPdfCopy copy) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 10),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _w(copy.brandFooter, fontSize: 7, color: _OledPdf.zinc600, letterSpacing: 0.8),
        _w(copy.generatedBy, fontSize: 7, color: _OledPdf.zinc600),
      ],
    ),
  );
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

  final mainCard = _oledCard(
    children: [
      _oledHero(s, copy, labels),
      _oledDivider(),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _fundamentalSection(s, copy, labels),
                if (s.gaugeVolumeProfileEnabled) ...[
                  pw.SizedBox(height: 12),
                  _volumeSection(s, copy),
                ],
                pw.SizedBox(height: 12),
                _entrySection(s, copy),
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _zoneCleSection(s, copy),
                pw.SizedBox(height: 12),
                _smcPanel(s, copy),
              ],
            ),
          ),
        ],
      ),
      _oledDivider(),
      _confidencePanel(s, copy),
      _pdfFooter(copy),
    ],
  );

  final body = <pw.Widget>[
    mainCard,
    ..._annexeBlocks(s, copy, labels),
  ];

  if (imageBytes != null && imageBytes.isNotEmpty) {
    body.addAll([
      pw.SizedBox(height: 14),
      _w(
        copy.captureSection,
        fontSize: 9,
        bold: true,
        color: _OledPdf.zinc400,
        letterSpacing: 0.6,
      ),
      pw.SizedBox(height: 8),
      pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: _OledPdf.card,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: _OledPdf.cardBorder),
        ),
        child: pw.Image(
          pw.MemoryImage(imageBytes),
          width: 480,
          fit: pw.BoxFit.contain,
        ),
      ),
    ]);
  }

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 36, 32, 32),
        theme: pdfTheme,
        buildBackground: (ctx) => pw.Container(color: _OledPdf.bg),
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
