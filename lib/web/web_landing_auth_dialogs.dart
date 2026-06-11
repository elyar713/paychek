import 'dart:async' show unawaited;

import 'dart:math' as math;



import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';



import '../l10n/app_localizations.dart';

import '../reglage/app_locale_scope.dart';

import '../reglage/reglage_profile_auth_panel.dart';

import '../reglage/reglage_profile_connect_constants.dart';

import 'web_landing_iframe_suppress.dart';

import 'web_return_to_landing_stub.dart'

    if (dart.library.html) 'web_return_to_landing_web.dart';



const _kCardBlack = Color(0xFF0A0A0A);

const _kAuthDialogRadius = 40.0;



enum _WebLandingAuthMode { login, signup }



bool _hasMaterialLocalizations(BuildContext context) {

  return Localizations.of<MaterialLocalizations>(

        context,

        MaterialLocalizations,

      ) !=

      null;

}



/// Contexte valide pour [showDialog] (évite l’assert MaterialLocalizations sur Web).

BuildContext? _resolveAuthDialogHost(BuildContext context) {

  if (!context.mounted) return null;

  if (_hasMaterialLocalizations(context)) return context;



  final overlay = Overlay.maybeOf(context, rootOverlay: true);

  final overlayCtx = overlay?.context;

  if (overlayCtx != null &&

      overlayCtx.mounted &&

      _hasMaterialLocalizations(overlayCtx)) {

    return overlayCtx;

  }



  final nav = Navigator.maybeOf(context, rootNavigator: true);

  if (nav != null &&

      nav.context.mounted &&

      _hasMaterialLocalizations(nav.context)) {

    return nav.context;

  }



  return null;

}



void _popDialog(BuildContext dialogCtx) {

  if (!dialogCtx.mounted) return;

  Navigator.of(dialogCtx, rootNavigator: true).pop();

}



Widget _buildWebLandingAuthCard({

  required BuildContext context,

  required _WebLandingAuthMode mode,

  required AppLocaleController localeController,

  required VoidCallback onClose,

  required VoidCallback onAuthSuccess,

  required VoidCallback onSwitchToSignup,

  required VoidCallback onSwitchToLogin,

}) {

  final isLogin = mode == _WebLandingAuthMode.login;



  return Material(

    color: _kCardBlack,

    shape: RoundedRectangleBorder(

      borderRadius: BorderRadius.circular(_kAuthDialogRadius),

      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),

    ),

    clipBehavior: Clip.antiAlias,

    child: ListenableBuilder(

      listenable: localeController,

      builder: (context, _) {

        final l10n = AppLocalizations.of(context)!;

        return Padding(

          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            mainAxisSize: MainAxisSize.min,

            children: [

              Align(

                alignment: Alignment.topRight,

                child: IconButton(

                  visualDensity: VisualDensity.compact,

                  icon: Icon(

                    Icons.close,

                    color: Colors.white.withValues(alpha: 0.5),

                  ),

                  onPressed: onClose,

                ),

              ),

              Text(

                isLogin ? l10n.accountTabLogin : l10n.accountTabSignup,

                style: GoogleFonts.plusJakartaSans(

                  fontSize: 28,

                  fontWeight: FontWeight.w800,

                  color: Colors.white,

                ),

              ),

              const SizedBox(height: 8),

              Text(

                isLogin

                    ? l10n.webLandingLoginSubtitle

                    : l10n.webLandingSignupSubtitle,

                style: GoogleFonts.plusJakartaSans(

                  fontSize: 13,

                  fontWeight: FontWeight.w500,

                  color: Colors.white54,

                ),

              ),

              const SizedBox(height: 20),

              ReglageProfileAuthPanel(

                mode: isLogin

                    ? ReglageAuthPanelMode.loginOnly

                    : ReglageAuthPanelMode.signupOnly,

                initialTab: isLogin

                    ? ReglageAuthInitialTab.connexion

                    : ReglageAuthInitialTab.inscription,

                closeImmediatelyOnSuccess: true,

                showNavbarLogo: false,

                showContinueHeading: true,

                showAuthEyebrow: false,

                dense: true,

                landingPillStyle: true,

                landingLoginCtaLabel: l10n.webLandingLoginCta,

                landingSignupCtaLabel: l10n.webLandingSignupCta,

                onAuthSuccess: onAuthSuccess,

              ),

              const SizedBox(height: 12),

              if (isLogin)

                Center(

                  child: Wrap(

                    crossAxisAlignment: WrapCrossAlignment.center,

                    spacing: 4,

                    children: [

                      Text(

                        l10n.webLandingNoAccountLabel,

                        style: GoogleFonts.plusJakartaSans(

                          fontSize: 11,

                          fontWeight: FontWeight.w700,

                          letterSpacing: 0.06,

                          color: Colors.white38,

                        ),

                      ),

                      TextButton(

                        onPressed: onSwitchToSignup,

                        child: Text(

                          l10n.webLandingRegisterLink,

                          style: GoogleFonts.plusJakartaSans(

                            fontSize: 11,

                            fontWeight: FontWeight.w800,

                            color: Colors.white,

                            decoration: TextDecoration.underline,

                          ),

                        ),

                      ),

                    ],

                  ),

                )

              else

                Center(

                  child: Wrap(

                    crossAxisAlignment: WrapCrossAlignment.center,

                    spacing: 4,

                    children: [

                      Text(

                        l10n.webLandingAlreadyMemberLabel,

                        style: GoogleFonts.plusJakartaSans(

                          fontSize: 11,

                          fontWeight: FontWeight.w700,

                          letterSpacing: 0.06,

                          color: Colors.white38,

                        ),

                      ),

                      TextButton(

                        onPressed: onSwitchToLogin,

                        child: Text(

                          l10n.webLandingLoginLink,

                          style: GoogleFonts.plusJakartaSans(

                            fontSize: 11,

                            fontWeight: FontWeight.w800,

                            color: Colors.white,

                            decoration: TextDecoration.underline,

                          ),

                        ),

                      ),

                    ],

                  ),

                ),

            ],

          ),

        );

      },

    ),

  );

}



/// Connexion / inscription plein écran (`/?auth=…`) — fiable sur mobile web.

class WebLandingAuthShell extends StatefulWidget {

  const WebLandingAuthShell({

    super.key,

    required this.signup,

    this.transparentBackground = false,

    this.onClose,

    this.onAuthSuccess,

  });



  final bool signup;

  final bool transparentBackground;

  final VoidCallback? onClose;

  final VoidCallback? onAuthSuccess;



  @override

  State<WebLandingAuthShell> createState() => _WebLandingAuthShellState();

}



class _WebLandingAuthShellState extends State<WebLandingAuthShell> {

  late _WebLandingAuthMode _mode;



  @override

  void initState() {

    super.initState();

    _mode = widget.signup

        ? _WebLandingAuthMode.signup

        : _WebLandingAuthMode.login;

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (!mounted) return;

      unawaited(AppLocaleScope.of(context).load());

    });

  }



  @override

  Widget build(BuildContext context) {

    final localeController = AppLocaleScope.of(context);

    final mq = MediaQuery.of(context);

    final maxCardW = math.min(440.0, mq.size.width - mq.padding.horizontal - 32);



    return Scaffold(

      backgroundColor: widget.transparentBackground

          ? Colors.transparent

          : Colors.black,

      resizeToAvoidBottomInset: true,

      body: SafeArea(

        child: SingleChildScrollView(

          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + mq.viewInsets.bottom),

          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

          child: Align(

            alignment: Alignment.topCenter,

            child: ConstrainedBox(

              constraints: BoxConstraints(maxWidth: maxCardW),

              child: _buildWebLandingAuthCard(

                context: context,

                mode: _mode,

                localeController: localeController,

                onClose: widget.onClose ?? paychekReturnToLandingIfAuthCancelled,

                onAuthSuccess: widget.onAuthSuccess ?? paychekStripAuthQueryFromUrl,

                onSwitchToSignup: () =>

                    setState(() => _mode = _WebLandingAuthMode.signup),

                onSwitchToLogin: () =>

                    setState(() => _mode = _WebLandingAuthMode.login),

              ),

            ),

          ),

        ),

      ),

    );

  }

}



Widget _webLandingAuthDialogBody({

  required BuildContext dialogCtx,

  required _WebLandingAuthMode mode,

  required BuildContext callerContext,

  required AppLocaleController localeController,

  VoidCallback? onAuthSuccessBeforePop,

}) {

  final mq = MediaQuery.of(dialogCtx);

  final maxCardW = math.min(440.0, mq.size.width - mq.padding.horizontal - 32);

  final maxCardH = mq.size.height * 0.88;



  return Dialog(

    backgroundColor: Colors.transparent,

    surfaceTintColor: Colors.transparent,

    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),

    alignment: Alignment.center,

    clipBehavior: Clip.none,

    child: ConstrainedBox(

      constraints: BoxConstraints(maxWidth: maxCardW, maxHeight: maxCardH),

      child: SingleChildScrollView(

        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),

        child: _buildWebLandingAuthCard(

          context: dialogCtx,

          mode: mode,

          localeController: localeController,

          onClose: () => _popDialog(dialogCtx),

          onAuthSuccess: () {

            onAuthSuccessBeforePop?.call();

            _popDialog(dialogCtx);

          },

          onSwitchToSignup: () {

            _popDialog(dialogCtx);

            final host = callerContext;

            WidgetsBinding.instance.addPostFrameCallback((_) {

              if (!host.mounted) return;

              unawaited(

                showWebLandingSignupDialog(

                  host,

                  onAuthSuccessBeforePop: onAuthSuccessBeforePop,

                ),

              );

            });

          },

          onSwitchToLogin: () {

            _popDialog(dialogCtx);

            final host = callerContext;

            WidgetsBinding.instance.addPostFrameCallback((_) {

              if (!host.mounted) return;

              unawaited(

                showWebLandingLoginDialog(

                  host,

                  onAuthSuccessBeforePop: onAuthSuccessBeforePop,

                ),

              );

            });

          },

        ),

      ),

    ),

  );

}



Future<void> _showWebLandingAuthDialog(

  BuildContext context, {

  required _WebLandingAuthMode mode,

  VoidCallback? onAuthSuccessBeforePop,

}) async {

  final host = _resolveAuthDialogHost(context);

  if (host == null) return;

  final localeController = AppLocaleScope.of(host);

  await localeController.load();

  if (!host.mounted) return;

  WebLandingIframeSuppress.prepareForAuthOverlay();

  if (!host.mounted) {

    WebLandingIframeSuppress.release();

    return;

  }

  try {

    await showDialog<void>(

      context: host,

      useRootNavigator: true,

      barrierDismissible: false,

      barrierColor: Colors.black.withValues(alpha: 0.88),

      builder: (dialogCtx) => _webLandingAuthDialogBody(

        dialogCtx: dialogCtx,

        mode: mode,

        callerContext: host,

        localeController: localeController,

        onAuthSuccessBeforePop: onAuthSuccessBeforePop,

      ),

    );

  } catch (e, st) {

    assert(() {

      debugPrint('showWebLandingAuthDialog: $e\n$st');

      return true;

    }());

  } finally {

    WebLandingIframeSuppress.release();

  }

}



Future<void> showWebLandingLoginDialog(

  BuildContext context, {

  VoidCallback? onAuthSuccessBeforePop,

}) async {

  await _showWebLandingAuthDialog(

    context,

    mode: _WebLandingAuthMode.login,

    onAuthSuccessBeforePop: onAuthSuccessBeforePop,

  );

}



Future<void> showWebLandingSignupDialog(

  BuildContext context, {

  VoidCallback? onAuthSuccessBeforePop,

}) async {

  await _showWebLandingAuthDialog(

    context,

    mode: _WebLandingAuthMode.signup,

    onAuthSuccessBeforePop: onAuthSuccessBeforePop,

  );

}


