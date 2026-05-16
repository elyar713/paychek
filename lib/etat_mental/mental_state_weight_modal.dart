import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import 'mental_state_tokens.dart';

const double _kModalGapSliderToFooter = 32;

/// Dialog partagÃ© page Ã‰tat mental + embed Dashboard (ajustement impact / polaritÃ©).
Future<void> showMentalWeightModal(
  BuildContext context, {
  required bool showPolarity,
  bool showImpactSlider = true,
  String impactSliderLabel = '',
  required double initialWeight,
  required bool initialInverse,
  required void Function(double weight, bool inverse) onApply,
  VoidCallback? onCancelRestore,
}) async {
  double w = initialWeight.clamp(0, 100);
  bool inverse = initialInverse;
  final snapW = w;
  final snapInv = inverse;

  void cancelModal() {
    if (onCancelRestore != null) {
      onCancelRestore();
    } else {
      onApply(snapW, snapInv);
    }
  }

  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModal) {
          final l = AppLocalizations.of(context)!;
          final pct = w.round().clamp(0, 100);
          final impactRowLabel =
              impactSliderLabel.isNotEmpty ? impactSliderLabel : l.mentalWeightGlobalImpact;
          final polarityHelp = inverse
              ? l.mentalWeightPolarityHelpNegative
              : l.mentalWeightPolarityHelpPositive;

          return Dialog(
            backgroundColor: const Color(0xFF0a0a0a),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF222222)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.settings, size: 16, color: Color(0xFF666666)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              l.mentalWeightModalTitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: '',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                          icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF555555)),
                          onPressed: () {
                            cancelModal();
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.mentalWeightModalBlurb,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF888888),
                        height: 1.4,
                      ),
                    ),
                    if (showPolarity) ...[
                      const SizedBox(height: 16),
                      Text(
                        l.mentalWeightNatureLabel,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF222222)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: inverse ? const Color(0xFF111111) : MentalStateTokens.matteGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: inverse ? const Color(0xFF333333) : MentalStateTokens.matteGreen,
                                    width: 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => setModal(() {
                                    inverse = false;
                                    onApply(w, inverse);
                                  }),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                      child: Text(
                                        l.mentalPositive,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: inverse ? const Color(0xFF666666) : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Material(
                                color: inverse ? MentalStateTokens.matteRed : const Color(0xFF111111),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: inverse ? MentalStateTokens.matteRed : const Color(0xFF333333),
                                    width: 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => setModal(() {
                                    inverse = true;
                                    onApply(w, inverse);
                                  }),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                      child: Text(
                                        l.mentalNegative,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: inverse ? Colors.black : const Color(0xFF666666),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        polarityHelp,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF888888),
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (showImpactSlider) ...[
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              impactRowLabel,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: MentalStateTokens.matteGreen),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          activeTrackColor: const Color(0xFF333333),
                          inactiveTrackColor: MentalStateTokens.trackBg,
                          thumbColor: MentalStateTokens.modalSliderThumbBlue,
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: w.clamp(0, 100),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          onChanged: (v) => setModal(() {
                            w = v;
                            onApply(w, inverse);
                          }),
                        ),
                      ),
                      const SizedBox(height: _kModalGapSliderToFooter),
                    ] else if (showPolarity)
                      const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              cancelModal();
                              Navigator.pop(ctx);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF888888),
                              side: const BorderSide(color: Color(0xFF333333)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(l.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l.confirm),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}



