/// Scores à partir des points Q1–Q3 ; Q4 réduit profil, global, stratégie et psychologie.
class QuestionnaireScoreResult {
  const QuestionnaireScoreResult({
    required this.profilPercent,
    required this.globalPercent,
    required this.strategie01,
    required this.psychologie01,
  });

  /// 0–100
  final double profilPercent;
  /// 0–100
  final double globalPercent;
  /// 0–1 (barre + note /10)
  final double strategie01;
  /// 0–1
  final double psychologie01;

  int get statisticGlobalPercent => globalPercent.round().clamp(1, 99);

  int get statisticProfilPercent => profilPercent.round().clamp(1, 99);

  int get strategieSur10 => (strategie01 * 10).round().clamp(1, 10);
  int get psychologieSur10 => (psychologie01 * 10).round().clamp(1, 10);

  /// Affichage inversé (1 − score) pour les barres Stratégie / Psychologie.
  double get strategieInverted01 => (1 - strategie01).clamp(0.0, 1.0);
  double get psychologieInverted01 => (1 - psychologie01).clamp(0.0, 1.0);

  int get strategieSur10Inverted =>
      ((1 - strategie01) * 10).round().clamp(0, 10);
  int get psychologieSur10Inverted =>
      ((1 - psychologie01) * 10).round().clamp(0, 10);

  static const QuestionnaireScoreResult fallback = QuestionnaireScoreResult(
    profilPercent: 50,
    globalPercent: 50,
    strategie01: 0.5,
    psychologie01: 0.5,
  );
}

/// Q1–Q3 : points par carte. Q4 : défis cochés = pénalité sur tout ; **psychologie** plus sensible.
abstract final class QuestionnaireScoring {
  QuestionnaireScoring._();

  /// Q1 — 4 cartes (indices 0–3).
  static const List<double> _q1Strat = [3, 2.5, 2, 1.5];
  static const List<double> _q1Psy = [3, 2.5, 2.5, 1.5];

  /// Q2 — 3 cartes.
  static const List<double> _q2Strat = [5, 3, 2];
  static const List<double> _q2Psy = [5, 3, 2.5];

  /// Q3 — 4 cartes.
  static const List<double> _q3Strat = [4, 3, 2, 1];
  static const List<double> _q3Psy = [4, 3, 2, 1];

  static const double _maxStratPoints = 12;
  static const double _maxPsyPoints = 12;

  /// Impact par défi Q4 (FOMO … Sans MM) — somme → pénalité normalisée.
  static const List<double> _q4Impact = [
    0.078,
    0.09,
    0.068,
    0.072,
    0.06,
    0.05,
    0.095,
  ];

  /// Somme des poids si les 7 défis sont cochés (normalisation p ∈ [0,1]).
  static const double _q4ImpactSumMax =
      0.078 + 0.09 + 0.068 + 0.072 + 0.06 + 0.05 + 0.095;

  /// Pénalité sur stratégie / profil / global (relative).
  static const double _penaltyStrat = 0.52;
  static const double _penaltyProfil = 0.45;

  /// Pénalité plus forte sur la psychologie (importance pour le trader).
  static const double _penaltyPsy = 0.92;

  static QuestionnaireScoreResult compute({
    int? q1,
    int? q2,
    int? q3,
    Set<int>? q4,
  }) {
    if (q1 == null ||
        q2 == null ||
        q3 == null ||
        q4 == null ||
        q4.isEmpty ||
        q1 < 0 ||
        q1 >= _q1Strat.length ||
        q2 < 0 ||
        q2 >= _q2Strat.length ||
        q3 < 0 ||
        q3 >= _q3Strat.length) {
      return QuestionnaireScoreResult.fallback;
    }

    final st = _q1Strat[q1] + _q2Strat[q2] + _q3Strat[q3];
    final py = _q1Psy[q1] + _q2Psy[q2] + _q3Psy[q3];

    var strategie01 = (st / _maxStratPoints).clamp(0.0, 1.0);
    var psychologie01 = (py / _maxPsyPoints).clamp(0.0, 1.0);
    var profil = (((st + py) / (_maxStratPoints + _maxPsyPoints)) * 100)
        .clamp(5.0, 100.0);

    var rawQ4 = 0.0;
    for (final i in q4) {
      if (i >= 0 && i < _q4Impact.length) {
        rawQ4 += _q4Impact[i];
      }
    }
    final p = (rawQ4 / _q4ImpactSumMax).clamp(0.0, 1.0);

    strategie01 *= (1 - _penaltyStrat * p);
    psychologie01 *= (1 - _penaltyPsy * p);
    profil *= (1 - _penaltyProfil * p);

    strategie01 = strategie01.clamp(0.06, 1.0);
    psychologie01 = psychologie01.clamp(0.05, 1.0);
    profil = profil.clamp(5.0, 100.0);

    final strat100 = strategie01 * 100;
    final psych100 = psychologie01 * 100;
    final global = (0.34 * profil + 0.33 * strat100 + 0.33 * psych100)
        .clamp(6.0, 99.0);

    return QuestionnaireScoreResult(
      profilPercent: profil,
      globalPercent: global,
      strategie01: strategie01,
      psychologie01: psychologie01,
    );
  }
}
