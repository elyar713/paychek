import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../web/paychek_web_tokens.dart';

/// CTA **Upgrade** compact — même rendu que l’accueil ([DashboardHomeHero]).
class PaychekMinimalUpgradeButton extends StatelessWidget {
  const PaychekMinimalUpgradeButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = PaychekWebTokens.upgradeAmber;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: gold.withValues(alpha: 0.15),
        highlightColor: gold.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gold.withValues(alpha: 0.1),
                gold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: gold.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upload_rounded,
                  size: 10,
                  color: gold,
                ),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: gold,
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
