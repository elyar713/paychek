import 'package:flutter/material.dart';

import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';
import '../widgets/analyse_gauge.dart';

class AnalyseReportHeader extends StatelessWidget {
  const AnalyseReportHeader({super.key, required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                snapshot.actif,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AnalyseTokens.matteText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                snapshot.sousTitre,
                style: TextStyle(
                  color: AnalyseTokens.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 76,
          height: 76,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 110,
              height: 110,
              child: AnalyseGauge(
                feuille: snapshot.gaugeFeuille,
                structure: snapshot.gaugeStructure,
                indicators: snapshot.gaugeIndicators,
                smc: snapshot.gaugeSmc,
                impactFeuille: snapshot.gaugeImpactFeuille,
                impactStructure: snapshot.gaugeImpactStructure,
                impactIndicators: snapshot.gaugeImpactIndicators,
                impactSmc: snapshot.gaugeImpactSmc,
                contextEnabled: snapshot.gaugeContextEnabled,
                structureEnabled: snapshot.gaugeStructureEnabled,
                indicatorsEnabled: snapshot.gaugeIndicatorsEnabled,
                smcEnabled: snapshot.gaugeSmcEnabled,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
