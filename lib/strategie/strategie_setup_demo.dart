import 'widgets/strategie_setup_card.dart';
import 'widgets/strategie_setup_cards_content.dart';

bool strategieSetupTitleMatches(StrategieSetupCardData a, StrategieSetupCardData b) =>
    a.title.trim().toLowerCase() == b.title.trim().toLowerCase();

/// Carte issue des 3 maquettes « Setups & modèles ».
bool isStrategieSetupStockDemo(StrategieSetupCardData card) {
  for (final d in strategieSetupDefaultCardDataList()) {
    if (strategieSetupTitleMatches(d, card)) return true;
  }
  return false;
}

/// Liste affichée / persistée : défauts tant qu’aucun setup utilisateur validé.
List<StrategieSetupCardData> strategieSetupsEffectiveList(
  List<StrategieSetupCardData> stored, {
  required bool setupsGraduated,
}) {
  final hasUserSetup = stored.any((c) => !isStrategieSetupStockDemo(c));
  if (!hasUserSetup && !setupsGraduated) {
    if (stored.isEmpty) {
      return List<StrategieSetupCardData>.from(strategieSetupDefaultCardDataList());
    }
    return List<StrategieSetupCardData>.from(stored);
  }
  return stored.where((c) => !isStrategieSetupStockDemo(c)).toList(growable: false);
}

List<StrategieSetupCardData> stripStrategieSetupStockDemos(
  List<StrategieSetupCardData> stored,
) =>
    stored.where((c) => !isStrategieSetupStockDemo(c)).toList(growable: false);
