import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async' show unawaited;

import '../l10n/app_localizations.dart';
import '../questionnaire/questionnaire_completion_prefs.dart';
import 'paychek_user_firestore.dart';
import 'reglage_profile_connect_terminal_chrome.dart';
import 'reglage_profile_prefs.dart';
import 'reglage_profile_connect_tokens.dart';

/// Formulaire d'inscription (prénom, nom, email, mot de passe).
class ReglageProfileSignupForm extends StatelessWidget {
  const ReglageProfileSignupForm({
    super.key,
    required this.signPrenom,
    required this.signNom,
    required this.signEmail,
    required this.signPassword,
    required this.signConfirm,
    required this.fieldDecoration,
    this.signupNamesSideBySide = false,
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
  });

  final TextEditingController signPrenom;
  final TextEditingController signNom;
  final TextEditingController signEmail;
  final TextEditingController signPassword;
  final TextEditingController signConfirm;
  final InputDecoration Function(String label, {Widget? suffixIcon}) fieldDecoration;
  final bool signupNamesSideBySide;
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
        primaryButtonLabel ?? l10n.accountSignupButton;
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

    Future<void> submit() async {
      final prenom = signPrenom.text.trim();
      final nom = signNom.text.trim();
      final email = signEmail.text.trim();
      final password = signPassword.text;
      final confirm = signConfirm.text;
      if (prenom.isEmpty) {
        snack(l10n.accountSignupSnackFirstNameMissing);
        return;
      }
      if (nom.isEmpty) {
        snack(l10n.accountSignupSnackLastNameMissing);
        return;
      }
      if (email.isEmpty) {
        snack(l10n.accountSignupSnackEmailMissing);
        return;
      }
      if (password.isEmpty) {
        snack(l10n.accountSignupSnackPasswordMissing);
        return;
      }
      if (password.length < 6) {
        snack(l10n.accountSignupSnackPasswordTooShort);
        return;
      }
      if (password != confirm) {
        snack(l10n.accountSignupSnackPasswordMismatch);
        return;
      }
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final syncedUser = cred.user;
        if (syncedUser == null) {
          if (!context.mounted) return;
          snackAuthFailure(StateError('Compte créé mais session introuvable.'), l10n);
          return;
        }
        await syncedUser.updateDisplayName('$prenom $nom'.trim());
        await syncedUser.reload();
        await QuestionnaireCompletionPrefs.markIncomplete(syncedUser.uid);
        if (closeImmediatelyOnSuccess) {
          await ReglageProfilePrefs.save(
            inscrit: true,
            prenom: prenom,
            nom: nom,
            email: email,
          );
          await syncPaychekUserDocument(
            syncedUser,
            firstName: prenom,
            lastName: nom,
          );
          if (!context.mounted) return;
          popBackToSettingsAfterAuth();
          unawaited(paychekMergeProfileFromFirestore(syncedUser));
          return;
        }
        await syncPaychekUserDocument(
          syncedUser,
          firstName: prenom,
          lastName: nom,
        );
        await applyLocalProfile(
          inscrit: true,
          prenom: prenom,
          nom: nom,
          email: email,
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
      final nameRow = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PaychekTerminalGlassTextField(
              label: l10n.accountFieldFirstName,
              controller: signPrenom,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.givenName],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PaychekTerminalGlassTextField(
              label: l10n.accountFieldLastName,
              controller: signNom,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.familyName],
            ),
          ),
        ],
      );

      return AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            nameRow,
            const SizedBox(height: 14),
            PaychekTerminalGlassTextField(
              label: l10n.accountFieldEmail,
              controller: signEmail,
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
              controller: signPassword,
              hintText: l10n.authTerminalHintPassword,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              prefixIcon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: 14),
            PaychekTerminalGlassTextField(
              label: l10n.accountFieldConfirmPassword,
              controller: signConfirm,
              hintText: l10n.authTerminalHintPassword,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              prefixIcon: Icons.verified_user_outlined,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: submit,
              style: _terminalPrimaryCta(),
              child: Text(
                (primaryButtonLabel ?? l10n.authTerminalCtaSignup)
                    .toUpperCase(),
                style: terminalCtaFont,
              ),
            ),
          ],
        ),
      );
    }

    final nameRow = signupNamesSideBySide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: signPrenom,
                  enabled: true,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.givenName],
                  style: inputStyle,
                  decoration: fieldDecoration(l10n.accountFieldFirstName),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: signNom,
                  enabled: true,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.familyName],
                  style: inputStyle,
                  decoration: fieldDecoration(l10n.accountFieldLastName),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: signPrenom,
                enabled: true,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.givenName],
                style: inputStyle,
                decoration: fieldDecoration(l10n.accountFieldFirstName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: signNom,
                enabled: true,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.familyName],
                style: inputStyle,
                decoration: fieldDecoration(l10n.accountFieldLastName),
              ),
            ],
          );

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          nameRow,
          const SizedBox(height: 12),
          TextField(
            controller: signEmail,
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
            controller: signPassword,
            enabled: true,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            style: inputStyle,
            decoration: fieldDecoration(l10n.accountFieldPassword),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: signConfirm,
            enabled: true,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            style: inputStyle,
            decoration: fieldDecoration(l10n.accountFieldConfirmPassword),
          ),
          const SizedBox(height: 20),
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
