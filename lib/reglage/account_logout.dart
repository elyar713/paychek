import 'dart:async';

import 'package:flutter/material.dart';

import 'reglage_profile_prefs.dart';
import 'social_auth_service.dart';
import 'trial_access_prefs.dart';
import 'user_profile_scope.dart';

/// Efface le profil stocké et les prefs Paychek, met à jour [UserProfileScope].
/// Firebase / Google / Facebook sont coupés **en arrière-plan** pour ne pas bloquer l’UI.
Future<void> applyLocalLogout(BuildContext context) async {
  await ReglageProfilePrefs.clearStoredAccountProfile();
  await TrialAccessPrefs.clearPaychekLocalEntitlements();
  final data = await ReglageProfilePrefs.load();
  if (!context.mounted) return;
  UserProfileScope.of(context).setProfile(data);
  unawaited(signOutEverywhere());
}
