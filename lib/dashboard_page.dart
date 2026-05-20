import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async' show Timer, StreamSubscription, unawaited;

import 'analyse/analyse_page.dart';
import 'analyse/analyse_report_snapshot.dart';
import 'analyse/analyse_report_snapshot_codec.dart';
import 'analyse/analyse_reports_storage.dart';
import 'analyse/analyse_starred_report_storage.dart';
import 'analyse/analyse_default_demo_seed.dart';
import 'analyse/analyse_realtime_notifier.dart';
import 'strategie/strategie_realtime_notifier.dart';
import 'checklist/checklist_page_controller.dart';
import 'checklist/checklist_page.dart';
import 'checklist/checklist_realtime_notifier.dart';
import 'etat_mental/mental_state_controller.dart';
import 'etat_mental/mental_state_page.dart';
import 'calculatrice/calculatrice_page.dart';
import 'dashboard/dashboard_home_content.dart';
import 'dashboard/dashboard_home_plan_logic.dart';
import 'dashboard/dashboard_main_bottom_nav.dart';
import 'dashboard/widgets/plus_menu_popup.dart';
import 'dashboard/dashboard_tokens.dart';
import 'web/plus_menu_actions.dart';
import 'web/paychek_web_tokens.dart';
import 'web/plus_web_left_rail.dart';
import 'web/web_dashboard_body.dart';
import 'web/web_dashboard_config.dart';
import 'shared/paychek_frame_callbacks.dart';
import 'ajouter_trade/ajouter_trade_page.dart';
import 'calendrier/calendrier_page.dart';
import 'help_center/help_center_page.dart';
import 'l10n/app_localizations.dart';
import 'onboarding_language_page.dart';
import 'reglage/paychek_remote_access.dart';
import 'strategie/strategie_page.dart';
import 'trade/trade_page.dart';
import 'strategie/strategie_setups_store.dart';
import 'strategie/strategie_starred_setup_storage.dart';
import 'strategie/widgets/strategie_setup_card.dart';
import 'trade/trade_models.dart';
import 'performance/performance_page.dart';
import 'reglage/reglage_dashboard_layout_page.dart';
import 'reglage/reglage_page.dart';
import 'reglage/reglage_cgv_terms_page.dart';
import 'reglage/reglage_privacy_policy_page.dart';
import 'reglage/support_feedback_page.dart';
import 'reglage/stripe_entitlement_sync.dart';
import 'reglage/trial_access_prefs.dart'
    show
        AccountEntitlementSnapshot,
        TrialAccessPrefs,
        TrialGateVm,
        kPaychekSubscriberEntitlementsCollection;
import 'reglage/trial_paywall_overlay.dart';
import 'reglage/lite_freemium_page_lock.dart';
import 'reglage/paychek_gold_upgrade_sheet.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  static const int _overlayNone = 0;
  static const int _overlayMental = 1;
  static const int _overlayStrategie = 2;
  static const int _overlayAnalyse = 3;
  static const int _overlayPerformance = 4;
  static const int _overlayChecklist = 5;
  static const int _overlayCalculatrice = 6;
  static const int _overlayHelpCenter = 7;
  static const int _overlayCgv = 8;
  static const int _overlayPrivacyPolicy = 9;
  static const int _overlaySupportFeedback = 10;

  /// 0 Dashboard, 1 Trade, 2 Ajouter, 3 Calendrier.
  int _bodyIndex = 0;
  int _overlayPage = _overlayNone;

  /// Petit menu Plus (widget en bas à droite, pas une page).
  bool _plusMenuOpen = false;

  /// Réglages au-dessus du contenu, barre du bas toujours visible.
  bool _reglageOverlayOpen = false;

  /// Null pendant le tout premier calcul ; après : règles d’accès Pro / Lite / essai.
  TrialGateVm? _trialGate;

  /// Statut Pro / Lite pour l’accueil (pastille à côté du nom).
  AccountEntitlementSnapshot? _accountEntitlement;

  /// Partagé avec [AjouterTradePage] pour fermer les overlays hors arbre (focus cohérent).
  /// Initialisation paresseuse : après hot reload, un [State] ancien peut avoir ce champ à null sur le web.
  ValueNotifier<int>? _shellBodyIndexNotifier;

  ValueNotifier<int> get _shellBodyIndex {
    _shellBodyIndexNotifier ??= ValueNotifier<int>(_bodyIndex);
    return _shellBodyIndexNotifier!;
  }
  final GlobalKey<State<AjouterTradePage>> _ajouterTabKey =
      GlobalKey<State<AjouterTradePage>>();
  final ChecklistPageController _checklistController =
      ChecklistPageController();
  final ValueNotifier<TradeListItem?> _editTrade = ValueNotifier<TradeListItem?>(
    null,
  );
  final ValueNotifier<String?> _openTradeIdNotifier = ValueNotifier<String?>(null);
  /// Aperçu accueil : rapport épinglé → sinon 1er rapport stocké → sinon `null` (titre seul).
  AnalyseReportSnapshot? _analyseHomePreview;

  /// Aperçu accueil : setup épinglé → sinon 1er setup → sinon `null` (titre seul).
  StrategieSetupCardData? _strategieHomeSetup;

  bool _remotePaychekAccessValidated = false;

  /// Compte connecté, après les 7 j d’essai sans Pro : **Lite** (dashboard + calendrier consultables ;
  /// saisie trade sans CSV / screenshot / discipline avancée).
  bool get _liteRestricted {
    final g = _trialGate;
    if (g == null || !g.liteFreemiumRestricted) return false;
    return FirebaseAuth.instance.currentUser != null;
  }

  PlusMenuLiteGate? get _plusMenuLiteGate {
    if (!_liteRestricted) return null;
    return (VoidCallback action, {required bool allowedInLite}) {
      if (!allowedInLite) {
        if (_plusMenuOpen) {
          setState(() => _plusMenuOpen = false);
        }
        _showLitePaywallSheet();
        return;
      }
      action();
    };
  }

  void _showVoluntaryGoldUpgradeSheet() {
    if (!mounted) return;
    unawaited(showPaychekGoldUpgradeSheet(context: context));
  }

  void _showLitePaywallSheet() {
    final anchor = _trialGate?.anchorUtc;
    if (anchor == null || !mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetCtx).bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.88,
              child: TrialPaywallOverlay(
                trialAnchorUtc: anchor,
                displayTrialEndUtc: _trialGate?.effectiveFullAccessEndUtc ??
                    TrialAccessPrefs.trialEndUtc(anchor),
                onDismissLite: () => Navigator.pop(sheetCtx),
                onReloadTrialGate: () async {
                  final stillLite = await _reloadTrialGate();
                  if (!sheetCtx.mounted) return stillLite;
                  if (!stillLite) Navigator.pop(sheetCtx);
                  return stillLite;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _applyMobileSystemChrome();
    WidgetsBinding.instance.addObserver(this);
    AnalyseRealtimeNotifier.tick.addListener(_reloadAnalyseHomePreview);
    AnalyseRealtimeNotifier.reportsTick.addListener(_reloadAnalyseHomePreview);
    PaychekFrameCallbacks.runPostFrame(() {
      _checklistController.hydrateFromStorage();
      _checkPaychekRemoteAccessGate();
    });
    _reloadAnalyseHomePreview();
    _reloadStrategieHomePreview();
    StrategieRealtimeNotifier.tick.addListener(_reloadStrategieHomePreview);
    ChecklistRealtimeNotifier.tick.addListener(_onChecklistCloudTick);
    TrialAccessPrefs.loadGateStateAndAccountEntitlement().then((pair) {
      if (!mounted) return;
      setState(() {
        _trialGate = pair.gate;
        _accountEntitlement = pair.entitlement;
        if (pair.gate.liteFreemiumRestricted &&
            FirebaseAuth.instance.currentUser != null &&
            _bodyIndex == 1) {
          _bodyIndex = 2;
          _shellBodyIndexNotifier?.value = 2;
        }
      });
    });
    _bindSubscriberEntitlementListener();
  }

  void _applyMobileSystemChrome() {
    if (kIsWeb) return;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: DashboardTokens.scaffoldMatte,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _subscriberEntitlementSub;
  Timer? _entitlementReloadDebounce;

  void _bindSubscriberEntitlementListener() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    unawaited(_subscriberEntitlementSub?.cancel());
    _subscriberEntitlementSub = FirebaseFirestore.instance
        .collection(kPaychekSubscriberEntitlementsCollection)
        .doc(u.uid)
        .snapshots()
        .listen((_) => _scheduleTrialGateReloadFromEntitlement());
  }

  void _scheduleTrialGateReloadFromEntitlement() {
    if (!mounted) return;
    _entitlementReloadDebounce?.cancel();
    _entitlementReloadDebounce = Timer(const Duration(milliseconds: 450), () {
      _entitlementReloadDebounce = null;
      if (!mounted) return;
      unawaited(_reloadTrialGate());
    });
  }

  Future<void> _syncStripeEntitlementAndReloadGate() async {
    await PaychekStripeEntitlementSync.syncFromStripe(maxAttempts: 2);
    await _reloadTrialGate();
  }

  void _onChecklistCloudTick() {
    if (_checklistController.isEditingChecklist) return;
    unawaited(_checklistController.reloadFromStorage());
  }

  Future<void> _checkPaychekRemoteAccessGate() async {
    if (_remotePaychekAccessValidated) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final block = await evaluatePaychekRemoteAccess(user);
    if (!mounted) return;
    _remotePaychekAccessValidated = true;
    if (block == null) return;

    final l10n = AppLocalizations.of(context)!;
    final body = switch (block) {
      PaychekRemoteAccessBlock.webDisabled => l10n.paychekAccessDeniedWeb,
      PaychekRemoteAccessBlock.mobileDisabled => l10n.paychekAccessDeniedMobile,
    };

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.paychekAccessDeniedTitle),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.settingsLogoutButton),
          ),
        ],
      ),
    );

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const OnboardingLanguagePage(),
      ),
      (_) => false,
    );
  }

  Future<bool> _reloadTrialGate() async {
    final pair = await TrialAccessPrefs.loadGateStateAndAccountEntitlement();
    if (!mounted) return true;
    final vm = pair.gate;
    final acc = pair.entitlement;
    setState(() {
      _trialGate = vm;
      _accountEntitlement = acc;
      if (vm.liteFreemiumRestricted &&
          FirebaseAuth.instance.currentUser != null &&
          (_bodyIndex == 0 || _bodyIndex == 1)) {
        _bodyIndex = 2;
        _shellBodyIndexNotifier?.value = 2;
      }
    });
    return vm.liteFreemiumRestricted;
  }

  Future<void> _reloadStrategieHomePreview() async {
    final starred = await StrategieStarredSetupStorage.load();
    if (!mounted) return;
    if (starred != null) {
      setState(() => _strategieHomeSetup = starred);
      return;
    }
    await StrategieSetupsStore.ensureLoaded();
    if (!mounted) return;
    final list = StrategieSetupsStore.notifier.value;
    setState(() {
      _strategieHomeSetup = list.isNotEmpty ? list.first : null;
    });
  }

  Future<void> _reloadAnalyseHomePreview() async {
    final starred = await AnalyseStarredReportStorage.load();
    final stored = await AnalyseReportsStorage.loadAll();
    if (!mounted) return;

    // 1) Rapport étoilé : priorité sur le dashboard.
    if (starred != null) {
      final inList = stored.any(
        (s) => analyseSnapshotsEqualForStar(s, starred),
      );
      // Liste vide = démos non encore persistés ou course disque ; garder l’étoile.
      if (stored.isEmpty || inList) {
        setState(() => _analyseHomePreview = starred);
        return;
      }
      // Étoile pointant vers un rapport supprimé.
      unawaited(AnalyseStarredReportStorage.clear());
    }

    // 2) Sans étoile : rapport stocké (GOLD / XAU en priorité si présent).
    final fromStorage = pickStoredAnalyseReportDefaultPreferGold(stored);
    if (fromStorage != null) {
      setState(() => _analyseHomePreview = fromStorage);
      return;
    }

    // 3) Nouveau compte : même aperçu démo que la page Analyse (GOLD H4).
    final locale = mounted
        ? Localizations.localeOf(context)
        : WidgetsBinding.instance.platformDispatcher.locale;
    setState(
      () => _analyseHomePreview =
          buildAnalyseDashboardPreviewSnapshot(locale: locale),
    );
  }

  @override
  void dispose() {
    _entitlementReloadDebounce?.cancel();
    unawaited(_subscriberEntitlementSub?.cancel());
    WidgetsBinding.instance.removeObserver(this);
    AnalyseRealtimeNotifier.tick.removeListener(_reloadAnalyseHomePreview);
    AnalyseRealtimeNotifier.reportsTick
        .removeListener(_reloadAnalyseHomePreview);
    StrategieRealtimeNotifier.tick.removeListener(_reloadStrategieHomePreview);
    ChecklistRealtimeNotifier.tick.removeListener(_onChecklistCloudTick);
    _shellBodyIndexNotifier?.dispose();
    _checklistController.dispose();
    _editTrade.dispose();
    _openTradeIdNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      MentalStateController.instance.onAppForegroundForCalendar();
      unawaited(_syncStripeEntitlementAndReloadGate());
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 4 && WebDashboardConfig.useLeftRail) {
      return;
    }
    if (_liteRestricted && index == 1) {
      _showLitePaywallSheet();
      return;
    }

    if (index == 4) {
      final openingPlus = !_plusMenuOpen;
      final closedOverlay = _overlayPage;
      setState(() {
        _plusMenuOpen = openingPlus;
        // Ouvrir le menu Plus : retirer Réglages pour que la barre reste utilisable.
        if (openingPlus) {
          _reglageOverlayOpen = false;
          _overlayPage = _overlayNone;
        }
      });
      if (openingPlus) {
        _handleOverlayClosed(closedOverlay);
      }
      return;
    }

    final closedOverlay = _overlayPage;
    if (_plusMenuOpen || _reglageOverlayOpen || _overlayPage != _overlayNone) {
      setState(() {
        _plusMenuOpen = false;
        _reglageOverlayOpen = false;
        _overlayPage = _overlayNone;
      });
    }
    _handleOverlayClosed(closedOverlay);
    _applyTabIndex(index);
  }

  void _closePlusMenu() {
    if (_plusMenuOpen) {
      setState(() => _plusMenuOpen = false);
    }
  }

  void _applyTabIndex(int index) {
    assert(index >= 0 && index <= 3, 'index');
    if (_bodyIndex == index) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (_bodyIndex == 2 && index != 2) {
      AjouterTradePage.resetDraft(_ajouterTabKey);
    }
    setState(() => _bodyIndex = index);
    _shellBodyIndex.value = index;
  }

  void _openOverlayPage(int overlayPage) {
    setState(() {
      _plusMenuOpen = false;
      _reglageOverlayOpen = false;
      _overlayPage = overlayPage;
    });
  }

  void _handleOverlayClosed(int overlayPage) {
    if (overlayPage == _overlayStrategie) {
      _reloadStrategieHomePreview();
    } else if (overlayPage == _overlayAnalyse) {
      _reloadAnalyseHomePreview();
    }
  }

  void _openChecklistFromHome() => _openOverlayPage(_overlayChecklist);

  void _openEtatMentalFromHome() => _openOverlayPage(_overlayMental);

  void _openStrategieFromHome() => _openOverlayPage(_overlayStrategie);

  void _openAnalyseFromHome() => _openOverlayPage(_overlayAnalyse);

  /// Pages Pro en Lite : visibles mais grisées ; interaction → paywall.
  Widget _wrapLiteProOverlayPage(Widget page) {
    if (!_liteRestricted) return page;
    return LiteFreemiumPageLock(
      onLockedInteraction: _showLitePaywallSheet,
      child: page,
    );
  }

  List<Widget> _dashboardTabChildren() {
    return [
      ExcludeFocus(
        excluding: _bodyIndex != 0,
        child: DashboardHomeContent(
          key: const ValueKey<String>('tab_home'),
          checklistController: _checklistController,
          analysePreviewSnapshot: _analyseHomePreview,
          strategiePreviewSetup: _strategieHomeSetup,
          accountPlanIsPro: _accountEntitlement?.isPro,
          liteFreemiumRestricted: _liteRestricted,
          onLiteFreemiumRestrictedTap: _showLitePaywallSheet,
          onHomeUpgradeTap: DashboardHomePlanLogic.resolveHomeUpgradeTap(
            currentUser: FirebaseAuth.instance.currentUser,
            entitlement: _accountEntitlement,
            onVoluntaryGoldUpgrade: _showVoluntaryGoldUpgradeSheet,
          ),
          onOpenChecklist: _openChecklistFromHome,
          onOpenAnalyse: _openAnalyseFromHome,
          onOpenEtatMental: _openEtatMentalFromHome,
          onOpenStrategie: _openStrategieFromHome,
          onOpenTrade: () {
            if (_liteRestricted) {
              _showLitePaywallSheet();
              return;
            }
            _applyTabIndex(1);
          },
          onOpenTradeById: (id) {
            if (_liteRestricted) {
              _showLitePaywallSheet();
              return;
            }
            _openTradeIdNotifier.value = id;
            _applyTabIndex(1);
          },
        ),
      ),
      ExcludeFocus(
        excluding: _bodyIndex != 1,
        child: TradePage(
          key: const ValueKey<String>('tab_trade'),
          checklistController: _checklistController,
          openTradeIdNotifier: _openTradeIdNotifier,
          onNavigateToDashboard: () => _applyTabIndex(0),
          onEditTrade: (t) {
            if (_liteRestricted) {
              _showLitePaywallSheet();
              return;
            }
            _editTrade.value = t;
            _applyTabIndex(2);
          },
        ),
      ),
      ExcludeFocus(
        excluding: _bodyIndex != 2,
        child: AjouterTradePage(
          key: _ajouterTabKey,
          checklistController: _checklistController,
          shellBodyIndex: _shellBodyIndex,
          accountEntitlement: _accountEntitlement,
          liteFreemiumRestricted: _liteRestricted,
          onLiteFreemiumRestrictedTap:
              _liteRestricted ? _showLitePaywallSheet : null,
          onBack: () {
            if (_liteRestricted) {
              _applyTabIndex(3);
            } else {
              _applyTabIndex(0);
            }
          },
          onNavigateToTrade: () {
            if (_liteRestricted) {
              _showLitePaywallSheet();
              return;
            }
            _applyTabIndex(1);
          },
          editTrade: _editTrade,
        ),
      ),
      ExcludeFocus(
        excluding: _bodyIndex != 3,
        child: CalendrierPage(
          key: const ValueKey<String>('tab_cal'),
          liteFreemiumRestricted: _liteRestricted,
          onLiteFreemiumRestrictedTap:
              _liteRestricted ? _showLitePaywallSheet : null,
          onNavigateToDashboard: () => _applyTabIndex(0),
          onNavigateToTrade: (trade) {
            if (_liteRestricted) {
              _showLitePaywallSheet();
              return;
            }
            _openTradeIdNotifier.value = trade.id;
            _applyTabIndex(1);
          },
          onAddTrade: () => _applyTabIndex(2),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    final primaryTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      base.primaryTextTheme,
    );

    return Theme(
      data: base.copyWith(
        textTheme: textTheme,
        primaryTextTheme: primaryTextTheme,
        scaffoldBackgroundColor: WebDashboardConfig.useLeftRail
            ? PaychekWebTokens.scaffoldBg
            : DashboardTokens.scaffoldMatte,
        canvasColor: WebDashboardConfig.useLeftRail
            ? PaychekWebTokens.scaffoldBg
            : DashboardTokens.scaffoldMatte,
        colorScheme: WebDashboardConfig.useLeftRail
            ? base.colorScheme.copyWith(
                primary: PaychekWebTokens.accentMint,
                surface: PaychekWebTokens.scaffoldBg,
              )
            : base.colorScheme,
      ),
      child: Builder(
        builder: (context) {
          final mq = MediaQuery.of(context);
          final bottomInset = mq.padding.bottom;
          final useWebRail = WebDashboardConfig.useLeftRail;
          // Mobile : barre du bas fixe. Web : navigation uniquement dans le rail gauche — pas de doublon en bas.
          final navTotal = useWebRail
              ? bottomInset
              : DashboardMainBottomNav.totalHeight(bottomInset);
          final overlayLeftInset = WebDashboardConfig.overlayLeftInsetPx;

          void closePlus() => _closePlusMenu();

          return PopScope(
            canPop: !_reglageOverlayOpen && _overlayPage == _overlayNone,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop && _reglageOverlayOpen) {
                setState(() => _reglageOverlayOpen = false);
              } else if (!didPop && _overlayPage != _overlayNone) {
                final closedOverlay = _overlayPage;
                setState(() => _overlayPage = _overlayNone);
                _handleOverlayClosed(closedOverlay);
              }
            },
            child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Scaffold(
                backgroundColor: DashboardTokens.scaffoldMatte,
                extendBody: true,
                resizeToAvoidBottomInset: !useWebRail ? false : true,
                body: WebDashboardBody(
                  useWebRail: useWebRail,
                  navTotal: navTotal,
                  bodyIndex: _bodyIndex,
                  tabChildren: _dashboardTabChildren(),
                  leftRail: PlusWebLeftRail(
                    activeMainTabIndex: _bodyIndex,
                    showMainTabSelection: !_reglageOverlayOpen &&
                        _overlayPage == _overlayNone,
                    onOpenAjouterTrade: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _onBottomNavTap(2);
                      });
                    },
                    onOpenMainTab: (i) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _onBottomNavTap(i);
                      });
                    },
                    onOpenMental: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _openOverlayPage(_overlayMental);
                      });
                    },
                    onOpenStrategie: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _openOverlayPage(_overlayStrategie);
                      });
                    },
                    onOpenAnalyse: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _openOverlayPage(_overlayAnalyse);
                      });
                    },
                    onOpenPerformance: () =>
                        _openOverlayPage(_overlayPerformance),
                    onOpenChecklist: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _openOverlayPage(_overlayChecklist);
                      });
                    },
                    onOpenCalculatrice: () =>
                        _openOverlayPage(_overlayCalculatrice),
                    onOpenHelpCenter: () =>
                        _openOverlayPage(_overlayHelpCenter),
                    onOpenSupportFeedback: () =>
                        _openOverlayPage(_overlaySupportFeedback),
                    onOpenReglage: () {
                      final closedOverlay = _overlayPage;
                      setState(() {
                        _overlayPage = _overlayNone;
                        _reglageOverlayOpen = true;
                      });
                      _handleOverlayClosed(closedOverlay);
                    },
                    liteGate: _plusMenuLiteGate,
                  ),
                ),
              ),
              if (_reglageOverlayOpen)
                Positioned(
                  left: overlayLeftInset,
                  right: 0,
                  top: 0,
                  bottom: navTotal,
                  child: ReglagePage(
                    onClose: () {
                      setState(() => _reglageOverlayOpen = false);
                      unawaited(_reloadTrialGate());
                    },
                    onGoToDashboard: () {
                      setState(() {
                        _reglageOverlayOpen = false;
                        _applyTabIndex(0);
                      });
                    },
                    onOpenHelpCenter: useWebRail
                        ? null
                        : () => setState(() {
                              _reglageOverlayOpen = false;
                              _overlayPage = _overlayHelpCenter;
                            }),
                    onOpenCgvTerms: useWebRail
                        ? null
                        : () => setState(() {
                              _reglageOverlayOpen = false;
                              _overlayPage = _overlayCgv;
                            }),
                    onOpenPrivacyPolicy: useWebRail
                        ? null
                        : () => setState(() {
                              _reglageOverlayOpen = false;
                              _overlayPage = _overlayPrivacyPolicy;
                            }),
                    onOpenDashboardLayout: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => ReglageDashboardLayoutPage(
                            onOpenHomeTab: () {
                              setState(() {
                                _reglageOverlayOpen = false;
                                _applyTabIndex(0);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (_plusMenuOpen && !useWebRail) ...[
                Positioned(
                  left: overlayLeftInset,
                  right: 0,
                  top: 0,
                  bottom: navTotal,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _closePlusMenu,
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.60),
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: navTotal + 4,
                  child: PlusMenuPopup(
                    onOpenMainTab: (i) {
                      closePlus();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _onBottomNavTap(i);
                      });
                    },
                    onOpenMental: () {
                      closePlus();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _openOverlayPage(_overlayMental);
                      });
                    },
                    onOpenStrategie: () {
                      closePlus();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _openOverlayPage(_overlayStrategie);
                      });
                    },
                    onOpenAnalyse: () {
                      closePlus();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _openOverlayPage(_overlayAnalyse);
                      });
                    },
                    onOpenPerformance: () => _openOverlayPage(_overlayPerformance),
                    onOpenChecklist: () {
                      closePlus();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _openOverlayPage(_overlayChecklist);
                      });
                    },
                    onOpenCalculatrice: () =>
                        _openOverlayPage(_overlayCalculatrice),
                    onOpenReglage: () {
                      closePlus();
                      final closedOverlay = _overlayPage;
                      setState(() {
                        _overlayPage = _overlayNone;
                        _reglageOverlayOpen = true;
                      });
                      _handleOverlayClosed(closedOverlay);
                    },
                    liteGate: _plusMenuLiteGate,
                  ),
                ),
              ],
              if (_overlayPage != _overlayNone)
                Positioned(
                  left: overlayLeftInset,
                  right: 0,
                  top: 0,
                  bottom: navTotal,
                  child: switch (_overlayPage) {
                    _overlayMental => _wrapLiteProOverlayPage(
                        MentalStatePage(
                          onCloseAsTab: () => setState(
                            () => _overlayPage = _overlayNone,
                          ),
                        ),
                      ),
                    _overlayStrategie => _wrapLiteProOverlayPage(
                        StrategiePage(
                          liteFreemiumRestricted: _liteRestricted,
                          onLiteFreemiumRestrictedTap:
                              _liteRestricted ? _showLitePaywallSheet : null,
                          onCloseAsTab: () {
                            setState(() => _overlayPage = _overlayNone);
                            _reloadStrategieHomePreview();
                          },
                        ),
                      ),
                    _overlayAnalyse => _wrapLiteProOverlayPage(
                        AnalysePage(
                          initialScrollToReports: true,
                          revealSnapshot: _analyseHomePreview,
                          onCloseAsTab: () {
                            setState(() => _overlayPage = _overlayNone);
                            _reloadAnalyseHomePreview();
                          },
                        ),
                      ),
                    _overlayPerformance => PerformancePage(
                        liteFreemiumRestricted: _liteRestricted,
                        onLiteFreemiumRestrictedTap:
                            _liteRestricted ? _showLitePaywallSheet : null,
                        onCloseAsTab: () =>
                            setState(() => _overlayPage = _overlayNone),
                      ),
                    _overlayChecklist => _wrapLiteProOverlayPage(
                        ChecklistPage(
                          controller: _checklistController,
                          liteFreemiumRestricted: _liteRestricted,
                          onLiteFreemiumRestrictedTap:
                              _liteRestricted ? _showLitePaywallSheet : null,
                          onBack: () => setState(
                            () => _overlayPage = _overlayNone,
                          ),
                        ),
                      ),
                    _overlayCalculatrice => _wrapLiteProOverlayPage(
                        CalculatricePage(
                          onCloseAsTab: () =>
                              setState(() => _overlayPage = _overlayNone),
                        ),
                      ),
                    _overlayHelpCenter => HelpCenterPage(
                        onCloseInShell: () {
                          if (!mounted) return;
                          setState(() => _overlayPage = _overlayNone);
                        },
                      ),
                    _overlaySupportFeedback => SupportFeedbackPage(
                        onCloseInShell: () {
                          if (!mounted) return;
                          setState(() => _overlayPage = _overlayNone);
                        },
                        onOpenHelpCenterInShell: () {
                          if (!mounted) return;
                          setState(() =>
                              _overlayPage = _overlayHelpCenter);
                        },
                      ),
                    _overlayCgv => ReglageCgvTermsPage(
                        onCloseInShell: () {
                          if (!mounted) return;
                          setState(() => _overlayPage = _overlayNone);
                        },
                      ),
                    _overlayPrivacyPolicy => ReglagePrivacyPolicyPage(
                        onCloseInShell: () {
                          if (!mounted) return;
                          setState(() => _overlayPage = _overlayNone);
                        },
                      ),
                    _ => const SizedBox.shrink(),
                  },
                ),
              if (!useWebRail)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DashboardMainBottomNav(
                    currentIndex:
                        _plusMenuOpen ? 4 : _bodyIndex,
                    onDestination: (i) => _onBottomNavTap(i),
                    showPlusTab: true,
                  ),
                ),
            ],
          ),
          );
        },
      ),
    );
  }
}
