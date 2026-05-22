import 'package:flutter/material.dart';

import '../analyse/analyse_tokens.dart';

/// Couleurs et styles « Ma Stratégie » — alignés sur [AnalyseTokens] (OLED).
abstract final class StrategieTokens {
  static const bg = AnalyseTokens.bg;
  static const cardBg = AnalyseTokens.cardBg;
  static const cardBorder = AnalyseTokens.cardBorder;
  static const innerCardBg = AnalyseTokens.inputBg;
  static const rowBg = AnalyseTokens.inputBg;
  static const mesReglesSectionCardBg = AnalyseTokens.cardBg;
  static const ruleLineCaseBg = AnalyseTokens.inputBgDeep;

  /// Libellés de blocs (ex-règles setup) — zinc OLED.
  static const maquetteHeadingOrange = AnalyseTokens.zinc400;
  static const pageMaxContentWidth = 1180.0;
  static const twoColumnBreakpoint = 960.0;

  static const emerald = AnalyseTokens.oledGreen;
  static const labelMuted = AnalyseTokens.zinc500;
  static const titleGrey = AnalyseTokens.zinc400;

  static const riskHeaderBlue = AnalyseTokens.oledBlue;
  static const horairesGold = AnalyseTokens.zinc300;

  static const riskRed = AnalyseTokens.oledRed;
  static const ratioTeal = AnalyseTokens.oledGreen;

  static const radiusLg = AnalyseTokens.radiusCard;
  static const radiusMd = 12.0;
  static const radiusSm = 8.0;

  static BoxDecoration sectionDecoration() => AnalyseTokens.oledStepDecoration();

  static BoxDecoration innerDecoration() => BoxDecoration(
        color: innerCardBg,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: cardBorder),
      );

  /// Champs / dialogues (sessions, roues horaires).
  static const dialogBg = AnalyseTokens.bg;
  static const fieldFill = AnalyseTokens.inputBg;
  static const fieldBorder = AnalyseTokens.cardBorder;
  static const wheelBg = AnalyseTokens.inputBg;
  static const wheelDigit = AnalyseTokens.zinc300;
  static const wheelSelection = AnalyseTokens.inputBgDeep;
  static const wheelSeparator = AnalyseTokens.zinc700;

  /// Pastilles sessions « Trade » / « No Trade » (horaires).
  static const sessionTradeIconBg = Color(0xFF0F2418);
  static const sessionNoTradeIconBg = Color(0xFF2A1010);
  static const sessionNoTradeIconFg = Color(0xFFE57373);
}
