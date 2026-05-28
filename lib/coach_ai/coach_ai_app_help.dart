import '../help_center/help_center_catalog.dart';
import '../help_center/help_center_guide_assets.dart';
import 'coach_ai_app_help_steps.dart';

/// Questions d’utilisation PAYCHEK → étapes UI locales (toute l’app) + Help Center.
abstract final class CoachAiAppHelp {
  static bool isAppHelpQuestion(String question) {
    final q = question.toLowerCase();
    if (q.isEmpty) return false;
    if (RegExp(
      r'help\s*center|comment utiliser|comment faire|où se trouve|ou se trouve|'
      r'fonctionnalit|workflow|guide|tutoriel|how to|where is|where can|'
      r'comment (modifier|changer|éditer|editer|ajouter|créer|creer|supprimer|configurer|accéder|acceder)|'
      r'(modifier|changer|éditer|editer|ajouter|créer|creer|configurer).{0,40}',
    ).hasMatch(q) &&
        RegExp(CoachAiAppHelpSteps.appFeaturePattern).hasMatch(q)) {
      return true;
    }
    if (RegExp(r'^(comment|où|ou|where|how)\b').hasMatch(q.trim()) &&
        RegExp(CoachAiAppHelpSteps.appFeaturePattern).hasMatch(q)) {
      return true;
    }
    if (RegExp(
      r"à quoi sert|a quoi sert|à sert|a sert|à quoi ca sert|a quoi ca sert|"
      r"sert à quoi|sert a quoi|c'est quoi|cest quoi|c est quoi|"
      r"what is|what does|utilité de|utilite de|role du|rôle du|"
      r"explique|expliquer|décris|decris",
    ).hasMatch(q)) {
      return RegExp(CoachAiAppHelpSteps.appFeaturePattern).hasMatch(q);
    }
    if (RegExp(r'engrenage|engrenage|⚙').hasMatch(q)) return true;
    if (RegExp(r'menu\s+plus|bouton\s+plus').hasMatch(q)) return true;
    return false;
  }

  /// Identifiant interne (priorité : cas précis → page Help Center).
  static String resolveTopicId(String question) {
    final q = question.toLowerCase();

    if (RegExp(r'engrenage|engrenage|⚙').hasMatch(q)) {
      if (RegExp(r'capital|commission|gain').hasMatch(q)) return 'capital_gear';
      if (RegExp(r'quantité|quantite|actif|lot|paire').hasMatch(q)) {
        return 'quantite_gear';
      }
      if (RegExp(r'état mental|etat mental|émotion|emotion|sommeil|poids|facteur|mental').hasMatch(q)) {
        return 'mental_state_gear';
      }
      if (RegExp(r'calendrier|objectif|mois').hasMatch(q)) {
        return 'calendar_objectives_gear';
      }
      if (RegExp(r'import|csv|relevé|releve|mt5|broker').hasMatch(q)) {
        return 'import_csv';
      }
      if (RegExp(r'feeling|principe|discipline|session').hasMatch(q)) {
        return 'discipline_gear';
      }
    }

    if (RegExp(r'\btag\b|tags psych|fomo|tilt|revenge').hasMatch(q) &&
        RegExp(r'ajouter|trade|cocher|renseigner').hasMatch(q)) {
      return 'tag_psych';
    }
    if (RegExp(r'import|csv|mt5|relevé|releve|statement').hasMatch(q)) return 'import_csv';
    if (RegExp(r'principe|feeling').hasMatch(q) && !RegExp(r'engrenage|engrenage').hasMatch(q)) {
      return 'principe_feeling';
    }

    if (RegExp(r'che?ck\s*list|checklist').hasMatch(q)) {
      if (RegExp(r'des trades?|du trade|sur (un |le )?trade|lors du trade|checklist des').hasMatch(q)) {
        return 'checklist_trade';
      }
      return 'checklist_page';
    }

    final slug = _resolveGuideSlug(q);
    return switch (slug) {
      'dashboard' => 'dashboard',
      'add_trade' => 'add_trade',
      'trade_page' => 'trade_page',
      'checklist' => 'checklist_page',
      'calendar' => 'calendar',
      'mental_state' => 'mental_state',
      'my_strategy' => 'my_strategy',
      'my_analysis' => 'my_analysis',
      'performance' => 'performance',
      'plus_menu' => 'plus_menu',
      'reglage' => 'reglage',
      'coach_ai' => 'coach_ai',
      'calculatrice' => 'plus_menu',
      _ => 'app_overview',
    };
  }

  static String? _resolveGuideSlug(String q) {
    final rules = <(RegExp, String)>[
      (RegExp(r'dashboard|tableau de bord|accueil'), 'dashboard'),
      (RegExp(r'ajouter.{0,12}trade|enregistrer.{0,12}trade|nouveau trade'), 'add_trade'),
      (RegExp(r'page trade|journal|historique trade|liste trade'), 'trade_page'),
      (RegExp(r'che?ck\s*list|checklist|tâche|tache|rappel'), 'checklist'),
      (RegExp(r'calendrier|calendar'), 'calendar'),
      (RegExp(r'état mental|etat mental|mental state'), 'mental_state'),
      (RegExp(r'strat(é|e)gie|strategie|setup|playbook'), 'my_strategy'),
      (RegExp(r'mon analyse|plan d.?analyse|analyse report'), 'my_analysis'),
      (RegExp(r'performance|scanner|kpi|stats\b'), 'performance'),
      (RegExp(r'menu\s+plus|bouton\s+plus'), 'plus_menu'),
      (RegExp(r'réglage|reglage|paramètre|parametre|settings'), 'reglage'),
      (RegExp(r'coach\s*ai|coach ai'), 'coach_ai'),
      (RegExp(r'calculatrice|calculator'), 'calculatrice'),
    ];
    for (final r in rules) {
      if (r.$1.hasMatch(q)) return r.$2;
    }
    return null;
  }

  static String? resolveGuideSlug(String question) => _resolveGuideSlug(question.toLowerCase());

  static String? localCardTitle(String question, String languageCode) {
    final topic = resolveTopicId(question);
    final fr = languageCode == 'fr';
    final custom = switch (topic) {
      'discipline_gear' => fr ? 'Réglages discipline (⚙)' : 'Discipline settings (⚙)',
      'mental_state_gear' => fr ? 'État mental · poids (⚙)' : 'Mental state · weights (⚙)',
      'capital_gear' => fr ? 'Capital & commissions (⚙)' : 'Capital & fees (⚙)',
      'quantite_gear' => fr ? 'Actifs & quantité (⚙)' : 'Assets & quantity (⚙)',
      'calendar_objectives_gear' => fr ? 'Objectifs calendrier (⚙)' : 'Calendar goals (⚙)',
      'tag_psych' => fr ? 'Tags psychologiques' : 'Psych tags',
      'import_csv' => fr ? 'Import CSV / relevé' : 'CSV / statement import',
      'principe_feeling' => fr ? 'Principe & Feeling' : 'Principle & Feeling',
      'plus_menu' => fr ? 'Menu Plus (⋯)' : 'Plus menu (⋯)',
      'coach_ai' => fr ? 'Coach AI' : 'Coach AI',
      'app_overview' => fr ? 'Navigation PAYCHEK' : 'PAYCHEK navigation',
      _ => null,
    };
    if (custom != null) return custom;
    final slug = _resolveGuideSlug(question.toLowerCase());
    if (slug == null) return null;
    return helpCenterArticles
        .where((a) => a.slug == slug)
        .map((a) => a.frenchTitle)
        .firstOrNull;
  }

  /// Toujours une liste d’étapes pour une question app_help reconnue.
  static List<String> uiStepsForQuestion(String question, String languageCode) {
    return CoachAiAppHelpSteps.forTopic(resolveTopicId(question), languageCode);
  }

  static String formatStepsAnswer(
    List<String> steps, {
    required String languageCode,
    String? title,
  }) {
    final buf = StringBuffer();
    if (title != null && title.isNotEmpty) {
      buf.writeln('$title :');
    } else {
      buf.writeln(languageCode == 'fr' ? 'Dans PAYCHEK :' : 'In PAYCHEK:');
    }
    for (var i = 0; i < steps.length; i++) {
      buf.writeln('${i + 1}. ${steps[i]}');
    }
    return buf.toString().trim();
  }

  static String _stripGuideForCoach(String raw) {
    var s = raw.replaceAll(RegExp(r'\[img:[^\]]+\]'), '');
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    s = s.trim();
    const max = 1800;
    if (s.length > max) s = '${s.substring(0, max)}…';
    return s;
  }

  static Future<Map<String, dynamic>?> guideContextForQuestion(
    String question, {
    required String languageCode,
  }) async {
    if (!isAppHelpQuestion(question)) return null;
    final topicId = resolveTopicId(question);
    final steps = uiStepsForQuestion(question, languageCode);
    final slug = _resolveGuideSlug(question.toLowerCase());
    final title = localCardTitle(question, languageCode);

    final body = slug == null
        ? null
        : await HelpCenterGuideAssets.loadArticleBody(
            slug,
            languageCode: languageCode,
          );

    return <String, dynamic>{
      'matched': topicId != 'app_overview' || slug != null,
      'topicId': topicId,
      'slug': ?slug,
      'title': ?title,
      'paychekUiSteps': steps,
      if (body != null && body.trim().isNotEmpty)
        'helpCenterExcerpt': _stripGuideForCoach(body),
      'availableTopics': <String>[
        'dashboard',
        'add_trade',
        'trade_page',
        'checklist_page',
        'mental_state',
        'my_strategy',
        'my_analysis',
        'performance',
        'calendar',
        'plus_menu',
        'reglage',
        'coach_ai',
      ],
    };
  }
}
