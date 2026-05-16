import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../analyse/analyse_report_pdf_platform.dart' as pdf_platform;
import '../l10n/app_localizations.dart';
import '../l10n/checklist_localizations.dart';
import 'checklist_page_controller.dart';

/// Texte ASCII pour Helvetica PDF (évite glyphes manquants).
String _ascii(String s) {
  var x = s.trim();
  x = x.replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ');
  x = x.replaceAll('×', 'x');
  x = x.replaceAll('–', '-');
  x = x.replaceAll('—', '-');
  x = x.replaceAll('…', '...');
  x = x.replaceAll('€', 'EUR');
  const map = <String, String>{
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'à': 'a',
    'ù': 'u',
    'ç': 'c',
    'ô': 'o',
    'î': 'i',
    'ï': 'i',
    'É': 'E',
    'À': 'A',
    'È': 'E',
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

Future<Uint8List> buildChecklistPdf(
  Locale locale,
  AppLocalizations l,
  ChecklistPageController controller,
) async {
  final doc = pw.Document();
  final exportDate =
      '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => [
        pw.Text(
          _ascii(l.checklistPageTitle),
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          _ascii('Export $exportDate — ${locale.languageCode}'),
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 16),
        pw.Text(
          _ascii(
            '${controller.checklistCompletionPercent}% '
            '(${controller.checkedItems}/${controller.totalItems} ${l.checklistProgressCl})',
          ),
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
        ),
        pw.SizedBox(height: 14),
        for (final s in controller.sections) ...[
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _ascii(checklistSectionTitle(l, s.id, s.title)),
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 6),
                for (final it in s.items)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      _ascii(
                        '${it.checked ? "[x]" : "[ ]"} '
                        '${checklistItemLabel(l, it.id, it.label)}',
                      ),
                      style: const pw.TextStyle(fontSize: 9, height: 1.35),
                    ),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
        ],
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
