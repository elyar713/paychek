import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../reglage/paychek_user_firestore.dart';
import 'admin_stripe_checkout_history.dart';
import 'admin_support_send_email.dart';

double _amountToMajor(int? totalCents, String currency) {
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

/// Canal de paiement pour une ligne d’historique admin.
enum AdminPaymentProvider {
  stripe,
  appleIap,
  googlePlay,
}

/// Ligne d’historique paiement (Stripe, App Store ou Google Play).
class AdminUserPaymentLine {
  const AdminUserPaymentLine({
    required this.provider,
    required this.checkoutSessionId,
    required this.paymentIntentId,
    required this.transactionId,
    required this.originalTransactionId,
    required this.productId,
    required this.amountMajor,
    required this.refundedMajor,
    required this.currencyCode,
    required this.paymentStatus,
    required this.sessionStatus,
    required this.displayStatus,
    required this.cycleHint,
    required this.failureMessage,
    required this.email,
    required this.createdAtUtc,
    this.expiresAtUtc,
    this.environment = '',
  });

  final AdminPaymentProvider provider;
  final String checkoutSessionId;
  final String paymentIntentId;
  final String transactionId;
  final String originalTransactionId;
  final String productId;
  final double amountMajor;
  final double refundedMajor;
  final String currencyCode;
  final String paymentStatus;
  final String sessionStatus;
  final String displayStatus;
  final String cycleHint;
  final String failureMessage;
  final String email;
  final DateTime createdAtUtc;
  final DateTime? expiresAtUtc;
  final String environment;

  bool get isApple => provider == AdminPaymentProvider.appleIap;
  bool get isGooglePlay => provider == AdminPaymentProvider.googlePlay;
  bool get isStoreIap => isApple || isGooglePlay;

  String get amountLabel {
    if (amountMajor <= 0 && isStoreIap) return '—';
    return formatStripeMajorCurrency(amountMajor, currencyCode);
  }

  String get refundedLabel => refundedMajor > 0
      ? formatStripeMajorCurrency(refundedMajor, currencyCode)
      : '';

  String get referenceId {
    if (isStoreIap && transactionId.isNotEmpty) return transactionId;
    return paymentIntentId.isNotEmpty ? paymentIntentId : checkoutSessionId;
  }

  String get providerLabel => switch (provider) {
        AdminPaymentProvider.stripe => 'Stripe',
        AdminPaymentProvider.appleIap => 'Apple',
        AdminPaymentProvider.googlePlay => 'Google Play',
      };
}

class AdminUserPaymentHistoryResult {
  const AdminUserPaymentHistoryResult({
    required this.payments,
    this.stripeKeyMode,
    this.appleConfigured,
    this.appleError,
    this.googleConfigured,
    this.googleError,
    this.errorMessage,
  });

  final List<AdminUserPaymentLine> payments;
  final String? stripeKeyMode;
  final bool? appleConfigured;
  final String? appleError;
  final bool? googleConfigured;
  final String? googleError;
  final String? errorMessage;
}

AdminPaymentProvider _parseProvider(Object? raw) {
  final p = '${raw ?? ''}'.trim().toLowerCase();
  if (p == 'apple_iap' || p == 'apple') {
    return AdminPaymentProvider.appleIap;
  }
  if (p == 'google_play' || p == 'google') {
    return AdminPaymentProvider.googlePlay;
  }
  return AdminPaymentProvider.stripe;
}

AdminUserPaymentLine? _parsePaymentRow(Object? raw) {
  if (raw is! Map) return null;
  final m = raw.map((k, v) => MapEntry('$k', v));
  final provider = _parseProvider(m['provider']);
  final checkoutId = '${m['checkoutSessionId'] ?? ''}'.trim();
  final transactionId = '${m['transactionId'] ?? ''}'.trim();

  if (provider == AdminPaymentProvider.stripe && checkoutId.isEmpty) {
    return null;
  }
  if (provider != AdminPaymentProvider.stripe && transactionId.isEmpty) {
    return null;
  }

  final cur = '${m['currency'] ?? 'usd'}'.trim().toLowerCase();

  final majorRaw = m['amountMajor'];
  double major;
  if (majorRaw is num) {
    major = majorRaw.toDouble();
  } else {
    final centsRaw = m['amountTotal'];
    final cents =
        centsRaw is num ? centsRaw.toInt() : int.tryParse('$centsRaw');
    major = _amountToMajor(cents, cur);
  }

  final refRaw = m['amountRefunded'];
  final refCents =
      refRaw is num ? refRaw.toInt() : int.tryParse('$refRaw') ?? 0;
  final refundedMajor = _amountToMajor(refCents, cur);

  final createdRaw = m['created'];
  final createdUnix =
      createdRaw is num ? createdRaw.toInt() : int.tryParse('$createdRaw') ?? 0;

  final expiresRaw = m['expiresDate'];
  final expiresUnix =
      expiresRaw is num ? expiresRaw.toInt() : int.tryParse('$expiresRaw');
  final expiresAt = expiresUnix != null && expiresUnix > 0
      ? DateTime.fromMillisecondsSinceEpoch(expiresUnix * 1000, isUtc: true)
      : null;

  final pi = '${m['paymentIntentId'] ?? ''}'.trim();

  return AdminUserPaymentLine(
    provider: provider,
    checkoutSessionId: checkoutId,
    paymentIntentId: pi,
    transactionId: transactionId,
    originalTransactionId: '${m['originalTransactionId'] ?? ''}'.trim(),
    productId: '${m['productId'] ?? ''}'.trim(),
    amountMajor: major,
    refundedMajor: refundedMajor,
    currencyCode: cur,
    paymentStatus: '${m['paymentStatus'] ?? ''}'.trim(),
    sessionStatus: '${m['sessionStatus'] ?? ''}'.trim(),
    displayStatus: '${m['displayStatus'] ?? '—'}'.trim(),
    cycleHint: '${m['cycleHint'] ?? ''}'.trim(),
    failureMessage: '${m['failureMessage'] ?? ''}'.trim(),
    email: '${m['email'] ?? ''}'.trim(),
    createdAtUtc: DateTime.fromMillisecondsSinceEpoch(
      createdUnix * 1000,
      isUtc: true,
    ),
    expiresAtUtc: expiresAt,
    environment: '${m['environment'] ?? ''}'.trim(),
  );
}

/// Historique Stripe + Apple + Google Play d’un utilisateur.
Future<AdminUserPaymentHistoryResult> paychekAdminListUserBillingHistory({
  required String uid,
  required String email,
}) async {
  final id = uid.trim();
  if (id.isEmpty) {
    return const AdminUserPaymentHistoryResult(payments: []);
  }

  var stripeCustomerId = '';
  try {
    final snap = await FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(id)
        .get();
    stripeCustomerId = '${snap.data()?['stripeCustomerId'] ?? ''}'.trim();
  } catch (e, st) {
    debugPrint('[Paychek] read stripeCustomerId: $e\n$st');
  }

  final fn =
      FirebaseFunctions.instanceFor(region: kPaychekSupportFunctionsRegion);
  try {
    final result = await fn
        .httpsCallable('adminListUserBillingHistory')
        .call<Object?>(<String, dynamic>{
      'uid': id,
      'email': email.trim(),
      if (stripeCustomerId.isNotEmpty) 'stripeCustomerId': stripeCustomerId,
    });
    final data = result.data;
    if (data is! Map) {
      return const AdminUserPaymentHistoryResult(
        payments: [],
        errorMessage: 'Réponse invalide.',
      );
    }
    final list = data['payments'];
    final out = <AdminUserPaymentLine>[];
    if (list is List) {
      for (final e in list) {
        final row = _parsePaymentRow(e);
        if (row != null) out.add(row);
      }
    }
    out.sort((a, b) => b.createdAtUtc.compareTo(a.createdAtUtc));

    final appleErr = data['appleError']?.toString().trim();
    final googleErr = data['googleError']?.toString().trim();
    final fnError = data['errorMessage']?.toString().trim();
    final storeErr = [
      if (appleErr != null && appleErr.isNotEmpty) appleErr,
      if (googleErr != null && googleErr.isNotEmpty) googleErr,
    ].join(' · ');

    return AdminUserPaymentHistoryResult(
      payments: out,
      stripeKeyMode: data['stripeKeyMode']?.toString(),
      appleConfigured: data['appleConfigured'] == true,
      appleError: appleErr != null && appleErr.isNotEmpty ? appleErr : null,
      googleConfigured: data['googleConfigured'] == true,
      googleError: googleErr != null && googleErr.isNotEmpty ? googleErr : null,
      errorMessage: fnError != null && fnError.isNotEmpty
          ? fnError
          : (storeErr.isEmpty ? null : storeErr),
    );
  } on FirebaseFunctionsException catch (e, st) {
    debugPrint(
      '[Paychek] adminListUserBillingHistory ${e.code}: ${e.message}\n$st',
    );
    final detail = (e.message ?? e.code).trim();
    return AdminUserPaymentHistoryResult(
      payments: const [],
      errorMessage: detail.isEmpty ? e.code : detail,
    );
  } catch (e, st) {
    debugPrint('[Paychek] adminListUserBillingHistory $e\n$st');
    return AdminUserPaymentHistoryResult(
      payments: const [],
      errorMessage: '$e',
    );
  }
}
