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

class PaychekAppleTransferCandidate {
  const PaychekAppleTransferCandidate({
    required this.uid,
    required this.maskedEmail,
    this.appleProductId,
    this.currentPeriodEndUtc,
  });

  final String uid;
  final String maskedEmail;
  final String? appleProductId;
  final DateTime? currentPeriodEndUtc;

  static PaychekAppleTransferCandidate? fromDynamic(Object? raw) {
    if (raw is! Map) return null;
    final uid = raw['uid']?.toString().trim() ?? '';
    if (uid.isEmpty) return null;
    DateTime? periodEnd;
    final ms = raw['currentPeriodEndMillis'];
    if (ms is num && ms > 0) {
      periodEnd = DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: true);
    }
    return PaychekAppleTransferCandidate(
      uid: uid,
      maskedEmail: raw['maskedEmail']?.toString().trim() ?? uid,
      appleProductId: raw['appleProductId']?.toString().trim(),
      currentPeriodEndUtc: periodEnd,
    );
  }
}

List<PaychekAppleTransferCandidate> paychekAppleTransferCandidatesFromDetails(
  Object? details,
) {
  if (details is! Map) return const [];
  final raw = details['candidates'];
  if (raw is! List) return const [];
  return raw
      .map(PaychekAppleTransferCandidate.fromDynamic)
      .whereType<PaychekAppleTransferCandidate>()
      .toList();
}

/// Comptes Paychek avec un abonnement Apple actif (admin).
Future<List<PaychekAppleTransferCandidate>>
paychekAdminListAppleTransferCandidates({
  required String excludeUserId,
}) async {
  final exclude = excludeUserId.trim();
  if (exclude.isEmpty) return const [];
  final fn =
      FirebaseFunctions.instanceFor(region: kPaychekSupportFunctionsRegion);
  try {
    final result = await fn
        .httpsCallable('listPaychekAppleTransferCandidates')
        .call<Object?>(<String, dynamic>{'excludeUserId': exclude});
    final data = result.data;
    if (data is! Map) return const [];
    return paychekAppleTransferCandidatesFromDetails(data);
  } on FirebaseFunctionsException catch (e, st) {
    debugPrint(
      '[Paychek] listPaychekAppleTransferCandidates ${e.code}: ${e.message}\n$st',
    );
    rethrow;
  } catch (e, st) {
    debugPrint('[Paychek] listPaychekAppleTransferCandidates $e\n$st');
    rethrow;
  }
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
    if (e.code == 'failed-precondition') {
      debugPrint(
        '[Paychek] syncPaychekAppleEntitlement ${e.code}: ${e.message}',
      );
    } else {
      debugPrint(
        '[Paychek] syncPaychekAppleEntitlement ${e.code}: ${e.message}\n$st',
      );
    }
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
