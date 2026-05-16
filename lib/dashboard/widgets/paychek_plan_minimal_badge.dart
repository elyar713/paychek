import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../web/paychek_web_tokens.dart';

/// Pastille Pro / Lite alignée sur l’accueil dashboard (point + libellé caps, or / émeraude).
///
/// S’adapte aux largeurs très faibles (ligne du hero avec [Flexible]) via [FittedBox.scaleDown].
class PaychekPlanMinimalBadge extends StatelessWidget {
  const PaychekPlanMinimalBadge({super.key, required this.isPro});

  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final accent =
        isPro ? PaychekWebTokens.upgradeAmber : PaychekWebTokens.accentEmerald;
    final label =
        (isPro ? l.profileAccountStatusPro : l.profileAccountStatusLite)
            .toUpperCase();
    final bgAlpha = isPro ? 0.06 : 0.05;
    final borderAlpha = isPro ? 0.22 : 0.2;
    final shadowAlpha = isPro ? 0.65 : 0.55;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: borderAlpha)),
      ),
      clipBehavior: Clip.antiAlias,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: shadowAlpha),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
