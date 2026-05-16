import 'package:flutter/foundation.dart';

/// Après fusion / snapshot cloud checklist → [DashboardPage] recharge le contrôleur.
abstract final class ChecklistRealtimeNotifier {
  ChecklistRealtimeNotifier._();

  static final ValueNotifier<int> tick = ValueNotifier<int>(0);

  static void bump() {
    tick.value = tick.value + 1;
  }
}
