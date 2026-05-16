import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async' show unawaited;

import '../l10n/app_localizations.dart';
import 'paychek_password_reset_sent_dialog.dart';
import 'paychek_user_firestore.dart';
import 'reglage_profile_connect_terminal_chrome.dart';
import 'reglage_profile_prefs.dart';
import 'reglage_profile_connect_tokens.dart';

/// Formulaire email / mot de passe (connexion).
class ReglageProfileLoginForm extends StatelessWidget {
  const ReglageProfileLoginForm({
    super.key,
    required this.loginEmail,
    required this.loginPassword,
    required this.fieldDecoration,
    this.fieldTextStyle,
    this.ctaButtonStyle,
    this.uppercaseCtaLabel = false,
    this.primaryButtonLabel,
    this.premiumTerminalChrome = false,
    this.closeImmediatelyOnSuccess = false,
    required this.snack,
    required this.firebaseAuthMessage,
    required this.snackAuthFailure,
    required this.applyLocalProfile,
    required this.popBackToSettingsAfterAuth,
    /// Landing web : ouvre la modale dédiée (même design que login) au lieu d’envoyer depuis le formulaire.
    this.onForgotPasswordTap,
  });

  final TextEditingController loginEmail;
  final TextEditingController loginPassword;
  final InputDecoration Function(String label, {Widget? suffixIcon}) fieldDecoration;
  final TextStyle? fieldTextStyle;
  final ButtonStyle? ctaButtonStyle;
  final bool uppercaseCtaLabel;
  final String? primaryButtonLabel;
  final bool premiumTerminalChrome;
  final bool closeImmediatelyOnSuccess;
  final void Function(String message) snack;
  final String Function(FirebaseAuthException e, AppLocalizations l10n) firebaseAuthMessage;
  final void Function(Object error, AppLocalizations l10n) snackAuthFailure;
  final Future<void> Function({
    required bool inscrit,
    required String prenom,
    required String nom,
    required String email,
  }) applyLocalProfile;
  final void Function() popBackToSettingsAfterAuth;
  final VoidCallback? onForgotPasswordTap;

  static ButtonStyle _terminalPrimaryCta() {
    return FilledButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      disabledBackgroundColor: Colors.white.withValues(alpha: 0.45),
      elevation: 6,
      shadowColor: PaychekTerminalAuthColors.emerald.withValues(alpha: 0.22),
      minimumSize: const Size(double.infinity, 52),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inputStyle = fieldTextStyle ??
        GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15);
    final primaryLabel =
        primaryButtonLabel ?? l10n.accountLoginButton;
    final ctaStyle = ctaButtonStyle ??
        FilledButton.styleFrom(
          backgroundColor: kReglageProfileBrandTeal,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
    final ctaFontStyle = GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w800,
      fontSize: uppercaseCtaLabel ? 13 : 15,
      letterSpacing: uppercaseCtaLabel ? 0.9 : 0,
    );
    final terminalCtaFont = GoogleFonts.inter(
      fontWeight: FontWeight.w900,
      fontSize: 11,
      letterSpacing: 2.4,
      color: Colors.black,
    );

    Future<void> sendPasswordReset() async {
      final email = loginEmail.text.trim();
      if (email.isEmpty) {
        snack(l10n.accountForgotPasswordSnackEmailMissing);
        return;
      }
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        if (!context.mounted) return;
        await showPaychekPasswordResetSentDialog(context);
      } on FirebaseAuthException catch (e) {
        if (!context.mounted) return;
        final code = e.code.trim().toLowerCase();
        if (code == 'user-not-found') {
          await showPaychekPasswordResetSentDialog(context);
          return;
        }
        if (code == 'too-many-requests') {
          snack(l10n.accountForgotPasswordSnackTooManyRequests);
          return;
        }
        if (code == 'invalid-email') {
          snack(l10n.accountAuthErrorInvalidEmail);
          return;
        }
        if (code == 'network-request-failed' || code == 'web-context-cancelled') {
          snack(l10n.accountAuthErrorNetwork);
          return;
        }
        snack(firebaseAuthMessage(e, l10n));
      } catch (e) {
        if (!context.mounted) return;
        snackAuthFailure(e, l10n);
      }
    }

    Future<void> submit() async {
      final email = loginEmail.text.trim();
      final password = loginPassword.text;
      if (email.isEmpty) {
        snack(l10n.accountLoginSnackEmailMissing);
        return;
      }
      if (password.isEmpty) {
        snack(l10n.accountLoginSnackPasswordMissing);
        return;
      }
      try {
        final cred =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final u = cred.user!;
        if (closeImmediatelyOnSuccess) {
          unawaited(() async {
            try {
              await syncPaychekUserDocument(u);
              await paychekMergeProfileFromFirestore(u);
            } catch (_) {}
          }());
          popBackToSettingsAfterAuth();
          return;
        }
        await syncPaychekUserDocument(u);
        await paychekMergeProfileFromFirestore(u);
        final merged = await ReglageProfilePrefs.load();
        await applyLocalProfile(
          inscrit: true,
          prenom: merged.prenom,
          nom: merged.nom,
          email: merged.email.trim().isNotEmpty
              ? merged.email
              : (u.email ?? email),
        );
        if (!context.mounted) return;
        popBackToSettingsAfterAuth();
      } on FirebaseAuthException catch (e) {
        if (!context.mounted) return;
        snack(firebaseAuthMessage(e, l10n));
      } catch (e) {
        if (!context.mounted) return;
        snackAuthFailure(e, l10n);
      }
    }

    if (premiumTerminalChrome) {
      return AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaychekTerminalGlassTextField(
              label: l10n.accountFieldEmail,
              controller: loginEmail,
              hintText: l10n.authTerminalHintEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              autofillHints: const [AutofillHints.email],
              prefixIcon: Icons.mail_outline_rounded,
            ),
            const SizedBox(height: 14),
            PaychekTerminalGlassTextField(
              label: l10n.accountFieldPassword,
              controller: loginPassword,
              hintText: l10n.authTerminalHintPassword,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              prefixIcon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  if (onForgotPasswordTap != null) {
                    onForgotPasswordTap!();
                  } else {
                    unawaited(sendPasswordReset());
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.accountForgotPasswordLink,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: submit,
              style: _terminalPrimaryCta(),
              child: Text(
                (primaryButtonLabel ?? l10n.authTerminalCtaLogin)
                    .toUpperCase(),
                style: terminalCtaFont,
              ),
            ),
          ],
        ),
      );
    }

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: loginEmail,
            enabled: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            style: inputStyle,
            decoration: fieldDecoration(l10n.accountFieldEmail),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: loginPassword,
            enabled: true,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            style: inputStyle,
            decoration: fieldDecoration(l10n.accountFieldPassword),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                if (onForgotPasswordTap != null) {
                  onForgotPasswordTap!();
                } else {
                  unawaited(sendPasswordReset());
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.accountForgotPasswordLink,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: submit,
            style: ctaStyle,
            child: Text(
              uppercaseCtaLabel ? primaryLabel.toUpperCase() : primaryLabel,
              style: ctaFontStyle,
            ),
          ),
        ],
      ),
    );
  }
}
