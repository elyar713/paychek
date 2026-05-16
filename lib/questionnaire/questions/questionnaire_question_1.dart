import 'package:flutter/material.dart';

import '../questionnaire_question_content.dart';
import '../widgets/questionnaire_option_card.dart';

/// Question 1 — Type de trader.
const questionnaireQuestion1 = QuestionnaireQuestionContent(
  title: 'Quel type de trader ?',
  slogan: 'Choisissez votre approche',
  useMPlus2ForSlogan: true,
  options: [
    QuestionnaireOptionData(
      icon: Icons.bolt_outlined,
      title: 'Scalping',
      subtitle: 'Positions de quelques secondes à quelques minutes',
      mPlus2Slogan1: true,
    ),
    QuestionnaireOptionData(
      icon: Icons.wb_sunny_outlined,
      title: 'Day trading',
      subtitle: 'Toutes les positions sont fermées avant la fin de la séance',
      mPlus2Slogan1: true,
    ),
    QuestionnaireOptionData(
      icon: Icons.view_day_outlined,
      title: 'Intraday',
      subtitle: 'Positions maintenues entre 1 et 3 jours',
      halfSunIcon: true,
      mPlus2Slogan1: true,
    ),
    QuestionnaireOptionData(
      icon: Icons.terrain,
      title: 'Swing',
      subtitle: 'Positions maintenues sur plusieurs jours ou semaines',
      mPlus2Slogan1: true,
    ),
  ],
);
