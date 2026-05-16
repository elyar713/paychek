import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'admin_support_send_email.dart';

/// Résultat de [paychekAdminNotifyUserRefundEmail].
class PaychekAdminRefundNotifyResult {
  const PaychekAdminRefundNotifyResult({
    required this.ok,
    this.amountLabel,
    this.message,
  });

  final bool ok;
  final String? amountLabel;
  final String? message;
}

/// Envoie uniquement l’e-mail informatif de remboursement (montant saisi par l’admin).
/// Le virement Stripe reste manuel depuis le Dashboard Stripe.
Future<PaychekAdminRefundNotifyResult> paychekAdminNotifyUserRefundEmail({
  required String targetUserId,
  required String amountLabel,
}) async {
  final uid = targetUserId.trim();
  final amount = amountLabel.trim();
  if (uid.isEmpty) {
    return const PaychekAdminRefundNotifyResult(ok: false, message: 'UID vide');
  }
  if (amount.isEmpty) {
    return const PaychekAdminRefundNotifyResult(
      ok: false,
      message: 'Indiquez le montant (ex. 35 \$).',
    );
  }
  final fn =
      FirebaseFunctions.instanceFor(region: kPaychekSupportFunctionsRegion);
  try {
    final result = await fn.httpsCallable('adminNotifyUserRefundEmail').call<
        Object?>(
      <String, dynamic>{
        'targetUserId': uid,
        'amountLabel': amount,
      },
    );
    final data = result.data;
    if (data is! Map) {
      return const PaychekAdminRefundNotifyResult(
        ok: false,
        message: 'Réponse invalide.',
      );
    }
    final ok = data['ok'] == true;
    final al = data['amountLabel']?.toString();
    return PaychekAdminRefundNotifyResult(ok: ok, amountLabel: al);
  } on FirebaseFunctionsException catch (e, st) {
    debugPrint(
      '[Paychek] adminNotifyUserRefundEmail ${e.code}: ${e.message}\n$st',
    );
    return PaychekAdminRefundNotifyResult(
      ok: false,
      message: (e.message ?? e.code).trim().isEmpty ? e.code : e.message,
    );
  } catch (e, st) {
    debugPrint('[Paychek] adminNotifyUserRefundEmail $e\n$st');
    return PaychekAdminRefundNotifyResult(ok: false, message: '$e');
  }
}
