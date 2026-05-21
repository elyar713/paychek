import 'dart:async' show StreamSubscription, unawaited;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dashboard_page.dart';
import '../onboarding_language_page.dart';
import '../questionnaire/questionnaire_completion_prefs.dart';
import '../questionnaire/questionnaire_flow.dart';
import '../reglage/paychek_user_firestore.dart';
import '../reglage/reglage_profile_prefs.dart';
import '../reglage/user_profile_scope.dart';
import '../shared/paychek_boot_splash.dart';
import '../splash_screen.dart';
import 'mobile_mandatory_auth_screen.dart';

/// Décide si le questionnaire est obligatoire (local + Firestore).
Future<bool> paychekNeedsQuestionnaire({
  required String uid,
  DocumentSnapshot<Map<String, dynamic>>? firestoreDoc,
}) async {
  if (await QuestionnaireCompletionPrefs.isLocallyCompleted(uid)) {
    return false;
  }
  if (await QuestionnaireCompletionPrefs.isLocallyPending(uid)) {
    return true;
  }

  DocumentSnapshot<Map<String, dynamic>>? doc = firestoreDoc;
  if (doc == null) {
    try {
      doc = await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(uid)
          .get(const GetOptions(source: Source.serverAndCache));
    } catch (e, st) {
      debugPrint('[Paychek] paychekNeedsQuestionnaire get: $e\n$st');
      return true;
    }
  }

  if (!doc.exists) return true;
  final data = doc.data();
  if (data == null) return true;

  final raw = data[kPaychekUserFieldQuestionnaireComplete];
  if (raw == true) {
    await QuestionnaireCompletionPrefs.markCompleted(uid);
    return false;
  }
  if (raw == false) {
    await QuestionnaireCompletionPrefs.markIncomplete(uid);
    return true;
  }
  // Champ absent : compte existant avant le questionnaire obligatoire.
  return false;
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
  bool _questionnaireFinishedLocally = false;
  bool _gateResolved = false;
  bool? _needsQuestionnaire;
  bool _resolveInFlight = false;
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  @override
  void initState() {
    super.initState();
    _userDocSub = FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(widget.user.uid)
        .snapshots()
        .listen(_onFirestoreSnapshot);
    _startInitialSync();
  }

  @override
  void dispose() {
    _userDocSub?.cancel();
    super.dispose();
  }

  void _startInitialSync() {
    if (_syncStarted) return;
    _syncStarted = true;
    unawaited(() async {
      try {
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
        if (mounted) {
          try {
            await UserProfileScope.of(context).load();
          } catch (e, st) {
            debugPrint('[Paychek] PostAuthGate profile reload: $e\n$st');
          }
        }
      } finally {
        if (mounted) {
          await _resolveGateFromDoc(_lastDoc);
        }
      }
    }());
  }

  Future<void> _resolveGateFromDoc(
    DocumentSnapshot<Map<String, dynamic>>? doc,
  ) async {
    if (_resolveInFlight || !mounted || _gateResolved) return;
    _resolveInFlight = true;
    try {
      final needs = await paychekNeedsQuestionnaire(
        uid: widget.user.uid,
        firestoreDoc: doc,
      );
      if (!mounted) return;
      setState(() {
        _needsQuestionnaire = needs;
        _gateResolved = true;
      });
    } catch (e, st) {
      debugPrint('[Paychek] PostAuthGate needs: $e\n$st');
      if (!mounted) return;
      setState(() {
        _needsQuestionnaire = true;
        _gateResolved = true;
      });
    } finally {
      _resolveInFlight = false;
    }
  }

  void _onFirestoreSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    _lastDoc = doc;
    if (!_gateResolved) {
      unawaited(_resolveGateFromDoc(doc));
      return;
    }
    unawaited(() async {
      final needs = await paychekNeedsQuestionnaire(
        uid: widget.user.uid,
        firestoreDoc: doc,
      );
      if (!mounted || needs == _needsQuestionnaire) return;
      setState(() => _needsQuestionnaire = needs);
    }());
  }

  Widget _loading() {
    return const PaychekBootSplash();
  }

  Widget _questionnaire() {
    return QuestionnaireFlow(
      onFinished: () async {
        await QuestionnaireCompletionPrefs.markCompleted(widget.user.uid);
        await setPaychekQuestionnaireCompleted(widget.user);
        if (mounted) {
          setState(() => _questionnaireFinishedLocally = true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questionnaireFinishedLocally) {
      return const DashboardPage();
    }

    if (!_gateResolved) {
      return _loading();
    }
    if (_needsQuestionnaire == true) {
      return _questionnaire();
    }
    return const DashboardPage();
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
