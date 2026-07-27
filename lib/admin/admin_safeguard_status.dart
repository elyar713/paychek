import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_safeguard_licenses.dart';

/// Pastille Safeguard (même sémantique que licence.html / paychek-account-entitlement.js).
enum AdminSafeguardBadge {
  inactive,
  lite,
  pro,
}

extension AdminSafeguardBadgeX on AdminSafeguardBadge {
  String get label => switch (this) {
        AdminSafeguardBadge.inactive => 'Inactive',
        AdminSafeguardBadge.lite => 'Lite',
        AdminSafeguardBadge.pro => 'Pro',
      };

  /// Rouge / vert / or — aligné sur licence.html.
  Color get color => switch (this) {
        AdminSafeguardBadge.inactive => const Color(0xFFEF4444),
        AdminSafeguardBadge.lite => const Color(0xFF22C55E),
        AdminSafeguardBadge.pro => const Color(0xFFD4A359),
      };

  Color get foreground => switch (this) {
        AdminSafeguardBadge.inactive => const Color(0xFF450A0A),
        AdminSafeguardBadge.lite => const Color(0xFF052E16),
        AdminSafeguardBadge.pro => const Color(0xFF000000),
      };

  List<Color> get gradientColors => switch (this) {
        AdminSafeguardBadge.inactive => const [
            Color(0xFFFCA5A5),
            Color(0xFFEF4444),
            Color(0xFFB91C1C),
          ],
        AdminSafeguardBadge.lite => const [
            Color(0xFF86EFAC),
            Color(0xFF22C55E),
            Color(0xFF16A34A),
          ],
        AdminSafeguardBadge.pro => const [
            Color(0xFFFFE0B2),
            Color(0xFFD4A359),
            Color(0xFFB38038),
          ],
      };
}

class AdminSafeguardStatus {
  const AdminSafeguardStatus({
    required this.badge,
    this.license,
    this.trialClaimed = false,
    this.revokedOnly = false,
    this.licenseKey = '',
    this.planLabel = '—',
    this.activationLabel = '0 / 1',
    this.expiryAt,
    this.sourceLabel = '—',
    this.linkedEmail = '',
    this.createdAt,
  });

  final AdminSafeguardBadge badge;
  final SafeguardLicense? license;
  final bool trialClaimed;
  final bool revokedOnly;
  final String licenseKey;
  final String planLabel;
  final String activationLabel;
  final DateTime? expiryAt;
  final String sourceLabel;
  final String linkedEmail;
  final DateTime? createdAt;

  static const empty = AdminSafeguardStatus(
    badge: AdminSafeguardBadge.inactive,
  );
}

const String kSafeguardTrialClaimsCollection = 'safeguard_trial_claims';

bool isTrialSafeguardLicenseData(Map<String, dynamic>? d) {
  if (d == null) return false;
  if (d['isTrial'] == true) return true;
  if ('${d['source'] ?? ''}'.trim().toLowerCase() == 'trial_claim') {
    return true;
  }
  final plan = '${d['plan'] ?? ''}'.trim().toLowerCase();
  final type = '${d['type'] ?? ''}'.trim().toLowerCase();
  return plan == 'trial' || type == 'trial';
}

bool isTrialSafeguardLicense(SafeguardLicense? lic) {
  if (lic == null) return false;
  return isTrialSafeguardLicenseData({
    'isTrial': lic.isTrial,
    'source': lic.source,
    'plan': lic.plan,
    'type': lic.type,
  });
}

/// Prefer paid/Pro over trial; among equals: non-expired, later expiry, newer.
SafeguardLicense? pickBestSafeguardLicense(List<SafeguardLicense> docs) {
  SafeguardLicense? best;
  _SgMeta? bestMeta;
  SafeguardLicense? revokedOnly;
  final now = DateTime.now().toUtc();

  for (final d in docs) {
    if (d.revoked) {
      revokedOnly ??= d;
      continue;
    }
    final m = _SgMeta.from(d, now);
    if (best == null || m.betterThan(bestMeta!)) {
      best = d;
      bestMeta = m;
    }
  }
  return best ?? revokedOnly;
}

class _SgMeta {
  const _SgMeta({
    required this.trial,
    required this.expired,
    required this.expMs,
    required this.createdMs,
    required this.acts,
  });

  final bool trial;
  final bool expired;
  final int expMs;
  final int createdMs;
  final int acts;

  factory _SgMeta.from(SafeguardLicense d, DateTime now) {
    final trial = isTrialSafeguardLicense(d);
    final exp = d.expiresAt?.toUtc();
    final expired = exp != null && exp.isBefore(now);
    final expMs = exp != null
        ? exp.millisecondsSinceEpoch
        : (trial ? 0 : 9007199254740991); // Number.MAX_SAFE_INTEGER
    return _SgMeta(
      trial: trial,
      expired: expired,
      expMs: expMs,
      createdMs: d.createdAt?.toUtc().millisecondsSinceEpoch ?? 0,
      acts: d.activationCount,
    );
  }

  bool betterThan(_SgMeta other) {
    if (trial != other.trial) return !trial;
    if (expired != other.expired) return !expired;
    if (expMs != other.expMs) return expMs > other.expMs;
    if (createdMs != other.createdMs) return createdMs > other.createdMs;
    if (acts != other.acts) return acts > other.acts;
    return false;
  }
}

AdminSafeguardBadge resolveSafeguardBadge({
  SafeguardLicense? license,
  bool trialClaimed = false,
  bool revokedOnly = false,
}) {
  if (revokedOnly) return AdminSafeguardBadge.inactive;
  if (license != null && license.revoked) {
    return AdminSafeguardBadge.inactive;
  }
  if (license != null && !isTrialSafeguardLicense(license)) {
    return AdminSafeguardBadge.pro;
  }
  if (trialClaimed) return AdminSafeguardBadge.lite;
  if (license != null) return AdminSafeguardBadge.lite;
  return AdminSafeguardBadge.inactive;
}

Future<List<SafeguardLicense>> _querySafeguardLicenses(
  String field,
  String value,
) async {
  if (value.isEmpty) return const [];
  try {
    final snap = await FirebaseFirestore.instance
        .collection(kSafeguardLicensesCollection)
        .where(field, isEqualTo: value)
        .limit(20)
        .get();
    return snap.docs.map(SafeguardLicense.fromDoc).toList();
  } catch (_) {
    return const [];
  }
}

List<SafeguardLicense> _mergeById(List<List<SafeguardLicense>> lists) {
  final byId = <String, SafeguardLicense>{};
  for (final list in lists) {
    for (final d in list) {
      final id = d.id.trim().isNotEmpty ? d.id.trim() : d.key.trim();
      if (id.isEmpty) continue;
      byId.putIfAbsent(id, () => d);
    }
  }
  return byId.values.toList();
}

/// Charge le statut Safeguard pour la fiche admin (userId + email + trial claim).
Future<AdminSafeguardStatus> loadAdminSafeguardStatus({
  required String userId,
  String? email,
}) async {
  final id = userId.trim();
  if (id.isEmpty) return AdminSafeguardStatus.empty;

  final emailNorm = (email ?? '').trim().toLowerCase();

  Map<String, dynamic>? claim;
  Map<String, dynamic>? user;
  try {
    final claimSnap = await FirebaseFirestore.instance
        .collection(kSafeguardTrialClaimsCollection)
        .doc(id)
        .get();
    if (claimSnap.exists) claim = claimSnap.data();
  } catch (_) {}
  try {
    final userSnap = await FirebaseFirestore.instance
        .collection('paychek_users')
        .doc(id)
        .get();
    if (userSnap.exists) user = userSnap.data();
  } catch (_) {}

  final byUid = await _querySafeguardLicenses('userId', id);
  final byEmail = emailNorm.isNotEmpty
      ? await _querySafeguardLicenses('userEmail', emailNorm)
      : const <SafeguardLicense>[];
  final licenses = _mergeById([byUid, byEmail]);

  var license = pickBestSafeguardLicense(licenses);

  if ((license == null || license.revoked) &&
      claim != null &&
      ('${claim['licenseKey'] ?? ''}'.trim().isNotEmpty ||
          '${claim['licenseId'] ?? ''}'.trim().isNotEmpty)) {
    final key = '${claim['licenseKey'] ?? claim['licenseId'] ?? ''}'.trim();
    DateTime? expires;
    final exp = claim['expiresAt'];
    if (exp is Timestamp) expires = exp.toDate();
    license = SafeguardLicense(
      id: key,
      key: key,
      plan: 'trial',
      note: '',
      maxActivations: 1,
      revoked: false,
      createdAt: null,
      createdByEmail: '',
      activations: const [],
      expiresAt: expires,
      source: 'trial_claim',
      isTrial: true,
      type: 'trial',
    );
  }

  final trialClaimed = (claim != null &&
          ('${claim['licenseKey'] ?? ''}'.trim().isNotEmpty ||
              claim['claimedAt'] != null)) ||
      user?['safeguardTrialClaimedAt'] != null ||
      (license != null && license.plan.trim().toLowerCase() == 'trial');

  final revokedOnly = license != null && license.revoked;
  final usable = revokedOnly ? null : license;
  final badge = resolveSafeguardBadge(
    license: usable,
    trialClaimed: trialClaimed,
    revokedOnly: revokedOnly,
  );
  final displayLicense = usable ?? license;

  final rawPlan = (displayLicense?.plan ?? '').trim().toLowerCase();
  final isTrial = displayLicense != null && isTrialSafeguardLicense(displayLicense);
  final planLabel = switch ((displayLicense != null, isTrial, rawPlan)) {
    (false, _, _) => trialClaimed ? 'Trial' : '—',
    (true, true, _) => 'Trial',
    (true, false, 'pro') => 'Pro annual',
    (true, false, final _) => displayLicense!.plan.trim().isEmpty
        ? 'Pro'
        : displayLicense.plan.trim(),
  };
  final activationLabel = displayLicense == null
      ? '0 / 1'
      : '${displayLicense.activationCount} / ${displayLicense.maxActivations}';
  final rawSource = (displayLicense?.source ?? '').trim().toLowerCase();
  final sourceLabel = switch (rawSource) {
    'trial_claim' => 'Website trial',
    'stripe' => 'Stripe',
    'admin' => 'Admin',
    '' => trialClaimed ? 'Website trial' : '—',
    _ => displayLicense?.source.trim().isEmpty == true
        ? '—'
        : displayLicense!.source.trim(),
  };

  return AdminSafeguardStatus(
    badge: badge,
    license: license,
    trialClaimed: trialClaimed,
    revokedOnly: revokedOnly,
    licenseKey: license?.key ?? '',
    planLabel: planLabel,
    activationLabel: activationLabel,
    expiryAt: license?.expiresAt,
    sourceLabel: sourceLabel,
    linkedEmail: (license?.userEmail ?? emailNorm).trim(),
    createdAt: license?.createdAt,
  );
}
