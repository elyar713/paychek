import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard_tokens.dart';
import '../../l10n/app_localizations.dart';

/// Pastille **Pro** (or) ou **Lite** à côté du nom sur l’accueil.
class DashboardPlanChip extends StatelessWidget {
  const DashboardPlanChip({super.key, required this.isPro});

  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isPro) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 17,
            color: DashboardTokens.proBadgeGold,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.profileAccountStatusPro,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: DashboardTokens.proBadgeGold,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          size: 15,
          color: DashboardTokens.labelGrey,
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: DashboardTokens.cardBoxBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: DashboardTokens.cardBoxBorder),
          ),
          child: Text(
            l10n.profileAccountStatusLite,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: DashboardTokens.labelGrey,
            ),
          ),
        ),
      ],
    );
  }
}
