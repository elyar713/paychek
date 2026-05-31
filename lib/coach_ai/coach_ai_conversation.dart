import 'coach_ai_query_text.dart';

/// Contexte multi-tours + suites après un récit coach (FOMO, etc.).
abstract final class CoachAiConversation {
  static const int maxTurnChars = 1000;
  static const int maxTurns = 8;

  static const _focusedTopicFollowUpPrior = <String>{
    'performance_overtrading',
    'performance_lens',
    'performance_summary',
    'calendar_month',
    'calendar_today',
    'strategy_today',
    'analysis_today',
    'checklist_today',
    'mental_today',
    'app_pricing',
    'coaching_story',
    'pillar_improvement',
  };

  /// Suite courte (« le point le plus important ») après une réponse ciblée.
  static bool isFocusedTopicFollowUp(String question, String? lastAssistantFocus) {
    if (lastAssistantFocus == null ||
        !_focusedTopicFollowUpPrior.contains(lastAssistantFocus)) {
      return false;
    }
    final q = question.toLowerCase().trim();
    if (q.length > 90) return false;
    return RegExp(
      r'point (le )?plus important|le plus important|most important|what matters|'
      r'en résumé|resume|résume|the key|essentiel|conclusion|priorit|'
      r'qu.?est.?ce qui compte|what should i focus|en bref|in short|'
      r'quels? points?|quel(le)?s? points?|quelle point|renforcer|renforce|'
      r'faiblesse|sur quoi me concentrer',
    ).hasMatch(q);
  }

  /// Nouvelle intention explicite (pas une simple suite du fil).
  static bool hasExplicitNewTopic(String question) {
    final q = CoachAiQueryText.forMatching(question);
    if (q.length > 220) return true;
    if (RegExp(
      r'quel(le)?s?\s+trade|quels\s+trades|montre.{0,30}trade|liste.{0,30}trade|'
      r'affiche.{0,30}trade|combien de trade|audit|bilan',
    ).hasMatch(q)) {
      return true;
    }
    if (RegExp(
      r'checklist|analyse|strat(é|e)gie|strategy|état mental|etat mental|mental|'
      r'fomo|tilt|revenge|performance|winrate|pnl|non.?respect',
    ).hasMatch(q) &&
        !RegExp(r"du jour|today|aujourd'hui|aujourdhui").hasMatch(q)) {
      return true;
    }
    if (RegExp(
      r'comment (faire|utiliser|modifier|ajouter)|où se trouve|help center|mode d.emploi',
    ).hasMatch(q)) {
      return true;
    }
    if (RegExp(
      r"aujourd'hui|aujourdhui|performance|winrate|pnl|checklist du jour|état mental du jour",
    ).hasMatch(q) &&
        q.length > 40) {
      return true;
    }
    return false;
  }

  /// Suite du fil (« et pour la checklist ? », « tu en penses quoi », « oui mais… »).
  static bool isConversationalFollowUp(String question, String? lastAssistantFocus) {
    if (lastAssistantFocus == null) return false;
    if (lastAssistantFocus == 'trade_list' ||
        lastAssistantFocus == 'app_help' ||
        lastAssistantFocus == 'app_help_hybrid') {
      return true;
    }
    final q = CoachAiQueryText.forMatching(question);
    if (q.isEmpty || q.length > 200) return false;
    if (hasExplicitNewTopic(question) && q.length > 80) return false;
    if (isStoryFollowUp(question, lastAssistantFocus)) return false;
    if (isFocusedTopicFollowUp(question, lastAssistantFocus)) return false;

    if (RegExp(
      r'^(et |aussi |oui|non|ok|d.accord|donc|sinon|puis|ensuite|alors |pour |concernant |'
      r'par contre |du coup |c.est ça|cest ca)',
    ).hasMatch(q)) {
      return true;
    }
    if (RegExp(
      r'\b(ça|ca|celui|celle|cette réponse|ta réponse|tu as dit|avant|précédent|precedent|'
      r'la question|ma question|comme tu dis|tu disais)\b',
    ).hasMatch(q)) {
      return true;
    }
    return q.length < 95 && RegExp(r'\?').hasMatch(q);
  }

  /// Évite trade_list / app_help locaux qui ignorent le fil.
  static bool shouldPreferCloudWithThread({
    required String question,
    required String? priorAssistantFocus,
    required String resolvedFocus,
  }) {
    if (priorAssistantFocus == null) return false;
    if (!isConversationalFollowUp(question, priorAssistantFocus)) return false;
    if (resolvedFocus == 'trade_list' && !RegExp(
      r'quel(le)?s?\s+trade|quels\s+trades|montre|liste|affiche|voir mes trades',
    ).hasMatch(question.toLowerCase())) {
      return true;
    }
    if ((resolvedFocus == 'app_help' || resolvedFocus == 'app_help_hybrid') &&
        !RegExp(r'comment|où|how|help').hasMatch(question.toLowerCase())) {
      return true;
    }
    return isConversationalFollowUp(question, priorAssistantFocus) &&
        !hasExplicitNewTopic(question);
  }

  static bool isStoryFollowUp(String question, String? lastAssistantFocus) {
    if (lastAssistantFocus != 'coaching_story') return false;
    final q = question.toLowerCase();
    return RegExp(
      r'comment|regler|régler|gérer|gerer|maitriser|maîtriser|éviter|eviter|'
      r'cette psycho|cet psycho|cette pyscho|gerer cette|gérer cette|'
      r'cette fonction|cet(te)? fonctionnal|avec (cette |l.)?app|dans paychek|'
      r'pour (ça|ca)|ce pattern|taguer|utiliser paychek',
    ).hasMatch(q);
  }

  static List<Map<String, dynamic>> priorTurnsToJson({
    required List<String> texts,
    required List<bool> isUserFlags,
    required List<bool> isErrorFlags,
    required List<String?> responseFocuses,
    required int excludeLastCount,
  }) {
    assert(texts.length == isUserFlags.length);
    final n = texts.length - excludeLastCount;
    if (n <= 0) return const [];
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < n; i++) {
      if (isErrorFlags[i]) continue;
      var text = texts[i].trim();
      if (text.isEmpty) continue;
      if (text.length > maxTurnChars) text = '${text.substring(0, maxTurnChars)}…';
      out.add(<String, dynamic>{
        'role': isUserFlags[i] ? 'user' : 'assistant',
        'text': text,
        if (!isUserFlags[i] && responseFocuses[i] != null) 'focus': responseFocuses[i],
      });
    }
    if (out.length > maxTurns) return out.sublist(out.length - maxTurns);
    return out;
  }

  static List<String> storyFollowUpSteps(String languageCode) {
    if (languageCode == 'fr') {
      return <String>[
        'Référence (adapter au récit : revenge, FOMO, SL…) — ne pas recopier mot pour mot si le récit dit revenge.',
        'Après chaque trade : Ajouter trade → section TAG → FOMO, Revenge, TILT… (note courte si besoin).',
        'Avant de trader : Checklist (accueil ou Plus) + État mental du jour (stress, FOMO, sommeil).',
        '⚙ à côté de Principe/Feeling : « Session du jour » — ex. 2 trades Principe puis Feeling auto si tu dépasses ton plan.',
        '⚙ Mode Feeling : laisse les sections actives pour documenter une sortie anticipée (non-respect si tu quittes avant le SL).',
        'Plus tard : Coach → « quels trades FOMO » ou Performance pour voir le pattern chiffré.',
      ];
    }
    return <String>[
      'Context: you described FOMO + anxiety exit — PAYCHEK helps track and fix it.',
      'After each trade: Add trade → TAG → FOMO.',
      'Before trading: Checklist + Mental state for the day.',
      '⚙ next to Principle/Feeling: Daily session auto-tag.',
      '⚙ Feeling mode: keep sections on to log early exits.',
      'Later: Coach → list FOMO trades or Performance.',
    ];
  }
}
