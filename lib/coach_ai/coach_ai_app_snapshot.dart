import '../l10n/app_localizations.dart';
import '../trade/trade_models.dart';
import 'coach_ai_analysis_today.dart';
import 'coach_ai_checklist_today.dart';
import 'coach_ai_locale.dart';
import 'coach_ai_mental_analysis.dart';
import 'coach_ai_strategy_today.dart';

/// Instantané compact PAYCHEK (pages + données du jour) pour chaque appel cloud Coach.
abstract final class CoachAiAppSnapshot {
  static Future<Map<String, dynamic>> buildCompact({
    required AppLocalizations l10n,
    required Iterable<TradeListItem> trades,
    required String languageCode,
    Map<String, dynamic>? portfolioScope,
  }) async {
    final lc = CoachAiLocale.normalize(languageCode);
    final mental = CoachAiMentalAnalysis.todayContextToJson(l10n, trades, lc);
    final checklist = await CoachAiChecklistToday.todayContextToJson(lc);
    final analysis = await CoachAiAnalysisToday.todayContextToJson(lc);
    final strategy = await CoachAiStrategyToday.todayContextToJson(lc);

    return <String, dynamic>{
      'source': 'paychek_app_snapshot_v1',
      'languageCode': lc,
      'portfolioScope': ?portfolioScope,
      'navigation': _navigation(lc),
      'today': <String, dynamic>{
        'mental': _compactMental(mental),
        'checklist': _compactChecklist(checklist),
        'analysis': _compactAnalysis(analysis),
        'strategy': _compactStrategy(strategy),
      },
    };
  }

  static String dataFirstCoachInstructions(String languageCode) {
    return CoachAiLocale.pick(
      languageCode,
      fr:
          'RÈGLE PAYCHEK : tu connais l’app. Base chaque réponse sur le JSON '
          '(paychekAppSnapshot, tradeJournal, recordedDiscipline, missingDiscipline, questionFocus). '
          'Cite les chiffres réels de l’utilisateur (winrate, PnL, trades, discipline). '
          'Ne invente pas de trades ni de stats. '
          'Pour un conseil actionnable, nomme une page PAYCHEK (ex. Ajouter trade, État mental, Mon Analyse, Performance). '
          'Si une donnée manque dans le JSON, dis-le et indique fillHintPath ou navigation.',
      en:
          'PAYCHEK RULE: you know the app. Base every answer on JSON context '
          '(paychekAppSnapshot, tradeJournal, recordedDiscipline, missingDiscipline, questionFocus). '
          'Cite the user’s real numbers (winrate, PnL, trades, discipline). '
          'Do not invent trades or stats. '
          'For actionable advice, name a PAYCHEK screen (Add trade, Mental state, My Analysis, Performance). '
          'If data is missing in JSON, say so and point to fillHintPath or navigation.',
      de:
          'PAYCHEK-REGEL: Antworte nur mit JSON-Daten (paychekAppSnapshot, tradeJournal, Disziplin). '
          'Nenne echte Zahlen und PAYCHEK-Seiten für konkrete Schritte.',
      es:
          'REGLA PAYCHEK: responde solo con datos JSON (paychekAppSnapshot, tradeJournal, disciplina). '
          'Cita cifras reales y pantallas PAYCHEK para acciones concretas.',
      pt:
          'REGRA PAYCHEK: responde só com dados JSON (paychekAppSnapshot, tradeJournal, disciplina). '
          'Cita números reais e ecrãs PAYCHEK para ações concretas.',
      ko:
          'PAYCHEK 규칙: JSON 데이터(paychekAppSnapshot, tradeJournal, 규율)만 사용해 답하세요. '
          '실제 수치와 PAYCHEK 화면을 언급하세요.',
    );
  }

  static Map<String, dynamic> _navigation(String lc) => <String, dynamic>{
        'dashboard': CoachAiLocale.pick(
          lc,
          fr: 'Accueil : capital, winrate, checklist, cartes Analyse/Stratégie/Calendrier',
          en: 'Home: capital, winrate, checklist, Analysis/Strategy/Calendar cards',
        ),
        'addTrade': CoachAiLocale.pick(
          lc,
          fr: 'Trade → + : enregistrer position, discipline, TAG psych, Feeling/Principe',
          en: 'Trade → +: log position, discipline blocks, psych TAGs, Principle/Feeling',
        ),
        'tradeJournal': CoachAiLocale.pick(
          lc,
          fr: 'Trade : journal, filtres, compléter champs manquants par trade',
          en: 'Trade tab: journal, filters, complete missing fields per trade',
        ),
        'mentalState': CoachAiLocale.pick(
          lc,
          fr: 'Plus → État mental : curseurs du jour (sommeil, émotions, focus)',
          en: 'More → Mental state: daily sliders (sleep, emotions, focus)',
        ),
        'myAnalysis': CoachAiLocale.pick(
          lc,
          fr: 'Plus → Analyse / Mon Analyse : plan du jour, confluence, rapport',
          en: 'More → Analysis / My Analysis: daily plan, confluence, report',
        ),
        'myStrategy': CoachAiLocale.pick(
          lc,
          fr: 'Plus → Stratégie : setups, règles d’or, sessions, risk',
          en: 'More → Strategy: setups, golden rules, sessions, risk',
        ),
        'checklist': CoachAiLocale.pick(
          lc,
          fr: 'Plus → Checklist : tâches du jour, rappels',
          en: 'More → Checklist: daily tasks, reminders',
        ),
        'performance': CoachAiLocale.pick(
          lc,
          fr: 'Plus → Performance : KPI, Paychek Lens, overtrading',
          en: 'More → Performance: KPIs, Paychek Lens, overtrading',
        ),
        'calendar': CoachAiLocale.pick(
          lc,
          fr: 'Plus → Calendrier : PnL jour/mois, objectifs',
          en: 'More → Calendar: daily/monthly PnL, goals',
        ),
        'coachAi': CoachAiLocale.pick(
          lc,
          fr: 'Plus → Coach AI : questions trading + utilisation app',
          en: 'More → Coach AI: trading + app usage questions',
        ),
      };

  static Map<String, dynamic> _compactMental(Map<String, dynamic> raw) =>
      <String, dynamic>{
        'hasDataToday': raw['hasDataToday'] == true,
        if (raw['overallPercent'] != null) 'overallPercent': raw['overallPercent'],
        if (raw['tradesToday'] != null) 'tradesToday': raw['tradesToday'],
        if (raw['fillHintPath'] != null) 'fillHintPath': raw['fillHintPath'],
      };

  static Map<String, dynamic> _compactChecklist(Map<String, dynamic> raw) =>
      <String, dynamic>{
        'hasItemsDueToday': raw['hasItemsDueToday'] == true,
        'completionPercent': raw['completionPercent'],
        'checkedDue': raw['checkedDue'],
        'totalDue': raw['totalDue'],
        if (raw['fillHintPath'] != null) 'fillHintPath': raw['fillHintPath'],
      };

  static Map<String, dynamic> _compactAnalysis(Map<String, dynamic> raw) =>
      <String, dynamic>{
        'hasDataToday': raw['hasDataToday'] == true,
        if (raw['actif'] != null) 'actif': raw['actif'],
        if (raw['bias'] != null) 'bias': raw['bias'],
        if (raw['confidencePercent'] != null)
          'confidencePercent': raw['confidencePercent'],
        if (raw['chartPattern'] != null) 'chartPattern': raw['chartPattern'],
        if (raw['fillHintPath'] != null) 'fillHintPath': raw['fillHintPath'],
      };

  static Map<String, dynamic> _compactStrategy(Map<String, dynamic> raw) =>
      <String, dynamic>{
        'hasDataToday': raw['hasDataToday'] == true,
        'setupsCount': raw['setupsCount'],
        if (raw['setupTitle'] != null) 'setupTitle': raw['setupTitle'],
        if (raw['signal'] != null) 'signal': raw['signal'],
        if (raw['fillHintPath'] != null) 'fillHintPath': raw['fillHintPath'],
      };
}
