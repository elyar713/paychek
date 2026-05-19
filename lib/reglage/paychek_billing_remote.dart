import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'paychek_billing_plan.dart';

/// Document unique : réglages facturation web (Stripe Payment Link, etc.).
/// Écriture réservée aux comptes **admin** — voir `firestore.rules`.
const String kPaychekAppConfigCollection = 'paychek_app_config';
const String kPaychekBillingDocId = 'billing';

/// Clés Stripe (pk / sk) — lecture / écriture **admin** uniquement (`firestore.rules`).
const String kPaychekStripeKeysDocId = 'stripe_keys';

const String kFieldStripePublishableKey = 'stripePublishableKey';
const String kFieldStripeSecretKey = 'stripeSecretKey';

const String kFieldStripeCheckoutUrl = 'stripeCheckoutUrl';
const String kFieldStripeCheckoutUrlMonthly = 'stripeCheckoutUrlMonthly';
const String kFieldStripeCheckoutUrlQuarterly = 'stripeCheckoutUrlQuarterly';
const String kFieldStripeCheckoutUrlAnnual = 'stripeCheckoutUrlAnnual';
const String kFieldStripeBillingEnabled = 'stripeBillingEnabled';

class PaychekStripeCheckoutUrls {
  const PaychekStripeCheckoutUrls({
    this.monthly,
    this.quarterly,
    this.annual,
  });

  final String? monthly;
  final String? quarterly;
  final String? annual;

  String? forCycle(PaychekBillingCycle cycle) => switch (cycle) {
        PaychekBillingCycle.monthly => monthly,
        PaychekBillingCycle.quarterly => quarterly,
        PaychekBillingCycle.annual => annual,
      };
}

/// Cache court pour limiter les lectures Firestore (paywall, profil).
abstract final class PaychekBillingRemote {
  PaychekBillingRemote._();

  static PaychekStripeCheckoutUrls? _cachedUrls;
  static bool _cacheValid = false;
  static DateTime? _cachedAt;
  static const Duration _ttl = Duration(minutes: 2);

  static void invalidateCache() {
    _cachedUrls = null;
    _cacheValid = false;
    _cachedAt = null;
  }

  static String? _firstNonEmpty(Iterable<String?> values) {
    for (final v in values) {
      final t = v?.trim() ?? '';
      if (t.isNotEmpty) return t;
    }
    return null;
  }

  static PaychekStripeCheckoutUrls mergeCompileAndRemote({
    required String compileMonthly,
    required String compileQuarterly,
    required String compileAnnual,
    required String compileLegacyAnnual,
    required Map<String, dynamic> remote,
  }) {
    final legacy = '${remote[kFieldStripeCheckoutUrl] ?? ''}'.trim();
    return PaychekStripeCheckoutUrls(
      monthly: _firstNonEmpty([
        compileMonthly,
        '${remote[kFieldStripeCheckoutUrlMonthly] ?? ''}'.trim(),
      ]),
      quarterly: _firstNonEmpty([
        compileQuarterly,
        '${remote[kFieldStripeCheckoutUrlQuarterly] ?? ''}'.trim(),
      ]),
      annual: _firstNonEmpty([
        compileAnnual,
        '${remote[kFieldStripeCheckoutUrlAnnual] ?? ''}'.trim(),
        compileLegacyAnnual,
        legacy,
      ]),
    );
  }

  static Future<PaychekStripeCheckoutUrls?> resolveStripeCheckoutUrls({
    String compileMonthly = '',
    String compileQuarterly = '',
    String compileAnnual = '',
    String compileLegacyAnnual = '',
  }) async {
    final hasCompile = [
      compileMonthly,
      compileQuarterly,
      compileAnnual,
      compileLegacyAnnual,
    ].any((s) => s.trim().isNotEmpty);

    final now = DateTime.now();
    if (_cacheValid &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _ttl &&
        _cachedUrls != null) {
      return _cachedUrls;
    }

    if (hasCompile) {
      _cachedUrls = PaychekStripeCheckoutUrls(
        monthly: compileMonthly.trim().isEmpty ? null : compileMonthly.trim(),
        quarterly:
            compileQuarterly.trim().isEmpty ? null : compileQuarterly.trim(),
        annual: _firstNonEmpty([compileAnnual, compileLegacyAnnual]),
      );
      _cacheValid = true;
      _cachedAt = now;
      return _cachedUrls;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection(kPaychekAppConfigCollection)
          .doc(kPaychekBillingDocId)
          .get();
      if (!snap.exists) {
        _cachedUrls = const PaychekStripeCheckoutUrls();
        _cacheValid = true;
        _cachedAt = now;
        return null;
      }
      final d = snap.data() ?? {};
      final enabled = d[kFieldStripeBillingEnabled];
      final billingOn = enabled is! bool || enabled == true;
      if (!billingOn) {
        _cachedUrls = const PaychekStripeCheckoutUrls();
        _cacheValid = true;
        _cachedAt = now;
        return null;
      }
      _cachedUrls = mergeCompileAndRemote(
        compileMonthly: compileMonthly,
        compileQuarterly: compileQuarterly,
        compileAnnual: compileAnnual,
        compileLegacyAnnual: compileLegacyAnnual,
        remote: d,
      );
      _cacheValid = true;
      _cachedAt = now;
      final urls = _cachedUrls!;
      if (urls.monthly == null &&
          urls.quarterly == null &&
          urls.annual == null) {
        return null;
      }
      return urls;
    } catch (e, st) {
      debugPrint('[PaychekBillingRemote] $e\n$st');
      _cachedUrls = const PaychekStripeCheckoutUrls();
      _cacheValid = true;
      _cachedAt = now;
      return null;
    }
  }

  static Future<String?> resolveStripeCheckoutBaseUrl(
    String compileTimeUrl,
  ) async {
    final urls = await resolveStripeCheckoutUrls(
      compileLegacyAnnual: compileTimeUrl,
    );
    return urls?.annual ?? urls?.monthly ?? urls?.quarterly;
  }
}
