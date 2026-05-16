import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../questionnaire_scoring.dart';

/// Trois lignes Â« Statistique Â» : point + texte (global %, profil %, citation).
class QuestionnaireResultStatsBlock extends StatelessWidget {
  const QuestionnaireResultStatsBlock({
    super.key,
    required this.scores,
    required this.l10n,
  });

  final QuestionnaireScoreResult scores;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final g = scores.statisticGlobalPercent;
    final p = scores.statisticProfilPercent;
    final base = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Colors.white60,
          fontWeight: FontWeight.w300,
          height: 1.45,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BulletLine(
          text: l10n.resultStatBullet1(g),
          style: base,
        ),
        const SizedBox(height: 12),
        _BulletLine(
          text: l10n.resultStatBullet2(p),
          style: base,
        ),
        const SizedBox(height: 12),
        _BulletLine(
          text: l10n.resultStatBullet3,
          style: base,
        ),
      ],
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white54,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}



