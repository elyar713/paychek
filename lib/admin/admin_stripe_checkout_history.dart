import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'admin_support_send_email.dart';

/// Ligne renvoyée par [paychekAdminListStripeCheckoutSessions].
class StripeCheckoutSessionPreview {
  const StripeCheckoutSessionPreview({
    required this.idDisplay,
    required this.amountMajor,
    required this.currencyCode,
    required this.statusLabel,
    required this.email,
    required this.createdAtUtc,
  });

  /// Payment Intent si présent, sinon ID session Checkout.
  final String idDisplay;
  final double amountMajor;
  final String currencyCode;

  /// Libellé court FR pour l’UI.
  final String statusLabel;
  final String email;
  final DateTime createdAtUtc;
}

class PaychekStripeCheckoutHistoryResult {
  const PaychekStripeCheckoutHistoryResult({
    required this.sessions,
    this.stripeKeyMode,
    this.errorMessage,
  });

  final List<StripeCheckoutSessionPreview> sessions;
  final String? stripeKeyMode;

  /// Erreur réseau / callable ; vide si succès.
  final String? errorMessage;
}

double _stripeAmountToMajor(int? totalCents, String currency) {
  if (totalCents == null) return 0;
  switch (currency.toLowerCase()) {
    case 'jpy':
    case 'krw':
    case 'vnd':
    case 'clp':
    case 'ugx':
      return totalCents.toDouble();
    default:
      return totalCents / 100.0;
  }
}

String _stripeSessionStatusFr(String paymentStatus, String status) {
  final ps = paymentStatus.trim().toLowerCase();
  final st = status.trim().toLowerCase();
  if (st == 'complete' && ps == 'paid') return 'Réussi';
  if (st == 'complete') return 'Terminé';
  if (st == 'open') return 'Ouverte';
  if (st == 'expired') return 'Expirée';
  if (ps == 'unpaid') return 'Non payé';
  if (paymentStatus.isNotEmpty) return paymentStatus;
  if (status.isNotEmpty) return status;
  return '—';
}

StripeCheckoutSessionPreview? _parseSessionRow(Object? raw) {
  if (raw is! Map) return null;
  final m = raw.map((k, v) => MapEntry('$k', v));
  final checkoutId = '${m['checkoutSessionId'] ?? ''}'.trim();
  final pi = '${m['paymentIntentId'] ?? ''}'.trim();
  final idDisplay = pi.isNotEmpty ? pi : checkoutId;
  if (idDisplay.isEmpty) return null;

  final cur = '${m['currency'] ?? 'usd'}'.trim().toLowerCase();
  final amountRaw = m['amountTotal'];
  final cents = amountRaw is num ? amountRaw.toInt() : int.tryParse('$amountRaw');
  final major = _stripeAmountToMajor(cents, cur);

  final createdRaw = m['created'];
  final createdUnix =
      createdRaw is num ? createdRaw.toInt() : int.tryParse('$createdRaw') ?? 0;
  final createdAtUtc = DateTime.fromMillisecondsSinceEpoch(
    createdUnix * 1000,
    isUtc: true,
  );

  return StripeCheckoutSessionPreview(
    idDisplay: idDisplay,
    amountMajor: major,
    currencyCode: cur,
    statusLabel: _stripeSessionStatusFr(
      '${m['paymentStatus'] ?? ''}',
      '${m['status'] ?? ''}',
    ),
    email: '${m['email'] ?? ''}'.trim(),
    createdAtUtc: createdAtUtc,
  );
}

/// Charge les dernières Checkout Sessions via Cloud Function (claim `admin`).
Future<PaychekStripeCheckoutHistoryResult> paychekAdminListStripeCheckoutSessions({
  int limit = 25,
}) async {
  final fn =
      FirebaseFunctions.instanceFor(region: kPaychekSupportFunctionsRegion);
  try {
    final clamped = limit.clamp(1, 50);
    final result = await fn
        .httpsCallable('adminListStripeCheckoutSessions')
        .call<Object?>(<String, dynamic>{'limit': clamped});
    final data = result.data;
    if (data is! Map) {
      return const PaychekStripeCheckoutHistoryResult(
        sessions: [],
        errorMessage: 'Réponse invalide.',
      );
    }
    final mode = data['stripeKeyMode']?.toString();
    final list = data['sessions'];
    final out = <StripeCheckoutSessionPreview>[];
    if (list is List) {
      for (final e in list) {
        final row = _parseSessionRow(e);
        if (row != null) out.add(row);
      }
    }
    return PaychekStripeCheckoutHistoryResult(
      sessions: out,
      stripeKeyMode: mode,
    );
  } on FirebaseFunctionsException catch (e, st) {
    debugPrint(
      '[Paychek] adminListStripeCheckoutSessions ${e.code}: ${e.message}\n$st',
    );
    final detail = (e.message ?? e.code).trim();
    return PaychekStripeCheckoutHistoryResult(
      sessions: const [],
      errorMessage: detail.isEmpty ? e.code : detail,
    );
  } catch (e, st) {
    debugPrint('[Paychek] adminListStripeCheckoutSessions $e\n$st');
    return PaychekStripeCheckoutHistoryResult(
      sessions: const [],
      errorMessage: '$e',
    );
  }
}

String formatStripeMajorCurrency(double major, String currencyCode) {
  final c = currencyCode.trim().toUpperCase();
  if (c == 'JPY' ||
      c == 'KRW' ||
      c == 'VND' ||
      c == 'CLP' ||
      c == 'UGX') {
    return '${major.round()} $c';
  }
  return '${major.toStringAsFixed(2)} $c';
}
