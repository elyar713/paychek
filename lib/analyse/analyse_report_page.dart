import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_report_snapshot.dart';
import 'analyse_report_widgets.dart';
import 'analyse_tokens.dart';

/// Rapport synthétique affiché après validation de l’analyse.
class AnalyseReportPage extends StatelessWidget {
  const AnalyseReportPage({
    super.key,
    required this.snapshot,
  });

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final reportTitle = l.analyseReportTitle;
    final media = MediaQuery.of(context);
    final maxW = math.min(AnalyseTokens.pageMaxWidth, media.size.width);

    return Scaffold(
      backgroundColor: AnalyseTokens.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: AnalyseTokens.zinc500),
                      ),
                      Expanded(
                        child: Text(
                          reportTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AnalyseTokens.matteText,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      AnalyseReportBody(snapshot: snapshot),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
