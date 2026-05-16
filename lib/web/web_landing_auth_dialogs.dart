import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../reglage/reglage_profile_auth_panel.dart';
import '../reglage/reglage_profile_connect_constants.dart';
import 'web_landing_iframe_suppress.dart';

const _kCardBlack = Color(0xFF0A0A0A);
const _kAuthDialogRadius = 40.0;

enum _WebLandingAuthMode { login, signup }

void _popDialog(BuildContext dialogCtx) {
  if (!dialogCtx.mounted) return;
  Navigator.of(dialogCtx, rootNavigator: true).pop();
}

/// Fenêtre **opaque** (#0A0A0A), même structure qu’avant : [Dialog] + [ReglageProfileAuthPanel] (Google / Apple / Facebook inchangés).
Widget _webLandingAuthDialogBody({
  required BuildContext dialogCtx,
  required _WebLandingAuthMode mode,
  required BuildContext callerContext,
}) {
  final l10n = AppLocalizations.of(dialogCtx)!;
  final isLogin = mode == _WebLandingAuthMode.login;
  final title = isLogin ? l10n.accountTabLogin : l10n.accountTabSignup;
  final subtitle = isLogin
      ? 'Bon retour sur Paychek.'
      : 'Rejoignez l\'élite des traders.';

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
      child: Material(
        color: _kCardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kAuthDialogRadius),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
          child: SingleChildScrollView(
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
                  onPressed: () => _popDialog(dialogCtx),
                ),
              ),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
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
                landingLoginCtaLabel: 'SE CONNECTER',
                landingSignupCtaLabel: 'ESSAYER GRATUITEMENT',
                onAuthSuccess: () => _popDialog(dialogCtx),
              ),
              const SizedBox(height: 12),
              if (isLogin)
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        'PAS DE COMPTE ?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.06,
                          color: Colors.white38,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _popDialog(dialogCtx);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (callerContext.mounted) {
                              showWebLandingSignupDialog(callerContext);
                            }
                          });
                        },
                        child: Text(
                          'S\'INSCRIRE',
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
                        'DÉJÀ MEMBRE ?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.06,
                          color: Colors.white38,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _popDialog(dialogCtx);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (callerContext.mounted) {
                              showWebLandingLoginDialog(callerContext);
                            }
                          });
                        },
                        child: Text(
                          'CONNEXION',
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
          ),
        ),
      ),
    ),
  );
}

Future<void> _showWebLandingAuthDialog(
  BuildContext context, {
  required _WebLandingAuthMode mode,
}) async {
  if (!context.mounted) return;
  WebLandingIframeSuppress.prepareForAuthOverlay();
  if (!context.mounted) {
    WebLandingIframeSuppress.release();
    return;
  }
  try {
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (dialogCtx) => _webLandingAuthDialogBody(
        dialogCtx: dialogCtx,
        mode: mode,
        callerContext: context,
      ),
    );
  } finally {
    WebLandingIframeSuppress.release();
  }
}

Future<void> showWebLandingLoginDialog(BuildContext context) async {
  await _showWebLandingAuthDialog(context, mode: _WebLandingAuthMode.login);
}

Future<void> showWebLandingSignupDialog(BuildContext context) async {
  await _showWebLandingAuthDialog(context, mode: _WebLandingAuthMode.signup);
}
