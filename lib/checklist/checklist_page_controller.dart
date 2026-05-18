import 'dart:async' show Timer, unawaited;

import 'package:flutter/material.dart';

import 'checklist_daily_completion_storage.dart';
import 'checklist_daily_day_snapshot.dart';
import 'checklist_firestore_sync.dart';
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
                items: s.items
                    .map(
                      (i) => ChecklistItemData(
                        id: i.id,
                        label: i.label,
                        checked: i.checked,
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

  /// Charge l’état persisté ; à appeler une fois au démarrage (ex. [DashboardPage]).
  Future<void> hydrateFromStorage() async {
    final data = await ChecklistSectionsStorage.load();
    if (data != null && data.isNotEmpty) {
      _sections = data;
      notifyListeners();
    }
    _snapshotsByDay = await ChecklistDailyCompletionStorage.load();
    _hydrated = true;
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

  int get totalItems =>
      _sections.fold<int>(0, (n, s) => n + s.items.length);

  int get checkedItems => _sections.fold<int>(
        0,
        (n, s) => n + s.items.where((i) => i.checked).length,
      );

  /// Lignes dont le rappel tombe sur [day] (défaut : aujourd’hui).
  int itemsDueOnDayCount([DateTime? day]) {
    var n = 0;
    for (final s in _sections) {
      for (final i in s.items) {
        if (i.isDueOnDay(day)) n++;
      }
    }
    return n;
  }

  int itemsDueOnDayCheckedCount([DateTime? day]) {
    var n = 0;
    for (final s in _sections) {
      for (final i in s.items) {
        if (i.isDueOnDay(day) && i.checked) n++;
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

  List<String> _uncheckedItemIdsForDay(DateTime day) {
    final ids = <String>[];
    for (final s in _sections) {
      for (final i in s.items) {
        if (i.isDueOnDay(day) && !i.checked) ids.add(i.id);
      }
    }
    return ids;
  }

  List<ChecklistUncheckedDayEntry> uncheckedEntriesForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (d.isAfter(today)) return const [];

    final ids = d == today
        ? _uncheckedItemIdsForDay(d)
        : _snapshotsByDay[ChecklistDailyCompletionStorage.dayKey(d)]
                ?.uncheckedItemIds ??
            const [];

    if (ids.isEmpty) return const [];

    final idSet = ids.toSet();
    final out = <ChecklistUncheckedDayEntry>[];
    for (final s in _sections) {
      for (final i in s.items) {
        if (!idSet.contains(i.id)) continue;
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
    return out;
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

    final stored = _snapshotsByDay[ChecklistDailyCompletionStorage.dayKey(d)];
    if (stored != null) return stored.percent;
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
    final uncheckedIds = _uncheckedItemIdsForDay(now);
    if (checked == 0) {
      if (due > 0) {
        final next = ChecklistDailyDaySnapshot(
          percent: 0,
          uncheckedItemIds: uncheckedIds,
        );
        final prev = _snapshotsByDay[k];
        if (prev != null &&
            prev.percent == 0 &&
            _listEquals(prev.uncheckedItemIds, uncheckedIds)) {
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
      uncheckedItemIds: uncheckedIds,
    );
    final prev = _snapshotsByDay[k];
    if (prev != null &&
        prev.percent == next.percent &&
        _listEquals(prev.uncheckedItemIds, next.uncheckedItemIds)) {
      return;
    }
    _snapshotsByDay[k] = next;
    unawaited(ChecklistDailyCompletionStorage.save(_snapshotsByDay));
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _notifyChecklistChanged() {
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
      _sections = data;
    } else {
      // Même logique que l’init + [ChecklistFirestoreSync._pushFull] : prefs vides → défauts.
      _sections = defaultNouveauTradeSections()
          .map(
            (s) => ChecklistSectionData(
              id: s.id,
              title: s.title,
              items: s.items
                  .map(
                    (i) => ChecklistItemData(
                      id: i.id,
                      label: i.label,
                      checked: i.checked,
                      schedule: i.schedule,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();
    }
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
      items: s.items
          .map(
            (i) => ChecklistItemData(
              id: i.id,
              label: i.label,
              checked: i.checked,
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
    _sections = _sections.map((section) {
      if (section.id != sectionId) return section;
      final nextItems = section.items.map((item) {
        if (item.id != itemId) return item;
        return item.copyWith(checked: value);
      }).toList();
      return section.copyWith(items: nextItems);
    }).toList();
    _notifyChecklistChanged();
    _persistSoon();
  }

  void onSectionMenu(String sectionId, String action, BuildContext context) {
    if (action == ChecklistPrompts.menuActionEdit) {
      startSectionTitleEdit(sectionId);
    } else if (action == ChecklistPrompts.menuActionDelete) {
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
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => const ChecklistDeleteSectionDialog(),
    );
    if (ok == true && context.mounted) {
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
