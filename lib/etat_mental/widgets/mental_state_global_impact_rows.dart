import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../mental_state_controller.dart';

/// Lignes « Impact : …% » + ⚙️ (synchronisées par le [ListenableBuilder] parent de la page).
class MentalStateRoutinesGlobalImpactRow extends StatelessWidget {
  const MentalStateRoutinesGlobalImpactRow({
    super.key,
    required this.controller,
    required this.onOpenModal,
  });

  final MentalStateController controller;
  final VoidCallback onOpenModal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pct = controller.weightPercent(controller.routinesGlobalWeight);
    const impactGray = Color(0xFF666666);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: onOpenModal,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  l.mentalSleepImpact(pct),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: impactGray,
                    height: 1.15,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onOpenModal,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  LucideIcons.settings,
                  size: 12,
                  color: impactGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MentalStateMomentBlockImpactRow extends StatelessWidget {
  const MentalStateMomentBlockImpactRow({
    super.key,
    required this.controller,
    required this.onOpenModal,
  });

  final MentalStateController controller;
  final VoidCallback onOpenModal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pct = controller.weightPercent(controller.momentBlockWeight);
    const impactGray = Color(0xFF666666);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: onOpenModal,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  l.mentalSleepImpact(pct),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: impactGray,
                    height: 1.15,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onOpenModal,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  LucideIcons.settings,
                  size: 12,
                  color: impactGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MentalStateEmotionBlockImpactRow extends StatelessWidget {
  const MentalStateEmotionBlockImpactRow({
    super.key,
    required this.controller,
    required this.onOpenModal,
  });

  final MentalStateController controller;
  final VoidCallback onOpenModal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pct = controller.weightPercent(controller.emotionBlockWeight);
    const impactGray = Color(0xFF666666);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: onOpenModal,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  l.mentalSleepImpact(pct),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: impactGray,
                    height: 1.15,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onOpenModal,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  LucideIcons.settings,
                  size: 12,
                  color: impactGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
