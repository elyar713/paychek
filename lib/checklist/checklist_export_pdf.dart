import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../analyse/analyse_report_pdf_platform.dart' as pdf_platform;
import '../l10n/app_localizations.dart';
import '../l10n/checklist_localizations.dart';
import '../performance/performance_locale_copy.dart';
import '../shared/paychek_pdf_fonts.dart';
import '../shared/paychek_pdf_text.dart';
import 'checklist_item_schedule.dart';
import 'checklist_item_schedule_summary.dart';
import 'checklist_page_controller.dart';

// Palette Modern Slate & Teal (alignée sur la maquette LaTeX).
final PdfColor _kPrimary = PdfColor.fromHex('0F172A');
final PdfColor _kAccent = PdfColor.fromHex('0D9488');
final PdfColor _kCardBg = PdfColor.fromHex('F8FAFC');
final PdfColor _kBorder = PdfColor.fromHex('E2E8F0');
final PdfColor _kMuted = PdfColor.fromHex('64748B');

bool _checklistPdfKo = false;

bool _koFor(String text) => _checklistPdfKo || paychekPdfTextHasHangul(text);

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
  final t = paychekPdfNormalize(text);
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

String _cl(
  Locale locale,
  String fr,
  String en,
  String es,
  String de,
  String pt,
  String ko,
) =>
    performancePickLocale(locale, fr, en, es, de, pt, ko);

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
  final t = paychekPdfNormalize(raw).trim();
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
            child: _w(
              'x',
              bold: true,
              fontSize: 7,
              color: PdfColors.white,
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
  final parts = _splitChecklistLabel(label);
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
                        style: PaychekPdfFonts.style(
                          text: '${parts.lead}: ',
                          preferHangulPrimary: _koFor(parts.lead!),
                          fontSize: 9.5,
                          bold: true,
                          color: _kPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                    pw.TextSpan(
                      text: parts.body,
                      style: PaychekPdfFonts.style(
                        text: parts.body,
                        preferHangulPrimary: _koFor(parts.body),
                        fontSize: 9.5,
                        color: PdfColors.grey800,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (scheduleLine != null && scheduleLine.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                _w(scheduleLine, fontSize: 8, color: _kMuted),
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
              _w(title, fontSize: 22, bold: true, color: _kPrimary, letterSpacing: 0.3),
              pw.SizedBox(height: 6),
              _w(exportLine, fontSize: 9, color: _kMuted),
            ],
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _w(progressLabel, fontSize: 8.5, color: _kMuted),
              pw.SizedBox(height: 4),
              _w(progressValue, fontSize: 13, bold: true, color: _kAccent),
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
          child: _w(
            sectionTitle,
            fontSize: 10.5,
            bold: true,
            color: PdfColors.white,
            letterSpacing: 0.4,
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
  final quote = _cl(
    locale,
    '" Plan the trade and trade the plan. " — La discipline surpasse le marché.',
    '" Plan the trade and trade the plan. " — Discipline beats the market.',
    '" Planifica el trade y opera el plan. " — La disciplina supera al mercado.',
    '" Plan the trade and trade the plan. " — Disziplin schlägt den Markt.',
    '" Plan the trade and trade the plan. " — A disciplina supera o mercado.',
    '" 계획대로 매매하라. " — 규율이 시장을 이긴다.',
  );
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 18, bottom: 8),
    child: pw.Center(
      child: _w(
        quote,
        fontSize: 9,
        fontStyle: pw.FontStyle.italic,
        color: _kMuted,
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
  await PaychekPdfFonts.ensureLoaded();
  _checklistPdfKo = locale.languageCode == 'ko';
  final pdfTheme = PaychekPdfFonts.theme();

  final doc = pw.Document(
    title: paychekPdfNormalize(l.checklistPageTitle),
    author: 'Paychek',
    theme: pdfTheme,
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
      if (it.isCompletedForCurrentPeriod(now)) checkedAll++;
    }
  }
  final pctAll = totalAll == 0
      ? 0
      : ((100 * checkedAll) / totalAll).round().clamp(0, 100);

  final headerTitle = _cl(
    locale,
    'CHECKLIST DE TRADING',
    'TRADING CHECKLIST',
    'LISTA DE TRADING',
    'TRADING-CHECKLISTE',
    'CHECKLIST DE TRADING',
    '트레이딩 체크리스트',
  ).toUpperCase();
  final exportLine = _cl(
    locale,
    'Export officiel — $exportDate à $exportTime',
    'Official export — $exportDate at $exportTime',
    'Exportación oficial — $exportDate a las $exportTime',
    'Offizieller Export — $exportDate um $exportTime',
    'Exportação oficial — $exportDate às $exportTime',
    '공식보내기 — $exportDate $exportTime',
  );
  final progressLabel = _cl(
    locale,
    'Progression globale',
    'Overall progress',
    'Progreso global',
    'Gesamtfortschritt',
    'Progresso global',
    '전체 진행률',
  );
  final validatedWord = _cl(
    locale,
    'Validés',
    'Completed',
    'Completados',
    'Erledigt',
    'Concluídos',
    '완료',
  );
  final itemsWord = _cl(
    locale,
    'éléments',
    'items',
    'elementos',
    'Elemente',
    'itens',
    '항목',
  );
  final progressValue =
      '$pctAll% ($checkedAll / $totalAll $validatedWord · $totalAll $itemsWord)';

  final sectionBlocks = <pw.Widget>[];
  var sectionIndex = 0;
  for (final s in controller.sections) {
    if (s.items.isEmpty) continue;

    final allItems = [
      for (final it in s.items)
        (
          label: checklistItemLabel(l, it.id, it.label),
          checked: it.isCompletedForCurrentPeriod(now),
          scheduleLine: checklistItemScheduleSummaryText(
            locale,
            l,
            ChecklistItemSchedule.effectiveSchedule(it.schedule),
          ),
        ),
    ];

    final roman = _romanNumeral(sectionIndex);
    sectionIndex++;
    final title =
        '$roman. ${checklistSectionTitle(l, s.id, s.title).toUpperCase()}';
    sectionBlocks.add(
      _sectionCard(
        sectionTitle: title,
        items: allItems,
        accentHeader: sectionIndex % 2 == 0,
      ),
    );
  }

  final footerStamp = _cl(
    locale,
    'Généré le $exportDate à $exportTime — Paychek',
    'Generated on $exportDate at $exportTime — Paychek',
    'Generado el $exportDate a las $exportTime — Paychek',
    'Erstellt am $exportDate um $exportTime — Paychek',
    'Gerado em $exportDate às $exportTime — Paychek',
    '$exportDate $exportTime 생성 — Paychek',
  );

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 44),
        theme: pdfTheme,
        buildBackground: (ctx) => pw.Container(color: _kCardBg),
      ),
      footer: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _w(footerStamp, fontSize: 7.5, color: _kMuted),
            _w(
              '${ctx.pageNumber} / ${ctx.pagesCount}',
              fontSize: 7.5,
              color: _kMuted,
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
            child: _w(
              _cl(
                locale,
                'Aucun élément dans la checklist.',
                'No checklist items yet.',
                'No hay elementos en la lista.',
                'Keine Checklisten-Einträge.',
                'Nenhum item na checklist.',
                '체크리스트 항목이 없습니다.',
              ),
              fontSize: 10,
              color: _kMuted,
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
