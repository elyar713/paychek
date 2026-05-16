import 'package:flutter/material.dart';

/// Couleurs de l’écran **Trade** (réf. maquette sombre).
abstract final class TradeTokens {
  TradeTokens._();

  static const bg = Color(0xFF050505);
  static const cardBg = Color(0xFF0A0A0A);

  /// Contours des cartes / pilules — très peu contrastés (presque fond).
  static const cardBorder = Color(0xFF0E0E0E);
  static const pillInactiveBg = Color(0xFF0E0E0E);
  static const profitNeon = Color(0xFF00E676);
  static const lossNeon = Color(0xFFFF5252);
  /// ACHAT = vert, VENTE = rouge.
  static const tagBuy = Color(0xFF00C853);
  static const tagSell = Color(0xFFE53935);
  static const textSecondary = Color(0xFF9E9E9E);
  /// Dates (ligne sous la paire) — gris plus neutre / discret.
  static const textDate = Color(0xFF5C5C5C);
  static const divider = Color(0xFF0C0C0C);
  /// Titres de sections (moutard).
  static const mustard = Color(0xFFFFC247);

  static const radiusLg = 16.0;
  static const radiusPill = 999.0;
  /// Filtres en haut : carré, coins légèrement arrondis.
  static const radiusFilter = 10.0;
  /// Badge VENTE / ACHAT : presque carré, coins légèrement arrondis.
  static const radiusSideBadge = 4.0;
}
