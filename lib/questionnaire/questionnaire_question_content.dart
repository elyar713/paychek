import 'widgets/questionnaire_option_card.dart';

/// Contenu d’une étape du questionnaire (titre, slogan, cartes).
class QuestionnaireQuestionContent {
  const QuestionnaireQuestionContent({
    required this.title,
    this.slogan,
    required this.options,
    this.useMPlus2ForSlogan = false,
    this.multiSelect = false,
  });

  final String title;
  final String? slogan;
  final List<QuestionnaireOptionData> options;
  final bool useMPlus2ForSlogan;
  /// Plusieurs cartes sélectionnables (ex. défis).
  final bool multiSelect;
}
