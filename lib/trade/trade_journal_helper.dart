import 'package:flutter/widgets.dart';

import '../reglage/user_portfolio_models.dart';
import '../reglage/user_portfolio_scope.dart';
import 'trade_demo_data.dart';
import 'trade_journal_scope.dart';
import 'trade_models.dart';

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
