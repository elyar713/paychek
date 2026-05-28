import 'package:intl/intl.dart';

import '../trade/trade_models.dart';
import 'coach_ai_coaching_story.dart';
import 'coach_ai_psych_analysis.dart';

class CoachTradeListRow {
  const CoachTradeListRow({
    required this.id,
    required this.pair,
    required this.dateLabel,
    required this.pnl,
    required this.isClosed,
    required this.sideLabel,
    required this.psychTags,
    required this.matchedTags,
  });

  final String id;
  final String pair;
  final String dateLabel;
  final double pnl;
  final bool isClosed;
  final String sideLabel;
  final List<String> psychTags;
  final List<String> matchedTags;
}

class CoachTradeListReport {
  const CoachTradeListReport({
    required this.filterLabel,
    required this.filterKind,
    required this.rows,
    required this.headline,
    required this.hint,
  });

  final String filterLabel;
  final String filterKind;
  final List<CoachTradeListRow> rows;
  final String headline;
  final String hint;
}

/// « Quels trades avec TILT ? », « montre mes trades FOMO », etc.
abstract final class CoachAiTradeListQuery {
  static bool isTradeListQuestion(String question) {
    if (CoachAiPsychAnalysis.isPsychologyWhyQuestion(question)) return false;
    if (CoachAiCoachingStory.isCoachingStoryQuestion(question)) return false;
    final q = question.toLowerCase();
    // Liste explicite uniquement — pas « trade contre mon analyse » (faux positif sur « ou »).
    if (RegExp(
      r'quel(le)?s?\s+trade|quels\s+trades|montre.{0,30}trade|liste.{0,30}trade|'
      r'affiche.{0,30}trade|donne.{0,30}trade|voir.{0,30}trade|'
      r'quels trades.{0,20}(tag|fomo|tilt|revenge|psycho)',
    ).hasMatch(q)) {
      return true;
    }
    final tag = CoachAiPsychAnalysis.extractTagQuery(question);
    if (tag != null &&
        RegExp(r'\btrade').hasMatch(q) &&
        RegExp(r'quel|quels|montre|liste|affiche|donne|voir').hasMatch(q)) {
      return true;
    }
    return false;
  }

  static String _normTag(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    final low = t.toLowerCase();
    const aliases = <String, String>{
      'fomo': 'FOMO',
      'tilt': 'TILT',
      'revenge': 'Revenge',
      'peur': 'Peur',
      'fear': 'Peur',
    };
    return aliases[low] ?? t;
  }

  static bool _tagMatchesFilter(String tag, String filter) {
    final a = _normTag(tag).toLowerCase();
    final b = filter.toLowerCase();
    return a == b || a.contains(b) || b.contains(a);
  }

  static String _dateLabel(TradeListItem t) {
    if (t.dateLine.trim().isNotEmpty) return t.dateLine.trim();
    return DateFormat('dd MMM yyyy · HH:mm', 'fr').format(t.entreeAt.toLocal());
  }

  static CoachTradeListReport build(Iterable<TradeListItem> trades, String question) {
    final tagFilter = CoachAiPsychAnalysis.extractTagQuery(question);
    final filterLabel = tagFilter ?? 'filtre';
    final filterKind = tagFilter != null ? 'psychTag' : 'anyPsychTag';

    final matchedTrades = <(TradeListItem t, List<String> matched)>[];
    for (final t in trades) {
      if (t.psychTags.isEmpty) continue;
      final matched = <String>[];
      if (tagFilter != null) {
        for (final raw in t.psychTags) {
          if (_tagMatchesFilter(raw, tagFilter)) {
            matched.add(_normTag(raw));
          }
        }
        if (matched.isEmpty) continue;
      } else {
        matched.addAll(t.psychTags.map(_normTag));
      }
      matchedTrades.add((t, matched.toSet().toList()));
    }
    matchedTrades.sort((a, b) => b.$1.entreeAt.compareTo(a.$1.entreeAt));
    final rows = [
      for (final e in matchedTrades)
        CoachTradeListRow(
          id: e.$1.id,
          pair: e.$1.pair,
          dateLabel: _dateLabel(e.$1),
          pnl: double.parse(e.$1.gainAmount.toStringAsFixed(2)),
          isClosed: e.$1.isClosed,
          sideLabel: e.$1.side == TradeSide.vente ? 'Vente' : 'Achat',
          psychTags: e.$1.psychTags.map(_normTag).toList(),
          matchedTags: e.$2,
        ),
    ];

    final count = rows.length;
    String headline;
    String hint;
    if (tagFilter != null) {
      if (count == 0) {
        headline = 'Aucun trade avec le tag $tagFilter';
        final other = <String, int>{};
        for (final t in trades) {
          for (final raw in t.psychTags) {
            final n = _normTag(raw);
            if (!_tagMatchesFilter(n, tagFilter)) {
              other[n] = (other[n] ?? 0) + 1;
            }
          }
        }
        if (other.isNotEmpty) {
          final top = other.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          final parts = top.take(4).map((e) => '${e.key} (${e.value})').join(', ');
          hint =
              'Tags psych sur d’autres trades : $parts. '
              'Tague $tagFilter sur Ajouter trade → section TAG pour le voir ici.';
        } else {
          hint =
              'Tague tes trades sur Ajouter trade → section TAG (FOMO, TILT, Revenge…). '
              'Seuls les tags enregistrés apparaissent ici.';
        }
      } else {
        headline = count == 1
            ? '1 trade avec le tag $tagFilter'
            : '$count trades avec le tag $tagFilter';
        hint = '';
      }
    } else {
      headline = count == 0
          ? 'Aucun trade avec tag psychologique'
          : (count == 1 ? '1 trade tagué' : '$count trades tagués');
      hint = count == 0
          ? 'Ajoute un tag psych sur Ajouter trade après chaque session.'
          : '';
    }

    return CoachTradeListReport(
      filterLabel: filterLabel,
      filterKind: filterKind,
      rows: rows,
      headline: headline,
      hint: hint,
    );
  }

  static Map<String, dynamic> reportToJson(CoachTradeListReport r) {
    return <String, dynamic>{
      'filterKind': r.filterKind,
      'filterLabel': r.filterLabel,
      'count': r.rows.length,
      'trades': [
        for (final row in r.rows)
          <String, dynamic>{
            'id': row.id,
            'pair': row.pair,
            'date': row.dateLabel,
            'pnl': row.pnl,
            'isClosed': row.isClosed,
            'side': row.sideLabel,
            'psychTags': row.psychTags,
            'matchedTags': row.matchedTags,
          },
      ],
    };
  }
}
