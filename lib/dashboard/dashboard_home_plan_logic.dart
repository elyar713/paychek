import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../reglage/trial_access_prefs.dart';

/// Règles **communes web / mobile** pour l’en-tête d’accueil : pastille Pro/Lite et CTA upgrade.
///
/// La source de vérité du statut est [TrialAccessPrefs.loadAccountEntitlement] ; le parent
/// ([DashboardPage]) charge [AccountEntitlementSnapshot] puis transmet [isProKnown]
/// à [DashboardHomeContent] comme `accountPlanIsPro`.
abstract final class DashboardHomePlanLogic {
  DashboardHomePlanLogic._();

  /// Pastille plan : affichée seulement une fois l’entitlement résolu (`null` = encore en chargement).
  static bool shouldShowPlanBadge(bool? isProKnown) => isProKnown != null;

  /// CTA « Upgrade » sur le hero : jamais si Pro avéré ; jamais sans callback parent.
  static bool shouldShowHomeUpgrade({
    required bool? isProKnown,
    required VoidCallback? upgradeTap,
  }) =>
      upgradeTap != null && isProKnown != true;

  /// Valeur à passer à [DashboardHomeContent.onHomeUpgradeTap] : utilisateur connecté,
  /// entitlement **déjà chargé**, et compte **non** Pro. [onVoluntaryGoldUpgrade] ouvre la
  /// feuille **HTML Gold** (marketing). Le blocage Lite (pages interdites) utilise
  /// [TrialPaywallOverlay] via un autre callback.
  static VoidCallback? resolveHomeUpgradeTap({
    required User? currentUser,
    required AccountEntitlementSnapshot? entitlement,
    required VoidCallback onVoluntaryGoldUpgrade,
  }) {
    if (currentUser == null) return null;
    if (entitlement == null) return null;
    if (entitlement.isPro) return null;
    return onVoluntaryGoldUpgrade;
  }
}
