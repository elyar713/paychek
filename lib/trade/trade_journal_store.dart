import 'dart:async';

import 'package:flutter/foundation.dart';

import 'trade_journal_firestore_sync.dart';
import 'trade_journal_storage.dart';
import 'trade_models.dart';

/// Journal en mémoire des trades enregistrés depuis "Ajouter un trade".
///
/// **Isolation par portefeuille** : utiliser [itemsForPortfolio] (ou
/// `activeJournalTradesOrDemo` côté UI) — chaque [TradeListItem.portfolioId]
/// rattache le trade au bon compte / broker.
///
/// **Isolation par utilisateur Firebase** : prefs locales + sync
/// [TradeJournalFirestoreSync] (Firestore sous `paychek_users/{uid}/sync_data/`).
/// [PaychekApp] sauvegarde le journal du compte sortant puis [clear] avant reload.
class TradeJournalStore extends ChangeNotifier {
  final List<TradeListItem> _items = <TradeListItem>[];

  Timer? _saveDebounce;
  bool _suppressPersist = false;

  List<TradeListItem> get items => List.unmodifiable(_items);

  List<TradeListItem> itemsForPortfolio(String portfolioId) => _items
      .where((e) => e.portfolioId == portfolioId)
      .toList(growable: false);

  TradeListItem? itemById(String id) {
    for (final t in _items) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Remplace tout le journal (ex. après chargement prefs) sans déclencher de sauvegarde.
  void replaceAll(List<TradeListItem> next) {
    _saveDebounce?.cancel();
    _suppressPersist = true;
    _items
      ..clear()
      ..addAll(next);
    _suppressPersist = false;
    notifyListeners();
  }

  void _persistSoon() {
    if (_suppressPersist) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      final copy = List<TradeListItem>.from(_items);
      unawaited(() async {
        await TradeJournalStorage.save(copy);
        await TradeJournalFirestoreSync.pushIfSignedIn(copy);
      }());
    });
  }

  void add(TradeListItem item) {
    _items.insert(0, item);
    notifyListeners();
    _persistSoon();
  }

  bool removeById(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return false;
    _items.removeAt(idx);
    notifyListeners();
    _persistSoon();
    return true;
  }

  bool update(TradeListItem item) {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx < 0) return false;
    _items[idx] = item;
    notifyListeners();
    _persistSoon();
    return true;
  }

  /// Vide le journal sans écrire sur disque (l’appelant sauvegarde avant si besoin).
  void clear() {
    _saveDebounce?.cancel();
    _items.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    final copy = List<TradeListItem>.from(_items);
    unawaited(() async {
      await TradeJournalStorage.save(copy);
      await TradeJournalFirestoreSync.pushIfSignedIn(copy);
    }());
    super.dispose();
  }
}
