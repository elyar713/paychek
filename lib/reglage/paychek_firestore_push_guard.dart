import 'package:flutter/foundation.dart' show debugPrint;

/// Bloque temporairement tous les `pushIfSignedIn` Firestore (changement de compte, merge).
abstract final class PaychekFirestorePushGuard {
  PaychekFirestorePushGuard._();

  static int _depth = 0;

  static bool get isSuppressed => _depth > 0;

  static Future<T> runSuppressed<T>(Future<T> Function() action) async {
    _depth++;
    try {
      return await action();
    } finally {
      _depth--;
    }
  }

  /// Pull cloud au démarrage / reprise : aucun push local tant que la fusion n’est pas finie.
  static Future<void> runCloudHydration(Future<void> Function() merge) async {
    await runSuppressed(merge);
  }

  /// Au merge : `localRev` > `cloudRev` indique souvent une rev locale stale (push accidentel).
  /// On adopte le cloud et on réaligne la rev locale — ne pas repousser l’ancien état mobile.
  static Future<void> adoptCloudWhenLocalRevAhead({
    required int localRev,
    required int cloudRev,
    required String label,
    required Future<void> Function() applyCloud,
    required Future<void> Function(int cloudRev) writeLocalRev,
    Future<void> Function()? afterApply,
  }) async {
    if (cloudRev >= localRev) return;
    debugPrint(
      '[Paychek] $label: localRev=$localRev > cloudRev=$cloudRev — adopt cloud.',
    );
    await applyCloud();
    await writeLocalRev(cloudRev);
    if (afterApply != null) await afterApply();
  }
}
