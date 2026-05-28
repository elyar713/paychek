/// Contexte multi-tours + suites après un récit coach (FOMO, etc.).
abstract final class CoachAiConversation {
  static const int maxTurnChars = 700;
  static const int maxTurns = 4;

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
      r'qu.?est.?ce qui compte|what should i focus|en bref|in short',
    ).hasMatch(q);
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
