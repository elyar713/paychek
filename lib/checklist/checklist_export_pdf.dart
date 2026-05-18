import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../analyse/analyse_report_pdf_platform.dart' as pdf_platform;
import '../l10n/app_localizations.dart';
import '../l10n/checklist_localizations.dart';
import 'checklist_item_schedule.dart';
import 'checklist_item_schedule_summary.dart';
import 'checklist_page_controller.dart';

// Palette Modern Slate & Teal (alignée sur la maquette LaTeX).
final PdfColor _kPrimary = PdfColor.fromHex('0F172A');
final PdfColor _kAccent = PdfColor.fromHex('0D9488');
final PdfColor _kCardBg = PdfColor.fromHex('F8FAFC');
final PdfColor _kBorder = PdfColor.fromHex('E2E8F0');
final PdfColor _kMuted = PdfColor.fromHex('64748B');

/// Texte ASCII pour Helvetica PDF (évite glyphes manquants).
String _ascii(String s) {
  var x = s.trim();
  x = x.replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ');
  x = x.replaceAll('×', 'x');
  x = x.replaceAll('–', '-');
  x = x.replaceAll('—', '-');
  x = x.replaceAll('…', '...');
  x = x.replaceAll('€', 'EUR');
  x = x.replaceAll('«', '"');
  x = x.replaceAll('»', '"');
  const map = <String, String>{
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ô': 'o',
    'ö': 'o',
    'î': 'i',
    'ï': 'i',
    'ç': 'c',
    'É': 'E',
    'È': 'E',
    'À': 'A',
    'Ù': 'U',
    'Ç': 'C',
  };
  final b = StringBuffer();
  for (final ch in x.runes) {
    final c = String.fromCharCode(ch);
    b.write(map[c] ?? c);
  }
  return b.toString();
}

String _pdfCopy(Locale locale, String fr, String en) {
  if (locale.languageCode == 'fr') return fr;
  return en;
}

String _romanNumeral(int index) {
  const vals = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  const syms = [
    'M',
    'CM',
    'D',
    'CD',
    'C',
    'XC',
    'L',
    'XL',
    'X',
    'IX',
    'V',
    'IV',
    'I',
  ];
  var n = index + 1;
  final out = StringBuffer();
  for (var i = 0; i < vals.length; i++) {
    while (n >= vals[i]) {
      out.write(syms[i]);
      n -= vals[i];
    }
  }
  return out.toString();
}

({String? lead, String body}) _splitChecklistLabel(String raw) {
  final t = raw.trim();
  final idx = t.indexOf(':');
  if (idx <= 0 || idx >= t.length - 1) {
    return (lead: null, body: t);
  }
  return (
    lead: t.substring(0, idx).trim(),
    body: t.substring(idx + 1).trim(),
  );
}

pw.Widget _checkboxGlyph({required bool checked}) {
  return pw.Container(
    width: 11,
    height: 11,
    margin: const pw.EdgeInsets.only(top: 1.5),
    decoration: pw.BoxDecoration(
      color: checked ? _kAccent : PdfColors.white,
      border: pw.Border.all(color: _kAccent, width: 1.4),
      borderRadius: pw.BorderRadius.circular(1.5),
    ),
    child: checked
        ? pw.Center(
            child: pw.Text(
              'x',
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          )
        : null,
  );
}

pw.Widget _checklistRow(
  String label, {
  required bool checked,
  String? scheduleLine,
}) {
  final parts = _splitChecklistLabel(_ascii(label));
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _checkboxGlyph(checked: checked),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    if (parts.lead != null) ...[
                      pw.TextSpan(
                        text: '${parts.lead}: ',
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: _kPrimary,
                          lineSpacing: 1.35,
                        ),
                      ),
                    ],
                    pw.TextSpan(
                      text: parts.lead != null ? parts.body : parts.body,
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.grey800,
                        lineSpacing: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (scheduleLine != null && scheduleLine.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  scheduleLine,
                  style: pw.TextStyle(fontSize: 8, color: _kMuted),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _headerCard({
  required String title,
  required String exportLine,
  required String progressLabel,
  required String progressValue,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      border: pw.Border.all(color: _kAccent, width: 1.5),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: _kPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                exportLine,
                style: pw.TextStyle(fontSize: 9, color: _kMuted),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                progressLabel,
                style: pw.TextStyle(fontSize: 8.5, color: _kMuted),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                progressValue,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _kAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _sectionCard({
  required String sectionTitle,
  required List<({String label, bool checked, String? scheduleLine})> items,
  required bool accentHeader,
}) {
  final headerBg = accentHeader ? _kAccent : _kPrimary;
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 14),
    decoration: pw.BoxDecoration(
      color: _kCardBg,
      border: pw.Border.all(color: _kBorder, width: 1),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: pw.BoxDecoration(
            color: headerBg,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(5),
              topRight: pw.Radius.circular(5),
            ),
          ),
          child: pw.Text(
            sectionTitle,
            style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: 0.4,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              for (final it in items)
                _checklistRow(
                  it.label,
                  checked: it.checked,
                  scheduleLine: it.scheduleLine,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _footerQuote(Locale locale) {
  final quote = _pdfCopy(
    locale,
    '" Plan the trade and trade the plan. " -- La discipline surpasse le marche.',
    '" Plan the trade and trade the plan. " -- Discipline beats the market.',
  );
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 18, bottom: 8),
    child: pw.Center(
      child: pw.Text(
        _ascii(quote),
        style: pw.TextStyle(
          fontSize: 9,
          fontStyle: pw.FontStyle.italic,
          color: _kMuted,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

Future<Uint8List> buildChecklistPdf(
  Locale locale,
  AppLocalizations l,
  ChecklistPageController controller,
) async {
  final doc = pw.Document(
    title: _ascii(l.checklistPageTitle),
    author: 'Paychek',
  );
  final now = DateTime.now();
  final localeTag = locale.toString();
  final exportDate = DateFormat.yMMMd(localeTag).format(now);
  final exportTime = DateFormat.Hm(localeTag).format(now);
  var checkedAll = 0;
  var totalAll = 0;
  for (final s in controller.sections) {
    for (final it in s.items) {
      totalAll++;
      if (it.checked) checkedAll++;
    }
  }
  final pctAll = totalAll == 0
      ? 0
      : ((100 * checkedAll) / totalAll).round().clamp(0, 100);

  final headerTitle = _ascii(
    _pdfCopy(
      locale,
      'CHECKLIST DE TRADING',
      'TRADING CHECKLIST',
    ).toUpperCase(),
  );
  final exportLine = _ascii(
    _pdfCopy(
      locale,
      'Export officiel -- $exportDate a $exportTime',
      'Official export -- $exportDate at $exportTime',
    ),
  );
  final progressLabel = _ascii(
    _pdfCopy(locale, 'Progression globale', 'Overall progress'),
  );
  final validatedWord = _pdfCopy(locale, 'Valides', 'Completed');
  final itemsWord = _pdfCopy(locale, 'elements', 'items');
  final progressValue = _ascii(
    '$pctAll% ($checkedAll / $totalAll $validatedWord · $totalAll $itemsWord)',
  );

  final sectionBlocks = <pw.Widget>[];
  var sectionIndex = 0;
  for (final s in controller.sections) {
    if (s.items.isEmpty) continue;

    final allItems = [
      for (final it in s.items)
        (
          label: checklistItemLabel(l, it.id, it.label),
          checked: it.checked,
          scheduleLine: _ascii(
            checklistItemScheduleSummaryText(
              locale,
              l,
              ChecklistItemSchedule.effectiveSchedule(it.schedule),
            ),
          ),
        ),
    ];

    final roman = _romanNumeral(sectionIndex);
    sectionIndex++;
    final title = _ascii(
      '$roman. ${checklistSectionTitle(l, s.id, s.title).toUpperCase()}',
    );
    sectionBlocks.add(
      _sectionCard(
        sectionTitle: title,
        items: allItems,
        accentHeader: sectionIndex % 2 == 0,
      ),
    );
  }

  final footerStamp = _ascii(
    _pdfCopy(
      locale,
      'Genere le $exportDate a $exportTime -- Paychek',
      'Generated on $exportDate at $exportTime -- Paychek',
    ),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 44),
      footer: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              footerStamp,
              style: pw.TextStyle(fontSize: 7.5, color: _kMuted),
            ),
            pw.Text(
              _ascii('${ctx.pageNumber} / ${ctx.pagesCount}'),
              style: pw.TextStyle(fontSize: 7.5, color: _kMuted),
            ),
          ],
        ),
      ),
      build: (ctx) => [
        _headerCard(
          title: headerTitle,
          exportLine: exportLine,
          progressLabel: progressLabel,
          progressValue: progressValue,
        ),
        pw.SizedBox(height: 18),
        ...sectionBlocks,
        if (sectionBlocks.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _kCardBg,
              border: pw.Border.all(color: _kBorder),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              _ascii(
                _pdfCopy(
                  locale,
                  'Aucun element dans la checklist.',
                  'No checklist items yet.',
                ),
              ),
              style: pw.TextStyle(fontSize: 10, color: _kMuted),
            ),
          ),
        _footerQuote(locale),
      ],
    ),
  );

  return doc.save();
}

Future<void> exportChecklistPdf(
  BuildContext context,
  ChecklistPageController controller,
) async {
  try {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final bytes = await buildChecklistPdf(locale, l, controller);
    if (!context.mounted) return;
    final stamp = DateTime.now().toIso8601String().split('T').first;
    final name = 'checklist_$stamp.pdf';
    final ok = await pdf_platform.trySaveReportPdfOnPlatform(
      bytes,
      name,
      shareContext: context,
    );
    if (!ok && kDebugMode) {
      debugPrint('exportChecklistPdf: save canceled');
    }
  } catch (e, st) {
    debugPrint('exportChecklistPdf: $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.tradeExportPdfTooltip}: $e',
            style: const TextStyle(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
