import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import 'gold_upgrade/gold_upgrade_embed.dart';
import 'paychek_billing_plan.dart';
import 'subscription_launch_helper.dart';

/// Paywall **marketing** — mobile : maquette or ; web : feuille + legacy.
Future<void> showPaychekGoldUpgradeSheet({required BuildContext context}) {
  final height = MediaQuery.sizeOf(context).height * 0.92;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      Future<void> runSubscribe(PaychekBillingCycle cycle) async {
        final l10n = AppLocalizations.of(sheetContext)!;
        final ok = await openPaychekSubscriptionFlow(cycle: cycle);
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

      final mobile = !kIsWeb;

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: ColoredBox(
            color: mobile ? const Color(0xFF020205) : const Color(0xFF050505),
            child: SizedBox(
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!mobile)
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
                                  color: const Color(0xFFEAB308),
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
                      onClose: mobile
                          ? () => Navigator.pop(sheetContext)
                          : null,
                      showTopClose: mobile,
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
