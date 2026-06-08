/// Normalise les questions utilisateur (fautes, accents, typos) avant routage Coach AI.
abstract final class CoachAiQueryText {
  static const Set<String> _supportedCoachLanguages = {
    'fr',
    'en',
    'es',
    'de',
    'pt',
    'ko',
  };

  /// Langues supportées par le Coach (callable + réponses locales).
  static String normalizeCoachLanguageCode(String raw) {
    final lc = raw.trim().toLowerCase().split('_').first.split('-').first;
    return _supportedCoachLanguages.contains(lc) ? lc : 'en';
  }

  /// Langue de réponse : priorité au texte de la question, sinon [fallback] (locale app).
  static String responseLanguageCode(
    String text, {
    required String fallback,
  }) {
    final q = text.trim().toLowerCase();
    final fb = normalizeCoachLanguageCode(fallback);
    if (q.isEmpty) return fb;

    final scores = <String, int>{
      for (final lc in _supportedCoachLanguages) lc: 0,
    };

    if (RegExp(r'[àâäéèêëïîôùûüç]').hasMatch(q)) scores['fr'] = scores['fr']! + 2;
    if (RegExp(r'[äöüß]').hasMatch(q)) scores['de'] = scores['de']! + 3;
    if (RegExp(r'[ñ¿¡]').hasMatch(q)) scores['es'] = scores['es']! + 3;
    if (RegExp(r'[ãõ]').hasMatch(q)) scores['pt'] = scores['pt']! + 2;
    if (RegExp(r'[가-힣]').hasMatch(q)) scores['ko'] = scores['ko']! + 5;

    for (final w in RegExp(r"[a-zàâäéèêëïîôùûüçäöüßñãõ가-힣']+")
        .allMatches(q)
        .map((m) => m.group(0)!)) {
      if (_enLanguageMarkers.contains(w)) scores['en'] = scores['en']! + 1;
      if (_frLanguageMarkers.contains(w)) scores['fr'] = scores['fr']! + 1;
      if (_deLanguageMarkers.contains(w)) scores['de'] = scores['de']! + 1;
      if (_esLanguageMarkers.contains(w)) scores['es'] = scores['es']! + 1;
      if (_ptLanguageMarkers.contains(w)) scores['pt'] = scores['pt']! + 1;
      if (_koLanguageMarkers.contains(w)) scores['ko'] = scores['ko']! + 1;
    }

    if (RegExp(
      r'\b(how do|how can|how should|what is|what are|what was|why do|why did|why is|'
      r'tell me|show me|help me|can you|could you|should i|i have|i had|my trades)\b',
    ).hasMatch(q)) {
      scores['en'] = scores['en']! + 2;
    }
    if (RegExp(
      r"\b(comment |pourquoi |est-ce que|qu'est-ce|quels? |quelles? |"
      r"aujourd'hui|j'ai |c'est |donne-moi|aide-moi)\b",
    ).hasMatch(q)) {
      scores['fr'] = scores['fr']! + 2;
    }
    if (RegExp(r'\b(wie |warum |was ist|kann ich|können sie|hilf mir)\b').hasMatch(q)) {
      scores['de'] = scores['de']! + 2;
    }
    if (RegExp(r'\b(cómo |por qué |qué es|puedes |ayúdame|muéstrame)\b').hasMatch(q)) {
      scores['es'] = scores['es']! + 2;
    }
    if (RegExp(r'\b(como |por que |o que |podes |ajuda-me|mostra-me)\b').hasMatch(q)) {
      scores['pt'] = scores['pt']! + 2;
    }
    if (RegExp(r'(어떻게|왜|무엇|도와|알려)').hasMatch(q)) {
      scores['ko'] = scores['ko']! + 2;
    }

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.first;
    final second = ranked.length > 1 ? ranked[1].value : 0;
    if (top.value >= 1 && top.value > second) return top.key;
    return fb;
  }

  /// Remplace les fautes fréquentes et harmonise le texte pour les regex de détection.
  static String forMatching(String question) {
    var q = question.toLowerCase().trim();
    if (q.isEmpty) return q;

    q = q
        .replaceAll(RegExp(r'[’`´]'), "'")
        .replaceAll(RegExp(r'\s+'), ' ');

    for (final e in _wordReplacements.entries) {
      q = q.replaceAll(
        RegExp('\\b${RegExp.escape(e.key)}\\b'),
        e.value,
      );
    }

    return q;
  }

  /// Mot-clé présent exactement ou proche (Levenshtein sur les tokens).
  static bool containsKeyword(
    String question,
    String keyword, {
    int maxEditDistance = 1,
  }) {
    final canon = keyword.toLowerCase();
    final q = forMatching(question);
    if (q.contains(canon)) return true;

    final words = RegExp(r"[a-zàâäéèêëïîôùûüç']+")
        .allMatches(q)
        .map((m) => m.group(0)!)
        .where((w) => w.length >= 3);
    final limit = _fuzzyLimit(canon);
    for (final w in words) {
      if (_levenshtein(w, canon) <= limit) return true;
    }
    return false;
  }

  static bool containsAny(
    String question,
    Iterable<String> keywords, {
    int maxEditDistance = 1,
  }) {
    for (final k in keywords) {
      if (containsKeyword(question, k, maxEditDistance: maxEditDistance)) {
        return true;
      }
    }
    return false;
  }

  static bool matchesPattern(String question, RegExp pattern) {
    return pattern.hasMatch(forMatching(question));
  }

  static int _fuzzyLimit(String term) {
    if (term.length >= 9) return 2;
    if (term.length >= 5) return 1;
    return 0;
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final m = a.length;
    final n = b.length;
    var prev = List<int>.generate(n + 1, (j) => j);
    var curr = List<int>.filled(n + 1, 0);

    for (var i = 1; i <= m; i++) {
      curr[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = _min3(
          curr[j - 1] + 1,
          prev[j] + 1,
          prev[j - 1] + cost,
        );
      }
      final swap = prev;
      prev = curr;
      curr = swap;
    }
    return prev[n];
  }

  static int _min3(int a, int b, int c) {
    if (a > b) {
      final t = a;
      a = b;
      b = t;
    }
    if (b > c) {
      final t = b;
      b = c;
      c = t;
    }
    if (a > b) return b;
    return a < c ? a : c;
  }

  static const Set<String> _enLanguageMarkers = {
    'the',
    'what',
    'why',
    'how',
    'when',
    'where',
    'which',
    'should',
    'could',
    'would',
    'can',
    'do',
    'does',
    'did',
    'is',
    'are',
    'was',
    'were',
    'my',
    'your',
    'help',
    'please',
    'today',
    'yesterday',
    'week',
    'month',
    'performance',
    'strategy',
    'checklist',
    'analysis',
    'mental',
    'tell',
    'explain',
    'show',
    'list',
    'trade',
    'trades',
    'about',
    'with',
    'this',
    'that',
    'have',
    'has',
    'had',
  };

  static const Set<String> _frLanguageMarkers = {
    'le',
    'la',
    'les',
    'un',
    'une',
    'des',
    'du',
    'de',
    'et',
    'est',
    'sont',
    'pour',
    'pourquoi',
    'comment',
    'quand',
    'quel',
    'quelle',
    'quels',
    'quelles',
    'mon',
    'ma',
    'mes',
    'ton',
    'ta',
    'tes',
    'aide',
    'expliquer',
    'montre',
    'liste',
    'aujourd',
    "aujourd'hui",
    'semaine',
    'mois',
    'stratégie',
    'strategie',
    'analyse',
    'discipline',
    'psychologie',
    'psycho',
    'avec',
    'cette',
    'cela',
    'suis',
    'ai',
    'pas',
    'plus',
    'moins',
  };

  static const Set<String> _deLanguageMarkers = {
    'der',
    'die',
    'das',
    'und',
    'ist',
    'sind',
    'ich',
    'mein',
    'meine',
    'dein',
    'warum',
    'wie',
    'wann',
    'welche',
    'welcher',
    'heute',
    'woche',
    'monat',
    'strategie',
    'analyse',
    'disziplin',
    'hilfe',
    'bitte',
    'trade',
    'trades',
    'nicht',
    'mehr',
    'weniger',
  };

  static const Set<String> _esLanguageMarkers = {
    'el',
    'la',
    'los',
    'las',
    'un',
    'una',
    'y',
    'es',
    'son',
    'por',
    'porqué',
    'porque',
    'cómo',
    'como',
    'cuando',
    'cuál',
    'cual',
    'mi',
    'tu',
    'hoy',
    'semana',
    'mes',
    'estrategia',
    'análisis',
    'analisis',
    'disciplina',
    'ayuda',
    'trade',
    'trades',
    'no',
    'más',
    'mas',
    'menos',
  };

  static const Set<String> _ptLanguageMarkers = {
    'o',
    'a',
    'os',
    'as',
    'um',
    'uma',
    'e',
    'é',
    'são',
    'sao',
    'por',
    'porque',
    'como',
    'quando',
    'qual',
    'meu',
    'minha',
    'teu',
    'hoje',
    'semana',
    'mês',
    'mes',
    'estratégia',
    'estrategia',
    'análise',
    'analise',
    'disciplina',
    'ajuda',
    'trade',
    'trades',
    'não',
    'nao',
    'mais',
    'menos',
  };

  static const Set<String> _koLanguageMarkers = {
    '오늘',
    '이번',
    '주',
    '월',
    '전략',
    '분석',
    '규율',
    '도움',
    '트레이드',
    '거래',
    '왜',
    '어떻게',
    '무엇',
    '내',
    '나의',
  };

  /// Fautes courantes PAYCHEK / trading / français oral.
  static const Map<String, String> _wordReplacements = {
    // checklist
    'chekliste': 'checklist',
    'cheklist': 'checklist',
    'checklit': 'checklist',
    'checkliste': 'checklist',
    'checlist': 'checklist',
  // sommeil / mental
    'someil': 'sommeil',
    'sommeill': 'sommeil',
    'sommei': 'sommeil',
    'somil': 'sommeil',
    'somail': 'sommeil',
    'dormie': 'dormi',
  // performance
    'winrat': 'winrate',
    'winrte': 'winrate',
    'winrete': 'winrate',
    'dimlinue': 'diminue',
    'diminiu': 'diminue',
    'diminuee': 'diminue',
    'baisse': 'baisse',
    'performence': 'performance',
    'perfomance': 'performance',
    'performanse': 'performance',
  // psycho / état
    'pyscho': 'psycho',
    'psyhco': 'psycho',
    'psyco': 'psycho',
    'etat': 'état',
    'impatien': 'impatience',
    'impatient': 'impatience',
  // trade
    'trede': 'trade',
    'trades': 'trades',
    'trad': 'trade',
    // audit / app
    'audite': 'audit',
    'audti': 'audit',
    'aujourdhui': "aujourd'hui",
    'ajourdhui': "aujourd'hui",
    'regler': 'régler',
    'regle': 'régler',
    'enregistre': 'enregistré',
    'enregistrer': 'enregistré',
    'strategie': 'stratégie',
    'ameliore': 'améliorer',
    'ameliorer': 'améliorer',
    'renforce': 'renforcer',
    'renforcer': 'renforcer',
    'pense': 'penses',
    'analyse': 'analyse',
    'fomo': 'fomo',
    'tilt': 'tilt',
  };
}
