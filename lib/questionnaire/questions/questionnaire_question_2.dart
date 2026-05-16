import 'package:flutter/material.dart';

import '../questionnaire_question_content.dart';
import '../widgets/questionnaire_option_card.dart';

/// Question 2 — Profil d’expérience.
const questionnaireQuestion2 = QuestionnaireQuestionContent(
  title: 'Profil d\'Expérience',
  slogan: 'Où en es-tu dans ton parcours ?',
  options: [
    QuestionnaireOptionData(
      icon: Icons.psychology_outlined,
      title: 'Je n\'ai pas de stratégie',
      subtitle: 'Tu n\'es pas seul',
      subtitle2: 'Pour les traders qui débutent et cherchent encore leur méthode',
    ),
    QuestionnaireOptionData(
      icon: Icons.route_outlined,
      title: 'J\'ai ma stratégie',
      subtitle: 'La lumière au bout du tunnel',
      subtitle2: 'Pour ceux qui ont les bases mais cherchent la régularité',
    ),
    QuestionnaireOptionData(
      icon: Icons.workspace_premium_outlined,
      title: 'Performant',
      subtitle: 'Le plus dur est derrière toi',
      subtitle2: 'Pour les traders expérimentés qui maîtrisent leur statistique',
    ),
  ],
);
