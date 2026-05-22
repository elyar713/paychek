import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';

/// Pilule de biais (ACHAT / VENTE / â€¦) pour le rapport.
Widget analyseReportBiasPillFromParts({
  required String label,
  required Color bg,
  required Color fg,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: fg,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 0.6,
      ),
    ),
  );
}

String _txtByLocale(BuildContext context, String fr, String en, String es, String de) {
  final l = AppLocalizations.of(context)!;
  final code = l.localeName.toLowerCase();
  if (code.startsWith('fr')) return fr;
  if (code.startsWith('es')) return es;
  if (code.startsWith('de')) return de;
  return en;
}

String _normalizeBiasForLocale(BuildContext context, String label) {
  final raw = label.trim().toUpperCase();
  if (raw == 'ACHAT' || raw == 'BUY' || raw == 'COMPRA') {
    return _txtByLocale(context, 'ACHAT', 'BUY', 'COMPRA', 'KAUF');
  }
  if (raw == 'VENTE' || raw == 'SELL' || raw == 'VENTA') {
    return _txtByLocale(context, 'VENTE', 'SELL', 'VENTA', 'VERKAUF');
  }
  return _txtByLocale(context, 'À SURVEILLER', 'WATCH', 'VIGILAR', 'BEOBACHTEN');
}

String _normalizeTrendForLocale(BuildContext context, String label) {
  final raw = label.trim().toLowerCase();
  if (raw.contains('hauss') || raw.contains('bullish') || raw.contains('alcista')) {
    return _txtByLocale(context, 'HAUSSIÈRE', 'BULLISH', 'ALCISTA', 'BULLISCH');
  }
  if (raw.contains('baiss') || raw.contains('bearish') || raw.contains('bajista')) {
    return _txtByLocale(context, 'BAISSIÈRE', 'BEARISH', 'BAJISTA', 'BÄRISCH');
  }
  if (raw.contains('range') || raw.contains('ranging') || raw.contains('rango')) {
    return _txtByLocale(context, 'RANGE', 'RANGING', 'RANGO', 'SEITWÄRTS');
  }
  return label;
}

Widget analyseReportBiasPill(BuildContext context, AnalyseReportSnapshot snapshot) {
  return analyseReportBiasPillFromParts(
    label: _normalizeBiasForLocale(context, snapshot.biasLabel),
    bg: snapshot.biasBg,
    fg: snapshot.biasFg,
  );
}

/// Carte dÃ©corÃ©e standard du rapport synthÃ©tique.
class AnalyseReportCard extends StatelessWidget {
  const AnalyseReportCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyseTokens.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

Widget analyseReportKv(
  String label,
  String value, {
  bool valueBold = false,
  Color? valueColor,
  TextAlign textAlign = TextAlign.start,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: AnalyseTokens.labelStyle,
        textAlign: textAlign,
      ),
      const SizedBox(height: 4),
      Text(
        value,
        textAlign: textAlign,
        style: TextStyle(
          color: valueColor ?? AnalyseTokens.matteText,
          fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
          fontSize: valueBold ? 14 : 13,
        ),
      ),
    ],
  );
}

/// Bandeau de note en italique.
class AnalyseReportNoteBand extends StatelessWidget {
  const AnalyseReportNoteBand({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AnalyseTokens.muted,
          fontSize: 12,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }
}

/// TIMEFRAME / TENDANCE / PHASE : une colonne par champ.
Widget analyseReportContexteTfTrendPhaseRow(
  BuildContext context, {
  required String contexteTfLine,
  required String trendLabel,
  required Color trendBg,
  required Color trendFg,
  required String phaseLabel,
  required Color phaseBg,
  required Color phaseFg,
}) {
  final l = AppLocalizations.of(context)!;
  final trendText = _normalizeTrendForLocale(context, trendLabel);
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    textDirection: TextDirection.ltr,
    children: [
      Expanded(
        child: analyseReportKv(
          l.analyseTimeframeLabelShort,
          contexteTfLine,
          valueBold: true,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(l.analyseTrend, style: AnalyseTokens.labelStyle),
            ),
            const SizedBox(height: 4),
            analyseReportContextePill(
              text: trendText,
              bg: trendBg,
              fg: trendFg,
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(l.analysePhase, style: AnalyseTokens.labelStyle),
            ),
            const SizedBox(height: 4),
            analyseReportContextePill(
              text: phaseLabel,
              bg: phaseBg,
              fg: phaseFg,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget analyseReportContextePill({
  required String text,
  required Color bg,
  required Color fg,
}) {
  return SizedBox(
    width: double.infinity,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.4,
        ),
      ),
    ),
  );
}



