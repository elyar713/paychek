import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../shared/paychek_frame_callbacks.dart';
import 'paychek_password_reset_sent_dialog.dart';

const _kCardBlack = Color(0xFF0A0A0A);
const _kDialogRadius = 24.0;
const _kAccent = Color(0xFF1EB48A);

/// Compte créé avec e-mail / mot de passe Firebase (pas Google / Apple seuls).
bool paychekUserHasEmailPasswordProvider(User? user) {
  if (user == null) return false;
  return user.providerData.any((info) => info.providerId == 'password');
}

Future<void> showPaychekChangePasswordDialog(
  BuildContext context, {
  required String email,
}) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.88),
    builder: (dialogCtx) => _PaychekChangePasswordDialog(
      dialogCtx: dialogCtx,
      callerContext: context,
      email: email.trim(),
    ),
  );
}

class _PaychekChangePasswordDialog extends StatefulWidget {
  const _PaychekChangePasswordDialog({
    required this.dialogCtx,
    required this.callerContext,
    required this.email,
  });

  final BuildContext dialogCtx;
  final BuildContext callerContext;
  final String email;

  @override
  State<_PaychekChangePasswordDialog> createState() =>
      _PaychekChangePasswordDialogState();
}

class _PaychekChangePasswordDialogState extends State<_PaychekChangePasswordDialog> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _busy = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!widget.callerContext.mounted) return;
    ScaffoldMessenger.of(widget.callerContext).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A2A2A),
      ),
    );
  }

  void _schedulePasswordResetSentDialog() {
    final caller = widget.callerContext;
    PaychekFrameCallbacks.runPostFrame(
      () => unawaited(showPaychekPasswordResetSentDialog(caller)),
      context: caller,
    );
  }

  void _closeDialog() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  String _authMessage(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'weak-password':
        return l10n.accountAuthErrorWeakPassword;
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return l10n.accountAuthErrorWrongCredentials;
      case 'requires-recent-login':
        return l10n.accountChangePasswordRequiresRecentLogin;
      case 'too-many-requests':
        return l10n.accountForgotPasswordSnackTooManyRequests;
      case 'network-request-failed':
        return l10n.accountAuthErrorNetwork;
      default:
        return l10n.accountAuthErrorWithFirebaseCode(e.code);
    }
  }

  Future<void> _sendResetLink() async {
    final l10n = AppLocalizations.of(context)!;
    final email = widget.email;
    if (email.isEmpty) {
      _snack(l10n.accountPasswordResetSnackEmailMissing);
      return;
    }
    setState(() => _busy = true);
    var closedDialog = false;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      closedDialog = true;
      _closeDialog();
      _schedulePasswordResetSentDialog();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final code = e.code.trim().toLowerCase();
      if (code == 'user-not-found') {
        closedDialog = true;
        _closeDialog();
        _schedulePasswordResetSentDialog();
        return;
      }
      _snack(_authMessage(e, l10n));
    } finally {
      if (mounted && !closedDialog) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final current = _currentCtrl.text;
    final newPw = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (current.isEmpty) {
      _snack(l10n.accountChangePasswordCurrentMissing);
      return;
    }
    if (newPw.isEmpty) {
      _snack(l10n.accountSignupSnackPasswordMissing);
      return;
    }
    if (newPw.length < 6) {
      _snack(l10n.accountSignupSnackPasswordTooShort);
      return;
    }
    if (newPw != confirm) {
      _snack(l10n.accountSignupSnackPasswordMismatch);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = widget.email;
    if (user == null || email.isEmpty) {
      _snack(l10n.accountAuthErrorGeneric);
      return;
    }

    setState(() => _busy = true);
    var closedDialog = false;
    try {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPw);
      if (!mounted) return;
      closedDialog = true;
      _closeDialog();
      _snack(l10n.accountChangePasswordSuccessSnack);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _snack(_authMessage(e, l10n));
    } catch (_) {
      if (!mounted) return;
      _snack(l10n.accountAuthErrorGeneric);
    } finally {
      if (mounted && !closedDialog) setState(() => _busy = false);
    }
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label.toUpperCase(),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: Colors.white54,
      ),
      filled: true,
      fillColor: const Color(0xFF121214),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2C2C30)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2C2C30)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kAccent),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      autofillHints: const [AutofillHints.password],
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      cursorColor: _kAccent,
      decoration: _fieldDecoration(label).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.white38,
            size: 20,
          ),
          onPressed: toggleObscure,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final maxCardW = math.min(440.0, mq.size.width - mq.padding.horizontal - 32);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxCardW),
        child: Material(
          color: _kCardBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kDialogRadius),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.5)),
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(widget.dialogCtx, rootNavigator: true).pop(),
                  ),
                ),
                Text(
                  l10n.accountChangePasswordDialogTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _passwordField(
                  controller: _currentCtrl,
                  label: l10n.accountChangePasswordCurrentLabel,
                  obscure: _obscureCurrent,
                  toggleObscure: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                const SizedBox(height: 12),
                _passwordField(
                  controller: _newCtrl,
                  label: l10n.accountChangePasswordNewLabel,
                  obscure: _obscureNew,
                  toggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 12),
                _passwordField(
                  controller: _confirmCtrl,
                  label: l10n.accountChangePasswordConfirmLabel,
                  obscure: _obscureConfirm,
                  toggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _busy ? null : () => unawaited(_sendResetLink()),
                    child: Text(
                      l10n.accountChangePasswordForgotLink,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _kAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _busy ? null : () => unawaited(_submit()),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kAccent,
                    foregroundColor: Colors.black87,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black54,
                          ),
                        )
                      : Text(
                          l10n.accountChangePasswordCta,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.6,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
