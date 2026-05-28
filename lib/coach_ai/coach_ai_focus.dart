import 'coach_ai_calendar.dart';
import 'coach_ai_strategy_today.dart';
import 'coach_ai_analysis_today.dart';
import 'coach_ai_app_help.dart';
import 'coach_ai_app_pricing.dart';
import 'coach_ai_checklist_today.dart';
import 'coach_ai_coaching_story.dart';
import 'coach_ai_conversation.dart';
import 'coach_ai_mental_analysis.dart';
import 'coach_ai_non_respect_analysis.dart';
import 'coach_ai_performance_summary.dart';
import 'coach_ai_psych_analysis.dart';
import 'coach_ai_trade_list_query.dart';

/// Routage des intentions Coach AI — source unique côté Flutter.
///
/// ## Familles (structuration produit)
///
/// | Famille | Intention | Carte UI | Données JSON |
/// |---------|-----------|----------|--------------|
/// | **Calendrier mois** | `calendar_month` | Objectif + PnL mois + intro | `calendarMonthContext` |
/// | **Calendrier jour** | `calendar_today` | Synthèse jour + mois + intro | `calendarTodayContext` |
/// | **Stratégie du jour** | `strategy_today` | Setup + signal + risque + intro | `strategyTodayContext` |
/// | **Analyse du jour** | `analysis_today` | Actif + bias + niveaux + intro | `analysisTodayContext` |
/// | **Checklist du jour** | `checklist_today` | % + items ✓/✗ + intro | `checklistTodayContext` |
/// | **État mental du jour** | `mental_today` | Intro + 1–4 (cloud) | `mentalTodayContext` |
/// | **Comment** | `app_help` | Étapes numérotées | `appHelpGuide` uniquement |
/// | **Récit** | `coaching_story` | Thèmes + texte coach | `coachingStoryFocus`, pas d’audit |
/// | **Récit → suite** | `story_followup` | Étapes PAYCHEK numérotées | cloud, après `coaching_story` |
/// | **Données** | `trade_list`, `performance_summary`, … | Liste / KPIs | stats réelles du journal |
///
/// ## Exemples de référence (ne pas inverser)
///
/// **Ex. A — FOMO + avis, puis PAYCHEK**
/// 1. « J’ai pris FOMO… marché parti… qu’en penses-tu ? » → [coaching_story]
/// 2. « Comment régler avec cette app ? » → [story_followup] (étapes locales)
///
/// **Ex. B — Revenge après SL (une seule question)**
/// « Aujourd’hui pullback, SL touché, j’ai renversé contre mon analyse,
/// comment régler cette psycho ? » → [coaching_story] — **pas** `trade_list`.
///
/// **Contre-exemple** : « Quels trades j’ai eu en TILT ? » → [trade_list] seulement
/// si demande explicite de liste + tag.
abstract final class CoachAiFocus {
  static const String coachingStory = 'coaching_story';
  static const String storyFollowUp = 'story_followup';
  static const String appHelp = 'app_help';
  static const String appPricing = 'app_pricing';
  static const String calendarMonth = 'calendar_month';
  static const String calendarToday = 'calendar_today';
  static const String strategyToday = 'strategy_today';
  static const String analysisToday = 'analysis_today';
  static const String checklistToday = 'checklist_today';
  static const String mentalToday = 'mental_today';
  static const String tradeList = 'trade_list';
  static const String tradeCount = 'trade_count';
  static const String performanceSummary = 'performance_summary';

  /// Réponses construites entièrement dans l’app (pas d’appel cloud).
  static bool isLocalOnly(String focus) =>
      focus == appHelp || focus == storyFollowUp || focus == tradeList;

  /// Ordre de priorité : conversation → comment → récit → données explicites → piliers.
  static String resolve(String question, {String? priorAssistantFocus}) {
    final q = question.toLowerCase();
    if (CoachAiConversation.isStoryFollowUp(question, priorAssistantFocus)) {
      return storyFollowUp;
    }
    if (CoachAiConversation.isFocusedTopicFollowUp(question, priorAssistantFocus)) {
      return priorAssistantFocus!;
    }
    if (CoachAiAppPricing.isPricingQuestion(question)) {
      return appPricing;
    }
    if (CoachAiChecklistToday.isTodayChecklistQuestion(question)) {
      return checklistToday;
    }
    if (CoachAiAnalysisToday.isTodayAnalysisQuestion(question)) {
      return analysisToday;
    }
    if (CoachAiStrategyToday.isTodayStrategyQuestion(question)) {
      return strategyToday;
    }
    if (CoachAiCalendar.isMonthCalendarQuestion(question)) {
      return calendarMonth;
    }
    if (CoachAiCalendar.isTodayCalendarQuestion(question)) {
      return calendarToday;
    }
    if (CoachAiMentalAnalysis.isTodayMentalStateQuestion(question)) {
      return mentalToday;
    }
    if (CoachAiAppHelp.isAppHelpQuestion(question)) {
      return appHelp;
    }
    if (RegExp(
      r'(combien|nombre|nb|how many).{0,25}trade|trade.{0,25}(combien|nombre|nb|how many)',
    ).hasMatch(q)) {
      return tradeCount;
    }
    if (CoachAiCoachingStory.isCoachingStoryQuestion(question)) {
      return coachingStory;
    }
    if (CoachAiTradeListQuery.isTradeListQuestion(question)) {
      return tradeList;
    }
    if (CoachAiMentalAnalysis.isMentalPerformanceQuestion(question)) {
      return 'mental_emotion';
    }
    if (CoachAiNonRespectAnalysis.isNonRespectQuestion(question)) {
      return 'non_respect';
    }
    if (CoachAiPsychAnalysis.isPsychologyWhyQuestion(question)) {
      return 'psychology_why';
    }
    if (RegExp(r'checklist').hasMatch(q)) return 'checklist';
    if (RegExp(r'analyse|analysis|plan d.?analyse').hasMatch(q)) return 'analyse';
    if (RegExp(r'strat(é|e)gie|strategy').hasMatch(q)) return 'strategie';
    if (RegExp(r'état mental|etat mental|mental state').hasMatch(q)) {
      return 'mental';
    }
    if (CoachAiPerformanceSummary.isGeneralPerformanceQuestion(question)) {
      return performanceSummary;
    }
    if (RegExp(r'performance|bilan|winrate|pnl|rendement').hasMatch(q)) {
      return 'full';
    }
    return 'coach';
  }

  static String storyFollowUpCardTitle(String languageCode) {
    if (languageCode == 'fr') {
      return 'Corriger le pattern avec PAYCHEK';
    }
    return 'Fix the pattern with PAYCHEK';
  }

  static String coachingStoryCardSubtitle({
    required String languageCode,
    required bool asksHowToFix,
    required bool asksOpinion,
  }) {
    if (languageCode == 'fr') {
      if (asksHowToFix && !asksOpinion) return ' · coaching psycho';
      return ' · ton récit de trade';
    }
    if (asksHowToFix && !asksOpinion) return ' · psycho coaching';
    return ' · your trade story';
  }
}
