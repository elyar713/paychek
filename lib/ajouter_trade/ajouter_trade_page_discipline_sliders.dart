import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_page_percent_slider.dart';

/// Quatre curseurs discipline (checklist, état, stratégie, plan).
class AjouterTradeDisciplineSlidersBlock extends StatelessWidget {
  const AjouterTradeDisciplineSlidersBlock({
    super.key,
    required this.checklistRespectPct,
    required this.etatMomentPct,
    required this.strategieRespectPct,
    required this.planRespectPct,
    required this.onChecklistChanged,
    required this.onEtatChanged,
    required this.onStrategieChanged,
    required this.onPlanChanged,
  });

  final double checklistRespectPct;
  final double etatMomentPct;
  final double strategieRespectPct;
  final double planRespectPct;
  final ValueChanged<double> onChecklistChanged;
  final ValueChanged<double> onEtatChanged;
  final ValueChanged<double> onStrategieChanged;
  final ValueChanged<double> onPlanChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Divider(
          height: 24,
          color: DashboardTokens.cardBoxBorder,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AjouterTradePercentSliderCell(
                label: '',
                value: checklistRespectPct,
                onChanged: onChecklistChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AjouterTradePercentSliderCell(
                label: '',
                value: etatMomentPct,
                onChanged: onEtatChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AjouterTradePercentSliderCell(
                label: l.ajouterTradeDisciplineSliderStrategieRespected,
                value: strategieRespectPct,
                onChanged: onStrategieChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AjouterTradePercentSliderCell(
                label: '',
                value: planRespectPct,
                onChanged: onPlanChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
