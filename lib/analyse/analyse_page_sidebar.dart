import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_report_snapshot.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_gauge.dart';

/// Panneau droit (synthèse + jauge confiance dans la carte, bouton rapport selon direction).
class AnalysePageEditorSidebar extends StatelessWidget {
  const AnalysePageEditorSidebar({
    super.key,
    required this.controller,
    required this.onGenerateReport,
  });

  final AnalyseController controller;
  final ValueChanged<AnalyseReportSnapshot> onGenerateReport;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = computeAnalyseGlobalConfidencePercent(
          feuille: controller.confidenceFeuille,
          structure: controller.confidenceStructure,
          indicators: controller.confidenceIndicators,
          smc: controller.confidenceSmc,
          impactFeuille: controller.impactFeuille,
          impactStructure: controller.impactStructure,
          impactIndicators: controller.impactIndicators,
          impactSmc: controller.impactSmc,
          contextEnabled: controller.contextEnabled,
          structureEnabled: controller.structureEnabled,
          indicatorsEnabled: controller.indicatorsEnabled,
          smcEnabled: controller.smcEnabled,
        );
        final band = AnalyseTokens.confidenceColorForPercent(p);
        final (btnBg, btnFg) =
            AnalyseTokens.reportPrimaryButtonColorsForBias(controller.bias);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(AnalyseTokens.radiusCard),
                border: Border.all(color: AnalyseTokens.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.analyseSidebarConfidenceSummary,
                    style: AnalyseTokens.labelStyle,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          l.analyseSidebarConfidenceLabel,
                          style: TextStyle(
                            color: AnalyseTokens.muted2,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                      AnalyseGauge(
                        feuille: controller.confidenceFeuille,
                        structure: controller.confidenceStructure,
                        indicators: controller.confidenceIndicators,
                        smc: controller.confidenceSmc,
                        impactFeuille: controller.impactFeuille,
                        impactStructure: controller.impactStructure,
                        impactIndicators: controller.impactIndicators,
                        impactSmc: controller.impactSmc,
                        contextEnabled: controller.contextEnabled,
                        structureEnabled: controller.structureEnabled,
                        indicatorsEnabled: controller.indicatorsEnabled,
                        smcEnabled: controller.smcEnabled,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: p / 100.0,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF1E1E1E),
                      valueColor: AlwaysStoppedAnimation<Color>(band),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        l.analyseConfidenceLow,
                        style: TextStyle(
                          color: AnalyseTokens.muted2,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l.analyseConfidenceHigh,
                        style: TextStyle(
                          color: AnalyseTokens.muted2,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: btnBg,
                  foregroundColor: btnFg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onGenerateReport(
                      AnalyseReportSnapshot.fromController(
                        controller,
                        locale: Localizations.localeOf(context),
                      ),
                    );
                  });
                },
                child: Text(
                  l.analyseReportTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l.analyseSidebarReportHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AnalyseTokens.muted2,
                fontSize: 10,
                height: 1.35,
              ),
            ),
          ],
        );
      },
    );
  }
}
