import 'package:shared_preferences/shared_preferences.dart';

import 'paychek_prefs_scope.dart';

/// Révision locale du bundle capital + portefeuilles (avant/après push Firestore).
abstract final class CapitalPortfolioLocalRev {
  CapitalPortfolioLocalRev._();

  static const _kBundleRev = 'capital_portfolio_bundle_rev_v1';

  static String _prefsKey() => paychekScopedPrefsKey(_kBundleRev);

  static Future<int> read() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_prefsKey()) ?? 0;
  }

  /// Incrémente la rev locale dès qu’on persiste capital ou portefeuilles.
  static Future<int> bump() async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now().microsecondsSinceEpoch;
    final cur = p.getInt(_prefsKey()) ?? 0;
    final next = now <= cur ? cur + 1 : now;
    await p.setInt(_prefsKey(), next);
    return next;
  }

  static Future<void> write(int rev) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefsKey(), rev);
  }
}
