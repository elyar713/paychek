import '../etat_mental/mental_state_controller.dart';
import '../etat_mental/mental_state_day_breakdown.dart';
import '../etat_mental/mental_state_models.dart';
import '../etat_mental/mental_state_storage.dart';
import '../l10n/app_localizations.dart';
import '../trade/trade_discipline_day_snapshot.dart';
import '../trade/trade_models.dart';
import '../trade/trade_plan_analysis.dart';
import 'coach_ai_response_format.dart';

/// Question ciblée sur l'état mental (émotion ou curseur du jour).
class CoachMentalQuery {
  const CoachMentalQuery({
    required this.kind,
    required this.label,
    this.metricId,
    this.polarity = 'neutral',
    this.threshold = 50,
  });

  /// `emotion` ou `metric` (curseurs moment / routines).
  final String kind;
  final String label;
  final String? metricId;

  /// `low`, `high` ou `neutral` (comparaison médiane si neutre).
  final String polarity;
  final double threshold;
}

class CoachMentalEmotionStats {
  const CoachMentalEmotionStats({
    required this.query,
    required this.matchedLabels,
    required this.matchedTrades,
    required this.matchedClosed,
    required this.matchedWins,
    required this.matchedLosses,
    required this.matchedWinrate,
    required this.matchedPnl,
    required this.otherEtatTrades,
    required this.otherClosed,
    required this.otherWins,
    required this.otherLosses,
    required this.otherWinrate,
    required this.otherPnl,
    required this.tradesWithEtatMental,
    required this.tradesWithMetricValue,
    required this.tradesWithoutMetricValue,
    required this.splitValueUsed,
    required this.splitMethod,
  });

  final CoachMentalQuery query;
  final List<String> matchedLabels;
  final int matchedTrades;
  final int matchedClosed;
  final int matchedWins;
  final int matchedLosses;
  final double matchedWinrate;
  final double matchedPnl;
  final int otherEtatTrades;
  final int otherClosed;
  final int otherWins;
  final int otherLosses;
  final double otherWinrate;
  final double otherPnl;
  final int tradesWithEtatMental;
  final int tradesWithMetricValue;
  final int tradesWithoutMetricValue;
  final double splitValueUsed;
  final String splitMethod;
}

/// État mental du jour (page État mental PAYCHEK), pas l’audit discipline des trades.
class CoachMentalTodaySnapshot {
  const CoachMentalTodaySnapshot({
    required this.hasSavedToday,
    this.breakdown,
    this.tradesToday = 0,
    this.tradesTodayWithEtat = 0,
  });

  final bool hasSavedToday;
  final MentalStateDayBreakdown? breakdown;
  final int tradesToday;
  final int tradesTodayWithEtat;
}

class CoachAiMentalAnalysis {
  static const _captureStopwords = <String>{
    'quelle',
    'quel',
    'quoi',
    'comment',
    'combien',
    'quand',
    'performance',
    'rendement',
    'winrate',
    'bilan',
    'trade',
    'trades',
    'mon',
    'ma',
    'mes',
    'une',
    'des',
    'les',
    'du',
    'de',
    'la',
    'le',
    'et',
    'ou',
    'sur',
    'avec',
    'sans',
    'pour',
    'dans',
  };

  static const _metricAliases = <String, String>{
    'focus': 'focus',
    'confiance': 'confidence',
    'confidence': 'confidence',
    'peur': 'risk',
    'fear': 'risk',
    'énergie': 'energy',
    'energie': 'energy',
    'energy': 'energy',
    'étude': 'study',
    'etude': 'study',
    'study': 'study',
    'émotionnel': 'emotion',
    'emotionnel': 'emotion',
    'emotion': 'emotion',
    'sommeil': 'sleep',
    'sleep': 'sleep',
    'méditation': 'meditation',
    'meditation': 'meditation',
    'sport': 'sport_jogging',
    'jogging': 'sport_jogging',
  };

  static String? extractEmotionQuery(String question) {
    return extractMentalQuery(question)?.label;
  }

  /// « Mon état mental aujourd’hui » — lecture du jour PAYCHEK, pas audit 4 piliers.
  static bool isTodayMentalStateQuestion(String question) {
    final q = question.toLowerCase();
    if (!RegExp(r"état mental|etat mental|mental state|mon mental|ma journée mental").hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r"aujourd'hui|aujourdhui|today|ce matin|ce soir|du jour|this morning|this evening",
    ).hasMatch(q)) {
      return true;
    }
    if (RegExp(r'performance|winrate|pnl|bilan|non.?respect|enregistr|audit|combien de trade')
        .hasMatch(q)) {
      return false;
    }
    return RegExp(
      r"dis.?moi|tu peux me dire|quel est|quelle est|what is my|tell me|comment suis|comment je suis",
    ).hasMatch(q);
  }

  static CoachMentalTodaySnapshot buildTodaySnapshot(
    AppLocalizations l,
    Iterable<TradeListItem> trades,
  ) {
    final controller = MentalStateController.instance;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    var tradesToday = 0;
    var tradesTodayWithEtat = 0;
    for (final t in trades) {
      final d = DateTime(t.entreeAt.year, t.entreeAt.month, t.entreeAt.day);
      if (d != todayOnly) continue;
      tradesToday++;
      if (t.etatLinkedExplicit) tradesTodayWithEtat++;
    }

    final saved = controller.dayBreakdownFor(today, l);
    if (saved != null) {
      return CoachMentalTodaySnapshot(
        hasSavedToday: true,
        breakdown: saved,
        tradesToday: tradesToday,
        tradesTodayWithEtat: tradesTodayWithEtat,
      );
    }

    final liveScore = controller.overallScoreForCalendarDay(today);
    if (liveScore != null) {
      final snap = controller.snapshotForCalendarDay(today);
      if (snap != null) {
        final bd = MentalStateDayBreakdown.fromSnapshot(
          snap,
          l,
          liveScore.round(),
        );
        if (bd != null) {
          return CoachMentalTodaySnapshot(
            hasSavedToday: true,
            breakdown: bd,
            tradesToday: tradesToday,
            tradesTodayWithEtat: tradesTodayWithEtat,
          );
        }
      }
    }

    return CoachMentalTodaySnapshot(
      hasSavedToday: false,
      tradesToday: tradesToday,
      tradesTodayWithEtat: tradesTodayWithEtat,
    );
  }

  static String todayCardTitle(String languageCode) {
    return switch (languageCode) {
      'en' => 'Mental state · today',
      'de' => 'Mental · heute',
      'es' => 'Estado mental · hoy',
      _ => 'État mental · aujourd’hui',
    };
  }

  /// Faits du jour pour le coach cloud (structure intro + 1.2.3.4., pas audit discipline).
  static Map<String, dynamic> todayContextToJson(
    AppLocalizations l,
    Iterable<TradeListItem> trades,
    String languageCode,
  ) {
    final snap = buildTodaySnapshot(l, trades);
    final bd = snap.breakdown;
    return <String, dynamic>{
      'coachInstructions': CoachAiResponseFormat.mentalTodayInstructions(languageCode),
      'hasDataToday': bd != null,
      if (bd != null) 'overallPercent': bd.overallPercent,
      'sections': bd == null
          ? const <Map<String, dynamic>>[]
          : [
              for (final section in bd.sections)
                <String, dynamic>{
                  'title': section.title,
                  if (section.blockPercent != null) 'blockPercent': section.blockPercent,
                  'criteria': [
                    for (final c in section.criteria)
                      <String, dynamic>{'label': c.label, 'percent': c.percent},
                  ],
                },
            ],
      'tradesToday': snap.tradesToday,
      'tradesTodayWithEtatLinked': snap.tradesTodayWithEtat,
      'fillHintPath': languageCode == 'fr'
          ? 'Plus → État mental (sommeil, routines, émotions, curseurs)'
          : 'Plus → Mental state (sleep, routines, emotions, sliders)',
    };
  }

  /// Performance liée à un curseur/émotion (pas les conseils « comment améliorer »).
  static bool isMentalPerformanceQuestion(String question) {
    if (extractMentalQuery(question) == null) return false;
    final q = question.toLowerCase();
    final coachingOnly = RegExp(
      r'comment\s+(améliorer|ameliorer|mieux|travailler|booster|renforcer)|'
      r'conseil|astuce|tip|how\s+to\s+improve',
    ).hasMatch(q);
    final performanceIntent = RegExp(
      r'performance|winrate|pnl|rendement|résultat|resultat|bilan|'
      r'gagn|perd|quoi comme|quel.*résultat',
    ).hasMatch(q);
    final whenIntent = RegExp(r'\bquand\b|\bwhen\b').hasMatch(q);
    final polarityIntent = RegExp(
      r"moins de|plus de|peu de|beaucoup|faible|élevé|eleve|high|low|moins d'",
    ).hasMatch(q);
    if (coachingOnly && !performanceIntent && !whenIntent) return false;
    return performanceIntent || whenIntent || polarityIntent;
  }

  static CoachMentalQuery? extractMentalQuery(String question) {
    final q = question.toLowerCase();
    final polarity = _detectPolarity(q);
    final controller = MentalStateController.instance;

    for (final m in [...controller.moment, ...controller.factors]) {
      final label = m.label.trim().toLowerCase();
      if (label.length >= 3 && q.contains(label)) {
        return CoachMentalQuery(
          kind: 'metric',
          label: m.label.trim(),
          metricId: m.id,
          polarity: polarity,
        );
      }
      final id = m.id.trim().toLowerCase();
      if (id.length >= 3 && RegExp(r'\b' + RegExp.escape(id) + r'\b').hasMatch(q)) {
        return CoachMentalQuery(
          kind: 'metric',
          label: m.label.trim(),
          metricId: m.id,
          polarity: polarity,
        );
      }
    }

    for (final entry in _metricAliases.entries) {
      if (!q.contains(entry.key)) continue;
      final metric = _metricById(controller, entry.value);
      if (metric != null) {
        return CoachMentalQuery(
          kind: 'metric',
          label: metric.label.trim(),
          metricId: metric.id,
          polarity: polarity,
        );
      }
      return CoachMentalQuery(
        kind: 'metric',
        label: _prettyMetricLabel(entry.key, entry.value),
        metricId: entry.value,
        polarity: polarity,
      );
    }

    for (final e in controller.emotions) {
      final label = e.label.trim().toLowerCase();
      if (label.length >= 3 && q.contains(label)) {
        return CoachMentalQuery(kind: 'emotion', label: e.label.trim(), polarity: polarity);
      }
    }

    const emotionAliases = <String, String>{
      'peur': 'peur',
      'fear': 'peur',
      'afraid': 'peur',
      'cupidité': 'cupidité',
      'cupidite': 'cupidité',
      'greed': 'cupidité',
      'confiance': 'confiance',
      'fatigue': 'fatigue',
      'stress': 'stress',
      'stressé': 'stress',
      'stresse': 'stress',
      'fomo': 'fomo',
      'tilt': 'tilt',
      'revenge': 'revenge',
      'vengeance': 'revenge',
      'frustré': 'frustré',
      'frustre': 'frustré',
      'excité': 'excité',
      'excite': 'excité',
    };
    for (final entry in emotionAliases.entries) {
      if (!q.contains(entry.key)) continue;
      final match = controller.emotions
          .where((e) => _labelMatchesQuery(e.label, entry.value))
          .map((e) => e.label.trim())
          .toList();
      return CoachMentalQuery(
        kind: 'emotion',
        label: match.isNotEmpty ? match.first : entry.value,
        polarity: polarity,
      );
    }

    final whenMatch = RegExp(
      r"(?:quand|when).{0,40}(?:j.?ai|je suis|i am|i'm)\s+"
      r"(?:(?:moins|peu|plus|beaucoup)\s+de\s+)?([a-zàâäéèêëïîôùûüç\-]{3,24})",
    ).firstMatch(q);
    if (whenMatch != null) {
      final captured = whenMatch.group(1)?.trim().toLowerCase() ?? '';
      if (captured.isNotEmpty && !_captureStopwords.contains(captured)) {
        final aliasId = _metricAliases[captured];
        if (aliasId != null) {
          final metric = _metricById(controller, aliasId);
          return CoachMentalQuery(
            kind: 'metric',
            label: metric?.label.trim() ?? captured,
            metricId: aliasId,
            polarity: polarity,
          );
        }
        return CoachMentalQuery(kind: 'emotion', label: captured, polarity: polarity);
      }
    }

    return null;
  }

  static String _detectPolarity(String q) {
    final low = RegExp(r'moins de|peu de|faible|bas\b|low\b|moins\b').hasMatch(q);
    final high = RegExp(r'plus de|beaucoup de|élevé|eleve|high\b|fort\b|plus\b').hasMatch(q);
    if (low && !high) return 'low';
    if (high && !low) return 'high';
    return 'neutral';
  }

  static MentalStateMetric? _metricById(MentalStateController c, String id) {
    for (final m in [...c.moment, ...c.factors]) {
      if (m.id == id) return m;
    }
    return null;
  }

  static bool _labelMatchesQuery(String label, String query) {
    final l = label.trim().toLowerCase();
    final q = query.trim().toLowerCase();
    if (l.isEmpty || q.isEmpty) return false;
    return l.contains(q) || q.contains(l);
  }

  static List<MentalStateMetric> _decodeMetrics(Object? raw) {
    if (raw is! List) return const [];
    final out = <MentalStateMetric>[];
    for (final e in raw) {
      final x = MentalStateStorage.decodeMetric(e);
      if (x != null) out.add(x);
    }
    return out;
  }

  static double? _metricValueForDay(DateTime day, CoachMentalQuery query) {
    final snap = MentalStateController.instance.snapshotForCalendarDay(day);
    if (snap == null) return null;

    final isSleep = query.metricId == 'sleep' ||
        query.label.toLowerCase().contains('sommeil') ||
        query.label.toLowerCase() == 'sleep';
    if (isSleep) {
      final raw = (snap['sleepValue'] as num?)?.toDouble();
      if (raw == null) return null;
      final inverse = snap['sleepInverse'] as bool? ?? false;
      final v = raw.clamp(0, 100).toDouble();
      return inverse ? (100 - v) : v;
    }

    final metrics = [
      ..._decodeMetrics(snap['moment']),
      ..._decodeMetrics(snap['factors']),
    ];
    if (query.metricId != null) {
      for (final m in metrics) {
        if (m.id == query.metricId) return m.value;
      }
    }
    for (final m in metrics) {
      if (_labelMatchesQuery(m.label, query.label)) return m.value;
    }
    return null;
  }

  static Set<String> _selectedEmotionIds(Map<String, dynamic> bundle) {
    final sel = bundle['selectedEmotionIds'];
    if (sel is List) {
      return sel.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toSet();
    }
    final sei = (bundle['selectedEmotionIndex'] as num?)?.toInt();
    final emotions = _decodeEmotions(bundle['emotions']);
    if (sei != null && sei >= 0 && sei < emotions.length) {
      return {emotions[sei].id};
    }
    return const {};
  }

  static List<MentalStateEmotion> _decodeEmotions(Object? raw) {
    if (raw is! List) return const [];
    final out = <MentalStateEmotion>[];
    for (final e in raw) {
      final x = MentalStateStorage.decodeEmotion(e);
      if (x != null) out.add(x);
    }
    return out;
  }

  static bool _dayHasEmotion(Map<String, dynamic>? bundle, CoachMentalQuery query) {
    if (bundle == null) return false;
    final selectedIds = _selectedEmotionIds(bundle);
    if (selectedIds.isEmpty) return false;
    final emotions = _decodeEmotions(bundle['emotions']);
    for (final e in emotions) {
      if (!selectedIds.contains(e.id)) continue;
      if (_labelMatchesQuery(e.label, query.label)) return true;
    }
    return false;
  }

  static String _prettyMetricLabel(String key, String metricId) {
    final metric = _metricById(MentalStateController.instance, metricId);
    if (metric != null && metric.label.trim().isNotEmpty) return metric.label.trim();
    const pretty = <String, String>{
      'energy': 'Énergie',
      'focus': 'Focus',
      'sleep': 'Sommeil',
      'risk': 'Peur',
    };
    return pretty[metricId] ?? (key.isNotEmpty ? key[0].toUpperCase() + key.substring(1) : metricId);
  }

  static bool _valueMatchesPolarity(double value, CoachMentalQuery query, double split) {
    return switch (query.polarity) {
      'low' => value < split,
      'high' => value >= split,
      _ => value < split,
    };
  }

  static bool _tradeMatchesQuery(TradeListItem t, CoachMentalQuery query, double medianSplit) {
    if (query.kind == 'metric') {
      final day = tradeEntryDateOnly(t.entreeAt);
      final v = _metricValueForDay(day, query);
      if (v == null) return false;
      return _valueMatchesPolarity(v, query, medianSplit);
    }

    final day = tradeEntryDateOnly(t.entreeAt);
    final snap = MentalStateController.instance.snapshotForCalendarDay(day);
    if (_dayHasEmotion(snap, query)) return true;

    final controller = MentalStateController.instance;
    for (final id in t.etatNonRespectIds) {
      if (!id.startsWith('emotion:')) continue;
      final key = id.substring('emotion:'.length);
      for (final e in controller.emotions) {
        if (e.id == key && _labelMatchesQuery(e.label, query.label)) return true;
      }
    }
    return false;
  }

  static double _medianMetricSplit(
    Iterable<TradeListItem> trades,
    CoachMentalQuery query,
  ) {
    final values = <double>[];
    for (final t in trades) {
      if (!tradeHasExplicitEtat(t)) continue;
      final v = _metricValueForDay(tradeEntryDateOnly(t.entreeAt), query);
      if (v != null) values.add(v);
    }
    if (values.isEmpty) return query.threshold;
    values.sort();
    return values[values.length ~/ 2];
  }

  static CoachMentalEmotionStats? buildStats(
    Iterable<TradeListItem> trades,
    String emotionQuery,
  ) {
    final query = extractMentalQuery(emotionQuery) ??
        CoachMentalQuery(kind: 'emotion', label: emotionQuery.trim());
    return buildStatsForQuery(trades, query);
  }

  static CoachMentalEmotionStats? buildStatsForQuery(
    Iterable<TradeListItem> trades,
    CoachMentalQuery query,
  ) {
    final controller = MentalStateController.instance;
    final matchedLabels = query.kind == 'emotion'
        ? controller.emotions
            .where((e) => _labelMatchesQuery(e.label, query.label))
            .map((e) => e.label.trim())
            .toSet()
            .toList()
        : <String>[
            if (query.label.trim().isNotEmpty) query.label.trim(),
          ];

    final medianSplit =
        query.kind == 'metric' ? _medianMetricSplit(trades, query) : query.threshold;

    var matchedTrades = 0;
    var matchedClosed = 0;
    var matchedWins = 0;
    var matchedLosses = 0;
    var matchedPnl = 0.0;

    var otherEtatTrades = 0;
    var otherClosed = 0;
    var otherWins = 0;
    var otherLosses = 0;
    var otherPnl = 0.0;
    var tradesWithEtatMental = 0;
    var tradesWithMetricValue = 0;
    var tradesWithoutMetricValue = 0;

    for (final t in trades) {
      if (!tradeHasExplicitEtat(t)) continue;
      tradesWithEtatMental++;

      if (query.kind == 'metric') {
        final v = _metricValueForDay(tradeEntryDateOnly(t.entreeAt), query);
        if (v == null) {
          tradesWithoutMetricValue++;
          continue;
        }
        tradesWithMetricValue++;
      }

      final isMatch = _tradeMatchesQuery(t, query, medianSplit);
      if (isMatch) {
        matchedTrades++;
        if (t.isClosed) {
          matchedClosed++;
          matchedPnl += t.gainAmount;
          if (t.countsAsClosedWin) matchedWins++;
          if (t.countsAsClosedLoss) matchedLosses++;
        }
      } else {
        otherEtatTrades++;
        if (t.isClosed) {
          otherClosed++;
          otherPnl += t.gainAmount;
          if (t.countsAsClosedWin) otherWins++;
          if (t.countsAsClosedLoss) otherLosses++;
        }
      }
    }

    if (tradesWithEtatMental == 0) return null;
    if (matchedLabels.isEmpty && query.label.trim().isEmpty) return null;

    final matchedWinrate =
        matchedClosed > 0 ? (matchedWins * 100 / matchedClosed) : 0.0;
    final otherWinrate = otherClosed > 0 ? (otherWins * 100 / otherClosed) : 0.0;
    final splitMethod = query.kind == 'metric' ? 'median_on_trade_days' : 'emotion_match';

    return CoachMentalEmotionStats(
      query: query,
      matchedLabels: matchedLabels.isNotEmpty ? matchedLabels : [query.label.trim()],
      matchedTrades: matchedTrades,
      matchedClosed: matchedClosed,
      matchedWins: matchedWins,
      matchedLosses: matchedLosses,
      matchedWinrate: double.parse(matchedWinrate.toStringAsFixed(1)),
      matchedPnl: double.parse(matchedPnl.toStringAsFixed(2)),
      otherEtatTrades: otherEtatTrades,
      otherClosed: otherClosed,
      otherWins: otherWins,
      otherLosses: otherLosses,
      otherWinrate: double.parse(otherWinrate.toStringAsFixed(1)),
      otherPnl: double.parse(otherPnl.toStringAsFixed(2)),
      tradesWithEtatMental: tradesWithEtatMental,
      tradesWithMetricValue: tradesWithMetricValue,
      tradesWithoutMetricValue: tradesWithoutMetricValue,
      splitValueUsed: double.parse(medianSplit.toStringAsFixed(1)),
      splitMethod: splitMethod,
    );
  }

  static String displayTitle(CoachMentalQuery query) {
    final polarityLabel = switch (query.polarity) {
      'low' => ' (niveau bas)',
      'high' => ' (niveau haut)',
      _ => '',
    };
    if (query.kind == 'metric') {
      final label = query.label.trim().isNotEmpty
          ? query.label.trim()
          : (query.metricId == 'sleep' ? 'Sommeil' : 'État mental');
      return 'Focus état mental : $label$polarityLabel';
    }
    return 'Focus émotion : ${query.label}';
  }

  static String comparisonChipLabel(CoachMentalQuery query) =>
      query.kind == 'metric' ? 'Hors focus' : 'Hors émotion';

  static Map<String, dynamic> statsToJson(CoachMentalEmotionStats s) {
    return <String, dynamic>{
      'kind': s.query.kind,
      'emotionQuery': s.query.label,
      'metricId': s.query.metricId,
      'polarity': s.query.polarity,
      'threshold': s.query.threshold,
      'matchedLabels': s.matchedLabels,
      'mentalStateCoverage': <String, dynamic>{
        'tradesWithEtatMental': s.tradesWithEtatMental,
        'tradesWithMetricValue': s.tradesWithMetricValue,
        'tradesWithoutMetricValue': s.tradesWithoutMetricValue,
        'splitValueUsed': s.splitValueUsed,
        'splitMethod': s.splitMethod,
        'note': s.query.kind == 'metric'
            ? 'Comparaison bas/haut via médiane du curseur sur les jours de trade avec état mental.'
            : 'Comparaison via émotions sélectionnées ce jour-là.',
      },
      'onEmotionDays': <String, dynamic>{
        'trades': s.matchedTrades,
        'closed': s.matchedClosed,
        'wins': s.matchedWins,
        'losses': s.matchedLosses,
        'winratePercent': s.matchedWinrate,
        'pnlTotal': s.matchedPnl,
      },
      'otherEtatDays': <String, dynamic>{
        'trades': s.otherEtatTrades,
        'closed': s.otherClosed,
        'wins': s.otherWins,
        'losses': s.otherLosses,
        'winratePercent': s.otherWinrate,
        'pnlTotal': s.otherPnl,
      },
    };
  }
}
