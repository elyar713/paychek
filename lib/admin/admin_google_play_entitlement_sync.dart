import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'admin_support_send_email.dart';

class PaychekAdminGooglePlaySyncResult {
  const PaychekAdminGooglePlaySyncResult({
    required this.active,
    this.reason,
    this.currentPeriodEndUtc,
    this.message,
    this.subscriptionState,
  });

  final bool active;
  final String? reason;
  final DateTime? currentPeriodEndUtc;
  final String? message;
  final String? subscriptionState;
}

/// Re-vérifie l’abonnement Google Play stocké dans Firestore (token + produit).
Future<PaychekAdminGooglePlaySyncResult> paychekAdminSyncGooglePlayEntitlement({
  required String targetUserId,
}) async {
  final uid = targetUserId.trim();
  if (uid.isEmpty) {
    return const PaychekAdminGooglePlaySyncResult(active: false);
  }
  final fn =
      FirebaseFunctions.instanceFor(region: kPaychekSupportFunctionsRegion);
  try {
    final result = await fn
        .httpsCallable('syncPaychekGooglePlayEntitlement')
        .call<Object?>(<String, dynamic>{'targetUserId': uid});
    final data = result.data;
    if (data is! Map) {
      return const PaychekAdminGooglePlaySyncResult(active: false);
    }
    DateTime? periodEnd;
    final ms = data['currentPeriodEndMillis'];
    if (ms is num && ms > 0) {
      periodEnd = DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: true);
    }
    return PaychekAdminGooglePlaySyncResult(
      active: data['active'] == true,
      reason: data['reason']?.toString(),
      currentPeriodEndUtc: periodEnd,
      message: data['message']?.toString(),
      subscriptionState: data['subscriptionState']?.toString(),
    );
  } on FirebaseFunctionsException catch (e, st) {
    debugPrint(
      '[Paychek] syncPaychekGooglePlayEntitlement ${e.code}: ${e.message}\n$st',
    );
    if (e.code == 'internal' &&
        (e.message == null || e.message == 'internal')) {
      throw FirebaseFunctionsException(
        code: 'not-found',
        message:
            'Fonction syncPaychekGooglePlayEntitlement absente. '
            'Déploie : firebase deploy --only functions:syncPaychekGooglePlayEntitlement',
      );
    }
    rethrow;
  } catch (e, st) {
    debugPrint('[Paychek] syncPaychekGooglePlayEntitlement $e\n$st');
    rethrow;
  }
}
