import 'package:flutter/material.dart';

/// Modèles légers pour l’admin (données démo ou Firestore futur).

/// Stocké dans `paychek_users.subscriptionTier` : **`lite`** (défaut, non payant) ou **`pro`** (payant ou forcé depuis le back-office).
///
/// Anciennes entrées **`none`** ou champ absent ⇒ interprété comme **`lite`**.
/// Legacy **`isPremium == true`** sans `subscriptionTier == pro` explicite ⇒ **`pro`**.
enum PaychekSubscriptionTier {
  lite,
  pro,
}

extension PaychekSubscriptionTierX on PaychekSubscriptionTier {
  /// Valeur stockée dans Firestore pour ce tier (toujours minuscules).
  String get firestoreValue => switch (this) {
        PaychekSubscriptionTier.lite => 'lite',
        PaychekSubscriptionTier.pro => 'pro',
      };

  static String _subscriptionTierRaw(Map<String, dynamic> d) {
    final v = d['subscriptionTier'];
    if (v == null) return '';
    return v.toString().trim().toLowerCase();
  }

  static PaychekSubscriptionTier fromFirestoreMap(Map<String, dynamic> d) {
    final raw = _subscriptionTierRaw(d);
    if (raw == 'pro') return PaychekSubscriptionTier.pro;
    if (raw == 'lite') return PaychekSubscriptionTier.lite;
    if (d['isPremium'] == true) return PaychekSubscriptionTier.pro;
    return PaychekSubscriptionTier.lite;
  }

  String get adminShortLabel => switch (this) {
        PaychekSubscriptionTier.lite => 'Lite',
        PaychekSubscriptionTier.pro => 'Pro',
      };

  String get adminChipLabel => switch (this) {
        PaychekSubscriptionTier.lite => 'LITE',
        PaychekSubscriptionTier.pro => 'PRO',
      };
}

class AdminUserRow {
  const AdminUserRow({
    required this.id,
    required this.email,
    required this.joinedAt,
    required this.country,
    required this.subscriptionTier,
    this.firstName = '',
    this.lastName = '',
    this.birthDate,
    this.paymentMethod = '',
    this.importedTrades = 0,
    this.platformsSeen = const [],
    this.lastSeenPlatform = '',
    this.accessWebEnabled = true,
    this.accessMobileEnabled = true,
    this.appLanguageCode = '',
    this.trialFreemiumOverrideUntil,
    this.lastSeenAt,
    this.appOpenDatesUtc = const [],
    this.subscriptionTierUpdatedAt,
    this.subscriptionCurrentPeriodEnd,
    this.subscriptionProSinceUtc,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;

  /// Stockée dans Firestore comme `birthDate` (jour civil, fuseau ignorant).
  final DateTime? birthDate;

  /// Ex. `stripe`, `apple`, `google` — renseigné par IAP / webhook si disponible.
  final String paymentMethod;
  final DateTime joinedAt;
  final String country;
  final PaychekSubscriptionTier subscriptionTier;
  final int importedTrades;

  /// Plateformes déjà vues par l’app (`web`, `android`, `ios`, `desktop`).
  final List<String> platformsSeen;

  /// Dernière plateforme lors du dernier sync (même vocabulaire que [platformsSeen]).
  final String lastSeenPlatform;

  /// Contrôle admin — accès navigateur (défaut : autorisé si absent en base).
  final bool accessWebEnabled;

  /// Contrôle admin — apps Android / iOS (défaut : autorisé si absent en base).
  final bool accessMobileEnabled;

  /// Code locale app (`ReglageLanguagePrefs`), ex. `fr` · `en` · synchronisé sur `paychek_users`.
  final String appLanguageCode;

  /// Fin d’accès **plein** (avant Lite) imposée par l’admin — voir [kPaychekUserFieldTrialFreemiumOverrideUntil].
  final DateTime? trialFreemiumOverrideUntil;

  /// Dernière synchro profil / connexion (`lastSeenAt`).
  final DateTime? lastSeenAt;

  /// Horodatage du dernier passage Lite ⟷ Pro par l’admin (`subscriptionTierUpdatedAt`).
  final DateTime? subscriptionTierUpdatedAt;

  /// Miroir Functions : fin de période Stripe (+ crédit essai), pour l’admin sans lire `subscriber_entitlements`.
  final DateTime? subscriptionCurrentPeriodEnd;

  /// Miroir Functions : début période Pro (`proSinceUtc`).
  final DateTime? subscriptionProSinceUtc;

  /// Jours civils UTC (`yyyy-MM-dd`) avec au moins une ouverture app (voir [kPaychekUserFieldAppOpenDatesUtcV1]).
  final List<String> appOpenDatesUtc;

  /// Formule avec accès Premium (tier Pro).
  bool get hasPaidPlan => subscriptionTier == PaychekSubscriptionTier.pro;
}

class AdminLiveFeedItem {
  const AdminLiveFeedItem({
    required this.message,
    required this.actor,
    required this.agoLabel,
    required this.dotColor,
  });

  final String message;
  final String actor;
  final String agoLabel;
  final Color dotColor;
}

class PaymentRow {
  const PaymentRow({
    required this.id,
    required this.amountUsd,
    required this.status,
    required this.userHandle,
    required this.date,
  });

  final String id;
  final double amountUsd;
  final String status;
  final String userHandle;
  final DateTime date;
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.fromEmail,
    required this.kind,
    required this.createdAt,
    this.status = 'open',
  });

  final String id;
  final String subject;
  final String fromEmail;
  final String kind;
  final DateTime createdAt;
  final String status;
}

class FeatureRequestRow {
  const FeatureRequestRow({
    required this.id,
    required this.title,
    required this.votes,
    required this.status,
  });

  final String id;
  final String title;
  final int votes;
  final String status;
}
