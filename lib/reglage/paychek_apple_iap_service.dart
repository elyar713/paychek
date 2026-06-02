import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';

import 'paychek_apple_entitlement_sync.dart';
import 'paychek_apple_iap_product_ids.dart';
import 'paychek_billing_plan.dart';

enum PaychekAppleIapPurchaseOutcome {
  success,
  cancelled,
  storeUnavailable,
  productUnavailable,
  notSignedIn,
  verificationFailed,
  error,
}

/// Achats in-app iOS (StoreKit) — abonnements Pro Paychek.
abstract final class PaychekAppleIapService {
  PaychekAppleIapService._();

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  static bool _initialized = false;
  static bool _available = false;

  static final Map<String, Completer<PaychekAppleIapPurchaseOutcome>> _pending =
      {};

  static bool get isSupported =>
      !kIsWeb && Platform.isIOS;

  static Future<void> ensureInitialized() async {
    if (!isSupported || _initialized) return;
    _initialized = true;
    _available = await _iap.isAvailable();
    _purchaseSub ??= _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object e, StackTrace st) {
        debugPrint('[Paychek] Apple IAP stream $e\n$st');
      },
    );
  }

  static Future<PaychekAppleIapPurchaseOutcome> purchase({
    required PaychekBillingCycle cycle,
  }) async {
    if (!isSupported) {
      return PaychekAppleIapPurchaseOutcome.storeUnavailable;
    }
    await ensureInitialized();
    if (!_available) {
      return PaychekAppleIapPurchaseOutcome.storeUnavailable;
    }

    final productId = PaychekAppleIapProductIds.forCycle(cycle);
    final response = await _iap.queryProductDetails({productId});
    if (response.error != null) {
      debugPrint('[Paychek] queryProductDetails ${response.error}');
      return PaychekAppleIapPurchaseOutcome.productUnavailable;
    }
    if (response.productDetails.isEmpty) {
      return PaychekAppleIapPurchaseOutcome.productUnavailable;
    }
    final product = response.productDetails.first;

    final completer = Completer<PaychekAppleIapPurchaseOutcome>();
    _pending[productId] = completer;

    final started = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
    if (!started) {
      _pending.remove(productId);
      return PaychekAppleIapPurchaseOutcome.error;
    }

    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        _pending.remove(productId);
        return PaychekAppleIapPurchaseOutcome.error;
      },
    );
  }

  static Future<PaychekAppleIapPurchaseOutcome> restorePurchases() async {
    if (!isSupported) {
      return PaychekAppleIapPurchaseOutcome.storeUnavailable;
    }
    await ensureInitialized();
    if (!_available) {
      return PaychekAppleIapPurchaseOutcome.storeUnavailable;
    }

    const restoreKey = '__restore__';
    final completer = Completer<PaychekAppleIapPurchaseOutcome>();
    _pending[restoreKey] = completer;

    await _iap.restorePurchases();

    return completer.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () {
        _pending.remove(restoreKey);
        return PaychekAppleIapPurchaseOutcome.verificationFailed;
      },
    );
  }

  static Future<void> _onPurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    var restoreHandled = false;
    for (final purchase in purchases) {
      final productId = purchase.productID;
      if (!PaychekAppleIapProductIds.all.contains(productId)) {
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
            PaychekAppleIapPurchaseOutcome.error,
          );
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          _completePending(
            pendingKey,
            PaychekAppleIapPurchaseOutcome.cancelled,
          );
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final jws = purchase.verificationData.serverVerificationData;
          final ok = await PaychekAppleEntitlementSync.verifySignedTransaction(
            productId: productId,
            signedTransaction: jws,
          );
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          if (ok && restoreMode) restoreHandled = true;
          _completePending(
            pendingKey,
            ok
                ? PaychekAppleIapPurchaseOutcome.success
                : PaychekAppleIapPurchaseOutcome.verificationFailed,
          );
          break;
      }
    }

    if (_pending.containsKey('__restore__') &&
        !restoreHandled &&
        purchases.isEmpty) {
      _completePending(
        '__restore__',
        PaychekAppleIapPurchaseOutcome.verificationFailed,
      );
    }
  }

  static void _completePending(
    String key,
    PaychekAppleIapPurchaseOutcome outcome,
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
        c.complete(PaychekAppleIapPurchaseOutcome.error);
      }
    }
    _pending.clear();
  }
}
