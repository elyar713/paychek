import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async' show StreamSubscription, Timer, unawaited;
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'reglage/social_auth_config.dart';
import 'reglage/social_auth_service.dart';
import 'reglage/app_locale_scope.dart';
import 'reglage/trading_week_scope.dart';
import 'reglage/trading_week_firestore_sync.dart';
import 'reglage/user_portfolio_scope.dart';
import 'reglage/user_portfolio_store.dart';
import 'reglage/user_profile_scope.dart';
import 'reglage/user_profile_store.dart';
import 'questionnaire/user_capital_scope.dart';
import 'questionnaire/user_capital_store.dart';
import 'questionnaire/questionnaire_flow.dart';
import 'dashboard/dashboard_home_layout_scope.dart';
import 'dashboard/dashboard_home_layout_store.dart';
import 'dashboard/dashboard_home_layout_firestore_sync.dart';
import 'reglage/capital_portfolio_firestore_sync.dart';
import 'reglage/paychek_firestore_push_guard.dart';
import 'reglage/paychek_user_firestore.dart';
import 'trade/trade_journal_scope.dart';
import 'trade/trade_journal_firestore_sync.dart';
import 'trade/trade_journal_storage.dart';
import 'trade/trade_journal_store.dart';
import 'trade/trade_models.dart';
import 'auth/post_auth_gate.dart';
import 'web/web_auth_gate.dart';
import 'etat_mental/mental_state_controller.dart';
import 'etat_mental/mental_state_firestore_sync.dart';
import 'strategie/strategie_setups_store.dart';
import 'strategie/strategie_setup_usage_store.dart';
import 'strategie/strategie_firestore_sync.dart';
import 'strategie/strategie_realtime_notifier.dart';
import 'analyse/analyse_firestore_sync.dart';
import 'analyse/analyse_realtime_notifier.dart';
import 'ajouter_trade/ajouter_trade_custom_actifs_storage.dart';
import 'checklist/checklist_firestore_sync.dart';
import 'checklist/checklist_realtime_notifier.dart';

/// Analytics (GA4) : implémentation pigeon **Android, iOS, macOS, Web** — pas de host Windows/Linux.
bool get _firebaseAnalyticsHostAvailable {
  if (kIsWeb) return true;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return false;
  }
}

/// Analytics (GA4) : plugin FlutterFire uniquement **Android, iOS, macOS, Web**.
void _warnIfAnalyticsUnavailableOnDesktop() {
  if (_firebaseAnalyticsHostAvailable) return;
  debugPrint(
    '[Paychek] Firebase Analytics n’envoie pas sur Windows/Linux depuis Flutter. '
    'Les cartes « Analytics » de la console ne bougent pas sur cette cible ; '
    'teste avec `flutter run -d chrome`, un téléphone ou un émulateur Android.',
  );
  if (defaultTargetPlatform == TargetPlatform.windows) {
    debugPrint(
      '[Paychek] Firebase Auth sur Windows (plugin C++) peut renvoyer des erreurs '
      '« unknown » ou échouer alors que mobile / Web fonctionnent — limitation FlutterFire ; '
      'l’écran Réglages affiche un rappel avec lien paychek.pro.',
    );
    debugPrint(
      '[Paychek] Firestore sur Windows (plugin C++) peut afficher '
      '« non-platform thread » ou planter (codec) — cible non officielle ; '
      'préfère le Web ou Android/iOS pour le flux complet Firebase.',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Windows : persistance SQLite + threads natifs → plantages / codec (ex. type 142) signalés côté FlutterFire.
  // Désactivation avant le 1er accès Firestore (obligatoire pour que [settings] soit prise en compte).
  if (defaultTargetPlatform == TargetPlatform.windows) {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
    } catch (e, st) {
      debugPrint('[Paychek] Firestore settings (Windows): $e\n$st');
    }
  }

  // Sur le Web, [GoogleSignIn.initialize] peut lancer UnimplementedError ; pas nécessaire ici.
  if (!kIsWeb && isGoogleSignInAvailableOnThisPlatform()) {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: kGoogleOAuthWebClientId.isNotEmpty
            ? kGoogleOAuthWebClientId
            : null,
      );
    } catch (e, st) {
      debugPrint('[Paychek] GoogleSignIn.initialize failed: $e\n$st');
    }
  }

  // Windows/Linux : pas d’hôte Pigeon Analytics — évite PlatformException inutile au démarrage.
  if (_firebaseAnalyticsHostAvailable) {
    unawaited(
      FirebaseAnalytics.instance.logAppOpen().catchError((Object e, StackTrace st) {
        debugPrint('[Paychek] FirebaseAnalytics.logAppOpen ignoré: $e\n$st');
      }),
    );
  }
  _warnIfAnalyticsUnavailableOnDesktop();

  assert(() {
    // Prevent accidental debug visual overlays (e.g. baselines) from staying enabled.
    debugPaintBaselinesEnabled = false;
    return true;
  }());

  final capitalStore = UserCapitalStore();
  await capitalStore.load();
  final portfolioStore = UserPortfolioStore();
  await portfolioStore.load(seedCapital: capitalStore);
  final tradeJournalStore = TradeJournalStore();
  final appLocaleController = AppLocaleController();
  await appLocaleController.load();
  final tradingWeekController = TradingWeekController();
  await tradingWeekController.load();
  await MentalStateController.instance.loadSharePreferences();
  final userProfileStore = UserProfileStore();
  await userProfileStore.load();
  runApp(PaychekApp(
    capitalStore: capitalStore,
    portfolioStore: portfolioStore,
    tradeJournalStore: tradeJournalStore,
    userProfileStore: userProfileStore,
    appLocaleController: appLocaleController,
    tradingWeekController: tradingWeekController,
  ));
}

class PaychekApp extends StatefulWidget {
  const PaychekApp({
    super.key,
    required this.capitalStore,
    required this.portfolioStore,
    required this.tradeJournalStore,
    required this.userProfileStore,
    this.appLocaleController,
    this.tradingWeekController,
  });

  final UserCapitalStore capitalStore;
  final UserPortfolioStore portfolioStore;
  final TradeJournalStore tradeJournalStore;
  final UserProfileStore userProfileStore;

  /// AprÃ¨s hot reload (web), peut Ãªtre null : [State] crÃ©e un contrÃ´leur de secours.
  final AppLocaleController? appLocaleController;

  final TradingWeekController? tradingWeekController;

  @override
  State<PaychekApp> createState() => _PaychekAppState();
}

class _PaychekAppState extends State<PaychekApp> with WidgetsBindingObserver {
  AppLocaleController? _localeCtrl;

  AppLocaleController get _locale {
    _localeCtrl ??= widget.appLocaleController ?? AppLocaleController();
    return _localeCtrl!;
  }

  TradingWeekController? _tradingWeekCtrl;

  TradingWeekController get _tradingWeek {
    _tradingWeekCtrl ??= widget.tradingWeekController ?? TradingWeekController();
    return _tradingWeekCtrl!;
  }

  /// Jamais [late final] seul : après hot reload (web), un [State] ancien peut
  /// avoir ce champ à null tant que l’instance n’a pas été recréée.
  DashboardHomeLayoutStore? _dashboardHomeLayoutStore;
  StreamSubscription<User?>? _authSub;
  String? _lastAuthUid;
  Timer? _capitalPortfolioCloudPushDebounce;
  Timer? _tradingWeekCloudPushDebounce;
  Timer? _dashboardLayoutCloudPushDebounce;
  Timer? _mentalStateCloudPushDebounce;
  Timer? _strategieCloudPushDebounce;

  StreamSubscription? _realtimeCapitalPortfolioSub;
  StreamSubscription? _realtimeTradingWeekSub;
  StreamSubscription? _realtimeDashboardLayoutSub;
  StreamSubscription? _realtimeMentalStateSub;
  StreamSubscription? _realtimeStrategieSub;
  StreamSubscription? _realtimeAnalyseSub;
  StreamSubscription? _realtimeJournalSub;
  StreamSubscription? _realtimeChecklistSub;

  DashboardHomeLayoutStore _dashboardHomeLayoutOrCreate() {
    if (_dashboardHomeLayoutStore == null) {
      final s = DashboardHomeLayoutStore();
      _dashboardHomeLayoutStore = s;
      // Sur web, `load()` déclenche `notifyListeners()` (SharedPreferences) et peut tomber
      // pendant une phase de layout/hot reload → erreurs type "_RenderDeferredLayoutBox mutated".
      // On décale au frame suivant pour éviter toute mutation pendant `performLayout`.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        s.load();
      });
      s.addListener(_scheduleDashboardLayoutCloudPush);
    }
    return _dashboardHomeLayoutStore!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.appLocaleController == null) {
      _locale.load();
    }
    if (widget.tradingWeekController == null) {
      _tradingWeek.load();
    }
    _dashboardHomeLayoutOrCreate();

    _lastAuthUid = FirebaseAuth.instance.currentUser?.uid;
    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
      final uid = u?.uid;
      if (uid == _lastAuthUid) return;
      final previousFirebaseUid = _lastAuthUid;
      _lastAuthUid = uid;
      unawaited(
        _reloadLocalStoresForAccount(
          previousFirebaseUid: previousFirebaseUid,
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sess = FirebaseAuth.instance.currentUser;
      if (sess != null) {
        try {
          await paychekMergeAppLanguageFromFirestore(sess).timeout(
            const Duration(seconds: 6),
          );
          if (mounted) await _locale.load();
        } catch (e, st) {
          debugPrint(
            '[Paychek] paychekMergeAppLanguageFromFirestore (post-frame): $e\n$st',
          );
        }
      }
      // Hydrater le journal **avant** d’attacher les listeners : sinon le premier snapshot
      // `!exists` + store vide pouvait enchaîner set/snapshot et saturer le heap (GC bloquant).
      await _hydrateTradeJournalFromPrefs();
      if (!mounted) return;
      if (FirebaseAuth.instance.currentUser != null) {
        await PaychekFirestorePushGuard.runCloudHydration(
          _mergeSignedInFirestoreAfterFirstFrame,
        );
      }
      if (!mounted) return;
      _startRealtimeSyncIfSignedIn();
    });
    widget.capitalStore.addListener(_scheduleCapitalPortfolioCloudPush);
    widget.portfolioStore.addListener(_scheduleCapitalPortfolioCloudPush);
    _tradingWeek.addListener(_scheduleTradingWeekCloudPush);
    MentalStateController.instance.addListener(_scheduleMentalStateCloudPush);
    StrategieSetupsStore.notifier.addListener(_scheduleStrategieCloudPush);
    StrategieSetupUsageStore.notifier.addListener(_scheduleStrategieCloudPush);
  }

  void _stopRealtimeSync() {
    _realtimeCapitalPortfolioSub?.cancel();
    _realtimeTradingWeekSub?.cancel();
    _realtimeDashboardLayoutSub?.cancel();
    _realtimeMentalStateSub?.cancel();
    _realtimeStrategieSub?.cancel();
    _realtimeAnalyseSub?.cancel();
    _realtimeJournalSub?.cancel();
    _realtimeChecklistSub?.cancel();
    _realtimeCapitalPortfolioSub = null;
    _realtimeTradingWeekSub = null;
    _realtimeDashboardLayoutSub = null;
    _realtimeMentalStateSub = null;
    _realtimeStrategieSub = null;
    _realtimeAnalyseSub = null;
    _realtimeJournalSub = null;
    _realtimeChecklistSub = null;
  }

  void _startRealtimeSyncIfSignedIn() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      _stopRealtimeSync();
      return;
    }
    _stopRealtimeSync();

    final base = FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(u.uid)
        .collection('sync_data');

    _realtimeCapitalPortfolioSub =
        base.doc('capital_portfolio_v1').snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) return;
      unawaited(
        CapitalPortfolioFirestoreSync.handleRemoteSnapshot(
          data,
          widget.capitalStore,
          widget.portfolioStore,
        ),
      );
    });

    _realtimeTradingWeekSub =
        base.doc('trading_week_v1').snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) return;
      unawaited(TradingWeekFirestoreSync.handleRemoteSnapshot(_tradingWeek, data));
    });

    _realtimeDashboardLayoutSub =
        base.doc('dashboard_home_layout_v1').snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) return;
      final store = _dashboardHomeLayoutOrCreate();
      unawaited(DashboardHomeLayoutFirestoreSync.handleRemoteSnapshot(store, data));
    });

    _realtimeMentalStateSub =
        base.doc('mental_state_v1').snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) return;
      MentalStateFirestoreSync.handleRemoteSnapshot(
        MentalStateController.instance,
        data,
      );
    });

    _realtimeStrategieSub =
        base.doc('strategie_v1').snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) return;
      unawaited(StrategieFirestoreSync.handleRemoteSnapshot(data));
    });

    _realtimeAnalyseSub = base.doc('analysis_v1').snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) return;
      unawaited(AnalyseFirestoreSync.handleRemoteSnapshot(data));
    });

    _realtimeJournalSub =
        base.doc('journal_trades_v1').snapshots().listen((snap) {
      if (!mounted) return;
      unawaited(
        TradeJournalFirestoreSync.handleRemoteSnapshot(
          widget.tradeJournalStore,
          snap,
        ),
      );
    });

    _realtimeChecklistSub =
        base.doc('checklist_nouveau_trade_v1').snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) return;
      unawaited(ChecklistFirestoreSync.handleRemoteSnapshot(data));
    });
  }

  void _scheduleCapitalPortfolioCloudPush() {
    if (!mounted) return;
    _capitalPortfolioCloudPushDebounce?.cancel();
    _capitalPortfolioCloudPushDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        unawaited(
          CapitalPortfolioFirestoreSync.pushIfSignedIn(
            widget.capitalStore,
            widget.portfolioStore,
          ),
        );
      },
    );
  }

  void _scheduleTradingWeekCloudPush() {
    if (!mounted) return;
    _tradingWeekCloudPushDebounce?.cancel();
    _tradingWeekCloudPushDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        unawaited(TradingWeekFirestoreSync.pushIfSignedIn(_tradingWeek));
      },
    );
  }

  void _scheduleDashboardLayoutCloudPush() {
    if (!mounted) return;
    final s = _dashboardHomeLayoutOrCreate();
    _dashboardLayoutCloudPushDebounce?.cancel();
    _dashboardLayoutCloudPushDebounce = Timer(
      const Duration(milliseconds: 700),
      () {
        unawaited(DashboardHomeLayoutFirestoreSync.pushIfSignedIn(s));
      },
    );
  }

  void _scheduleMentalStateCloudPush() {
    if (!mounted) return;
    _mentalStateCloudPushDebounce?.cancel();
    _mentalStateCloudPushDebounce = Timer(
      const Duration(milliseconds: 400),
      () {
        unawaited(
          MentalStateFirestoreSync.pushIfSignedIn(MentalStateController.instance),
        );
      },
    );
  }

  void _scheduleStrategieCloudPush() {
    if (!mounted) return;
    _strategieCloudPushDebounce?.cancel();
    _strategieCloudPushDebounce = Timer(
      const Duration(milliseconds: 900),
      () {
        unawaited(StrategieFirestoreSync.pushIfSignedIn());
      },
    );
  }

  Future<void> _hydrateTradeJournalFromPrefs() async {
    final list = await TradeJournalStorage.load();
    if (!mounted) return;
    if (list != null) {
      widget.tradeJournalStore.replaceAll(list);
    }
    try {
      await TradeJournalFirestoreSync.mergeFromCloudIntoStore(
        widget.tradeJournalStore,
      ).timeout(_deferredCloudMergeTimeout);
    } catch (e, st) {
      debugPrint('[Paychek] trade journal cloud merge: $e\n$st');
    }
  }

  /// LTE / appareils modestes : 12 s suffisait rarement ; évite merges support/journal/etc. annulés trop tôt.
  static const Duration _deferredCloudMergeTimeout = Duration(seconds: 28);

  Future<void> _mergeSignedInFirestoreAfterFirstFrame() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    Future<void> run(String label, Future<void> Function() op) async {
      try {
        await op().timeout(_deferredCloudMergeTimeout);
      } catch (e, st) {
        debugPrint('[Paychek] deferred cloud merge "$label": $e\n$st');
      }
    }

    // Phase 1 — profil + capital (accueil / réglages).
    await run('paychek_user', () => syncPaychekUserDocumentAndMergeProfile(u));
    if (!mounted) return;
    await widget.userProfileStore.load();
    await run(
      'capital_portfolio',
      () => CapitalPortfolioFirestoreSync.mergeFromCloud(
        widget.capitalStore,
        widget.portfolioStore,
      ),
    );
    if (!mounted) return;

    // Phase 2 — le reste en parallèle (n’empêche pas l’UI d’être utilisable).
    final layoutStore = _dashboardHomeLayoutOrCreate();
    await layoutStore.load();
    if (!mounted) return;
    await Future.wait<void>([
      run(
        'trading_week',
        () => TradingWeekFirestoreSync.mergeFromCloud(_tradingWeek),
      ),
      run(
        'dashboard_home_layout',
        () => DashboardHomeLayoutFirestoreSync.mergeFromCloud(layoutStore),
      ),
      run(
        'mental_state',
        () => MentalStateFirestoreSync.mergeFromCloud(
          MentalStateController.instance,
        ),
      ),
      run('strategie', StrategieFirestoreSync.mergeFromCloud),
      run('analyse', AnalyseFirestoreSync.mergeFromCloud),
      run('checklist', ChecklistFirestoreSync.mergeFromCloud),
    ]);
    if (mounted) ChecklistRealtimeNotifier.bump();
  }

  Future<void> _reloadLocalStoresForAccount({
    String? previousFirebaseUid,
  }) async {
    AjouterTradeCustomActifsStorage.resetForAccountChange();
    final prev = previousFirebaseUid?.trim();
    if (prev != null && prev.isNotEmpty) {
      try {
        await TradeJournalStorage.save(
          List<TradeListItem>.from(widget.tradeJournalStore.items),
          firebaseUidOverride: prev,
        );
      } catch (e, st) {
        debugPrint('[Paychek] trade journal save before account switch: $e\n$st');
      }
    }
    widget.tradeJournalStore.clear();
    _stopRealtimeSync();
    _capitalPortfolioCloudPushDebounce?.cancel();
    _capitalPortfolioCloudPushDebounce = null;
    _tradingWeekCloudPushDebounce?.cancel();
    _tradingWeekCloudPushDebounce = null;
    _dashboardLayoutCloudPushDebounce?.cancel();
    _dashboardLayoutCloudPushDebounce = null;
    _mentalStateCloudPushDebounce?.cancel();
    _mentalStateCloudPushDebounce = null;
    _strategieCloudPushDebounce?.cancel();
    _strategieCloudPushDebounce = null;
    try {
      await PaychekFirestorePushGuard.runSuppressed(() async {
        StrategieSetupsStore.resetForAccountChange();
        StrategieSetupUsageStore.resetForAccountChange();
        await widget.capitalStore.load();
        await widget.portfolioStore.load(seedCapital: widget.capitalStore);
        final profileUser = FirebaseAuth.instance.currentUser;
        if (profileUser != null) {
          final layout = _dashboardHomeLayoutOrCreate();
          await layout.load();
          try {
            await Future.wait<void>([
              CapitalPortfolioFirestoreSync.mergeFromCloud(
                widget.capitalStore,
                widget.portfolioStore,
              ),
              ChecklistFirestoreSync.mergeFromCloud(),
              AnalyseFirestoreSync.mergeFromCloud(),
              StrategieFirestoreSync.mergeFromCloud(),
              TradingWeekFirestoreSync.mergeFromCloud(_tradingWeek),
              DashboardHomeLayoutFirestoreSync.mergeFromCloud(layout),
              MentalStateFirestoreSync.mergeFromCloud(
                MentalStateController.instance,
              ),
            ]);
          } catch (e, st) {
            debugPrint('[Paychek] cloud merge on account switch: $e\n$st');
          }
          try {
            await paychekMergeProfileFromFirestore(profileUser);
          } catch (e, st) {
            debugPrint('[Paychek] profile merge after account switch: $e\n$st');
          }
        }
        await widget.userProfileStore.load();
        MentalStateController.instance.resetToFactoryDefaults();
        await MentalStateController.instance.loadSharePreferences();
      });
    } catch (e, st) {
      debugPrint('[Paychek] reload local stores failed: $e\n$st');
    }
    final langUser = FirebaseAuth.instance.currentUser;
    if (langUser != null) {
      try {
        await paychekMergeAppLanguageFromFirestore(langUser);
      } catch (e, st) {
        debugPrint('[Paychek] app language merge after account switch: $e\n$st');
      }
    }
    await _locale.load();
    await _hydrateTradeJournalFromPrefs();
    _startRealtimeSyncIfSignedIn();
    if (FirebaseAuth.instance.currentUser != null) {
      AnalyseRealtimeNotifier.bumpReports();
      AnalyseRealtimeNotifier.bump();
      ChecklistRealtimeNotifier.bump();
      StrategieRealtimeNotifier.bump();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_pullSyncDataFromCloudOnResume());
    }
  }

  /// Re-ouverture de l’app : tirer le cloud **avant** tout push local (évite d’écraser le web).
  Future<void> _pullSyncDataFromCloudOnResume() async {
    if (FirebaseAuth.instance.currentUser == null || !mounted) return;
    _capitalPortfolioCloudPushDebounce?.cancel();
    _strategieCloudPushDebounce?.cancel();
    await PaychekFirestorePushGuard.runCloudHydration(() async {
      await Future.wait<void>([
        CapitalPortfolioFirestoreSync.mergeFromCloud(
          widget.capitalStore,
          widget.portfolioStore,
        ),
        ChecklistFirestoreSync.mergeFromCloud(),
        AnalyseFirestoreSync.mergeFromCloud(),
        StrategieFirestoreSync.mergeFromCloud(),
      ]);
      if (mounted) {
        ChecklistRealtimeNotifier.bump();
        AnalyseRealtimeNotifier.bumpReports();
        AnalyseRealtimeNotifier.bump();
        StrategieRealtimeNotifier.bump();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.capitalStore.removeListener(_scheduleCapitalPortfolioCloudPush);
    widget.portfolioStore.removeListener(_scheduleCapitalPortfolioCloudPush);
    _capitalPortfolioCloudPushDebounce?.cancel();
    _tradingWeek.removeListener(_scheduleTradingWeekCloudPush);
    _tradingWeekCloudPushDebounce?.cancel();
    _dashboardLayoutCloudPushDebounce?.cancel();
    _mentalStateCloudPushDebounce?.cancel();
    _strategieCloudPushDebounce?.cancel();
    _stopRealtimeSync();
    _authSub?.cancel();
    MentalStateController.instance.removeListener(_scheduleMentalStateCloudPush);
    StrategieSetupsStore.notifier.removeListener(_scheduleStrategieCloudPush);
    StrategieSetupUsageStore.notifier.removeListener(_scheduleStrategieCloudPush);
    _dashboardHomeLayoutStore?.removeListener(_scheduleDashboardLayoutCloudPush);
    _dashboardHomeLayoutStore?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      // Keep debug paint overlays disabled even if they get toggled in DevTools.
      debugPaintBaselinesEnabled = false;
      return true;
    }());
    final localeCtrl = _locale;
    return AppLocaleScope(
      controller: localeCtrl,
      child: TradingWeekScope(
        controller: _tradingWeek,
        child: UserCapitalScope(
          store: widget.capitalStore,
          child: UserPortfolioScope(
            store: widget.portfolioStore,
            child: UserProfileScope(
              store: widget.userProfileStore,
              child: TradeJournalScope(
                store: widget.tradeJournalStore,
              child: ListenableBuilder(
                listenable: localeCtrl,
                builder: (context, _) {
                  return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  navigatorObservers: [
                    if (Firebase.apps.isNotEmpty && _firebaseAnalyticsHostAvailable)
                      FirebaseAnalyticsObserver(
                        analytics: FirebaseAnalytics.instance,
                      ),
                  ],
                  locale: localeCtrl.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  theme: ThemeData(
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Colors.black,
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF1EB48A),
                      surface: Colors.black,
                    ),
                    filledButtonTheme: FilledButtonThemeData(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1EB48A),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  builder: (context, child) {
                    return DashboardHomeLayoutScope(
                      store: _dashboardHomeLayoutOrCreate(),
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                  home: kIsWeb ? const WebAuthGate() : const MobileRootGate(),
                  routes: {
                    '/questionnaire': (context) => const QuestionnaireFlow(),
                  },
                  );
                },
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}



