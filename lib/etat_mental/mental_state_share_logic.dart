import 'mental_state_models.dart';

/// Répartitions « gâteau » 100 % et ajouts de lignes (sans dépendre du contrôleur).
class MentalStateShareLogic {
  MentalStateShareLogic._();

  static void fixFactorSumOnIndex(List<MentalStateMetric> factors, int index) {
    if (factors.isEmpty) return;
    double s = 0;
    for (final f in factors) {
      s += f.weight;
    }
    factors[index].weight += (100 - s);
  }

  static void normalizeFactorsTo100(List<MentalStateMetric> factors) {
    if (factors.isEmpty) return;
    if (factors.length == 1) {
      factors[0].weight = 100;
      return;
    }
    double s = 0;
    for (final f in factors) {
      s += f.weight;
    }
    if (s <= 0) {
      equalizeFactorWeights(factors);
      return;
    }
    for (final f in factors) {
      f.weight = f.weight * 100.0 / s;
    }
    fixFactorSumOnIndex(factors, factors.length - 1);
  }

  static void equalizeFactorWeights(List<MentalStateMetric> factors) {
    if (factors.isEmpty) return;
    if (factors.length == 1) {
      factors[0].weight = 100;
      return;
    }
    final share = 100.0 / factors.length;
    for (final f in factors) {
      f.weight = share;
    }
    fixFactorSumOnIndex(factors, factors.length - 1);
  }

  static void setShareInList(List<double> weights, int index, double targetPercent) {
    final t = targetPercent.clamp(0.0, 100.0);
    final n = weights.length;
    if (n == 0) return;
    if (n == 1) {
      weights[0] = 100;
      return;
    }
    double sumOthers = 0;
    for (var j = 0; j < n; j++) {
      if (j != index) sumOthers += weights[j];
    }
    final remaining = 100 - t;
    if (sumOthers <= 0) {
      final eq = remaining / (n - 1);
      for (var j = 0; j < n; j++) {
        if (j != index) weights[j] = eq;
      }
    } else {
      final scale = remaining / sumOthers;
      for (var j = 0; j < n; j++) {
        if (j != index) weights[j] = weights[j] * scale;
      }
    }
    weights[index] = t;
    double sum = 0;
    for (final x in weights) {
      sum += x;
    }
    weights[index] += (100 - sum);
  }

  static void setFactorShare(List<MentalStateMetric> factors, int index, double targetPercent) {
    final weights = factors.map((f) => f.weight).toList();
    setShareInList(weights, index, targetPercent);
    for (var i = 0; i < factors.length; i++) {
      factors[i].weight = weights[i];
    }
  }

  static void fixMomentSumOnIndex(List<MentalStateMetric> moment, int index) {
    if (moment.isEmpty) return;
    double s = 0;
    for (final m in moment) {
      s += m.weight;
    }
    moment[index].weight += (100 - s);
  }

  static void normalizeMomentTo100(List<MentalStateMetric> moment) {
    if (moment.isEmpty) return;
    if (moment.length == 1) {
      moment[0].weight = 100;
      return;
    }
    double s = 0;
    for (final m in moment) {
      s += m.weight;
    }
    if (s <= 0) {
      equalizeMomentWeights(moment);
      return;
    }
    for (final m in moment) {
      m.weight = m.weight * 100.0 / s;
    }
    fixMomentSumOnIndex(moment, moment.length - 1);
  }

  static void equalizeMomentWeights(List<MentalStateMetric> moment) {
    if (moment.isEmpty) return;
    if (moment.length == 1) {
      moment[0].weight = 100;
      return;
    }
    final share = 100.0 / moment.length;
    for (final m in moment) {
      m.weight = share;
    }
    fixMomentSumOnIndex(moment, moment.length - 1);
  }

  static void setMomentShare(List<MentalStateMetric> moment, int index, double targetPercent) {
    final weights = moment.map((m) => m.weight).toList();
    setShareInList(weights, index, targetPercent);
    for (var i = 0; i < moment.length; i++) {
      moment[i].weight = weights[i];
    }
  }

  /// Met à jour les 3 poids globaux (legacy) — somme = 100 %.
  static void setGlobalThreeShare(
    List<double> w,
    int index,
    double targetPercent,
  ) {
    setShareInList(w, index, targetPercent);
  }

  /// Met à jour les 4 poids globaux (Repos, Routines, Moment, Émotion) — somme = 100 %.
  static void setGlobalFourShare(
    List<double> w,
    int index,
    double targetPercent,
  ) {
    setShareInList(w, index, targetPercent);
  }

  static void fixSum100Emotions(List<MentalStateEmotion> emotions) {
    if (emotions.isEmpty) return;
    double s = 0;
    for (final e in emotions) {
      s += e.weight;
    }
    final d = 100 - s;
    emotions[emotions.length - 1].weight += d;
  }

  static void equalizeEmotionWeights(List<MentalStateEmotion> emotions) {
    if (emotions.isEmpty) return;
    if (emotions.length == 1) {
      emotions[0].weight = 100;
      return;
    }
    final share = 100.0 / emotions.length;
    for (final e in emotions) {
      e.weight = share;
    }
    fixSum100Emotions(emotions);
  }

  static void setEmotionShareSingle(List<MentalStateEmotion> emotions, int index, double targetPercent) {
    final t = targetPercent.clamp(0.0, 100.0);
    final n = emotions.length;
    if (n == 0) return;
    if (n == 1) {
      emotions[0].weight = 100;
      return;
    }
    double sumOthers = 0;
    for (var j = 0; j < n; j++) {
      if (j != index) sumOthers += emotions[j].weight;
    }
    final remaining = 100 - t;
    if (sumOthers <= 0) {
      final eq = remaining / (n - 1);
      for (var j = 0; j < n; j++) {
        if (j != index) emotions[j].weight = eq;
      }
    } else {
      final scale = remaining / sumOthers;
      for (var j = 0; j < n; j++) {
        if (j != index) emotions[j].weight = emotions[j].weight * scale;
      }
    }
    emotions[index].weight = t;
    double sum = 0;
    for (final e in emotions) {
      sum += e.weight;
    }
    emotions[index].weight += (100 - sum);
  }

  static void addFactorWithShare({
    required List<MentalStateMetric> factors,
    required bool factorsShare100,
    required MentalStateMetric m,
    required double targetPercent,
  }) {
    if (!factorsShare100) {
      m.weight = targetPercent.clamp(0.0, 100.0);
      factors.add(m);
      return;
    }
    final t = targetPercent.clamp(0.0, 100.0);
    if (factors.isEmpty) {
      m.weight = 100;
      factors.add(m);
      return;
    }
    final scale = (100 - t) / 100;
    for (final f in factors) {
      f.weight *= scale;
    }
    m.weight = t;
    factors.add(m);
    fixFactorSumOnIndex(factors, factors.length - 1);
  }

  static void addMomentWithShare({
    required List<MentalStateMetric> moment,
    required bool momentShare100,
    required MentalStateMetric m,
    required double targetPercent,
  }) {
    if (!momentShare100) {
      m.weight = targetPercent.clamp(0.0, 100.0);
      moment.add(m);
      return;
    }
    final t = targetPercent.clamp(0.0, 100.0);
    if (moment.isEmpty) {
      m.weight = 100;
      moment.add(m);
      return;
    }
    final scale = (100 - t) / 100;
    for (final x in moment) {
      x.weight *= scale;
    }
    m.weight = t;
    moment.add(m);
    fixMomentSumOnIndex(moment, moment.length - 1);
  }

  static void addEmotionWithShare({
    required List<MentalStateEmotion> emotions,
    required bool emotionsShare100,
    required MentalStateEmotion e,
    required double targetPercent,
  }) {
    if (!emotionsShare100) {
      e.weight = targetPercent.clamp(0.0, 100.0);
      emotions.add(e);
      return;
    }
    final t = targetPercent.clamp(0.0, 100.0);
    if (emotions.isEmpty) {
      e.weight = 100;
      emotions.add(e);
      return;
    }
    final scale = (100 - t) / 100;
    for (final em in emotions) {
      em.weight *= scale;
    }
    e.weight = t;
    emotions.add(e);
    double sum = 0;
    for (final em in emotions) {
      sum += em.weight;
    }
    emotions[emotions.length - 1].weight += (100 - sum);
  }

  static void normalizeEmotionsTo100(List<MentalStateEmotion> emotions) {
    if (emotions.isEmpty) return;
    if (emotions.length == 1) {
      emotions[0].weight = 100;
      return;
    }
    double s = 0;
    for (final e in emotions) {
      s += e.weight;
    }
    if (s <= 0) {
      equalizeEmotionWeights(emotions);
      return;
    }
    for (final e in emotions) {
      e.weight = e.weight * 100.0 / s;
    }
    fixSum100Emotions(emotions);
  }
}
