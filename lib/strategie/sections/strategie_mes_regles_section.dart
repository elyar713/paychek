import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../checklist/widgets/checklist_delete_section_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../strategie_mes_regles_storage.dart';
import '../strategie_realtime_notifier.dart';
import '../strategie_tokens.dart';
import '../strategie_feedback_reference.dart';
import '../widgets/strategie_mes_regles_widgets.dart';
import '../widgets/strategie_section_frame.dart';

/// « Mes règles d'or » — état / annulation ; UI : [StrategieMesReglesPopupMenu] etc. dans `strategie_mes_regles_widgets.dart`.
class StrategieMesReglesSection extends StatefulWidget {
  const StrategieMesReglesSection({super.key});

  @override
  State<StrategieMesReglesSection> createState() =>
      _StrategieMesReglesSectionState();
}

class _StrategieMesReglesSectionState extends State<StrategieMesReglesSection> {
  late String _sectionTitle;
  late final TextEditingController _titleController;
  late final FocusNode _titleFocus;

  late List<TextEditingController> _ruleControllers;

  bool _menuEditMode = false;
  String? _snapTitle;
  List<String>? _snapRuleTexts;

  TextEditingController? _draftAdd;
  late final FocusNode _draftFocus;

  /// Dernière langue pour laquelle les textes des règles par défaut ont été alignés.
  String? _rulesSyncedLang;

  @override
  void initState() {
    super.initState();
    final bootLoc = WidgetsBinding.instance.platformDispatcher.locale;
    final initial = StrategieMesReglesStore.notifier.value;
    final rules = initial.isCustom
        ? initial.rules
        : StrategieFeedbackReference.mesReglesDor(bootLoc);
    final title = initial.isCustom
        ? initial.sectionTitle
        : lookupAppLocalizations(bootLoc)
            .ajouterTradeStrategieGoldRules
            .toUpperCase();
    _sectionTitle = title;
    _titleController = TextEditingController(text: title);
    _titleFocus = FocusNode();
    _ruleControllers = rules
        .map((t) => TextEditingController(text: t))
        .toList(growable: true);
    _rulesSyncedLang = null;
    _draftFocus = FocusNode()..addListener(_onDraftFocusChanged);
    unawaited(
      StrategieMesReglesStore.ensureLoaded().then((_) {
        if (!mounted) return;
        _hydrateFromPersisted(
          StrategieMesReglesStore.notifier.value,
          Localizations.localeOf(context),
        );
      }),
    );
    StrategieRealtimeNotifier.tick.addListener(_onStrategieRemoteTick);
  }

  void _onStrategieRemoteTick() {
    if (!mounted || _menuEditMode) return;
    _hydrateFromPersisted(
      StrategieMesReglesStore.notifier.value,
      Localizations.localeOf(context),
    );
  }

  void _hydrateFromPersisted(StrategieMesReglesPersisted data, Locale locale) {
    final rules = data.isCustom
        ? data.rules
        : StrategieFeedbackReference.mesReglesDor(locale);
    final title = data.isCustom
        ? data.sectionTitle
        : StrategieMesReglesStore.sectionTitleForLocale(locale);

    setState(() {
      _sectionTitle = title;
      _titleController.text = title;
      for (final c in _ruleControllers) {
        c.dispose();
      }
      _ruleControllers =
          rules.map((t) => TextEditingController(text: t)).toList(growable: true);
      _rulesSyncedLang = locale.languageCode;
    });
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _applyLocalizedGoldenRules(Locale appLocale) {
    if (StrategieMesReglesStore.notifier.value.isCustom) return;

    final lang = appLocale.languageCode;
    if (_rulesSyncedLang == lang) return;

    final prevLang = _rulesSyncedLang;
    final curTexts = _ruleControllers.map((c) => c.text).toList();
    final shouldReplace = prevLang == null ||
        _listEquals(
          curTexts,
          StrategieFeedbackReference.mesReglesDor(Locale(prevLang)),
        ) ||
        StrategieMesReglesStore.isStockGoldenRules(curTexts);

    if (shouldReplace) {
      final targetTitle = lookupAppLocalizations(appLocale)
          .ajouterTradeStrategieGoldRules
          .toUpperCase();
      setState(() {
        if (StrategieMesReglesStore.isStockGoldenTitle(_sectionTitle)) {
          _sectionTitle = targetTitle;
          _titleController.text = targetTitle;
        }
        for (final c in _ruleControllers) {
          c.dispose();
        }
        _ruleControllers = StrategieFeedbackReference.mesReglesDor(appLocale)
            .map((t) => TextEditingController(text: t))
            .toList(growable: true);
      });
    }
    _rulesSyncedLang = lang;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appLoc = Localizations.localeOf(context);
    if (!StrategieMesReglesStore.notifier.value.isCustom) {
      final target = AppLocalizations.of(context)!
          .ajouterTradeStrategieGoldRules
          .toUpperCase();
      if (StrategieMesReglesStore.isStockGoldenTitle(_sectionTitle) &&
          _sectionTitle != target) {
        setState(() {
          _sectionTitle = target;
          _titleController.text = target;
        });
      }
    }
    _applyLocalizedGoldenRules(appLoc);
  }

  Future<void> _persistCurrent() async {
    await StrategieMesReglesStore.persistIfCustomized(
      sectionTitle: _sectionTitle,
      rules: _ruleControllers.map((c) => c.text).toList(growable: false),
    );
  }

  /// Fusionne brouillon / mode édition sans [setState] (ex. [dispose]).
  void _finalizePendingEditsForDispose() {
    if (_draftAdd != null) {
      final t = _draftAdd!.text.trim();
      if (t.isNotEmpty) {
        _ruleControllers.add(_draftAdd!);
      } else {
        _draftAdd!.dispose();
      }
      _draftAdd = null;
    }
    if (!_menuEditMode) return;
    final title = _titleController.text.trim();
    if (title.isNotEmpty) {
      _sectionTitle = title.toUpperCase();
    }
    _menuEditMode = false;
    _snapTitle = null;
    _snapRuleTexts = null;
  }

  @override
  void dispose() {
    _finalizePendingEditsForDispose();
    unawaited(_persistCurrent());
    StrategieRealtimeNotifier.tick.removeListener(_onStrategieRemoteTick);
    _draftFocus.removeListener(_onDraftFocusChanged);
    _titleController.dispose();
    _titleFocus.dispose();
    _draftFocus.dispose();
    for (final c in _ruleControllers) {
      c.dispose();
    }
    _draftAdd?.dispose();
    super.dispose();
  }

  void _onDraftFocusChanged() {
    if (_draftAdd == null) return;
    if (_draftFocus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _draftAdd == null) return;
      if (_draftFocus.hasFocus) return;
      final t = _draftAdd!.text.trim();
      setState(() {
        if (t.isEmpty) {
          _draftAdd!.dispose();
          _draftAdd = null;
        } else {
          _ruleControllers.add(_draftAdd!);
          _draftAdd = null;
        }
      });
    });
  }

  void _discardDraftIfAny() {
    if (_draftAdd == null) return;
    _draftAdd!.dispose();
    _draftAdd = null;
  }

  void _startMenuEdit() {
    _discardDraftIfAny();
    setState(() {
      _snapTitle = _sectionTitle;
      _snapRuleTexts =
          _ruleControllers.map((c) => c.text).toList(growable: false);
      _menuEditMode = true;
      _titleController.text = _sectionTitle;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _titleFocus.requestFocus();
      }
    });
  }

  void _cancelMenuEdit() {
    if (!_menuEditMode) return;
    final st = _snapTitle;
    final sr = _snapRuleTexts;
    if (st != null && sr != null) {
      setState(() {
        _sectionTitle = st;
        _titleController.text = st;
        for (final c in _ruleControllers) {
          c.dispose();
        }
        _ruleControllers =
            sr.map((t) => TextEditingController(text: t)).toList();
        _menuEditMode = false;
        _snapTitle = null;
        _snapRuleTexts = null;
      });
    } else {
      setState(() => _menuEditMode = false);
    }
    _discardDraftIfAny();
  }

  void _commitMenuEdit() {
    if (!_menuEditMode) return;
    _commitTitleFromField();
    if (_draftAdd != null) {
      final t = _draftAdd!.text.trim();
      if (t.isNotEmpty) {
        _ruleControllers.add(_draftAdd!);
      } else {
        _draftAdd!.dispose();
      }
      _draftAdd = null;
    }
    setState(() {
      _menuEditMode = false;
      _snapTitle = null;
      _snapRuleTexts = null;
    });
    unawaited(_persistCurrent());
  }

  void _commitTitleFromField() {
    final t = _titleController.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _sectionTitle = t.toUpperCase();
      _titleController.text = _sectionTitle;
    });
  }

  Future<void> _confirmDeleteSection(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => const ChecklistDeleteSectionDialog(),
    );
    if (ok != true || !mounted) return;
    setState(() {
      for (final c in _ruleControllers) {
        c.dispose();
      }
      _ruleControllers = [];
      _menuEditMode = false;
      _snapTitle = null;
      _snapRuleTexts = null;
    });
    _discardDraftIfAny();
    unawaited(_persistCurrent());
  }

  void _addRuleDraft() {
    if (_draftAdd != null) return;
    setState(() {
      _draftAdd = TextEditingController();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _draftFocus.requestFocus();
      }
    });
  }

  void _removeRuleAt(int index) {
    setState(() {
      _ruleControllers[index].dispose();
      _ruleControllers.removeAt(index);
      if (_menuEditMode && _snapRuleTexts != null) {
        _snapRuleTexts =
            _ruleControllers.map((c) => c.text).toList(growable: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) {
        if (_menuEditMode) {
          _commitMenuEdit();
        }
      },
      child: StrategieSectionFrame(
        backgroundColor: StrategieTokens.mesReglesSectionCardBg,
        leadingIcon: LucideIcons.bookmark,
        title: _sectionTitle,
        titleColor: StrategieTokens.titleGrey,
        titleEditing: _menuEditMode,
        titleEditController: _titleController,
        titleFocusNode: _titleFocus,
        onTitleSubmitted: _commitTitleFromField,
        trailingMenu: StrategieMesReglesPopupMenu(
          onEdit: () {
            if (_menuEditMode) {
              _cancelMenuEdit();
            } else {
              _startMenuEdit();
            }
          },
          onAdd: _addRuleDraft,
          onDelete: () => _confirmDeleteSection(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _ruleControllers.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _menuEditMode
                  ? StrategieMesReglesEditableRuleLine(
                      index: i + 1,
                      controller: _ruleControllers[i],
                      onDelete: () => _removeRuleAt(i),
                    )
                  : StrategieMesReglesRuleLine(
                      index: i + 1,
                      text: _ruleControllers[i].text,
                      onTap: _startMenuEdit,
                    ),
            ],
            if (_draftAdd != null) ...[
              const SizedBox(height: 16),
              StrategieMesReglesDraftRuleLine(
                index: _ruleControllers.length + 1,
                controller: _draftAdd!,
                focusNode: _draftFocus,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
