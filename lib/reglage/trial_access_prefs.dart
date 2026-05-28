import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import 'paychek_prefs_scope.dart';
import 'paychek_user_firestore.dart';

const _kTrialStartUtcMsBase = 'paychek_trial_start_utc_ms';
const _kSubscriberActiveBase = 'paychek_subscriber_active';

String get _kTrialStartUtcMs => paychekScopedPrefsKey(_kTrialStartUtcMsBase);
String get _kSubscriberActive => paychekScopedPrefsKey(_kSubscriberActiveBase);

/// Collection Firestore — **une doc par utilisateur** : `subscriber_entitlements/{uid}`
/// Champ recommandé : `{ "active": true }` (écrit après validation IAP Stripe / Apple / Google).
///
/// **Règles (exemple)** : lecture si `request.auth.uid == userId`, écriture interdite côté client
/// ou uniquement via Admin SDK / Cloud Functions.
const String kPaychekSubscriberEntitlementsCollection =
    'subscriber_entitlements';

/// Durée d’essai : jours 1–7 inclus, blocage au **jour 8** après l’instant d’ancrage.
const Duration kPaychekTrialDuration = Duration(days: 7);

class TrialGateVm {
  const TrialGateVm({
    required this.liteFreemiumRestricted,
    required this.anchorUtc,
    this.effectiveFullAccessEndUtc,
  });

  /// Compte connecté, hors Pro, après les 7 j d’essai : **Lite** (consultation dashboard + calendrier ;
  /// saisie trade limitée — pas CSV / screenshot / discipline avancée).
  final bool liteFreemiumRestricted;
  final DateTime? anchorUtc;

  /// Fin d’accès plein (affichage paywall) : override admin ou [anchorUtc] + 7 j.
  final DateTime? effectiveFullAccessEndUtc;
}

Future<
    ({
      DateTime? createdAtUtc,
      DateTime? trialFreemiumOverrideUntilUtc,
      bool docPro,
      DateTime? subscriptionTierUpdatedAtUtc,
      DateTime? subscriptionCurrentPeriodEndUtc,
      bool userDocExists,
      bool fetchSucceeded,
    })> _readPaychekUserTrialBootstrap(
  User u,
) async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(u.uid)
        .get(const GetOptions(source: Source.serverAndCache));
    if (!snap.exists) {
      return (
        createdAtUtc: null,
        trialFreemiumOverrideUntilUtc: null,
        docPro: false,
        subscriptionTierUpdatedAtUtc: null,
        subscriptionCurrentPeriodEndUtc: null,
        userDocExists: false,
        fetchSucceeded: true,
      );
    }
    final d = snap.data();
    if (d == null) {
      return (
        createdAtUtc: null,
        trialFreemiumOverrideUntilUtc: null,
        docPro: false,
        subscriptionTierUpdatedAtUtc: null,
        subscriptionCurrentPeriodEndUtc: null,
        userDocExists: true,
        fetchSucceeded: true,
      );
    }
    final createdUtc = paychekResolveUserJoinedAtUtc(d);
    DateTime? overrideUntilUtc;
    final rawOv = d[kPaychekUserFieldTrialFreemiumOverrideUntil];
    if (rawOv is Timestamp) {
      overrideUntilUtc = rawOv.toDate().toUtc();
    }
    DateTime? subscriptionTierUpdatedAtUtc;
    final rawTierUp = d[kPaychekUserFieldSubscriptionTierUpdatedAt];
    if (rawTierUp is Timestamp) {
      subscriptionTierUpdatedAtUtc = rawTierUp.toDate().toUtc();
    }
    DateTime? subscriptionCurrentPeriodEndUtc;
    final rawPeriodEnd = d[kPaychekUserFieldSubscriptionCurrentPeriodEnd];
    if (rawPeriodEnd is Timestamp) {
      subscriptionCurrentPeriodEndUtc = rawPeriodEnd.toDate().toUtc();
    }
    if (d['isPremium'] == true) {
      return (
        createdAtUtc: createdUtc,
        trialFreemiumOverrideUntilUtc: overrideUntilUtc,
        docPro: true,
        subscriptionTierUpdatedAtUtc: subscriptionTierUpdatedAtUtc,
        subscriptionCurrentPeriodEndUtc: subscriptionCurrentPeriodEndUtc,
        userDocExists: true,
        fetchSucceeded: true,
      );
    }
    final tier = d['subscriptionTier']?.toString().trim().toLowerCase();
    final pro = tier == 'pro';
    return (
      createdAtUtc: createdUtc,
      trialFreemiumOverrideUntilUtc: overrideUntilUtc,
      docPro: pro,
      subscriptionTierUpdatedAtUtc: subscriptionTierUpdatedAtUtc,
      subscriptionCurrentPeriodEndUtc: subscriptionCurrentPeriodEndUtc,
      userDocExists: true,
      fetchSucceeded: true,
    );
  } catch (e, st) {
    debugPrint('[Paychek] _readPaychekUserTrialBootstrap: $e\n$st');
    return (
      createdAtUtc: null,
      trialFreemiumOverrideUntilUtc: null,
      docPro: false,
      subscriptionTierUpdatedAtUtc: null,
      subscriptionCurrentPeriodEndUtc: null,
      userDocExists: false,
      fetchSucceeded: false,
    );
  }
}

DateTime? _resolveProSinceUtc({
  required ({
    bool active,
    DateTime? periodEndUtc,
    DateTime? proSinceUtc,
  }) subRow,
  required ({
    DateTime? createdAtUtc,
    DateTime? trialFreemiumOverrideUntilUtc,
    bool docPro,
    DateTime? subscriptionTierUpdatedAtUtc,
    DateTime? subscriptionCurrentPeriodEndUtc,
    bool userDocExists,
    bool fetchSucceeded,
  }) row,
}) {
  if (subRow.active && subRow.proSinceUtc != null) {
    return subRow.proSinceUtc;
  }
  if (row.docPro && row.subscriptionTierUpdatedAtUtc != null) {
    return row.subscriptionTierUpdatedAtUtc;
  }
  if (subRow.proSinceUtc != null) {
    return subRow.proSinceUtc;
  }
  return null;
}

DateTime _defaultTrialFullAccessEndUtc(DateTime anchorUtc) =>
    anchorUtc.add(kPaychekTrialDuration);

DateTime _effectiveTrialFullAccessEndUtc(
  DateTime anchorUtc,
  DateTime? trialFreemiumOverrideUntilUtc,
) =>
    trialFreemiumOverrideUntilUtc ?? _defaultTrialFullAccessEndUtc(anchorUtc);

/// Statut affiché sur l’écran profil : **Pro** = abonné, **Lite** = essai ou hors abo.
class AccountEntitlementSnapshot {
  const AccountEntitlementSnapshot({
    required this.isPro,
    required this.trialActive,
    required this.daysLeftInTrial,
    required this.trialEndUtc,
    required this.anchorUtc,
    this.subscriptionPeriodEndUtc,
    this.proSinceUtc,
  });

  final bool isPro;

  /// Essai gratuit encore valide (`isPro` false).
  final bool trialActive;

  /// Journées restantes (essai). `0` si pas en essai.
  final int daysLeftInTrial;
  final DateTime? trialEndUtc;
  final DateTime? anchorUtc;

  /// Fin de période d’abonnement (ex. `subscriber_entitlements.currentPeriodEnd` Stripe).
  final DateTime? subscriptionPeriodEndUtc;

  /// Début de la période Pro : `subscriber_entitlements.proSinceUtc` (Stripe) ou
  /// [kPaychekUserFieldSubscriptionTierUpdatedAt] (passage Pro par l’admin).
  final DateTime? proSinceUtc;
}

abstract final class TrialAccessPrefs {
  /// Cache device (offline / dernier IAP). Firestore reflète ensuite le même **uid**.
  static Future<void> setSubscriberActive(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSubscriberActive, value);
  }

  /// À la déconnexion : évite de réattribuer essai ou statut acheteur d’un **autre** compte sur l’appareil.
  static Future<void> clearPaychekLocalEntitlements() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kTrialStartUtcMs);
    await p.remove(_kSubscriberActive);
  }

  /// Ancre la date de début de l’essai (premier accès au dashboard).
  static Future<void> ensureTrialAnchoredUtc() async {
    final p = await SharedPreferences.getInstance();
    if (!p.containsKey(_kTrialStartUtcMs)) {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await p.setInt(_kTrialStartUtcMs, now);
    }
  }

  /// Abonnement actif dans Firestore pour l’utilisateur Firebase courant (`uid`).
  static Future<bool> subscriberActiveFirestore() async {
    final row = await _subscriberEntitlementFirestoreRow();
    return row.active;
  }

  static Future<({bool active, DateTime? periodEndUtc, DateTime? proSinceUtc})>
      _subscriberEntitlementFirestoreRow() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      return (active: false, periodEndUtc: null, proSinceUtc: null);
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection(kPaychekSubscriberEntitlementsCollection)
          .doc(u.uid)
          .get(const GetOptions(source: Source.serverAndCache));

      final data = doc.data();
      if (data == null) {
        return (active: false, periodEndUtc: null, proSinceUtc: null);
      }

      final active = data['active'] == true;
      DateTime? periodEndUtc;
      for (final key in ['currentPeriodEnd', 'expiresAt', 'periodEnd']) {
        final v = data[key];
        if (v is Timestamp) {
          periodEndUtc = v.toDate().toUtc();
          break;
        }
      }
      DateTime? proSinceUtc;
      for (final key in ['proSinceUtc', 'proSince', 'currentPeriodStart']) {
        final v = data[key];
        if (v is Timestamp) {
          proSinceUtc = v.toDate().toUtc();
          break;
        }
      }
      return (active: active, periodEndUtc: periodEndUtc, proSinceUtc: proSinceUtc);
    } catch (e, st) {
      debugPrint('[Paychek] subscriber_entitlements: $e\n$st');
      return (active: false, periodEndUtc: null, proSinceUtc: null);
    }
  }

  /// Secours admin (sans échéance Stripe) : +1 an civil à partir de [proSinceUtc].
  static DateTime? webProLicenseEndUtc(DateTime? proSinceUtc) {
    if (proSinceUtc == null) return null;
    final u = proSinceUtc.toUtc();
    return DateTime.utc(
      u.year + 1,
      u.month,
      u.day,
      u.hour,
      u.minute,
      u.second,
      u.millisecond,
      u.microsecond,
    );
  }

  /// Fin Pro affichée : priorité à l’échéance Stripe / Firestore (`currentPeriodEnd`, déjà
  /// prolongée côté Functions si achat pendant l’essai). Secours +1 an civil uniquement sans
  /// date d’échéance (ex. Pro accordé par l’admin).
  static DateTime? proSubscriptionDisplayEndUtc({
    required bool isWebUi,
    DateTime? proSinceUtc,
    DateTime? subscriptionPeriodEndUtc,
  }) {
    if (subscriptionPeriodEndUtc != null) {
      return subscriptionPeriodEndUtc;
    }
    return webProLicenseEndUtc(proSinceUtc);
  }

  /// Back-office : priorité à l’échéance Firestore (`currentPeriodEnd`, inclut crédit essai côté
  /// Functions), sinon licence civile +1 an à partir de [proSinceUtc].
  static DateTime? proSubscriptionAdminEndUtc({
    DateTime? proSinceUtc,
    DateTime? subscriptionPeriodEndUtc,
  }) =>
      subscriptionPeriodEndUtc ?? webProLicenseEndUtc(proSinceUtc);

  /// Invité : pas de limite Lite. Connecté : ancrage = `paychek_users.createdAt` si présent,
  /// sinon premier lancement local. Fin d’accès plein = [kPaychekUserFieldTrialFreemiumOverrideUntil]
  /// (admin) ou ancrage + 7 j. Pro = prefs · `subscriber_entitlements` · doc `paychek_users`.
  ///
  /// **Préférer** [loadGateStateAndAccountEntitlement] au démarrage du dashboard : un seul aller
  /// réseau parallèle au lieu d’appeler [loadGateState] puis [loadAccountEntitlement] (doublons).
  static Future<TrialGateVm> loadGateState() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      return const TrialGateVm(
        liteFreemiumRestricted: false,
        anchorUtc: null,
        effectiveFullAccessEndUtc: null,
      );
    }
    return (await loadGateStateAndAccountEntitlement()).gate;
  }

  static Future<({TrialGateVm gate, AccountEntitlementSnapshot entitlement})>?
      _signedInAccessFuture;

  /// Une lecture parallèle `paychek_users` + `subscriber_entitlements` + prefs, puis calcul des
  /// deux vues (essai / Lite **et** statut Pro affiché). Les appels concurrents partagent la même [Future].
  static Future<({TrialGateVm gate, AccountEntitlementSnapshot entitlement})>
      loadGateStateAndAccountEntitlement() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      return (
        gate: const TrialGateVm(
          liteFreemiumRestricted: false,
          anchorUtc: null,
          effectiveFullAccessEndUtc: null,
        ),
        entitlement: const AccountEntitlementSnapshot(
          isPro: false,
          trialActive: false,
          daysLeftInTrial: 0,
          trialEndUtc: null,
          anchorUtc: null,
          subscriptionPeriodEndUtc: null,
          proSinceUtc: null,
        ),
      );
    }

    _signedInAccessFuture ??=
        _loadSignedInUserAccess(u).whenComplete(() => _signedInAccessFuture = null);
    return _signedInAccessFuture!;
  }

  static Future<({TrialGateVm gate, AccountEntitlementSnapshot entitlement})>
      _loadSignedInUserAccess(User u) async {
    final parallel = await Future.wait<Object>([
      _readPaychekUserTrialBootstrap(u),
      _subscriberEntitlementFirestoreRow(),
      SharedPreferences.getInstance(),
    ]);
    final row = parallel[0]
        as ({
          DateTime? createdAtUtc,
          DateTime? trialFreemiumOverrideUntilUtc,
          bool docPro,
          DateTime? subscriptionTierUpdatedAtUtc,
          DateTime? subscriptionCurrentPeriodEndUtc,
          bool userDocExists,
          bool fetchSucceeded,
        });
    final subRow = parallel[1]
        as ({bool active, DateTime? periodEndUtc, DateTime? proSinceUtc});
    final p = parallel[2] as SharedPreferences;

    if (row.createdAtUtc != null) {
      await p.setInt(
        _kTrialStartUtcMs,
        row.createdAtUtc!.millisecondsSinceEpoch,
      );
    } else if (row.fetchSucceeded && !row.userDocExists) {
      // Nouveau compte cloud : ancrage local du 1er accès.
      await ensureTrialAnchoredUtc();
    }
    // Doc existant sans date OU lecture Firestore en échec : ne pas réancrer l’essai
    // (évite un 2e essai de 7 j sur Android quand le réseau/cache diffère de l’iPhone).

    final localSub = p.getBool(_kSubscriberActive) ?? false;
    final ms = p.getInt(_kTrialStartUtcMs);
    final anchorUtc = ms != null
        ? DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)
        : null;

    final remoteSub = subRow.active;

    final TrialGateVm gate;
    if (localSub || row.docPro) {
      final eff = anchorUtc == null
          ? null
          : _effectiveTrialFullAccessEndUtc(
              anchorUtc,
              row.trialFreemiumOverrideUntilUtc,
            );
      gate = TrialGateVm(
        liteFreemiumRestricted: false,
        anchorUtc: anchorUtc,
        effectiveFullAccessEndUtc: eff,
      );
    } else if (remoteSub) {
      final eff = anchorUtc == null
          ? null
          : _effectiveTrialFullAccessEndUtc(
              anchorUtc,
              row.trialFreemiumOverrideUntilUtc,
            );
      gate = TrialGateVm(
        liteFreemiumRestricted: false,
        anchorUtc: anchorUtc,
        effectiveFullAccessEndUtc: eff,
      );
    } else if (anchorUtc == null) {
      gate = const TrialGateVm(
        liteFreemiumRestricted: false,
        anchorUtc: null,
        effectiveFullAccessEndUtc: null,
      );
    } else {
      final effectiveEnd = _effectiveTrialFullAccessEndUtc(
        anchorUtc,
        row.trialFreemiumOverrideUntilUtc,
      );
      final expired = DateTime.now().toUtc().isAfter(effectiveEnd);
      gate = TrialGateVm(
        liteFreemiumRestricted: expired,
        anchorUtc: anchorUtc,
        effectiveFullAccessEndUtc: effectiveEnd,
      );
    }

    final remoteSubEnt = localSub || subRow.active;
    final isPro = localSub || remoteSubEnt || row.docPro;

    final DateTime? subscriptionPeriodEndUtc = isPro
        ? (subRow.periodEndUtc ?? row.subscriptionCurrentPeriodEndUtc)
        : null;
    final DateTime? proSinceUtc = isPro
        ? _resolveProSinceUtc(
            subRow: subRow,
            row: row,
          )
        : null;

    final AccountEntitlementSnapshot entitlement;
    if (anchorUtc == null || isPro) {
      final endUtc = anchorUtc == null
          ? null
          : _effectiveTrialFullAccessEndUtc(
              anchorUtc,
              row.trialFreemiumOverrideUntilUtc,
            );
      entitlement = AccountEntitlementSnapshot(
        isPro: isPro,
        trialActive: false,
        daysLeftInTrial: 0,
        trialEndUtc: endUtc,
        anchorUtc: anchorUtc,
        subscriptionPeriodEndUtc: subscriptionPeriodEndUtc,
        proSinceUtc: proSinceUtc,
      );
    } else {
      final endUtc = _effectiveTrialFullAccessEndUtc(
        anchorUtc,
        row.trialFreemiumOverrideUntilUtc,
      );
      final nowUtc = DateTime.now().toUtc();
      final trialActive = !nowUtc.isAfter(endUtc);

      var daysLeft = 0;
      if (trialActive) {
        final diff = endUtc.difference(nowUtc);
        daysLeft = diff.inDays;
        if (diff > Duration.zero && daysLeft == 0) {
          daysLeft = 1;
        }
      }

      entitlement = AccountEntitlementSnapshot(
        isPro: false,
        trialActive: trialActive,
        daysLeftInTrial: daysLeft,
        trialEndUtc: endUtc,
        anchorUtc: anchorUtc,
        subscriptionPeriodEndUtc: null,
        proSinceUtc: null,
      );
    }

    return (gate: gate, entitlement: entitlement);
  }

  static DateTime trialEndUtc(DateTime anchorUtc) =>
      anchorUtc.add(kPaychekTrialDuration);

  /// Pour l’UI profil / statut Pro · Lite · essai.
  ///
  /// Délègue à [loadGateStateAndAccountEntitlement] pour éviter un second aller Firestore si le
  /// gate vient d’être chargé dans le même tick.
  static Future<AccountEntitlementSnapshot> loadAccountEntitlement() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      return const AccountEntitlementSnapshot(
        isPro: false,
        trialActive: false,
        daysLeftInTrial: 0,
        trialEndUtc: null,
        anchorUtc: null,
        subscriptionPeriodEndUtc: null,
        proSinceUtc: null,
      );
    }
    return (await loadGateStateAndAccountEntitlement()).entitlement;
  }
}
