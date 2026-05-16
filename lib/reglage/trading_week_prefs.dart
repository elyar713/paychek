import 'package:shared_preferences/shared_preferences.dart';

import 'paychek_prefs_scope.dart';

abstract final class TradingWeekPrefs {
  static const _kKeyBase = 'trading_week_days';

  // Ce réglage est un choix utilisateur (semaine 5j/7j) → scoppé par compte.
  static String get _kKey => paychekScopedPrefsKey(_kKeyBase);

  static Future<int> load() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getInt(_kKey) ?? 7;
    return (v == 5 || v == 7) ? v : 7;
  }

  static Future<void> save(int days) async {
    assert(days == 5 || days == 7);
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kKey, days);
  }
}
