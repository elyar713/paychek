import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../strategie_tokens.dart';
import 'strategie_setup_card.dart';

/// Icônes et couleurs des 4 blocs règles — identiques carte + dialogue Modifier setup.
abstract final class StrategieSetupRuleStyles {
  StrategieSetupRuleStyles._();

  static const double iconSize = 18;

  static const List<String> ruleIconKeys = [
    'entry',
    'invalidation',
    'target',
    'management',
  ];

  static const Color entryHeading = Colors.white;
  static const Color invalidationHeading = StrategieTokens.riskRed;
  static const Color targetHeading = StrategieTokens.emerald;
  static const Color managementHeading = StrategieTokens.labelMuted;

  static String iconKeyForIcon(IconData icon) {
    if (icon == LucideIcons.shield) return 'invalidation';
    if (icon == LucideIcons.circleDot) return 'target';
    if (icon == LucideIcons.lock) return 'management';
    return 'entry';
  }

  static IconData iconFromKey(String? key, {int blockIndex = 0}) {
    switch (key) {
      case 'invalidation':
        return LucideIcons.shield;
      case 'target':
        return LucideIcons.circleDot;
      case 'management':
        return LucideIcons.lock;
      case 'entry':
        return LucideIcons.crosshair;
      default:
        if (blockIndex >= 0 && blockIndex < ruleIconKeys.length) {
          return iconFromKey(ruleIconKeys[blockIndex]);
        }
        return LucideIcons.crosshair;
    }
  }

  static Color headingColorForIcon(IconData icon) {
    if (icon == LucideIcons.crosshair) return entryHeading;
    if (icon == LucideIcons.shield) return invalidationHeading;
    if (icon == LucideIcons.circleDot) return targetHeading;
    if (icon == LucideIcons.lock) return managementHeading;
    return StrategieTokens.labelMuted;
  }

  /// Même couleur que le titre de section (dialogue + carte).
  static Color iconColorForIcon(IconData icon) => headingColorForIcon(icon);

  static StrategieSetupRuleBlock block({
    required IconData icon,
    required String heading,
    required String body,
  }) {
    return StrategieSetupRuleBlock(
      icon: icon,
      heading: heading,
      headingColor: headingColorForIcon(icon),
      body: body,
    );
  }
}
