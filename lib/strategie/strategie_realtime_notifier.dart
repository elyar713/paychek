import 'package:flutter/foundation.dart';

/// Déclenché après application d’un snapshot cloud Stratégie (setups / usage / horaires / risque / épinglé).
abstract final class StrategieRealtimeNotifier {
  StrategieRealtimeNotifier._();

  static final ValueNotifier<int> tick = ValueNotifier<int>(0);

  static void bump() {
    tick.value = tick.value + 1;
  }
}
