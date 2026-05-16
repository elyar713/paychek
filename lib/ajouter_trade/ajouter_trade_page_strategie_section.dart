import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';

/// Libellé **STRATÉGIE**, ligne de sélection (slot) + menu rétroaction en dessous.
class AjouterTradeStrategieSection extends StatelessWidget {
  const AjouterTradeStrategieSection({
    super.key,
    required this.labelStyle,
    required this.slider,
    required this.strategiePicker,
    required this.feedbackMenu,
  });

  final TextStyle? labelStyle;
  final Widget slider;
  final Widget strategiePicker;
  final Widget feedbackMenu;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Text(
          l.tradeSectionStrategie.toUpperCase(),
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
        const SizedBox(height: 6),
        slider,
        const SizedBox(height: 6),
        strategiePicker,
        const SizedBox(height: 10),
        feedbackMenu,
      ],
    );
  }
}
