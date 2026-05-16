import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../questionnaire/user_capital_scope.dart';
import '../reglage/user_portfolio_scope.dart';
import '../strategie/sections/strategie_gestion_risque_section_display.dart';
import 'ajouter_trade_asset_class.dart';
import 'ajouter_trade_position_sizing.dart';
import 'ajouter_trade_quantite_settings_field_styles.dart';

/// Bloc capital + taille de position suggérée (selon risque % et stop).
class AjouterTradeQuantiteSuggestedSizeBlock extends StatelessWidget {
  const AjouterTradeQuantiteSuggestedSizeBlock({
    super.key,
    required this.marche,
    required this.actif,
    required this.riskPctCtrl,
    required this.stopDistCtrl,
    required this.labelStyle,
    required this.onApplySuggestedLot,
  });

  final AjouterTradeAssetClass marche;
  final String actif;
  final TextEditingController riskPctCtrl;
  final TextEditingController stopDistCtrl;
  final TextStyle labelStyle;
  final ValueChanged<double> onApplySuggestedLot;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        UserCapitalScope.of(context),
        UserPortfolioScope.of(context),
      ]),
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        final store = UserCapitalScope.of(context);
        final pf = UserPortfolioScope.of(context);
        final cap = pf.effectiveCapitalAmount(store);
        final riskPct =
            StrategieGestionRisqueFormat.parseFlexible(riskPctCtrl.text) ??
                1.0;
        final stop =
            StrategieGestionRisqueFormat.parseFlexible(stopDistCtrl.text) ??
                defaultStopDistanceForSizing(marche);
        final suggested = computeSuggestedPositionSize(
          assetClass: marche,
          symbol: actif,
          capitalAmount: cap,
          riskPercent: riskPct,
          stopDistance: stop,
        );
        final unit = suggestedSizeUnitLabel(marche);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (cap != null && cap > 0)
              Text(
                '${l.capitalLabel}: ${StrategieGestionRisqueFormat.formatMoneyTotal(cap)} ${pf.effectiveCurrencySymbol(store)}',
                style: labelStyle.copyWith(
                  fontSize: 10,
                  color: DashboardTokens.muted,
                ),
              )
            else
              Text(
                l.ajouterTradeCapitalRequiredHint,
                style: labelStyle.copyWith(
                  fontSize: 10,
                  color: DashboardTokens.muted,
                ),
              ),
            const SizedBox(height: 8),
            Text(l.labelSuggestedSize, style: labelStyle),
            const SizedBox(height: 4),
            Text(
              suggested != null
                  ? '\u2248 ${StrategieGestionRisqueFormat.formatNumEdit(suggested)} $unit'
                  : '\u2014',
              style: AjouterTradeQuantiteSettingsFieldStyles.valueStyle
                  .copyWith(fontSize: 13),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: suggested == null
                    ? null
                    : () => onApplySuggestedLot(suggested),
                child: Text(
                  l.ajouterTradeFillSuggestedLot,
                  style: TextStyle(
                    color: suggested != null
                        ? DashboardTokens.accent
                        : DashboardTokens.muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Text(
              l.ajouterTradeSizingEstimationFootnote,
              style: labelStyle.copyWith(
                fontSize: 8,
                height: 1.25,
                color: DashboardTokens.muted,
              ),
            ),
          ],
        );
      },
    );
  }
}



