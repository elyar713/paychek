import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'paychek_client_platform.dart';
import 'reglage_language_prefs.dart';
import 'reglage_profile_prefs.dart';

/// Profils utilisateur pour l’admin et le suivi (une doc par `uid` Auth).
///
/// À déployer côté console : voir `firestore.rules` à la racine du repo.
const String kPaychekUsersCollection = 'paychek_users';

/// `false` = le compte doit encore passer le questionnaire Paychek (première inscription).
/// `true` ou champ absent = pas de questionnaire à l’ouverture (comptes existants / déjà complété).
const String kPaychekUserFieldQuestionnaireComplete =
    'hasCompletedPaychekQuestionnaire';

/// Fin d’accès **plein** (avant mode Lite) imposée par l’**admin** — remplace la fin par défaut
/// `createdAt` + 7 jours lorsque le champ est présent. Les clients ne doivent pas l’écrire (règles Firestore).
const String kPaychekUserFieldTrialFreemiumOverrideUntil =
    'trialFreemiumOverrideUntil';

/// Jours civils UTC (`yyyy-MM-dd`) où l’utilisateur a ouvert l’app (sync connexion).
/// Sert à l’admin (pastille d’activité sur 7 jours). Taille bornée côté client.
const String kPaychekUserFieldAppOpenDatesUtcV1 = 'appOpenDatesUtcV1';

/// Horodatage du dernier changement de plan (`subscriptionTier` / `isPremium`) par l’**admin**.
/// Les apps ne l’écrivent pas (hors console admin). Sert d’ancrage pour une licence Pro affichée (+1 an).
const String kPaychekUserFieldSubscriptionTierUpdatedAt =
    'subscriptionTierUpdatedAt';

/// Copie « admin » de la fin de période Pro (`subscriber_entitlements.currentPeriodEnd`),
/// écrite par les Cloud Functions (Stripe). Évite la lecture `subscriber_entitlements` depuis la console admin.
const String kPaychekUserFieldSubscriptionCurrentPeriodEnd =
    'subscriptionCurrentPeriodEnd';

/// Début de période Pro miroir (`subscriber_entitlements.proSinceUtc` ou équivalent).
const String kPaychekUserFieldSubscriptionProSinceUtc =
    'subscriptionProSinceUtc';

String _paychekTrimField(Object? v) => v?.toString().trim() ?? '';

/// Sépare un libellé type « Prénom Nom » (admin, pas garanti ambigu hors formulaire).
(String first, String last) _paychekSplitDisplayForNames(String dn) {
  final t = dn.trim();
  if (t.isEmpty) return ('', '');
  final parts = t.split(RegExp(r'\s+'));
  if (parts.length == 1) return (parts.single, '');
  return (parts.first, parts.sublist(1).join(' '));
}

/// Lit `paychek_users/{uid}` et aligne les prefs locales si le cloud est plus récent
/// (ou si aucun horodatage — anciennes docs — et les codes diffèrent).
///
/// À appeler **avant** de lire la langue pour [syncPaychekUserDocument] ou [AppLocaleController.load].
/// Délai max pour lire la langue cloud (web lent / hors ligne) — ne pas bloquer l’UI.
const Duration _kAppLanguageFirestoreReadTimeout = Duration(seconds: 4);

Future<void> paychekMergeAppLanguageFromFirestore(User user) async {
  try {
    await ReglageLanguagePrefs.promoteGuestLanguageToCurrentAccountIfNeeded();
    final DocumentSnapshot<Map<String, dynamic>> snap;
    try {
      snap = await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(user.uid)
          .get()
          .timeout(_kAppLanguageFirestoreReadTimeout);
    } on TimeoutException {
      return;
    }
    if (!snap.exists) return;
    final data = snap.data();
    if (data == null) return;
    final raw = data['appLanguageCode'];
    if (raw is! String) return;
    final cloudCode = raw.trim().toLowerCase();
    if (!ReglageLanguagePrefs.availableCodes.contains(cloudCode)) return;

    final cloudTs = data['appLanguageUpdatedAt'];
    final cloudMs =
        cloudTs is Timestamp ? cloudTs.millisecondsSinceEpoch : 0;

    final localMs = await ReglageLanguagePrefs.loadUpdatedAtMillis();
    final localCode = await ReglageLanguagePrefs.loadCode();

    final takeCloud = cloudMs > localMs ||
        (cloudMs == 0 &&
            localMs == 0 &&
            cloudCode != localCode);

    if (!takeCloud) return;

    final ms = cloudMs > 0
        ? cloudMs
        : DateTime.now().millisecondsSinceEpoch;
    await ReglageLanguagePrefs.save(cloudCode, updatedAtMillis: ms);
  } catch (e, st) {
    debugPrint('[Paychek] paychekMergeAppLanguageFromFirestore: $e\n$st');
  }
}

/// Met à jour `paychek_users/{uid}` (merge). Crée `createdAt` uniquement si absent.
///
/// Ne touche pas aux champs réservés à l’admin : `accessWebEnabled`, `accessMobileEnabled`,
/// `subscriptionTier` (hors création), [kPaychekUserFieldTrialFreemiumOverrideUntil],
/// [kPaychekUserFieldSubscriptionTierUpdatedAt], etc.
/// Écrit [kPaychekUserFieldAppOpenDatesUtcV1] (historique d’ouverture par jour UTC, borné).
/// Écrit `appLanguageCode` (choix Réglages) à chaque sync.
///
/// [firstName] / [lastName] : passés `null` (défaut) = ne pas écraser prénom/nom sauf déduction
/// depuis `displayName` lorsque ces champs sont encore vides (réparation + Google, etc.).
///
/// À appeler après inscription, connexion email, Google, Facebook.
Future<void> syncPaychekUserDocument(
  User user, {
  String? firstName,
  String? lastName,
  /// Jour de naissance (composantes date seulement), stocké en UTC minuit.
  DateTime? birthDate,
}) async {
  try {
    await paychekMergeAppLanguageFromFirestore(user);
  } catch (e, st) {
    debugPrint('[Paychek] merge lang before syncPaychekUserDocument: $e\n$st');
  }
  try {
    final ref = FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(user.uid);

    try {
      await user.reload();
    } catch (_) {
      // Réseau / session : continuer avec le profil déjà en mémoire.
    }

    final snap = await ref.get();
    final now = FieldValue.serverTimestamp();

    final email = user.email ?? '';
    var displayName = user.displayName?.trim() ?? '';
    if (displayName.isEmpty && snap.exists) {
      displayName = _paychekTrimField(snap.data()?['displayName']);
    }
    if (displayName.isEmpty) {
      final f = firstName?.trim() ?? '';
      final l = lastName?.trim() ?? '';
      if (f.isNotEmpty || l.isNotEmpty) {
        displayName = '$f $l'.trim();
      }
    }

    final platform = PaychekClientPlatform.currentSyncLabel();
    final utcNow = DateTime.now().toUtc();
    final todayUtcKey =
        '${utcNow.year.toString().padLeft(4, '0')}-${utcNow.month.toString().padLeft(2, '0')}-${utcNow.day.toString().padLeft(2, '0')}';
    final rawOpens = snap.data()?[kPaychekUserFieldAppOpenDatesUtcV1];
    final openDates = <String>{};
    if (rawOpens is List) {
      for (final e in rawOpens) {
        final s = '$e'.trim();
        if (s.length >= 10 && RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(s)) {
          openDates.add(s.substring(0, 10));
        }
      }
    }
    openDates.add(todayUtcKey);
    final sortedOpens = openDates.toList()..sort();
    const keepDays = 45;
    final cutoff = utcNow.subtract(const Duration(days: keepDays));
    final cutoffKey =
        '${cutoff.year.toString().padLeft(4, '0')}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';
    sortedOpens.removeWhere((k) => k.compareTo(cutoffKey) < 0);
    while (sortedOpens.length > keepDays) {
      sortedOpens.removeAt(0);
    }

    final payload = <String, dynamic>{
      'email': email,
      if (user.photoURL != null) 'photoUrl': user.photoURL,
      'lastSeenAt': now,
      'updatedAt': now,
      'lastSeenPlatform': platform,
      'lastSeenPlatformAt': now,
      'platformsSeen': FieldValue.arrayUnion(<Object?>[platform]),
      kPaychekUserFieldAppOpenDatesUtcV1: sortedOpens,
    };

    if (displayName.isNotEmpty) {
      payload['displayName'] = displayName;
    } else if (!snap.exists) {
      payload['displayName'] = '';
    }

    if (!snap.exists) {
      payload['createdAt'] = now;
      payload['country'] = '';
      payload['isPremium'] = false;
      payload['subscriptionTier'] = 'lite';
      payload['importedTrades'] = 0;
      payload['accessWebEnabled'] = true;
      payload['accessMobileEnabled'] = true;
      payload[kPaychekUserFieldQuestionnaireComplete] = false;
    }

    if (firstName != null) {
      payload['firstName'] = firstName.trim();
    }
    if (lastName != null) {
      payload['lastName'] = lastName.trim();
    }
    if (firstName == null && lastName == null) {
      final prev = snap.data();
      final oldF = _paychekTrimField(prev?['firstName']);
      final oldL = _paychekTrimField(prev?['lastName']);
      if (oldF.isEmpty && oldL.isEmpty && displayName.isNotEmpty) {
        final inferred = _paychekSplitDisplayForNames(displayName);
        payload['firstName'] = inferred.$1;
        payload['lastName'] = inferred.$2;
      }
    }

    if (birthDate != null) {
      final utc = DateTime.utc(
        birthDate.year,
        birthDate.month,
        birthDate.day,
      );
      payload['birthDate'] = Timestamp.fromDate(utc);
    }

    try {
      var lang = await ReglageLanguagePrefs.loadCode();
      if (!ReglageLanguagePrefs.availableCodes.contains(lang)) {
        lang = ReglageLanguagePrefs.defaultCode;
      }
      payload['appLanguageCode'] = lang;
      final langMs = await ReglageLanguagePrefs.loadUpdatedAtMillis();
      if (langMs > 0) {
        payload['appLanguageUpdatedAt'] =
            Timestamp.fromMillisecondsSinceEpoch(langMs);
      }
    } catch (_) {
      payload['appLanguageCode'] = ReglageLanguagePrefs.defaultCode;
    }

    // Merge write au lieu de runTransaction — évite crash codec Firestore sur certains desktops (Windows).
    await ref.set(payload, SetOptions(merge: true));
  } catch (e, st) {
    // Ne pas bloquer inscription / connexion si Firestore échoue (règle ou réseau).
    debugPrint('[Paychek] syncPaychekUserDocument: $e\n$st');
  }
}

/// [syncPaychekUserDocument] puis alignement des prefs **prénom / nom / e-mail** depuis le nuage.
///
/// À utiliser après connexion ou au démarrage : la déconnexion efface le profil local
/// ([ReglageProfilePrefs.clearStoredAccountProfile]) ; sans ce merge, les noms modifiés ne reviennent pas.
Future<void> syncPaychekUserDocumentAndMergeProfile(User user) async {
  await syncPaychekUserDocument(user);
  await paychekMergeProfileFromFirestore(user);
}

/// Lit `paychek_users/{uid}` et met à jour [ReglageProfilePrefs] (`inscrit: true`).
///
/// Ordre de repli : `firstName`/`lastName` sur le doc → `displayName` doc → `displayName` Auth
/// → valeurs déjà présentes dans les prefs (même clé compte).
Future<void> paychekMergeProfileFromFirestore(User user) async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(user.uid)
        .get();

    final existing = await ReglageProfilePrefs.load();
    var fn = '';
    var ln = '';

    if (snap.exists) {
      final d = snap.data();
      if (d != null) {
        fn = _paychekTrimField(d['firstName']);
        ln = _paychekTrimField(d['lastName']);
        if (fn.isEmpty && ln.isEmpty) {
          final docDn = _paychekTrimField(d['displayName']);
          if (docDn.isNotEmpty) {
            final sp = _paychekSplitDisplayForNames(docDn);
            fn = sp.$1;
            ln = sp.$2;
          }
        }
      }
    }

    if (fn.isEmpty && ln.isEmpty) {
      final authDn = user.displayName?.trim() ?? '';
      if (authDn.isNotEmpty) {
        final sp = _paychekSplitDisplayForNames(authDn);
        fn = sp.$1;
        ln = sp.$2;
      }
    }

    if (fn.isEmpty && ln.isEmpty) {
      fn = existing.prenom.trim();
      ln = existing.nom.trim();
    }

    final authEmail = (user.email ?? '').trim();
    var email = authEmail;
    if (email.isEmpty && snap.exists) {
      email = _paychekTrimField(snap.data()?['email']);
    }
    if (email.isEmpty) {
      email = existing.email.trim();
    }

    if (fn.isEmpty && ln.isEmpty && email.isEmpty) {
      return;
    }

    await ReglageProfilePrefs.save(
      inscrit: true,
      prenom: fn,
      nom: ln,
      email: email,
    );
  } catch (e, st) {
    debugPrint('[Paychek] paychekMergeProfileFromFirestore: $e\n$st');
  }
}

/// Après fin du questionnaire (web + mobile). Ne bloque pas l’UI en cas d’échec réseau / règles.
Future<void> setPaychekQuestionnaireCompleted(User user) async {
  try {
    await FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(user.uid)
        .set(
          <String, dynamic>{
            kPaychekUserFieldQuestionnaireComplete: true,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  } catch (e, st) {
    debugPrint('[Paychek] setPaychekQuestionnaireCompleted: $e\n$st');
  }
}

/// Met à jour la langue d’interface choisie (`Reglage`) sur Firestore pour l’admin.
Future<void> paychekPushUserAppLanguageToFirestore(String code) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final trimmed = code.trim().toLowerCase();
  final safe = ReglageLanguagePrefs.availableCodes.contains(trimmed)
      ? trimmed
      : ReglageLanguagePrefs.defaultCode;
  try {
    await FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(user.uid)
        .set(
          <String, dynamic>{
            'appLanguageCode': safe,
            'appLanguageUpdatedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  } catch (e, st) {
    debugPrint('[Paychek] paychekPushUserAppLanguageToFirestore: $e\n$st');
  }
}

/// Aligner le champ [importedTrades] (`paychek_users/{uid}`) avec les imports CSV réussis,
/// utilisé dans l’admin (carte « TRADES »). Les trades vivent encore en local.
Future<void> bumpPaychekUserImportedTradesCount(int delta) async {
  if (delta <= 0) return;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  try {
    await FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(uid)
        .set(
          <String, dynamic>{
            'importedTrades': FieldValue.increment(delta),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  } catch (e, st) {
    debugPrint('[Paychek] bumpPaychekUserImportedTradesCount: $e\n$st');
  }
}
