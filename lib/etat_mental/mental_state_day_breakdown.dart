import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'mental_state_localized_labels.dart';
import 'mental_state_models.dart';
import 'mental_state_share_logic.dart';
import 'mental_state_storage.dart';
import 'mental_state_tokens.dart';

class MentalStateDayCriterion {
  const MentalStateDayCriterion({
    required this.label,
    required this.percent,
    this.percentColor,
  });

  final String label;
  final int percent;
  /// Couleur du % (ex. polarité émotion) ; sinon seuil 50 % vert/rouge.
  final Color? percentColor;
}

class MentalStateDaySectionBreakdown {
  const MentalStateDaySectionBreakdown({
    required this.title,
    this.blockPercent,
    required this.criteria,
  });

  final String title;
  final int? blockPercent;
  final List<MentalStateDayCriterion> criteria;
}

/// Critères et pourcentages d’un jour (décodés depuis le snapshot journalier).
class MentalStateDayBreakdown {
  const MentalStateDayBreakdown({
    required this.overallPercent,
    required this.sections,
  });

  final int overallPercent;
  final List<MentalStateDaySectionBreakdown> sections;

  static MentalStateDayBreakdown? fromSnapshot(
    Map<String, dynamic> bundle,
    AppLocalizations l,
    int overallPercent,
  ) {
    final sections = <MentalStateDaySectionBreakdown>[];

    final sleepValue = (bundle['sleepValue'] as num?)?.toDouble() ?? 0;
    final sleepInverse = bundle['sleepInverse'] as bool? ?? false;
    final sleepNorm =
        (sleepInverse ? (100 - sleepValue) : sleepValue).round().clamp(0, 100);
    sections.add(
      MentalStateDaySectionBreakdown(
        title: l.mentalRestTitle,
        blockPercent: sleepNorm,
        criteria: [
          MentalStateDayCriterion(
            label: l.mentalSleepEnough,
            percent: sleepNorm,
          ),
        ],
      ),
    );

    final factors = _decodeMetrics(bundle['factors']);
    if (factors.isNotEmpty) {
      final share100 = bundle['factorsShare100'] as bool? ?? true;
      final block = _blockScore(factors, share100).round().clamp(0, 100);
      sections.add(
        MentalStateDaySectionBreakdown(
          title: l.mentalSectionRoutinesHeading,
          blockPercent: block,
          criteria: [
            for (final f in factors)
              MentalStateDayCriterion(
                label: mentalStateMetricDisplayLabel(l, f.id, f.label),
                percent: f.normalizedForScore().round().clamp(0, 100),
              ),
          ],
        ),
      );
    }

    final moment = _decodeMetrics(bundle['moment']);
    if (moment.isNotEmpty) {
      final share100 = bundle['momentShare100'] as bool? ?? true;
      final block = _blockScore(moment, share100).round().clamp(0, 100);
      sections.add(
        MentalStateDaySectionBreakdown(
          title: l.mentalSectionMomentHeading,
          blockPercent: block,
          criteria: [
            for (final m in moment)
              MentalStateDayCriterion(
                label: mentalStateMetricDisplayLabel(l, m.id, m.label),
                percent: m.normalizedForScore().round().clamp(0, 100),
              ),
          ],
        ),
      );
    }

    final selected = _selectedEmotionsForDay(bundle);
    if (selected.isNotEmpty) {
        final blockImpact = ((bundle['emotionBlockWeight'] as num?)?.toDouble() ?? 0)
            .round()
            .clamp(0, 100);
        sections.add(
          MentalStateDaySectionBreakdown(
            title: l.mentalSectionEmotionHeading,
            blockPercent: blockImpact,
            criteria: [
              for (final e in selected)
                MentalStateDayCriterion(
                  label: mentalStateEmotionDisplayLabel(l, e.id, e.label),
                  percent: MentalStateShareLogic.emotionChipImpactPercent(
                    emotion: e,
                  ),
                  percentColor: e.inverse
                      ? MentalStateTokens.matteRed
                      : MentalStateTokens.matteGreen,
                ),
            ],
          ),
        );
    }

    if (sections.isEmpty) return null;
    return MentalStateDayBreakdown(
      overallPercent: overallPercent,
      sections: sections,
    );
  }

  static List<MentalStateMetric> _decodeMetrics(Object? raw) {
    if (raw is! List) return const [];
    final out = <MentalStateMetric>[];
    for (final e in raw) {
      final m = MentalStateStorage.decodeMetric(e);
      if (m != null) out.add(m);
    }
    return out;
  }

  static List<MentalStateEmotion> _decodeEmotions(Object? raw) {
    if (raw is! List) return const [];
    final out = <MentalStateEmotion>[];
    for (final e in raw) {
      final x = MentalStateStorage.decodeEmotion(e);
      if (x != null) out.add(x);
    }
    return out;
  }

  static List<MentalStateEmotion> _selectedEmotionsForDay(
    Map<String, dynamic> bundle,
  ) {
    final frozen =
        MentalStateStorage.decodeEmotionsList(bundle['selectedEmotionsSnapshot']);
    if (frozen.isNotEmpty) return frozen;

    final emotions = _decodeEmotions(bundle['emotions']);
    final selectedIds = _selectedEmotionIds(bundle);
    return [
      for (final e in emotions)
        if (selectedIds.contains(e.id)) e,
    ];
  }

  static Set<String> _selectedEmotionIds(Map<String, dynamic> bundle) {
    final sel = bundle['selectedEmotionIds'];
    if (sel is List) {
      return sel
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toSet();
    }
    final sei = (bundle['selectedEmotionIndex'] as num?)?.toInt();
    final emotions = _decodeEmotions(bundle['emotions']);
    if (sei != null && sei >= 0 && sei < emotions.length) {
      return {emotions[sei].id};
    }
    return const {};
  }

  static double _blockScore(List<MentalStateMetric> items, bool share100) {
    if (items.isEmpty) return 0;
    if (share100) {
      var num = 0.0;
      var den = 0.0;
      for (final f in items) {
        num += f.normalizedForScore() * f.weight;
        den += f.weight;
      }
      return den > 0 ? num / den : 0;
    }
    var s = 0.0;
    for (final f in items) {
      s += (f.weight / 100.0) * f.normalizedForScore();
    }
    return s / items.length;
  }

}
