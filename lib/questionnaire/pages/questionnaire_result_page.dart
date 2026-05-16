import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';
import '../questionnaire_scoring.dart';
import 'questionnaire_circle_progress.dart';
import 'questionnaire_linear_stat_bar.dart';
import 'questionnaire_result_header.dart';
import 'questionnaire_result_statistic_line.dart';

/// RÃ©sultat du questionnaire : cercles, barres, statistiques.
/// Navigation via les flÃ¨ches du flux.
class QuestionnaireResultPage extends StatelessWidget {
  const QuestionnaireResultPage({
    super.key,
    required this.scores,
  });

  final QuestionnaireScoreResult scores;

  static const Color _bg = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    final s = scores;
    final l10n = AppLocalizations.of(context)!;

    final mq = MediaQuery.sizeOf(context);
    final isWideWeb = kIsWeb && mq.width >= 900;
    final contentMaxWidth = isWideWeb ? 720.0 : double.infinity;

    final effectiveWidth = isWideWeb ? contentMaxWidth : mq.width;
    final rowW = effectiveWidth - 48;
    final ringSize = (rowW / 2 - 12).clamp(88.0, isWideWeb ? 104.0 : 118.0);

    return ColoredBox(
      color: _bg,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(isWideWeb ? 20 : 24, 8, isWideWeb ? 20 : 24, isWideWeb ? 20 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const QuestionnaireResultHeader(),
                SizedBox(height: isWideWeb ? 18 : 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    QuestionnaireCircleProgress(
                      percentage: s.globalPercent,
                      label: l10n.resultLabelGlobal,
                      progressColor: Colors.white,
                      size: ringSize,
                    ),
                    QuestionnaireCircleProgress(
                      percentage: s.profilPercent,
                      label: l10n.resultLabelProfil,
                      progressColor: Colors.white,
                      size: ringSize,
                    ),
                  ],
                ),
                SizedBox(height: isWideWeb ? 24 : 32),
                QuestionnaireLinearStatBar.strategy(
                  title: l10n.resultLabelStrategy,
                  note: '${s.strategieSur10Inverted}/10',
                  value: s.strategieInverted01,
                ),
                SizedBox(height: isWideWeb ? 16 : 22),
                QuestionnaireLinearStatBar.psychology(
                  title: l10n.resultLabelPsychology,
                  note: '${s.psychologieSur10Inverted}/10',
                  value: s.psychologieInverted01,
                ),
                SizedBox(height: isWideWeb ? 20 : 28),
                QuestionnaireResultStatsBlock(scores: s, l10n: l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



