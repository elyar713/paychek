import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../performance/performance_locale_copy.dart';
import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';
import 'analyse_report_structure_ui.dart';
import 'analyse_report_ui_primitives.dart';

class AnalyseReportContexteStructureCard extends StatelessWidget {
  const AnalyseReportContexteStructureCard({super.key, required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final code = l.localeName.toLowerCase();
    String txt(String fr, String en, String es, String de) => performancePickLang(code, fr, en, es, de);
    final showCtx = snapshot.gaugeContextEnabled;
    final showStruct = snapshot.gaugeStructureEnabled;
    if (!showCtx && !showStruct) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];

    if (showCtx) {
      children.addAll([
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                  child: analyseReportBiasPill(context, snapshot),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: AnalyseTokens.muted2,
                ),
                const SizedBox(width: 8),
                Text(
                  snapshot.contexteDateLabel ?? '—',
                  style: AnalyseTokens.inlineMutedStyle,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        analyseReportContexteTfTrendPhaseRow(
          context,
          contexteTfLine: snapshot.contexteTfLine,
          trendLabel: snapshot.trendLabel,
          trendBg: snapshot.trendBg,
          trendFg: snapshot.trendFg,
          phaseLabel: snapshot.phaseLabel,
          phaseBg: snapshot.phaseBg,
          phaseFg: snapshot.phaseFg,
        ),
        for (final copy in snapshot.contexteCopies ?? const []) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AnalyseTokens.cardBorder,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: analyseReportBiasPillFromParts(
              label: copy.biasLabel,
              bg: copy.biasBg,
              fg: copy.biasFg,
            ),
          ),
          const SizedBox(height: 10),
          analyseReportContexteTfTrendPhaseRow(
            context,
            contexteTfLine: copy.contexteTfLine,
            trendLabel: copy.trendLabel,
            trendBg: copy.trendBg,
            trendFg: copy.trendFg,
            phaseLabel: copy.phaseLabel,
            phaseBg: copy.phaseBg,
            phaseFg: copy.phaseFg,
          ),
        ],
        if (snapshot.noteContexte.isNotEmpty) ...[
          const SizedBox(height: 14),
          AnalyseReportNoteBand(text: snapshot.noteContexte),
        ],
      ]);
    }

    if (showCtx && showStruct) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AnalyseTokens.cardBorder,
          ),
        ),
      );
    }

    if (showStruct) {
      children.addAll([
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            Expanded(
              child: analyseReportKv(
                'TIMEFRAME',
                snapshot.structureTf,
                valueBold: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: analyseReportKv(
                  txt('CHARTISME', 'CHART PATTERN', 'PATRÓN', 'CHARTMUSTER'),
                snapshot.chartisme,
                valueBold: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            Expanded(
              child: analyseReportStructureLevelWithTestedBadge(
                label: l.analyseSupport,
                value: snapshot.support,
                valueColor: AnalyseTokens.accentGreen,
                tested: snapshot.structureSupportTested == true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: analyseReportStructureLevelWithTestedBadge(
                label: l.analyseResistShort,
                value: snapshot.resistance,
                valueColor: AnalyseTokens.accentRed,
                tested: snapshot.structureResistanceTested == true,
              ),
            ),
          ],
        ),
        ...analyseReportStructureExtraRowsForLists(
          context,
          snapshot.structureExtraSupports,
          snapshot.structureExtraResistances,
        ),
        for (final copy in snapshot.structureCopies ??
            const <AnalyseReportStructureCopy>[]) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AnalyseTokens.cardBorder,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Expanded(
                child: analyseReportKv(
                  'TIMEFRAME',
                  copy.structureTf,
                  valueBold: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: analyseReportKv(
                  txt('CHARTISME', 'CHART PATTERN', 'PATRÓN', 'CHARTMUSTER'),
                  copy.chartisme,
                  valueBold: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Expanded(
                child: analyseReportStructureLevelWithTestedBadge(
                  label: l.analyseSupport,
                  value: copy.support,
                  valueColor: AnalyseTokens.accentGreen,
                  tested: copy.structureSupportTested,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: analyseReportStructureLevelWithTestedBadge(
                  label: l.analyseResistShort,
                  value: copy.resistance,
                  valueColor: AnalyseTokens.accentRed,
                  tested: copy.structureResistanceTested,
                ),
              ),
            ],
          ),
          ...analyseReportStructureExtraRowsForLists(
            context,
            copy.structureExtraSupports,
            copy.structureExtraResistances,
          ),
        ],
        if (snapshot.noteStructure.isNotEmpty) ...[
          const SizedBox(height: 14),
          AnalyseReportNoteBand(text: snapshot.noteStructure),
        ],
      ]);
    }

    return AnalyseReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
