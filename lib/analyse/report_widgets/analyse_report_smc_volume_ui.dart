import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../analyse_tokens.dart';

Widget analyseReportSmcBlockFields(
  BuildContext context, {
  required String smcOb,
  required String smcFvg,
  required String smcLiq,
  required String smcFibPrice,
  required String smcFibOteLabel,
}) {
  final l = AppLocalizations.of(context)!;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: analyseReportSmcCell(l.analyseReportCellOrderBlock, smcOb),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: analyseReportSmcCell(l.analyseReportCellFvg, smcFvg),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: analyseReportSmcCell(l.analyseReportCellLiqPools, smcLiq),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.analyseFibShort, style: AnalyseTokens.labelStyle),
                const SizedBox(height: 6),
                Text(
                  smcFibPrice,
                  style: const TextStyle(
                    color: AnalyseTokens.accentAmber,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                if (smcFibOteLabel.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        smcFibOteLabel,
                        style: const TextStyle(
                          color: AnalyseTokens.matteText,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

Widget analyseReportSmcCell(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: AnalyseTokens.labelStyle),
      const SizedBox(height: 6),
      Text(
        value,
        style: const TextStyle(
          color: AnalyseTokens.matteText,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    ],
  );
}

Widget analyseReportVolumeTile(String label, String price) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: AnalyseTokens.fieldBg,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: AnalyseTokens.volumeProfileLabelStyle,
        ),
        const SizedBox(height: 6),
        Text(
          price,
          style: const TextStyle(
            color: AnalyseTokens.matteText,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}



