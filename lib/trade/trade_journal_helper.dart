import 'package:flutter/widgets.dart';

import '../reglage/user_portfolio_models.dart';
import '../reglage/user_portfolio_scope.dart';
import 'trade_demo_data.dart';
import 'trade_journal_scope.dart';
import 'trade_journal_store.dart';
import 'trade_models.dart';

/// Journal vide sur le portefeuille par défaut → l’app affiche des trades / textes démo.
bool isPaychekJournalDemoMode(BuildContext context) {
  final journal = TradeJournalScope.of(context);
  final portfolios = UserPortfolioScope.of(context);
  final pid = portfolios.activePortfolioId;
  if (pid != kDefaultPortfolioId) return false;
  final raw = journal.itemsForPortfolio(pid);
  if (raw.isEmpty) return true;
  return raw.every((t) => t.id.startsWith('demo_'));
}

/// Journal Coach AI : **portefeuille actif uniquement**, jamais de trades démo.
List<TradeListItem> coachAiJournalTrades(BuildContext context) {
  final journal = TradeJournalScope.of(context);
  final pid = UserPortfolioScope.of(context).activePortfolioId;
  return coachAiJournalTradesForPortfolio(journal, pid);
}

/// Même filtre Coach sans [BuildContext] (labo admin).
List<TradeListItem> coachAiJournalTradesForPortfolio(
  TradeJournalStore journal,
  String portfolioId,
) {
  return journal
      .itemsForPortfolio(portfolioId)
      .where((t) => !t.id.startsWith('demo_'))
      .toList(growable: false);
}

/// Métadonnées portefeuille pour le contexte JSON Coach AI.
Map<String, dynamic> coachAiPortfolioScopeJson(BuildContext context) {
  final store = UserPortfolioScope.of(context);
  final p = store.activePortfolio;
  final name = p?.name.trim() ?? '';
  return <String, dynamic>{
    'scope': 'active_portfolio_only',
    'activePortfolioId': store.activePortfolioId,
    'activePortfolioName':
        name.isEmpty ? kDefaultPortfolioName : name,
    'note':
        'Toutes les stats Coach = ce portefeuille uniquement. '
        'Ignorer tout autre compte / portefeuille supprimé.',
  };
}

/// Supprime du journal les trades rattachés à un portefeuille (local uniquement).
///
/// Pour une suppression complète avec sync Firebase, utiliser
/// `PortfolioDeletionSync.deletePortfolio`.
void purgeJournalTradesForPortfolio(BuildContext context, String portfolioId) {
  TradeJournalScope.of(context).removeAllForPortfolio(portfolioId);
}

/// Nettoie les trades orphelins (portefeuille déjà supprimé mais trades restés).
void purgeOrphanJournalTrades(BuildContext context) {
  final valid = UserPortfolioScope.of(context)
      .items
      .map((p) => p.id)
      .toSet();
  TradeJournalScope.of(context).removeTradesWithUnknownPortfolios(valid);
}

/// Trades du portefeuille actif ; **démonstration** pour [kDefaultPortfolioId]
/// lorsque le journal est encore vide (plan d’analyse, discipline, etc.).
List<TradeListItem> activeJournalTradesOrDemo(BuildContext context) {
  final journal = TradeJournalScope.of(context);
  final portfolios = UserPortfolioScope.of(context);
  final pid = portfolios.activePortfolioId;
  final raw = journal.itemsForPortfolio(pid);
  if (raw.isNotEmpty) return raw;
  if (pid == kDefaultPortfolioId) {
    return tradeDemoItems(locale: Localizations.localeOf(context));
  }
  return const <TradeListItem>[];
}
