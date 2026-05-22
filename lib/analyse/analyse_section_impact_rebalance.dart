/// Répartit 100 % d'impact entre les sections dont l'interrupteur est actif.
List<int> rebalanceImpactsAmongActiveSections({
  required int feuille,
  required int structure,
  required int indicators,
  required int smc,
  required bool contextEnabled,
  required bool structureEnabled,
  required bool indicatorsEnabled,
  required bool smcEnabled,
}) {
  final raw = <int>[
    contextEnabled ? feuille : 0,
    structureEnabled ? structure : 0,
    indicatorsEnabled ? indicators : 0,
    smcEnabled ? smc : 0,
  ];
  final active = <int>[];
  final activeIdx = <int>[];
  for (var i = 0; i < 4; i++) {
    final on = switch (i) {
      0 => contextEnabled,
      1 => structureEnabled,
      2 => indicatorsEnabled,
      _ => smcEnabled,
    };
    if (on) {
      // Poids 0 (section réactivée) → 1 pour une part proportionnelle non nulle.
      active.add(raw[i] > 0 ? raw[i] : 1);
      activeIdx.add(i);
    }
  }
  if (active.isEmpty) {
    return [0, 0, 0, 0];
  }
  final parts = _splitProportional(100, active);
  final out = [0, 0, 0, 0];
  for (var j = 0; j < activeIdx.length; j++) {
    out[activeIdx[j]] = parts[j];
  }
  return out;
}

List<int> _splitProportional(int total, List<int> weights) {
  final n = weights.length;
  if (n == 0) return [];
  if (total <= 0) return List.filled(n, 0);
  final sum = weights.fold<int>(0, (a, b) => a + b);
  if (sum == 0) {
    final q = total ~/ n;
    final r = total % n;
    return List.generate(n, (i) => q + (i < r ? 1 : 0));
  }
  final exact = [for (final w in weights) total * w / sum];
  final floors = exact.map((e) => e.floor()).toList();
  var diff = total - floors.fold<int>(0, (a, b) => a + b);
  final frac = List<double>.generate(n, (i) => exact[i] - floors[i]);
  final order = List.generate(n, (i) => i)..sort((a, b) => frac[b].compareTo(frac[a]));
  var k = 0;
  while (diff > 0) {
    floors[order[k % n]]++;
    diff--;
    k++;
  }
  return floors;
}
