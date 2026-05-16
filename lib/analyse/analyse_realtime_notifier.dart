import 'package:flutter/foundation.dart';

/// Petit bus de notification (in-memory) pour rafraîchir l'UI Analyse
/// lorsqu'une mise à jour arrive du cloud en arrière-plan.
abstract final class AnalyseRealtimeNotifier {
  AnalyseRealtimeNotifier._();

  /// Rafraîchit l'aperçu dashboard (étoile + liste) sans relire toute la liste
  /// des rapports sur disque (évite une course avec l'épinglage local).
  static final ValueNotifier<int> tick = ValueNotifier<int>(0);

  /// Relit [AnalyseReportsStorage] et réaligne la liste des rapports (merge cloud, persistance).
  static final ValueNotifier<int> reportsTick = ValueNotifier<int>(0);

  static void bump() {
    tick.value = tick.value + 1;
  }

  static void bumpReports() {
    reportsTick.value = reportsTick.value + 1;
  }
}
