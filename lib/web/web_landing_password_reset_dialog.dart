import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async' show unawaited;

import '../l10n/app_localizations.dart';
import '../reglage/paychek_password_reset_sent_dialog.dart';

const _kCardBlack = Color(0xFF0A0A0A);
const _kAuthDialogRadius = 40.0;

void _popDialog(BuildContext dialogCtx) {
  if (!dialogCtx.mounted) return;
  Navigator.of(dialogCtx, rootNavigator: true).pop();
}

TextStyle _landingFieldTextStyle() {
  return GoogleFonts.plusJakartaSans(
    color: const Color(0xFF111111),
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );
}

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
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
  );
}

/// Même coque visuelle que [showWebLandingLoginDialog] : carte #0A0A0A, champs pilule, CTA blanc.
/// N’appelle pas [WebLandingIframeSuppress] : à ouvrir par-dessus la modale login (déjà en overlay).
Future<void> showWebLandingPasswordResetDialog(
  BuildContext context, {
  String initialEmail = '',
  required void Function(String message) snack,
  required String Function(FirebaseAuthException e, AppLocalizations l10n)
      firebaseAuthMessage,
  required void Function(Object error, AppLocalizations l10n) snackAuthFailure,
}) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.88),
    builder: (dialogCtx) => _WebLandingPasswordResetDialog(
      dialogCtx: dialogCtx,
      callerContext: context,
      initialEmail: initialEmail,
      snack: snack,
      firebaseAuthMessage: firebaseAuthMessage,
      snackAuthFailure: snackAuthFailure,
    ),
  );
}

class _WebLandingPasswordResetDialog extends StatefulWidget {
  const _WebLandingPasswordResetDialog({
    required this.dialogCtx,
    required this.callerContext,
    required this.initialEmail,
    required this.snack,
    required this.firebaseAuthMessage,
    required this.snackAuthFailure,
  });

  final BuildContext dialogCtx;
  final BuildContext callerContext;
  final String initialEmail;
  final void Function(String message) snack;
  final String Function(FirebaseAuthException e, AppLocalizations l10n)
      firebaseAuthMessage;
  final void Function(Object error, AppLocalizations l10n) snackAuthFailure;

  @override
  State<_WebLandingPasswordResetDialog> createState() =>
      _WebLandingPasswordResetDialogState();
}

class _WebLandingPasswordResetDialogState
    extends State<_WebLandingPasswordResetDialog> {
  late final TextEditingController _email;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _showSentConfirmation() {
    _popDialog(widget.dialogCtx);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.callerContext.mounted) {
        unawaited(showPaychekPasswordResetSentDialog(widget.callerContext));
      }
    });
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _email.text.trim();
    if (email.isEmpty) {
      widget.snack(l10n.accountPasswordResetSnackEmailMissing);
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showSentConfirmation();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10nAfter = AppLocalizations.of(context)!;
      final code = e.code.trim().toLowerCase();
      if (code == 'user-not-found') {
        _showSentConfirmation();
        return;
      }
      if (code == 'too-many-requests') {
        widget.snack(l10nAfter.accountForgotPasswordSnackTooManyRequests);
        return;
      }
      if (code == 'invalid-email') {
        widget.snack(l10nAfter.accountAuthErrorInvalidEmail);
        return;
      }
      if (code == 'network-request-failed' || code == 'web-context-cancelled') {
        widget.snack(l10nAfter.accountAuthErrorNetwork);
        return;
      }
      widget.snack(widget.firebaseAuthMessage(e, l10nAfter));
    } catch (e) {
      if (!mounted) return;
      final l10nAfter = AppLocalizations.of(context)!;
      widget.snackAuthFailure(e, l10nAfter);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final maxCardW = math.min(440.0, mq.size.width - mq.padding.horizontal - 32);
    final maxCardH = mq.size.height * 0.88;
    final ctaFont = GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w800,
      fontSize: 13,
      letterSpacing: 0.9,
    );

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
                      onPressed: () => _popDialog(widget.dialogCtx),
                    ),
                  ),
                  Text(
                    l10n.accountPasswordResetDialogTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.accountPasswordResetDialogSubtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _email,
                    enabled: !_busy,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    style: _landingFieldTextStyle(),
                    decoration: _landingPillFieldDecoration(l10n.accountFieldEmail),
                    onSubmitted: (_) {
                      if (!_busy) _send();
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _send,
                    style: _landingCtaButtonStyle(),
                    child: _busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            l10n.accountPasswordResetCta,
                            style: ctaFont,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _busy ? null : () => _popDialog(widget.dialogCtx),
                      child: Text(
                        l10n.accountPasswordResetBackToLogin,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.06,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
}
