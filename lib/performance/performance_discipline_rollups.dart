import 'package:flutter/material.dart';

import '../ajouter_trade/ajouter_trade_asset_class.dart';
import 'performance_trade_model.dart';

double _rate(int wins, int total) => total == 0 ? 0.0 : wins / total;

bool _hasDiscipline(Trade t) =>
    t.checklistPct != null ||
    t.planPct != null ||
    t.strategiePct != null ||
    t.etatPct != null;

/// Couleurs d'identification Paychek Lens (texte).
const Color kLensEtat = Color(0xFF4FC3F7);
const Color kLensChecklist = Color(0xFF66BB6A);
const Color kLensStrategie = Color(0xFFFFCA28);
const Color kLensPlan = Color(0xFFCE93D8);
const Color kLensAccentNum = Color(0xFFFFFFFF);
const Color kLensLoss = Color(0xFFFF6B6B);
const Color kLensDuration = Color(0xFF90CAF9);
const Color kLensWinrate = Color(0xFF69F0AE);

/// Moyennes discipline sur les trades où au moins un pourcentage est renseigné.
class DisciplineRollups {
  const DisciplineRollups({
    required this.countWithAnyDisciplineField,
    required this.avgChecklist,
    required this.avgPlan,
    required this.avgStrategie,
    required this.avgEtat,
    required this.compositeDisciplinePct,
  });

  final int countWithAnyDisciplineField;
  final double avgChecklist;
  final double avgPlan;
  final double avgStrategie;
  final double avgEtat;

  /// Moyenne des axes discipline (checklist, analyse, stratégie, état) pour lesquels au moins une valeur existe (0–100).
  final double compositeDisciplinePct;

  bool get hasData => countWithAnyDisciplineField > 0;
}

DisciplineRollups computeDisciplineRollups(List<Trade> trades) {
  var sumCl = 0.0, sumPl = 0.0, sumSt = 0.0, sumEt = 0.0;
  var nCl = 0, nPl = 0, nSt = 0, nEt = 0;
  var any = 0;
  for (final t in trades) {
    if (!_hasDiscipline(t)) continue;
    any++;
    final c = t.checklistPct;
    if (c != null) {
      sumCl += c;
      nCl++;
    }
    final p = t.planPct;
    if (p != null) {
      sumPl += p;
      nPl++;
    }
    final s = t.strategiePct;
    if (s != null) {
      sumSt += s;
      nSt++;
    }
    final e = t.etatPct;
    if (e != null) {
      sumEt += e;
      nEt++;
    }
  }
  final avgChecklist = nCl == 0 ? 0.0 : sumCl / nCl;
  final avgPlan = nPl == 0 ? 0.0 : sumPl / nPl;
  final avgStrategie = nSt == 0 ? 0.0 : sumSt / nSt;
  final avgEtat = nEt == 0 ? 0.0 : sumEt / nEt;
  final compositeParts = <double>[
    if (nCl > 0) avgChecklist,
    if (nPl > 0) avgPlan,
    if (nSt > 0) avgStrategie,
    if (nEt > 0) avgEtat,
  ];
  final compositeDisciplinePct = compositeParts.isEmpty
      ? 0.0
      : compositeParts.reduce((a, b) => a + b) / compositeParts.length;

  return DisciplineRollups(
    countWithAnyDisciplineField: any,
    avgChecklist: avgChecklist,
    avgPlan: avgPlan,
    avgStrategie: avgStrategie,
    avgEtat: avgEtat,
    compositeDisciplinePct: compositeDisciplinePct,
  );
}

(double wr, int n) winRateDisciplinePctBand(
  List<Trade> trades,
  double? Function(Trade t) getPct,
  bool Function(double pct) inBand,
) {
  var wins = 0, nTr = 0;
  for (final t in trades) {
    final p = getPct(t);
    if (p == null) continue;
    if (!inBand(p)) continue;
    nTr++;
    if (t.win) wins++;
  }
  return (_rate(wins, nTr), nTr);
}

(double wr, int n) winRateChecklistBand(
    List<Trade> trades, bool Function(double pct) inBand) {
  return winRateDisciplinePctBand(trades, (t) => t.checklistPct, inBand);
}

(double wr, int n) winRatePlanBand(
    List<Trade> trades, bool Function(double pct) inBand) {
  return winRateDisciplinePctBand(trades, (t) => t.planPct, inBand);
}

(double wr, int n) winRateEtatBand(
    List<Trade> trades, bool Function(double pct) inBand) {
  return winRateDisciplinePctBand(trades, (t) => t.etatPct, inBand);
}

(double wrHigh, int nHigh, double wrLow, int nLow) winRatesStrategieHighVsForced(
    List<Trade> trades) {
  const highThreshold = 50.0;
  const lowThreshold = 50.0;
  var wH = 0, tH = 0, wL = 0, tL = 0;
  for (final t in trades) {
    final p = t.strategiePct;
    if (p == null) continue;
    if (p >= highThreshold) {
      tH++;
      if (t.win) wH++;
    } else if (p < lowThreshold) {
      tL++;
      if (t.win) wL++;
    }
  }
  return (_rate(wH, tH), tH, _rate(wL, tL), tL);
}

/// Winrate par titre de setup (champ stratégie du journal), aligné sur la page Stratégie.
class StrategieSetupWinStat {
  const StrategieSetupWinStat({
    required this.title,
    required this.winRate,
    required this.count,
  });

  final String title;
  final double winRate;
  final int count;
}

/// [orderedSetupTitles] d'abord (ex. [StrategieSetupsStore]), puis titres seulement présents dans les trades (triés).
List<StrategieSetupWinStat> winRatesByStrategieSetupTitles(
  List<Trade> trades,
  List<String> orderedSetupTitles,
) {
  final map = <String, ({int w, int n})>{};
  for (final tr in trades) {
    final title = tr.strategieTitle?.trim();
    if (title == null || title.isEmpty) continue;
    final cur = map[title] ?? (w: 0, n: 0);
    map[title] = (w: cur.w + (tr.win ? 1 : 0), n: cur.n + 1);
  }
  final seen = <String>{};
  final out = <StrategieSetupWinStat>[];
  for (final title in orderedSetupTitles) {
    seen.add(title);
    final s = map[title];
    final n = s?.n ?? 0;
    final wr = n == 0 ? 0.0 : s!.w / n;
    out.add(StrategieSetupWinStat(title: title, winRate: wr, count: n));
  }
  final rest = map.keys.where((k) => !seen.contains(k)).toList()..sort();
  for (final k in rest) {
    final s = map[k]!;
    out.add(StrategieSetupWinStat(title: k, winRate: s.w / s.n, count: s.n));
  }
  return out;
}

/// Feeling seul compte comme Feeling ; tout le reste (dont `null`) = Principe.
(double wrP, int nP, double wrF, int nF) winRatesMindsetPrincipeFeeling(
    List<Trade> trades) {
  var wP = 0, tP = 0, wF = 0, tF = 0;
  for (final t in trades) {
    if (t.mindsetPrincipe == false) {
      tF++;
      if (t.win) wF++;
    } else {
      tP++;
      if (t.win) wP++;
    }
  }
  return (_rate(wP, tP), tP, _rate(wF, tF), tF);
}

double worstSingleLoss(List<Trade> trades) {
  if (trades.isEmpty) return 0.0;
  var m = 0.0;
  for (final t in trades) {
    if (t.profit < m) m = t.profit;
  }
  return m;
}

double averageDurationMinutes(List<Trade> trades) {
  if (trades.isEmpty) return 0.0;
  var s = 0;
  for (final t in trades) {
    s += t.durationMinutes;
  }
  return s / trades.length;
}

class VolumeBucketStat {
  const VolumeBucketStat({
    required this.label,
    required this.winRate,
    required this.count,
  });

  final String label;
  final double winRate;
  final int count;
}

/// Winrate par taille de lot (micro &lt; 0,10 ; mini 0,10–0,99 ; standard ≥ 1,00).
List<VolumeBucketStat> volumeBucketWinRates(List<Trade> trades) {
  final specs = <(bool Function(double), String label)>[
    ((l) => l < 0.1, 'Micro (< 0,10 Lot)'),
    ((l) => l >= 0.1 && l < 1.0, 'Mini (0,10 – 0,99 Lot)'),
    ((l) => l >= 1.0, 'Standard (≥ 1,00 Lot)'),
  ];
  return specs.map((s) {
    var wins = 0, n = 0;
    for (final t in trades) {
      final lot = t.lotSize;
      if (lot == null) continue;
      if (!s.$1(lot)) continue;
      n++;
      if (t.win) wins++;
    }
    final wr = n == 0 ? 0.0 : wins / n;
    return VolumeBucketStat(label: s.$2, winRate: wr, count: n);
  }).toList();
}

/// Tranches affichées selon le « marché » choisi (UI Performance) — mêmes ordres de grandeur qu'Ajouter un trade.
List<VolumeBucketStat> volumeBucketWinRatesForMarche(
  List<Trade> trades,
  AjouterTradeAssetClass marche,
) {
  final scoped = trades
      .where((t) => (t.assetClass ?? AjouterTradeAssetClass.forex) == marche)
      .toList();
  switch (marche) {
    case AjouterTradeAssetClass.indice:
    case AjouterTradeAssetClass.future:
    case AjouterTradeAssetClass.stock:
      final specs = <(bool Function(double), String label)>[
        ((l) => l >= 1 && l < 3, '1 – 3 Lot'),
        ((l) => l >= 3 && l < 5, '3 – 5 Lot'),
        ((l) => l >= 5, '> 5 Lot'),
      ];
      return specs.map((s) {
        var wins = 0, n = 0;
        for (final t in scoped) {
          final lot = t.lotSize;
          if (lot == null) continue;
          if (!s.$1(lot)) continue;
          n++;
          if (t.win) wins++;
        }
        final wr = n == 0 ? 0.0 : wins / n;
        return VolumeBucketStat(label: s.$2, winRate: wr, count: n);
      }).toList();
    default:
      return volumeBucketWinRates(scoped);
  }
}

/// Comptage des points stratégie non respectés (clé = stratégie + id).
class StrategieViolationAgg {
  const StrategieViolationAgg({
    required this.id,
    required this.strategieTitle,
    required this.count,
  });

  final String id;
  final String strategieTitle;
  final int count;
}

List<StrategieViolationAgg> aggregateStrategieNonRespect(List<Trade> trades) {
  const sep = '\u001E';
  final m = <String, int>{};
  for (final t in trades) {
    final ids = t.strategieNonRespectIds;
    if (ids == null || ids.isEmpty) continue;
    final st = t.strategieTitle ?? '';
    for (final id in ids) {
      final k = '$st$sep$id';
      m[k] = (m[k] ?? 0) + 1;
    }
  }
  final out = <StrategieViolationAgg>[];
  for (final e in m.entries) {
    final parts = e.key.split(sep);
    if (parts.length != 2) continue;
    out.add(StrategieViolationAgg(id: parts[1], strategieTitle: parts[0], count: e.value));
  }
  out.sort((a, b) => b.count.compareTo(a.count));
  return out;
}
