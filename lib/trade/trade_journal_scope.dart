import 'package:flutter/material.dart';

import 'trade_journal_store.dart';

/// Fournit [TradeJournalStore] dans l’arbre des widgets.
class TradeJournalScope extends InheritedWidget {
  const TradeJournalScope({
    super.key,
    required this.store,
    required super.child,
  });

  final TradeJournalStore store;

  static TradeJournalStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<TradeJournalScope>();
    assert(scope != null, 'TradeJournalScope introuvable');
    return scope!.store;
  }

  @override
  bool updateShouldNotify(TradeJournalScope oldWidget) => store != oldWidget.store;
}

