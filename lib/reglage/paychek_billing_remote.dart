import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Document unique : réglages facturation web (Stripe Payment Link, etc.).
/// Écriture réservée aux comptes **admin** — voir `firestore.rules`.
const String kPaychekAppConfigCollection = 'paychek_app_config';
const String kPaychekBillingDocId = 'billing';

const String kFieldStripeCheckoutUrl = 'stripeCheckoutUrl';
const String kFieldStripeBillingEnabled = 'stripeBillingEnabled';

/// Cache court pour limiter les lectures Firestore (paywall, profil).
abstract final class PaychekBillingRemote {
  PaychekBillingRemote._();

  static String? _cachedBaseUrl;
  static bool _cacheValid = false;
  static DateTime? _cachedAt;
  static const Duration _ttl = Duration(minutes: 2);

  static void invalidateCache() {
    _cachedBaseUrl = null;
    _cacheValid = false;
    _cachedAt = null;
  }

  /// [compileTimeUrl] : valeur `--dart-define=PAYCHEK_STRIPE_CHECKOUT_URL=...` (prioritaire).
  static Future<String?> resolveStripeCheckoutBaseUrl(
    String compileTimeUrl,
  ) async {
    final env = compileTimeUrl.trim();
    if (env.isNotEmpty) return env;

    final now = DateTime.now();
    if (_cacheValid &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _ttl &&
        _cachedBaseUrl != null) {
      final u = _cachedBaseUrl!.trim();
      return u.isEmpty ? null : u;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection(kPaychekAppConfigCollection)
          .doc(kPaychekBillingDocId)
          .get();
      if (!snap.exists) {
        _cachedBaseUrl = '';
        _cacheValid = true;
        _cachedAt = now;
        return null;
      }
      final d = snap.data() ?? {};
      final enabled = d[kFieldStripeBillingEnabled];
      final billingOn = enabled is! bool || enabled == true;
      if (!billingOn) {
        _cachedBaseUrl = '';
        _cacheValid = true;
        _cachedAt = now;
        return null;
      }
      final raw = '${d[kFieldStripeCheckoutUrl] ?? ''}'.trim();
      _cachedBaseUrl = raw;
      _cacheValid = true;
      _cachedAt = now;
      return raw.isEmpty ? null : raw;
    } catch (e, st) {
      debugPrint('[PaychekBillingRemote] $e\n$st');
      _cachedBaseUrl = '';
      _cacheValid = true;
      _cachedAt = now;
      return null;
    }
  }
}
