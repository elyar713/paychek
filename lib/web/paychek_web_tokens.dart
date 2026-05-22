import 'package:flutter/material.dart';

import '../analyse/analyse_tokens.dart';

/// Palette Web — alignée sur [AnalyseTokens] (OLED Mon analyse).
abstract final class PaychekWebTokens {
  PaychekWebTokens._();

  static const Color textZinc500 = AnalyseTokens.zinc500;
  static const Color upgradeAmber = AnalyseTokens.oledAmber;
  static const Color glassCardFill = Color(0xCC050508);
  static const Color scaffoldBg = AnalyseTokens.bg;
  static const Color railBg = AnalyseTokens.bg;
  static const Color cardBg = AnalyseTokens.cardBg;
  static const Color borderGray800 = AnalyseTokens.cardBorder;
  static Color get cardBorder => AnalyseTokens.cardBorder;
  static const Color pillTrackBg = AnalyseTokens.inputBg;
  static const Color textGray500 = AnalyseTokens.zinc500;
  static const Color textGray400 = AnalyseTokens.zinc400;
  static const Color textGray600 = AnalyseTokens.zinc600;
  static const Color accentEmerald = AnalyseTokens.oledGreen;
  static const Color accentEmeraldLight = Color(0xFF34D399);
  static const Color sectionLabelCopper = AnalyseTokens.zinc400;

  static const double radiusCard = AnalyseTokens.radiusCard;
  static const double radiusNavItem = 8;
  static const double radiusButton = 12;

  static Color get accentMint => accentEmerald;
  static Color get accentMintDark => const Color(0xFF059669);

  static BoxDecoration shellCardDecoration() => AnalyseTokens.oledStepDecoration();

  static BoxDecoration primaryButtonDecoration() => const BoxDecoration(
        color: accentEmerald,
        borderRadius: BorderRadius.all(Radius.circular(radiusButton)),
      );
}
