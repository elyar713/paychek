import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

import 'plus_web_left_rail.dart';

/// Configuration du shell dashboard pour la **version Web** (rail gauche, décalage des overlays).
abstract final class WebDashboardConfig {
  WebDashboardConfig._();

  /// Largeur min. pour le rail gauche (sinon shell **mobile** : barre du bas).
  static const double leftRailMinWidth = 768;

  /// Rail logo + menu Plus à gauche (navigateur large uniquement).
  static bool useLeftRailFor(double width) =>
      kIsWeb && width >= leftRailMinWidth;

  static bool useLeftRailOf(BuildContext context) =>
      useLeftRailFor(MediaQuery.sizeOf(context).width);

  /// Décalage horizontal des overlays pour ne pas masquer le rail.
  static double overlayLeftInsetOf(BuildContext context) =>
      useLeftRailOf(context) ? PlusWebLeftRail.preferredWidth : 0.0;

  /// Marge gauche/droite du contenu principal (web large, hors rail).
  static double mainContentHorizontalPaddingOf(BuildContext context) =>
      useLeftRailOf(context) ? 40.0 : 0.0;
}
