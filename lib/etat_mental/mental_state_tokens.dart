import 'package:flutter/material.dart';

import '../analyse/analyse_tokens.dart';
import 'mental_state_models.dart';

/// Couleurs et constantes de mise en page « État mental » (OLED).
class MentalStateTokens {
  MentalStateTokens._();

  static const matteGreen = kMentalStateRingGreen;
  static const matteRed = kMentalStateMatteRed;
  static const scaffoldBg = AnalyseTokens.bg;
  static const cardBg = AnalyseTokens.cardBg;
  static const factorSectionBg = AnalyseTokens.inputBg;
  static const cardBorder = AnalyseTokens.cardBorder;
  static const trackBg = AnalyseTokens.inputBg;
  static const modalSliderThumbBlue = Color(0xFF2196F3);

  /// Ancienne contrainte étroite (ex. [StrategiePage]).
  static const pageMaxWidth = 420.0;
  /// Colonne unique mobile — page État mental.
  static const pageSingleColumnMax = 520.0;
  /// Page grille 2 colonnes (desktop).
  static const pageMaxWide = 1120.0;
  static const pageWideBreakpoint = 960.0;
  static const gaugeSize = 130.0;
  static const gaugeSizeWide = 148.0;

  static const titleBarCtrlGap = 4.0;

  /// Couleur d’anneau score global (alignée sur la jauge État mental).
  static Color ringStrokeForScore(double score) {
    if (score >= 70) return matteGreen;
    if (score >= 45) return Colors.white;
    return matteRed;
  }

  /// % jour sur le mini-calendrier (historique inclus) : ≥ 50 % vert, sinon rouge.
  static Color calendarDayPercentColor(double score) {
    if (score >= 50) return matteGreen;
    return matteRed;
  }
}
