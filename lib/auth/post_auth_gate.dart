import 'dart:async' show unawaited;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dashboard_page.dart';
import '../onboarding_language_page.dart';
import '../reglage/paychek_user_firestore.dart';
import '../reglage/reglage_profile_prefs.dart';
import '../reglage/user_profile_scope.dart';
import '../questionnaire/questionnaire_flow.dart';
import '../splash_screen.dart';
import 'mobile_mandatory_auth_screen.dart';

/// `paychek_users/{uid}.hasCompletedPaychekQuestionnaire == false` → questionnaire obligatoire.
/// Champ absent ou `true` → tableau de bord (comptes existants / déjà complété).
bool _requiresQuestionnaire(DocumentSnapshot<Object?> doc) {
  if (!doc.exists) return false;
  final raw = doc.data();
  if (raw is! Map) return false;
  final map = Map<String, dynamic>.from(raw);
  return map[kPaychekUserFieldQuestionnaireComplete] == false;
}

/// Après connexion Firebase : questionnaire une seule fois pour les nouveaux comptes, sinon dashboard.
class PostAuthGate extends StatefulWidget {
  const PostAuthGate({super.key, required this.user});

  final User user;

  @override
  State<PostAuthGate> createState() => _PostAuthGateState();
}

class _PostAuthGateState extends State<PostAuthGate> {
  bool _syncStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Robustesse: on force une sync post-auth une fois (création doc si absent).
    // Ça garantit `hasCompletedPaychekQuestionnaire: false` pour les nouveaux comptes,
    // même si le formulaire d’inscription n’a pas pu écrire Firestore (réseau / timing).
    if (_syncStarted) return;
    _syncStarted = true;
    // Fire-and-forget: ne pas bloquer l'UI.
    unawaited(() async {
      final prefs = await ReglageProfilePrefs.load();
      final prenom = prefs.prenom.trim();
      final nom = prefs.nom.trim();
      if (prenom.isNotEmpty || nom.isNotEmpty) {
        await syncPaychekUserDocument(
          widget.user,
          firstName: prenom.isNotEmpty ? prenom : null,
          lastName: nom.isNotEmpty ? nom : null,
        );
        await paychekMergeProfileFromFirestore(widget.user);
      } else {
        await syncPaychekUserDocumentAndMergeProfile(widget.user);
      }
      if (!mounted) return;
      try {
        await UserProfileScope.of(context).load();
      } catch (e, st) {
        debugPrint('[Paychek] PostAuthGate profile reload: $e\n$st');
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Object?>>(
      stream: FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.user.uid)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          debugPrint('[Paychek] PostAuthGate: ${snap.error}');
          return const DashboardPage();
        }
        final doc = snap.data;
        if (doc != null && doc.exists && _requiresQuestionnaire(doc)) {
          return QuestionnaireFlow(
            onFinished: () => setPaychekQuestionnaireCompleted(widget.user),
          );
        }
        // Dashboard tout de suite (cache local) ; le questionnaire s’affiche
        // dès que Firestore confirme hasCompletedPaychekQuestionnaire == false.
        return const DashboardPage();
      },
    );
  }
}

/// Mobile : hors session → splash → langue → **connexion obligatoire** (pas d’accès invité).
/// Connecté → [PostAuthGate] (questionnaire seulement si `hasCompletedPaychekQuestionnaire == false`).
class MobileRootGate extends StatefulWidget {
  const MobileRootGate({super.key});

  @override
  State<MobileRootGate> createState() => _MobileRootGateState();
}

class _MobileRootGateState extends State<MobileRootGate> {
  /// 0 splash, 1 langue, 2 authentification obligatoire.
  int _preAuthStep = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snap) {
        final u = snap.data ?? FirebaseAuth.instance.currentUser;
        if (u != null) {
          return PostAuthGate(key: ValueKey(u.uid), user: u);
        }
        if (_preAuthStep == 0) {
          return SplashScreen(
            onFinished: () {
              if (mounted) setState(() => _preAuthStep = 1);
            },
          );
        }
        if (_preAuthStep == 1) {
          return OnboardingLanguagePage(
            onContinueWithoutNavigator: () {
              if (mounted) setState(() => _preAuthStep = 2);
            },
          );
        }
        return const MobileMandatoryAuthScreen();
      },
    );
  }
}
