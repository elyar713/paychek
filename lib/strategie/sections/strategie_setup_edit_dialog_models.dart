import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../strategie_tokens.dart';
import '../widgets/strategie_setup_card.dart';
import '../widgets/strategie_setup_cards_content.dart';

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
  String joinOrDash(List<String> l) {
    if (l.isEmpty) return '—';
    return l.join(' · ');
  }

  String joinCsv(List<String> l) {
    if (l.isEmpty) return '—';
    return l.join(', ');
  }

  return StrategieSetupCardData(
    title: r.modelName.trim().isEmpty ? 'Untitled' : r.modelName.trim(),
    dotColor: r.dotColor,
    timeframes: joinCsv(r.timeframes),
    indicateurs: joinCsv(r.indicators),
    pattern: joinOrDash(r.patterns),
    signalText: joinOrDash(r.signals),
    signalColor: r.dotColor,
    ruleBlocks: [
      StrategieSetupRuleBlock(
        icon: LucideIcons.crosshair,
        heading: 'PRECISE ENTRY',
        headingColor: strategieSetupRuleHeadingTan,
        body: joinOrDash(r.entreePrecise),
      ),
      StrategieSetupRuleBlock(
        icon: LucideIcons.shield,
        heading: 'INVALIDATION (STOP LOSS)',
        headingColor: StrategieTokens.riskRed,
        body: joinOrDash(r.invalidation),
      ),
      StrategieSetupRuleBlock(
        icon: LucideIcons.circleDot,
        heading: 'CIBLE (TAKE PROFIT)',
        headingColor: StrategieTokens.emerald,
        body: joinOrDash(r.cible),
      ),
      StrategieSetupRuleBlock(
        icon: LucideIcons.lock,
        heading: 'GESTION (BREAKEVEN / PARTIELS)',
        headingColor: StrategieTokens.labelMuted,
        body: joinOrDash(r.gestion),
      ),
    ],
  );
}

List<String> strategieSetupSplitCsv(String s) {
  if (s.isEmpty || s == '—') return [];
  return s
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

List<String> strategieSetupBodyToTags(String body) {
  if (body.isEmpty || body == '—') return [];
  if (body.contains(' · ')) {
    return body
        .split(' · ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return [body];
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
