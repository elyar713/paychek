import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../web/paychek_web_tokens.dart';
import 'gold_upgrade/gold_upgrade_embed.dart';
import 'subscription_launch_helper.dart';

/// Paywall **marketing** (maquette HTML Gold) — tap volontaire « Upgrade ».
///
/// Le blocage **Lite** après essai utilise toujours [TrialPaywallOverlay] (prompt classique).
/// Le checkout est déclenché par le bouton **Subscribe now** dans le HTML (canal JS / postMessage).
Future<void> showPaychekGoldUpgradeSheet({required BuildContext context}) {
  final height = MediaQuery.sizeOf(context).height * 0.92;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      Future<void> runSubscribe() async {
        final l10n = AppLocalizations.of(sheetContext)!;
        final ok = await openPaychekSubscriptionFlow();
        if (!sheetContext.mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(sheetContext).showSnackBar(
            SnackBar(
              content: Text(l10n.paywallStoreNotConfigured),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF2A2A2A),
            ),
          );
          return;
        }
        Navigator.pop(sheetContext);
      }

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: ColoredBox(
            color: const Color(0xFF050505),
            child: SizedBox(
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              AppLocalizations.of(sheetContext)!
                                  .profileUpgradeLabel
                                  .toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.15,
                                color: PaychekWebTokens.upgradeAmber,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: buildGoldUpgradeEmbed(
                      sheetContext,
                      onSubscribe: runSubscribe,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
