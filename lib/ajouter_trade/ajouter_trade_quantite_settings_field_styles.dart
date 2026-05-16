import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';

/// Styles des champs texte du dialogue « Réglages position ».
abstract final class AjouterTradeQuantiteSettingsFieldStyles {
  AjouterTradeQuantiteSettingsFieldStyles._();

  static const double fieldHeight = 36;
  static const double radius = 10;

  static const TextStyle valueStyle = TextStyle(
    color: DashboardTokens.onMatteEmphasis,
    fontWeight: FontWeight.w700,
    fontSize: 12,
  );

  static InputDecoration fieldDecoration([String? hint]) {
    return InputDecoration(
      hintText: hint != null && hint.isNotEmpty ? hint : null,
      hintStyle: TextStyle(
        color: DashboardTokens.muted.withValues(alpha: 0.55),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      isDense: true,
      filled: true,
      fillColor: DashboardTokens.scaffoldMatte,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: DashboardTokens.cardBoxBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: DashboardTokens.cardBoxBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: DashboardTokens.accent, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
