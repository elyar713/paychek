import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'paychek_billing_plan.dart';
import 'paychek_google_entitlement_sync.dart';
import 'paychek_google_play_product_ids.dart';

enum PaychekGooglePlayIapPurchaseOutcome {
  success,
  cancelled,
  storeUnavailable,
  productUnavailable,
  notSignedIn,
  verificationFailed,
  error,
}

/// Achats in-app Android (Google Play Billing) — abonnements Pro Paychek.
abstract final class PaychekGooglePlayIapService {
  PaychekGooglePlayIapService._();

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  static bool _initialized = false;
  static bool _available = false;

  static final Map<String, Completer<PaychekGooglePlayIapPurchaseOutcome>>
      _pending = {};

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static Future<void> ensureInitialized() async {
    if (!isSupported || _initialized) return;
    _initialized = true;
    _available = await _iap.isAvailable();
    _purchaseSub ??= _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object e, StackTrace st) {
        debugPrint('[Paychek] Google Play IAP stream $e\n$st');
      },
    );
  }

  static Future<PaychekGooglePlayIapPurchaseOutcome> purchase({
    required PaychekBillingCycle cycle,
  }) async {
    if (!isSupported) {
      return PaychekGooglePlayIapPurchaseOutcome.storeUnavailable;
    }
    await ensureInitialized();
    if (!_available) {
      return PaychekGooglePlayIapPurchaseOutcome.storeUnavailable;
    }

    final productId = PaychekGooglePlayProductIds.forCycle(cycle);
    final response = await _iap.queryProductDetails({productId});
    if (response.error != null) {
      debugPrint('[Paychek] queryProductDetails ${response.error}');
      return PaychekGooglePlayIapPurchaseOutcome.productUnavailable;
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[Paychek] Play products not found: ${response.notFoundIDs}');
    }
    if (response.productDetails.isEmpty) {
      return PaychekGooglePlayIapPurchaseOutcome.productUnavailable;
    }

    final product = _pickGooglePlayProduct(response.productDetails, productId);
    if (product == null) {
      debugPrint('[Paychek] No GooglePlayProductDetails for $productId');
      return PaychekGooglePlayIapPurchaseOutcome.productUnavailable;
    }

    final offerToken = product.offerToken;
    if (offerToken == null || offerToken.isEmpty) {
      debugPrint('[Paychek] offerToken missing for $productId');
      return PaychekGooglePlayIapPurchaseOutcome.productUnavailable;
    }

    final completer = Completer<PaychekGooglePlayIapPurchaseOutcome>();
    _pending[productId] = completer;

    final started = await _iap.buyNonConsumable(
      purchaseParam: GooglePlayPurchaseParam(
        productDetails: product,
        offerToken: offerToken,
      ),
    );
    if (!started) {
      _pending.remove(productId);
      return PaychekGooglePlayIapPurchaseOutcome.error;
    }

    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        _pending.remove(productId);
        return PaychekGooglePlayIapPurchaseOutcome.error;
      },
    );
  }

  static Future<PaychekGooglePlayIapPurchaseOutcome> restorePurchases() async {
    if (!isSupported) {
      return PaychekGooglePlayIapPurchaseOutcome.storeUnavailable;
    }
    await ensureInitialized();
    if (!_available) {
      return PaychekGooglePlayIapPurchaseOutcome.storeUnavailable;
    }

    final synced = await _syncPastPurchasesFromPlay();
    if (synced == PaychekGooglePlayIapPurchaseOutcome.success) {
      return synced;
    }

    const restoreKey = '__restore__';
    final completer = Completer<PaychekGooglePlayIapPurchaseOutcome>();
    _pending[restoreKey] = completer;

    await _iap.restorePurchases();

    return completer.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () {
        _pending.remove(restoreKey);
        return synced;
      },
    );
  }

  /// Lit les abonnements actifs sur l’appareil et les valide côté serveur.
  static Future<PaychekGooglePlayIapPurchaseOutcome>
      _syncPastPurchasesFromPlay() async {
    try {
      final addition = InAppPurchase.instance
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await addition.queryPastPurchases();
      if (response.error != null) {
        debugPrint('[Paychek] queryPastPurchases ${response.error}');
      }
      for (final purchase in response.pastPurchases) {
        final productId = purchase.productID;
        if (!PaychekGooglePlayProductIds.isKnownProductId(productId)) {
          continue;
        }
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        var token = purchase.verificationData.serverVerificationData.trim();
        if (token.isEmpty) {
          token = purchase.billingClientPurchase.purchaseToken.trim();
        }
        if (token.isEmpty) continue;
        final ok = await PaychekGoogleEntitlementSync.verifyPurchase(
          productId: productId,
          purchaseToken: token,
        );
        if (ok) {
          return PaychekGooglePlayIapPurchaseOutcome.success;
        }
      }
    } catch (e, st) {
      debugPrint('[Paychek] _syncPastPurchasesFromPlay $e\n$st');
    }
    return PaychekGooglePlayIapPurchaseOutcome.verificationFailed;
  }

  static Future<void> _onPurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    var restoreHandled = false;
    for (final purchase in purchases) {
      final productId = purchase.productID;
      if (!PaychekGooglePlayProductIds.isKnownProductId(productId)) {
        continue;
      }
      final restoreMode = _pending.containsKey('__restore__');
      final pendingKey = restoreMode ? '__restore__' : productId;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          _completePending(
            pendingKey,
            PaychekGooglePlayIapPurchaseOutcome.error,
          );
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          _completePending(
            pendingKey,
            PaychekGooglePlayIapPurchaseOutcome.cancelled,
          );
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          var token = purchase.verificationData.serverVerificationData.trim();
          if (token.isEmpty && purchase is GooglePlayPurchaseDetails) {
            token = purchase.billingClientPurchase.purchaseToken.trim();
          }
          final ok = token.isNotEmpty &&
              await PaychekGoogleEntitlementSync.verifyPurchase(
            productId: productId,
            purchaseToken: token,
          );
          if (ok && restoreMode) restoreHandled = true;
          _completePending(
            pendingKey,
            ok
                ? PaychekGooglePlayIapPurchaseOutcome.success
                : PaychekGooglePlayIapPurchaseOutcome.verificationFailed,
          );
          break;
      }
    }

    if (_pending.containsKey('__restore__') &&
        !restoreHandled &&
        purchases.isEmpty) {
      _completePending(
        '__restore__',
        PaychekGooglePlayIapPurchaseOutcome.verificationFailed,
      );
    }
  }

  /// Choisit le [GooglePlayProductDetails] renvoyé par Play (forfait de base actif).
  static GooglePlayProductDetails? _pickGooglePlayProduct(
    List<ProductDetails> details,
    String productId,
  ) {
    GooglePlayProductDetails? fallback;
    for (final d in details) {
      if (d.id != productId) continue;
      if (d is! GooglePlayProductDetails) {
        debugPrint(
          '[Paychek] Expected GooglePlayProductDetails, got ${d.runtimeType}',
        );
        continue;
      }
      fallback ??= d;
      final token = d.offerToken;
      if (token != null && token.isNotEmpty) return d;
    }
    return fallback;
  }

  static void _completePending(
    String key,
    PaychekGooglePlayIapPurchaseOutcome outcome,
  ) {
    final c = _pending.remove(key);
    if (c != null && !c.isCompleted) {
      c.complete(outcome);
    }
  }

  static Future<void> dispose() async {
    await _purchaseSub?.cancel();
    _purchaseSub = null;
    _initialized = false;
    _available = false;
    for (final c in _pending.values) {
      if (!c.isCompleted) {
        c.complete(PaychekGooglePlayIapPurchaseOutcome.error);
      }
    }
    _pending.clear();
  }
}
