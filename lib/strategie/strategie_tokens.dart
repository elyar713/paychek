import 'package:flutter/material.dart';

/// Couleurs et styles « Ma Stratégie » (maquettes).
abstract final class StrategieTokens {
  static const bg = Colors.black;
  /// Cartes principales (maquette « My Strategy »).
  static const cardBg = Color(0xFF1A1A1A);
  static const cardBorder = Color(0xFF2C2C2E);
  static const innerCardBg = Color(0xFF121212);
  static const rowBg = Color(0xFF1A1A1A);

  /// Sections gauche : même facette que [cardBg].
  static const mesReglesSectionCardBg = Color(0xFF1A1A1A);

  /// Lignes de règle numérotées.
  static const ruleLineCaseBg = Color(0xFF151515);

  /// Libellés type maquette (titres de blocs règles setup).
  static const maquetteHeadingOrange = Color(0xFFE8A66B);

  static const pageMaxContentWidth = 1180.0;
  static const twoColumnBreakpoint = 960.0;

  static const emerald = Color(0xFF1EB48A);
  static const labelMuted = Color(0xFF888888);
  static const titleGrey = Color(0xFF666666);

  /// En-tête Gestion du risque (bleu ciel).
  static const riskHeaderBlue = Color(0xFF64B5F6);

  /// Horaires & sessions (or).
  static const horairesGold = Color(0xFFD4AF37);

  static const riskRed = Color(0xFFE53935);
  static const ratioTeal = Color(0xFF26C694);

  static const radiusLg = 20.0;
  static const radiusMd = 14.0;
  static const radiusSm = 10.0;

  static BoxDecoration sectionDecoration() => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: cardBorder.withValues(alpha: 0.55)),
      );

  static BoxDecoration innerDecoration() => BoxDecoration(
        color: innerCardBg,
        borderRadius: BorderRadius.circular(radiusMd),
      );
}
