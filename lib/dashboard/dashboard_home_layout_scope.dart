import 'package:flutter/material.dart';

import 'dashboard_home_layout_store.dart';

class DashboardHomeLayoutScope extends InheritedNotifier<DashboardHomeLayoutStore> {
  const DashboardHomeLayoutScope({
    super.key,
    required DashboardHomeLayoutStore store,
    required super.child,
  }) : super(notifier: store);

  static DashboardHomeLayoutStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DashboardHomeLayoutScope>();
    assert(scope != null, 'DashboardHomeLayoutScope introuvable');
    return scope!.notifier!;
  }
}
