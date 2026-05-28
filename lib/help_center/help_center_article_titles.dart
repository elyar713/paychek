import '../l10n/app_localizations.dart';

/// Titre localisé d’un article help center à partir de son [slug].
String helpCenterArticleTitle(AppLocalizations l10n, String slug) {
  switch (slug) {
    case 'dashboard':
      return l10n.helpCenterArticleDashboardTitle;
    case 'add_trade':
      return l10n.helpCenterArticleAddTradeTitle;
    case 'trade_page':
      return l10n.helpCenterArticleEditTradeTitle;
    case 'checklist':
      return l10n.helpCenterArticleChecklistTitle;
    case 'calendar':
      return l10n.helpCenterArticleCalendarTitle;
    case 'mental_state':
      return l10n.helpCenterArticleMentalStateTitle;
    case 'my_strategy':
      return l10n.helpCenterArticleMyStrategyTitle;
    case 'my_analysis':
      return l10n.helpCenterArticleMyAnalysisTitle;
    case 'performance':
      return l10n.helpCenterArticlePerformanceTitle;
    default:
      return slug;
  }
}
