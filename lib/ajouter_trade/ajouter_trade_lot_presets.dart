import '../l10n/app_localizations.dart';
import 'ajouter_trade_asset_class.dart';

/// Un bouton raccourci : [label] affiché, [value] injecté dans le champ quantité.
class AjouterTradeLotPreset {
  const AjouterTradeLotPreset({required this.label, required this.value});

  final String label;
  final double value;
}

/// Libellé du champ quantité (au-dessus de la saisie / des raccourcis).
String ajouterTradeQuantiteFieldLabel(
  AjouterTradeAssetClass marche,
  AppLocalizations l,
) {
  switch (marche) {
    case AjouterTradeAssetClass.forex:
      return l.ajouterTradeQtyLots;
    case AjouterTradeAssetClass.indice:
    case AjouterTradeAssetClass.future:
      return l.ajouterTradeQtyContracts;
    case AjouterTradeAssetClass.crypto:
      return l.ajouterTradeQtyUnits;
    case AjouterTradeAssetClass.stock:
      return l.ajouterTradeQtyShares;
    case AjouterTradeAssetClass.matieresPremieres:
      return l.ajouterTradeQtyContracts;
  }
}

/// Titre au-dessus des boutons raccourcis (change selon le marché).
String ajouterTradeLotShortcutsHeading(
  AjouterTradeAssetClass marche,
  AppLocalizations l,
) {
  switch (marche) {
    case AjouterTradeAssetClass.forex:
      return l.ajouterTradeShortcutsLots;
    case AjouterTradeAssetClass.indice:
    case AjouterTradeAssetClass.future:
      return l.ajouterTradeShortcutsContracts;
    case AjouterTradeAssetClass.crypto:
      return l.ajouterTradeShortcutsQty;
    case AjouterTradeAssetClass.stock:
      return l.ajouterTradeShortcutsCommonSizes;
    case AjouterTradeAssetClass.matieresPremieres:
      return l.ajouterTradeShortcutsContracts;
  }
}

/// Sous-texte optionnel sous le titre des raccourcis.
String? ajouterTradeLotShortcutsSubheading(
  AjouterTradeAssetClass marche,
  AppLocalizations l,
) {
  switch (marche) {
    case AjouterTradeAssetClass.forex:
      return l.ajouterTradeLotHintMini;
    default:
      return null;
  }
}

/// Exemple sous le champ LOT (feuille réglages).
String ajouterTradeLotFieldHint(
  AjouterTradeAssetClass marche,
  AppLocalizations l,
) {
  switch (marche) {
    case AjouterTradeAssetClass.forex:
      return l.ajouterTradeLotFieldHintForex;
    case AjouterTradeAssetClass.indice:
    case AjouterTradeAssetClass.future:
      return l.ajouterTradeLotFieldHintContracts;
    case AjouterTradeAssetClass.crypto:
      return l.ajouterTradeLotFieldHintUnits;
    case AjouterTradeAssetClass.stock:
      return l.ajouterTradeLotFieldHintShares;
    case AjouterTradeAssetClass.matieresPremieres:
      return l.ajouterTradeLotFieldHintContracts;
  }
}

/// Boutons rapides : libellés et valeurs selon le marché.
List<AjouterTradeLotPreset> ajouterTradeLotPresetsFor(AjouterTradeAssetClass marche) {
  switch (marche) {
    case AjouterTradeAssetClass.forex:
      return const [
        AjouterTradeLotPreset(label: '0,01', value: 0.01),
        AjouterTradeLotPreset(label: '0,05', value: 0.05),
        AjouterTradeLotPreset(label: '0,1', value: 0.1),
        AjouterTradeLotPreset(label: '0,2', value: 0.2),
        AjouterTradeLotPreset(label: '0,5', value: 0.5),
        AjouterTradeLotPreset(label: '1', value: 1.0),
      ];
    case AjouterTradeAssetClass.indice:
    case AjouterTradeAssetClass.future:
      return const [
        AjouterTradeLotPreset(label: '1', value: 1),
        AjouterTradeLotPreset(label: '3', value: 3),
        AjouterTradeLotPreset(label: '5', value: 5),
        AjouterTradeLotPreset(label: '10', value: 10),
      ];
    case AjouterTradeAssetClass.crypto:
      return const [
        AjouterTradeLotPreset(label: '0,01', value: 0.01),
        AjouterTradeLotPreset(label: '0,1', value: 0.1),
        AjouterTradeLotPreset(label: '1', value: 1),
        AjouterTradeLotPreset(label: '5', value: 5),
        AjouterTradeLotPreset(label: '10', value: 10),
      ];
    case AjouterTradeAssetClass.stock:
      return const [
        AjouterTradeLotPreset(label: '1', value: 1),
        AjouterTradeLotPreset(label: '5', value: 5),
        AjouterTradeLotPreset(label: '10', value: 10),
        AjouterTradeLotPreset(label: '25', value: 25),
        AjouterTradeLotPreset(label: '100', value: 100),
      ];
    case AjouterTradeAssetClass.matieresPremieres:
      return const [
        AjouterTradeLotPreset(label: '1', value: 1),
        AjouterTradeLotPreset(label: '2', value: 2),
        AjouterTradeLotPreset(label: '3', value: 3),
        AjouterTradeLotPreset(label: '5', value: 5),
        AjouterTradeLotPreset(label: '10', value: 10),
      ];
  }
}
