import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_actifs.dart';
import 'ajouter_trade_asset_class.dart';
import 'ajouter_trade_lot_presets.dart';
import 'ajouter_trade_lot_quick_chips.dart';
import 'ajouter_trade_page_format.dart';
import 'ajouter_trade_widgets.dart';
import '../strategie/sections/strategie_gestion_risque_section_display.dart';

/// Carte : marché, actif, quantité, entrée/sortie, breakeven / position.
class AjouterTradeInstrumentCard extends StatelessWidget {
  const AjouterTradeInstrumentCard({
    super.key,
    required this.assetClass,
    required this.actif,
    required this.quantiteController,
    required this.prixPositionController,
    required this.entreeController,
    required this.sortieController,
    required this.entreeDateTime,
    required this.sortieDateTime,
    required this.breakeven,
    required this.positionEnCours,
    required this.avantNews,
    required this.apresNews,
    required this.labelStyle,
    required this.entreeSortieDtStyle,
    required this.checkboxLabelStyle,
    required this.onMarcheChanged,
    required this.onActifChanged,
    this.persistedFavoriteActif,
    this.onPersistFavoriteToggle,
    required this.onBreakevenChanged,
    required this.onPositionEnCoursChanged,
    required this.onAvantNewsChanged,
    required this.onApresNewsChanged,
    required this.requestGainRecalc,
    required this.onOpenAddCustomActif,
    required this.onEntreeDateTimeTap,
    required this.onSortieDateTimeTap,
    required this.entreeDateLayerLink,
    required this.sortieDateLayerLink,
    required this.entreeDateRowKey,
    required this.sortieDateRowKey,
    required this.entreeDatePickerOpen,
    required this.sortieDatePickerOpen,
    this.cardDecoration,
  });

  /// Si non null, remplace [DashboardTokens.cardBoxDecoration] (ex. shell web).
  final BoxDecoration? cardDecoration;

  final AjouterTradeAssetClass assetClass;
  final String actif;
  final TextEditingController quantiteController;
  final TextEditingController prixPositionController;
  final TextEditingController entreeController;
  final TextEditingController sortieController;
  final DateTime entreeDateTime;
  final DateTime sortieDateTime;
  final bool breakeven;
  final bool positionEnCours;
  final bool avantNews;
  final bool apresNews;
  final TextStyle? labelStyle;
  final TextStyle? entreeSortieDtStyle;
  final TextStyle? checkboxLabelStyle;

  final ValueChanged<AjouterTradeAssetClass> onMarcheChanged;
  final ValueChanged<String> onActifChanged;
  final String? persistedFavoriteActif;
  final void Function(String symbol, {required bool add})? onPersistFavoriteToggle;
  final ValueChanged<bool> onBreakevenChanged;
  final ValueChanged<bool> onPositionEnCoursChanged;
  final ValueChanged<bool> onAvantNewsChanged;
  final ValueChanged<bool> onApresNewsChanged;
  final VoidCallback requestGainRecalc;
  final VoidCallback onOpenAddCustomActif;
  final VoidCallback onEntreeDateTimeTap;
  final VoidCallback onSortieDateTimeTap;
  final LayerLink entreeDateLayerLink;
  final LayerLink sortieDateLayerLink;
  final GlobalKey entreeDateRowKey;
  final GlobalKey sortieDateRowKey;
  final bool entreeDatePickerOpen;
  final bool sortieDatePickerOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    return Container(
      padding: DashboardTokens.cardPadding,
      decoration: cardDecoration ?? DashboardTokens.cardBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AjouterTradeAssetClassTrack(
            value: assetClass,
            onSelected: (v) {
              onMarcheChanged(v);
              requestGainRecalc();
            },
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AjouterTradeLabeledActifDropdown(
                  label: l.ajouterTradeFieldActif,
                  labelStyle: labelStyle,
                  value: actif,
                  items: ajouterTradeActifsPour(assetClass, locale: locale),
                  onChanged: (v) {
                    onActifChanged(v);
                    requestGainRecalc();
                  },
                  persistedFavoriteActif: persistedFavoriteActif,
                  onPersistFavoriteToggle: onPersistFavoriteToggle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AjouterTradeLabeledFieldBox(
                  label: ajouterTradeQuantiteFieldLabel(assetClass, l),
                  controller: quantiteController,
                  hintText: '0',
                  labelStyle: labelStyle,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  fieldHeight: 40,
                  fieldTrailing: IconButton(
                    onPressed: onOpenAddCustomActif,
                    tooltip: '${l.actionAdd} ${l.ajouterTradeFieldActif}',
                    icon: const Icon(
                      Icons.settings_outlined,
                      size: 16,
                      color: DashboardTokens.labelGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ajouterTradeLotShortcutsHeading(assetClass, l),
            style: labelStyle?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: DashboardTokens.onMatteEmphasis,
                ),
          ),
          if (ajouterTradeLotShortcutsSubheading(assetClass, l) != null) ...[
            const SizedBox(height: 4),
            Text(
              ajouterTradeLotShortcutsSubheading(assetClass, l)!,
              style: labelStyle?.copyWith(
                    fontSize: 8,
                    height: 1.3,
                    color: DashboardTokens.muted,
                  ),
            ),
          ],
          const SizedBox(height: 6),
          AjouterTradeLotQuickChips(
            marche: assetClass,
            onPick: (v) {
              quantiteController.text =
                  StrategieGestionRisqueFormat.formatNumEdit(v);
              requestGainRecalc();
            },
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AjouterTradeLabeledFieldBox(
                      label: l.ajouterTradeFieldEntree,
                      controller: entreeController,
                      hintText: '0',
                      labelStyle: labelStyle,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                    ),
                    const SizedBox(
                      height: AjouterTradeDateAndCheckboxColumn.gapAfterField,
                    ),
                    AjouterTradeDateAndCheckboxColumn(
                      dateTimeText: formatAjouterTradeEntreeSortieDateTime(
                        entreeDateTime,
                      ),
                      dateStyle: entreeSortieDtStyle,
                      dateLayerLink: entreeDateLayerLink,
                      dateRowMeasureKey: entreeDateRowKey,
                      highlightDateRow: entreeDatePickerOpen,
                      onDateTimeTap: onEntreeDateTimeTap,
                      checkboxValue: breakeven,
                      onCheckboxChanged: (v) {
                        onBreakevenChanged(v ?? false);
                        requestGainRecalc();
                      },
                      checkboxLabel: l.ajouterTradeCheckboxBreakeven,
                      checkboxLabelStyle: checkboxLabelStyle,
                    ),
                    const SizedBox(height: 4),
                    _MiniCheckboxRow(
                      value: avantNews,
                      onChanged: onAvantNewsChanged,
                      label: l.ajouterTradeCheckboxAvantNews,
                      labelStyle: checkboxLabelStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AbsorbPointer(
                  absorbing: breakeven,
                  child: Opacity(
                    opacity: breakeven ? 0.38 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AjouterTradeLabeledFieldBox(
                          label: l.ajouterTradeFieldSortie,
                          controller: sortieController,
                          hintText: '0',
                          labelStyle: labelStyle,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: AjouterTradeDateAndCheckboxColumn.gapAfterField,
                        ),
                        AjouterTradeDateAndCheckboxColumn(
                          dateTimeText: formatAjouterTradeEntreeSortieDateTime(
                            sortieDateTime,
                          ),
                          dateStyle: entreeSortieDtStyle,
                          dateLayerLink: sortieDateLayerLink,
                          dateRowMeasureKey: sortieDateRowKey,
                          highlightDateRow: sortieDatePickerOpen,
                          onDateTimeTap: onSortieDateTimeTap,
                          checkboxValue: positionEnCours,
                          onCheckboxChanged: (v) {
                            onPositionEnCoursChanged(v ?? false);
                            requestGainRecalc();
                          },
                          checkboxLabel: l.ajouterTradeCheckboxPositionOpen,
                          checkboxLabelStyle: checkboxLabelStyle,
                          alignStart: true,
                        ),
                        const SizedBox(height: 4),
                        _MiniCheckboxRow(
                          value: apresNews,
                          onChanged: onApresNewsChanged,
                          label: l.ajouterTradeCheckboxApresNews,
                          labelStyle: checkboxLabelStyle,
                          alignStart: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            thickness: 1,
            color: DashboardTokens.cardBoxBorder,
          ),
          const SizedBox(height: 6),
          Text(
            l.ajouterTradeEntryExitDateHint,
            textAlign: TextAlign.start,
            style: entreeSortieDtStyle?.copyWith(
                  fontSize: 9.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: DashboardTokens.muted,
                ) ??
                const TextStyle(
                  color: DashboardTokens.muted,
                  fontSize: 9.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniCheckboxRow extends StatelessWidget {
  const _MiniCheckboxRow({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.labelStyle,
    this.alignStart = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final TextStyle? labelStyle;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final ls =
        labelStyle ??
        const TextStyle(
          color: DashboardTokens.labelGrey,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          height: 1.15,
        );

    final row = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: const BorderSide(color: DashboardTokens.cardBoxBorder),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return DashboardTokens.accent;
                  }
                  return null;
                }),
                checkColor: DashboardTokens.onMatteEmphasis,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: ls,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    return Align(
      alignment: alignStart ? Alignment.centerLeft : Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 188),
        child: row,
      ),
    );
  }
}
