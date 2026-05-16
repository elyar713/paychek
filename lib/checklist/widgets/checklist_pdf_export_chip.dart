import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dashboard/dashboard_tokens.dart';
import '../../l10n/app_localizations.dart';

/// Même principe que Performance / Stratégie / Calculatrice.
class ChecklistPdfExportChip extends StatelessWidget {
  const ChecklistPdfExportChip({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  static const Color _kAccent = Color(0xFF1EB48A);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Tooltip(
      message: l.tradeExportPdfTooltip,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF0F2620),
          border: Border.all(color: _kAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _kAccent.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            splashColor: _kAccent.withValues(alpha: 0.28),
            highlightColor: _kAccent.withValues(alpha: 0.14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 23,
                    color: _kAccent,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'PDF',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: DashboardTokens.onMatteEmphasis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
