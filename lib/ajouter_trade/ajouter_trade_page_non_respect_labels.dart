import 'dart:ui' show Locale;

import '../l10n/app_localizations.dart';
import '../strategie/strategie_feedback_reference.dart';
import '../strategie/widgets/strategie_setup_cards_content.dart';

/// Libellé lisible pour un id « non respect » du panneau stratégie.
String labelForStrategieNonRespectId(
  String id,
  String strategieChoisie, {
  required AppLocalizations l,
  required Locale locale,
}) {
  final regles = StrategieFeedbackReference.mesReglesDor(locale);

  if (id.startsWith('mes_regles_')) {
    final idx = int.tryParse(id.substring('mes_regles_'.length));
    if (idx != null && idx >= 0 && idx < regles.length) {
      return '${l.ajouterTradeStrategieRuleN(idx + 1)}: ${regles[idx]}';
    }
  }

  final data = strategieSetupCardDataPourTitre(strategieChoisie);
  if (data != null) {
    switch (id) {
      case 'setup_timeframes':
        return l.ajouterTradeStrategieSetupTimeframesRow(data.timeframes);
      case 'setup_indicateurs':
        return l.ajouterTradeStrategieSetupIndicatorsRow(data.indicateurs);
      case 'setup_pattern':
        return l.ajouterTradeStrategieSetupPatternRow(data.pattern);
      case 'setup_signal':
        return l.ajouterTradeStrategieSetupSignalRow(data.signalText);
    }
    if (id.startsWith('setup_rule_')) {
      final idx = int.tryParse(id.substring('setup_rule_'.length));
      if (idx != null && idx >= 0 && idx < data.ruleBlocks.length) {
        final rule = data.ruleBlocks[idx];
        return '${rule.heading} : ${rule.body}';
      }
    }
  }

  if (id.startsWith('setup_')) {
    return l.tradeStrategieNonRespectUnmapped(id);
  }

  return id;
}
