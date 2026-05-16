import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';

const _kCardBlack = Color(0xFF0A0A0A);
const _kAuthDialogRadius = 40.0;

/// Confirmation après envoi du lien de réinitialisation (web landing + mobile).
Future<void> showPaychekPasswordResetSentDialog(BuildContext context) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.88),
    builder: (dialogCtx) => _PaychekPasswordResetSentDialog(dialogCtx: dialogCtx),
  );
}

class _PaychekPasswordResetSentDialog extends StatelessWidget {
  const _PaychekPasswordResetSentDialog({required this.dialogCtx});

  final BuildContext dialogCtx;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final maxCardW = math.min(440.0, mq.size.width - mq.padding.horizontal - 32);
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
        constraints: BoxConstraints(maxWidth: maxCardW),
        child: Material(
          color: _kCardBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kAuthDialogRadius),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
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
                    onPressed: () => Navigator.of(dialogCtx, rootNavigator: true).pop(),
                  ),
                ),
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.accountPasswordResetSentDialogTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.accountPasswordResetSentDialogMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white54,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogCtx, rootNavigator: true).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 52),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    l10n.accountPasswordResetSentDialogCta,
                    style: ctaFont,
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
