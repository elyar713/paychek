import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mental_state_tokens.dart';

class MentalStateValueBadge extends StatelessWidget {
  const MentalStateValueBadge(
    this.text, {
    super.key,
    this.compact = false,
  });

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: 2),
      decoration: BoxDecoration(
        color: MentalStateTokens.matteGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w700,
          color: MentalStateTokens.matteGreen,
        ),
      ),
    );
  }
}
