import 'package:flutter/foundation.dart';

/// Répartit [total] entre 3 parts proportionnellement à (a,b,c) ; la somme retournée vaut [total].
List<int> _splitThreeProportional(int total, int a, int b, int c) {
  if (total <= 0) return [0, 0, 0];
  final sum = a + b + c;
  if (sum == 0) {
    final q = total ~/ 3;
    final r = total % 3;
    return [
      q + (r > 0 ? 1 : 0),
      q + (r > 1 ? 1 : 0),
      q,
    ];
  }
  final exact = <double>[
    total * a / sum,
    total * b / sum,
    total * c / sum,
  ];
  final floors = exact.map((e) => e.floor()).toList();
  var diff = total - floors[0] - floors[1] - floors[2];
  final frac = List<double>.generate(3, (i) => exact[i] - floors[i]);
  final order = [0, 1, 2]..sort((i, j) => frac[j].compareTo(frac[i]));
  var k = 0;
  while (diff > 0) {
    floors[order[k % 3]]++;
    diff--;
    k++;
  }
  return floors;
}

/// Pondération des 4 impacts + niveaux de confiance par section.
mixin AnalyseControllerImpactConfidence on ChangeNotifier {
  /// Les 4 impacts se partagent toujours 100 % (pondération de l’anneau).
  int _impactFeuille = 25;
  int _impactStructure = 25;
  int _impactIndicators = 25;
  int _impactSmc = 25;

  int get impactFeuille => _impactFeuille;
  set impactFeuille(int v) {
    v = v.clamp(0, 100);
    final rem = 100 - v;
    final parts = _splitThreeProportional(rem, _impactStructure, _impactIndicators, _impactSmc);
    if (v == _impactFeuille &&
        parts[0] == _impactStructure &&
        parts[1] == _impactIndicators &&
        parts[2] == _impactSmc) {
      return;
    }
    _impactFeuille = v;
    _impactStructure = parts[0];
    _impactIndicators = parts[1];
    _impactSmc = parts[2];
    notifyListeners();
  }

  int get impactStructure => _impactStructure;
  set impactStructure(int v) {
    v = v.clamp(0, 100);
    final rem = 100 - v;
    final parts = _splitThreeProportional(rem, _impactFeuille, _impactIndicators, _impactSmc);
    if (v == _impactStructure &&
        parts[0] == _impactFeuille &&
        parts[1] == _impactIndicators &&
        parts[2] == _impactSmc) {
      return;
    }
    _impactStructure = v;
    _impactFeuille = parts[0];
    _impactIndicators = parts[1];
    _impactSmc = parts[2];
    notifyListeners();
  }

  int get impactIndicators => _impactIndicators;
  set impactIndicators(int v) {
    v = v.clamp(0, 100);
    final rem = 100 - v;
    final parts = _splitThreeProportional(rem, _impactFeuille, _impactStructure, _impactSmc);
    if (v == _impactIndicators &&
        parts[0] == _impactFeuille &&
        parts[1] == _impactStructure &&
        parts[2] == _impactSmc) {
      return;
    }
    _impactIndicators = v;
    _impactFeuille = parts[0];
    _impactStructure = parts[1];
    _impactSmc = parts[2];
    notifyListeners();
  }

  int get impactSmc => _impactSmc;
  set impactSmc(int v) {
    v = v.clamp(0, 100);
    final rem = 100 - v;
    final parts = _splitThreeProportional(rem, _impactFeuille, _impactStructure, _impactIndicators);
    if (v == _impactSmc &&
        parts[0] == _impactFeuille &&
        parts[1] == _impactStructure &&
        parts[2] == _impactIndicators) {
      return;
    }
    _impactSmc = v;
    _impactFeuille = parts[0];
    _impactStructure = parts[1];
    _impactIndicators = parts[2];
    notifyListeners();
  }

  /// Annulation du modal d’impact : restaure les 4 valeurs telles qu’à l’ouverture.
  void restoreImpactsSnapshot(int feuille, int structure, int indicators, int smc) {
    _impactFeuille = feuille.clamp(0, 100);
    _impactStructure = structure.clamp(0, 100);
    _impactIndicators = indicators.clamp(0, 100);
    _impactSmc = smc.clamp(0, 100);
    notifyListeners();
  }

  int _confidenceFeuille = 45;
  int get confidenceFeuille => _confidenceFeuille;
  set confidenceFeuille(int v) {
    final nv = v.clamp(0, 100);
    if (nv == _confidenceFeuille) return;
    _confidenceFeuille = nv;
    notifyListeners();
  }

  int _confidenceStructure = 45;
  int get confidenceStructure => _confidenceStructure;
  set confidenceStructure(int v) {
    final nv = v.clamp(0, 100);
    if (nv == _confidenceStructure) return;
    _confidenceStructure = nv;
    notifyListeners();
  }

  int _confidenceIndicators = 45;
  int get confidenceIndicators => _confidenceIndicators;
  set confidenceIndicators(int v) {
    final nv = v.clamp(0, 100);
    if (nv == _confidenceIndicators) return;
    _confidenceIndicators = nv;
    notifyListeners();
  }

  int _confidenceSmc = 45;
  int get confidenceSmc => _confidenceSmc;
  set confidenceSmc(int v) {
    final nv = v.clamp(0, 100);
    if (nv == _confidenceSmc) return;
    _confidenceSmc = nv;
    notifyListeners();
  }
}
