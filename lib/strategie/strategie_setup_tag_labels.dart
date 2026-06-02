import 'widgets/strategie_setup_card.dart';
import 'widgets/strategie_setup_tag_format.dart';

/// Résout un id « non respect » setup_* vers le libellé tag affiché sur la carte.
String? labelForSetupNonRespectIdOnCard(String id, StrategieSetupCardData data) {
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

  return _labelForRuleBlockTags(id, data);
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
