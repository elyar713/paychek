import '../trade/trade_models.dart';
import 'coach_ai_response_format.dart';

class CoachPsychTagStats {
  const CoachPsychTagStats({
    required this.tag,
    required this.trades,
    required this.closed,
    required this.wins,
    required this.losses,
    required this.winrate,
    required this.pnl,
  });

  final String tag;
  final int trades;
  final int closed;
  final int wins;
  final int losses;
  final double winrate;
  final double pnl;
}

class CoachPsychologyWhyFocus {
  const CoachPsychologyWhyFocus({
    required this.tagQuery,
    required this.tagStats,
    required this.allTags,
  });

  final String tagQuery;
  final CoachPsychTagStats? tagStats;
  final List<CoachPsychTagStats> allTags;
}

/// Tags psychologiques (Ajouter un trade) + questions « pourquoi j'ai eu FOMO ».
abstract final class CoachAiPsychAnalysis {
  static const _aliases = <String, String>{
    'fomo': 'FOMO',
    'tilt': 'TILT',
    'revenge': 'Revenge',
    'vengeance': 'Revenge',
    'peur': 'Peur',
    'fear': 'Peur',
    'frustration': 'Frustration',
    'frustré': 'Frustration',
    'frustre': 'Frustration',
    'cupidité': 'Cupidité',
    'cupidite': 'Cupidité',
    'greed': 'Cupidité',
    'stress': 'Stress',
    'overtrade': 'Overtrade',
    'revenge trading': 'Revenge',
  };

  static bool isPsychologyWhyQuestion(String question) {
    final q = question.toLowerCase();
    if (RegExp(
      r"c.?est quoi|c quoi|quelle psycho|quel psycho|what.{0,16}psycho",
    ).hasMatch(q)) {
      return RegExp(r'fomo|tilt|revenge|peur|fear|frustr|cupidit|greed|stress|overtrade|émotion|emotion')
          .hasMatch(q);
    }
    final why = RegExp(
      r"pourquoi|why|comment se fait|d'où vient|d'ou vient|what caused|what made",
    ).hasMatch(q);
    if (!why) return false;
    return extractTagQuery(question) != null ||
        RegExp(r'fomo|tilt|revenge|peur|fear|frustr|cupidit|greed|stress|overtrade|émotion|emotion')
            .hasMatch(q);
  }

  static String? extractTagQuery(String question) {
    final q = question.toLowerCase();
    for (final entry in _aliases.entries) {
      if (q.contains(entry.key)) return entry.value;
    }
    final m = RegExp(
      r'(?:pourquoi|why).{0,30}(?:eu|had|ressenti|felt)\s+([a-zàâäéèêëïîôùûüç\-]{3,})',
    ).firstMatch(q);
    if (m != null) {
      final raw = m.group(1)?.trim() ?? '';
      if (raw.isNotEmpty) return _aliases[raw] ?? raw[0].toUpperCase() + raw.substring(1);
    }
    return null;
  }

  static String _normTag(String tag) {
    final t = tag.trim();
    if (t.isEmpty) return t;
    final low = t.toLowerCase();
    return _aliases[low] ?? t;
  }

  static CoachPsychologyWhyFocus? buildFocus(Iterable<TradeListItem> trades, String question) {
    final tagQuery = extractTagQuery(question);
    if (tagQuery == null && !isPsychologyWhyQuestion(question)) return null;

    final resolved = tagQuery ?? 'émotion';
    final buckets = <String, _Bucket>{};

    for (final t in trades) {
      for (final raw in t.psychTags) {
        final tag = _normTag(raw);
        if (tag.isEmpty) continue;
        final b = buckets.putIfAbsent(tag, _Bucket.new);
        b.trades++;
        if (t.isClosed) {
          b.closed++;
          b.pnl += t.gainAmount;
          if (t.countsAsClosedWin) b.wins++;
          if (t.countsAsClosedLoss) b.losses++;
        }
      }
    }

    if (buckets.isEmpty && tagQuery == null) return null;

    CoachPsychTagStats toStats(String tag, _Bucket b) {
      final wr = b.closed > 0 ? (b.wins * 100 / b.closed) : 0.0;
      return CoachPsychTagStats(
        tag: tag,
        trades: b.trades,
        closed: b.closed,
        wins: b.wins,
        losses: b.losses,
        winrate: double.parse(wr.toStringAsFixed(1)),
        pnl: double.parse(b.pnl.toStringAsFixed(2)),
      );
    }

    final all = buckets.entries
        .map((e) => toStats(e.key, e.value))
        .toList()
      ..sort((a, b) => b.trades.compareTo(a.trades));

    final match = all.where((s) => s.tag.toLowerCase() == resolved.toLowerCase()).toList();
    CoachPsychTagStats? tagStats;
    if (match.isNotEmpty) {
      tagStats = match.first;
    } else if (all.isNotEmpty && resolved != 'émotion') {
      tagStats = null;
    }

    return CoachPsychologyWhyFocus(
      tagQuery: resolved,
      tagStats: tagStats,
      allTags: all,
    );
  }

  static Map<String, dynamic> focusToJson(
    CoachPsychologyWhyFocus f, {
    String languageCode = 'fr',
  }) {
    return <String, dynamic>{
      'tagQuery': f.tagQuery,
      'coachInstructions': CoachAiResponseFormat.narrativeInstructions(languageCode),
      if (f.tagStats != null)
        'tagStats': <String, dynamic>{
          'tag': f.tagStats!.tag,
          'trades': f.tagStats!.trades,
          'closed': f.tagStats!.closed,
          'wins': f.tagStats!.wins,
          'losses': f.tagStats!.losses,
          'winratePercent': f.tagStats!.winrate,
          'pnlTotal': f.tagStats!.pnl,
        },
      'allPsychTags': [
        for (final t in f.allTags)
          <String, dynamic>{
            'tag': t.tag,
            'trades': t.trades,
            'winratePercent': t.winrate,
            'pnlTotal': t.pnl,
          },
      ],
      'paychekTrainingHint':
          'Routine modeste: checklist quotidienne, plan d\'analyse, stratégie, état mental, tag psych après trade. '
          '4 semaines de saisie régulière pour voir des patterns chiffrés.',
    };
  }
}

class _Bucket {
  int trades = 0;
  int closed = 0;
  int wins = 0;
  int losses = 0;
  double pnl = 0;
}
