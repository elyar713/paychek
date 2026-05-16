import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';

/// Libellé **PLAN D’ANALYSE** + champ déroulant + panneau dessous (comme STRATÉGIE).
class AjouterTradePlanAnalyseSection extends StatelessWidget {
  const AjouterTradePlanAnalyseSection({
    super.key,
    required this.labelStyle,
    required this.slider,
    required this.planPickerTop,
    required this.planPickerBottom,
  });

  final TextStyle? labelStyle;
  final Widget slider;
  final Widget planPickerTop;
  final Widget planPickerBottom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'PLAN D’ANALYSE',
          style: (labelStyle ??
                  const TextStyle(
                    color: DashboardTokens.onMatteEmphasis,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.35,
                  ))
              .copyWith(
            color: DashboardTokens.titleGold,
            fontSize: 9,
            letterSpacing: 0.35,
          ),
        ),
        const SizedBox(height: 4),
        slider,
        const SizedBox(height: 4),
        planPickerTop,
        const SizedBox(height: 6),
        planPickerBottom,
      ],
    );
  }
}
