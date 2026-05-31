/// Normalise les questions utilisateur (fautes, accents, typos) avant routage Coach AI.
abstract final class CoachAiQueryText {
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
