import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Libellés persistés dans Firestore (`paychek_users`).
abstract final class PaychekClientPlatform {
  PaychekClientPlatform._();

  /// `web` | `android` | `ios` | `desktop` (builds natifs hors mobile).
  static String currentSyncLabel() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'desktop';
    }
  }
}
