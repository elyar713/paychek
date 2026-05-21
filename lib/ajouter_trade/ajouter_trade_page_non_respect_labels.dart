import 'dart:ui' show Locale;

import '../l10n/app_localizations.dart';
import '../strategie/strategie_feedback_reference.dart';
import '../strategie/widgets/strategie_setup_card.dart';
import '../strategie/widgets/strategie_setup_cards_content.dart';
import '../strategie/widgets/strategie_setup_tag_format.dart';

/// Libellé lisible pour un id « non respect » — **élément** coché (tag / valeur),
/// jamais le sujet de section (titre TIMEFRAMES, ENTRÉE PRÉCISE, etc.).
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

  if (id.startsWith('gestion_risque_')) {
    final idx = int.tryParse(id.substring('gestion_risque_'.length));
    final gestion = StrategieFeedbackReference.gestionRisque(locale);
    if (idx != null && idx >= 0 && idx < gestion.length) {
      return _normalizeElementText(gestion[idx].valeur);
    }
  }

  if (id.startsWith('horaire_')) {
    final idx = int.tryParse(id.substring('horaire_'.length));
    final horaires = StrategieFeedbackReference.horairesSessions(locale);
    if (idx != null && idx >= 0 && idx < horaires.length) {
      return _horaireSessionElementLabel(horaires[idx]);
    }
  }

  final data = strategieSetupCardDataPourTitre(strategieChoisie);
  if (data != null) {
    final tf = _labelForIndexedSetupTags(id, 'setup_timeframes', data.timeframes);
    if (tf != null) return tf;

    final ind = _labelForIndexedSetupTags(id, 'setup_indicateurs', data.indicateurs);
    if (ind != null) return ind;

    final pat = _labelForIndexedSetupTags(id, 'setup_pattern', data.pattern);
    if (pat != null) return pat;

    final sig = _labelForIndexedSetupTags(id, 'setup_signal', data.signalText);
    if (sig != null) return sig;

    final bareTf = _labelForBareSetupPrefix(id, 'setup_timeframes', data.timeframes);
    if (bareTf != null) return bareTf;

    final bareInd = _labelForBareSetupPrefix(id, 'setup_indicateurs', data.indicateurs);
    if (bareInd != null) return bareInd;

    final barePat = _labelForBareSetupPrefix(id, 'setup_pattern', data.pattern);
    if (barePat != null) return barePat;

    final bareSig = _labelForBareSetupPrefix(id, 'setup_signal', data.signalText);
    if (bareSig != null) return bareSig;

    final rule = _labelForRuleBlockTags(id, data);
    if (rule != null) return rule;
  }

  if (id.startsWith('setup_')) {
    return l.tradeStrategieNonRespectUnmapped(id);
  }

  return id;
}

String _normalizeElementText(String raw) =>
    raw.replaceAll(RegExp(r'\s+'), ' ').trim();

String _horaireSessionElementLabel(({String titre, String sousTitre, String creneau}) h) {
  final st = h.sousTitre.trim();
  final cr = h.creneau.trim();
  if (st.isNotEmpty && cr.isNotEmpty) return '$st ($cr)';
  if (cr.isNotEmpty) return cr;
  if (st.isNotEmpty) return st;
  return h.titre.trim();
}

String? _labelForSetupDisplayElements(String display) {
  final tags = strategieSetupDisplayToTags(display);
  if (tags.isEmpty) return null;
  if (tags.length == 1) return tags.first;
  return strategieSetupJoinTags(tags);
}

String? _labelForIndexedSetupTags(String id, String prefix, String display) {
  if (!id.startsWith('${prefix}_')) return null;
  final idx = int.tryParse(id.substring(prefix.length + 1));
  if (idx == null) return null;
  final tags = strategieSetupDisplayToTags(display);
  if (idx < 0 || idx >= tags.length) return null;
  return tags[idx];
}

String? _labelForBareSetupPrefix(String id, String prefix, String display) {
  if (id != prefix) return null;
  return _labelForSetupDisplayElements(display);
}

String? _labelForRuleBlockTags(String id, StrategieSetupCardData data) {
  if (!id.startsWith('setup_rule_')) return null;
  final rest = id.substring('setup_rule_'.length);
  final sep = rest.indexOf('_');

  if (sep < 0) {
    final ruleIndex = int.tryParse(rest);
    if (ruleIndex == null ||
        ruleIndex < 0 ||
        ruleIndex >= data.ruleBlocks.length) {
      return null;
    }
    return _labelForSetupDisplayElements(data.ruleBlocks[ruleIndex].body);
  }

  final ruleIndex = int.tryParse(rest.substring(0, sep));
  final tagIndex = int.tryParse(rest.substring(sep + 1));
  if (ruleIndex == null || tagIndex == null) return null;
  if (ruleIndex < 0 || ruleIndex >= data.ruleBlocks.length) return null;
  final tags = strategieSetupDisplayToTags(data.ruleBlocks[ruleIndex].body);
  if (tagIndex < 0 || tagIndex >= tags.length) return null;
  return tags[tagIndex];
}
