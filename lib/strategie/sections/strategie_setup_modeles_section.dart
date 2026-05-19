import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../gestion_risque_edit_notifier.dart';
import '../strategie_setups_store.dart';
import '../strategie_starred_setup_storage.dart';
import '../strategie_firestore_sync.dart';
import '../strategie_realtime_notifier.dart';
import '../strategie_tokens.dart';
import '../widgets/strategie_section_frame.dart';
import '../widgets/strategie_setup_card.dart';
import '../widgets/strategie_setup_rule_styles.dart';
import 'strategie_setup_edit_dialog.dart';
import 'strategie_setup_modeles_section_menu.dart';

/// Setups & modèles — menu ⋮ **Ajouter** / **Modifier** (comme Horaires & sessions).
/// Le crayon d’édition reste disponible sans « Modifier » ; le menu active surtout la corbeille.
class StrategieSetupModelesSection extends StatefulWidget {
  const StrategieSetupModelesSection({
    super.key,
    required this.editNotifier,
    required this.visibleSetupIndex,
  });

  final GestionRisqueEditNotifier editNotifier;

  /// Synchronisé avec le calendrier d’usage (même setup sélectionné que la barre de noms).
  final ValueNotifier<int> visibleSetupIndex;

  @override
  State<StrategieSetupModelesSection> createState() =>
      _StrategieSetupModelesSectionState();
}

class _StrategieSetupModelesSectionState
    extends State<StrategieSetupModelesSection> {
  bool _editMode = false;
  final GlobalKey _menuKey = GlobalKey();
  /// Toute la zone « contenu » (barre de choix rapide + carte) : évite qu’un tap sur les
  /// pastilles de setup soit traité comme « extérieur » et ne ferme pas l’édition par erreur.
  final GlobalKey _sectionBodyKey = GlobalKey();
  late List<StrategieSetupCardData> _cards;
  final List<GlobalKey> _cardKeys = [];
  StrategieSetupCardData? _starredSetupSnapshot;

  /// Lazy : après hot reload, un `final ScrollController()` ajouté plus tard peut rester null sur le web.
  ScrollController? _quickPickScrollControllerImpl;

  ScrollController get _quickPickScrollController {
    _quickPickScrollControllerImpl ??= ScrollController();
    return _quickPickScrollControllerImpl!;
  }

  bool _isNewSetupPlaceholderTitle(String title) {
    final t = title.trim();
    for (final code in ['fr', 'en', 'es', 'de', 'pt', 'ko']) {
      if (t == lookupAppLocalizations(Locale(code)).strategieSetupNewTitle) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _cards = List<StrategieSetupCardData>.from(StrategieSetupsStore.notifier.value);
    _syncCardKeysLength();
    StrategieSetupsStore.ensureLoaded().then((_) {
      if (!mounted) return;
      setState(() {
        _cards = List<StrategieSetupCardData>.from(StrategieSetupsStore.notifier.value);
        _syncCardKeysLength();
      });
    });
    StrategieStarredSetupStorage.load().then((s) {
      if (!mounted) return;
      setState(() => _starredSetupSnapshot = s);
    });
    widget.visibleSetupIndex.addListener(_onVisibleSetupIndexChanged);
    StrategieRealtimeNotifier.tick.addListener(_onStrategieRemoteTick);
  }

  void _onStrategieRemoteTick() {
    if (!mounted || _editMode) return;
    setState(() {
      _cards = List<StrategieSetupCardData>.from(StrategieSetupsStore.notifier.value);
      _syncCardKeysLength();
      _ensureVisibleSetupIndex();
    });
    StrategieStarredSetupStorage.load().then((s) {
      if (!mounted) return;
      setState(() => _starredSetupSnapshot = s);
    });
  }

  void _onVisibleSetupIndexChanged() {
    if (mounted) setState(() {});
  }

  void _syncCardKeysLength() {
    while (_cardKeys.length < _cards.length) {
      _cardKeys.add(GlobalKey());
    }
    while (_cardKeys.length > _cards.length) {
      _cardKeys.removeLast();
    }
  }

  void _nudgeQuickPickScroll(double delta) {
    final c = _quickPickScrollController;
    if (!c.hasClients) return;
    final pos = c.position;
    final target = (c.offset + delta).clamp(0.0, pos.maxScrollExtent);
    c.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    StrategieRealtimeNotifier.tick.removeListener(_onStrategieRemoteTick);
    widget.visibleSetupIndex.removeListener(_onVisibleSetupIndexChanged);
    _quickPickScrollControllerImpl?.dispose();
    final n = widget.editNotifier;
    n.setupsEditing = false;
    n.setupsMenuKey = null;
    n.setupsExcludeKeys = [];
    n.onCommitSetupsOutside = null;
    n.onForceCloseSetupsEdit = null;
    super.dispose();
  }

  StrategieSetupCardData _blankSetup(AppLocalizations l) {
    return StrategieSetupCardData(
      title: l.strategieSetupNewTitle,
      dotColor: StrategieTokens.emerald,
      timeframes: '—',
      indicateurs: '—',
      pattern: '—',
      signalText: '—',
      signalColor: Colors.white,
      ruleBlocks: [
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.crosshair,
          heading: l.strategieRuleEntryPrecise,
          body: '—',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.shield,
          heading: l.strategieRuleInvalidation,
          body: '—',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.circleDot,
          heading: l.strategieRuleTarget,
          body: '—',
        ),
        StrategieSetupRuleStyles.block(
          icon: LucideIcons.lock,
          heading: l.strategieRuleManagement,
          body: '—',
        ),
      ],
    );
  }

  void _onMenuModify() {
    if (_editMode) {
      _cancelEdit();
    } else {
      _startEdit();
    }
  }

  void _startEdit() {
    widget.editNotifier.onForceCloseGestionRisqueEdit?.call();
    widget.editNotifier.onForceCloseHorairesEdit?.call();
    setState(() => _editMode = true);
  }

  void _commitEdit() {
    if (!_editMode || !mounted) return;
    setState(() => _editMode = false);
  }

  void _cancelEdit() {
    if (!_editMode || !mounted) return;
    setState(() => _editMode = false);
  }

  void _onMenuAdd() {
    widget.editNotifier.onForceCloseGestionRisqueEdit?.call();
    widget.editNotifier.onForceCloseHorairesEdit?.call();
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    if (!_editMode) {
      setState(() => _editMode = true);
    }
    setState(() {
      _cards.add(_blankSetup(l));
      _syncCardKeysLength();
    });
    widget.visibleSetupIndex.value = _cards.length - 1;
    unawaited(_persistSetupsAndPush());
  }

  Future<void> _persistSetupsAndPush() async {
    await StrategieSetupsStore.setAll(_cards);
    await StrategieFirestoreSync.pushIfSignedIn();
  }

  void _removeCardAt(int index) {
    final starred = StrategieStarredSetupStorage.matches(
      _starredSetupSnapshot,
      _cards[index],
    );
    setState(() {
      if (starred) _starredSetupSnapshot = null;
      _cards.removeAt(index);
      _cardKeys.removeAt(index);
    });
    final v = widget.visibleSetupIndex.value;
    if (_cards.isEmpty) {
      widget.visibleSetupIndex.value = 0;
    } else if (v >= _cards.length) {
      widget.visibleSetupIndex.value = _cards.length - 1;
    } else if (index < v) {
      widget.visibleSetupIndex.value = v - 1;
    }
    unawaited(() async {
      if (starred) await StrategieStarredSetupStorage.clear();
      await StrategieSetupsStore.setAll(_cards);
      await StrategieFirestoreSync.pushIfSignedIn();
    }());
  }

  bool _isStarredAt(int i) {
    return StrategieStarredSetupStorage.matches(
      _starredSetupSnapshot,
      _cards[i],
    );
  }

  Future<void> _toggleDashboardStarAt(int index) async {
    final d = _cards[index];
    if (_isStarredAt(index)) {
      await StrategieStarredSetupStorage.clear();
      if (!mounted) return;
      setState(() => _starredSetupSnapshot = null);
    } else {
      await StrategieStarredSetupStorage.save(d);
      if (!mounted) return;
      setState(() => _starredSetupSnapshot = d);
    }
    await StrategieFirestoreSync.pushIfSignedIn();
  }

  Future<void> _openSetupEditor(int index) async {
    final wasStarred = _isStarredAt(index);
    final r = await showStrategieSetupEditDialog(
      context,
      initial: _cards[index],
      isNew: _isNewSetupPlaceholderTitle(_cards[index].title),
    );
    if (!mounted || r == null) return;
    setState(() {
      _cards[index] = strategieSetupCardDataFromEditResult(r);
    });
    await StrategieSetupsStore.setAll(_cards);
    if (wasStarred) {
      await StrategieStarredSetupStorage.save(_cards[index]);
      if (!mounted) return;
      setState(() => _starredSetupSnapshot = _cards[index]);
    }
    await StrategieFirestoreSync.pushIfSignedIn();
  }

  void _syncSetupsNotifier() {
    final n = widget.editNotifier;
    n.setupsEditing = _editMode;
    n.setupsMenuKey = _menuKey;
    n.setupsExcludeKeys = [_sectionBodyKey, ..._cardKeys];
    n.onCommitSetupsOutside = _commitEdit;
    n.onForceCloseSetupsEdit = _cancelEdit;
  }

  void _ensureVisibleSetupIndex() {
    final n = widget.visibleSetupIndex;
    if (_cards.isEmpty) {
      n.value = 0;
      return;
    }
    if (n.value >= _cards.length) {
      n.value = _cards.length - 1;
    }
    if (n.value < 0) n.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    _syncCardKeysLength();
    _ensureVisibleSetupIndex();
    _syncSetupsNotifier();

    Widget cardsArea(BoxConstraints constraints) {
      final wide = constraints.maxWidth >= 520;
      final multi = _cards.length > 1;

      if (_cards.isEmpty) {
        return const SizedBox.shrink();
      }

      Widget oneCard(int i, {required bool maquette}) {
        return StrategieSetupCard(
          key: _cardKeys[i],
          title: _cards[i].title,
          dotColor: _cards[i].dotColor,
          timeframes: _cards[i].timeframes,
          indicateurs: _cards[i].indicateurs,
          pattern: _cards[i].pattern,
          signalText: _cards[i].signalText,
          signalColor: _cards[i].signalColor,
          ruleBlocks: _cards[i].ruleBlocks,
          maquetteStyle: maquette,
          isDashboardStarred: _isStarredAt(i),
          onToggleDashboardStar: () => _toggleDashboardStarAt(i),
          onEditTap: () => _openSetupEditor(i),
          onDeleteTap: _editMode ? () => _removeCardAt(i) : null,
        );
      }

      if (!multi) {
        return oneCard(0, maquette: wide);
      }

      final i = widget.visibleSetupIndex.value.clamp(0, _cards.length - 1);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          oneCard(i, maquette: wide),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: i > 0
                    ? () => widget.visibleSetupIndex.value = i - 1
                    : null,
                child: Text(
                  l.strategieSetupNavPrevious,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: StrategieTokens.labelMuted,
                  ),
                ),
              ),
              TextButton(
                onPressed: i < _cards.length - 1
                    ? () => widget.visibleSetupIndex.value = i + 1
                    : null,
                child: Text(
                  l.strategieSetupNavNext,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: StrategieTokens.emerald,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return StrategieSectionFrame(
          leadingIcon: LucideIcons.zap,
          title: l.strategieSectionSetupsAndModels,
          titleColor: StrategieTokens.titleGrey,
          trailingMenu: KeyedSubtree(
            key: _menuKey,
            child: buildStrategieSetupModelesPopupMenu(
              onAdd: _onMenuAdd,
              onModify: _onMenuModify,
            ),
          ),
          child: Column(
            key: _sectionBodyKey,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_cards.length > 1) ...[
                _SetupQuickPickBar(
                  cards: _cards,
                  selectedIndex: widget.visibleSetupIndex.value
                      .clamp(0, _cards.length - 1),
                  scrollController: _quickPickScrollController,
                  editMode: _editMode,
                  onScrollBack: () => _nudgeQuickPickScroll(-220),
                  onScrollForward: () => _nudgeQuickPickScroll(220),
                  onSelect: (index) =>
                      widget.visibleSetupIndex.value = index,
                  onEditAt: _openSetupEditor,
                  onDeleteAt: _editMode ? _removeCardAt : null,
                ),
                const SizedBox(height: 12),
              ],
              cardsArea(constraints),
            ],
          ),
        );
      },
    );
  }
}

/// Boutons horizontaux (nom de chaque setup) sous « SETUPS & TEMPLATES ».
class _SetupQuickPickBar extends StatelessWidget {
  // [ScrollController] n'est pas const — pas de constructeur const.
  // ignore: prefer_const_constructors_in_immutables
  _SetupQuickPickBar({
    required this.cards,
    required this.selectedIndex,
    required this.scrollController,
    required this.editMode,
    required this.onScrollBack,
    required this.onScrollForward,
    required this.onSelect,
    required this.onEditAt,
    this.onDeleteAt,
  });

  final List<StrategieSetupCardData> cards;
  final int selectedIndex;
  final ScrollController scrollController;
  final bool editMode;
  final VoidCallback onScrollBack;
  final VoidCallback onScrollForward;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onEditAt;
  final ValueChanged<int>? onDeleteAt;

  static const _arrowHit = BoxConstraints(minWidth: 40, minHeight: 40);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: _arrowHit,
          tooltip: MaterialLocalizations.of(context).previousPageTooltip,
          icon: Icon(
            LucideIcons.chevronLeft,
            size: 22,
            color: StrategieTokens.labelMuted,
          ),
          onPressed: onScrollBack,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _SetupQuickPickButton(
                    label: cards[i].title,
                    dotColor: cards[i].dotColor,
                    selected: i == selectedIndex,
                    onTap: () => onSelect(i),
                    onEditTap: () => onEditAt(i),
                    onDeleteTap:
                        editMode && onDeleteAt != null ? () => onDeleteAt!(i) : null,
                  ),
                ],
              ],
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: _arrowHit,
          tooltip: MaterialLocalizations.of(context).nextPageTooltip,
          icon: Icon(
            LucideIcons.chevronRight,
            size: 22,
            color: StrategieTokens.emerald,
          ),
          onPressed: onScrollForward,
        ),
      ],
    );
  }
}

class _SetupQuickPickButton extends StatelessWidget {
  const _SetupQuickPickButton({
    required this.label,
    required this.dotColor,
    required this.selected,
    required this.onTap,
    required this.onEditTap,
    this.onDeleteTap,
  });

  final String label;
  final Color dotColor;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StrategieTokens.radiusSm),
        child: SizedBox(
          width: onDeleteTap != null ? 248 : 228,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? StrategieTokens.emerald.withValues(alpha: 0.12)
                  : StrategieTokens.innerCardBg,
              borderRadius: BorderRadius.circular(StrategieTokens.radiusSm),
              border: Border.all(
                color: selected
                    ? StrategieTokens.emerald.withValues(alpha: 0.85)
                    : StrategieTokens.cardBorder.withValues(alpha: 0.55),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? StrategieTokens.emerald
                          : Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ),
                StrategieSetupEditIconButton(onPressed: onEditTap),
                if (onDeleteTap != null)
                  StrategieSetupDeleteIconButton(onPressed: onDeleteTap!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
