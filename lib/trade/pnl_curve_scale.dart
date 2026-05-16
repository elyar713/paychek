import 'dart:math' as math;

/// Même axe Y pour courbe cumulative P&amp;L (calendrier + évolution capital).
abstract final class PnlCurveScale {
  PnlCurveScale._();

  /// Marge ajoutée autour de ±max|cumulative| (+22 % comme `CapitalEvolutionComputed._finish`).
  static const double extentFactorWithMargin = 1.22;

  /// Hauteur ± quand tout le cumul vaut exactement zéro (flat).
  static const double symmetricFlatExtent = 10;

  /// Valeurs déjà cumulées (une par pas : jour de mois ou point évolution).
  static ({double minY, double maxY}) extentsForCumulativeYs(Iterable<double> ys) {
    final list = ys.toList();
    if (list.isEmpty) {
      return (minY: -symmetricFlatExtent, maxY: symmetricFlatExtent);
    }
    final hasMovement = list.any((y) => y != 0);
    if (!hasMovement) {
      return (
        minY: -symmetricFlatExtent.toDouble(),
        maxY: symmetricFlatExtent.toDouble(),
      );
    }
    final minRaw = list.reduce(math.min);
    final maxRaw = list.reduce(math.max);
    final maxAbs = math.max(math.max(minRaw.abs(), maxRaw.abs()), 1e-6);
    final extent = maxAbs * extentFactorWithMargin;
    return (minY: -extent, maxY: extent);
  }
}
