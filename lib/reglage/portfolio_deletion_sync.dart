import 'package:flutter/widgets.dart';

import '../questionnaire/user_capital_scope.dart';
import '../trade/trade_journal_firestore_sync.dart';
import '../trade/trade_journal_scope.dart';
import '../trade/trade_journal_storage.dart';
import '../trade/trade_models.dart';
import 'capital_portfolio_firestore_sync.dart';
import 'user_portfolio_scope.dart';

/// Suppression portefeuille : local + Firebase (journal trades + liste portefeuilles).
abstract final class PortfolioDeletionSync {
  PortfolioDeletionSync._();

  /// Retire le portefeuille, purge ses trades et pousse immédiatement sur Firestore.
  static Future<bool> deletePortfolio(
    BuildContext context, {
    required String portfolioId,
  }) async {
    final portfolio = UserPortfolioScope.of(context);
    if (!portfolio.canRemovePortfolio(portfolioId)) return false;

    return TradeJournalFirestoreSync.runWithRemoteApplySuppressed(() async {
      final journal = TradeJournalScope.of(context);
      final capital = UserCapitalScope.of(context);

      journal.removeAllForPortfolio(portfolioId);
      final journalItems = List<TradeListItem>.from(journal.items);
      await TradeJournalStorage.save(journalItems);
      await TradeJournalFirestoreSync.pushIfSignedIn(journalItems);

      await portfolio.remove(portfolioId);
      await CapitalPortfolioFirestoreSync.pushIfSignedIn(capital, portfolio);

      return true;
    });
  }
}
