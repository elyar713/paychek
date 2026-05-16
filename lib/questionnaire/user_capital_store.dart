import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'trading_currency.dart';

/// Capital saisi : montant + devise — source unique pour l’app.
class UserCapitalStore extends ChangeNotifier {
  static const _kAmount = 'user_capital_amount';
  static const _kCurrency = 'user_capital_currency';
  static const _kCustomName = 'user_capital_custom_name';
  static const _kCustomSymbol = 'user_capital_custom_symbol';
  static const _legacyKeyEuros = 'user_capital_euros';

  String get _prefsKeyAmount => paychekScopedPrefsKey(_kAmount);
  String get _prefsKeyCurrency => paychekScopedPrefsKey(_kCurrency);
  String get _prefsKeyCustomName => paychekScopedPrefsKey(_kCustomName);
  String get _prefsKeyCustomSymbol => paychekScopedPrefsKey(_kCustomSymbol);

  double? _capitalAmount;
  String _currencyCode = kDefaultCurrencyCode;
  String _customCurrencyName = '';
  String _customCurrencySymbol = '';

  /// Montant (sans conversion de change ; unité = [currencyCode] ou devise perso).
  double? get capitalAmount => _capitalAmount;

  String get currencyCode => _currencyCode;

  bool get isCustomCurrency => _currencyCode == kCustomCurrencyCode;

  String? get customCurrencyName =>
      isCustomCurrency && _customCurrencyName.isNotEmpty
          ? _customCurrencyName
          : null;

  String get currencySymbol {
    if (isCustomCurrency) {
      return _customCurrencySymbol.isNotEmpty ? _customCurrencySymbol : r'$';
    }
    return tradingCurrencyByCode(_currencyCode)?.symbol ?? r'$';
  }

  /// Champs bruts (devise perso) pour synchroniser [UserPortfolio].
  String get syncCustomCurrencyName => _customCurrencyName;

  String get syncCustomCurrencySymbol => _customCurrencySymbol;

  /// Anciennes clés **sans** suffixe `__uid__` / `__guest__` (avant isolation par compte).
  Future<void> _migrateLegacyGlobalKeysIfNeeded(SharedPreferences prefs) async {
    if (prefs.getDouble(_prefsKeyAmount) != null) return;
    final euros = prefs.getDouble(_legacyKeyEuros);
    if (euros != null) {
      await prefs.setDouble(_prefsKeyAmount, euros);
      await prefs.setString(_prefsKeyCurrency, 'EUR');
      await prefs.remove(_legacyKeyEuros);
      return;
    }
    final globalAmount = prefs.getDouble(_kAmount);
    if (globalAmount == null) return;
    final globalCode = prefs.getString(_kCurrency);
    final globalName = prefs.getString(_kCustomName);
    final globalSym = prefs.getString(_kCustomSymbol);
    await prefs.setDouble(_prefsKeyAmount, globalAmount);
    if (globalCode != null) {
      await prefs.setString(_prefsKeyCurrency, globalCode);
    }
    if (globalName != null && globalName.isNotEmpty) {
      await prefs.setString(_prefsKeyCustomName, globalName);
    }
    if (globalSym != null && globalSym.isNotEmpty) {
      await prefs.setString(_prefsKeyCustomSymbol, globalSym);
    }
    await prefs.remove(_kAmount);
    await prefs.remove(_kCurrency);
    await prefs.remove(_kCustomName);
    await prefs.remove(_kCustomSymbol);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyGlobalKeysIfNeeded(prefs);
    var amount = prefs.getDouble(_prefsKeyAmount);
    var code = prefs.getString(_prefsKeyCurrency);

    _capitalAmount = amount;
    _customCurrencyName = prefs.getString(_prefsKeyCustomName) ?? '';
    _customCurrencySymbol = prefs.getString(_prefsKeyCustomSymbol) ?? '';

    if (code == kCustomCurrencyCode) {
      _currencyCode = kCustomCurrencyCode;
    } else if (code != null && tradingCurrencyByCode(code) != null) {
      _currencyCode = code;
      _customCurrencyName = '';
      _customCurrencySymbol = '';
    } else if (amount != null) {
      _currencyCode = kDefaultCurrencyCode;
    }
    notifyListeners();
  }

  /// Devise prédéfinie (liste [kTradingCurrencies]).
  Future<void> setCapital({
    required double amount,
    required String currencyCode,
  }) async {
    if (amount.isNaN || amount.isInfinite || amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'Valeur invalide');
    }
    if (tradingCurrencyByCode(currencyCode) == null) {
      throw ArgumentError.value(currencyCode, 'currencyCode', 'Devise inconnue');
    }
    _capitalAmount = amount;
    _currencyCode = currencyCode;
    _customCurrencyName = '';
    _customCurrencySymbol = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKeyAmount, amount);
    await prefs.setString(_prefsKeyCurrency, currencyCode);
    await prefs.remove(_prefsKeyCustomName);
    await prefs.remove(_prefsKeyCustomSymbol);
    await prefs.remove(_legacyKeyEuros);
    notifyListeners();
  }

  /// Devise personnalisée (nom + symbole).
  Future<void> setCapitalCustom({
    required double amount,
    required String name,
    required String symbol,
  }) async {
    if (amount.isNaN || amount.isInfinite || amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'Valeur invalide');
    }
    final n = name.trim();
    final s = symbol.trim();
    if (n.isEmpty && s.isEmpty) {
      throw ArgumentError('Au moins un nom ou symbole requis.');
    }
    final resolvedName = n.isEmpty ? s : n;
    final resolvedSymbol = s.isEmpty ? n : s;
    _capitalAmount = amount;
    _currencyCode = kCustomCurrencyCode;
    _customCurrencyName = resolvedName;
    _customCurrencySymbol = resolvedSymbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKeyAmount, amount);
    await prefs.setString(_prefsKeyCurrency, kCustomCurrencyCode);
    await prefs.setString(_prefsKeyCustomName, resolvedName);
    await prefs.setString(_prefsKeyCustomSymbol, resolvedSymbol);
    await prefs.remove(_legacyKeyEuros);
    notifyListeners();
  }

  Future<void> clear() async {
    _capitalAmount = null;
    _currencyCode = kDefaultCurrencyCode;
    _customCurrencyName = '';
    _customCurrencySymbol = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyAmount);
    await prefs.remove(_prefsKeyCurrency);
    await prefs.remove(_prefsKeyCustomName);
    await prefs.remove(_prefsKeyCustomSymbol);
    await prefs.remove(_legacyKeyEuros);
    notifyListeners();
  }

  /// Applique un snapshot Firestore (sync web / mobile) puis persiste en prefs.
  Future<void> applyFromFirestoreSnapshot(Map<String, dynamic>? row) async {
    if (row == null || row.isEmpty) {
      await clear();
      return;
    }
    final amount = (row['amount'] as num?)?.toDouble();
    if (amount != null && (amount.isNaN || amount.isInfinite || amount < 0)) {
      return;
    }
    final codeRaw = row['currencyCode'] as String?;
    final customName = (row['customName'] as String?) ?? '';
    final customSymbol = (row['customSymbol'] as String?) ?? '';

    _capitalAmount = amount;

    if (codeRaw == kCustomCurrencyCode) {
      _currencyCode = kCustomCurrencyCode;
      _customCurrencyName = customName;
      _customCurrencySymbol = customSymbol;
    } else if (codeRaw != null && tradingCurrencyByCode(codeRaw) != null) {
      _currencyCode = codeRaw;
      _customCurrencyName = '';
      _customCurrencySymbol = '';
    } else if (amount != null) {
      _currencyCode = kDefaultCurrencyCode;
      _customCurrencyName = '';
      _customCurrencySymbol = '';
    } else {
      _currencyCode = kDefaultCurrencyCode;
      _customCurrencyName = '';
      _customCurrencySymbol = '';
    }

    final prefs = await SharedPreferences.getInstance();
    if (amount == null) {
      await prefs.remove(_prefsKeyAmount);
    } else {
      await prefs.setDouble(_prefsKeyAmount, amount);
    }
    await prefs.setString(_prefsKeyCurrency, _currencyCode);
    if (_currencyCode == kCustomCurrencyCode) {
      await prefs.setString(_prefsKeyCustomName, _customCurrencyName);
      await prefs.setString(_prefsKeyCustomSymbol, _customCurrencySymbol);
    } else {
      await prefs.remove(_prefsKeyCustomName);
      await prefs.remove(_prefsKeyCustomSymbol);
    }
    await prefs.remove(_legacyKeyEuros);
    notifyListeners();
  }
}
