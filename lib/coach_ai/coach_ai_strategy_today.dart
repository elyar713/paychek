import '../strategie/strategie_gestion_risque_storage.dart';
import '../strategie/strategie_horaires_sessions_storage.dart';
import '../strategie/strategie_mes_regles_storage.dart';
import '../strategie/strategie_setups_store.dart';
import '../strategie/strategie_starred_setup_storage.dart';
import '../strategie/widgets/strategie_setup_card.dart';
import 'coach_ai_response_format.dart';

class StrategyTodayRule {
  const StrategyTodayRule({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

class StrategyTodaySession {
  const StrategyTodaySession({
    required this.title,
    required this.timeDisplay,
    required this.isNoTradeZone,
  });

  final String title;
  final String timeDisplay;
  final bool isNoTradeZone;
}

class StrategyTodaySnapshot {
  const StrategyTodaySnapshot({
    required this.hasData,
    this.source = 'none',
    this.setupTitle = '',
    this.timeframes = '',
    this.indicateurs = '',
    this.pattern = '',
    this.signalText = '',
    this.rules = const [],
    this.goldRules = const [],
    this.riskPct = 0,
    this.lossPct = 0,
    this.tradesPerDay = 0,
    this.rrRatio = 0,
    this.sessions = const [],
    this.setupsCount = 0,
  });

  final bool hasData;
  final String source;
  final String setupTitle;
  final String timeframes;
  final String indicateurs;
  final String pattern;
  final String signalText;
  final List<StrategyTodayRule> rules;
  final List<String> goldRules;
  final double riskPct;
  final double lossPct;
  final int tradesPerDay;
  final double rrRatio;
  final List<StrategyTodaySession> sessions;
  final int setupsCount;

  factory StrategyTodaySnapshot.fromSetup(
    StrategieSetupCardData setup, {
    required String source,
    required StrategieGestionRisqueParams risk,
    required List<String> goldRules,
    required List<StrategyTodaySession> sessions,
    required int setupsCount,
  }) {
    return StrategyTodaySnapshot(
      hasData: true,
      source: source,
      setupTitle: setup.title,
      timeframes: setup.timeframes,
      indicateurs: setup.indicateurs,
      pattern: setup.pattern,
      signalText: setup.signalText,
      rules: [
        for (final block in setup.ruleBlocks)
          if (block.heading.trim().isNotEmpty || block.body.trim().isNotEmpty)
            StrategyTodayRule(
              heading: block.heading.trim(),
              body: block.body.trim(),
            ),
      ],
      goldRules: goldRules,
      riskPct: risk.riskPct,
      lossPct: risk.lossPct,
      tradesPerDay: risk.tradesPerDay,
      rrRatio: risk.rrRatio,
      sessions: sessions,
      setupsCount: setupsCount,
    );
  }
}

/// Stratégie du jour (page Stratégie PAYCHEK), pas l’audit discipline des trades.
abstract final class CoachAiStrategyToday {
  static bool isTodayStrategyQuestion(String question) {
    final q = question.toLowerCase();
    if (!RegExp(
      r'strat(é|e)gie|strategy|\bsetup\b|mon setup|ma stratégie|ma strategie|my strategy',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r'performance|winrate|pnl|bilan|non.?respect|enregistr|audit|combien|sur mes trades|discipline',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r"aujourd'hui|aujourdhui|today|du jour|ce matin|this morning|this evening",
    ).hasMatch(q)) {
      return true;
    }
    return RegExp(
      r"dis.?moi|montre|quelle est|quel est|what is|show me|ma stratégie|ma strategie|mon setup|my strategy|la stratégie|la strategie",
    ).hasMatch(q);
  }

  static Future<StrategyTodaySnapshot> buildTodaySnapshot() async {
    await StrategieSetupsStore.ensureLoaded();
    await StrategieMesReglesStore.ensureLoaded();

    final starred = await StrategieStarredSetupStorage.load();
    final setups = StrategieSetupsStore.notifier.value;
    final risk = await StrategieGestionRisqueStorage.load();
    final goldRules = StrategieMesReglesStore.notifier.value.rules;
    final sessionsRaw = await StrategieHorairesSessionsStorage.load();

    StrategieSetupCardData? picked;
    var source = 'none';

    if (starred != null && starred.title.trim().isNotEmpty) {
      picked = starred;
      source = 'starred';
    } else if (setups.isNotEmpty) {
      picked = setups.first;
      source = 'setup_first';
    }

    if (picked == null) {
      return const StrategyTodaySnapshot(hasData: false);
    }

    final sessions = [
      for (final s in sessionsRaw.take(6))
        StrategyTodaySession(
          title: s.title,
          timeDisplay: s.timeDisplay,
          isNoTradeZone: s.isNoTradeZone,
        ),
    ];

    return StrategyTodaySnapshot.fromSetup(
      picked,
      source: source,
      risk: risk,
      goldRules: goldRules,
      sessions: sessions,
      setupsCount: setups.length,
    );
  }

  static String todayCardTitle(String languageCode) {
    return switch (languageCode) {
      'en' => 'Strategy · today',
      'de' => 'Strategie · heute',
      'es' => 'Estrategia · hoy',
      _ => 'Stratégie · aujourd’hui',
    };
  }

  static Future<Map<String, dynamic>> todayContextToJson(
    String languageCode, {
    bool briefFollowUp = false,
  }) async {
    final snap = await buildTodaySnapshot();
    return <String, dynamic>{
      'coachInstructions': briefFollowUp
          ? CoachAiResponseFormat.strategyTodayFollowUpInstructions(languageCode)
          : CoachAiResponseFormat.strategyTodayInstructions(languageCode),
      'hasDataToday': snap.hasData,
      'source': snap.source,
      'setupsCount': snap.setupsCount,
      if (snap.hasData) ...<String, dynamic>{
        'setupTitle': snap.setupTitle,
        if (snap.timeframes.trim().isNotEmpty && snap.timeframes != '—')
          'timeframes': snap.timeframes,
        if (snap.indicateurs.trim().isNotEmpty && snap.indicateurs != '—')
          'indicators': snap.indicateurs,
        if (snap.pattern.trim().isNotEmpty && snap.pattern != '—') 'pattern': snap.pattern,
        if (snap.signalText.trim().isNotEmpty && snap.signalText != '—') 'signal': snap.signalText,
        'riskManagement': <String, dynamic>{
          'riskPctPerTrade': snap.riskPct,
          'maxDailyLossPct': snap.lossPct,
          'maxTradesPerDay': snap.tradesPerDay,
          'targetRrRatio': snap.rrRatio,
        },
        if (snap.rules.isNotEmpty)
          'setupRules': [
            for (final rule in snap.rules.take(6))
              <String, dynamic>{
                if (rule.heading.isNotEmpty) 'heading': rule.heading,
                if (rule.body.isNotEmpty) 'body': rule.body,
              },
          ],
        if (snap.goldRules.isNotEmpty)
          'goldRules': snap.goldRules.take(6).toList(),
        if (snap.sessions.isNotEmpty)
          'sessions': [
            for (final session in snap.sessions)
              <String, dynamic>{
                'title': session.title,
                'time': session.timeDisplay,
                'noTradeZone': session.isNoTradeZone,
              },
          ],
      },
      'fillHintPath': languageCode == 'fr'
          ? 'Accueil → carte Stratégie, ou Plus → Stratégie → Setups & modèles'
          : 'Home → Strategy card, or More → Strategy → Setups & templates',
    };
  }
}
