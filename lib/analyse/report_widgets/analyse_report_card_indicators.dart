import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';
import 'analyse_report_ui_primitives.dart';

class AnalyseReportIndicateursCard extends StatelessWidget {
  const AnalyseReportIndicateursCard({super.key, required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (!snapshot.gaugeIndicatorsEnabled) {
      return const SizedBox.shrink();
    }
    return AnalyseReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.analyseCardIndicators,
            style: AnalyseTokens.sectionTitleStyle.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    analyseReportKv(
                      l.analyseTimeframeLabelShort,
                      snapshot.indicatorsTf,
                      valueBold: true,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    analyseReportKv(
                      l.ajouterTradePlanRowOutils.toUpperCase(),
                      snapshot.indicateursOutils,
                      valueBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (snapshot.noteIndicators.isNotEmpty) ...[
            const SizedBox(height: 14),
            AnalyseReportNoteBand(text: snapshot.noteIndicators),
          ],
          for (final copy
              in snapshot.indicatorsCopies ?? const <AnalyseReportIndicatorsCopy>[]) ...[
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      analyseReportKv(
                        l.analyseTimeframeLabelShort,
                        copy.indicatorsTf,
                        valueBold: true,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      analyseReportKv(
                        l.ajouterTradePlanRowOutils.toUpperCase(),
                        copy.indicateursOutils,
                        valueBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (copy.noteIndicators.isNotEmpty) ...[
              const SizedBox(height: 14),
              AnalyseReportNoteBand(text: copy.noteIndicators),
            ],
          ],
        ],
      ),
    );
  }
}
