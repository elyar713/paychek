import 'package:flutter/material.dart';

/// Marges clavier pour pages overlay / champs en bas d’écran.
abstract final class PaychekKeyboardInsets {
  PaychekKeyboardInsets._();

  static double viewBottom(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;

  static EdgeInsets fieldScrollPadding(
    BuildContext context, {
    double extra = 120,
  }) =>
      EdgeInsets.only(bottom: viewBottom(context) + extra);

  static EdgeInsets addBottom(EdgeInsets base, BuildContext context) =>
      base.copyWith(bottom: base.bottom + viewBottom(context));
}
