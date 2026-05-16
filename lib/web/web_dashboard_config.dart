import 'package:flutter/foundation.dart' show kIsWeb;

import 'plus_web_left_rail.dart';

/// Configuration du shell dashboard pour la **version Web** (rail gauche, décalage des overlays).
abstract final class WebDashboardConfig {
  WebDashboardConfig._();

  /// Rail logo + menu Plus à gauche (desktop / navigateur).
  static bool get useLeftRail => kIsWeb;

  /// Décalage horizontal des overlays pour ne pas masquer le rail.
  static double get overlayLeftInsetPx =>
      useLeftRail ? PlusWebLeftRail.preferredWidth : 0.0;

  /// Marge gauche/droite du contenu principal et de la barre du bas (web, hors rail).
  static const double mainContentHorizontalPaddingPx = 40.0;
}
