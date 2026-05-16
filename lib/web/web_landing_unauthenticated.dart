import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'web_landing_unauthenticated_stub.dart'
    if (dart.library.html) 'web_landing_unauthenticated_web.dart' as impl;

/// Conteneur Web : iframe vers `web/landing.html`.
Widget buildWebLandingUnauthenticated(
  BuildContext context,
  Future<void> Function(String languageCode) onLocaleSelected,
) {
  if (!kIsWeb) {
    return const SizedBox.shrink();
  }
  return impl.buildWebLandingUnauthenticated(
    context,
    onLocaleSelected,
  );
}
