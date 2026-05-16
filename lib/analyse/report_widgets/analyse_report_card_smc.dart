import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';
import 'analyse_report_smc_volume_ui.dart';
import 'analyse_report_ui_primitives.dart';

class AnalyseReportSmcCard extends StatelessWidget {
  const AnalyseReportSmcCard({super.key, required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.gaugeSmcEnabled) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context)!;
    final smcCopies = snapshot.smcCopies ?? const <AnalyseReportSmcCopy>[];
    return AnalyseReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.analyseCardSmcLiquidity,
            style: AnalyseTokens.sectionTitleStyle.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 14),
          analyseReportSmcBlockFields(
            context,
            smcOb: snapshot.smcOb,
            smcFvg: snapshot.smcFvg,
            smcLiq: snapshot.smcLiq,
            smcFibPrice: snapshot.smcFibPrice,
            smcFibOteLabel: snapshot.smcFibOteLabel,
          ),
          if (snapshot.noteSmc.isNotEmpty) ...[
            const SizedBox(height: 14),
            AnalyseReportNoteBand(text: snapshot.noteSmc),
          ],
          for (var i = 0; i < smcCopies.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                thickness: 1,
                color: AnalyseTokens.cardBorder,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AnalyseTokens.smcDuplicateBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.analyseCopyNumber(i + 1),
                      style: AnalyseTokens.inlineMutedStyle,
                    ),
                  ),
                  const SizedBox(height: 10),
                  analyseReportSmcBlockFields(
                    context,
                    smcOb: smcCopies[i].smcOb,
                    smcFvg: smcCopies[i].smcFvg,
                    smcLiq: smcCopies[i].smcLiq,
                    smcFibPrice: smcCopies[i].smcFibPrice,
                    smcFibOteLabel: smcCopies[i].smcFibOteLabel,
                  ),
                  if (smcCopies[i].noteSmc.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    AnalyseReportNoteBand(text: smcCopies[i].noteSmc),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}



