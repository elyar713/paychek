import 'package:cloud_firestore/cloud_firestore.dart';

import '../reglage/paychek_user_firestore.dart';
import '../reglage/reglage_language_prefs.dart';
import '../reglage/trial_access_prefs.dart';
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
      final provider = _adminFirestoreStr(d['paymentProvider']).toLowerCase();
      paymentMethod = switch (provider) {
        'stripe' => 'stripe',
        'apple' || 'apple_iap' => 'apple_iap',
        'google' || 'google_play' => 'google_play',
        _ => paymentMethod,
      };
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

  final subscriptionCurrentPeriodEnd = paychekParseFirestoreInstantUtc(
    d[kPaychekUserFieldSubscriptionCurrentPeriodEnd],
  );
  final adminCompPeriodEnd = paychekParseFirestoreInstantUtc(
    d['adminCompPeriodEnd'],
  );
  final effectivePeriodEnd = _adminLatestPeriodEndUtc(
    subscriptionCurrentPeriodEnd,
    adminCompPeriodEnd,
  );

  final subscriptionProSinceUtc = paychekParseFirestoreInstantUtc(
    d[kPaychekUserFieldSubscriptionProSinceUtc],
  );

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
    subscriptionCurrentPeriodEnd: effectivePeriodEnd,
    subscriptionProSinceUtc: subscriptionProSinceUtc,
  );
}

Query<Map<String, dynamic>> paychekUsersOrderedQuery() => FirebaseFirestore
    .instance
    .collection(kPaychekUsersCollection)
    .orderBy('lastSeenAt', descending: true);

DateTime? _adminLatestPeriodEndUtc(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.isAfter(b) ? a : b;
}

/// Fusionne la fin Pro : max(`paychek_users`, `subscriber_entitlements`).
AdminUserRow adminUserRowMergeEntitlementData(
  AdminUserRow u,
  Map<String, dynamic>? entData,
) {
  if (entData == null) return u;
  DateTime? periodEnd = u.subscriptionCurrentPeriodEnd;
  final entPeriod = paychekParseFirestoreInstantUtc(entData['currentPeriodEnd']);
  if (entPeriod != null) {
    periodEnd = _adminLatestPeriodEndUtc(periodEnd, entPeriod);
  }
  final adminComp = paychekParseFirestoreInstantUtc(entData['adminCompPeriodEnd']);
  if (adminComp != null) {
    periodEnd = _adminLatestPeriodEndUtc(periodEnd, adminComp);
  }
  DateTime? proSince = u.subscriptionProSinceUtc;
  for (final key in ['proSinceUtc', 'proSince']) {
    final entSince = paychekParseFirestoreInstantUtc(entData[key]);
    if (entSince != null) {
      proSince = proSince == null
          ? entSince
          : (entSince.isBefore(proSince) ? entSince : proSince);
      break;
    }
  }
  final productRaw = entData['googlePlayProductId']?.toString().trim();
  final productId =
      productRaw != null && productRaw.isNotEmpty ? productRaw : null;
  final entActive = entData['active'] == true;
  final endedAt =
      paychekParseFirestoreInstantUtc(entData['subscriptionEndedAt']);
  final endReason = entData['subscriptionEndReason']?.toString().trim();
  final subscriptionEndReason =
      endReason != null && endReason.isNotEmpty ? endReason : null;
  if (periodEnd == u.subscriptionCurrentPeriodEnd &&
      proSince == u.subscriptionProSinceUtc &&
      productId == u.googlePlayProductId &&
      entActive == u.subscriberEntitlementActive &&
      endedAt == u.subscriptionEndedAtUtc &&
      subscriptionEndReason == u.subscriptionEndReason) {
    return u;
  }
  return u.copyWith(
    subscriptionCurrentPeriodEnd: periodEnd,
    subscriptionProSinceUtc: proSince,
    googlePlayProductId: productId ?? u.googlePlayProductId,
    subscriberEntitlementActive: entActive,
    subscriptionEndedAtUtc: endedAt ?? u.subscriptionEndedAtUtc,
    subscriptionEndReason: subscriptionEndReason ?? u.subscriptionEndReason,
  );
}

/// Complète [subscriptionCurrentPeriodEnd] depuis `subscriber_entitlements` (max des deux).
Future<List<AdminUserRow>> adminEnrichUsersWithEntitlements(
  List<AdminUserRow> users,
) async {
  if (users.isEmpty) return users;
  final db = FirebaseFirestore.instance;
  const chunkSize = 10;
  final out = <AdminUserRow>[];
  for (var i = 0; i < users.length; i += chunkSize) {
    final end = i + chunkSize < users.length ? i + chunkSize : users.length;
    final chunk = users.sublist(i, end);
    final refs = chunk
        .map(
          (u) => db
              .collection(kPaychekSubscriberEntitlementsCollection)
              .doc(u.id),
        )
        .toList();
    final snaps = await Future.wait(refs.map((ref) => ref.get()));
    for (var j = 0; j < chunk.length; j++) {
      out.add(adminUserRowMergeEntitlementData(chunk[j], snaps[j].data()));
    }
  }
  return out;
}
