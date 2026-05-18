import 'dart:math' show max;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';
bool _matchesHeld(String raw) {
  final v = raw.trim().toLowerCase();
  for (final code in ['fr', 'en', 'es', 'de', 'pt', 'ko']) {
    final loc = lookupAppLocalizations(Locale(code));
    if (v == loc.analyseExtraHeld.toLowerCase()) return true;
  }
  return v == 'tenu' ||
      v == 'held' ||
      v == 'mantenido' ||
      v == 'gehalten' ||
      v == 'realizado';
}

bool _matchesBroken(String raw) {
  final v = raw.trim().toLowerCase();
  for (final code in ['fr', 'en', 'es', 'de', 'pt', 'ko']) {
    final loc = lookupAppLocalizations(Locale(code));
    if (v == loc.analyseExtraBroken.toLowerCase()) return true;
  }
  return v == 'cassé' ||
      v == 'casse' ||
      v == 'broken' ||
      v == 'roto' ||
      v == 'gebrochen' ||
      v == 'quebrado';
}

String _localizedStateLabel(BuildContext context, String label) {
  final l = AppLocalizations.of(context)!;
  if (_matchesHeld(label)) {
    return l.analyseExtraHeld.toLowerCase();
  }
  if (_matchesBroken(label)) {
    return l.analyseExtraBroken.toLowerCase();
  }
  return label.toLowerCase();
}

String _dashboardHeaderText(String raw, {required bool uppercase}) {
  final t = raw.trim();
  if (t.isEmpty) return t;
  return uppercase ? t.toUpperCase() : t;
}

Widget _dashboardStructureExtraHeader(
  BuildContext context, {
  required String label,
  required AnalyseReportStructureExtraLine line,
  required TextStyle headerStyle,
  required bool uppercaseHeaders,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Flexible(
        child: Text(
          _dashboardHeaderText(label, uppercase: uppercaseHeaders),
          style: headerStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (line.tenueLabel != null) ...[
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _matchesHeld(line.tenueLabel!)
                ? AnalyseTokens.accentGreen.withValues(alpha: 0.14)
                : AnalyseTokens.accentRed.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _localizedStateLabel(context, line.tenueLabel!),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              height: 1.1,
              color: _matchesHeld(line.tenueLabel!)
                  ? AnalyseTokens.accentGreen
                  : AnalyseTokens.accentRed,
            ),
          ),
        ),
      ],
    ],
  );
}

/// Colonne Support/Résistance pour le **dashboard** uniquement :
/// en-têtes sur une ligne, prix sur la ligne suivante (même style) ;
/// S1/R1 à côté du principal ; S2+/R2+ sous la moitié gauche de la colonne.
Widget dashboardStructureLevelColumn({
  required BuildContext context,
  required String mainLabel,
  required String mainValue,
  required TextStyle headerStyle,
  required TextStyle valueStyle,
  required List<AnalyseReportStructureExtraLine> extras,
  required String extraPrefix,
  required Color extraValueColor,
  double headerValueGap = 6,
  bool uppercaseHeaders = true,
}) {
  final first = extras.isNotEmpty ? extras.first : null;
  final below =
      extras.length > 1 ? extras.sublist(1) : const <AnalyseReportStructureExtraLine>[];
  final extraValueStyle = valueStyle.copyWith(color: extraValueColor);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              _dashboardHeaderText(mainLabel, uppercase: uppercaseHeaders),
              style: headerStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (first != null) ...[
            const SizedBox(width: 6),
            Expanded(
              child: _dashboardStructureExtraHeader(
                context,
                label: '${extraPrefix}1',
                line: first,
                headerStyle: headerStyle,
                uppercaseHeaders: uppercaseHeaders,
              ),
            ),
          ],
        ],
      ),
      SizedBox(height: headerValueGap),
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              mainValue,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
          ),
          if (first != null) ...[
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                first.priceLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: extraValueStyle,
              ),
            ),
          ],
        ],
      ),
      for (var i = 0; i < below.length; i++)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _dashboardStructureExtraHeader(
                      context,
                      label: '$extraPrefix${i + 2}',
                      line: below[i],
                      headerStyle: headerStyle,
                      uppercaseHeaders: uppercaseHeaders,
                    ),
                    SizedBox(height: headerValueGap),
                    Text(
                      below[i].priceLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: extraValueStyle,
                    ),
                  ],
                ),
              ),
              if (first != null) const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
    ],
  );
}

/// Ligne Support + Résistance (dashboard) avec extras S/R intégrés.
Widget dashboardStructureSupportResistanceRow({
  required BuildContext context,
  required String supportLabel,
  required String supportValue,
  required String resistLabel,
  required String resistValue,
  required TextStyle headerStyle,
  required TextStyle supportValueStyle,
  required TextStyle resistValueStyle,
  List<AnalyseReportStructureExtraLine>? structureExtraSupports,
  List<AnalyseReportStructureExtraLine>? structureExtraResistances,
  double gap = 10,
  double headerValueGap = 6,
  bool uppercaseHeaders = true,
}) {
  final sup = structureExtraSupports ?? const <AnalyseReportStructureExtraLine>[];
  final res =
      structureExtraResistances ?? const <AnalyseReportStructureExtraLine>[];

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    textDirection: TextDirection.ltr,
    children: [
      Expanded(
        child: dashboardStructureLevelColumn(
          context: context,
          mainLabel: supportLabel,
          mainValue: supportValue,
          headerStyle: headerStyle,
          valueStyle: supportValueStyle,
          extras: sup,
          extraPrefix: 'S',
          extraValueColor: AnalyseTokens.accentGreen,
          headerValueGap: headerValueGap,
          uppercaseHeaders: uppercaseHeaders,
        ),
      ),
      SizedBox(width: gap),
      Expanded(
        child: dashboardStructureLevelColumn(
          context: context,
          mainLabel: resistLabel,
          mainValue: resistValue,
          headerStyle: headerStyle,
          valueStyle: resistValueStyle,
          extras: res,
          extraPrefix: 'R',
          extraValueColor: AnalyseTokens.accentRed,
          headerValueGap: headerValueGap,
          uppercaseHeaders: uppercaseHeaders,
        ),
      ),
    ],
  );
}

List<Widget> analyseReportStructureExtraRowsForLists(
  BuildContext context,
  List<AnalyseReportStructureExtraLine>? supports,
  List<AnalyseReportStructureExtraLine>? resists,
) {
  final sup = supports ?? const <AnalyseReportStructureExtraLine>[];
  final res = resists ?? const <AnalyseReportStructureExtraLine>[];
  if (sup.isEmpty && res.isEmpty) return const [];

  final n = max(sup.length, res.length);
  return [
    for (var i = 0; i < n; i++)
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            Expanded(
              child: i < sup.length
                  ? analyseReportStructureExtraCell(
                      context: context,
                      label: 'S${i + 1}',
                      line: sup[i],
                      valueColor: AnalyseTokens.accentGreen,
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: i < res.length
                  ? analyseReportStructureExtraCell(
                      context: context,
                      label: 'R${i + 1}',
                      line: res[i],
                      valueColor: AnalyseTokens.accentRed,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
  ];
}

Widget analyseReportStructureExtraCell({
  required BuildContext context,
  required String label,
  required AnalyseReportStructureExtraLine line,
  required Color valueColor,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: AnalyseTokens.labelStyle),
          if (line.tenueLabel != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _matchesHeld(line.tenueLabel!)
                    ? AnalyseTokens.accentGreen.withValues(alpha: 0.14)
                    : AnalyseTokens.accentRed.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _localizedStateLabel(context, line.tenueLabel!),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: _matchesHeld(line.tenueLabel!)
                      ? AnalyseTokens.accentGreen
                      : AnalyseTokens.accentRed,
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 4),
      Text(
        line.priceLabel,
        style: TextStyle(
          color: valueColor,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          height: 1.2,
        ),
      ),
    ],
  );
}

/// Ligne SUPPORT / RÉSIST. : prix + badge « x2 » si testé.
Widget analyseReportStructureLevelWithTestedBadge({
  required String label,
  required String value,
  required Color valueColor,
  required bool tested,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: AnalyseTokens.labelStyle),
      const SizedBox(height: 4),
      Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            if (tested) ...[
              const SizedBox(width: 6),
              analyseReportTestedTimesBadge(),
            ],
          ],
        ),
      ),
    ],
  );
}

Widget analyseReportTestedTimesBadge() {
  return Text(
    'x2',
    style: TextStyle(
      color: AnalyseTokens.muted2,
      fontWeight: FontWeight.w600,
      fontSize: 10,
    ),
  );
}
