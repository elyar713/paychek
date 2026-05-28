import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../analyse/analyse_report_pdf_platform.dart' as pdf_platform;
import '../l10n/app_localizations.dart';
import '../shared/paychek_pdf_fonts.dart';
import '../shared/paychek_pdf_text.dart';
import 'strategie_export_pdf_icons.dart';
import 'strategie_feedback_reference.dart';
import 'strategie_gestion_risque_storage.dart';
import 'strategie_horaires_sessions_storage.dart';
import 'strategie_mes_regles_storage.dart';
import 'strategie_setups_store.dart';
import 'widgets/strategie_setup_card.dart';
import 'widgets/strategie_setup_rule_styles.dart';
import 'widgets/strategie_setup_tag_format.dart';

// Palette alignée checklist / app Paychek.
final PdfColor _kPrimary = PdfColor.fromHex('0F172A');
final PdfColor _kAccent = PdfColor.fromHex('0D9488');
final PdfColor _kAccentSoft = PdfColor.fromHex('CCFBF1');
final PdfColor _kCardBg = PdfColor.fromHex('F8FAFC');
final PdfColor _kBorder = PdfColor.fromHex('E2E8F0');
final PdfColor _kMuted = PdfColor.fromHex('64748B');
final PdfColor _kGreen = PdfColor.fromHex('15803D');
final PdfColor _kRed = PdfColor.fromHex('DC2626');
final PdfColor _kSignalBg = PdfColor.fromHex('E8F5E9');

pw.Widget _sectionTitle(String t, {required bool koPrimary}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10, top: 6),
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
          child: PaychekPdfFonts.text(
            t.toUpperCase(),
            preferHangulPrimary: koPrimary,
            fontSize: 10,
            bold: true,
            color: _kPrimary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _bulletLine(String text, {required bool koPrimary}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PaychekPdfFonts.text(
          '•',
          preferHangulPrimary: koPrimary,
          fontSize: 9,
          bold: true,
          color: _kAccent,
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: PaychekPdfFonts.text(
            text,
            preferHangulPrimary: koPrimary,
            fontSize: 9,
            color: PdfColors.grey800,
            height: 1.35,
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
      border: pw.Border.all(color: _kBorder, width: 0.8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

pw.Widget _tableHeaderCell(String label, {required bool koPrimary}) {
  return PaychekPdfFonts.text(
    label.toUpperCase(),
    preferHangulPrimary: koPrimary,
    fontSize: 7,
    bold: true,
    color: _kMuted,
    letterSpacing: 0.6,
  );
}

String _ruleHeadingForPdf(StrategieSetupRuleBlock r, AppLocalizations l) {
  switch (StrategieSetupRuleStyles.iconKeyForIcon(r.icon)) {
    case 'invalidation':
      return l.strategieRuleInvalidation;
    case 'target':
      return l.strategieRuleTarget;
    case 'management':
      return l.strategieRuleManagement;
    default:
      return l.strategieRuleEntryPrecise;
  }
}

pw.Widget _pdfRuleIcon(Uint8List? bytes) {
  if (bytes != null && bytes.isNotEmpty) {
    return pw.SizedBox(
      width: 18,
      height: 18,
      child: pw.Image(
        pw.MemoryImage(bytes),
        width: 16,
        height: 16,
        fit: pw.BoxFit.contain,
      ),
    );
  }
  return pw.SizedBox(width: 18, height: 18);
}

pw.Widget _ruleBodyPdf(String body, {required bool koPrimary}) {
  final normalized = paychekPdfNormalize(body);
  if (normalized.isEmpty || normalized == '—') {
    return PaychekPdfFonts.text(
      '—',
      preferHangulPrimary: koPrimary,
      fontSize: 9,
      color: PdfColors.grey800,
      height: 1.4,
    );
  }
  final tags = strategieSetupBodyToTags(normalized);
  if (tags.length <= 1) {
    return PaychekPdfFonts.text(
      tags.isEmpty ? normalized : tags.first,
      preferHangulPrimary: koPrimary,
      fontSize: 9,
      color: PdfColors.grey800,
      height: 1.4,
    );
  }
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < tags.length; i++) ...[
        if (i > 0) pw.SizedBox(height: 4),
        _bulletLine('- ${tags[i]}', koPrimary: koPrimary),
      ],
    ],
  );
}

pw.Widget _ruleBlockPdf(
  StrategieSetupRuleBlock r,
  AppLocalizations l, {
  required bool koPrimary,
  required StrategieExportPdfIcons icons,
}) {
  final heading = _ruleHeadingForPdf(r, l);
  final iconBytes = icons.bytesForIcon(r.icon);
  final headingColor = strategiePdfHeadingColor(r.icon);

  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 1),
          child: _pdfRuleIcon(iconBytes),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PaychekPdfFonts.text(
                heading.toUpperCase(),
                preferHangulPrimary: koPrimary,
                fontSize: 7,
                bold: true,
                color: headingColor,
                letterSpacing: 0.4,
              ),
              pw.SizedBox(height: 4),
              _ruleBodyPdf(r.body, koPrimary: koPrimary),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<Uint8List> buildStrategiePdf(Locale locale) async {
  await PaychekPdfFonts.ensureLoaded();
  final ruleIcons = await StrategieExportPdfIcons.load();
  final koPrimary = locale.languageCode == 'ko';
  final l = lookupAppLocalizations(locale);
  final gr = StrategieFeedbackReference.gestionRisque(locale);
  await StrategieSetupsStore.ensureLoaded();
  await StrategieMesReglesStore.ensureLoaded();
  final gestion = await StrategieGestionRisqueStorage.load();
  final sessions = await StrategieHorairesSessionsStorage.load();
  final setups = List<StrategieSetupCardData>.from(StrategieSetupsStore.notifier.value);
  final rules = StrategieMesReglesStore.rulesForLocale(locale);

  final body = <pw.Widget>[
    pw.Center(
      child: PaychekPdfFonts.text(
        l.plusMyStrategy.toUpperCase(),
        preferHangulPrimary: koPrimary,
        fontSize: 20,
        bold: true,
        color: _kPrimary,
        letterSpacing: 1.4,
      ),
    ),
    pw.SizedBox(height: 8),
    pw.Center(
      child: pw.Container(
        width: 48,
        height: 3,
        decoration: pw.BoxDecoration(
          color: _kAccent,
          borderRadius: pw.BorderRadius.circular(2),
        ),
      ),
    ),
    pw.SizedBox(height: 10),
    pw.Center(
      child: PaychekPdfFonts.text(
        l.strategiePdfPlaybookBlurbShort,
        preferHangulPrimary: koPrimary,
        fontSize: 9,
        color: _kMuted,
        height: 1.4,
        textAlign: pw.TextAlign.center,
      ),
    ),
    pw.SizedBox(height: 14),
    pw.Container(height: 1, color: _kBorder),
    pw.SizedBox(height: 16),
    _sectionTitle(l.ajouterTradeStrategieGoldRules, koPrimary: koPrimary),
    _card(
      bg: _kCardBg,
      children: [
        for (var i = 0; i < rules.length; i++) ...[
          if (i > 0) pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _kBorder, width: 0.6),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 24,
                  height: 24,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    color: _kAccent,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: PaychekPdfFonts.text(
                    '${i + 1}',
                    preferHangulPrimary: koPrimary,
                    fontSize: 10,
                    bold: true,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: PaychekPdfFonts.text(
                    rules[i],
                    preferHangulPrimary: koPrimary,
                    fontSize: 9,
                    color: PdfColors.grey800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
    _sectionTitle(l.ajouterTradeStrategieRiskManagement, koPrimary: koPrimary),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _riskCell(
            gr[0].label,
            '${gestion.riskPct}%',
            false,
            koPrimary: koPrimary,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _riskCell(
            gr[1].label,
            '${gestion.lossPct}%',
            true,
            koPrimary: koPrimary,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _riskCell(
            gr[2].label,
            '${gestion.tradesPerDay} ${l.strategieGestionCaptionMaximum}',
            false,
            koPrimary: koPrimary,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _riskCell(
            gr[3].label,
            '1:${gestion.rrRatio.round()} ${l.strategieGestionCaptionMinimum}',
            false,
            koPrimary: koPrimary,
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 14),
    _sectionTitle(l.ajouterTradeStrategieHoursSessions, koPrimary: koPrimary),
    _card(
      bg: _kCardBg,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('E2E8F0'),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: _tableHeaderCell(
                  l.strategiePdfTableSession,
                  koPrimary: koPrimary,
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: _tableHeaderCell(
                  l.strategiePdfTableDescription,
                  koPrimary: koPrimary,
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: _tableHeaderCell(
                  l.strategiePdfTableSchedule,
                  koPrimary: koPrimary,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 6),
        for (final s in sessions) ...[
          pw.Divider(color: _kBorder, height: 1),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: PaychekPdfFonts.text(
                  s.title,
                  preferHangulPrimary: koPrimary,
                  fontSize: 9,
                  bold: true,
                  color: s.isNoTradeZone ? _kRed : _kPrimary,
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: PaychekPdfFonts.text(
                  s.subtitle,
                  preferHangulPrimary: koPrimary,
                  fontSize: 8,
                  color: PdfColors.grey700,
                  height: 1.35,
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: PaychekPdfFonts.text(
                  s.timeDisplay,
                  preferHangulPrimary: koPrimary,
                  fontSize: 9,
                  bold: true,
                  color: s.isNoTradeZone ? _kRed : _kPrimary,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
        ],
      ],
    ),
    _sectionTitle(l.strategieSectionSetupsAndModels, koPrimary: koPrimary),
    for (final setup in setups) ...[
      pw.SizedBox(height: 4),
      _setupCardPdf(setup, l, icons: ruleIcons, koPrimary: koPrimary),
    ],
    pw.SizedBox(height: 10),
    PaychekPdfFonts.text(
      l.strategiePdfFooterNote,
      preferHangulPrimary: koPrimary,
      fontSize: 7,
      color: PdfColors.grey500,
      height: 1.35,
      fontStyle: pw.FontStyle.italic,
    ),
  ];

  final doc = pw.Document(
    title: paychekPdfNormalize(l.plusMyStrategy),
    author: 'PAYCHEK',
    theme: PaychekPdfFonts.theme(),
  );
  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 40, 32, 36),
        theme: PaychekPdfFonts.theme(),
        buildBackground: (ctx) => pw.Container(color: _kCardBg),
      ),
      build: (ctx) => body,
    ),
  );
  return doc.save();
}

pw.Widget _riskCell(
  String label,
  String value,
  bool redValue, {
  required bool koPrimary,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(
        color: redValue ? PdfColor.fromHex('FECACA') : _kBorder,
        width: 0.8,
      ),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        PaychekPdfFonts.text(
          label.toUpperCase(),
          preferHangulPrimary: koPrimary,
          fontSize: 6.5,
          bold: true,
          color: _kMuted,
          letterSpacing: 0.5,
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        PaychekPdfFonts.text(
          value,
          preferHangulPrimary: koPrimary,
          fontSize: 12,
          bold: true,
          color: redValue ? _kRed : _kPrimary,
          textAlign: pw.TextAlign.center,
        ),
      ],
    ),
  );
}

pw.Widget _setupCardPdf(
  StrategieSetupCardData s,
  AppLocalizations l, {
  required StrategieExportPdfIcons icons,
  required bool koPrimary,
}) {
  final blocks = <pw.Widget>[
    pw.Row(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: pw.BoxDecoration(
            color: _kAccentSoft,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: PaychekPdfFonts.text(
            'SETUP',
            preferHangulPrimary: koPrimary,
            fontSize: 7,
            bold: true,
            color: _kAccent,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: PaychekPdfFonts.text(
            paychekPdfNormalize(s.title).toUpperCase(),
            preferHangulPrimary: koPrimary,
            fontSize: 11,
            bold: true,
            color: _kPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PaychekPdfFonts.text(
                l.strategiePdfTechnicalContext.toUpperCase(),
                preferHangulPrimary: koPrimary,
                fontSize: 7,
                bold: true,
                color: _kMuted,
                letterSpacing: 0.5,
              ),
              pw.SizedBox(height: 6),
              _bulletLine(
                l.ajouterTradeStrategieSetupTimeframesRow(s.timeframes),
                koPrimary: koPrimary,
              ),
              _bulletLine(
                l.ajouterTradeStrategieSetupIndicatorsRow(s.indicateurs),
                koPrimary: koPrimary,
              ),
              _bulletLine(
                l.ajouterTradeStrategieSetupPatternRow(s.pattern),
                koPrimary: koPrimary,
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _kSignalBg,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _kGreen, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                PaychekPdfFonts.text(
                  l.strategiePdfAlertSignal.toUpperCase(),
                  preferHangulPrimary: koPrimary,
                  fontSize: 7,
                  bold: true,
                  color: _kGreen,
                  letterSpacing: 0.4,
                ),
                pw.SizedBox(height: 6),
                PaychekPdfFonts.text(
                  s.signalText,
                  preferHangulPrimary: koPrimary,
                  fontSize: 9,
                  bold: true,
                  color: _kGreen,
                  height: 1.35,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 10),
    pw.Container(height: 1, color: _kBorder),
    pw.SizedBox(height: 10),
    pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('F1F5F9'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < s.ruleBlocks.length; i++) ...[
            if (i > 0) pw.SizedBox(height: 6),
            _ruleBlockPdf(
              s.ruleBlocks[i],
              l,
              koPrimary: koPrimary,
              icons: icons,
            ),
          ],
        ],
      ),
    ),
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
