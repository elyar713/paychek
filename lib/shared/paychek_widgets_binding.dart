import 'package:flutter/widgets.dart';

import 'paychek_frame_callbacks.dart';

/// Binding applicatif : invalide les callbacks au reassemble et évite de
/// composer une frame sur une [EngineFlutterView] déjà disposée (hot restart web).
class PaychekWidgetsBinding extends WidgetsFlutterBinding {
  static PaychekWidgetsBinding ensureInitialized() {
    try {
      final existing = WidgetsBinding.instance;
      if (existing is PaychekWidgetsBinding) return existing;
    } catch (_) {
      // Binding pas encore créé (premier appel dans main).
    }
    PaychekWidgetsBinding();
    return WidgetsBinding.instance as PaychekWidgetsBinding;
  }

  @override
  Future<void> performReassemble() async {
    PaychekFrameCallbacks.bumpGeneration();
    await super.performReassemble();
  }

  @override
  void handleDrawFrame() {
    if (!PaychekFrameCallbacks.canSafelyCompositeFrame()) {
      return;
    }
    super.handleDrawFrame();
  }
}
