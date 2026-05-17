import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_models.dart';
import 'analyse_phase_locale.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_equal_chips_row.dart';
import 'widgets/analyse_htf_add_sheet.dart';

List<AnalyseEqualChipOption<ContextePick<AnalyseTimeframe>>> buildHtfChipOptions(
  AnalyseController c,
) {
  return [
    for (final tf in c.htfPillsVisibleOrdered)
      AnalyseEqualChipOption(
        value: ContextePick.enumOf(tf),
        label: ctxLabelHtf(tf),
        accent: AnalyseTokens.chipHtfSelected,
      ),
    for (final s in c.htfCustomLabels)
      AnalyseEqualChipOption(
        value: ContextePick.customLabel(s),
        label: s,
        accent: AnalyseTokens.chipHtfSelected,
      ),
  ];
}

List<AnalyseEqualChipOption<ContextePick<AnalyseLocalTrend>>> buildTrendChipOptions(
  AnalyseController c,
  AppLocalizations l,
) {
  return [
    for (final t in c.trendPillsVisibleOrdered)
      AnalyseEqualChipOption(
        value: ContextePick.enumOf(t),
        label: ctxLabelTrendLocalized(t, l),
        accent: switch (t) {
          AnalyseLocalTrend.haussiere => AnalyseTokens.accentGreen,
          AnalyseLocalTrend.baissiere => AnalyseTokens.accentRed,
          AnalyseLocalTrend.range => AnalyseTokens.accentAmber,
        },
      ),
    for (final s in c.trendCustomLabels)
      AnalyseEqualChipOption(
        value: ContextePick.customLabel(s),
        label: s,
        accent: AnalyseTokens.accentAmber,
      ),
  ];
}

List<AnalyseEqualChipOption<ContextePick<AnalysePhase>>> buildPhaseChipOptions(
  AnalyseController c,
  Locale locale,
) {
  return [
    for (final p in c.phasePillsVisibleOrdered)
      AnalyseEqualChipOption(
        value: ContextePick.enumOf(p),
        label: ctxLabelPhase(p, locale),
        accent: AnalyseTokens.chipPhaseSelected,
      ),
    for (final s in c.phaseCustomLabels)
      AnalyseEqualChipOption(
        value: ContextePick.customLabel(s),
        label: s,
        accent: AnalyseTokens.chipPhaseSelected,
      ),
  ];
}

List<AnalyseEqualChipOption<ContextePick<AnalyseTimeframe>>> snapshotHtfChipOptions(
  AnalyseContexteTendanceSnapshot s,
) {
  return [
    for (final tf in AnalyseTimeframe.values
        .where((e) => s.htfVisibleEnums.contains(e)))
      AnalyseEqualChipOption(
        value: ContextePick.enumOf(tf),
        label: ctxLabelHtf(tf),
        accent: AnalyseTokens.chipHtfSelected,
      ),
    for (final label in s.htfCustomLabels)
      AnalyseEqualChipOption(
        value: ContextePick.customLabel(label),
        label: label,
        accent: AnalyseTokens.chipHtfSelected,
      ),
  ];
}

List<AnalyseEqualChipOption<ContextePick<AnalyseLocalTrend>>> snapshotTrendChipOptions(
  AnalyseContexteTendanceSnapshot s,
  AppLocalizations l,
) {
  return [
    for (final t in AnalyseLocalTrend.values
        .where((e) => s.trendVisibleEnums.contains(e)))
      AnalyseEqualChipOption(
        value: ContextePick.enumOf(t),
        label: ctxLabelTrendLocalized(t, l),
        accent: switch (t) {
          AnalyseLocalTrend.haussiere => AnalyseTokens.accentGreen,
          AnalyseLocalTrend.baissiere => AnalyseTokens.accentRed,
          AnalyseLocalTrend.range => AnalyseTokens.accentAmber,
        },
      ),
    for (final label in s.trendCustomLabels)
      AnalyseEqualChipOption(
        value: ContextePick.customLabel(label),
        label: label,
        accent: AnalyseTokens.accentAmber,
      ),
  ];
}

List<AnalyseEqualChipOption<ContextePick<AnalysePhase>>> snapshotPhaseChipOptions(
  AnalyseContexteTendanceSnapshot s,
  Locale locale,
) {
  return [
    for (final p
        in AnalysePhase.values.where((e) => s.phaseVisibleEnums.contains(e)))
      AnalyseEqualChipOption(
        value: ContextePick.enumOf(p),
        label: ctxLabelPhase(p, locale),
        accent: AnalyseTokens.chipPhaseSelected,
      ),
    for (final label in s.phaseCustomLabels)
      AnalyseEqualChipOption(
        value: ContextePick.customLabel(label),
        label: label,
        accent: AnalyseTokens.chipPhaseSelected,
      ),
  ];
}

String ctxLabelTrend(AnalyseLocalTrend t) => switch (t) {
      AnalyseLocalTrend.haussiere => 'Haussi\u00e8re',
      AnalyseLocalTrend.baissiere => 'Baissi\u00e8re',
      AnalyseLocalTrend.range => 'Range',
    };

String ctxLabelTrendLocalized(AnalyseLocalTrend t, AppLocalizations l) =>
    switch (t) {
      AnalyseLocalTrend.haussiere =>
        l.localeName.startsWith('fr')
            ? 'Haussi\u00e8re'
            : (l.localeName.startsWith('es')
                ? 'Alcista'
                : (l.localeName.startsWith('de')
                    ? 'Bullisch'
                    : (l.localeName.startsWith('pt') ? 'Alta' : 'Bullish'))),
      AnalyseLocalTrend.baissiere =>
        l.localeName.startsWith('fr')
            ? 'Baissi\u00e8re'
            : (l.localeName.startsWith('es')
                ? 'Bajista'
                : (l.localeName.startsWith('de')
                    ? 'B\u00e4risch'
                    : (l.localeName.startsWith('pt') ? 'Baixa' : 'Bearish'))),
      AnalyseLocalTrend.range =>
        l.localeName.startsWith('fr')
            ? 'Range'
            : (l.localeName.startsWith('es')
                ? 'Rango'
                : (l.localeName.startsWith('de')
                    ? 'Seitw\u00e4rts'
                    : (l.localeName.startsWith('pt') ? 'Lateral' : 'Ranging'))),
    };

String ctxLabelPhase(AnalysePhase p, Locale locale) =>
    analysePhaseLabelForLocale(p, locale);

Future<AnalyseHtfAddChoice?> showAnalyseContexteAddHtfSheet(
  BuildContext context, {
  required List<AnalyseTimeframe> hiddenEnums,
  required Set<String> visibleLabels,
}) {
  return showAnalyseHtfAddSheet(
    context,
    hiddenEnums: hiddenEnums,
    visibleLabels: visibleLabels,
  );
}

Future<AnalyseLocalTrend?> showAnalyseContexteHiddenTrendSheet(
  BuildContext context,
  List<AnalyseLocalTrend> hidden,
) {
  return showModalBottomSheet<AnalyseLocalTrend>(
    context: context,
    backgroundColor: const Color(0xFF141414),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetCtx) {
      final l = AppLocalizations.of(sheetCtx)!;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                l.analyseAddTrendTitle,
                style: AnalyseTokens.labelStyle.copyWith(fontSize: 13),
              ),
            ),
            for (final x in hidden)
              ListTile(
                title: Text(
                  ctxLabelTrendLocalized(x, l),
                  style: const TextStyle(
                    color: Color(0xFFDFDFDF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                onTap: () => Navigator.pop(sheetCtx, x),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<AnalysePhase?> showAnalyseContexteHiddenPhaseSheet(
  BuildContext context,
  List<AnalysePhase> hidden,
) {
  return showModalBottomSheet<AnalysePhase>(
    context: context,
    backgroundColor: const Color(0xFF141414),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetCtx) {
      final l = AppLocalizations.of(sheetCtx)!;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                l.analyseAddPhaseTitle,
                style: AnalyseTokens.labelStyle.copyWith(fontSize: 13),
              ),
            ),
            for (final x in hidden)
              ListTile(
                title: Text(
                  ctxLabelPhase(x, Localizations.localeOf(sheetCtx)),
                  style: const TextStyle(
                    color: Color(0xFFDFDFDF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                onTap: () => Navigator.pop(sheetCtx, x),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}



