import 'package:intl/intl.dart';

import '../trade/trade_models.dart';
import 'coach_ai_psych_analysis.dart';
import 'coach_ai_trade_list_query.dart';

/// Trades du journal à afficher sous une réponse coaching / psycho (hors `trade_list`).
class CoachRelatedTradesSection {
  const CoachRelatedTradesSection({
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.journalTotal,
  });

  final String title;
  final String subtitle;
  final List<CoachTradeListRow> rows;
  final int journalTotal;
}

abstract final class CoachAiRelatedTrades {
  static const int maxRows = 12;

  static String _dateLabel(TradeListItem t) {
    if (t.dateLine.trim().isNotEmpty) return t.dateLine.trim();
    return DateFormat('dd MMM yyyy · HH:mm', 'fr').format(t.entreeAt.toLocal());
  }

  static String _normTag(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    const aliases = <String, String>{
      'fomo': 'FOMO',
      'tilt': 'TILT',
      'revenge': 'Revenge',
      'peur': 'Peur',
      'impatience': 'Impatience',
    };
    return aliases[t.toLowerCase()] ?? t;
  }

  static bool _tagMatchesAny(String tag, Iterable<String> filters) {
    final a = _normTag(tag).toLowerCase();
    for (final f in filters) {
      final b = f.toLowerCase();
      if (a == b || a.contains(b) || b.contains(a)) return true;
    }
    return false;
  }

  static List<String> _inferTagFilters(String question, List<String> themes) {
    final q = question.toLowerCase();
    final filters = <String>[];
    final explicit = CoachAiPsychAnalysis.extractTagQuery(question);
    if (explicit != null) filters.add(explicit);

    if (RegExp(r'fomo|trop t[oô]t|early|avant|attendre|patience|impatien').hasMatch(q)) {
      filters.add('FOMO');
      filters.add('Impatience');
    }
    if (RegExp(r'revenge|renvers|contre mon analyse').hasMatch(q)) {
      filters.add('Revenge');
    }
    if (RegExp(r'tilt|frustr').hasMatch(q)) {
      filters.add('TILT');
      filters.add('Frustration');
    }
    if (RegExp(r'peur|stress|inquiétude|inquietude').hasMatch(q)) {
      filters.add('Peur');
      filters.add('Stress');
    }
    for (final theme in themes) {
      final tl = theme.toLowerCase();
      if (tl.contains('fomo') || tl.contains('anticip')) filters.add('FOMO');
      if (tl.contains('revenge')) filters.add('Revenge');
      if (tl.contains('inquiétude') || tl.contains('peur')) filters.add('Peur');
    }
    return filters.toSet().toList();
  }

  static int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  /// Évite d’afficher uniquement une seule journée quand le journal couvre plusieurs mois.
  static List<TradeListItem> _diversifyByDay(List<TradeListItem> sorted, int cap) {
    if (sorted.length <= cap) return sorted;
    final byDay = <int, List<TradeListItem>>{};
    for (final t in sorted) {
      final key = _dayKey(t.entreeAt.toLocal());
      byDay.putIfAbsent(key, () => []).add(t);
    }
    final dayKeys = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    final out = <TradeListItem>[];
    var round = 0;
    while (out.length < cap && round < cap) {
      var added = false;
      for (final key in dayKeys) {
        if (out.length >= cap) break;
        final bucket = byDay[key]!;
        if (round < bucket.length) {
          out.add(bucket[round]);
          added = true;
        }
      }
      if (!added) break;
      round++;
    }
    out.sort((a, b) => b.entreeAt.compareTo(a.entreeAt));
    return out.take(cap).toList();
  }

  static CoachRelatedTradesSection? build(
    Iterable<TradeListItem> trades,
    String question, {
    List<String> themes = const [],
  }) {
    final all = trades.toList();
    if (all.isEmpty) return null;

    final q = question.toLowerCase();
    final today = DateTime.now();
    final todayKey = _dayKey(DateTime(today.year, today.month, today.day));
    final preferToday = RegExp(r"aujourd'hui|aujourdhui|today|ce matin|ce soir").hasMatch(q);

    final tagFilters = _inferTagFilters(question, themes);
    final matched = <(TradeListItem t, List<String> matched)>[];
    final matchById = <String, List<String>>{};

    if (tagFilters.isNotEmpty) {
      for (final t in all) {
        if (t.psychTags.isEmpty) continue;
        final hits = <String>{};
        for (final raw in t.psychTags) {
          if (_tagMatchesAny(raw, tagFilters)) hits.add(_normTag(raw));
        }
        if (hits.isEmpty) continue;
        final hitList = hits.toList();
        matched.add((t, hitList));
        matchById[t.id] = hitList;
      }
    }

    final allTagged = all.where((t) => t.psychTags.isNotEmpty).toList()
      ..sort((a, b) => b.entreeAt.compareTo(a.entreeAt));

    List<TradeListItem> pool;
    if (tagFilters.isNotEmpty && matched.isNotEmpty) {
      final primaryIds = matched.map((e) => e.$1.id).toSet();
      pool = [
        ...matched.map((e) => e.$1),
        for (final t in allTagged)
          if (!primaryIds.contains(t.id)) t,
      ];
    } else if (allTagged.isNotEmpty) {
      pool = allTagged;
    } else {
      pool = List<TradeListItem>.from(all)
        ..sort((a, b) => b.entreeAt.compareTo(a.entreeAt));
    }

    if (preferToday) {
      final todayTrades = pool
          .where((t) => _dayKey(t.entreeAt.toLocal()) == todayKey)
          .toList();
      if (todayTrades.isNotEmpty) {
        final todayIds = todayTrades.map((t) => t.id).toSet();
        pool = [
          ...todayTrades,
          for (final t in pool)
            if (!todayIds.contains(t.id)) t,
        ];
      }
    }

    final picked = pool.length <= maxRows
        ? pool.take(maxRows).toList()
        : _diversifyByDay(pool, maxRows);
    if (picked.isEmpty) return null;

    final rows = <CoachTradeListRow>[];
    for (final t in picked) {
      final hits = matchById[t.id];
      rows.add(
        CoachTradeListRow(
          id: t.id,
          pair: t.pair,
          dateLabel: _dateLabel(t),
          pnl: double.parse(t.gainAmount.toStringAsFixed(2)),
          isClosed: t.isClosed,
          sideLabel: t.side == TradeSide.vente ? 'Vente' : 'Achat',
          psychTags: t.psychTags.map(_normTag).toList(),
          matchedTags: hits ?? const [],
        ),
      );
    }

    final taggedTotal = allTagged.length;
    final directMatchCount = matchById.length;
    String title;
    String subtitle;
    if (taggedTotal > 0 && rows.length == taggedTotal && taggedTotal <= maxRows) {
      title = taggedTotal == 1
          ? '1 trade avec tag psych'
          : '$taggedTotal trades avec tag psych';
      if (directMatchCount > 0 && directMatchCount < taggedTotal) {
        subtitle =
            '${all.length} au journal · $directMatchCount lié${directMatchCount > 1 ? 's' : ''} à ta question (surlignés) · les autres pour contexte.';
      } else if (directMatchCount > 0) {
        subtitle = '${all.length} au journal · liés à ta question (FOMO, impatience, etc.).';
      } else {
        subtitle = '${all.length} au journal · aperçu de tes trades tagués.';
      }
    } else if (tagFilters.isNotEmpty && directMatchCount > 0) {
      title = rows.length == 1
          ? '1 trade lié à ta question'
          : '${rows.length} trades (dont $directMatchCount lié${directMatchCount > 1 ? 's' : ''} à ta question)';
      subtitle =
          '${all.length} au journal · $taggedTotal avec tag psych au total.';
    } else {
      title = rows.length == 1
          ? '1 trade récent du journal'
          : '${rows.length} trades récents du journal';
      subtitle =
          '${all.length} trades au total · aperçu des plus récents (plusieurs dates si possible).';
    }

    return CoachRelatedTradesSection(
      title: title,
      subtitle: subtitle,
      rows: rows,
      journalTotal: all.length,
    );
  }
}
