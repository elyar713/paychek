import 'dart:ui' show Locale;

import '../l10n/app_localizations.dart';
import '../strategie/strategie_feedback_reference.dart';
import '../strategie/widgets/strategie_setup_card.dart';
import '../strategie/widgets/strategie_setup_cards_content.dart';
import '../strategie/widgets/strategie_setup_tag_format.dart';

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
      return regles[idx];
    }
  }

  final data = strategieSetupCardDataPourTitre(strategieChoisie);
  if (data != null) {
    final tf = _labelForIndexedTags(
      id,
      'setup_timeframes',
      data.timeframes,
      l.strategieTimeframes,
    );
    if (tf != null) return tf;

    final ind = _labelForIndexedTags(
      id,
      'setup_indicateurs',
      data.indicateurs,
      l.strategieIndicators,
    );
    if (ind != null) return ind;

    final pat = _labelForIndexedTags(
      id,
      'setup_pattern',
      data.pattern,
      l.ajouterTradeStrategieRowPattern,
    );
    if (pat != null) return pat;

    final sig = _labelForIndexedTags(
      id,
      'setup_signal',
      data.signalText,
      l.ajouterTradeStrategieRowSignal,
    );
    if (sig != null) return sig;

    final rule = _labelForRuleBlockTags(id, data);
    if (rule != null) return rule;
  }

  if (id.startsWith('setup_')) {
    return l.tradeStrategieNonRespectUnmapped(id);
  }

  return id;
}

String? _labelForIndexedTags(
  String id,
  String prefix,
  String display,
  String sectionTitle,
) {
  if (!id.startsWith('${prefix}_')) return null;
  final idx = int.tryParse(id.substring(prefix.length + 1));
  if (idx == null) return null;
  final tags = strategieSetupDisplayToTags(display);
  if (idx < 0 || idx >= tags.length) return null;
  return tags[idx];
}

String? _labelForRuleBlockTags(String id, StrategieSetupCardData data) {
  if (!id.startsWith('setup_rule_')) return null;
  final rest = id.substring('setup_rule_'.length);
  final sep = rest.indexOf('_');
  if (sep <= 0) return null;
  final ruleIndex = int.tryParse(rest.substring(0, sep));
  final tagIndex = int.tryParse(rest.substring(sep + 1));
  if (ruleIndex == null || tagIndex == null) return null;
  if (ruleIndex < 0 || ruleIndex >= data.ruleBlocks.length) return null;
  final block = data.ruleBlocks[ruleIndex];
  final tags = strategieSetupDisplayToTags(block.body);
  if (tagIndex < 0 || tagIndex >= tags.length) return null;
  return tags[tagIndex];
}
