// Paywall web : URL Stripe via --dart-define ou Firestore `paychek_app_config/billing`
// (éditable console admin). Voir aussi subscriber_entitlements + webhook Functions.

import 'paychek_billing_remote.dart';

/// Build / CI : prioritaire sur la valeur Firestore (back-office).
const String kPaywallSubscribeLaunchUrl = String.fromEnvironment(
  'PAYCHEK_STRIPE_CHECKOUT_URL',
  defaultValue: '',
);

/// Stripe Payment Link : alphanum, tirets, underscores, max 200 car.
String? paychekSanitizeStripeClientReferenceId(String? raw) {
  final t = raw?.trim() ?? '';
  if (t.isEmpty) return null;
  final sanitized = t.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
  if (sanitized.isEmpty) return null;
  return sanitized.length > 200 ? sanitized.substring(0, 200) : sanitized;
}

Uri? _buildPaywallSubscribeUriFromBase(
  String baseTrimmed, {
  String? firebaseEmail,
  String? firebaseUid,
}) {
  final trimmed = baseTrimmed.trim();
  if (trimmed.isEmpty) return null;
  final base = Uri.tryParse(trimmed);
  if (base == null) return null;
  if (base.scheme != 'https' && base.scheme != 'http') return null;
  if (!base.host.contains('stripe.com')) return null;

  final q = Map<String, String>.from(base.queryParameters);
  final email = firebaseEmail?.trim();
  if (email != null && email.isNotEmpty) {
    q.putIfAbsent('prefilled_email', () => email);
  }
  final ref = paychekSanitizeStripeClientReferenceId(firebaseUid);
  if (ref != null) {
    q.putIfAbsent('client_reference_id', () => ref);
  }
  return base.replace(queryParameters: q);
}

/// Version synchrone : **dart-define uniquement** (tests / hot reload sans Firestore).
Uri? buildPaywallSubscribeUri({
  String? firebaseEmail,
  String? firebaseUid,
}) {
  return _buildPaywallSubscribeUriFromBase(
    kPaywallSubscribeLaunchUrl,
    firebaseEmail: firebaseEmail,
    firebaseUid: firebaseUid,
  );
}

/// Résout l’URL (dart-define puis Firestore admin), puis construit l’URI finale.
Future<Uri?> buildPaywallSubscribeUriAsync({
  String? firebaseEmail,
  String? firebaseUid,
}) async {
  final base = await PaychekBillingRemote.resolveStripeCheckoutBaseUrl(
    kPaywallSubscribeLaunchUrl,
  );
  if (base == null || base.trim().isEmpty) return null;
  return _buildPaywallSubscribeUriFromBase(
    base,
    firebaseEmail: firebaseEmail,
    firebaseUid: firebaseUid,
  );
}
