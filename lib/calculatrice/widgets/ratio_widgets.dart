import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ajouter_trade/ajouter_trade_actifs.dart';
import '../../ajouter_trade/ajouter_trade_asset_class.dart';
import '../../ajouter_trade/ajouter_trade_labeled_actif_dropdown.dart';
import '../../dashboard/dashboard_tokens.dart';
import '../calculatrice_format.dart';
import '../calculatrice_models.dart';
import 'calculatrice_common_widgets.dart';

class RatioSection extends StatelessWidget {
  const RatioSection({
    super.key,
    required this.market,
    required this.asset,
    required this.currencySymbol,
    required this.lot,
    required this.entry,
    required this.sl,
    required this.tp,
    required this.error,
    required this.result,
    required this.onChangedMarket,
    required this.onChangedAsset,
    required this.onCalculate,
  });

  final AjouterTradeAssetClass market;
  final String asset;
  final String currencySymbol;
  final TextEditingController lot;
  final TextEditingController entry;
  final TextEditingController sl;
  final TextEditingController tp;
  final String? error;
  final RatioResult? result;
  final ValueChanged<AjouterTradeAssetClass> onChangedMarket;
  final ValueChanged<String> onChangedAsset;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;
    final assets = ajouterTradeActifsPour(
      market,
      locale: Localizations.localeOf(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title: l.calcRatioSectionTitle),
        const SizedBox(height: 10),
        CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MarketPillDropdown(value: market, onChanged: onChangedMarket),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AjouterTradeLabeledActifDropdown(
                      label: l.labelActif,
                      labelStyle: t.labelMedium?.copyWith(
                        color: DashboardTokens.muted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                      value: assets.contains(asset) ? asset : assets.first,
                      items: assets,
                      valueFontSize: 12,
                      onChanged: onChangedAsset,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NumberField(controller: lot, label: l.labelLot, onSubmitted: (_) => onCalculate()),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NumberField(controller: entry, label: l.calcLabelEntry, onSubmitted: (_) => onCalculate()),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: NumberField(controller: sl, label: l.calcLabelSl, onSubmitted: (_) => onCalculate()),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NumberField(controller: tp, label: l.calcLabelTp, onSubmitted: (_) => onCalculate()),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: onCalculate, child: Text(l.calculateRatio)),
              ),
              const SizedBox(height: 12),
              if (error != null)
                Text(error!, style: t.bodyMedium?.copyWith(color: Colors.redAccent))
              else if (result == null)
                Text('—', style: t.bodyMedium?.copyWith(color: DashboardTokens.muted))
              else ...[
                Text(
                  l.calcResult,
                  style: t.labelLarge?.copyWith(
                    color: DashboardTokens.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '1:${fmtRatio(result!.ratio)}',
                    textAlign: TextAlign.center,
                    style: t.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: DashboardTokens.muted.withValues(alpha: 0.25), height: 1),
                const SizedBox(height: 10),
                RatioResultRow(
                  label: l.calcRowSl,
                  value: '${fmtMoney(result!.riskMoney)} $currencySymbol',
                  valueColor: Colors.redAccent,
                ),
                RatioResultRow(
                  label: l.calcRowGain,
                  value: '${fmtMoney(result!.rewardMoney)} $currencySymbol',
                ),
                RatioResultRow(
                  label: l.calcRowVsCapital,
                  value: result!.riskPctOfCapital == null ? '—' : fmtPctTrim(result!.riskPctOfCapital!),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketPillDropdown extends StatelessWidget {
  const _MarketPillDropdown({required this.value, required this.onChanged});

  final AjouterTradeAssetClass value;
  final ValueChanged<AjouterTradeAssetClass> onChanged;

  static const double _fieldH = 36;
  static const double _radius = 10;

  String _marketLabel(
    BuildContext context,
    AjouterTradeAssetClass market,
  ) {
    final l = AppLocalizations.of(context)!;
    switch (market) {
      case AjouterTradeAssetClass.forex:
        return 'Forex';
      case AjouterTradeAssetClass.indice:
        return l.calcMarketIndex;
      case AjouterTradeAssetClass.future:
        return l.calcMarketFutures;
      case AjouterTradeAssetClass.crypto:
        return 'Crypto';
      case AjouterTradeAssetClass.stock:
        return l.calcMarketStock;
      case AjouterTradeAssetClass.matieresPremieres:
        return l.calcMarketCommodities;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;
    final labelStyle = t.labelMedium?.copyWith(
      color: DashboardTokens.muted,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
    );
    final valueStyle = t.labelLarge?.copyWith(
      color: DashboardTokens.onMatteEmphasis,
      fontWeight: FontWeight.w800,
      fontSize: 12,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l.labelMarket, style: labelStyle, maxLines: 1),
        const SizedBox(height: 6),
        Container(
          height: _fieldH,
          padding: const EdgeInsets.only(left: 8, right: 4),
          decoration: BoxDecoration(
            color: DashboardTokens.cardBoxBg,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(_radius),
            clipBehavior: Clip.antiAlias,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AjouterTradeAssetClass>(
                value: value,
                isExpanded: true,
                dropdownColor: DashboardTokens.cardBoxBg,
                iconEnabledColor: DashboardTokens.labelGrey,
                style: valueStyle,
                items: AjouterTradeAssetClass.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          _marketLabel(context, e),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                selectedItemBuilder: (context) {
                  return AjouterTradeAssetClass.values
                      .map(
                        (e) => Center(
                          child: Text(
                            _marketLabel(context, e),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: valueStyle,
                          ),
                        ),
                      )
                      .toList();
                },
                onChanged: (v) {
                  if (v == null) return;
                  onChanged(v);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}



