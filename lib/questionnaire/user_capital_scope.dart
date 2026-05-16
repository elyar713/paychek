import 'package:flutter/material.dart';

import 'user_capital_store.dart';

/// Fournit [UserCapitalStore] dans l’arbre des widgets.
class UserCapitalScope extends InheritedWidget {
  const UserCapitalScope({
    super.key,
    required this.store,
    required super.child,
  });

  final UserCapitalStore store;

  static UserCapitalStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<UserCapitalScope>();
    assert(scope != null, 'UserCapitalScope introuvable');
    return scope!.store;
  }

  @override
  bool updateShouldNotify(UserCapitalScope oldWidget) => store != oldWidget.store;
}
