import 'package:flutter/widgets.dart';

/// Post-frame callbacks sûrs au **hot restart / hot reload** (Flutter web).
///
/// Au hot restart, l’isolate garde la file du scheduler alors que
/// [EngineFlutterView] est recréée → « Trying to render a disposed
/// EngineFlutterView » si un callback ancien déclenche encore un frame.
abstract final class PaychekFrameCallbacks {
  PaychekFrameCallbacks._();

  static int _generation = 0;

  /// Invalide les callbacks planifiés avant un redémarrage / reassemble.
  static void bumpGeneration() => _generation++;

  /// Vrai lorsqu’une frame peut être composée sans toucher une vue disposée.
  static bool canSafelyCompositeFrame() {
    final binding = WidgetsBinding.instance;
    final views = binding.platformDispatcher.views;
    if (views.isEmpty) return false;
    final root = binding.rootElement;
    return root != null && root.mounted;
  }

  /// Exécute [dispose] au frame suivant (toujours, sans garde de vue).
  ///
  /// Utile pour [TextEditingController] / [FocusNode] : évite
  /// « used after being disposed » si un [TextField] traite encore un geste
  /// (sélection par glisser) au moment du [State.dispose].
  static void disposeAfterFrame(void Function() dispose) {
    WidgetsBinding.instance.addPostFrameCallback((_) => dispose());
  }

  /// Exécute [action] au frame suivant si la génération UI est toujours valide.
  static void runPostFrame(
    VoidCallback action, {
    BuildContext? context,
  }) {
    final gen = _generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gen != _generation) return;
      if (!canSafelyCompositeFrame()) return;
      if (context != null && !context.mounted) return;
      action();
    });
  }
}
