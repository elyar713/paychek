import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// Ouvre le Payment Link Stripe de façon fiable (web : même onglet, pas de popup vide).
Future<bool> launchPaychekCheckoutUri(Uri uri) async {
  if (kIsWeb) {
    // Évite les onglets vides : `externalApplication` après un `await` perd le geste clic.
    return launchUrl(uri, mode: LaunchMode.platformDefault);
  }
  var ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
  return ok;
}

void debugLogPaychekCheckoutUri(Uri uri) {
  assert(() {
    debugPrint('[Paychek] Stripe checkout → $uri');
    return true;
  }());
}
