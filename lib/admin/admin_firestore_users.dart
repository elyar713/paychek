import 'package:cloud_firestore/cloud_firestore.dart';

import '../reglage/paychek_user_firestore.dart';
import '../reglage/reglage_language_prefs.dart';
import 'admin_models.dart';

String _adminFirestoreStr(Object? v) => v?.toString().trim() ?? '';

/// Même convention que le client : chaine Auth type « Prénom Nom ».
(String firstName, String lastName) _adminNamesFromDisplayField(String dn) {
  final t = dn.trim();
  if (t.isEmpty) return ('', '');
  final parts = t.split(RegExp(r'\s+'));
  if (parts.length == 1) return (parts.single, '');
  return (parts.first, parts.sublist(1).join(' '));
}

AdminUserRow adminUserRowFromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  final d = doc.data() ?? {};
  final email = d['email'] as String? ?? '';
  final created = paychekResolveUserJoinedAtUtc(d) ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  final country = (d['country'] as String?)?.trim();
  var firstName = _adminFirestoreStr(d['firstName']);
  var lastName = _adminFirestoreStr(d['lastName']);
  if (firstName.isEmpty && lastName.isEmpty) {
    final inferred = _adminNamesFromDisplayField(_adminFirestoreStr(d['displayName']));
    firstName = inferred.$1;
    lastName = inferred.$2;
  }

  DateTime? birthDate;
  final birthRaw = d['birthDate'];
  if (birthRaw is Timestamp) {
    final t = birthRaw.toDate().toUtc();
    birthDate = DateTime.utc(t.year, t.month, t.day);
  }
  var paymentMethod = _adminFirestoreStr(d['paymentMethod']);
  if (paymentMethod.isEmpty) {
    final stripeCustomer = _adminFirestoreStr(d['stripeCustomerId']);
    if (stripeCustomer.isNotEmpty) {
      paymentMethod = 'stripe';
    } else if (PaychekSubscriptionTierX.fromFirestoreMap(d) ==
        PaychekSubscriptionTier.pro) {
      final provider = _adminFirestoreStr(d['paymentProvider']);
      if (provider == 'stripe') paymentMethod = 'stripe';
    }
  }
  final platformsRaw = d['platformsSeen'];
  final platformsSeen = <String>[
    if (platformsRaw is List)
      for (final e in platformsRaw)
        '$e'.trim().toLowerCase(),
  ].where((s) => s.isNotEmpty).toSet().toList(growable: false);
  platformsSeen.sort();
  final lastPlat = (d['lastSeenPlatform'] as String?)?.trim().toLowerCase() ?? '';
  final accessWeb = d['accessWebEnabled'] != false;
  final accessMobile = d['accessMobileEnabled'] != false;

  final langRaw =
      _adminFirestoreStr(d['appLanguageCode']).toLowerCase();
  final appLang = ReglageLanguagePrefs.availableCodes.contains(langRaw)
      ? langRaw
      : '';

  DateTime? trialOverride;
  final rawOv = d[kPaychekUserFieldTrialFreemiumOverrideUntil];
  if (rawOv is Timestamp) {
    trialOverride = rawOv.toDate().toUtc();
  }

  DateTime? subscriptionTierUpdatedAt;
  final rawTierUp = d[kPaychekUserFieldSubscriptionTierUpdatedAt];
  if (rawTierUp is Timestamp) {
    subscriptionTierUpdatedAt = rawTierUp.toDate().toUtc();
  }

  DateTime? subscriptionCurrentPeriodEnd;
  final rawSubEnd = d[kPaychekUserFieldSubscriptionCurrentPeriodEnd];
  if (rawSubEnd is Timestamp) {
    subscriptionCurrentPeriodEnd = rawSubEnd.toDate().toUtc();
  }

  DateTime? subscriptionProSinceUtc;
  final rawSubSince = d[kPaychekUserFieldSubscriptionProSinceUtc];
  if (rawSubSince is Timestamp) {
    subscriptionProSinceUtc = rawSubSince.toDate().toUtc();
  }

  DateTime? lastSeenAt;
  final rawSeen = d['lastSeenAt'];
  if (rawSeen is Timestamp) {
    lastSeenAt = rawSeen.toDate().toUtc();
  }

  final appOpenDatesUtc = <String>[];
  final rawOpenDays = d[kPaychekUserFieldAppOpenDatesUtcV1];
  if (rawOpenDays is List) {
    for (final e in rawOpenDays) {
      final s = '$e'.trim();
      if (s.length >= 10 && RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(s)) {
        appOpenDatesUtc.add(s.substring(0, 10));
      }
    }
  }
  appOpenDatesUtc.sort();

  return AdminUserRow(
    id: doc.id,
    email: email.isEmpty ? '(sans email)' : email,
    joinedAt: created,
    country: (country == null || country.isEmpty) ? '—' : country,
    subscriptionTier: PaychekSubscriptionTierX.fromFirestoreMap(d),
    firstName: firstName,
    lastName: lastName,
    birthDate: birthDate,
    paymentMethod: paymentMethod,
    importedTrades: (d['importedTrades'] as num?)?.toInt() ?? 0,
    platformsSeen: platformsSeen,
    lastSeenPlatform: lastPlat,
    accessWebEnabled: accessWeb,
    accessMobileEnabled: accessMobile,
    appLanguageCode: appLang,
    trialFreemiumOverrideUntil: trialOverride,
    lastSeenAt: lastSeenAt,
    appOpenDatesUtc: appOpenDatesUtc,
    subscriptionTierUpdatedAt: subscriptionTierUpdatedAt,
    subscriptionCurrentPeriodEnd: subscriptionCurrentPeriodEnd,
    subscriptionProSinceUtc: subscriptionProSinceUtc,
  );
}

Query<Map<String, dynamic>> paychekUsersOrderedQuery() => FirebaseFirestore
    .instance
    .collection(kPaychekUsersCollection)
    .orderBy('lastSeenAt', descending: true);
