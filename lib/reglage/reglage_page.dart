import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_home_layout_scope.dart';
import '../dashboard/widgets/paychek_plan_minimal_badge.dart';
import '../dashboard/dashboard_home_layout_store.dart';
import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../questionnaire/user_capital_scope.dart';
import '../questionnaire/user_capital_store.dart';
import '../trade/trade_journal_scope.dart';
import '../trade/trade_journal_store.dart';
import '../help_center/help_center_page.dart';
import '../web/paychek_web_tokens.dart';
import '../widgets/paychek_page_header.dart';
import 'app_locale_scope.dart';
import 'trading_week_scope.dart';
import 'language_picker_shared.dart';
import 'reglage_language_prefs.dart';
import 'reglage_portfolio_sheet.dart';
import 'reglage_portfolios_manager_sheet.dart';
import 'user_portfolio_models.dart';
import 'user_portfolio_scope.dart';
import 'user_portfolio_store.dart';
import 'reglage_app_local_data_reset.dart';
import 'reglage_cgv_terms_page.dart';
import 'reglage_privacy_policy_page.dart';
import 'reglage_profile_connect_constants.dart'
    show kReglageAuthSuccessPopResult, kReglageProfileLogoutPopResult;
import 'account_logout.dart';
import 'reglage_profile_prefs.dart';
import 'reglage_profile_view_page.dart';
import 'support_feedback_page.dart';
import 'trial_access_prefs.dart';
import 'user_profile_scope.dart';
import 'user_profile_store.dart';

part 'reglage_page_tokens.dart';
part 'reglage_page_profile_section.dart';
part 'reglage_page_trading_section.dart';
part 'reglage_page_cgv_data_reset.dart';
part 'reglage_page_language_week.dart';
part 'reglage_page_support_section.dart';

/// Colonne Réglages centrée sur le web (maquette shell).
const double _kWebReglageMaxWidth = 460;

/// Réglages — affiché en overlay au-dessus du shell (barre du bas inchangée).
class ReglagePage extends StatefulWidget {
  const ReglagePage({
    super.key,
    required this.onClose,
    this.onGoToDashboard,
    this.onOpenDashboardLayout,
    this.onOpenHelpCenter,
    this.onOpenCgvTerms,
    this.onOpenPrivacyPolicy,
  });

  final VoidCallback onClose;

  /// Ferme les réglages et affiche l’onglet Dashboard (accueil).
  final VoidCallback? onGoToDashboard;

  /// Ouvre l’écran de personnalisation des sections (prioritaire sur [onGoToDashboard] pour l’appui sur la carte).
  final VoidCallback? onOpenDashboardLayout;

  /// Ouvre le Help Center **dans le shell** (mobile uniquement).
  final VoidCallback? onOpenHelpCenter;

  /// Ouvre la page CGV **dans le shell** (mobile uniquement).
  final VoidCallback? onOpenCgvTerms;

  /// Ouvre la politique de confidentialité **dans le shell** (mobile uniquement).
  final VoidCallback? onOpenPrivacyPolicy;

  @override
  State<ReglagePage> createState() => _ReglagePageState();
}

class _ReglagePageState extends State<ReglagePage> {
  ReglageProfileData _profile = const ReglageProfileData(
    inscrit: false,
    prenom: '',
    nom: '',
    email: '',
  );
  AccountEntitlementSnapshot? _accountEntitlement;
  bool _webAccountOpen = false;
  bool _settingsLogoutBusy = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAccountEntitlement();
  }

  Future<void> _loadProfile() async {
    final data = await ReglageProfilePrefs.load();
    if (!mounted) return;
    setState(() => _profile = data);
    UserProfileScope.of(context).setProfile(data);
  }

  Future<void> _loadAccountEntitlement() async {
    final e = await TrialAccessPrefs.loadAccountEntitlement();
    if (!mounted) return;
    setState(() => _accountEntitlement = e);
  }

  void _presentAccountRoute() {
    if (kIsWeb) {
      setState(() => _webAccountOpen = true);
      return;
    }
    final route = MaterialPageRoute<void>(
      builder: (_) => ReglageProfileViewPage(
        profile: _profile,
        initialEntitlement: _accountEntitlement,
      ),
    );
    Navigator.of(context, rootNavigator: true).push<Object?>(route).then((
      result,
    ) {
      _loadProfile();
      _loadAccountEntitlement();
      if (!mounted) return;
      if (result == kReglageAuthSuccessPopResult) {
        // Après pop, évite le double Hero des SnackBars (surtout Web) si la transition
        // chevauche encore l’ancienne route.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final messenger = ScaffoldMessenger.maybeOf(context);
          messenger?.clearSnackBars();
          messenger?.showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.accountAuthLoginSuccess,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF2A2A2A),
            ),
          );
        });
      }
      if (result == kReglageProfileLogoutPopResult) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final messenger = ScaffoldMessenger.maybeOf(context);
          messenger?.clearSnackBars();
          messenger?.showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.settingsLogoutSnack,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF2A2A2A),
            ),
          );
        });
      }
    });
  }

  Future<void> _onSettingsLogout() async {
    setState(() => _settingsLogoutBusy = true);
    try {
      await applyLocalLogout(context);
      if (!mounted) return;
      if (kIsWeb && _webAccountOpen) {
        setState(() => _webAccountOpen = false);
      }
      await _loadProfile();
      await _loadAccountEntitlement();
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.clearSnackBars();
        messenger?.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.settingsLogoutSnack),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2A2A2A),
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _settingsLogoutBusy = false);
    }
  }

  Widget _settingsLogoutButton(AppLocalizations l10n, {required bool isWebUi}) {
    if (!_profile.inscrit) return const SizedBox.shrink();
    return OutlinedButton.icon(
      onPressed: _settingsLogoutBusy ? null : _onSettingsLogout,
      icon: Icon(
        Icons.logout_rounded,
        size: 20,
        color: _kSettingsLogoutRed,
      ),
      label: Text(
        l10n.settingsLogoutButton,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: isWebUi ? 16 : 15,
          color: _kSettingsLogoutRed,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _kSettingsLogoutRed,
        backgroundColor: const Color(0xFF141416),
        side: BorderSide(
          color: _kSettingsLogoutRed.withValues(alpha: 0.9),
        ),
        minimumSize: const Size(double.infinity, 52),
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: isWebUi ? 16 : 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = UserCapitalScope.of(context);
    final portfolioStore = UserPortfolioScope.of(context);
    final localeController = AppLocaleScope.of(context);
    final tradingWeek = TradingWeekScope.of(context);

    final isWebUi = kIsWeb;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor:
          isWebUi ? PaychekWebTokens.scaffoldBg : Colors.black,
      body: ListenableBuilder(
        listenable: Listenable.merge([store, portfolioStore]),
        builder: (context, _) {
          final l10n = AppLocalizations.of(context)!;
          final gap = isWebUi ? 12.0 : 16.0;
          final pagePad = EdgeInsets.fromLTRB(
            isWebUi ? 24 : 16,
            isWebUi ? 12 : 8,
            isWebUi ? 24 : 16,
            0,
          );

          if (isWebUi && _webAccountOpen) {
            return SafeArea(
              minimum: EdgeInsets.zero,
              child: Padding(
                padding: pagePad,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _kWebReglageMaxWidth,
                    ),
                    child: ReglageProfileViewPage(
                      profile: _profile,
                      embeddedInReglageOverlay: true,
                      initialEntitlement: _accountEntitlement,
                      onBack: () {
                        setState(() => _webAccountOpen = false);
                        _loadProfile();
                        _loadAccountEntitlement();
                      },
                    ),
                  ),
                ),
              ),
            );
          }

          final listChildren = <Widget>[
            _ProfileCard(
              profile: _profile,
              accountPlanIsPro: _accountEntitlement?.isPro,
              onTap: _presentAccountRoute,
            ),
            if (widget.onOpenDashboardLayout != null ||
                widget.onGoToDashboard != null) ...[
              SizedBox(height: gap),
              _DashboardShortcutCard(
                onTap: () {
                  if (widget.onOpenDashboardLayout != null) {
                    widget.onOpenDashboardLayout!();
                  } else {
                    widget.onGoToDashboard?.call();
                  }
                },
              ),
            ],
            SizedBox(height: gap),
            _TradingPrefsSection(
              capitalStore: store,
              portfolioStore: portfolioStore,
              onClose: widget.onClose,
            ),
            SizedBox(height: gap),
            _LanguageAndTradingWeekSection(
              tradingWeek: tradingWeek,
              localeController: localeController,
            ),
            SizedBox(height: gap),
            _SupportFeedbackReglageCard(
              onOpenHelpCenterInShell: widget.onOpenHelpCenter,
            ),
            SizedBox(height: gap),
            _HelpCenterReglageCard(
              onOpenHelpCenter: widget.onOpenHelpCenter,
            ),
            SizedBox(height: gap),
            _CgvSection(
              onOpenCgv: widget.onOpenCgvTerms,
              onOpenPrivacy: widget.onOpenPrivacyPolicy,
            ),
            SizedBox(height: gap),
            _DataResetSection(
              capitalStore: store,
              portfolioStore: portfolioStore,
              profileStore: UserProfileScope.of(context),
              journalStore: TradeJournalScope.of(context),
              layoutStore: DashboardHomeLayoutScope.of(context),
              localeController: localeController,
              tradingWeek: tradingWeek,
              onResetComplete: () {
                _loadProfile();
                _loadAccountEntitlement();
              },
            ),
            if (_profile.inscrit) ...[
              SizedBox(height: gap + 12),
              _settingsLogoutButton(l10n, isWebUi: isWebUi),
            ],
          ];

          final listView = ListView(
            padding: EdgeInsets.only(
              bottom: isWebUi ? 40 : 40,
              top: isWebUi ? 8 : 0,
            ),
            children: listChildren,
          );

          return SafeArea(
            minimum: EdgeInsets.zero,
            child: Padding(
              padding: pagePad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isWebUi)
                    PaychekPageHeader(
                      title: l10n.settingsTitle,
                      subtitle: '',
                      onBack: widget.onClose,
                      maxContentWidth: _kWebReglageMaxWidth,
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: widget.onClose,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.settingsTitle,
                                style: t.labelMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ) ??
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: isWebUi ? 12 : 6),
                  Expanded(
                    child: isWebUi
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _kWebReglageMaxWidth,
                              ),
                              child: listView,
                            ),
                          )
                        : listView,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
