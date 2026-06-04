import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'admin_support_send_email.dart';

class PaychekAdminAppleSyncResult {
  const PaychekAdminAppleSyncResult({
    required this.active,
    this.reason,
    this.currentPeriodEndUtc,
    this.message,
  });

  final bool active;
  final String? reason;
  final DateTime? currentPeriodEndUtc;
  final String? message;
}

/// Re-synchronise l’abonnement Apple stocké dans Firestore (admin).
Future<PaychekAdminAppleSyncResult> paychekAdminSyncAppleEntitlement({
  required String targetUserId,
  String? transferFromUid,
}) async {
  final uid = targetUserId.trim();
  if (uid.isEmpty) {
    return const PaychekAdminAppleSyncResult(active: false);
  }
  final fn =
      FirebaseFunctions.instanceFor(region: kPaychekSupportFunctionsRegion);
  try {
    final payload = <String, dynamic>{'targetUserId': uid};
    final from = transferFromUid?.trim();
    if (from != null && from.isNotEmpty) {
      payload['transferFromUid'] = from;
    }
    final result = await fn
        .httpsCallable('syncPaychekAppleEntitlement')
        .call<Object?>(payload);
    final data = result.data;
    if (data is! Map) {
      return const PaychekAdminAppleSyncResult(active: false);
    }
    DateTime? periodEnd;
    final ms = data['currentPeriodEndMillis'];
    if (ms is num && ms > 0) {
      periodEnd = DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: true);
    }
    return PaychekAdminAppleSyncResult(
      active: data['active'] == true,
      reason: data['reason']?.toString(),
      currentPeriodEndUtc: periodEnd,
      message: data['message']?.toString(),
    );
  } on FirebaseFunctionsException catch (e, st) {
    debugPrint(
      '[Paychek] syncPaychekAppleEntitlement ${e.code}: ${e.message}\n$st',
    );
    if (e.code == 'internal' &&
        (e.message == null || e.message == 'internal')) {
      throw FirebaseFunctionsException(
        code: 'not-found',
        message:
            'Fonction syncPaychekAppleEntitlement absente. '
            'Déploie : firebase deploy --only functions:syncPaychekAppleEntitlement',
      );
    }
    rethrow;
  } catch (e, st) {
    debugPrint('[Paychek] syncPaychekAppleEntitlement $e\n$st');
    rethrow;
  }
}
