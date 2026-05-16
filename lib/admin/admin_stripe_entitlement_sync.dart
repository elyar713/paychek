import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'admin_support_send_email.dart';

/// Résultat de [paychekAdminSyncStripeEntitlement].
class PaychekAdminStripeSyncResult {
  const PaychekAdminStripeSyncResult({
    required this.active,
    this.reason,
    this.stripeKeyMode,
  });

  final bool active;
  final String? reason;
  final String? stripeKeyMode;
}

/// Demande au backend de relier un paiement Stripe au compte Firebase cible.
Future<PaychekAdminStripeSyncResult> paychekAdminSyncStripeEntitlement({
  required String targetUserId,
}) async {
  final uid = targetUserId.trim();
  if (uid.isEmpty) {
    return const PaychekAdminStripeSyncResult(active: false);
  }
  final fn =
      FirebaseFunctions.instanceFor(region: kPaychekSupportFunctionsRegion);
  try {
    final result = await fn
        .httpsCallable('adminSyncPaychekStripeEntitlement')
        .call<Object?>(<String, dynamic>{'targetUserId': uid});
    final data = result.data;
    if (data is! Map) {
      return const PaychekAdminStripeSyncResult(active: false);
    }
    return PaychekAdminStripeSyncResult(
      active: data['active'] == true,
      reason: data['reason']?.toString(),
      stripeKeyMode: data['stripeKeyMode']?.toString(),
    );
  } on FirebaseFunctionsException catch (e, st) {
    debugPrint(
      '[Paychek] adminSyncPaychekStripeEntitlement ${e.code}: ${e.message}\n$st',
    );
    rethrow;
  } catch (e, st) {
    debugPrint('[Paychek] adminSyncPaychekStripeEntitlement $e\n$st');
    rethrow;
  }
}
