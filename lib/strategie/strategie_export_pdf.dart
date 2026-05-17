import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../analyse/analyse_report_pdf_platform.dart' as pdf_platform;
import '../l10n/app_localizations.dart';
import 'strategie_feedback_reference.dart';
import 'strategie_gestion_risque_storage.dart';
import 'strategie_horaires_sessions_storage.dart';
import 'strategie_setups_store.dart';
import 'widgets/strategie_setup_card.dart';

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

PdfColor _kGreen() => PdfColor.fromInt(0xFF15803D);
PdfColor _kRed() => PdfColor.fromInt(0xFFDC2626);
PdfColor _kGreyBg() => PdfColor.fromInt(0xFFF3F4F6);

pw.Widget _sectionTitle(String t) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8, top: 4),
    child: pw.Text(
      _ascii(t),
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey900,
        letterSpacing: 0.6,
      ),
    ),
  );
}

pw.Widget _bulletLine(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('- ', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
        pw.Expanded(
          child: pw.Text(
            _ascii(text),
            style: const pw.TextStyle(fontSize: 9, height: 1.3),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _card({required List<pw.Widget> children, PdfColor? bg}) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 10),
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: bg ?? PdfColors.white,
      borderRadius: pw.BorderRadius.circular(10),
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

Future<Uint8List> buildStrategiePdf(Locale locale) async {
  final l = lookupAppLocalizations(locale);
  final gr = StrategieFeedbackReference.gestionRisque(locale);
  await StrategieSetupsStore.ensureLoaded();
  final gestion = await StrategieGestionRisqueStorage.load();
  final sessions = await StrategieHorairesSessionsStorage.load();
  final setups = List<StrategieSetupCardData>.from(StrategieSetupsStore.notifier.value);
  final rules = StrategieFeedbackReference.mesReglesDor(locale);

  final body = <pw.Widget>[
    pw.Center(
      child: pw.Text(
        _ascii(l.plusMyStrategy.toUpperCase()),
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey900,
          letterSpacing: 1.2,
        ),
      ),
    ),
    pw.SizedBox(height: 6),
    pw.Center(
      child: pw.Text(
        _ascii(l.strategiePdfPlaybookBlurbShort),
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700, height: 1.35),
      ),
    ),
    pw.SizedBox(height: 12),
    pw.Container(height: 1, color: PdfColors.grey400),
    pw.SizedBox(height: 14),
    _sectionTitle(l.ajouterTradeStrategieGoldRules),
    _card(
      bg: _kGreyBg(),
      children: [
        for (var i = 0; i < rules.length; i++) ...[
          if (i > 0) pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 22,
                  height: 22,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey700,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    '${i + 1}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Text(
                    _ascii(rules[i]),
                    style: const pw.TextStyle(fontSize: 9, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
    _sectionTitle(l.ajouterTradeStrategieRiskManagement),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _riskCell(
            gr[0].label,
            '${gestion.riskPct}%',
            false,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _riskCell(
            gr[1].label,
            '${gestion.lossPct}%',
            true,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _riskCell(
            gr[2].label,
            '${gestion.tradesPerDay} ${l.strategieGestionCaptionMaximum}',
            false,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _riskCell(
            gr[3].label,
            '1:${gestion.rrRatio.round()} ${l.strategieGestionCaptionMinimum}',
            false,
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 14),
    _sectionTitle(l.ajouterTradeStrategieHoursSessions),
    _card(
      bg: _kGreyBg(),
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                _ascii(l.strategiePdfTableSession),
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                _ascii(l.strategiePdfTableDescription),
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                _ascii(l.strategiePdfTableSchedule),
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        for (final s in sessions) ...[
          pw.Divider(color: PdfColors.grey400, height: 1),
          pw.SizedBox(height: 6),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  _ascii(s.title),
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: s.isNoTradeZone ? _kRed() : PdfColors.grey900,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  _ascii(s.subtitle),
                  style: const pw.TextStyle(fontSize: 8, height: 1.3),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  _ascii(s.timeDisplay),
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: s.isNoTradeZone ? _kRed() : PdfColors.grey900,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
        ],
      ],
    ),
    _sectionTitle(l.strategieSectionSetupsAndModels),
    for (final setup in setups) ...[
      pw.SizedBox(height: 4),
      _setupCardPdf(setup, l),
    ],
    pw.SizedBox(height: 8),
    pw.Text(
      _ascii(l.strategiePdfFooterNote),
      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500, height: 1.3),
    ),
  ];

  final doc = pw.Document(
    title: l.plusMyStrategy,
    author: 'PAYCHEK',
  );
  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 40, 32, 36),
        buildBackground: (ctx) => pw.Container(color: PdfColors.grey50),
      ),
      build: (ctx) => body,
    ),
  );
  return doc.save();
}

pw.Widget _riskCell(String label, String value, bool redValue) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          _ascii(label),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey600,
            letterSpacing: 0.4,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          _ascii(value),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: redValue ? _kRed() : PdfColors.grey900,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _setupCardPdf(StrategieSetupCardData s, AppLocalizations l) {
  final blocks = <pw.Widget>[
    pw.Text(
      'SETUP : ${_ascii(s.title).toUpperCase()}',
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey900,
        letterSpacing: 0.4,
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
                _ascii(l.strategiePdfTechnicalContext),
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 4),
              _bulletLine(l.ajouterTradeStrategieSetupTimeframesRow(s.timeframes)),
              _bulletLine(l.ajouterTradeStrategieSetupIndicatorsRow(s.indicateurs)),
              _bulletLine(l.ajouterTradeStrategieSetupPatternRow(s.pattern)),
            ],
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFE8F5E9),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _kGreen()),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _ascii(l.strategiePdfAlertSignal),
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: _kGreen(),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _ascii(s.signalText),
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _kGreen(),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 10),
    pw.Container(height: 1, color: PdfColors.grey300),
    pw.SizedBox(height: 10),
    for (final r in s.ruleBlocks) ...[
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _ascii(r.heading),
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
                letterSpacing: 0.3,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              _ascii(r.body),
              style: const pw.TextStyle(fontSize: 9, height: 1.35),
            ),
          ],
        ),
      ),
    ],
  ];

  return _card(children: blocks);
}

Future<void> exportStrategiePdf(BuildContext context) async {
  try {
    final locale = Localizations.localeOf(context);
    final l = lookupAppLocalizations(locale);
    final bytes = await buildStrategiePdf(locale);
    if (!context.mounted) return;
    final stamp = DateTime.now().toIso8601String().split('T').first;
    final name = '${l.strategiePdfFileNamePrefix}_$stamp.pdf';
    final ok = await pdf_platform.trySaveReportPdfOnPlatform(
      bytes,
      name,
      shareContext: context,
    );
    if (!ok && kDebugMode) {
      debugPrint('exportStrategiePdf: save canceled');
    }
  } catch (e, st) {
    debugPrint('exportStrategiePdf: $e\n$st');
    if (context.mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.strategiePdfExportError('$e'),
            style: const TextStyle(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
