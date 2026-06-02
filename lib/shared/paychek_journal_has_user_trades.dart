import 'package:flutter/widgets.dart';

import '../reglage/user_portfolio_models.dart';
import '../reglage/user_portfolio_scope.dart';
import '../trade/trade_journal_scope.dart';
import '../trade/trade_journal_store.dart';

/// Au moins un trade réel (non `demo_`) sur le portefeuille actif.
bool paychekActivePortfolioHasUserTrades(BuildContext context) {
  final journal = TradeJournalScope.of(context);
  final pid = UserPortfolioScope.of(context).activePortfolioId;
  return paychekPortfolioHasUserTrades(journal, pid);
}

bool paychekPortfolioHasUserTrades(TradeJournalStore journal, String portfolioId) {
  final raw = journal.itemsForPortfolio(portfolioId);
  if (portfolioId != kDefaultPortfolioId) {
    return raw.isNotEmpty;
  }
  return raw.any((t) => !t.id.startsWith('demo_'));
}
