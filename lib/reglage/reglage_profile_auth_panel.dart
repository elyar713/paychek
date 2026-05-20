import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show debugPrint, kDebugMode, defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:async' show unawaited;

import 'package:url_launcher/url_launcher.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../questionnaire/questionnaire_completion_prefs.dart';
import '../paychek_brand_links.dart';
import '../web/web_landing_password_reset_dialog.dart';
import 'paychek_user_firestore.dart';
import 'reglage_profile_connect_branding.dart';
import 'reglage_profile_connect_constants.dart';
import 'reglage_profile_connect_login_form.dart';
import 'reglage_profile_connect_signup_form.dart';
import 'reglage_profile_connect_terminal_chrome.dart';
import 'reglage_profile_connect_tokens.dart';
import 'reglage_profile_prefs.dart';
import 'social_auth_service.dart';
import 'user_profile_scope.dart';

/// Présentation du bloc connexion / inscription (onglets ou formulaire unique).
enum ReglageAuthPanelMode {
  tabbed,
  loginOnly,
  signupOnly,
}

enum _AuthTab { connexion, inscription }

/// Logo + réseaux + email / mot de passe — réutilisable (page Réglages, modales web).
class ReglageProfileAuthPanel extends StatefulWidget {
  const ReglageProfileAuthPanel({
    super.key,
    this.initialTab = ReglageAuthInitialTab.connexion,
    this.mode = ReglageAuthPanelMode.tabbed,
    required this.onAuthSuccess,
    this.closeImmediatelyOnSuccess = false,
    this.showNavbarLogo = true,
    this.showContinueHeading = true,
    this.showAuthEyebrow = true,
    this.dense = false,
    /// Champs blancs en pilule + CTA blanc (modales landing web).
    this.landingPillStyle = false,
    /// Libellé bouton principal connexion si [landingPillStyle] (ex. « SE CONNECTER »).
    this.landingLoginCtaLabel,
    /// Libellé bouton principal inscription si [landingPillStyle] (ex. « ESSAYER GRATUITEMENT »).
    this.landingSignupCtaLabel,
    this.premiumTerminalChrome = false,
  });

  final ReglageAuthInitialTab initialTab;
  final ReglageAuthPanelMode mode;
  final VoidCallback onAuthSuccess;
  /// Landing web : fermer la modale tout de suite après succès Auth (ne pas attendre Firestore).
  final bool closeImmediatelyOnSuccess;
  final bool showNavbarLogo;
  final bool showContinueHeading;
  /// Petit titre « Login » au-dessus du logo ; désactivé dans les modales landing.
  final bool showAuthEyebrow;
  final bool dense;
  final bool landingPillStyle;
  final String? landingLoginCtaLabel;
  final String? landingSignupCtaLabel;
  /// Maquette « Premium Terminal » (grille, logo PAYCHEK, onglets soulignés, champs glass).
  final bool premiumTerminalChrome;

  @override
  State<ReglageProfileAuthPanel> createState() =>
      _ReglageProfileAuthPanelState();
}

class _ReglageProfileAuthPanelState extends State<ReglageProfileAuthPanel> {
  late _AuthTab _tab;

  final TextEditingController _loginEmail = TextEditingController();
  final TextEditingController _loginPassword = TextEditingController();
  final TextEditingController _signPrenom = TextEditingController();
  final TextEditingController _signNom = TextEditingController();
  final TextEditingController _signEmail = TextEditingController();
  final TextEditingController _signPassword = TextEditingController();
  final TextEditingController _signConfirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    switch (widget.mode) {
      case ReglageAuthPanelMode.loginOnly:
        _tab = _AuthTab.connexion;
      case ReglageAuthPanelMode.signupOnly:
        _tab = _AuthTab.inscription;
      case ReglageAuthPanelMode.tabbed:
        _tab = widget.initialTab == ReglageAuthInitialTab.inscription
            ? _AuthTab.inscription
            : _AuthTab.connexion;
    }
  }

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _signPrenom.dispose();
    _signNom.dispose();
    _signEmail.dispose();
    _signPassword.dispose();
    _signConfirm.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2A2A2A),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool get _showWindowsAuthNotice =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  Future<void> _openPaychekWebsite(AppLocalizations l10n) async {
    final uri = Uri.parse(kPaychekPublicWebsiteUrl);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        _snack(l10n.accountAuthErrorNetwork);
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[Paychek] launchUrl paychek.pro: $e\n$st');
      }
      if (mounted) {
        _snack(l10n.accountAuthErrorNetwork);
      }
    }
  }

  Widget _buildWindowsAuthNotice(AppLocalizations l10n, {required bool terminal}) {
    final textStyle = terminal
        ? GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: PaychekTerminalAuthColors.zinc500,
          )
        : GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: Colors.white.withValues(alpha: 0.78),
          );
    final btnStyle = terminal
        ? GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: PaychekTerminalAuthColors.emerald,
          )
        : GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kReglageProfileBrandTeal,
          );
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
      decoration: BoxDecoration(
        color: terminal
            ? PaychekTerminalAuthColors.zinc900
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: terminal
              ? PaychekTerminalAuthColors.zinc600.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: terminal ? 16 : 18,
                color: terminal
                    ? PaychekTerminalAuthColors.zinc500
                    : Colors.white.withValues(alpha: 0.65),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.accountAuthWindowsSignInNotice,
                  style: textStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                unawaited(_openPaychekWebsite(l10n));
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.accountAuthWindowsOpenWebsite, style: btnStyle),
            ),
          ),
        ],
      ),
    );
  }

  String _firebaseAuthMessage(FirebaseAuthException e, AppLocalizations l10n) {
    final normalized = e.code.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'unknown') {
      final detail = e.message?.trim();
      if (detail != null && detail.isNotEmpty) {
        final clipped =
            detail.length > 180 ? '${detail.substring(0, 177)}…' : detail;
        return l10n.accountAuthErrorSignInServerMessage(clipped);
      }
      return l10n.accountAuthErrorUnknownFirebaseAuth;
    }
    switch (e.code) {
      case 'weak-password':
        return l10n.accountAuthErrorWeakPassword;
      case 'email-already-in-use':
        return l10n.accountAuthErrorEmailInUse;
      case 'invalid-email':
        return l10n.accountAuthErrorInvalidEmail;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'user-disabled':
      case 'invalid-login-credentials':
        return l10n.accountAuthErrorWrongCredentials;
      case 'network-request-failed':
      case 'web-context-cancelled':
        return l10n.accountAuthErrorNetwork;
      case 'operation-not-allowed':
      case 'too-many-requests':
      case 'internal-error':
      case 'invalid-api-key':
        return l10n.accountAuthErrorWithFirebaseCode(e.code);
      case 'account-exists-with-different-credential':
        return l10n.accountAuthErrorDifferentSignInMethod;
      default:
        return l10n.accountAuthErrorWithFirebaseCode(e.code);
    }
  }

  void _snackAuthFailure(Object error, AppLocalizations l10n) {
    if (error is FirebaseAuthException) {
      _snack(_firebaseAuthMessage(error, l10n));
      return;
    }
    if (error is PlatformException &&
        (error.code == 'channel-error' ||
            (error.message?.contains('Unable to establish connection') ??
                false))) {
      _snack(l10n.accountAuthErrorRestartOrReload);
      return;
    }
    if (error is StateError) {
      final m = error.message;
      if (m == 'google_web_client_id' || m == 'google_no_id_token') {
        _snack(l10n.accountSocialGoogleWebClientMissing);
        return;
      }
      if (m == 'apple_sign_in_use_google_android') {
        _snack(l10n.accountSocialAppleAndroidUseGoogle);
        return;
      }
      if (m == 'apple_sign_in_unavailable_desktop') {
        _snack(l10n.accountSocialAppleUnavailableDesktop);
        return;
      }
      if (m == 'apple_no_id_token') {
        _snack(l10n.accountAuthErrorUnknownFirebaseAuth);
        return;
      }
      if (m.isNotEmpty) {
        final snakeOnly = RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(m);
        if (!snakeOnly) {
          _snack(m.length > 200 ? '${m.substring(0, 197)}…' : m);
          return;
        }
      }
    }
    if (error is FirebaseException && error is! FirebaseAuthException) {
      final fe = error;
      final msg = fe.message?.trim();
      if (msg != null && msg.isNotEmpty) {
        final clipped =
            msg.length > 180 ? '${msg.substring(0, 177)}…' : msg;
        _snack(l10n.accountAuthErrorSignInServerMessage(clipped));
      } else {
        _snack(l10n.accountAuthErrorWithFirebaseCode('${fe.plugin}/${fe.code}'));
      }
      return;
    }
    if (kDebugMode) {
      debugPrint('[Paychek] ReglageProfileAuthPanel auth failure: $error');
    }
    _snack(l10n.accountAuthErrorGeneric);
  }

  Future<void> _applyLocalProfile({
    required bool inscrit,
    required String prenom,
    required String nom,
    required String email,
  }) async {
    await ReglageProfilePrefs.save(
      inscrit: inscrit,
      prenom: prenom,
      nom: nom,
      email: email,
    );
    final data = await ReglageProfilePrefs.load();
    if (!mounted) return;
    UserProfileScope.of(context).setProfile(data);
  }

  Future<void> _mergeFirebaseUserIntoLocalProfile(User user) async {
    await paychekMergeProfileFromFirestore(user);
    final data = await ReglageProfilePrefs.load();
    if (!mounted) return;
    UserProfileScope.of(context).setProfile(data);
  }

  void _afterAuthOk() => widget.onAuthSuccess();

  Future<void> _markQuestionnaireIfNewUser(UserCredential cred) async {
    if (cred.additionalUserInfo?.isNewUser == true && cred.user != null) {
      await QuestionnaireCompletionPrefs.markIncomplete(cred.user!.uid);
    }
  }

  Future<void> _signInWithGoogle(AppLocalizations l10n) async {
    if (!isGoogleSignInAvailableOnThisPlatform()) {
      _snack(l10n.accountSocialGoogleUnavailableDesktop);
      return;
    }
    try {
      final cred = await signInWithGoogle();
      if (cred == null || cred.user == null) return;
      await _markQuestionnaireIfNewUser(cred);
      if (widget.closeImmediatelyOnSuccess) {
        _afterAuthOk();
        unawaited(syncPaychekUserDocumentAndMergeProfile(cred.user!));
        return;
      }
      await syncPaychekUserDocument(cred.user!);
      await _mergeFirebaseUserIntoLocalProfile(cred.user!);
      if (!mounted) return;
      _afterAuthOk();
    } on UnsupportedError catch (_) {
      if (!mounted) return;
      _snack(l10n.accountSocialGoogleUnavailableDesktop);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _snack(_firebaseAuthMessage(e, l10n));
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      final detail = e.description?.trim();
      if (detail != null && detail.isNotEmpty) {
        _snack(detail);
      } else {
        _snack(l10n.accountSocialGoogleWebClientMissing);
      }
    } catch (e) {
      if (!mounted) return;
      if (e is StateError && e.message == 'google_web_client_id') {
        _snack(l10n.accountSocialGoogleWebClientMissing);
      } else {
        _snackAuthFailure(e, l10n);
      }
    }
  }

  Future<void> _signInWithFacebook(AppLocalizations l10n) async {
    if (!isFacebookSignInAvailableOnThisPlatform()) {
      _snack(l10n.accountSocialFacebookUnavailableDesktop);
      return;
    }
    try {
      final cred = await signInWithFacebook();
      if (cred == null || cred.user == null) return;
      await _markQuestionnaireIfNewUser(cred);
      if (widget.closeImmediatelyOnSuccess) {
        _afterAuthOk();
        unawaited(syncPaychekUserDocumentAndMergeProfile(cred.user!));
        return;
      }
      await syncPaychekUserDocument(cred.user!);
      await _mergeFirebaseUserIntoLocalProfile(cred.user!);
      if (!mounted) return;
      _afterAuthOk();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _snack(_firebaseAuthMessage(e, l10n));
    } catch (e) {
      if (!mounted) return;
      _snackAuthFailure(e, l10n);
    }
  }

  Future<void> _signInWithApple(AppLocalizations l10n) async {
    try {
      final cred = await signInWithApple();
      if (cred == null || cred.user == null) return;
      await _markQuestionnaireIfNewUser(cred);
      if (widget.closeImmediatelyOnSuccess) {
        _afterAuthOk();
        unawaited(syncPaychekUserDocumentAndMergeProfile(cred.user!));
        return;
      }
      await syncPaychekUserDocument(cred.user!);
      await _mergeFirebaseUserIntoLocalProfile(cred.user!);
      if (!mounted) return;
      _afterAuthOk();
    } on UnsupportedError catch (e) {
      if (!mounted) return;
      if (e.message == 'apple_sign_in_native') {
        _snack(l10n.accountSocialAppleUnavailableDesktop);
        return;
      }
      _snack(l10n.accountAuthErrorGeneric);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (!mounted) return;
      if (e.code == AuthorizationErrorCode.canceled) return;
      _snack(e.message);
    } on SignInWithAppleNotSupportedException catch (e) {
      if (!mounted) return;
      _snack(e.message);
    } on SignInWithAppleCredentialsException catch (e) {
      if (!mounted) return;
      _snack(e.message);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _snack(_firebaseAuthMessage(e, l10n));
    } catch (e) {
      if (!mounted) return;
      _snackAuthFailure(e, l10n);
    }
  }

  static final TextStyle _kLandingFieldTextStyle = GoogleFonts.plusJakartaSans(
    color: const Color(0xFF111111),
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  ButtonStyle _landingCtaButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
      minimumSize: const Size(double.infinity, 52),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }

  InputDecoration _fieldDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(color: kReglageProfileMonoMuted),
      floatingLabelStyle: const TextStyle(color: kReglageProfileMonoMuted),
      filled: true,
      fillColor: kReglageProfileMonoSurface,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      isDense: true,
      contentPadding:
          EdgeInsets.symmetric(vertical: widget.dense ? 12 : 14, horizontal: 14),
    );
  }

  InputDecoration _landingPillFieldDecoration(String label, {Widget? suffixIcon}) {
    final r = BorderRadius.circular(999);
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF7A7A7A),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF444444),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: r, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: r, borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
      ),
      disabledBorder: OutlineInputBorder(borderRadius: r, borderSide: BorderSide.none),
      errorBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        vertical: widget.dense ? 14 : 16,
        horizontal: 20,
      ),
    );
  }

  InputDecoration Function(String label, {Widget? suffixIcon}) get _activeFieldDecoration {
    return widget.landingPillStyle ? _landingPillFieldDecoration : _fieldDecoration;
  }

  Widget _socialIconTap(Widget icon, VoidCallback onTap) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }

  bool get _showLoginForm {
    return widget.mode == ReglageAuthPanelMode.loginOnly ||
        (widget.mode == ReglageAuthPanelMode.tabbed &&
            _tab == _AuthTab.connexion);
  }

  bool get _showSignupForm {
    return widget.mode == ReglageAuthPanelMode.signupOnly ||
        (widget.mode == ReglageAuthPanelMode.tabbed &&
            _tab == _AuthTab.inscription);
  }

  bool get _showTabs => widget.mode == ReglageAuthPanelMode.tabbed;

  Widget _terminalContinueDivider(AppLocalizations l10n) {
    final inter = GoogleFonts.inter;
    final label =
        l10n.accountContinueWith.replaceAll(':', '').trim().toUpperCase();
    return Row(
      children: [
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: PaychekTerminalAuthColors.zinc900,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: inter(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: PaychekTerminalAuthColors.zinc600,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: PaychekTerminalAuthColors.zinc900,
          ),
        ),
      ],
    );
  }

  Widget _terminalSocialRow(AppLocalizations l10n) {
    return Row(
      children: [
        PaychekTerminalSocialTile(
          onTap: () => _signInWithGoogle(l10n),
          child: const ReglageProfileGoogleBrandMark(size: 22),
        ),
        const SizedBox(width: 14),
        PaychekTerminalSocialTile(
          onTap: () => _signInWithApple(l10n),
          child: const Icon(Icons.apple, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        PaychekTerminalSocialTile(
          onTap: () => _signInWithFacebook(l10n),
          child: const ReglageProfileFacebookBrandMark(size: 22),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = widget.dense ? 0.0 : 4.0;
    final useTerminal = widget.premiumTerminalChrome && !widget.landingPillStyle;

    if (useTerminal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.dense) SizedBox(height: topPad),
          if (_showWindowsAuthNotice) ...[
            _buildWindowsAuthNotice(l10n, terminal: true),
            SizedBox(height: widget.dense ? 10 : 14),
          ],
          PaychekTerminalLogoHeader(tagline: l10n.authTerminalTagline),
          SizedBox(height: widget.dense ? 14 : 24),
          if (_showTabs) ...[
            PaychekTerminalAuthTabBar(
              tabLoginLabel: l10n.accountTabLogin,
              tabSignupLabel: l10n.accountTabSignup,
              loginSelected: _tab == _AuthTab.connexion,
              onLoginTap: () => setState(() => _tab = _AuthTab.connexion),
              onSignupTap: () => setState(() => _tab = _AuthTab.inscription),
            ),
            SizedBox(height: widget.dense ? 16 : 24),
          ],
          if (_showLoginForm)
            ReglageProfileLoginForm(
              loginEmail: _loginEmail,
              loginPassword: _loginPassword,
              fieldDecoration: _activeFieldDecoration,
              premiumTerminalChrome: true,
              primaryButtonLabel: l10n.authTerminalCtaLogin,
              closeImmediatelyOnSuccess: widget.closeImmediatelyOnSuccess,
              snack: _snack,
              firebaseAuthMessage: _firebaseAuthMessage,
              snackAuthFailure: _snackAuthFailure,
              applyLocalProfile: _applyLocalProfile,
              popBackToSettingsAfterAuth: _afterAuthOk,
            )
          else if (_showSignupForm)
            ReglageProfileSignupForm(
              signPrenom: _signPrenom,
              signNom: _signNom,
              signEmail: _signEmail,
              signPassword: _signPassword,
              signConfirm: _signConfirm,
              fieldDecoration: _activeFieldDecoration,
              signupNamesSideBySide: true,
              premiumTerminalChrome: true,
              primaryButtonLabel: l10n.authTerminalCtaSignup,
              closeImmediatelyOnSuccess: widget.closeImmediatelyOnSuccess,
              snack: _snack,
              firebaseAuthMessage: _firebaseAuthMessage,
              snackAuthFailure: _snackAuthFailure,
              applyLocalProfile: _applyLocalProfile,
              popBackToSettingsAfterAuth: _afterAuthOk,
            ),
          SizedBox(height: widget.dense ? 20 : 28),
          _terminalContinueDivider(l10n),
          SizedBox(height: widget.dense ? 12 : 16),
          _terminalSocialRow(l10n),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.dense) SizedBox(height: topPad),
        if (_showWindowsAuthNotice) ...[
          _buildWindowsAuthNotice(l10n, terminal: false),
          SizedBox(height: widget.dense ? 10 : 14),
        ],
        if (widget.showAuthEyebrow &&
            (widget.showContinueHeading || widget.showNavbarLogo))
          Text(
            l10n.accountAuthSectionTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: DashboardTokens.labelGrey,
            ),
          ),
        if (widget.showAuthEyebrow &&
            (widget.showContinueHeading || widget.showNavbarLogo))
          SizedBox(height: widget.dense ? 10 : 12),
        if (widget.showNavbarLogo) ...[
          const Center(child: ReglageProfileNavbarHorizontalLogo()),
          SizedBox(height: widget.dense ? 14 : 18),
        ],
        if (widget.showContinueHeading)
          Center(
            child: Text(
              l10n.accountContinueWith,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: widget.landingPillStyle
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.white,
              ),
            ),
          ),
        if (widget.showContinueHeading) SizedBox(height: widget.dense ? 8 : 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIconTap(
              const ReglageProfileGoogleBrandMark(size: 28),
              () => _signInWithGoogle(l10n),
            ),
            _socialIconTap(
              const Icon(Icons.apple, color: Colors.white, size: 28),
              () => _signInWithApple(l10n),
            ),
            _socialIconTap(
              const ReglageProfileFacebookBrandMark(size: 28),
              () => _signInWithFacebook(l10n),
            ),
          ],
        ),
        SizedBox(height: widget.dense ? 18 : 24),
        Divider(
          height: 1,
          thickness: 1,
          color: widget.landingPillStyle
              ? Colors.white.withValues(alpha: 0.12)
              : DashboardTokens.border.withValues(alpha: 0.6),
        ),
        SizedBox(height: widget.dense ? 14 : 16),
        if (_showTabs) ...[
          Row(
            children: [
              Expanded(
                child: ReglageProfileAuthTabButton(
                  label: l10n.accountTabLogin,
                  selected: _tab == _AuthTab.connexion,
                  onTap: () => setState(() => _tab = _AuthTab.connexion),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReglageProfileAuthTabButton(
                  label: l10n.accountTabSignup,
                  selected: _tab == _AuthTab.inscription,
                  onTap: () => setState(() => _tab = _AuthTab.inscription),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.dense ? 14 : 20),
        ],
        if (_showLoginForm)
          ReglageProfileLoginForm(
            loginEmail: _loginEmail,
            loginPassword: _loginPassword,
            fieldDecoration: _activeFieldDecoration,
            fieldTextStyle:
                widget.landingPillStyle ? _kLandingFieldTextStyle : null,
            ctaButtonStyle:
                widget.landingPillStyle ? _landingCtaButtonStyle() : null,
            uppercaseCtaLabel: widget.landingPillStyle,
            primaryButtonLabel: widget.landingLoginCtaLabel,
            closeImmediatelyOnSuccess: widget.closeImmediatelyOnSuccess,
            snack: _snack,
            firebaseAuthMessage: _firebaseAuthMessage,
            snackAuthFailure: _snackAuthFailure,
            applyLocalProfile: _applyLocalProfile,
            popBackToSettingsAfterAuth: _afterAuthOk,
            onForgotPasswordTap: widget.landingPillStyle
                ? () {
                    unawaited(
                      showWebLandingPasswordResetDialog(
                        context,
                        initialEmail: _loginEmail.text.trim(),
                        snack: _snack,
                        firebaseAuthMessage: _firebaseAuthMessage,
                        snackAuthFailure: _snackAuthFailure,
                      ),
                    );
                  }
                : null,
          )
        else if (_showSignupForm)
          ReglageProfileSignupForm(
            signPrenom: _signPrenom,
            signNom: _signNom,
            signEmail: _signEmail,
            signPassword: _signPassword,
            signConfirm: _signConfirm,
            fieldDecoration: _activeFieldDecoration,
            signupNamesSideBySide: widget.landingPillStyle,
            fieldTextStyle:
                widget.landingPillStyle ? _kLandingFieldTextStyle : null,
            ctaButtonStyle:
                widget.landingPillStyle ? _landingCtaButtonStyle() : null,
            uppercaseCtaLabel: widget.landingPillStyle,
            primaryButtonLabel: widget.landingSignupCtaLabel,
            closeImmediatelyOnSuccess: widget.closeImmediatelyOnSuccess,
            snack: _snack,
            firebaseAuthMessage: _firebaseAuthMessage,
            snackAuthFailure: _snackAuthFailure,
            applyLocalProfile: _applyLocalProfile,
            popBackToSettingsAfterAuth: _afterAuthOk,
          ),
      ],
    );
  }
}
