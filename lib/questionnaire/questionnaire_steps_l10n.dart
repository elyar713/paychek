import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'questionnaire_question_content.dart';
import 'widgets/questionnaire_option_card.dart';

/// Contenu des 4 questions â€” textes depuis [AppLocalizations].
List<QuestionnaireQuestionContent> questionnaireStepsFromL10n(
  AppLocalizations l10n,
) {
  return [
    QuestionnaireQuestionContent(
      title: l10n.q1Title,
      slogan: l10n.q1Slogan,
      useMPlus2ForSlogan: true,
      options: [
        QuestionnaireOptionData(
          icon: Icons.bolt_outlined,
          title: l10n.q1o1t,
          subtitle: l10n.q1o1s,
          mPlus2Slogan1: true,
        ),
        QuestionnaireOptionData(
          icon: Icons.wb_sunny_outlined,
          title: l10n.q1o2t,
          subtitle: l10n.q1o2s,
          mPlus2Slogan1: true,
        ),
        QuestionnaireOptionData(
          icon: Icons.view_day_outlined,
          title: l10n.q1o3t,
          subtitle: l10n.q1o3s,
          halfSunIcon: true,
          mPlus2Slogan1: true,
        ),
        QuestionnaireOptionData(
          icon: Icons.terrain,
          title: l10n.q1o4t,
          subtitle: l10n.q1o4s,
          mPlus2Slogan1: true,
        ),
      ],
    ),
    QuestionnaireQuestionContent(
      title: l10n.q2Title,
      slogan: l10n.q2Slogan,
      options: [
        QuestionnaireOptionData(
          icon: Icons.psychology_outlined,
          title: l10n.q2o1t,
          subtitle: l10n.q2o1s,
          subtitle2: l10n.q2o1s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.route_outlined,
          title: l10n.q2o2t,
          subtitle: l10n.q2o2s,
          subtitle2: l10n.q2o2s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.workspace_premium_outlined,
          title: l10n.q2o3t,
          subtitle: l10n.q2o3s,
          subtitle2: l10n.q2o3s2,
        ),
      ],
    ),
    QuestionnaireQuestionContent(
      title: l10n.q3Title,
      slogan: l10n.q3Slogan,
      options: [
        QuestionnaireOptionData(
          icon: Icons.swap_vert,
          title: l10n.q3o1t,
          subtitle: l10n.q3o1s,
          subtitle2: l10n.q3o1s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.gps_fixed,
          title: l10n.q3o2t,
          subtitle: l10n.q3o2s,
          subtitle2: l10n.q3o2s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.self_improvement,
          title: l10n.q3o3t,
          subtitle: l10n.q3o3s,
          subtitle2: l10n.q3o3s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.auto_awesome_outlined,
          title: l10n.q3o4t,
          subtitle: l10n.q3o4s,
          subtitle2: l10n.q3o4s2,
        ),
      ],
    ),
    QuestionnaireQuestionContent(
      title: l10n.q4Title,
      slogan: l10n.q4Slogan,
      multiSelect: true,
      options: [
        QuestionnaireOptionData(
          icon: Icons.notifications_active_outlined,
          title: l10n.q4o1t,
          subtitle: l10n.q4o1s,
          subtitle2: l10n.q4o1s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.whatshot_outlined,
          title: l10n.q4o2t,
          subtitle: l10n.q4o2s,
          subtitle2: l10n.q4o2s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.visibility_off_outlined,
          title: l10n.q4o3t,
          subtitle: l10n.q4o3s,
          subtitle2: l10n.q4o3s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.touch_app_outlined,
          title: l10n.q4o4t,
          subtitle: l10n.q4o4s,
          subtitle2: l10n.q4o4s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.emoji_events_outlined,
          title: l10n.q4o5t,
          subtitle: l10n.q4o5s,
          subtitle2: l10n.q4o5s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.pause_circle_outline,
          title: l10n.q4o6t,
          subtitle: l10n.q4o6s,
          subtitle2: l10n.q4o6s2,
        ),
        QuestionnaireOptionData(
          icon: Icons.casino_outlined,
          title: l10n.q4o7t,
          subtitle: l10n.q4o7s,
          subtitle2: l10n.q4o7s2,
        ),
      ],
    ),
  ];
}



