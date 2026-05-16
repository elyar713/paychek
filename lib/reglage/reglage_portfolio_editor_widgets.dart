import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';

const Color kReglagePortfolioBrandTeal = Color(0xFF1EB48A);

InputDecoration reglagePortfolioDialogField(String label, String hint) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: GoogleFonts.plusJakartaSans(color: DashboardTokens.muted),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}

class ReglagePortfolioCurrencyChip extends StatelessWidget {
  const ReglagePortfolioCurrencyChip({
    super.key,
    required this.selected,
    required this.size,
    required this.onTap,
    required this.topText,
    required this.bottomText,
    this.bottomFontSize = 13,
    this.largeTop = false,
  });

  final bool selected;
  final double size;
  final VoidCallback onTap;
  final String topText;
  final String bottomText;
  final double bottomFontSize;
  final bool largeTop;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? kReglagePortfolioBrandTeal.withValues(alpha: 0.22) : const Color(0xFF121214);
    final border = selected ? kReglagePortfolioBrandTeal : const Color(0xFF333333);
    final topSize = largeTop ? 17.0 : 9.5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: selected ? 1.5 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                topText,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: topSize,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                bottomText,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : Colors.white54,
                  fontSize: bottomFontSize,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
