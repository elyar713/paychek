import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';

/// Une cellule libellé + pourcentage + [Slider] 0–100 % (discipline / page Ajouter trade).
class AjouterTradePercentSliderCell extends StatelessWidget {
  const AjouterTradePercentSliderCell({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final sliderTheme = SliderThemeData(
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      activeTrackColor: DashboardTokens.accent,
      inactiveTrackColor: DashboardTokens.cardBoxBorder,
      thumbColor: DashboardTokens.accent,
      overlayColor: DashboardTokens.accent.withValues(alpha: 0.18),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (label.trim().isNotEmpty)
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardTokens.labelGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 9.5,
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                ),
              )
            else
              const Spacer(),
            Text(
              '${value.round()} %',
              style: const TextStyle(
                color: DashboardTokens.onMatteEmphasis,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: sliderTheme,
          child: Slider(
            value: value.clamp(0, 100),
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
