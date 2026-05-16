import 'package:flutter/material.dart';

import 'analyse_controller.dart';
import 'analyse_report_snapshot.dart';
import 'analyse_tokens.dart';
import 'package:mon_app_finder/l10n/app_localizations.dart';

/// Bouton « Rapport » : génère le snapshot et le remonte au parent.
class AnalyseValiderAnalyseFooter extends StatelessWidget {
  const AnalyseValiderAnalyseFooter({
    super.key,
    required this.controller,
    required this.onValidated,
  });

  final AnalyseController controller;
  final ValueChanged<AnalyseReportSnapshot> onValidated;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final buttonLabel = l.analyseReportTitle;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final (btnBg, btnFg) =
            AnalyseTokens.reportPrimaryButtonColorsForBias(controller.bias);
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            bottom: MediaQuery.viewPaddingOf(context).bottom + 16,
          ),
          child: SizedBox(
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
                  onValidated(
                    AnalyseReportSnapshot.fromController(
                      controller,
                      locale: Localizations.localeOf(context),
                    ),
                  );
                });
              },
              child: Text(
                buttonLabel,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        );
      },
    );
  }
}
