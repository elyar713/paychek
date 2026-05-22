import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../analyse_tokens.dart';

class AnalyseConfidenceSlider extends StatelessWidget {
  const AnalyseConfidenceSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.impactPercent,
    required this.onImpactTap,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int impactPercent;
  final VoidCallback onImpactTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final v = value.clamp(0, 100);
    final band = AnalyseTokens.confidenceColorForPercent(v);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.analyseConfidenceLevelTitle,
                style: AnalyseTokens.labelStyle,
              ),
            ),
            Text(
              '$v%',
              style: TextStyle(
                color: band,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            inactiveTrackColor: AnalyseTokens.nightBorder,
            activeTrackColor: band,
            thumbColor: Colors.white,
            overlayColor: band.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: v.toDouble(),
            min: 0,
            max: 100,
            onChanged: (d) => onChanged(d.round()),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(l.analyseConfidenceLow, style: TextStyle(color: AnalyseTokens.muted2, fontSize: 10)),
            const Spacer(),
            InkWell(
              onTap: onImpactTap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.settings, size: 12, color: AnalyseTokens.muted2),
                    const SizedBox(width: 4),
                    Text(
                      l.analyseImpactLine(impactPercent.clamp(0, 100)),
                      style: TextStyle(
                        color: AnalyseTokens.muted2,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Text(l.analyseConfidenceHigh, style: TextStyle(color: AnalyseTokens.muted2, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}




