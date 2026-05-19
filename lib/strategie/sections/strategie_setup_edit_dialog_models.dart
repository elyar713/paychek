import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../strategie_tokens.dart';
import '../widgets/strategie_setup_card.dart';
import '../widgets/strategie_setup_rule_styles.dart';
import '../widgets/strategie_setup_tag_format.dart';

export '../widgets/strategie_setup_tag_format.dart';

/// Données renvoyées par le dialogue **Modifier Setup** (tags + nom + couleur).
class StrategieSetupEditDialogResult {
  StrategieSetupEditDialogResult({
    required this.modelName,
    required this.dotColor,
    required this.timeframes,
    required this.indicators,
    required this.patterns,
    required this.signals,
    required this.entreePrecise,
    required this.invalidation,
    required this.cible,
    required this.gestion,
  });

  final String modelName;
  final Color dotColor;
  final List<String> timeframes;
  final List<String> indicators;
  final List<String> patterns;
  final List<String> signals;
  final List<String> entreePrecise;
  final List<String> invalidation;
  final List<String> cible;
  final List<String> gestion;
}

/// Reconstruit une carte à partir du résultat du dialogue.
StrategieSetupCardData strategieSetupCardDataFromEditResult(
  StrategieSetupEditDialogResult r,
) {
  String joinOrDash(List<String> l) => strategieSetupJoinTags(l);

  String joinCsv(List<String> l) => strategieSetupJoinTags(l);

  return StrategieSetupCardData(
    title: r.modelName.trim().isEmpty ? 'Untitled' : r.modelName.trim(),
    dotColor: r.dotColor,
    timeframes: joinCsv(r.timeframes),
    indicateurs: joinCsv(r.indicators),
    pattern: joinOrDash(r.patterns),
    signalText: joinOrDash(r.signals),
    signalColor: r.dotColor,
    ruleBlocks: [
      StrategieSetupRuleStyles.block(
        icon: LucideIcons.crosshair,
        heading: 'PRECISE ENTRY',
        body: joinOrDash(r.entreePrecise),
      ),
      StrategieSetupRuleStyles.block(
        icon: LucideIcons.shield,
        heading: 'INVALIDATION (STOP LOSS)',
        body: joinOrDash(r.invalidation),
      ),
      StrategieSetupRuleStyles.block(
        icon: LucideIcons.circleDot,
        heading: 'CIBLE (TAKE PROFIT)',
        body: joinOrDash(r.cible),
      ),
      StrategieSetupRuleStyles.block(
        icon: LucideIcons.lock,
        heading: 'GESTION (BREAKEVEN / PARTIELS)',
        body: joinOrDash(r.gestion),
      ),
    ],
  );
}

Color strategieSetupClosestPresetColor(Color c) {
  const presets = <Color>[
    StrategieTokens.emerald,
    Color(0xFF42A5F5),
    Color(0xFFFFB74D),
    StrategieTokens.riskRed,
    Colors.white,
  ];
  Color best = presets.first;
  var bestD = double.infinity;
  for (final p in presets) {
    final d = (p.r - c.r) * (p.r - c.r) +
        (p.g - c.g) * (p.g - c.g) +
        (p.b - c.b) * (p.b - c.b);
    if (d < bestD) {
      bestD = d;
      best = p;
    }
  }
  return best;
}

/// Libellés + couleurs du menu déroulant « Couleur ».
const strategieSetupEditColorPresets = <({String label, Color color})>[
  (label: 'Green', color: StrategieTokens.emerald),
  (label: 'Blue', color: Color(0xFF42A5F5)),
  (label: 'Orange', color: Color(0xFFFFB74D)),
  (label: 'Red', color: StrategieTokens.riskRed),
  (label: 'White', color: Colors.white),
];
