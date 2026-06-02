import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'journal_demo_notice_prefs.dart';

/// Boîte d’avertissement : les données démo disparaissent au premier trade enregistré.
Future<void> showJournalDemoNoticeDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: DashboardTokens.cardBoxBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: DashboardTokens.cardBoxBorder),
        ),
        icon: Icon(
          Icons.info_outline_rounded,
          color: DashboardTokens.titleGold.withValues(alpha: 0.9),
          size: 28,
        ),
        title: Text(
          l10n.journalDemoNoticeTitle,
          style: const TextStyle(
            color: DashboardTokens.onMatteEmphasis,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            height: 1.25,
          ),
        ),
        content: Text(
          l10n.journalDemoNoticeBody,
          style: const TextStyle(
            color: DashboardTokens.labelGrey,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: DashboardTokens.titleGold,
              foregroundColor: Colors.black,
            ),
            child: Text(l10n.journalDemoNoticeButton),
          ),
        ],
      );
    },
  );
}

/// Affiche l’avertissement une fois après inscription, à l’entrée dans l’app.
Future<void> showJournalDemoNoticeAfterSignupIfNeeded(BuildContext context) async {
  final uid = (FirebaseAuth.instance.currentUser?.uid ?? '').trim();
  if (uid.isEmpty) return;
  if (!await JournalDemoNoticePrefs.consumePending(uid)) return;
  if (!context.mounted) return;
  await showJournalDemoNoticeDialog(context);
}
