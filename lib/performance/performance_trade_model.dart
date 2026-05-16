library;

import '../ajouter_trade/ajouter_trade_asset_class.dart';

/// Modèle [Trade] et parsing CSV / helpers de dates (journal ou import historique).

class Trade {
  const Trade({
    required this.date,
    this.timeOfDay,
    required this.durationMinutes,
    required this.profit,
    required this.win,
    this.commission = 0,
    /// Renseignés quand le trade vient du journal (discipline).
    this.checklistPct,
    this.planPct,
    this.strategiePct,
    this.etatPct,
    /// `true` = Principe, `false` = Feeling ; `null` traité comme Principe dans les stats.
    this.mindsetPrincipe,
    /// Lot parsé depuis la quantité (journal) ; `null` si absent.
    this.lotSize,
    this.strategieTitle,
    /// Points stratégie cochés « non respectés » (journal).
    this.strategieNonRespectIds,
    this.assetClass,
    this.pair,
    this.avantNews = false,
    this.apresNews = false,
    this.performanceLite = false,
  });

  final DateTime date;
  final String? timeOfDay;
  final int durationMinutes;
  final double profit;
  final bool win;
  final double commission;

  /// Pourcentages 0–100 issus du journal ; `null` si non disponible.
  final double? checklistPct;
  final double? planPct;
  final double? strategiePct;
  final double? etatPct;
  final bool? mindsetPrincipe;

  final double? lotSize;

  final String? strategieTitle;

  final Set<String>? strategieNonRespectIds;

  final AjouterTradeAssetClass? assetClass;

  /// Symbole actif (journal) — ex. EURUSD, AAPL.
  final String? pair;

  final bool avantNews;
  final bool apresNews;

  /// Entrée journal sans champs discipline (voir [TradeListItem.performanceLite]).
  final bool performanceLite;

  DateTime get sortKey {
    final t = timeOfDay;
    if (t == null || t.isEmpty) return DateTime(date.year, date.month, date.day);
    final p = t.split(':');
    if (p.length >= 2) {
      final h = int.tryParse(p[0].trim()) ?? 0;
      final m = int.tryParse(p[1].trim()) ?? 0;
      return DateTime(date.year, date.month, date.day, h, m);
    }
    return DateTime(date.year, date.month, date.day);
  }
}

class SessionFilterResult {
  const SessionFilterResult({
    required this.earlyWinRate,
    required this.lateWinRate,
    required this.earlyWins,
    required this.earlyTotal,
    required this.lateWins,
    required this.lateTotal,
  });

  final double earlyWinRate;
  final double lateWinRate;
  final int earlyWins;
  final int earlyTotal;
  final int lateWins;
  final int lateTotal;
}

class DurationCorrelationResult {
  const DurationCorrelationResult({
    required this.avgProfitNear15,
    required this.avgProfitNear60,
    required this.count15,
    required this.count60,
  });

  final double avgProfitNear15;
  final double avgProfitNear60;
  final int count15;
  final int count60;
}

double _rate(int wins, int total) => total == 0 ? 0.0 : wins / total;

SessionFilterResult sessionFilterFirstTwoVsRest(List<Trade> trades) {
  final byDay = <String, List<Trade>>{};
  for (final t in trades) {
    final k = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
    byDay.putIfAbsent(k, () => []).add(t);
  }
  var earlyWins = 0, earlyTotal = 0;
  var lateWins = 0, lateTotal = 0;
  for (final list in byDay.values) {
    list.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    for (var i = 0; i < list.length; i++) {
      final tr = list[i];
      if (i < 2) {
        earlyTotal++;
        if (tr.win) earlyWins++;
      } else {
        lateTotal++;
        if (tr.win) lateWins++;
      }
    }
  }
  return SessionFilterResult(
    earlyWinRate: _rate(earlyWins, earlyTotal),
    lateWinRate: _rate(lateWins, lateTotal),
    earlyWins: earlyWins,
    earlyTotal: earlyTotal,
    lateWins: lateWins,
    lateTotal: lateTotal,
  );
}

DurationCorrelationResult durationCorrelation15vs60(List<Trade> trades) {
  const near15 = (min: 10, max: 22);
  const near60 = (min: 50, max: 75);
  final p15 = <double>[];
  final p60 = <double>[];
  for (final t in trades) {
    final d = t.durationMinutes;
    if (d >= near15.min && d <= near15.max) p15.add(t.profit);
    if (d >= near60.min && d <= near60.max) p60.add(t.profit);
  }
  double avg(List<double> xs) =>
      xs.isEmpty ? 0.0 : xs.reduce((a, b) => a + b) / xs.length;
  return DurationCorrelationResult(
    avgProfitNear15: avg(p15),
    avgProfitNear60: avg(p60),
    count15: p15.length,
    count60: p60.length,
  );
}

String _normHeader(String s) =>
    s.trim().toLowerCase().replaceAll('é', 'e').replaceAll(' ', '_');

double? _parseDoubleLoose(String s) {
  final t = s.trim().replaceAll(' ', '').replaceAll(',', '.');
  return double.tryParse(t);
}

bool _parseBoolLoose(String s) {
  final v = s.trim().toLowerCase();
  if (v == '1' || v == 'true' || v == 'oui' || v == 'yes' || v == 'gagne' || v == 'win') {
    return true;
  }
  if (v == '0' || v == 'false' || v == 'non' || v == 'no' || v == 'perdu' || v == 'loss') {
    return false;
  }
  return false;
}

/// Parse CSV (séparateur , ou ;). Colonnes : date, time, duration_min / duration, profit, win.
List<Trade> parsePerformanceCsv(String raw) {
  var text = raw.trim();
  if (text.startsWith('\uFEFF')) text = text.substring(1);
  final lines = text.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) return [];

  final sep = lines.first.contains(';') && !lines.first.contains(',') ? ';' : ',';
  List<String> splitLine(String line) =>
      line.split(sep).map((e) => e.trim().replaceAll('"', '')).toList();

  final header = splitLine(lines.first).map(_normHeader).toList();
  int idx(List<String> names) {
    for (var i = 0; i < header.length; i++) {
      if (names.contains(header[i])) return i;
    }
    for (var i = 0; i < header.length; i++) {
      for (final n in names) {
        if (header[i].startsWith(n) || header[i].endsWith(n)) return i;
      }
    }
    return -1;
  }

  final iDate = idx(['date', 'jour', 'day']);
  final iTime = idx(['time', 'heure', 'hour']);
  final iDur = idx(['duration_min', 'duration', 'duree', 'duree_min']);
  final iProfit = idx(['profit', 'pnl', 'resultat', 'gain']);
  final iWin = idx(['win', 'success', 'gagne']);
  final iComm = idx(['commission', 'commissions', 'fee', 'frais', 'frais_commission']);

  if (iDate < 0 || iDur < 0) {
    throw FormatException('CSV : colonnes date et duration_min (ou duration) requises.');
  }

  final out = <Trade>[];
  for (var li = 1; li < lines.length; li++) {
    final cells = splitLine(lines[li]);
    String cell(int i) => i >= 0 && i < cells.length ? cells[i] : '';

    final ds = cell(iDate);
    DateTime? date;
    for (final pattern in [
      (String s) => DateTime.tryParse(s),
      (String s) {
        final p = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
        if (p == null) return null;
        return DateTime(int.parse(p.group(1)!), int.parse(p.group(2)!), int.parse(p.group(3)!));
      },
      (String s) {
        final p = RegExp(r'^(\d{2})/(\d{2})/(\d{4})').firstMatch(s);
        if (p == null) return null;
        return DateTime(int.parse(p.group(3)!), int.parse(p.group(2)!), int.parse(p.group(1)!));
      },
    ]) {
      date = pattern(ds);
      if (date != null) break;
    }
    if (date == null) continue;

    final durStr = cell(iDur);
    final durMatch = RegExp(r'\d+').firstMatch(durStr);
    final dur = int.tryParse(durMatch?.group(0) ?? '') ??
        _parseDoubleLoose(durStr)?.round() ??
        0;

    final profitStr = cell(iProfit);
    final profit = _parseDoubleLoose(profitStr.isEmpty ? '0' : profitStr) ?? 0.0;

    bool win;
    if (iWin >= 0 && cell(iWin).isNotEmpty) {
      win = _parseBoolLoose(cell(iWin));
    } else {
      win = profit > 0;
    }

    final commission = iComm >= 0 ? (_parseDoubleLoose(cell(iComm)) ?? 0.0) : 0.0;

    final tim = iTime >= 0 ? cell(iTime) : null;

    out.add(Trade(
      date: DateTime(date.year, date.month, date.day),
      timeOfDay: tim?.isEmpty ?? true ? null : tim,
      durationMinutes: dur,
      profit: profit,
      win: win,
      commission: commission,
      checklistPct: null,
      planPct: null,
      strategiePct: null,
      etatPct: null,
      mindsetPrincipe: null,
      lotSize: null,
      strategieTitle: null,
      strategieNonRespectIds: null,
      assetClass: null,
      pair: null,
      avantNews: false,
      apresNews: false,
      performanceLite: false,
    ));
  }
  return out;
}

bool sameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

double sumProfitForCalendarDay(List<Trade> trades, DateTime day) {
  var s = 0.0;
  for (final t in trades) {
    if (sameCalendarDay(t.date, day)) {
      s += t.profit + t.commission;
    }
  }
  return s;
}

int countTradesForCalendarDay(List<Trade> trades, DateTime day) {
  var n = 0;
  for (final t in trades) {
    if (sameCalendarDay(t.date, day)) n++;
  }
  return n;
}

double cumulativePnlThroughDate(List<Trade> trades, DateTime endInclusive) {
  final e = DateTime(endInclusive.year, endInclusive.month, endInclusive.day);
  var s = 0.0;
  for (final t in trades) {
    final td = DateTime(t.date.year, t.date.month, t.date.day);
    if (!td.isAfter(e)) s += t.profit + t.commission;
  }
  return s;
}

double totalProfitAllTrades(List<Trade> trades) =>
    trades.fold<double>(0, (s, t) => s + t.profit + t.commission);

String pct(double r) => '${(r * 100).toStringAsFixed(1)} %';

String money(double v) => v.toStringAsFixed(2);
