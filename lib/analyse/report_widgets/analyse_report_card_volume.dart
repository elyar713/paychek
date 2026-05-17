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
    final s = snapshot;
    final tf = (s.volumeProfileTf ?? '').trim();
    final zoneOn = s.volumeProfileZoneActive == true;
    final zoneFrom = (s.volumeProfileZoneFrom ?? '').trim();
    final zoneTo = (s.volumeProfileZoneTo ?? '').trim();

    return AnalyseReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.analyseVolumeProfile, style: AnalyseTokens.labelStyle),
          if (tf.isNotEmpty && tf != '—') ...[
            const SizedBox(height: 10),
            analyseReportKv(
              l.analyseTimeframeLabelShort,
              tf,
              valueBold: true,
            ),
          ],
          if (zoneOn && (zoneFrom.isNotEmpty || zoneTo.isNotEmpty)) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: analyseReportKv(
                    l.analyseVolumeZoneFrom,
                    zoneFrom.isEmpty ? '—' : zoneFrom,
                    valueBold: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: analyseReportKv(
                    l.analyseVolumeZoneTo,
                    zoneTo.isEmpty ? '—' : zoneTo,
                    valueBold: true,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: analyseReportVolumeTile(l.analyseVolumePoc, s.poc),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: analyseReportVolumeTile(l.analyseVolumeVah, s.vah),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: analyseReportVolumeTile(l.analyseVolumeVal, s.val),
              ),
            ],
          ),
          if (s.noteVolume.isNotEmpty) ...[
            const SizedBox(height: 14),
            AnalyseReportNoteBand(text: s.noteVolume),
          ],
        ],
      ),
    );
  }
}
