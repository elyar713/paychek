import 'package:flutter/material.dart';

import '../questionnaire_question_content.dart';
import '../widgets/questionnaire_option_card.dart';

/// Question 3 — Amélioration prioritaire.
const questionnaireQuestion3 = QuestionnaireQuestionContent(
  title: 'Que veux-tu améliorer ?',
  slogan: 'Choisis ton objectif prioritaire',
  options: [
    QuestionnaireOptionData(
      icon: Icons.swap_vert,
      title: 'SORTIR DES MONTAGNES RUSSES',
      subtitle: 'Arrêter de gagner un jour pour tout perdre le lendemain.',
      subtitle2:
          'Pour stabiliser sa courbe de capital et éviter l\'ascenseur émotionnel.',
    ),
    QuestionnaireOptionData(
      icon: Icons.gps_fixed,
      title: 'DEVENIR UN SNIPER',
      subtitle:
          'Améliorer mon taux de réussite et la précision de mes entrées.',
      subtitle2:
          'Pour ceux qui veulent gagner plus souvent en sélectionnant mieux leurs trades.',
    ),
    QuestionnaireOptionData(
      icon: Icons.self_improvement,
      title: 'RESTER DE MARBRE',
      subtitle:
          'Maîtriser ma discipline et stopper les décisions sous le coup de l\'émotion.',
      subtitle2:
          'Pour éliminer le trading impulsif et respecter son plan à 100%.',
    ),
    QuestionnaireOptionData(
      icon: Icons.auto_awesome_outlined,
      title: 'TROUVER MA SIGNATURE',
      subtitle:
          'Comprendre les schémas graphiques qui fonctionnent réellement pour moi.',
      subtitle2:
          'Pour identifier ses propres modèles de réussite et devenir un spécialiste.',
    ),
  ],
);
