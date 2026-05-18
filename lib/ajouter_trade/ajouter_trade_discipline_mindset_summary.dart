import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../checklist/checklist_progress_ring.dart';
import '../etat_mental/mental_state_tokens.dart';
import '../etat_mental/widgets/mental_state_overall_gauge.dart';
import '../l10n/app_localizations.dart';
import '../web/paychek_web_tokens.dart';

/// Deux anneaux (checklist + état mental) pour le jour d'entrée du trade.
class AjouterTradeDisciplineMindsetSummary extends StatelessWidget {
  const AjouterTradeDisciplineMindsetSummary({
    super.key,
    required this.checklistPercent,
    required this.mentalScore,
    required this.sectionHeaderColor,
  });

  final int checklistPercent;
  final double mentalScore;
  final Color sectionHeaderColor;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final captionStyle = GoogleFonts.plusJakartaSans(
      fontSize: 9,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.35,
      color: sectionHeaderColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _RingColumn(
                caption: l.dashboardChecklistHeading.toUpperCase(),
                captionStyle: captionStyle,
                child: ChecklistProgressRing(
                  percent: checklistPercent,
                  size: 56,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _RingColumn(
                caption: l.ajouterTradeSectionEtatMoment,
                captionStyle: captionStyle,
                child: _EtatMentalMiniRing(
                  score: mentalScore,
                  strokeColor: _mentalStroke(mentalScore),
                  centerColor: _mentalCenterText(mentalScore),
                  bottomLabel: l.mentalGaugeStateLabel,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _mentalStroke(double score) {
    if (score >= 70) {
      return kIsWeb ? PaychekWebTokens.accentEmerald : MentalStateTokens.matteGreen;
    }
    if (score >= 45) return Colors.white;
    return MentalStateTokens.matteRed;
  }

  Color _mentalCenterText(double score) {
    if (score >= 70) return Colors.white;
    if (score >= 45) return Colors.white;
    return MentalStateTokens.matteRed;
  }
}

class _RingColumn extends StatelessWidget {
  const _RingColumn({
    required this.caption,
    required this.captionStyle,
    required this.child,
  });

  final String caption;
  final TextStyle captionStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(alignment: Alignment.center, child: child),
        const SizedBox(height: 8),
        Text(
          caption,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: captionStyle,
        ),
      ],
    );
  }
}

class _EtatMentalMiniRing extends StatelessWidget {
  const _EtatMentalMiniRing({
    required this.score,
    required this.strokeColor,
    required this.centerColor,
    required this.bottomLabel,
  });

  final double score;
  final Color strokeColor;
  final Color centerColor;
  final String bottomLabel;

  static const _size = 56.0;

  @override
  Widget build(BuildContext context) {
    final p = (score / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(_size),
            painter: MentalStateOverallGaugePainter(
              progress: p,
              strokeColor: strokeColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.round()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: centerColor,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                bottomLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF666666),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
