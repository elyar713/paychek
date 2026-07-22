import 'dart:async';

import 'package:flutter/foundation.dart';

import 'trade_journal_firestore_sync.dart';
import 'trade_journal_storage.dart';
import 'trade_models.dart';
import 'trade_screenshot_storage.dart';

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
  TradeJournalStore({this.remoteMirrorOnly = false});

  /// Miroir Firestore admin (labo Coach) : pas d’écriture prefs / cloud admin.
  final bool remoteMirrorOnly;

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

  /// Remplace le journal (hydratation prefs / merge cloud).
  ///
  /// Ne laisse pas tomber une sauvegarde debounce en cours : fusionne les items
  /// mémoire plus récents / absents de [next], puis re-planifie un persist si
  /// besoin (évite la perte de trades ajoutés pendant un snapshot cloud).
  void replaceAll(List<TradeListItem> next) {
    final hadPendingPersist = _saveDebounce?.isActive == true;
    _saveDebounce?.cancel();

    final byId = <String, TradeListItem>{for (final t in next) t.id: t};
    for (final t in _items) {
      final c = byId[t.id];
      if (c == null) {
        byId[t.id] = t;
        continue;
      }
      if (t.syncRev > c.syncRev) {
        byId[t.id] = t;
        continue;
      }
      var winner = c;
      if ((winner.screenshotBytes == null || winner.screenshotBytes!.isEmpty) &&
          t.screenshotBytes != null &&
          t.screenshotBytes!.isNotEmpty) {
        winner = winner.copyWith(screenshotBytes: t.screenshotBytes);
      }
      if ((winner.screenshotStoragePath == null ||
              winner.screenshotStoragePath!.trim().isEmpty) &&
          t.screenshotStoragePath != null &&
          t.screenshotStoragePath!.trim().isNotEmpty) {
        winner = winner.copyWith(
          screenshotStoragePath: t.screenshotStoragePath,
        );
      }
      byId[t.id] = winner;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => b.entreeAt.compareTo(a.entreeAt));

    final grewOrDiverged = merged.length != next.length ||
        !_sameIdsAndRevs(merged, next);

    _suppressPersist = true;
    _items
      ..clear()
      ..addAll(merged);
    _suppressPersist = false;
    notifyListeners();

    if (hadPendingPersist || grewOrDiverged) {
      _persistSoon();
    }
  }

  static bool _sameIdsAndRevs(List<TradeListItem> a, List<TradeListItem> b) {
    if (a.length != b.length) return false;
    final bm = {for (final t in b) t.id: t.syncRev};
    for (final t in a) {
      if (bm[t.id] != t.syncRev) return false;
    }
    return true;
  }

  void _persistSoon() {
    if (_suppressPersist || remoteMirrorOnly) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      final copy = List<TradeListItem>.from(_items);
      unawaited(() async {
        final synced = await _syncScreenshotsBeforePersist(copy);
        await TradeJournalStorage.save(synced);
        await TradeJournalFirestoreSync.pushIfSignedIn(synced);
      }());
    });
  }

  Future<List<TradeListItem>> _syncScreenshotsBeforePersist(
    List<TradeListItem> items,
  ) async {
    final out = <TradeListItem>[];
    var storeChanged = false;
    for (final t in items) {
      final alreadyCloud = t.screenshotStoragePath?.trim().isNotEmpty == true;
      final needsUpload = !alreadyCloud &&
          ((t.screenshotBytes != null && t.screenshotBytes!.isNotEmpty) ||
              (t.screenshotPath != null && t.screenshotPath!.trim().isNotEmpty));
      if (!needsUpload) {
        out.add(t);
        continue;
      }
      final uploaded = await TradeScreenshotCloud.ensureUploaded(t);
      out.add(uploaded);
      if (uploaded.screenshotStoragePath != t.screenshotStoragePath) {
        storeChanged = true;
      }
    }
    if (storeChanged && !_suppressPersist) {
      _suppressPersist = true;
      for (final t in out) {
        final idx = _items.indexWhere((e) => e.id == t.id);
        if (idx >= 0) _items[idx] = t;
      }
      _suppressPersist = false;
      notifyListeners();
    }
    return out;
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

  /// Retire les trades dont le [portfolioId] n’existe plus (portefeuilles supprimés).
  int removeTradesWithUnknownPortfolios(Set<String> validPortfolioIds) {
    if (validPortfolioIds.isEmpty) return 0;
    final before = _items.length;
    _items.removeWhere((e) => !validPortfolioIds.contains(e.portfolioId));
    final removed = before - _items.length;
    if (removed > 0) {
      notifyListeners();
      _persistSoon();
    }
    return removed;
  }

  /// Retire tous les trades d’un portefeuille (ex. après suppression du compte).
  int removeAllForPortfolio(String portfolioId) {
    final before = _items.length;
    _items.removeWhere((e) => e.portfolioId == portfolioId);
    final removed = before - _items.length;
    if (removed > 0) {
      notifyListeners();
      _persistSoon();
    }
    return removed;
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
    if (!remoteMirrorOnly) {
      final copy = List<TradeListItem>.from(_items);
      unawaited(() async {
        final synced = await _syncScreenshotsBeforePersist(copy);
        await TradeJournalStorage.save(synced);
        await TradeJournalFirestoreSync.pushIfSignedIn(synced);
      }());
    }
    super.dispose();
  }
}
