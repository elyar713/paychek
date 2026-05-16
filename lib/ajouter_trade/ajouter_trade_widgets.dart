/// Widgets partagés par l’écran **Ajouter un trade**.
///
/// Le code est découpé par thème pour rester sous ~300 lignes par fichier :
/// - pistes Long/Short et marchés : [AjouterTradeDirectionBar], [AjouterTradeAssetClassTrack]
/// - menu actif avec favoris : [AjouterTradeLabeledActifDropdown]
/// - champs pilule et date/checkbox : [AjouterTradeLabeledFieldBox], [AjouterTradeDateAndCheckboxColumn]
///
/// Importer ce fichier (`ajouter_trade_widgets.dart`) suffit pour réexporter tout le sous-ensemble.
library;

export 'ajouter_trade_labeled_actif_dropdown.dart';
export 'ajouter_trade_widgets_fields.dart';
export 'ajouter_trade_widgets_tracks.dart';
