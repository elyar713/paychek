import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'admin_support_send_email.dart';

/// Collection Firestore des licences Paychek Safeguard (desktop).
const String kSafeguardLicensesCollection = 'safeguard_licenses';

String normalizeSafeguardLicenseKey(String raw) {
  final text = raw.toUpperCase();
  final embedded = RegExp(
    r'PAYC[\s\-]*([A-F0-9]{4})[\s\-]*([A-F0-9]{4})[\s\-]*([A-F0-9]{4})',
  ).firstMatch(text);
  if (embedded != null) {
    return 'PAYC-${embedded.group(1)}-${embedded.group(2)}-${embedded.group(3)}';
  }
  final cleaned = text.replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final paycAt = cleaned.indexOf('PAYC');
  var body = paycAt >= 0 ? cleaned.substring(paycAt + 4) : cleaned;
  final hexOnly = RegExp(r'^[A-F0-9]+').firstMatch(body);
  if (hexOnly != null) {
    body = hexOnly.group(0)!;
  }
  if (body.length < 12) {
    body = body.padRight(12, '0');
  } else if (body.length > 12) {
    body = body.substring(0, 12);
  }
  final parts = <String>[
    body.substring(0, 4),
    body.substring(4, 8),
    body.substring(8, 12),
  ];
  return 'PAYC-${parts.join('-')}';
}

String generateSafeguardLicenseKey([Random? random]) {
  final rng = random ?? Random.secure();
  const hex = '0123456789ABCDEF';
  final buf = StringBuffer();
  for (var i = 0; i < 12; i++) {
    buf.write(hex[rng.nextInt(hex.length)]);
  }
  return normalizeSafeguardLicenseKey('PAYC${buf.toString()}');
}

class SafeguardLicense {
  const SafeguardLicense({
    required this.id,
    required this.key,
    required this.plan,
    required this.note,
    required this.maxActivations,
    required this.revoked,
    required this.createdAt,
    required this.createdByEmail,
    required this.activations,
    this.userEmail,
    this.userId,
    this.expiresAt,
    this.source = '',
    this.type = '',
    this.isTrial = false,
  });

  final String id;
  final String key;
  final String plan;
  final String note;
  final int maxActivations;
  final bool revoked;
  final DateTime? createdAt;
  final String createdByEmail;
  final List<Map<String, dynamic>> activations;
  final String? userEmail;
  final String? userId;
  final DateTime? expiresAt;

  /// Ex. `trial_claim`, `stripe`, `admin`.
  final String source;

  /// Ex. `trial` / `pro` (souvent redondant avec [plan]).
  final String type;

  /// Flag Firestore explicite pour un essai 7 jours.
  final bool isTrial;

  int get activationCount => activations.length;

  bool get isUnused => !revoked && activationCount == 0;

  bool get isActive => !revoked && activationCount > 0;

  factory SafeguardLicense.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final rawActs = d['activations'];
    final acts = <Map<String, dynamic>>[];
    if (rawActs is List) {
      for (final item in rawActs) {
        if (item is Map) {
          acts.add(Map<String, dynamic>.from(item));
        }
      }
    }
    DateTime? created;
    final ts = d['createdAt'];
    if (ts is Timestamp) created = ts.toDate();
    DateTime? expires;
    final exp = d['expiresAt'];
    if (exp is Timestamp) expires = exp.toDate();
    return SafeguardLicense(
      id: doc.id,
      key: (d['key'] as String?) ?? doc.id,
      plan: (d['plan'] as String?) ?? 'pro',
      note: (d['note'] as String?) ?? '',
      maxActivations: (d['maxActivations'] as num?)?.toInt() ?? 1,
      revoked: d['revoked'] == true,
      createdAt: created,
      createdByEmail: (d['createdByEmail'] as String?) ?? '',
      activations: acts,
      userEmail: (() {
        final delivery = '${d['deliveryEmail'] ?? ''}'.trim();
        final user = '${d['userEmail'] ?? ''}'.trim();
        if (delivery.isNotEmpty) return delivery;
        if (user.isNotEmpty) return user;
        return null;
      })(),
      userId: d['userId'] as String?,
      expiresAt: expires,
      source: '${d['source'] ?? ''}'.trim(),
      type: '${d['type'] ?? ''}'.trim(),
      isTrial: d['isTrial'] == true,
    );
  }
}

Future<List<SafeguardLicense>> fetchSafeguardLicenses() async {
  final snap = await FirebaseFirestore.instance
      .collection(kSafeguardLicensesCollection)
      .orderBy('createdAt', descending: true)
      .limit(200)
      .get();
  return snap.docs.map(SafeguardLicense.fromDoc).toList();
}

Future<SafeguardLicense> mintSafeguardLicense({
  String plan = 'pro',
  String note = '',
  int maxActivations = 1,
  String? userEmail,
  Duration validity = const Duration(days: 365),
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Admin non connecté.');
  }

  var key = generateSafeguardLicenseKey();
  final col = FirebaseFirestore.instance.collection(kSafeguardLicensesCollection);
  final emailNorm = (userEmail ?? '').trim().toLowerCase();
  String? linkedUserId;
  if (emailNorm.isNotEmpty) {
    try {
      final users = await FirebaseFirestore.instance
          .collection('paychek_users')
          .where('email', isEqualTo: emailNorm)
          .limit(1)
          .get();
      if (users.docs.isNotEmpty) {
        linkedUserId = users.docs.first.id;
      }
    } catch (_) {
      // Email link remains usable even if uid lookup fails.
    }
  }
  final expiresAt = Timestamp.fromDate(DateTime.now().toUtc().add(validity));

  for (var attempt = 0; attempt < 8; attempt++) {
    final doc = col.doc(key);
    final exists = await doc.get();
    if (exists.exists) {
      key = generateSafeguardLicenseKey();
      continue;
    }
    final payload = <String, dynamic>{
      'key': key,
      'keyNormalized': key.replaceAll('-', ''),
      'plan': plan,
      'note': note.trim(),
      'maxActivations': maxActivations.clamp(1, 5),
      'revoked': false,
      'createdAt': FieldValue.serverTimestamp(),
      'createdByUid': user.uid,
      'createdByEmail': user.email ?? '',
      'activations': <Map<String, dynamic>>[],
      'expiresAt': expiresAt,
      if (emailNorm.isNotEmpty) 'userEmail': emailNorm,
      if (linkedUserId != null && linkedUserId.isNotEmpty) 'userId': linkedUserId,
    };
    await doc.set(payload);
    final saved = await doc.get();
    return SafeguardLicense.fromDoc(saved);
  }
  throw StateError('Impossible de générer une clé unique.');
}

Future<void> adminSendSafeguardLicenseEmail({
  required String licenseKey,
  required String email,
  String note = '',
  String locale = 'fr',
}) async {
  final fn =
      FirebaseFunctions.instanceFor(region: kPaychekSupportFunctionsRegion);
  try {
    await fn.httpsCallable('adminSendSafeguardLicenseEmail').call<Object?>(
      <String, dynamic>{
        'licenseKey': licenseKey.trim(),
        'email': email.trim(),
        'note': note.trim(),
        'locale': locale.trim().isEmpty ? 'fr' : locale.trim(),
      },
    );
  } on FirebaseFunctionsException catch (e) {
    final msg = (e.message ?? e.code).trim();
    throw StateError(msg.isEmpty ? e.code : msg);
  }
}

/// Prolonge [expiresAt] de [days] jours à partir de max(maintenant, expiresAt actuel).
Future<DateTime> extendSafeguardLicense({
  required String key,
  required int days,
}) async {
  if (days < 1) {
    throw ArgumentError('days must be >= 1');
  }
  final id = normalizeSafeguardLicenseKey(key);
  final ref = FirebaseFirestore.instance
      .collection(kSafeguardLicensesCollection)
      .doc(id);
  final snap = await ref.get();
  if (!snap.exists) {
    throw StateError('Licence introuvable : $id');
  }
  final data = snap.data() ?? {};
  DateTime base = DateTime.now().toUtc();
  final raw = data['expiresAt'];
  if (raw is Timestamp) {
    final current = raw.toDate().toUtc();
    if (current.isAfter(base)) base = current;
  }
  final newEnd = base.add(Duration(days: days));
  await ref.update({
    'expiresAt': Timestamp.fromDate(newEnd),
    'adminExtendedDays': FieldValue.increment(days),
    'adminExtendedAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  return newEnd;
}

Future<void> revokeSafeguardLicense(String key) async {
  final id = normalizeSafeguardLicenseKey(key);
  await FirebaseFirestore.instance
      .collection(kSafeguardLicensesCollection)
      .doc(id)
      .update({
    'revoked': true,
    'revokedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> unrevokeSafeguardLicense(String key) async {
  final id = normalizeSafeguardLicenseKey(key);
  await FirebaseFirestore.instance
      .collection(kSafeguardLicensesCollection)
      .doc(id)
      .update({
    'revoked': false,
    'revokedAt': FieldValue.delete(),
  });
}
