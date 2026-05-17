import 'dart:ui' show Locale;

import 'package:intl/intl.dart' as intl;

import '../ajouter_trade/ajouter_trade_asset_class.dart';
import 'performance_locale_copy.dart';
import 'performance_trade_model.dart';

class TradeAggregates {
  const TradeAggregates({
    required this.wins,
    required this.losses,
    required this.breakeven,
  });

  final int wins;
  final int losses;
  final int breakeven;

  int get total => wins + losses + breakeven;

  double get winrate => total == 0 ? 0.0 : wins / total;
}

TradeAggregates aggregateTrades(List<Trade> trades) {
  var w = 0, l = 0, b = 0;
  for (final t in trades) {
    if (t.profit.abs() < 1e-9) {
      b++;
    } else if (t.profit > 0) {
      w++;
    } else {
      l++;
    }
  }
  return TradeAggregates(wins: w, losses: l, breakeven: b);
}

class DurationBucketStat {
  const DurationBucketStat({required this.label, required this.winRate, required this.count});

  final String label;
  final double winRate;
  final int count;
}

List<DurationBucketStat> durationBucketWinRates(List<Trade> trades) {
  final specs = <(int min, int max, String label)>[
    (0, 15, '0-15 min'),
    (15, 30, '15-30 min'),
    (30, 60, '30m – 1h'),
    (60, 120, '1h – 2h'),
    (120, 240, '2h – 4h'),
    (240, 360, '4h – 6h'),
    (360, 600, '6h – 10h'),
    (600, 720, '10h – 12h'),
    (720, 1000000000, '> 12h'),
  ];
  return specs.map((s) {
    var wins = 0, n = 0;
    for (final t in trades) {
      if (t.durationMinutes >= s.$1 && t.durationMinutes < s.$2) {
        n++;
        if (t.win) wins++;
      }
    }
    final wr = n == 0 ? 0.0 : wins / n;
    return DurationBucketStat(label: s.$3, winRate: wr, count: n);
  }).toList();
}

/// Actif agrégé pour le diagramme en barres (page Performance).
class AssetTradeBarStat {
  const AssetTradeBarStat({
    required this.symbol,
    required this.count,
    required this.winRate,
  });

  final String symbol;
  final int count;
  final double winRate;
}

/// Top actifs par nombre de trades sur la période (barres proportionnelles au volume).
List<AssetTradeBarStat> computeTopAssetBarStats(
  List<Trade> trades, {
  int maxBars = 8,
  AjouterTradeAssetClass? marche,
}) {
  final map = <String, List<Trade>>{};
  for (final t in trades) {
    if (marche != null && t.assetClass != marche) continue;
    final p = t.pair?.trim();
    if (p == null || p.isEmpty) continue;
    map.putIfAbsent(p, () => []).add(t);
  }
  if (map.isEmpty) return [];
  final entries = map.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));
  return [
    for (final e in entries.take(maxBars))
      AssetTradeBarStat(
        symbol: e.key,
        count: e.value.length,
        winRate: e.value.where((t) => t.win).length / e.value.length,
      )
  ];
}

/// Histogramme intensité journalière : nombre de **jours calendaires** (avec au moins un trade) dont le
/// volume du jour tombe dans une tranche **[1–3], [4–5], [6–10], 11+** trades, avec winrate poolé.
class DayIntensityHistogramBucketStat {
  const DayIntensityHistogramBucketStat({
    required this.dayCount,
    required this.tradeCount,
    required this.winRate,
  });

  static const DayIntensityHistogramBucketStat emptyBucket =
      DayIntensityHistogramBucketStat(dayCount: 0, tradeCount: 0, winRate: 0);

  bool get hasData => tradeCount > 0;

  /// Jours actifs tombant dans cette tranche (même jour = trades du [Trade.date] normalisés).
  final int dayCount;

  /// Tous les trades de ces jours (pour le winrate global de la colonne).
  final int tradeCount;

  /// Part des trades « gagnants » dans [tradeCount] ([Trade.win]; aligné imports journal).
  final double winRate;
}

int _histogramBucketIndexForDayTradeCount(int n) {
  if (n <= 0) throw ArgumentError.value(n);
  if (n <= 3) return 0;
  if (n <= 5) return 1;
  if (n <= 10) return 2;
  return 3;
}

DateTime _calendarDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Regroupe les trades par jour calendaire (période filtrée en amont), puis quatre barres pour la page Performance.
List<DayIntensityHistogramBucketStat> computeDayIntensityHistogramBuckets(List<Trade> trades) {
  const kBuckets = 4;
  if (trades.isEmpty) {
    return List<DayIntensityHistogramBucketStat>.filled(
      kBuckets,
      DayIntensityHistogramBucketStat.emptyBucket,
      growable: false,
    );
  }

  final byCalendarDay = <DateTime, List<Trade>>{};
  for (final t in trades) {
    final d = _calendarDay(t.date);
    byCalendarDay.putIfAbsent(d, () => []).add(t);
  }

  final daysPerBucket = List<int>.filled(kBuckets, 0);
  final tradesPerBucket = List.generate(kBuckets, (_) => <Trade>[]);

  for (final e in byCalendarDay.entries) {
    final n = e.value.length;
    final i = _histogramBucketIndexForDayTradeCount(n);
    daysPerBucket[i]++;
    tradesPerBucket[i].addAll(e.value);
  }

  return List.generate(kBuckets, (i) {
    final list = tradesPerBucket[i];
    if (list.isEmpty) return DayIntensityHistogramBucketStat.emptyBucket;
    final wins = list.where((t) => t.win).length;
    return DayIntensityHistogramBucketStat(
      dayCount: daysPerBucket[i],
      tradeCount: list.length,
      winRate: wins / list.length,
    );
  });
}

/// Tranche de durée avec le meilleur winrate (toutes tranches confondues ; ignoré si aucun trade).
DurationBucketStat? pickBestDurationBucketByWinrate(List<DurationBucketStat> buckets) {
  DurationBucketStat? best;
  for (final b in buckets) {
    if (b.count == 0) continue;
    if (best == null || b.winRate > best.winRate) best = b;
  }
  return best;
}

class TimeSlotStat {
  const TimeSlotStat({required this.label, required this.sub, required this.winRate, required this.count});

  final String label;
  final String sub;
  final double winRate;
  final int count;
}

List<TimeSlotStat> timeSlotWinRates(
  List<Trade> trades, {
  required Locale locale,
}) {
  double m(DateTime dt) => dt.hour * 60.0 + dt.minute;
  bool hasTime(Trade t) => t.timeOfDay != null && t.timeOfDay!.isNotEmpty;

  (double wr, int n) slot(bool Function(double) inSlot) {
    var wins = 0, c = 0;
    for (final t in trades) {
      if (!hasTime(t)) continue;
      final mm = m(t.sortKey);
      if (inSlot(mm)) {
        c++;
        if (t.win) wins++;
      }
    }
    return (c == 0 ? 0.0 : wins / c, c);
  }

  final a = slot((mm) => mm >= 9 * 60 && mm < 11 * 60 + 30);
  final b = slot((mm) => mm >= 14 * 60 + 30 && mm < 16 * 60 + 30);
  final c = slot((mm) => mm >= 19 * 60);
  return [
    TimeSlotStat(
      label: '09:00 - 11:30',
      sub: performancePickLocale(locale, '(Début)', '(Start)', '(Inicio)', '(Start)', '(Início)', '(시작)'),
      winRate: a.$1,
      count: a.$2,
    ),
    TimeSlotStat(
      label: '14:30 - 16:30',
      sub: performancePickLocale(locale, '(US Open)', '(US Open)', '(Apertura US)', '(US Open)', '(Abertura EUA)', '(미국장)'),
      winRate: b.$1,
      count: b.$2,
    ),
    TimeSlotStat(
      label: performancePickLocale(locale, '19h00 et +', '19:00+', '19:00+', '19:00+', '19:00+', '19:00+'),
      sub: performancePickLocale(locale, '(Fin/Soir)', '(Evening)', '(Noche)', '(Abend)', '(Fim/Noite)', '(저녁)'),
      winRate: c.$1,
      count: c.$2,
    ),
  ];
}

int winrateDropPercentPoints(SessionFilterResult s) {
  if (s.earlyTotal == 0 || s.lateTotal == 0) return 0;
  return ((s.earlyWinRate - s.lateWinRate) * 100).round().clamp(0, 100);
}

class NamedWinRate {
  const NamedWinRate({required this.label, required this.winRate, required this.count});

  final String label;
  final double winRate;
  final int count;
}

List<NamedWinRate> weekdayWinRates(List<Trade> trades, {required Locale locale}) {
  // Semaine calendaire Mon–Sun alignée sur [trades] : libellés selon la locale de l’app (pas la locale système).
  final baseMonday = DateTime(2024, 1, 1);
  final fmt = intl.DateFormat.E(locale.toString());
  final names = List<String>.generate(7, (i) => fmt.format(baseMonday.add(Duration(days: i))));
  final by = List.generate(7, (_) => <Trade>[]);
  for (final t in trades) {
    final d = t.date.weekday;
    if (d >= 1 && d <= 7) by[d - 1].add(t);
  }
  return List.generate(7, (i) {
    final list = by[i];
    var wins = 0;
    for (final t in list) {
      if (t.win) wins++;
    }
    final n = list.length;
    return NamedWinRate(label: names[i], winRate: n == 0 ? 0.0 : wins / n, count: n);
  });
}

List<NamedWinRate> timeSlotWinRatesNamed(List<Trade> trades, {required Locale locale}) {
  final slots = timeSlotWinRates(trades, locale: locale);
  return [
    for (final s in slots) NamedWinRate(label: s.label, winRate: s.winRate, count: s.count),
  ];
}

List<NamedWinRate> durationBucketWinRatesNamed(List<Trade> trades) {
  final b = durationBucketWinRates(trades);
  return [for (final d in b) NamedWinRate(label: d.label, winRate: d.winRate, count: d.count)];
}

List<NamedWinRate> profitAmplitudeBuckets(List<Trade> trades) {
  const labels = ['Micro (< 30)', 'Mini (30–100)', 'Standard (> 100)'];
  final buckets = List.generate(3, (_) => <Trade>[]);
  for (final t in trades) {
    final a = t.profit.abs();
    if (a < 30) {
      buckets[0].add(t);
    } else if (a <= 100) {
      buckets[1].add(t);
    } else {
      buckets[2].add(t);
    }
  }
  return List.generate(3, (i) {
    final list = buckets[i];
    var wins = 0;
    for (final t in list) {
      if (t.win) wins++;
    }
    final n = list.length;
    return NamedWinRate(label: labels[i], winRate: n == 0 ? 0.0 : wins / n, count: n);
  });
}

List<double> cumulativeProfitSeries(List<Trade> trades) {
  if (trades.isEmpty) return [];
  final sorted = [...trades]..sort((a, b) => a.sortKey.compareTo(b.sortKey));
  var cum = 0.0;
  final out = <double>[];
  for (final t in sorted) {
    cum += t.profit;
    out.add(cum);
  }
  return out;
}

double _winRateFromTrades(List<Trade> list) {
  if (list.isEmpty) return 0.0;
  var w = 0;
  for (final t in list) {
    if (t.win) w++;
  }
  return w / list.length;
}

/// Winrate selon le nombre de trades **le même jour** (journée = date du trade).
/// Tranches : 1–5, 6–10, >10 (sans chevauchement).
class DailyJournalVolumeBucketStat {
  const DailyJournalVolumeBucketStat({
    required this.label,
    required this.winRate,
    required this.tradeCount,
    required this.dayCount,
  });

  final String label;
  final double winRate;
  final int tradeCount;
  final int dayCount;
}

List<DailyJournalVolumeBucketStat> dailyJournalVolumeBucketWinRates(List<Trade> trades) {
  // Backward-compatible default for older call sites.
  return dailyJournalVolumeBucketWinRatesLocalized(trades, locale: const Locale('en'));
}

List<DailyJournalVolumeBucketStat> dailyJournalVolumeBucketWinRatesLocalized(
  List<Trade> trades, {
  required Locale locale,
}) {
  final labels = [
    performancePickLocale(
      locale,
      '1 – 5 trades / jour',
      '1–5 trades/day',
      '1–5 trades/día',
      '1–5 Trades/Tag',
      '1–5 trades/dia',
      '하루 1–5회 트레이드',
    ),
    performancePickLocale(
      locale,
      '6 – 10 trades / jour',
      '6–10 trades/day',
      '6–10 trades/día',
      '6–10 Trades/Tag',
      '6–10 trades/dia',
      '하루 6–10회 트레이드',
    ),
    performancePickLocale(
      locale,
      '> 10 trades / jour',
      '> 10 trades/day',
      '> 10 trades/día',
      '> 10 Trades/Tag',
      '> 10 trades/dia',
      '하루 10회 초과 트레이드',
    ),
  ];
  final buckets = List.generate(3, (_) => <Trade>[]);
  final daysPerBucket = List.filled(3, 0);

  final byDay = <DateTime, List<Trade>>{};
  for (final t in trades) {
    final d = DateTime(t.date.year, t.date.month, t.date.day);
    byDay.putIfAbsent(d, () => []).add(t);
  }

  for (final e in byDay.entries) {
    final n = e.value.length;
    if (n >= 1 && n <= 5) {
      buckets[0].addAll(e.value);
      daysPerBucket[0]++;
    } else if (n >= 6 && n <= 10) {
      buckets[1].addAll(e.value);
      daysPerBucket[1]++;
    } else if (n > 10) {
      buckets[2].addAll(e.value);
      daysPerBucket[2]++;
    }
  }

  return [
    for (var i = 0; i < 3; i++)
      DailyJournalVolumeBucketStat(
        label: labels[i],
        winRate: _winRateFromTrades(buckets[i]),
        tradeCount: buckets[i].length,
        dayCount: daysPerBucket[i],
      ),
  ];
}
