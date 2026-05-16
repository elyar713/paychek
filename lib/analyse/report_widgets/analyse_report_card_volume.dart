import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';
import 'analyse_report_smc_volume_ui.dart';
import 'analyse_report_ui_primitives.dart';

class AnalyseReportVolumeCard extends StatelessWidget {
  const AnalyseReportVolumeCard({super.key, required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.gaugeVolumeProfileEnabled) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context)!;
    return AnalyseReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.analyseVolumeProfile, style: AnalyseTokens.labelStyle),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: analyseReportVolumeTile(l.analyseVolumePoc, snapshot.poc),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: analyseReportVolumeTile(l.analyseVolumeVah, snapshot.vah),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: analyseReportVolumeTile(l.analyseVolumeVal, snapshot.val),
              ),
            ],
          ),
          if (snapshot.noteVolume.isNotEmpty) ...[
            const SizedBox(height: 14),
            AnalyseReportNoteBand(text: snapshot.noteVolume),
          ],
        ],
      ),
    );
  }
}



