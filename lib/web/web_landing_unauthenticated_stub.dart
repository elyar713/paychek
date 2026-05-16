import 'package:flutter/material.dart';

/// Hôte non-web (jamais utilisé : [WebAuthGate] n’affiche la landing que sur le Web).
Widget buildWebLandingUnauthenticated(
  BuildContext context,
  Future<void> Function(String languageCode) onLocaleSelected,
) {
  return const SizedBox.shrink();
}
