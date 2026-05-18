// Paywall : URL Stripe via --dart-define ou Firestore `paychek_app_config/billing`

import 'paychek_billing_plan.dart';
import 'paychek_billing_remote.dart';

const String kPaywallSubscribeLaunchUrl = String.fromEnvironment(
  'PAYCHEK_STRIPE_CHECKOUT_URL',
  defaultValue: '',
);

const String kPaywallSubscribeLaunchUrlMonthly = String.fromEnvironment(
  'PAYCHEK_STRIPE_CHECKOUT_URL_MONTHLY',
  defaultValue: '',
);

const String kPaywallSubscribeLaunchUrlQuarterly = String.fromEnvironment(
  'PAYCHEK_STRIPE_CHECKOUT_URL_QUARTERLY',
  defaultValue: '',
);

const String kPaywallSubscribeLaunchUrlAnnual = String.fromEnvironment(
  'PAYCHEK_STRIPE_CHECKOUT_URL_ANNUAL',
  defaultValue: '',
);

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

Uri? buildPaywallSubscribeUri({
  PaychekBillingCycle cycle = PaychekBillingCycle.annual,
  String? firebaseEmail,
  String? firebaseUid,
}) {
  final urls = PaychekBillingRemote.mergeCompileAndRemote(
    compileMonthly: kPaywallSubscribeLaunchUrlMonthly,
    compileQuarterly: kPaywallSubscribeLaunchUrlQuarterly,
    compileAnnual: kPaywallSubscribeLaunchUrlAnnual,
    compileLegacyAnnual: kPaywallSubscribeLaunchUrl,
    remote: const {},
  );
  final base = urls.forCycle(cycle);
  if (base == null || base.isEmpty) return null;
  return _buildPaywallSubscribeUriFromBase(
    base,
    firebaseEmail: firebaseEmail,
    firebaseUid: firebaseUid,
  );
}

Future<Uri?> buildPaywallSubscribeUriAsync({
  PaychekBillingCycle cycle = PaychekBillingCycle.annual,
  String? firebaseEmail,
  String? firebaseUid,
}) async {
  final urls = await PaychekBillingRemote.resolveStripeCheckoutUrls(
    compileMonthly: kPaywallSubscribeLaunchUrlMonthly,
    compileQuarterly: kPaywallSubscribeLaunchUrlQuarterly,
    compileAnnual: kPaywallSubscribeLaunchUrlAnnual,
    compileLegacyAnnual: kPaywallSubscribeLaunchUrl,
  );
  final base = urls?.forCycle(cycle);
  if (base == null || base.trim().isEmpty) return null;
  return _buildPaywallSubscribeUriFromBase(
    base,
    firebaseEmail: firebaseEmail,
    firebaseUid: firebaseUid,
  );
}
