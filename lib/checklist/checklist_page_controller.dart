import 'dart:async' show Timer, unawaited;

import 'package:flutter/material.dart';

import 'checklist_firestore_sync.dart';
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

  /// Charge l’état persisté ; à appeler une fois au démarrage (ex. [DashboardPage]).
  Future<void> hydrateFromStorage() async {
    final data = await ChecklistSectionsStorage.load();
    if (data != null && data.isNotEmpty) {
      _sections = data;
      notifyListeners();
    }
    _hydrated = true;
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

  List<ChecklistSectionData> get sections => _sections;

  int get totalItems =>
      _sections.fold<int>(0, (n, s) => n + s.items.length);

  int get checkedItems => _sections.fold<int>(
        0,
        (n, s) => n + s.items.where((i) => i.checked).length,
      );

  int get checklistCompletionPercent {
    if (totalItems == 0) return 0;
    return ((100 * checkedItems) / totalItems).round();
  }

  /// Recharge depuis les prefs (ex. snapshot Firestore appliqué sur un autre appareil).
  Future<void> reloadFromStorage() async {
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
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();
    }
    notifyListeners();
  }

  @override
  void dispose() {
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

  void _onItemLabelFocusChange() {
    if (!itemLabelFocusNode.hasFocus && editingItemId != null) {
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
    notifyListeners();
    _persistSoon();
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
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemLabelFocusNode.requestFocus();
    });
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

  void toggleItem(String sectionId, String itemId, bool value) {
    _sections = _sections.map((section) {
      if (section.id != sectionId) return section;
      final nextItems = section.items.map((item) {
        if (item.id != itemId) return item;
        return item.copyWith(checked: value);
      }).toList();
      return section.copyWith(items: nextItems);
    }).toList();
    notifyListeners();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sectionTitleFocusNode.requestFocus();
    });
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
  }

  void onEditTapOutsideSection() {
    if (editingSectionId == null) return;
    if (editingItemId != null) {
      commitItemLabelEdit();
    }
    if (!sectionEditInteraction) {
      cancelSectionEdit();
    } else {
      commitSectionTitleEdit();
    }
  }

  void removeItemFromSection(String sectionId, String itemId) {
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
    notifyListeners();
    _persistSoon();
  }

  void addLineToSection(String sectionId) {
    if (editingItemId != null) {
      commitItemLabelEdit();
    }
    final nid = '${sectionId}_${DateTime.now().millisecondsSinceEpoch}';
    if (editingSectionId == sectionId) {
      sectionEditInteraction = true;
    }
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
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemLabelFocusNode.requestFocus();
    });
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
      notifyListeners();
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
    notifyListeners();
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
