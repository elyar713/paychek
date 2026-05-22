/// Configuration de la carte « discipline personnalisée » (Performance).
enum PerformanceCustomLensDimension { etat, checklist, plan, strategie }

class PerformanceCustomLensConfig {
  const PerformanceCustomLensConfig({
    required this.dimension,
    required this.elementId,
    required this.thresholds,
  });

  final PerformanceCustomLensDimension dimension;
  final String elementId;

  /// Seuils ascendants en % (0–100) ; `n` seuils ⇒ `n + 1` barres.
  final List<double> thresholds;

  static const int maxBars = 5;
  static const int minBars = 2;

  factory PerformanceCustomLensConfig.defaults() =>
      const PerformanceCustomLensConfig(
        dimension: PerformanceCustomLensDimension.etat,
        elementId: '',
        thresholds: [50],
      );

  int get barCount => thresholds.length + 1;

  List<double> get sortedThresholds {
    final t = thresholds.map((e) => e.clamp(1.0, 99.0)).toList()..sort();
    return t;
  }

  PerformanceCustomLensConfig copyWith({
    PerformanceCustomLensDimension? dimension,
    String? elementId,
    List<double>? thresholds,
  }) {
    return PerformanceCustomLensConfig(
      dimension: dimension ?? this.dimension,
      elementId: elementId ?? this.elementId,
      thresholds: thresholds ?? List<double>.from(this.thresholds),
    );
  }

  Map<String, dynamic> toJson() => {
    'dimension': dimension.index,
    'elementId': elementId,
    'thresholds': thresholds,
  };

  factory PerformanceCustomLensConfig.fromJson(Map<String, dynamic> json) {
    final dim = json['dimension'];
    final dimension =
        dim is int &&
            dim >= 0 &&
            dim < PerformanceCustomLensDimension.values.length
        ? PerformanceCustomLensDimension.values[dim]
        : PerformanceCustomLensDimension.etat;
    final rawT = json['thresholds'];
    final thresholds = <double>[];
    if (rawT is List) {
      for (final e in rawT) {
        if (e is num) thresholds.add(e.toDouble().clamp(1.0, 99.0));
      }
    }
    if (thresholds.isEmpty) thresholds.add(50);
    while (thresholds.length >= PerformanceCustomLensConfig.maxBars) {
      thresholds.removeLast();
    }
    return PerformanceCustomLensConfig(
      dimension: dimension,
      elementId: json['elementId'] is String ? json['elementId'] as String : '',
      thresholds: thresholds,
    );
  }
}

class PerformanceCustomLensElementOption {
  const PerformanceCustomLensElementOption({
    required this.id,
    required this.label,
    required this.tradeHits,
  });

  final String id;
  final String label;
  final int tradeHits;
}

/// Carte enregistrée via « Ajouter » (affichée au-dessus du brouillon).
class PerformanceCustomLensSavedCard {
  const PerformanceCustomLensSavedCard({
    required this.id,
    required this.config,
    required this.savedAtMillis,
  });

  final String id;
  final PerformanceCustomLensConfig config;
  final int savedAtMillis;

  Map<String, dynamic> toJson() => {
    'id': id,
    'config': config.toJson(),
    'savedAtMillis': savedAtMillis,
  };

  factory PerformanceCustomLensSavedCard.fromJson(Map<String, dynamic> json) {
    final cfg = json['config'];
    return PerformanceCustomLensSavedCard(
      id: json['id'] is String ? json['id'] as String : '',
      config: cfg is Map<String, dynamic>
          ? PerformanceCustomLensConfig.fromJson(cfg)
          : PerformanceCustomLensConfig.defaults(),
      savedAtMillis: json['savedAtMillis'] is int
          ? json['savedAtMillis'] as int
          : 0,
    );
  }
}

class PerformanceCustomLensBandStat {
  const PerformanceCustomLensBandStat({
    required this.label,
    required this.sharePercent,
    required this.winRate,
    required this.tradeCount,
  });

  final String label;

  /// Part du score discipline (0–100) couverte par cette barre ; la somme des barres = 100.
  final double sharePercent;
  final double winRate;
  final int tradeCount;

  bool get hasData => tradeCount > 0;
}
