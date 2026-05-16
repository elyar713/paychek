import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import 'ajouter_trade_asset_class.dart';
import 'ajouter_trade_lot_presets.dart';

/// Boutons rapides pour remplir quantité / lot selon le marché (libellés = [AjouterTradeLotPreset.label]).
class AjouterTradeLotQuickChips extends StatelessWidget {
  const AjouterTradeLotQuickChips({
    super.key,
    required this.marche,
    required this.onPick,
  });

  final AjouterTradeAssetClass marche;
  final ValueChanged<double> onPick;

  @override
  Widget build(BuildContext context) {
    final presets = ajouterTradeLotPresetsFor(marche);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final p in presets)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onPick(p.value),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: DashboardTokens.scaffoldMatte,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DashboardTokens.cardBoxBorder),
                ),
                child: Text(
                  p.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: DashboardTokens.onMatteEmphasis,
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
