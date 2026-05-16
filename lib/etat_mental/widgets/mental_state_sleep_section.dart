import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../mental_state_controller.dart';
import '../mental_state_tokens.dart';
import 'mental_state_card_title_row.dart';
import 'mental_state_value_badge.dart';

class MentalStateSleepSection extends StatelessWidget {
  const MentalStateSleepSection({
    super.key,
    required this.controller,
    required this.titleStyle,
    required this.onSleepImpactTap,
  });

  final MentalStateController controller;
  final TextStyle titleStyle;
  final Future<void> Function() onSleepImpactTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MentalStateCardTitleRow(
          left: Row(
            children: [
              const Icon(LucideIcons.moon, size: 16, color: Color(0xFF6B6B6B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.mentalRestTitle,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          right: InkWell(
            onTap: () => onSleepImpactTap(),
            borderRadius: BorderRadius.circular(8),
            child: MentalStateValueBadge(
              l.mentalSleepImpact(c.weightPercent(c.sleepWeight)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                l.mentalSleepEnough,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            MentalStateValueBadge('${c.sleepValue.round()}%'),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: c.sleepInverse ? MentalStateTokens.matteRed : MentalStateTokens.matteGreen,
            inactiveTrackColor: MentalStateTokens.trackBg,
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: c.sleepValue.clamp(0, 100),
            min: 0,
            max: 100,
            onChanged: c.updateSleepValue,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                l.mentalTired,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B6B6B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () => onSleepImpactTap(),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(
                LucideIcons.settings,
                size: 14,
                color: Color(0xFF6B6B6B),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  l.mentalPeakForm,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6B6B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
