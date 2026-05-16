import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'paychek_prefs_scope.dart';
import '../questionnaire/trading_currency.dart';
import '../questionnaire/user_capital_store.dart';
import 'user_portfolio_models.dart';

/// Liste des portefeuilles (multi-brokers) — persistance locale.
class UserPortfolioStore extends ChangeNotifier {
  static const _kPrefsKey = 'user_portfolios_v1';
  static const _kPrefsActiveIdKey = 'user_portfolio_active_id_v1';

  String get _prefsKey => paychekScopedPrefsKey(_kPrefsKey);
  String get _prefsActiveIdKey => paychekScopedPrefsKey(_kPrefsActiveIdKey);

  List<UserPortfolio> _items = [];
  String _activePortfolioId = kDefaultPortfolioId;

  List<UserPortfolio> get items => List.unmodifiable(_items);

  /// Portefeuille utilisé pour le capital, le journal et les écrans trading.
  String get activePortfolioId => _activePortfolioId;

  UserPortfolio? get activePortfolio {
    for (final e in _items) {
      if (e.id == _activePortfolioId) return e;
    }
    return _items.isEmpty ? null : _items.first;
  }

  int get count => _items.length;

  /// Anciennes clés globales (avant isolation par compte).
  Future<void> _migrateLegacyGlobalPortfoliosIfNeeded(SharedPreferences prefs) async {
    final existing = prefs.getString(_prefsKey);
    if (existing != null && existing.trim().isNotEmpty) return;
    final globalList = prefs.getString(_kPrefsKey);
    if (globalList == null || globalList.trim().isEmpty) return;
    await prefs.setString(_prefsKey, globalList);
    final globalActive = prefs.getString(_kPrefsActiveIdKey);
    if (globalActive != null && globalActive.isNotEmpty) {
      await prefs.setString(_prefsActiveIdKey, globalActive);
    }
    await prefs.remove(_kPrefsKey);
    await prefs.remove(_kPrefsActiveIdKey);
  }

  Future<void> load({UserCapitalStore? seedCapital}) async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyGlobalPortfoliosIfNeeded(prefs);
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      _items = [];
      notifyListeners();
      if (seedCapital != null) await ensureDefaultPortfolio(seedCapital);
      _reconcileActivePortfolioId(prefs.getString(_prefsActiveIdKey));
      await _persistActiveId();
      notifyListeners();
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _items = list
          .map((e) => UserPortfolio.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      _items = [];
    }
    notifyListeners();
    if (seedCapital != null) await ensureDefaultPortfolio(seedCapital);
    _reconcileActivePortfolioId(prefs.getString(_prefsActiveIdKey));
    await _persistActiveId();
    notifyListeners();
  }

  void _reconcileActivePortfolioId(String? saved) {
    if (_items.isEmpty) {
      _activePortfolioId = kDefaultPortfolioId;
      return;
    }
    if (saved != null && _items.any((e) => e.id == saved)) {
      _activePortfolioId = saved;
      return;
    }
    _activePortfolioId = _items.any((e) => e.id == kDefaultPortfolioId)
        ? kDefaultPortfolioId
        : _items.first.id;
  }

  Future<void> _persistActiveId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsActiveIdKey, _activePortfolioId);
  }

  Future<void> setActivePortfolioId(String id) async {
    if (!_items.any((e) => e.id == id)) return;
    if (_activePortfolioId == id) return;
    _activePortfolioId = id;
    await _persistActiveId();
    notifyListeners();
  }

  /// Capital affiché selon le portefeuille actif (global pour [kDefaultPortfolioId]).
  double? effectiveCapitalAmount(UserCapitalStore global) {
    final p = activePortfolio;
    if (p == null) return global.capitalAmount;
    if (p.id == kDefaultPortfolioId) return global.capitalAmount;
    return p.capitalAmount;
  }

  String effectiveCurrencyCode(UserCapitalStore global) {
    final p = activePortfolio;
    if (p == null) return global.currencyCode;
    if (p.id == kDefaultPortfolioId) return global.currencyCode;
    return p.currencyCode;
  }

  bool effectiveIsCustomCurrency(UserCapitalStore global) {
    final p = activePortfolio;
    if (p == null) return global.isCustomCurrency;
    if (p.id == kDefaultPortfolioId) return global.isCustomCurrency;
    return p.isCustomCurrency;
  }

  String effectiveCurrencySymbol(UserCapitalStore global) {
    final p = activePortfolio;
    if (p == null) return global.currencySymbol;
    if (p.id == kDefaultPortfolioId) return global.currencySymbol;
    if (p.isCustomCurrency) {
      return p.customCurrencySymbol.isNotEmpty ? p.customCurrencySymbol : r'$';
    }
    return tradingCurrencyByCode(p.currencyCode)?.symbol ?? r'$';
  }

  /// Garantit [kDefaultPortfolioId] : capital / devise alignés sur [UserCapitalStore].
  Future<void> ensureDefaultPortfolio(UserCapitalStore capital) async {
    if (_items.any((e) => e.id == kDefaultPortfolioId)) return;
    final p = UserPortfolio(
      id: kDefaultPortfolioId,
      name: kDefaultPortfolioName,
      capitalAmount: capital.capitalAmount,
      currencyCode: capital.currencyCode,
      customCurrencyName:
          capital.isCustomCurrency ? capital.syncCustomCurrencyName : '',
      customCurrencySymbol:
          capital.isCustomCurrency ? capital.syncCustomCurrencySymbol : '',
    );
    _items = [p, ..._items];
    await _persist();
  }

  /// Après changement du capital global (questionnaire, réglages Capital).
  Future<void> syncDefaultFromCapital(
    UserCapitalStore capital, {
    String? displayName,
  }) async {
    await ensureDefaultPortfolio(capital);
    final i = _items.indexWhere((e) => e.id == kDefaultPortfolioId);
    if (i < 0) return;
    final old = _items[i];
    final name = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : (old.name.isNotEmpty ? old.name : kDefaultPortfolioName);
    final p = UserPortfolio(
      id: kDefaultPortfolioId,
      name: name,
      capitalAmount: capital.capitalAmount,
      currencyCode: capital.currencyCode,
      customCurrencyName:
          capital.isCustomCurrency ? capital.syncCustomCurrencyName : '',
      customCurrencySymbol:
          capital.isCustomCurrency ? capital.syncCustomCurrencySymbol : '',
    );
    _items = [..._items]..[i] = p;
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  /// Remplace la liste depuis Firestore (sync web / mobile).
  Future<void> applyFromFirestoreSnapshot(
    UserCapitalStore capital,
    List<dynamic> rawPortfolios,
    String? activePortfolioId,
  ) async {
    final items = <UserPortfolio>[];
    for (final e in rawPortfolios) {
      if (e is Map) {
        try {
          items.add(
            UserPortfolio.fromJson(Map<String, dynamic>.from(e)),
          );
        } catch (_) {}
      }
    }
    _items = items;
    if (_items.isEmpty) {
      await ensureDefaultPortfolio(capital);
    }
    _reconcileActivePortfolioId(activePortfolioId);
    await _persist();
    await _persistActiveId();
    notifyListeners();
  }

  Future<void> add(UserPortfolio p) async {
    _items = [..._items, p];
    await _persist();
  }

  Future<void> upsert(UserPortfolio p) async {
    final i = _items.indexWhere((e) => e.id == p.id);
    if (i < 0) {
      _items = [..._items, p];
    } else {
      _items = [..._items]..[i] = p;
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    if (id == kDefaultPortfolioId) return;
    _items = _items.where((e) => e.id != id).toList();
    if (_activePortfolioId == id) {
      _activePortfolioId = _items.any((e) => e.id == kDefaultPortfolioId)
          ? kDefaultPortfolioId
          : _items.first.id;
      await _persistActiveId();
    }
    await _persist();
  }

  String displayLine(UserPortfolio p) {
    final sym = p.isCustomCurrency
        ? (p.customCurrencySymbol.isNotEmpty ? p.customCurrencySymbol : r'$')
        : (tradingCurrencyByCode(p.currencyCode)?.symbol ?? r'$');
    final code = p.isCustomCurrency
        ? (p.customCurrencyName.isNotEmpty ? p.customCurrencyName : 'Perso')
        : (tradingCurrencyByCode(p.currencyCode)?.code ?? p.currencyCode);
    final a = p.capitalAmount;
    if (a == null) return code;
    final s = _formatThousands(a);
    return '$s $sym · $code';
  }

  String summaryForRow() {
    if (_items.isEmpty) return kDefaultPortfolioName;
    if (_items.length == 1) {
      final n = _items.first.name;
      return n.isEmpty ? kDefaultPortfolioName : n;
    }
    return '${_items.length} portefeuilles';
  }
}

String _formatThousands(double value) {
  final v = value.round().abs();
  final s = v.toString();
  final len = s.length;
  final out = StringBuffer();
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) out.write(' ');
    out.write(s[i]);
  }
  return out.toString();
}
