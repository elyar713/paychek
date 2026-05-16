import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../questionnaire/user_capital_scope.dart';
import '../reglage/user_portfolio_scope.dart';
import '../strategie/sections/strategie_gestion_risque_section_display.dart';
import 'ajouter_trade_asset_class.dart';
import 'ajouter_trade_position_sizing.dart';
import 'ajouter_trade_quantite_settings_field_styles.dart';
import 'ajouter_trade_quantite_settings_suggested_block.dart';
import 'ajouter_trade_lot_presets.dart';
import 'ajouter_trade_lot_quick_chips.dart';
import 'ajouter_trade_widgets.dart';

/// Formulaire du dialogue Â« RÃ©glages position Â» (marchÃ©, actif, risque, lot, prix).
class AjouterTradeQuantiteSettingsForm extends StatelessWidget {
  const AjouterTradeQuantiteSettingsForm({
    super.key,
    required this.marche,
    required this.onMarcheChanged,
    required this.actif,
    required this.actifItems,
    required this.onActifChanged,
    required this.onCustomActifAdded,
    required this.riskPctCtrl,
    required this.stopDistCtrl,
    required this.lotCtrl,
    required this.prixCtrl,
    required this.labelStyle,
    required this.actifLabelStyle,
    required this.onApplySuggestedLot,
    required this.onApplyPressed,
  });

  final AjouterTradeAssetClass marche;
  final ValueChanged<AjouterTradeAssetClass> onMarcheChanged;
  final String actif;
  final List<String> actifItems;
  final ValueChanged<String> onActifChanged;
  final ValueChanged<String> onCustomActifAdded;
  final TextEditingController riskPctCtrl;
  final TextEditingController stopDistCtrl;
  final TextEditingController lotCtrl;
  final TextEditingController prixCtrl;
  final TextStyle labelStyle;
  final TextStyle actifLabelStyle;
  final ValueChanged<double> onApplySuggestedLot;
  final VoidCallback onApplyPressed;

  static const double _fh = AjouterTradeQuantiteSettingsFieldStyles.fieldHeight;
  static const double _r = AjouterTradeQuantiteSettingsFieldStyles.radius;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.labelMarket, style: labelStyle),
          const SizedBox(height: 6),
          Container(
            height: _fh,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: DashboardTokens.scaffoldMatte,
              borderRadius: BorderRadius.circular(_r),
              border: Border.all(
                color: DashboardTokens.cardBoxBorder,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AjouterTradeAssetClass>(
                isExpanded: true,
                value: marche,
                dropdownColor: DashboardTokens.cardBoxBg,
                icon: Icon(
                  Icons.expand_more,
                  color: DashboardTokens.labelGrey,
                ),
                style: AjouterTradeQuantiteSettingsFieldStyles.valueStyle,
                items: [
                  for (final e in AjouterTradeAssetClass.values)
                    DropdownMenuItem(
                      value: e,
                      child: Text(e.label),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) onMarcheChanged(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          AjouterTradeLabeledActifDropdown(
            label: l.labelActif,
            labelStyle: actifLabelStyle,
            value: actif,
            items: actifItems,
            onChanged: onActifChanged,
            onCustomActifAdded: onCustomActifAdded,
          ),
          const SizedBox(height: 12),
          Text(l.labelRiskPct, style: labelStyle),
          const SizedBox(height: 6),
          SizedBox(
            height: _fh,
            child: TextField(
              controller: riskPctCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              textAlign: TextAlign.center,
              style: AjouterTradeQuantiteSettingsFieldStyles.valueStyle,
              cursorColor: DashboardTokens.accent,
              decoration:
                  AjouterTradeQuantiteSettingsFieldStyles.fieldDecoration(
                'ex. 1',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'STOP (${stopFieldHintLabel(marche)})',
            style: labelStyle,
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: _fh,
            child: TextField(
              controller: stopDistCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              textAlign: TextAlign.center,
              style: AjouterTradeQuantiteSettingsFieldStyles.valueStyle,
              cursorColor: DashboardTokens.accent,
              decoration:
                  AjouterTradeQuantiteSettingsFieldStyles.fieldDecoration(
                'ex. ${StrategieGestionRisqueFormat.formatNumEdit(defaultStopDistanceForSizing(marche))}',
              ),
            ),
          ),
          const SizedBox(height: 10),
          AjouterTradeQuantiteSuggestedSizeBlock(
            marche: marche,
            actif: actif,
            riskPctCtrl: riskPctCtrl,
            stopDistCtrl: stopDistCtrl,
            labelStyle: labelStyle,
            onApplySuggestedLot: onApplySuggestedLot,
          ),
          const SizedBox(height: 12),
          Text(l.labelLot, style: labelStyle),
          const SizedBox(height: 6),
          SizedBox(
            height: _fh,
            child: TextField(
              controller: lotCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              textAlign: TextAlign.center,
              style: AjouterTradeQuantiteSettingsFieldStyles.valueStyle,
              cursorColor: DashboardTokens.accent,
              decoration:
                  AjouterTradeQuantiteSettingsFieldStyles.fieldDecoration(
                ajouterTradeLotFieldHint(marche, l),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ajouterTradeLotShortcutsHeading(marche, l),
            style: labelStyle.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: DashboardTokens.onMatteEmphasis,
            ),
          ),
          if (ajouterTradeLotShortcutsSubheading(marche, l) != null) ...[
            const SizedBox(height: 4),
            Text(
              ajouterTradeLotShortcutsSubheading(marche, l)!,
              style: labelStyle.copyWith(
                fontSize: 8,
                height: 1.3,
                color: DashboardTokens.muted,
              ),
            ),
          ],
          const SizedBox(height: 6),
          AjouterTradeLotQuickChips(
            marche: marche,
            onPick: (v) {
              lotCtrl.text = StrategieGestionRisqueFormat.formatNumEdit(v);
            },
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: Listenable.merge([
              UserCapitalScope.of(context),
              UserPortfolioScope.of(context),
            ]),
            builder: (context, _) {
              final capStore = UserCapitalScope.of(context);
              final devise = UserPortfolioScope.of(context)
                  .effectiveCurrencySymbol(capStore);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(l.labelPrice, style: labelStyle),
                  const SizedBox(width: 8),
                  Text(
                    devise,
                    style: labelStyle.copyWith(
                      color: DashboardTokens.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: _fh,
            child: TextField(
              controller: prixCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              textAlign: TextAlign.center,
              style: AjouterTradeQuantiteSettingsFieldStyles.valueStyle,
              cursorColor: DashboardTokens.accent,
              decoration:
                  AjouterTradeQuantiteSettingsFieldStyles.fieldDecoration(
                'ex. 1,0850',
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onApplyPressed,
            style: FilledButton.styleFrom(
              backgroundColor: DashboardTokens.accent,
              foregroundColor: DashboardTokens.onMatteEmphasis,
              disabledBackgroundColor: DashboardTokens.cardBoxBorder,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Appliquer',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



