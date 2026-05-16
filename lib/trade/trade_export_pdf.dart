import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/app_localizations.dart';
import '../l10n/checklist_localizations.dart';
import 'trade_session.dart';
import '../ajouter_trade/ajouter_trade_page_non_respect_labels.dart';
import '../ajouter_trade/ajouter_trade_plan_analyse_feedback_items.dart';
import '../analyse/analyse_report_pdf_platform.dart' as pdf_platform;
import '../checklist/checklist_page_controller.dart';
import '../etat_mental/mental_state_controller.dart';
import 'trade_models.dart';

String _safePdfFileName(TradeListItem t) {
  final raw = 'trade_${t.pair}_${t.id}'.trim();
  final cleaned = raw.replaceAll(RegExp(r'[<>:"/\\|?*\n\r]'), '_');
  final base = cleaned.length > 72 ? cleaned.substring(0, 72) : cleaned;
  return '${base.isEmpty ? 'trade' : base}.pdf';
}

String _t(String? v) {
  final x = v?.trim() ?? '';
  // Ã‰vite les caractÃ¨res Unicode non supportÃ©s par la police PDF par dÃ©faut
  // (sinon Ã§a affiche un "X" dans un carrÃ©).
  var s = x.isEmpty ? '-' : x;
  // Puces / apostrophes typographiques frÃ©quentes.
  s = s.replaceAll('â€¢', '-');
  s = s.replaceAll('â€™', "'");
  s = s.replaceAll('â€“', '-').replaceAll('â€”', '-');
  // Accents FR courants -> ASCII simple (robuste sans police custom).
  const map = <String, String>{
    'Ã©': 'e',
    'Ã¨': 'e',
    'Ãª': 'e',
    'Ã«': 'e',
    'Ã‰': 'E',
    'Ãˆ': 'E',
    'ÃŠ': 'E',
    'Ã‹': 'E',
    'Ã ': 'a',
    'Ã¢': 'a',
    'Ã¤': 'a',
    'Ã€': 'A',
    'Ã‚': 'A',
    'Ã„': 'A',
    'Ã¹': 'u',
    'Ã»': 'u',
    'Ã¼': 'u',
    'Ã™': 'U',
    'Ã›': 'U',
    'Ãœ': 'U',
    'Ã®': 'i',
    'Ã¯': 'i',
    'ÃŽ': 'I',
    'Ã': 'I',
    'Ã´': 'o',
    'Ã¶': 'o',
    'Ã”': 'O',
    'Ã–': 'O',
    'Ã§': 'c',
    'Ã‡': 'C',
  };
  map.forEach((k, v) => s = s.replaceAll(k, v));
  return s;
}

pw.Widget _line(String k, String v) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 90,
          child: pw.Text(
            '$k :',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            v,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _pctBar(String label, double pct) {
  final p = (pct / 100.0).clamp(0.0, 1.0);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
          ),
          pw.Text(
            '${pct.round()}%',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Container(
        height: 6,
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Container(
            width: 220 * p,
            height: 6,
            decoration: pw.BoxDecoration(
              color: PdfColors.black,
              borderRadius: pw.BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    ],
  );
}

String _formatHm(DateTime d) {
  String p2(int v) => v.toString().padLeft(2, '0');
  final l = d.toLocal();
  return '${p2(l.hour)}:${p2(l.minute)}';
}

String _formatDuration(AppLocalizations l, DateTime start, DateTime? end) {
  if (end == null) return '-';
  final d = end.difference(start);
  final totalMin = d.inMinutes.abs();
  final hh = totalMin ~/ 60;
  final mm = totalMin % 60;
  if (hh <= 0) return l.tradeDurationMinutes(mm);
  return l.tradeDurationHoursMinutes(hh, mm.toString().padLeft(2, '0'));
}

pw.Widget _sectionTitle(String text) {
  return pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    ),
  );
}

pw.Widget _tagRed(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: pw.BoxDecoration(
      color: PdfColors.red,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
    ),
  );
}

pw.Widget _bullets(String title, Iterable<String> items) {
  final list = items.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (list.isEmpty) return pw.SizedBox.shrink();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey900,
        ),
      ),
      pw.SizedBox(height: 4),
      for (final it in list.take(6))
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Text(
            '- $it',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
          ),
        ),
    ],
  );
}

String _formatDt(DateTime d) {
  String p2(int v) => v.toString().padLeft(2, '0');
  final l = d.toLocal();
  return '${p2(l.day)}/${p2(l.month)}/${l.year} ${p2(l.hour)}:${p2(l.minute)}';
}

List<String> _resolveChecklistNonRespect(
  TradeListItem t,
  ChecklistPageController? checklistController,
  AppLocalizations l,
) {
  final c = checklistController;
  if (c == null) return const <String>[];
  final out = <String>[];
  for (final id in t.checklistNonRespectIds) {
    final parts = id.split(':');
    if (parts.length != 2) continue;
    final sectionId = parts[0];
    final itemId = parts[1];
    for (final s in c.sections) {
      if (s.id != sectionId) continue;
      for (final it in s.items) {
        if (it.id == itemId) {
          out.add(checklistItemLabel(l, itemId, it.label));
          break;
        }
      }
    }
  }
  return out;
}

List<String> _resolveEtatNonRespect(TradeListItem t) {
  final out = <String>[];
  final c = MentalStateController.instance;
  for (final id in t.etatNonRespectIds) {
    final parts = id.split(':');
    if (parts.length != 2) continue;
    final kind = parts[0];
    final key = parts[1];
    if (kind == 'moment') {
      final m = c.moment.where((e) => e.id == key).toList();
      if (m.isNotEmpty) out.add(m.first.label);
      continue;
    }
    if (kind == 'emotion') {
      final e = c.emotions.where((e) => e.id == key).toList();
      if (e.isNotEmpty) out.add(e.first.label);
      continue;
    }
  }
  return out;
}

List<String> _resolveStrategieNonRespect(TradeListItem t, AppLocalizations l) {
  final locale = Locale(l.localeName);
  return t.strategieNonRespectIds
      .map(
        (id) => labelForStrategieNonRespectId(
          id,
          t.strategieTitle,
          l: l,
          locale: locale,
        ),
      )
      .toList();
}

List<String> _resolvePlanNonRespect(TradeListItem t, AppLocalizations l) {
  final report = t.planReport;
  if (report == null) return const <String>[];
  final entries = planAnalyseFeedbackEntriesFor(report, l);
  final rows = entries.whereType<PlanAnalyseFeedbackRow>().toList();
  final out = <String>[];
  for (final id in t.planNonRespectIds) {
    final row = rows.where((r) => r.id == id).toList();
    if (row.isEmpty) continue;
    final r = row.first;
    final h = (r.hint ?? '').trim();
    out.add(h.isEmpty ? r.label : '${r.label} : $h');
  }
  return out;
}

Future<Uint8List> buildTradePdf(
  TradeListItem t, {
  required AppLocalizations l,
  ChecklistPageController? checklistController,
}) async {
  final doc = pw.Document(title: 'Trade ${t.pair}', author: 'Paychek');

  Uint8List? screenshotBytes;
  if (kIsWeb) {
    screenshotBytes = t.screenshotBytes;
  } else {
    final sp = t.screenshotPath;
    if (sp != null && sp.trim().isNotEmpty) {
      try {
        screenshotBytes = await File(sp).readAsBytes();
      } catch (_) {
        screenshotBytes = null;
      }
    }
  }

  final side = t.breakeven
      ? l.tradeSideBreakevenShort
      : (t.side == TradeSide.achat
            ? l.tradeSideBuyShort
            : l.tradeSideSellShort);
  final sortieLabel = t.sortieAt == null
      ? l.tradePdfPositionOpen
      : l.tradePdfCloture;
  final entreeHm = _formatHm(t.entreeAt);
  final sortieHm = t.sortieAt == null ? '-' : _formatHm(t.sortieAt!);
  final duree = _formatDuration(l, t.entreeAt, t.sortieAt);
  final session = tradeSessionLabel(l, tradeSessionBucketId(t.entreeAt));
  final nonPlan = _resolvePlanNonRespect(t, l);
  final nonChecklist = _resolveChecklistNonRespect(t, checklistController, l);
  final nonStrategie = _resolveStrategieNonRespect(t, l);
  final nonEtat = _resolveEtatNonRespect(t);

  // Page 1 : rÃ©sumÃ© (toujours).
  doc.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(24),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              color: PdfColors.black,
              child: pw.Text(
                _t(l.tradePdfDetailsTitle(t.pair)),
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
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
                        _t(t.pair),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _t(l.tradePdfDatePrefix(_formatDt(t.entreeAt))),
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    side,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      t.amountLabel,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: t.gainAmount < 0
                            ? PdfColors.red
                            : PdfColors.green,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      sortieLabel,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _pctBar(
                          _t(l.tradeLabelChecklist),
                          t.checklistPct,
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: _pctBar(_t(l.tradeLabelPlan), t.planPct),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _pctBar(
                          _t(l.tradeLabelStrategie),
                          t.strategiePct,
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: _pctBar(_t(l.tradeLabelEtat), t.etatPct),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _line(_t(l.tradeLabelDuration), duree),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: _line(_t(l.tradeLabelSession), session),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  _line(_t(l.tradeLabelHours), '$entreeHm -> $sortieHm'),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _line(
                          _t(l.tradeLabelEntry),
                          _t(t.prixEntreeLabel),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: _line(
                          _t(l.tradeLabelExit),
                          _t(t.prixSortieLabel),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  _line(
                    _t(l.ajouterTradeCommissionFeesLabel),
                    '${t.commissionAmount.toStringAsFixed(2).replaceAll('.', ',')}\$',
                  ),
                  if (t.avantNews || t.apresNews) ...[
                    pw.SizedBox(height: 4),
                    _line(
                      _t(l.tradeLabelNews),
                      _t([
                        if (t.avantNews) l.ajouterTradeCheckboxAvantNews,
                        if (t.apresNews) l.ajouterTradeCheckboxApresNews,
                      ].join(', ')),
                    ),
                  ],
                ],
              ),
            ),
            if (t.psychTags.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              _line(_t(l.tradePdfTags), _t(t.psychTags.join(', '))),
            ],
            pw.SizedBox(height: 14),
            _sectionTitle(_t(l.tradePdfAnalysePostTrade)),
            pw.SizedBox(height: 6),
            _tagRed(_t(l.tradePdfNonRespecte)),
            pw.SizedBox(height: 10),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: _bullets(_t(l.tradeSectionPlan), nonPlan)),
                pw.SizedBox(width: 14),
                pw.Expanded(
                  child: _bullets(_t(l.tradeSectionChecklist), nonChecklist),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _bullets(_t(l.tradeSectionStrategie), nonStrategie),
                ),
                pw.SizedBox(width: 14),
                pw.Expanded(
                  child: _bullets(_t(l.tradePdfEtatPsychologique), nonEtat),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  // Page 2 : screenshot seulement si prÃ©sent.
  if (screenshotBytes != null) {
    doc.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                _t(l.tradePdfScreenshotTitle(t.pair)),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.ClipRRect(
                horizontalRadius: 10,
                verticalRadius: 10,
                child: pw.Container(
                  height: 520,
                  color: PdfColors.grey200,
                  child: pw.Image(
                    pw.MemoryImage(screenshotBytes!),
                    fit: pw.BoxFit.cover,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  return doc.save();
}

// ignore: unused_element
String _safeTimeframePdfFileName(String rawBase) {
  final cleaned = rawBase.trim().replaceAll(RegExp(r'[<>:"/\\|?*\n\r]'), '_');
  final base = cleaned.length > 72 ? cleaned.substring(0, 72) : cleaned;
  return '${base.isEmpty ? 'trades' : base}.pdf';
}

pw.Widget _kv(String k, String v) => _line(k, v);

pw.Widget _kvColored(String k, String v, PdfColor vColor) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 90,
          child: pw.Text(
            '$k :',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            v,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: vColor,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _tradeMiniRow(TradeListItem t, AppLocalizations l) {
  final side = t.breakeven
      ? 'BE'
      : (t.side == TradeSide.achat ? l.tradeSideBuyLong : l.tradeSideSellLong);
  final session = tradeSessionLabel(l, tradeSessionBucketId(t.entreeAt));
  final when = _formatDt(t.entreeAt);
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                '${_t(t.pair)} - ${_t(side)}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey900,
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              '${t.gainAmount >= 0 ? '+' : ''}${t.gainAmount.toStringAsFixed(2)}\$',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: t.gainAmount < 0 ? PdfColors.red : PdfColors.green,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          '${_t(when)} · ${_t(session)}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    ),
  );
}

pw.Widget _weekBarsPdf(List<double> bars, {List<String>? dayLabels}) {
  if (bars.isEmpty) return pw.SizedBox.shrink();
  final maxAbs = bars
      .map((e) => e.abs())
      .fold<double>(0.0, (a, b) => a > b ? a : b);
  final denom = maxAbs <= 1e-9 ? 1.0 : maxAbs;
  const h = 28.0;
  final labels = (dayLabels != null && dayLabels.length == bars.length)
      ? dayLabels
      : null;
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            for (final v in bars)
              pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 1.5),
                  height: (h * (v.abs() / denom)).clamp(2.0, h),
                  decoration: pw.BoxDecoration(
                    color: v < 0
                        ? PdfColors.red
                        : (v == 0 ? PdfColors.grey400 : PdfColors.green),
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
        if (labels != null) ...[
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              for (final lab in labels)
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(
                      _t(lab),
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    ),
  );
}

pw.Widget _sparklinePdf(List<double> cumulative) {
  if (cumulative.length < 2) return pw.SizedBox.shrink();
  final neutral = cumulative.every((e) => e.abs() < 1e-6);
  final last = cumulative.isEmpty ? 0.0 : cumulative.last;
  final lineColor = neutral
      ? PdfColors.grey600
      : (last >= 0 ? PdfColors.green : PdfColors.red);
  const h = 32.0;
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.SizedBox(height: h, child: _sparklineSvg(cumulative, lineColor)),
  );
}

pw.Widget _sparklineSvg(List<double> values, PdfColor color) {
  if (values.length < 2) return pw.SizedBox.shrink();
  final minV = values.fold<double>(values.first, (a, b) => a < b ? a : b);
  final maxV = values.fold<double>(values.first, (a, b) => a > b ? a : b);
  final range = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);
  const w = 260.0;
  const h = 32.0;
  final dx = w / (values.length - 1);

  String yOf(double v) {
    final t = (v - minV) / range;
    final y = h - (t * h);
    return y.toStringAsFixed(2);
  }

  final sb = StringBuffer();
  for (var i = 0; i < values.length; i++) {
    final x = (dx * i).toStringAsFixed(2);
    final y = yOf(values[i]);
    sb.write(i == 0 ? 'M $x $y' : ' L $x $y');
  }

  final svg =
      '''
<svg xmlns="http://www.w3.org/2000/svg" width="$w" height="$h" viewBox="0 0 $w $h">
  <path d="${sb.toString()}" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  return pw.DefaultTextStyle(
    style: pw.TextStyle(color: color),
    child: pw.SvgImage(svg: svg),
  );
}

Future<Uint8List> buildTradeTimeframePdf({
  required AppLocalizations l,
  required String title,
  required String rangeLabel,
  required int count,
  required double net,
  required double avg,
  required double? pct,
  required int winRatePct,
  required double avgChecklist,
  required double avgPlan,
  required double avgStrategie,
  required double avgEtat,
  required int principeCount,
  required int feelingCount,
  required Map<String, int> sessionCounts,
  List<String>? weekDayLabels,
  List<double>? weekBars,
  List<double>? monthSparklineCumulative,
  required List<TradeListItem> trades,
}) async {
  final doc = pw.Document(title: title, author: 'Paychek');

  doc.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(24),
      build: (context) {
        return [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: PdfColors.black,
            child: pw.Text(
              title.toUpperCase(),
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          _kv(_t(l.tradePdfPeriode), _t(rangeLabel)),
          _kv(_t(l.tradePdfTrades), '$count'),
          _kv(
            _t(l.tradePdfGainNet),
            '${net >= 0 ? '+' : ''}${net.toStringAsFixed(2)}\$',
          ),
          _kv(
            _t(l.tradePdfMoyenne),
            '${avg >= 0 ? '+' : ''}${avg.toStringAsFixed(2)}\$',
          ),
          _kvColored(_t(l.tradePdfWinRate), '$winRatePct%', PdfColors.blue),
          if (pct != null)
            _kvColored(
              _t(l.tradePdfImpactCapital),
              '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%',
              PdfColors.green,
            ),
          pw.SizedBox(height: 6),
          _kv(_t(l.tradeMindsetPrinciple), '$principeCount'),
          _kv(_t(l.tradeMindsetFeeling), '$feelingCount'),
          _kv(
            _t(l.tradePdfSessions),
            '${_t(l.tradeSessionAsia)} ${sessionCounts[kTradeSessionAsia] ?? 0} | ${_t(l.tradeSessionEurope)} ${sessionCounts[kTradeSessionEurope] ?? 0} | ${_t(l.tradeSessionUs)} ${sessionCounts[kTradeSessionUs] ?? 0} | ${_t(l.tradeSessionLate)} ${sessionCounts[kTradeSessionLate] ?? 0}',
          ),
          if (weekBars != null && weekBars.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _sectionTitle(_t(l.tradePdfBarresSemaine)),
            pw.SizedBox(height: 4),
            _weekBarsPdf(weekBars, dayLabels: weekDayLabels),
          ],
          if (monthSparklineCumulative != null &&
              monthSparklineCumulative.length >= 2) ...[
            pw.SizedBox(height: 8),
            _sectionTitle(_t(l.tradePdfSparklineMois)),
            pw.SizedBox(height: 4),
            _sparklinePdf(monthSparklineCumulative),
          ],
          pw.SizedBox(height: 10),
          _sectionTitle(_t(l.tradePdfQualiteMoyennes)),
          pw.SizedBox(height: 6),
          _pctBar(_t(l.tradeLabelChecklist), avgChecklist),
          pw.SizedBox(height: 6),
          _pctBar(_t(l.tradeLabelPlan), avgPlan),
          pw.SizedBox(height: 6),
          _pctBar(_t(l.tradeLabelStrategie), avgStrategie),
          pw.SizedBox(height: 6),
          _pctBar(_t(l.tradeLabelEtat), avgEtat),
          pw.SizedBox(height: 14),
          _sectionTitle(_t(l.tradePdfTrades)),
          pw.SizedBox(height: 6),
          if (trades.isEmpty)
            pw.Text('-', style: const pw.TextStyle(fontSize: 10))
          else
            pw.Column(children: [for (final t in trades) _tradeMiniRow(t, l)]),
        ];
      },
    ),
  );

  return doc.save();
}

Future<void> exportTradeTimeframePdf(
  BuildContext context, {
  required Uint8List bytes,
  required String filename,
}) async {
  try {
    final ok = await pdf_platform.trySaveReportPdfOnPlatform(bytes, filename);
    if (!ok && context.mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.exportPdfUnavailable)));
    }
  } catch (e, st) {
    debugPrint('exportTradeTimeframePdf failed: $e\n$st');
    if (!context.mounted) return;
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          kDebugMode ? l.exportPdfFailedWithError('$e') : l.exportPdfFailed,
        ),
      ),
    );
  }
}

Future<void> exportTradePdf(
  BuildContext context,
  TradeListItem t, {
  ChecklistPageController? checklistController,
}) async {
  try {
    final l = AppLocalizations.of(context)!;
    final bytes = await buildTradePdf(
      t,
      l: l,
      checklistController: checklistController,
    );
    final ok = await pdf_platform.trySaveReportPdfOnPlatform(
      bytes,
      _safePdfFileName(t),
    );
    if (!ok && context.mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.exportPdfUnavailable)));
    }
  } catch (e, st) {
    debugPrint('exportTradePdf failed: $e\n$st');
    if (!context.mounted) return;
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          kDebugMode ? l.exportPdfFailedWithError('$e') : l.exportPdfFailed,
        ),
      ),
    );
  }
}
