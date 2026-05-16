import 'package:flutter/material.dart';

import '../questionnaire_question_content.dart';
import '../widgets/questionnaire_option_card.dart';

/// Question 4 — Défis (sélection multiple).
const questionnaireQuestion4 = QuestionnaireQuestionContent(
  title: 'Quel est ton plus grand défi ?',
  slogan: 'Identifie ce qui te bloque le plus',
  multiSelect: true,
  options: [
    QuestionnaireOptionData(
      icon: Icons.notifications_active_outlined,
      title: 'FOMO',
      subtitle: 'Peur de rater quelque chose.',
      subtitle2: 'Vite, je vais rater l\'occasion de gagner !',
    ),
    QuestionnaireOptionData(
      icon: Icons.whatshot_outlined,
      title: 'TILT',
      subtitle: 'Ton cœur a remplacé ton cerveau.',
      subtitle2: 'C\'est pas possible, je DOIS récupérer mon argent !',
    ),
    QuestionnaireOptionData(
      icon: Icons.visibility_off_outlined,
      title: 'TRADER À L\'AVEUGLETTE',
      subtitle: 'Pas de stratégie claire ni de plan.',
      subtitle2: 'Je ne sais pas trop, mais je le sens bien… on tente le coup.',
    ),
    QuestionnaireOptionData(
      icon: Icons.touch_app_outlined,
      title: 'OVERTRADING',
      subtitle: 'L\'agitation permanente.',
      subtitle2: 'Si je ne clique pas, j\'ai l\'impression de ne pas travailler.',
    ),
    QuestionnaireOptionData(
      icon: Icons.emoji_events_outlined,
      title: 'EXCÈS DE CONFIANCE',
      subtitle: 'Se croire invincible.',
      subtitle2: 'Je suis trop fort, c\'est de l\'argent facile ! Je mise le double.',
    ),
    QuestionnaireOptionData(
      icon: Icons.pause_circle_outline,
      title: 'LA PARALYSIE',
      subtitle: 'Peur de tout.',
      subtitle2: 'Je ne suis pas sûr, j\'ai peur de perdre encore.',
    ),
    QuestionnaireOptionData(
      icon: Icons.casino_outlined,
      title: 'SANS MONEY MANAGEMENT',
      subtitle: 'Jouer à la roulette russe.',
      subtitle2: 'Je mets tout sur ce trade, ça passe ou ça casse !',
    ),
  ],
);
