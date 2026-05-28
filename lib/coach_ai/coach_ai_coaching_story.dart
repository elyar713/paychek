import '../trade/trade_models.dart';
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
    final q = question.toLowerCase().trim();

    // Récit du jour + « comment régler cette psycho » (revenge, SL, renverser…).
    if (RegExp(
      r"c.?est quoi|c quoi|quelle psycho|quel psycho|quoi comme psycho|what.{0,16}psycho",
    ).hasMatch(q)) {
      if (RegExp(
        r'trade|tp\b|take profit|gagnant|gain|perte|clotur|position|retourn|lacher|lâcher',
      ).hasMatch(q)) {
        return q.length >= 50;
      }
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
    final q = question.toLowerCase();
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
          'Relie-toi aux themes du récit (pas de liste de trades du journal). '
          'Une phrase max sur taguer Revenge/Cupidité sur Ajouter trade si pertinent.',
    };
  }
}
