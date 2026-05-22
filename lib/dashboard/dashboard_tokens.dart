import 'package:flutter/material.dart';

import '../analyse/analyse_tokens.dart';

/// Couleurs et rayons du dashboard — alignés sur [AnalyseTokens] (OLED).
class DashboardTokens {
  DashboardTokens._();

  static const scaffoldMatte = AnalyseTokens.bg;
  static const accent = AnalyseTokens.oledGreen;
  static const accentDeep = Color(0xFF059669);
  static const border = AnalyseTokens.cardBorder;
  static const cardBoxBg = AnalyseTokens.cardBg;
  static const cardBoxBorder = AnalyseTokens.cardBorder;
  static const negative = AnalyseTokens.oledRed;
  static const muted = AnalyseTokens.zinc500;
  static const labelGrey = AnalyseTokens.zinc400;
  static const navInactive = AnalyseTokens.zinc600;
  static const bottomNavFabBg = AnalyseTokens.inputBg;

  static const onMatteEmphasis = AnalyseTokens.textPrimary;
  static const homeHeaderAnthracite = AnalyseTokens.zinc400;

  /// Libellés de section (ex-calendrier) : zinc OLED, plus de doré maquette.
  static const titleGold = AnalyseTokens.zinc300;

  static const proBadgeGold = Color(0xFFE6C35C);

  static const radiusCard = AnalyseTokens.radiusCard;
  static const EdgeInsets cardPadding = AnalyseTokens.sectionCardPadding;

  /// Padding scroll accueil (aligné Performance / Mon analyse).
  static const EdgeInsets pageScrollPaddingMobile =
      EdgeInsets.symmetric(horizontal: 16);

  static const EdgeInsets pageScrollPaddingWeb =
      EdgeInsets.fromLTRB(32, 32, 32, 32);

  static const double sectionGapMobile = 16;
  static const double sectionGapWeb = 20;

  static BoxDecoration cardDecoration() => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radiusCard),
      );

  static BoxDecoration cardBoxDecoration() => AnalyseTokens.oledStepDecoration();
}
