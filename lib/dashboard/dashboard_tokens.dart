import 'package:flutter/material.dart';

/// Couleurs et rayons partagés par les cartes du dashboard (réf. maquettes).
class DashboardTokens {
  DashboardTokens._();

  /// Fond global : graphite très sombre, aspect **mat** (évite le noir pur brillant).
  static const scaffoldMatte = Color(0xFF0A0A0B);

  /// Accent atténué : moins saturé que le teal vif, rendu plus mat sur fond sombre.
  static const accent = Color(0xFF2F8F78);
  static const accentDeep = Color(0xFF267A66);
  static const border = Color(0xFF1A1A1C);
  static const cardBoxBg = Color(0xFF0E0E10);
  static const cardBoxBorder = Color(0xFF232326);
  static const negative = Color(0xFFD85A4E);
  static const muted = Color(0xFF7B7B7E);
  static const labelGrey = Color(0xFF939396);
  /// Barre du bas : icônes inactives, bordures discrètes.
  static const navInactive = Color(0xFF5A5A5D);
  static const bottomNavFabBg = Color(0xFF303032);

  /// Texte / icônes actifs : blanc cassé mat (moins agressif que [Colors.white] pur).
  static const onMatteEmphasis = Color(0xFFE6E6E4);

  /// En-tête accueil (nom trader ou marque) — anthracite doux sur fond mat.
  static const homeHeaderAnthracite = Color(0xFFA8A8AD);

  /// Titres de sections (or/jaune, comme les maquettes).
  static const titleGold = Color(0xFFD4A574);

  /// Badge / icône **Pro** (doré).
  static const proBadgeGold = Color(0xFFE6C35C);

  static const radiusCard = 20.0;

  static const EdgeInsets cardPadding = EdgeInsets.all(20);

  /// Fond transparent (sections sans cadre).
  static BoxDecoration cardDecoration() => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radiusCard),
      );

  /// Cartes principales : coins arrondis, contraste doux (aspect mat).
  static BoxDecoration cardBoxDecoration() => BoxDecoration(
        color: cardBoxBg,
        borderRadius: BorderRadius.circular(24),
      );
}
