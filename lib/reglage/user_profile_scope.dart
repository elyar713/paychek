import 'package:flutter/material.dart';

import 'user_profile_store.dart';

/// Fournit [UserProfileStore] dans l’arbre des widgets.
class UserProfileScope extends InheritedWidget {
  const UserProfileScope({
    super.key,
    required this.store,
    required super.child,
  });

  final UserProfileStore store;

  static UserProfileStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<UserProfileScope>();
    assert(scope != null, 'UserProfileScope introuvable');
    return scope!.store;
  }

  @override
  bool updateShouldNotify(UserProfileScope oldWidget) =>
      store != oldWidget.store;
}
