/// Partitions 0–100 % pour les barres « analyse personnalisée » (parts qui totalisent 100 %).
library;

const double kCustomLensMinBandShare = 5.0;

/// Bornes strictement croissantes : [0, …seuils…, 100].
List<double> customLensPartitionBounds(List<double> thresholds) {
  final t = List<double>.from(thresholds)..sort();
  return [0, ...t, 100];
}

double customLensBandSharePercent(List<double> thresholds, int bandIndex) {
  final b = customLensPartitionBounds(thresholds);
  return (b[bandIndex + 1] - b[bandIndex]).clamp(0.0, 100.0);
}

/// Seuils équidistants pour [barCount] barres (ex. 2 → [50], 3 → [33.33, 66.67]).
List<double> customLensEqualThresholds(int barCount) {
  if (barCount < 2) return [50];
  return [
    for (var i = 1; i < barCount; i++) (100.0 * i / barCount),
  ];
}

/// Ajoute une barre en conservant la 1ʳᵉ part, le reste se répartit sur les nouvelles barres.
List<double> customLensAddBar(List<double> thresholds) {
  final nextBarCount = thresholds.length + 2;
  if (nextBarCount > 5) return thresholds;
  final first = thresholds.isEmpty ? 50.0 : thresholds.first;
  final inner = nextBarCount - 1;
  if (inner <= 1) return [first];
  final tail = 100 - first;
  return [
    first,
    for (var k = 1; k < inner; k++) first + tail * k / inner,
  ];
}

/// Retire la dernière barre en conservant la 1ʳᵉ part.
List<double> customLensRemoveBar(List<double> thresholds) {
  final nextBarCount = thresholds.length;
  if (nextBarCount < 2) return [50];
  final first = thresholds.first;
  if (nextBarCount == 2) return [first];
  final inner = nextBarCount - 1;
  final tail = 100 - first;
  return [
    first,
    for (var k = 1; k < inner; k++) first + tail * k / inner,
  ];
}

/// Modifie le 1er seuil ; les suivants sont reprojetés dans l'espace restant (total = 100 %).
List<double> customLensSetFirstThreshold(
  List<double> thresholds,
  double firstPercent,
) {
  final barCount = thresholds.length + 1;
  final minFirst = kCustomLensMinBandShare;
  final maxFirst = 100 - kCustomLensMinBandShare * (barCount - 1);
  final first = firstPercent.clamp(minFirst, maxFirst);

  if (barCount == 2) return [first];

  final old = customLensPartitionBounds(thresholds);
  final oldFirst = old[1];
  final tailOld = 100 - oldFirst;
  final tailNew = 100 - first;

  final out = <double>[first];
  if (tailOld <= 1e-6 || old.length <= 3) {
    for (var i = 2; i < old.length - 1; i++) {
      final rel = (i - 1) / (barCount - 1);
      out.add(first + tailNew * rel);
    }
    return _enforceMinGaps(out, barCount);
  }

  for (var j = 2; j < old.length - 1; j++) {
    final rel = (old[j] - oldFirst) / tailOld;
    out.add(first + rel * tailNew);
  }
  return _enforceMinGaps(out, barCount);
}

List<double> _enforceMinGaps(List<double> thresholds, int barCount) {
  if (thresholds.isEmpty) return thresholds;
  final bounds = customLensPartitionBounds(thresholds);
  for (var pass = 0; pass < 8; pass++) {
    var changed = false;
    for (var i = 1; i < bounds.length - 1; i++) {
      final minV = bounds[i - 1] + kCustomLensMinBandShare;
      if (bounds[i] < minV) {
        bounds[i] = minV;
        changed = true;
      }
    }
    for (var i = bounds.length - 2; i >= 1; i--) {
      final maxV = bounds[i + 1] - kCustomLensMinBandShare;
      if (bounds[i] > maxV) {
        bounds[i] = maxV;
        changed = true;
      }
    }
    if (!changed) break;
  }
  bounds[bounds.length - 1] = 100;
  return bounds.sublist(1, bounds.length - 1);
}

bool customLensPctInBand(double pct, int bandIndex, List<double> thresholds) {
  final b = customLensPartitionBounds(thresholds);
  final lo = b[bandIndex];
  final hi = b[bandIndex + 1];
  if (bandIndex == b.length - 2) {
    return pct >= lo && pct <= hi;
  }
  return pct >= lo && pct < hi;
}
