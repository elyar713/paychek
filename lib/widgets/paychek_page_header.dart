import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';

/// En-tête aligné sur Strategy / Performance : colonne centrée, largeur max, retour optionnel.
class PaychekPageHeader extends StatelessWidget {
  const PaychekPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.trailing,
    this.maxContentWidth = 1180,
    this.subtitleMaxLines,
    /// Si `true` et sans [onBack], réserve une largeur équivalente au bouton retour pour aligner le titre.
    this.reserveLeadingWidthWhenNoBack = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double maxContentWidth;
  final int? subtitleMaxLines;
  final bool reserveLeadingWidthWhenNoBack;

  static const double _kBreakpoint = 920;

  static double horizontalPad(double width) => width >= _kBreakpoint ? 24.0 : 20.0;

  /// Overlay shell ([onCloseInShell]) ou [Navigator.maybePop] si une route est empilée.
  static VoidCallback? resolveBack(
    BuildContext context, {
    VoidCallback? onCloseInShell,
  }) {
    if (onCloseInShell != null) return onCloseInShell;
    if (Navigator.of(context).canPop()) {
      return () => Navigator.of(context).maybePop();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final hPad = horizontalPad(w);
        final innerMax = math.min(
          maxContentWidth,
          math.max(0.0, w - 2 * hPad),
        );

        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: innerMax),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onBack != null)
                      IconButton(
                        onPressed: onBack,
                        style: IconButton.styleFrom(
                          foregroundColor: const Color(0xFF555555),
                          padding: const EdgeInsets.all(10),
                          minimumSize: const Size(40, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      )
                    else if (reserveLeadingWidthWhenNoBack)
                      const SizedBox(width: 52)
                    else
                      const SizedBox.shrink(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, top: 6),
                        child: DefaultTextStyle.merge(
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                            decorationThickness: 0,
                          ),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.4,
                                color: DashboardTokens.onMatteEmphasis,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              maxLines: subtitleMaxLines,
                              overflow: subtitleMaxLines != null
                                  ? TextOverflow.ellipsis
                                  : null,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                color: const Color(0xFF888888),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
