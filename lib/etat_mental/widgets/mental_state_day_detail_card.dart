import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../mental_state_controller.dart';
import '../mental_state_day_breakdown.dart';
import '../mental_state_tokens.dart';
import 'mental_state_overall_gauge.dart';

Color _detailPercentColor(int percent) {
  if (percent > 50) return MentalStateTokens.matteGreen;
  if (percent < 50) return MentalStateTokens.matteRed;
  return const Color(0xFFE5E5E5);
}

/// Carte critères du jour — même structure / scroll que [ChecklistDailyUncheckedCard].
class MentalStateDayDetailCard extends StatelessWidget {
  const MentalStateDayDetailCard({
    super.key,
    required this.controller,
    required this.selectedDay,
  });

  final MentalStateController controller;
  final DateTime selectedDay;

  static const double criteriaScrollMaxHeight = 220;

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  String _formatDayHeader(DateTime day) {
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${p2(day.day)}/${p2(day.month)}/${day.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final titleStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF9CA3AF),
      letterSpacing: 1.2,
      decoration: TextDecoration.none,
    );

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final day = _dateOnly(selectedDay);
        final breakdown = controller.dayBreakdownFor(day, l);
        final overall = controller.overallScoreForCalendarDay(day);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: MentalStateTokens.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MentalStateTokens.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.clipboardList,
                      size: 15,
                      color: Color(0xFF8A8A8A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.mentalDayDetailTitle,
                        style: titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatDayHeader(day)} · ${controller.mentalDayWindowLabel()}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B6B6B),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                if (breakdown == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l.mentalDayDetailNoData,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7A7A7A),
                        height: 1.35,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  )
                else ...[
                  _DayDetailGlobalScoreRow(
                    label: l.mentalDayDetailGlobalScore,
                    percent: overall?.round() ?? breakdown.overallPercent,
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: criteriaScrollMaxHeight,
                    ),
                    child: _CriteriaScrollArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var s = 0; s < breakdown.sections.length; s++)
                            ...[
                              if (s > 0) const SizedBox(height: 12),
                              _SectionBlock(section: breakdown.sections[s]),
                            ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Scroll isolé (évite le [PrimaryScrollController] de la page parente sur web).
class _DayDetailGlobalScoreRow extends StatelessWidget {
  const _DayDetailGlobalScoreRow({
    required this.label,
    required this.percent,
  });

  final String label;
  final int percent;

  static const _ringSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final color = _detailPercentColor(percent);
    final progress = (percent / 100).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: const Color(0xFF6B6B6B),
              decoration: TextDecoration.none,
            ),
          ),
        ),
        SizedBox(
          width: _ringSize,
          height: _ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(_ringSize),
                painter: MentalStateOverallGaugePainter(
                  progress: progress,
                  strokeColor: color,
                ),
              ),
              Text(
                '$percent%',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CriteriaScrollArea extends StatelessWidget {
  const _CriteriaScrollArea({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: SingleChildScrollView(
        primary: false,
        physics: const ClampingScrollPhysics(),
        child: child,
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});

  final MentalStateDaySectionBreakdown section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          children: [
            Text(
              section.title,
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: const Color(0xFF7A7A7A),
                decoration: TextDecoration.none,
              ),
            ),
            if (section.blockPercent != null)
              Text(
                '${section.blockPercent}%',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFF8A8A8A),
                  decoration: TextDecoration.none,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < section.criteria.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          _CriterionRow(criterion: section.criteria[i]),
        ],
      ],
    );
  }
}

class _CriterionRow extends StatelessWidget {
  const _CriterionRow({required this.criterion});

  final MentalStateDayCriterion criterion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '· ',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5C5C5C),
              decoration: TextDecoration.none,
            ),
          ),
          Expanded(
            child: Text(
              criterion.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB0B0B0),
                height: 1.3,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${criterion.percent}%',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: criterion.percentColor ??
                  _detailPercentColor(criterion.percent),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
