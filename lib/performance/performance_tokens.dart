import 'package:flutter/material.dart';

import '../analyse/analyse_tokens.dart';

/// Palette « Performance » — alignée sur [AnalyseTokens] (OLED).
abstract final class PerformanceTokens {
  PerformanceTokens._();

  static const bg = AnalyseTokens.bg;
  static const cardBg = AnalyseTokens.cardBg;
  static const cardBorder = AnalyseTokens.cardBorder;
  static const innerBg = AnalyseTokens.inputBg;
  static const innerBgDeep = AnalyseTokens.inputBgDeep;

  static const green = AnalyseTokens.oledGreen;
  static const red = AnalyseTokens.oledRed;
  static const oledBlue = AnalyseTokens.oledBlue;
  static const oledAmber = AnalyseTokens.oledAmber;
  static const greenTintBg = Color(0xFF0F2418);

  static const textPrimary = AnalyseTokens.textPrimary;
  static const textBright = AnalyseTokens.zinc300;
  static const textSecondary = AnalyseTokens.zinc400;
  static const labelMuted = AnalyseTokens.zinc500;
  static const labelDim = AnalyseTokens.zinc600;
  static const labelFaint = AnalyseTokens.zinc700;

  static const borderSubtle = AnalyseTokens.cardBorder;
  static const divider = AnalyseTokens.cardBorder;
  static const splitLine = AnalyseTokens.zinc700;

  /// Filtres période / chips actifs (bleu ardoise OLED).
  static const filterActive = Color(0xFF3D4F5C);
  static const filterInactive = innerBgDeep;
  static const chipBorderInactive = AnalyseTokens.zinc700;
  static const chipBorderActive = AnalyseTokens.zinc500;

  static const barTrack = innerBgDeep;
  static const barTrackAlt = innerBg;
  static const popupBg = cardBg;
  static const tooltipBg = innerBgDeep;

  static const radiusCard = AnalyseTokens.radiusCard;

  static BoxDecoration sectionDecoration() =>
      AnalyseTokens.oledStepDecoration();
}
