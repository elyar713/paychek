import 'package:flutter/material.dart';

import 'trading_week_prefs.dart';

/// Préférence **5** (lun–ven) ou **7** (lun–dim) pour l’agrégation « semaine ».
class TradingWeekController extends ChangeNotifier {
  TradingWeekController() : _days = 7;

  int _days;

  int get tradingDaysPerWeek => _days;

  Future<void> load() async {
    _days = await TradingWeekPrefs.load();
    notifyListeners();
  }

  Future<void> select(int days) async {
    if (days != 5 && days != 7) return;
    await TradingWeekPrefs.save(days);
    _days = days;
    notifyListeners();
  }

  /// Applique une valeur venant du cloud (sync multi-device) puis persiste localement.
  Future<void> applyFromCloud(int days) async {
    if (days != 5 && days != 7) return;
    if (_days == days) return;
    await TradingWeekPrefs.save(days);
    _days = days;
    notifyListeners();
  }
}

class TradingWeekScope extends InheritedWidget {
  const TradingWeekScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final TradingWeekController controller;

  static TradingWeekController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<TradingWeekScope>();
    assert(scope != null, 'TradingWeekScope introuvable');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(TradingWeekScope oldWidget) =>
      controller != oldWidget.controller;
}
