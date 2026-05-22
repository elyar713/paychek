import 'performance_custom_lens_model.dart';
import 'performance_custom_lens_partitions.dart';
import 'performance_trade_model.dart';

double _rate(int wins, int total) => total == 0 ? 0.0 : wins / total;

bool performanceCustomLensTradeHasElement(
  Trade t,
  PerformanceCustomLensDimension dimension,
  String elementId,
) {
  if (elementId.isEmpty || t.performanceLite) return false;
  switch (dimension) {
    case PerformanceCustomLensDimension.etat:
      if (elementId == 'etat_sleep') return false;
      if (elementId.startsWith('psych:')) {
        final tag = elementId.substring('psych:'.length);
        return t.psychTags.contains(tag);
      }
      if (elementId.startsWith('factor:')) {
        return t.etatNonRespectIds?.contains(elementId) ?? false;
      }
      return t.etatNonRespectIds?.contains(elementId) ?? false;
    case PerformanceCustomLensDimension.checklist:
      return t.checklistNonRespectIds?.contains(elementId) ?? false;
    case PerformanceCustomLensDimension.plan:
      return t.planNonRespectIds?.contains(elementId) ?? false;
    case PerformanceCustomLensDimension.strategie:
      return t.strategieNonRespectIds?.contains(elementId) ?? false;
  }
}

double? performanceCustomLensPctForTrade(
  Trade t,
  PerformanceCustomLensDimension dimension,
) {
  switch (dimension) {
    case PerformanceCustomLensDimension.etat:
      return t.etatPct;
    case PerformanceCustomLensDimension.checklist:
      return t.checklistPct;
    case PerformanceCustomLensDimension.plan:
      return t.planPct;
    case PerformanceCustomLensDimension.strategie:
      return t.strategiePct;
  }
}

List<PerformanceCustomLensElementOption> performanceCustomLensElementCatalog(
  List<Trade> trades,
  PerformanceCustomLensDimension dimension,
) {
  final counts = <String, int>{};
  for (final t in trades) {
    if (t.performanceLite) continue;
    switch (dimension) {
      case PerformanceCustomLensDimension.etat:
        for (final id in t.etatNonRespectIds ?? const <String>{}) {
          counts[id] = (counts[id] ?? 0) + 1;
        }
        for (final tag in t.psychTags) {
          final id = 'psych:$tag';
          counts[id] = (counts[id] ?? 0) + 1;
        }
      case PerformanceCustomLensDimension.checklist:
        for (final id in t.checklistNonRespectIds ?? const <String>{}) {
          counts[id] = (counts[id] ?? 0) + 1;
        }
      case PerformanceCustomLensDimension.plan:
        for (final id in t.planNonRespectIds ?? const <String>{}) {
          counts[id] = (counts[id] ?? 0) + 1;
        }
      case PerformanceCustomLensDimension.strategie:
        for (final id in t.strategieNonRespectIds ?? const <String>{}) {
          counts[id] = (counts[id] ?? 0) + 1;
        }
    }
  }
  final ids = counts.keys.toList()
    ..sort((a, b) {
      final c = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
      if (c != 0) return c;
      return a.compareTo(b);
    });
  return [
    for (final id in ids)
      PerformanceCustomLensElementOption(
        id: id,
        label: id,
        tradeHits: counts[id] ?? 0,
      ),
  ];
}

String performanceCustomLensBandLabel({
  required int bandIndex,
  required List<double> thresholds,
  required String Function(
    String fr,
    String en,
    String es,
    String de,
    String pt,
    String ko,
  )
  txt,
}) {
  final barCount = thresholds.length + 1;
  final b = customLensPartitionBounds(thresholds);

  if (barCount == 2) {
    final t = thresholds.first.round();
    final share0 = customLensBandSharePercent(thresholds, 0).round();
    final share1 = customLensBandSharePercent(thresholds, 1).round();
    final equalSplit = (share0 - 50).abs() <= 1 && (share1 - 50).abs() <= 1;
    if (equalSplit) {
      if (bandIndex == 0) {
        return txt('<$t %', '<$t%', '<$t %', '<$t %', '<$t %', '<$t%');
      }
      return txt('>$t %', '>$t%', '>$t %', '>$t %', '>$t %', '>$t%');
    }
    final share = bandIndex == 0 ? share0 : share1;
    return txt(
      '$share %',
      '$share%',
      '$share %',
      '$share %',
      '$share %',
      '$share%',
    );
  }

  if (bandIndex == 0) {
    final hi = b[1].round();
    return txt('<$hi %', '<$hi%', '<$hi %', '<$hi %', '<$hi %', '<$hi%');
  }
  if (bandIndex == barCount - 1) {
    final lo = b[bandIndex].round();
    return txt('>$lo %', '>$lo%', '>$lo %', '>$lo %', '>$lo %', '>$lo%');
  }
  final lo = b[bandIndex].round();
  final hi = b[bandIndex + 1].round();
  return txt(
    '$lo – $hi %',
    '$lo–$hi%',
    '$lo – $hi %',
    '$lo – $hi %',
    '$lo – $hi %',
    '$lo–$hi%',
  );
}

List<PerformanceCustomLensBandStat> performanceCustomLensBandStats({
  required List<Trade> trades,
  required PerformanceCustomLensConfig config,
  required String Function(
    String fr,
    String en,
    String es,
    String de,
    String pt,
    String ko,
  )
  txt,
}) {
  final thresholds = config.sortedThresholds;
  final barCount = config.barCount;
  if (config.elementId.isEmpty) {
    return [
      for (var i = 0; i < barCount; i++)
        PerformanceCustomLensBandStat(
          label: performanceCustomLensBandLabel(
            bandIndex: i,
            thresholds: thresholds,
            txt: txt,
          ),
          sharePercent: customLensBandSharePercent(thresholds, i),
          winRate: 0,
          tradeCount: 0,
        ),
    ];
  }

  final pool = trades.where((t) {
    if (t.performanceLite) return false;
    if (!performanceCustomLensTradeHasElement(
      t,
      config.dimension,
      config.elementId,
    )) {
      return false;
    }
    return performanceCustomLensPctForTrade(t, config.dimension) != null;
  }).toList();

  final out = <PerformanceCustomLensBandStat>[];
  for (var i = 0; i < barCount; i++) {
    var wins = 0, n = 0;
    for (final t in pool) {
      final p = performanceCustomLensPctForTrade(t, config.dimension)!;
      if (!customLensPctInBand(p, i, thresholds)) continue;
      n++;
      if (t.win) wins++;
    }
    out.add(
      PerformanceCustomLensBandStat(
        label: performanceCustomLensBandLabel(
          bandIndex: i,
          thresholds: thresholds,
          txt: txt,
        ),
        sharePercent: customLensBandSharePercent(thresholds, i),
        winRate: _rate(wins, n),
        tradeCount: n,
      ),
    );
  }
  return out;
}
