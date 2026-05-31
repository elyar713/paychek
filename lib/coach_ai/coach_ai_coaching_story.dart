import '../trade/trade_models.dart';
import 'coach_ai_query_text.dart';
import 'coach_ai_psych_analysis.dart';
import 'coach_ai_response_format.dart';

/// Récit de session / trade du jour + demande d’avis coach (pas audit discipline).
class CoachCoachingStoryFocus {
  const CoachCoachingStoryFocus({
    required this.themes,
    required this.asksOpinion,
    required this.asksHowToFix,
    this.relatedTag,
    this.todayTaggedTrades = 0,
  });

  final List<String> themes;
  final bool asksOpinion;
  final bool asksHowToFix;
  final String? relatedTag;
  final int todayTaggedTrades;
}

abstract final class CoachAiCoachingStory {
  static bool isCoachingStoryQuestion(String question) {
    final q = CoachAiQueryText.forMatching(question);

    // Récit du jour + « comment régler cette psycho » (revenge, SL, renverser…).
    if (RegExp(
      r"c.?est quoi|c quoi|quelle psycho|quel psycho|quoi comme psycho|what.{0,16}psycho|"
      r"quel(le)?\s+probl[eè]me|what.{0,12}problem",
    ).hasMatch(q)) {
      if (RegExp(
        r'trade|tp\b|take profit|gagnant|gain|perte|clotur|position|retourn|lacher|lâcher|'
        r'attendre|patience|impatien|fomo|niveau|prix|marché|marche|psycho|émotion|emotion',
      ).hasMatch(q)) {
        return q.length >= 40;
      }
    }

    if (RegExp(r"aujourd'hui|aujourdhui|today").hasMatch(q) &&
        RegExp(r'attendre|patience|impatien|niveau|fomo|trop t[oô]t|prix').hasMatch(q) &&
        RegExp(r'probl[eè]me|pourquoi|pas r[eé]ussir|n.arrive pas|difficile').hasMatch(q)) {
      return true;
    }

    if (RegExp(
      r'comment (je peux |tu peux )?(régler|regler|régle|regle|gérer|gerer|maitriser|maîtriser|éviter|eviter)',
    ).hasMatch(q)) {
      if (RegExp(
        r'psycho|pyscho|fomo|tilt|revenge|renvers|émotion|emotion|inquiétude|inquietude',
      ).hasMatch(q)) {
        if (RegExp(r"aujourd'hui|sl\b|pullback|trade|analyse|position").hasMatch(q)) {
          return true;
        }
      }
    }

    // Récit court : trades au feeling / impossible de tenir la stratégie.
    if (RegExp(
      r'feeling|au feeling|hors[\s-]?plan|impulsif|'
      r'n.?arrive pas.{0,35}(suivre|respect|tenir|appliquer)|'
      r'ne (tiens|suis) pas.{0,25}strat|pas suivi.{0,20}strat|'
      r"can.?t follow.{0,20}strateg|don.?t follow.{0,20}strateg",
    ).hasMatch(q)) {
      if (RegExp(r"j.?ai|trade|strat|setup|discipline|respect|feeling").hasMatch(q)) {
        return true;
      }
    }

    if (q.length < 70) return false;

    var signals = 0;
    if (RegExp(r"j'ai|j'ai|je suis|aujourd'hui|aujourdhui|ce matin|ce soir").hasMatch(q)) {
      signals++;
    }
    if (RegExp(r'rentré|rentre|entré|entre|position|sl\b|stop loss|zone').hasMatch(q)) {
      signals++;
    }
    if (RegExp(r'clôtur|clos|sorti|fermé|ferme|couper|cut|renvers').hasMatch(q)) {
      signals++;
    }
    if (RegExp(
      r'fomo|pyscho|psycho|inquiétude|inquietude|peur|stress|tilt|revenge|renvers|frustr',
    ).hasMatch(q)) {
      signals++;
    }
    if (RegExp(r'marché|marche|parti|perte|gain|analyse').hasMatch(q)) signals++;

    if (signals < 2) return false;

    if (RegExp(
      r"qu'en penses|que penses|pense[s-]? tu|ton avis|what do you think|"
      r"ques[- ]?ce que tu pense|ques[- ]?ce que tu en pense|"
      r"que ton pense|comment tu vois|tu en dis quoi|ton opinion",
    ).hasMatch(q)) {
      return true;
    }

    return signals >= 3 && q.length > 140;
  }

  static List<String> _detectThemes(String q) {
    final themes = <String>[];
    if (RegExp(r'renvers|revenge|contre mon analyse|contre l.analyse').hasMatch(q)) {
      themes.add('Revenge — trade contre ton analyse');
    }
    if (RegExp(r'pullback').hasMatch(q) && RegExp(r'sl\b|stop').hasMatch(q)) {
      themes.add('Pullback puis SL touché');
    }
    if (RegExp(r'fomo|trop t[oô]t|early|avant').hasMatch(q)) {
      themes.add('FOMO / entrée anticipée');
    }
    if (RegExp(r'feeling|au feeling|hors[\s-]?plan|impulsif').hasMatch(q)) {
      themes.add('Trades au feeling — hors plan');
    }
    if (RegExp(
      r'n.?arrive pas.{0,35}(suivre|respect|tenir)|'
      r'ne (tiens|suis) pas.{0,25}strat|pas suivi.{0,20}strat',
    ).hasMatch(q)) {
      themes.add('Difficulté à suivre la stratégie');
    }
    if (RegExp(r'attendre|patience|impatien|n.arrive pas').hasMatch(q)) {
      themes.add('Impatience — difficulté à attendre le niveau');
    }
    if (RegExp(r'inquiétude|inquietude|peur|stress|panique').hasMatch(q)) {
      themes.add('Sortie par inquiétude (pas par le plan)');
    }
    if (RegExp(r'sl\b|stop').hasMatch(q) && RegExp(r'pas touch|n.a pas touch|non touch').hasMatch(q)) {
      themes.add('SL non touché mais sortie manuelle');
    }
    if (RegExp(r'tp\b|take profit').hasMatch(q) &&
        RegExp(r'gagnant|gain|positif|vert').hasMatch(q) &&
        RegExp(r'retourn|pas touch|n.a pas touch|non touch|lacher|lâcher|clotur|perte').hasMatch(q)) {
      themes.add('Gain virtuel non sécurisé (TP non touché)');
    }
    if (RegExp(r'ne veux pas|pas lacher|pas lâcher|refus').hasMatch(q) &&
        RegExp(r'clotur|couper|sortir|fermer').hasMatch(q)) {
      themes.add('Refus de couper — aversion à la perte');
    }
    if (RegExp(r'analyse.*(juste|bonne|bon|correct)|marché.*(parti|suit)').hasMatch(q)) {
      themes.add('Analyse directionnelle OK mais exécution dégradée');
    }
    if (RegExp(r'perte|loss|malgré').hasMatch(q)) {
      themes.add('Résultat : perte malgré lecture marché');
    }
    return themes;
  }

  static CoachCoachingStoryFocus? buildFocus(
    Iterable<TradeListItem> trades,
    String question,
  ) {
    if (!isCoachingStoryQuestion(question)) return null;
    final q = CoachAiQueryText.forMatching(question);
    final tag = CoachAiPsychAnalysis.extractTagQuery(question);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    var todayTagged = 0;
    if (tag != null) {
      for (final t in trades) {
        final d = DateTime(t.entreeAt.year, t.entreeAt.month, t.entreeAt.day);
        if (d == todayOnly &&
            t.psychTags.any((x) => x.toLowerCase().contains(tag.toLowerCase()))) {
          todayTagged++;
        }
      }
    }
    final asksOpinion = RegExp(
      r"qu'en penses|que penses|pense[s-]? tu|ton avis|what do you think|"
      r"ques[- ]?ce que tu pense|comment tu vois|tu en dis quoi|ton opinion",
    ).hasMatch(q);
    final asksHowToFix = RegExp(
      r'comment (je peux |tu peux )?(régler|regler|régle|regle|gérer|gerer|maitriser|maîtriser|éviter|eviter)',
    ).hasMatch(q);

    return CoachCoachingStoryFocus(
      themes: _detectThemes(q),
      asksOpinion: asksOpinion,
      asksHowToFix: asksHowToFix,
      relatedTag: tag,
      todayTaggedTrades: todayTagged,
    );
  }

  /// Réponse coach sans cloud (feeling, discipline stratégie, récit court).
  static String buildLocalAnswer({
    required String question,
    required String languageCode,
    Iterable<TradeListItem> trades = const [],
  }) {
    final focus = buildFocus(trades, question);
    final themes = focus?.themes ?? <String>[];
    final themeLine = themes.isEmpty
        ? null
        : (languageCode == 'fr'
            ? 'Je vois surtout : ${themes.join(' · ')}.'
            : 'Main themes: ${themes.join(' · ')}.');

    var feelingTagged = 0;
    for (final t in trades) {
      final blob = t.psychTags.map((x) => x.toLowerCase()).join(' ');
      if (blob.contains('feeling') ||
          blob.contains('impuls') ||
          blob.contains('hors plan')) {
        feelingTagged++;
      }
    }

    if (languageCode == 'fr') {
      final journalHint = feelingTagged > 0
          ? 'Tu as déjà $feelingTagged trade(s) tagué(s) feeling/impulsif dans le journal — le pattern est visible, c’est une bonne base pour corriger.'
          : 'Commence par taguer chaque trade « feeling » sur Ajouter trade : sans étiquette, tu crois que c’est aléatoire alors que c’est répétitif.';

      return 'Tu décris des trades au feeling alors que tu veux suivre ta stratégie — classique : l’intention est bonne, l’exécution part en mode impulsion.\n\n'
          '${themeLine != null ? '$themeLine\n\n' : ''}'
          '1. (Avant le clic) Règle PAYCHEK : pas de trade si setup épinglé + checklist + état mental ne sont pas renseignés — un seul manquant = session en pause 15 min.\n'
          '2. (Nommer) $journalHint\n'
          '3. (Stratégie) Si tu ne peux pas lier le trade à ton setup du jour (signal M15, volume, invalidation), considère-le comme du feeling par définition — ne le rationalise pas après coup.\n'
          '4. (Après 2 feeling d’affilée) Fin de session obligatoire ; revue à froid : qu’est-ce qui manquait (patience, niveau, peur de rater) ?\n'
          '5. (Semaine) Objectif : 5 trades max, 100 % liés à la stratégie ; chaque non-respect noté avant le prochain signal.\n\n'
          'Tu n’as pas besoin d’une nouvelle stratégie tout de suite — tu as besoin d’un filtre feeling → plan → exécution.';
    }

    final journalHint = feelingTagged > 0
        ? 'You already have $feelingTagged feeling/impulsive tagged trades — the pattern is visible.'
        : 'Tag every feeling trade in Add Trade before rationalizing it.';

    return 'You describe feeling trades while wanting to follow your strategy — intention is fine, execution slips into impulse.\n\n'
        '${themeLine != null ? '$themeLine\n\n' : ''}'
        '1. (Before click) PAYCHEK rule: no trade unless starred setup + checklist + mental state are filled — one missing = 15 min pause.\n'
        '2. (Label) $journalHint\n'
        '3. (Strategy) If you cannot link the trade to today’s setup (M15 signal, volume, invalidation), treat it as feeling — don’t retrofit the story.\n'
        '4. (After 2 feeling trades in a row) End session; review what was missing (patience, level, FOMO).\n'
        '5. (This week) Max 5 trades, 100% strategy-linked; log every violation before the next signal.\n\n'
        'You likely need a feeling → plan → execution filter more than a brand-new strategy.';
  }

  static Map<String, dynamic> focusToJson(
    CoachCoachingStoryFocus f, {
    String languageCode = 'fr',
  }) {
    return <String, dynamic>{
      'themes': f.themes,
      'asksOpinion': f.asksOpinion,
      if (f.relatedTag != null) 'relatedPsychTag': f.relatedTag,
      'todayTradesWithTag': f.todayTaggedTrades,
      'coachInstructions':
          '${CoachAiResponseFormat.narrativeInstructions(languageCode)} '
          'Relie-toi aux thèmes du récit. Ne liste PAS les trades dans le texte — l’app affiche les lignes du journal en bas. '
          'Cite au plus 1 exemple chiffré si relatedTradesPreview est fourni. '
          'Une phrase max sur taguer FOMO/Impatience sur Ajouter trade si pertinent.',
    };
  }
}
