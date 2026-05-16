import 'package:flutter/material.dart';

import 'user_portfolio_store.dart';

/// Fournit [UserPortfolioStore] dans l’arbre des widgets.
class UserPortfolioScope extends InheritedWidget {
  const UserPortfolioScope({
    super.key,
    required this.store,
    required super.child,
  });

  final UserPortfolioStore store;

  static UserPortfolioStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<UserPortfolioScope>();
    assert(scope != null, 'UserPortfolioScope introuvable');
    return scope!.store;
  }

  @override
  bool updateShouldNotify(UserPortfolioScope oldWidget) =>
      store != oldWidget.store;
}
