import 'dart:async' show Timer, unawaited;

import 'package:flutter/material.dart';

import 'checklist_daily_completion_storage.dart';
import 'checklist_daily_day_snapshot.dart';
import 'checklist_firestore_sync.dart';
import 'checklist_item_period.dart';
import 'checklist_item_schedule.dart';
import 'checklist_item_schedule_sort.dart';
import 'checklist_models.dart';
import 'checklist_prompts.dart';
import 'checklist_sections_storage.dart';
import 'widgets/checklist_delete_section_dialog.dart';

/// État et actions de [ChecklistPage] (hors arbre de widgets).
class ChecklistPageController extends ChangeNotifier {
  ChecklistPageController()
      : _sections = defaultNouveauTradeSections()
            .map(
              (s) => ChecklistSectionData(
                id: s.id,
                title: s.title,
                enabled: s.enabled,
                items: s.items
                    .map(
                      (i) => ChecklistItemData(
                        id: i.id,
                        label: i.label,
                        checked: i.checked,
                        checkedAt: i.checkedAt,
                        schedule: i.schedule,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList() {
    itemLabelFocusNode.addListener(_onItemLabelFocusChange);
  }

  List<ChecklistSectionData> _sections;

  Timer? _saveDebounce;
  bool _hydrated = false;
  Map<int, ChecklistDailyDaySnapshot> _snapshotsByDay = {};

  /// Dernier jour calendaire traité (clôture 23:59 → snapshot).
  DateTime? _calendarAnchorDay;

  static DateTime _dateOnly(DateTime d) =>
      ChecklistItemPeriod.dateOnly(d);

  bool _isHistoricalDay(DateTime day) {
    final d = _dateOnly(day);
    final today = _dateOnly(DateTime.now());
    return d.isBefore(today);
  }

  bool _itemDoneOnDay(ChecklistItemData item, DateTime day) {
    if (_isHistoricalDay(day)) {
      if (item.isCompletedForCalendarDay(day)) return true;
      // Anciennes coches sans checkedAt (avant clôture journalière).
      if (item.checked && item.checkedAt == null && item.isDueOnDay(day)) {
        return true;
      }
      return false;
    }
    return item.isCompletedForCurrentPeriod(day);
  }

  /// Charge l’état persisté ; à appeler une fois au démarrage (ex. [DashboardPage]).
  Future<void> hydrateFromStorage() async {
    final data = await ChecklistSectionsStorage.load();
    if (data != null && data.isNotEmpty) {
      _sections = checklistEnsureProtectedSections(data);
    }
    _snapshotsByDay = await ChecklistDailyCompletionStorage.load();
    _hydrated = true;
    _sealCompletionForPastDays();
    _refreshCompletionPeriods(silent: true);
    notifyListeners();
    _snapshotTodayCompletion();
  }

  void _persistSoon() {
    if (!_hydrated) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_persistToDiskAndCloud());
    });
  }

  Future<void> _persistToDiskAndCloud() async {
    _sections = checklistEnsureProtectedSections(_sections);
    await ChecklistSectionsStorage.save(_sections);
    await ChecklistFirestoreSync.pushIfSignedIn();
  }

  String? editingSectionId;
  ChecklistSectionData? sectionEditSnapshot;
  bool sectionEditInteraction = false;

  final TextEditingController sectionTitleEditController =
      TextEditingController();
  final FocusNode sectionTitleFocusNode = FocusNode();

  String? editingItemId;
  String? draftItemId;
  final TextEditingController itemLabelEditController =
      TextEditingController();
  final FocusNode itemLabelFocusNode = FocusNode();

  /// Carte en cours de modification (hit-test pour tap hors carte).
  final GlobalKey sectionEditCardKey = GlobalKey();

  bool _disposed = false;

  /// Sync cloud demandée pendant une édition en cours → appliquée après commit / cancel.
  bool _reloadDeferred = false;

  /// Pendant un rebuild (nouvelle ligne +), le [TextField] précédent lâche le focus :
  /// sans garde, [commitItemLabelEdit] supprime le brouillon vide tout de suite.
  int _itemLabelBlurCommitPause = 0;

  bool get isEditingChecklist =>
      editingSectionId != null || editingItemId != null;

  void _postFrame(void Function() fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      fn();
    });
  }

  List<ChecklistSectionData> get sections => _sections;

  /// Sections / lignes triées par date+heure de rappel la plus proche.
  List<ChecklistSectionData> get sectionsSortedBySchedule =>
      checklistSectionsSortedBySchedule(_sections);

  int get totalItems => _sections.fold<int>(
        0,
        (n, s) =>
            checklistSectionIsActive(s) ? n + s.items.length : n,
      );

  int get checkedItems => _sections.fold<int>(
        0,
        (n, s) => checklistSectionIsActive(s)
            ? n +
                s.items.where((i) => i.isCompletedForCurrentPeriod()).length
            : n,
      );

  /// Lignes dont le rappel tombe sur [day] (défaut : aujourd’hui).
  int itemsDueOnDayCount([DateTime? day]) {
    var n = 0;
    for (final s in _sections) {
      if (!checklistSectionIsActive(s)) continue;
      for (final i in s.items) {
        if (i.isDueOnDay(day)) n++;
      }
    }
    return n;
  }

  int itemsDueOnDayCheckedCount([DateTime? day]) {
    final on = day ?? DateTime.now();
    var n = 0;
    for (final s in _sections) {
      if (!checklistSectionIsActive(s)) continue;
      for (final i in s.items) {
        if (i.isDueOnDay(on) && _itemDoneOnDay(i, on)) n++;
      }
    }
    return n;
  }

  int get totalItemsDueToday => itemsDueOnDayCount();

  int get checkedItemsDueToday => itemsDueOnDayCheckedCount();

  /// Anneau du jour : uniquement les critères concernés aujourd’hui.
  int get checklistCompletionPercent => completionPercentOnDay(DateTime.now());

  /// % checklist pour un jour donné (critères dus ce jour-là).
  int completionPercentOnDay(DateTime day) {
    final total = itemsDueOnDayCount(day);
    if (total == 0) return 100;
    return ((100 * itemsDueOnDayCheckedCount(day)) / total).round().clamp(0, 100);
  }

  /// Historique checklist enregistré pour ce jour (snapshot local).
  bool hasSnapshotForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _snapshotsByDay.containsKey(
      ChecklistDailyCompletionStorage.dayKey(d),
    );
  }

  /// Au moins une case cochée ce jour-là (live aujourd’hui, historique sinon).
  bool hasChecklistCheckedOnDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (d == today) {
      return itemsDueOnDayCheckedCount(d) > 0;
    }
    if (d.isAfter(today)) return false;
    final stored = _snapshotsByDay[ChecklistDailyCompletionStorage.dayKey(d)];
    return stored != null && stored.percent > 0;
  }

  List<ChecklistUncheckedDayEntry> _uncheckedEntriesForDay(DateTime day) {
    final out = <ChecklistUncheckedDayEntry>[];
    for (final s in _sections) {
      if (!checklistSectionIsActive(s)) continue;
      for (final i in s.items) {
        if (i.isDueOnDay(day) && !_itemDoneOnDay(i, day)) {
          out.add(
            ChecklistUncheckedDayEntry(
              sectionId: s.id,
              sectionTitle: s.title,
              itemId: i.id,
              itemLabel: i.label,
            ),
          );
        }
      }
    }
    return out;
  }

  /// Affiche les lignes historiques même si l’élément a été supprimé depuis.
  List<ChecklistUncheckedDayEntry> _resolveStoredUncheckedEntries(
    List<ChecklistUncheckedDayEntry> stored,
  ) {
    if (stored.isEmpty) return const [];

    final liveByItemId = <String, ChecklistUncheckedDayEntry>{};
    for (final s in _sections) {
      for (final i in s.items) {
        liveByItemId[i.id] = ChecklistUncheckedDayEntry(
          sectionId: s.id,
          sectionTitle: s.title,
          itemId: i.id,
          itemLabel: i.label,
        );
      }
    }

    final out = <ChecklistUncheckedDayEntry>[];
    for (final e in stored) {
      final live = liveByItemId[e.itemId];
      if (live != null) {
        out.add(
          ChecklistUncheckedDayEntry(
            sectionId: live.sectionId,
            sectionTitle: live.sectionTitle,
            itemId: e.itemId,
            itemLabel: live.itemLabel.isNotEmpty ? live.itemLabel : e.itemLabel,
          ),
        );
      } else if (e.itemLabel.isNotEmpty || e.sectionTitle.isNotEmpty) {
        out.add(e);
      }
    }
    return out;
  }

  void _freezeItemInPastSnapshots({
    required String sectionId,
    required String sectionTitle,
    required String itemId,
    required String itemLabel,
  }) {
    if (itemLabel.isEmpty && sectionTitle.isEmpty) return;

    final frozen = ChecklistUncheckedDayEntry(
      sectionId: sectionId,
      sectionTitle: sectionTitle,
      itemId: itemId,
      itemLabel: itemLabel,
    );

    var anyChanged = false;
    for (final k in _snapshotsByDay.keys.toList()) {
      final snap = _snapshotsByDay[k]!;
      if (!snap.uncheckedItemIds.contains(itemId)) continue;

      final nextEntries = <ChecklistUncheckedDayEntry>[];
      var snapChanged = false;
      var found = false;
      for (final e in snap.uncheckedEntries) {
        if (e.itemId != itemId) {
          nextEntries.add(e);
          continue;
        }
        found = true;
        if (e.itemLabel.isNotEmpty && e.sectionTitle.isNotEmpty) {
          nextEntries.add(e);
        } else {
          nextEntries.add(frozen);
          snapChanged = true;
        }
      }
      if (!found) {
        nextEntries.add(frozen);
        snapChanged = true;
      }
      if (snapChanged) {
        _snapshotsByDay[k] = snap.copyWith(uncheckedEntries: nextEntries);
        anyChanged = true;
      }
    }
    if (anyChanged) {
      unawaited(ChecklistDailyCompletionStorage.save(_snapshotsByDay));
    }
  }

  int _completionPercentForDay(DateTime day) {
    final total = itemsDueOnDayCount(day);
    if (total == 0) return 100;
    return ((100 * itemsDueOnDayCheckedCount(day)) / total).round().clamp(0, 100);
  }

  void _writeDaySnapshot(DateTime day) {
    final d = _dateOnly(day);
    final due = itemsDueOnDayCount(d);
    if (due == 0) return;
    final k = ChecklistDailyCompletionStorage.dayKey(d);
    final pct = _completionPercentForDay(d);
    final uncheckedEntries = _uncheckedEntriesForDay(d);
    _snapshotsByDay[k] = ChecklistDailyDaySnapshot(
      percent: pct,
      uncheckedEntries: uncheckedEntries,
    );
  }

  void _sealDaySnapshotIfMissing(DateTime day) {
    final d = _dateOnly(day);
    final k = ChecklistDailyCompletionStorage.dayKey(d);
    if (_snapshotsByDay.containsKey(k)) return;
    _writeDaySnapshot(d);
  }

  /// Clôture les jours passés (23:59) avant de réinitialiser les coches du jour.
  void _sealCompletionForPastDays() {
    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    if (_calendarAnchorDay != null && _calendarAnchorDay != today) {
      var d = _calendarAnchorDay!;
      while (d.isBefore(today)) {
        _writeDaySnapshot(d);
        d = d.add(const Duration(days: 1));
      }
    } else {
      _sealDaySnapshotIfMissing(yesterday);
    }
    _calendarAnchorDay = today;

    if (_snapshotsByDay.isNotEmpty) {
      unawaited(ChecklistDailyCompletionStorage.save(_snapshotsByDay));
    }
  }

  List<ChecklistUncheckedDayEntry> uncheckedEntriesForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (d.isAfter(today)) return const [];

    if (d == today) return _uncheckedEntriesForDay(d);

    final stored =
        _snapshotsByDay[ChecklistDailyCompletionStorage.dayKey(d)];
    if (stored == null) return const [];

    return _resolveStoredUncheckedEntries(stored.uncheckedEntries);
  }

  /// % affiché dans le mini-calendrier (historique + jour courant en direct).
  ///
  /// Jour tradé sans case cochée → **0 %**. Sans trade ni critère dû → rien.
  int? completionPercentForCalendarDay(DateTime day, {int tradeCount = 0}) {
    final d = DateTime(day.year, day.month, day.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (d.isAfter(today)) return null;

    final due = itemsDueOnDayCount(d);
    final checked = itemsDueOnDayCheckedCount(d);
    final hasTrades = tradeCount > 0;

    if (d == today) {
      if (!hasTrades && checked == 0 && due == 0) return null;
      if (checked == 0) return 0;
      return completionPercentOnDay(d);
    }

    final k = ChecklistDailyCompletionStorage.dayKey(d);
    final stored = _snapshotsByDay[k];
    final retro = _completionPercentForDay(d);

    if (stored != null) {
      if (retro > stored.percent) return retro;
      return stored.percent;
    }

    if (due > 0) return retro;
    if (hasTrades) return 0;
    return null;
  }

  void _snapshotTodayCompletion() {
    if (!_hydrated) return;
    final now = DateTime.now();
    final k = ChecklistDailyCompletionStorage.dayKey(
      DateTime(now.year, now.month, now.day),
    );
    final checked = itemsDueOnDayCheckedCount(now);
    final due = itemsDueOnDayCount(now);
    final uncheckedEntries = _uncheckedEntriesForDay(now);
    if (checked == 0) {
      if (due > 0) {
        final next = ChecklistDailyDaySnapshot(
          percent: 0,
          uncheckedEntries: uncheckedEntries,
        );
        final prev = _snapshotsByDay[k];
        if (prev != null &&
            prev.percent == 0 &&
            _uncheckedEntriesEqual(prev.uncheckedEntries, uncheckedEntries)) {
          return;
        }
        _snapshotsByDay[k] = next;
        unawaited(ChecklistDailyCompletionStorage.save(_snapshotsByDay));
        return;
      }
      if (!_snapshotsByDay.containsKey(k)) return;
      _snapshotsByDay.remove(k);
      unawaited(ChecklistDailyCompletionStorage.save(_snapshotsByDay));
      return;
    }
    final pct = completionPercentOnDay(now);
    final next = ChecklistDailyDaySnapshot(
      percent: pct,
      uncheckedEntries: uncheckedEntries,
    );
    final prev = _snapshotsByDay[k];
    if (prev != null &&
        prev.percent == next.percent &&
        _uncheckedEntriesEqual(prev.uncheckedEntries, next.uncheckedEntries)) {
      return;
    }
    _snapshotsByDay[k] = next;
    unawaited(ChecklistDailyCompletionStorage.save(_snapshotsByDay));
  }

  static bool _uncheckedEntriesEqual(
    List<ChecklistUncheckedDayEntry> a,
    List<ChecklistUncheckedDayEntry> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];
      if (x.itemId != y.itemId ||
          x.itemLabel != y.itemLabel ||
          x.sectionId != y.sectionId ||
          x.sectionTitle != y.sectionTitle) {
        return false;
      }
    }
    return true;
  }

  void _refreshCompletionPeriods({bool silent = false}) {
    final now = DateTime.now();
    final today = _dateOnly(now);
    if (_calendarAnchorDay != null && _calendarAnchorDay != today) {
      _sealCompletionForPastDays();
    }
    _calendarAnchorDay ??= today;

    var changed = false;
    _sections = _sections.map((section) {
      final nextItems = section.items.map((item) {
        final normalized = ChecklistItemPeriod.normalizeCheckedState(item, now);
        if (normalized != item) changed = true;
        return normalized;
      }).toList();
      return section.copyWith(items: nextItems);
    }).toList();
    if (changed && !silent) {
      _persistSoon();
    }
  }

  void _notifyChecklistChanged() {
    _refreshCompletionPeriods(silent: true);
    notifyListeners();
    _snapshotTodayCompletion();
  }

  void _flushDeferredReloadIfNeeded() {
    if (!_reloadDeferred || isEditingChecklist) return;
    _reloadDeferred = false;
    unawaited(reloadFromStorage());
  }

  /// Recharge depuis les prefs (ex. snapshot Firestore appliqué sur un autre appareil).
  Future<void> reloadFromStorage() async {
    if (isEditingChecklist) {
      _reloadDeferred = true;
      return;
    }
    await _applyReloadFromStorage();
  }

  Future<void> _applyReloadFromStorage() async {
    _reloadDeferred = false;
    final data = await ChecklistSectionsStorage.load();
    editingSectionId = null;
    sectionEditSnapshot = null;
    sectionEditInteraction = false;
    editingItemId = null;
    draftItemId = null;
    sectionTitleEditController.clear();
    itemLabelEditController.clear();
    if (data != null && data.isNotEmpty) {
      _sections = checklistEnsureProtectedSections(data);
    } else {
      // Même logique que l’init + [ChecklistFirestoreSync._pushFull] : prefs vides → défauts.
      _sections = defaultNouveauTradeSections()
          .map(
            (s) => ChecklistSectionData(
              id: s.id,
              title: s.title,
              enabled: s.enabled,
              items: s.items
                  .map(
                    (i) => ChecklistItemData(
                      id: i.id,
                      label: i.label,
                      checked: i.checked,
                      checkedAt: i.checkedAt,
                      schedule: i.schedule,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();
    }
    _refreshCompletionPeriods(silent: true);
    notifyListeners();
    _snapshotTodayCompletion();
  }

  @override
  void dispose() {
    _disposed = true;
    _saveDebounce?.cancel();
    if (_hydrated) {
      unawaited(_persistToDiskAndCloud());
    }
    itemLabelFocusNode.removeListener(_onItemLabelFocusChange);
    itemLabelEditController.dispose();
    itemLabelFocusNode.dispose();
    sectionTitleEditController.dispose();
    sectionTitleFocusNode.dispose();
    super.dispose();
  }

  void _pauseItemLabelBlurCommitForRebuild() {
    _itemLabelBlurCommitPause++;
    _postFrame(() {
      _postFrame(() {
        if (_itemLabelBlurCommitPause > 0) {
          _itemLabelBlurCommitPause--;
        }
      });
    });
  }

  void _requestItemLabelFocus() {
    _postFrame(() {
      if (_disposed || editingItemId == null) return;
      itemLabelFocusNode.requestFocus();
      if (!itemLabelFocusNode.hasFocus) {
        _postFrame(() {
          if (!_disposed && editingItemId != null) {
            itemLabelFocusNode.requestFocus();
          }
        });
      }
    });
  }

  void _onItemLabelFocusChange() {
    if (_disposed || _itemLabelBlurCommitPause > 0) return;
    // Mode Modifier section : validation uniquement sur Entrée ou action explicite.
    if (editingSectionId != null) return;
    if (!itemLabelFocusNode.hasFocus && editingItemId != null) {
      final isDraft = draftItemId == editingItemId;
      final empty = itemLabelEditController.text.trim().isEmpty;
      if (isDraft && empty) return;
      commitItemLabelEdit();
    }
  }

  void commitItemLabelEdit() {
    final id = editingItemId;
    if (id == null) return;
    final t = itemLabelEditController.text.trim();
    final isDraft = draftItemId == id;

    if (isDraft && t.isEmpty) {
      _sections = _sections.map((section) {
        if (!section.items.any((i) => i.id == id)) return section;
        final nextItems =
            section.items.where((i) => i.id != id).toList(growable: false);
        return section.copyWith(items: nextItems);
      }).toList();
      editingItemId = null;
      draftItemId = null;
      itemLabelEditController.clear();
      notifyListeners();
      _persistSoon();
      _flushDeferredReloadIfNeeded();
      return;
    }

    _sections = _sections.map((section) {
      final idx = section.items.indexWhere((i) => i.id == id);
      if (idx < 0) return section;
      final nextItems = [...section.items];
      nextItems[idx] = nextItems[idx].copyWith(label: t);
      return section.copyWith(items: nextItems);
    }).toList();
    editingItemId = null;
    if (isDraft) {
      draftItemId = null;
    }
    _notifyChecklistChanged();
    _persistSoon();
    _flushDeferredReloadIfNeeded();
  }

  void startEditItemLabel(String sectionId, String itemId) {
    if (editingItemId != null) {
      commitItemLabelEdit();
    }
    final section = _sections.firstWhere((s) => s.id == sectionId);
    final item = section.items.firstWhere((i) => i.id == itemId);
    editingItemId = itemId;
    if (editingSectionId == sectionId) {
      sectionEditInteraction = true;
    }
    itemLabelEditController.text = item.label;
    _pauseItemLabelBlurCommitForRebuild();
    notifyListeners();
    _requestItemLabelFocus();
  }

  ChecklistSectionData _copySection(ChecklistSectionData s) {
    return ChecklistSectionData(
      id: s.id,
      title: s.title,
      enabled: s.enabled,
      items: s.items
          .map(
            (i) => ChecklistItemData(
              id: i.id,
              label: i.label,
              checked: i.checked,
              checkedAt: i.checkedAt,
              schedule: i.schedule,
            ),
          )
          .toList(),
    );
  }

  void markSectionEditInteraction() {
    if (!sectionEditInteraction) {
      sectionEditInteraction = true;
      notifyListeners();
    }
  }

  void updateItemSchedule(
    String sectionId,
    String itemId,
    ChecklistItemSchedule schedule,
  ) {
    _sections = _sections.map((section) {
      if (section.id != sectionId) return section;
      final nextItems = section.items.map((item) {
        if (item.id != itemId) return item;
        return item.copyWith(schedule: schedule);
      }).toList();
      return section.copyWith(items: nextItems);
    }).toList();
    _notifyChecklistChanged();
    _persistSoon();
  }

  ChecklistItemSchedule scheduleForItem(String sectionId, String itemId) {
    final section = _sections.firstWhere((s) => s.id == sectionId);
    final item = section.items.firstWhere((i) => i.id == itemId);
    return item.schedule ?? const ChecklistItemSchedule();
  }

  void toggleItem(String sectionId, String itemId, bool value) {
    final section = _sections.where((s) => s.id == sectionId).toList();
    if (section.isEmpty || !checklistSectionIsActive(section.first)) return;
    final now = DateTime.now();
    _sections = _sections.map((section) {
      if (section.id != sectionId) return section;
      final nextItems = section.items.map((item) {
        if (item.id != itemId) return item;
        if (value && item.isExpiredMissed(now)) return item;
        if (!value) {
          return item.copyWith(checked: false, clearCheckedAt: true);
        }
        return item.copyWith(checked: true, checkedAt: now);
      }).toList();
      return section.copyWith(items: nextItems);
    }).toList();
    _notifyChecklistChanged();
    _persistSoon();
  }

  void setSectionEnabled(String sectionId, bool enabled) {
    if (!checklistSectionHasEnableToggle(sectionId)) return;
    _sections = _sections
        .map(
          (s) => s.id == sectionId ? s.copyWith(enabled: enabled) : s,
        )
        .toList();
    _notifyChecklistChanged();
    _persistSoon();
    notifyListeners();
  }

  void onSectionMenu(String sectionId, String action, BuildContext context) {
    if (action == ChecklistPrompts.menuActionEdit) {
      startSectionTitleEdit(sectionId);
    } else if (action == ChecklistPrompts.menuActionDelete) {
      if (checklistSectionIsProtected(sectionId)) return;
      confirmDeleteSection(sectionId, context);
    }
  }

  void startSectionTitleEdit(String sectionId) {
    if (editingItemId != null) {
      commitItemLabelEdit();
    }
    if (editingSectionId != null && editingSectionId != sectionId) {
      if (sectionEditInteraction) {
        commitSectionTitleEdit();
      } else {
        cancelSectionEdit();
      }
    }
    final section = _sections.firstWhere((s) => s.id == sectionId);
    sectionEditSnapshot = _copySection(section);
    sectionEditInteraction = false;
    sectionTitleEditController.text = section.title;
    editingSectionId = sectionId;
    notifyListeners();
    _postFrame(() => sectionTitleFocusNode.requestFocus());
  }

  void commitSectionTitleEdit() {
    if (editingItemId != null) {
      commitItemLabelEdit();
    }
    final id = editingSectionId;
    if (id == null) return;
    final t = sectionTitleEditController.text.trim();
    if (t.isEmpty) {
      cancelSectionEdit();
      return;
    }
    _sections = _sections.map((s) {
      if (s.id != id) return s;
      return s.copyWith(title: t.toUpperCase());
    }).toList();
    editingSectionId = null;
    sectionEditSnapshot = null;
    sectionEditInteraction = false;
    notifyListeners();
    _persistSoon();
    _flushDeferredReloadIfNeeded();
  }

  void cancelSectionEdit() {
    final id = editingSectionId;
    if (id == null) return;
    final snap = sectionEditSnapshot;
    if (snap != null) {
      _sections = _sections.map((s) {
        if (s.id != id) return s;
        return _copySection(snap);
      }).toList();
    }
    editingSectionId = null;
    sectionEditSnapshot = null;
    sectionEditInteraction = false;
    editingItemId = null;
    draftItemId = null;
    sectionTitleEditController.clear();
    itemLabelEditController.clear();
    notifyListeners();
    _persistSoon();
    _flushDeferredReloadIfNeeded();
  }

  bool isPointerOnEditingSectionCard(Offset globalPosition) {
    if (editingSectionId == null) return false;
    final ctx = sectionEditCardKey.currentContext;
    if (ctx == null) return false;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return false;
    final local = box.globalToLocal(globalPosition);
    return local.dx >= 0 &&
        local.dy >= 0 &&
        local.dx <= box.size.width &&
        local.dy <= box.size.height;
  }

  /// Tap vraiment hors de la carte en édition → valider ou annuler la section.
  void finishSectionEditFromOutsideTap() {
    if (editingSectionId == null) return;
    if (editingItemId != null) {
      commitItemLabelEdit();
    }
    if (sectionEditInteraction) {
      commitSectionTitleEdit();
    } else {
      cancelSectionEdit();
    }
  }

  void removeItemFromSection(String sectionId, String itemId) {
    for (final s in _sections) {
      if (s.id != sectionId) continue;
      for (final i in s.items) {
        if (i.id != itemId) continue;
        _freezeItemInPastSnapshots(
          sectionId: sectionId,
          sectionTitle: s.title,
          itemId: itemId,
          itemLabel: i.label,
        );
        break;
      }
      break;
    }
    _pauseItemLabelBlurCommitForRebuild();
    if (editingItemId == itemId) {
      editingItemId = null;
      itemLabelEditController.clear();
    }
    if (draftItemId == itemId) {
      draftItemId = null;
    }
    if (editingSectionId == sectionId) {
      sectionEditInteraction = true;
    }
    _sections = _sections.map((section) {
      if (section.id != sectionId) return section;
      final nextItems =
          section.items.where((i) => i.id != itemId).toList(growable: false);
      return section.copyWith(items: nextItems);
    }).toList();
    _notifyChecklistChanged();
    _persistSoon();
  }

  void addLineToSection(String sectionId) {
    if (editingSectionId == sectionId) {
      sectionEditInteraction = true;
    }
    if (editingItemId != null) {
      final isDraft = draftItemId == editingItemId;
      final empty = itemLabelEditController.text.trim().isEmpty;
      if (!(isDraft && empty)) {
        commitItemLabelEdit();
      }
    }
    final nid = '${sectionId}_${DateTime.now().millisecondsSinceEpoch}';
    _sections = _sections.map((section) {
      if (section.id != sectionId) return section;
      return section.copyWith(
        items: [
          ...section.items,
          ChecklistItemData(id: nid, label: ''),
        ],
      );
    }).toList();
    editingItemId = nid;
    draftItemId = nid;
    itemLabelEditController.text = '';
    _pauseItemLabelBlurCommitForRebuild();
    notifyListeners();
    _requestItemLabelFocus();
    _persistSoon();
  }

  Future<void> confirmDeleteSection(String sectionId, BuildContext context) async {
    if (checklistSectionIsProtected(sectionId)) return;
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => const ChecklistDeleteSectionDialog(),
    );
    if (ok == true && context.mounted) {
      for (final s in _sections) {
        if (s.id != sectionId) continue;
        for (final i in s.items) {
          _freezeItemInPastSnapshots(
            sectionId: sectionId,
            sectionTitle: s.title,
            itemId: i.id,
            itemLabel: i.label,
          );
        }
        break;
      }
      _sections = _sections.where((s) => s.id != sectionId).toList();
      _notifyChecklistChanged();
      _persistSoon();
    }
  }

  void addSection(String defaultNewSectionTitle) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final id = 'sect_$ts';
    _sections.add(
      ChecklistSectionData(
        id: id,
        title: defaultNewSectionTitle,
        items: [
          ChecklistItemData(id: '${id}_1', label: ''),
        ],
      ),
    );
    _notifyChecklistChanged();
    _persistSoon();
  }

  /// Retourne `false` si l’action s’arrête là (ex. annulation édition section).
  bool prepareBackNavigation() {
    if (editingSectionId != null) {
      cancelSectionEdit();
      return false;
    }
    if (editingItemId != null) {
      commitItemLabelEdit();
    }
    return true;
  }

}
