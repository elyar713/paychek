import 'package:flutter/material.dart';

import '../checklist/checklist_page_controller.dart';
import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_shell_scope.dart';

/// Une seule case "Checklist" (style dropdown overlay), pour cocher les éléments
/// non respectés (multi-choix) à partir de la page Checklist.
class AjouterTradeChecklistFeedbackMenu extends StatefulWidget {
  const AjouterTradeChecklistFeedbackMenu({
    super.key,
    required this.checklistRespectPercent,
    required this.controller,
    this.onNonRespectSelectionChanged,
  });

  final double checklistRespectPercent;
  final ChecklistPageController controller;
  final ValueChanged<Set<String>>? onNonRespectSelectionChanged;

  @override
  State<AjouterTradeChecklistFeedbackMenu> createState() =>
      _AjouterTradeChecklistFeedbackMenuState();
}

sealed class _ChecklistEntry {
  const _ChecklistEntry();
}

final class _ChecklistHeader extends _ChecklistEntry {
  const _ChecklistHeader(this.title);
  final String title;
}

final class _ChecklistRow extends _ChecklistEntry {
  const _ChecklistRow({required this.id, required this.label, required this.respected});
  final String id;
  final String label;
  final bool respected;
}

class _AjouterTradeChecklistFeedbackMenuState
    extends State<AjouterTradeChecklistFeedbackMenu> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlay;
  final ScrollController _scroll = ScrollController();

  /// Coche = élément non respecté.
  final Set<String> _nonRespectSelection = <String>{};

  void _clearNonRespectIfOffAddTradeTab() {
    final scope = AjouterTradeShellScope.maybeOf(context);
    if (scope == null || scope.shellTabIndex == 2) return;
    _closeOverlay();
    if (_nonRespectSelection.isEmpty) return;
    _nonRespectSelection.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onNonRespectSelectionChanged
          ?.call(Set<String>.from(_nonRespectSelection));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clearNonRespectIfOffAddTradeTab();
  }

  @override
  void didUpdateWidget(covariant AjouterTradeChecklistFeedbackMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldP = oldWidget.checklistRespectPercent.round().clamp(0, 100);
    final newP = widget.checklistRespectPercent.round().clamp(0, 100);
    if (oldP < 95 && newP >= 95) {
      _nonRespectSelection.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onNonRespectSelectionChanged
            ?.call(Set<String>.from(_nonRespectSelection));
      });
      _overlay?.markNeedsBuild();
    }
  }

  void _closeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  List<_ChecklistEntry> _entries() {
    final out = <_ChecklistEntry>[];
    for (final s in widget.controller.sections) {
      out.add(_ChecklistHeader(s.title));
      for (final it in s.items) {
        out.add(
          _ChecklistRow(
            id: '${s.id}:${it.id}',
            label: it.label,
            respected: it.checked,
          ),
        );
      }
    }
    return out;
  }

  void _toggleOverlay(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_overlay != null) {
      _closeOverlay();
      return;
    }

    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final w = box.size.width;
    final topLeft = box.localToGlobal(Offset.zero);
    final fieldTop = topLeft.dy;
    final fieldBottom = topLeft.dy + box.size.height;
    final media = MediaQuery.of(context);
    final safeTop = media.padding.top + 8;
    final safeBottom = media.size.height - media.padding.bottom - 8;
    final spaceBelow = (safeBottom - fieldBottom - 5).clamp(0, 9999).toDouble();
    final spaceAbove = (fieldTop - safeTop - 5).clamp(0, 9999).toDouble();
    final showBelow = spaceBelow >= 180 || spaceBelow >= spaceAbove;
    final maxH = (showBelow ? spaceBelow : spaceAbove).clamp(160, 380).toDouble();

    final entry = OverlayEntry(
      builder: (_) {
        final p = widget.checklistRespectPercent.round().clamp(0, 100);
        final showPrompt = p < 95;
        final entries = _entries();
        return SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeOverlay,
                  behavior: HitTestBehavior.opaque,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                ),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: showBelow ? Alignment.bottomLeft : Alignment.topLeft,
                followerAnchor: showBelow ? Alignment.topLeft : Alignment.bottomLeft,
                offset: showBelow ? const Offset(0, 5) : const Offset(0, -5),
                child: Material(
                  color: Colors.transparent,
                  elevation: 10,
                  shadowColor: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: w,
                    constraints: BoxConstraints(maxHeight: maxH),
                    decoration: BoxDecoration(
                      color: DashboardTokens.cardBoxBg.withValues(alpha: 0.98),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: DashboardTokens.cardBoxBorder),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Scrollbar(
                        controller: _scroll,
                        thumbVisibility: true,
                        child: ListView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          children: [
                            if (entries.isEmpty)
                              const Text(
                                '—',
                                style: TextStyle(
                                  color: DashboardTokens.muted,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              )
                            else if (p >= 100)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                                decoration: BoxDecoration(
                                  color:
                                      DashboardTokens.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: DashboardTokens.accent
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  l.ajouterTradeChecklistFeedbackBravo,
                                  style: const TextStyle(
                                    color: DashboardTokens.accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              )
                            else if (p >= 95)
                              Text(
                                l.ajouterTradeChecklistFeedbackAlmost100,
                                style: const TextStyle(
                                  color: DashboardTokens.muted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              )
                            else ...[
                              if (showPrompt) ...[
                                Text(
                                  l.ajouterTradeChecklistFeedbackWhichMissed,
                                  style: TextStyle(
                                    color: DashboardTokens.negative
                                        .withValues(alpha: 0.92),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l.ajouterTradeFeedbackTickEach,
                                  style: const TextStyle(
                                    color: DashboardTokens.muted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              for (final e in entries) ...[
                                if (e is _ChecklistHeader) _header(e.title),
                                if (e is _ChecklistRow) _row(l, e),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    _overlay = entry;
    Overlay.of(context).insert(entry);
  }

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          color: DashboardTokens.onMatteEmphasis.withValues(alpha: 0.72),
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _row(AppLocalizations l, _ChecklistRow it) {
    final nonRespecte = _nonRespectSelection.contains(it.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleId(it.id),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 4, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1, right: 8),
                  child: Semantics(
                    label: l.ajouterTradeNonRespectedSemantic(it.label),
                    checked: nonRespecte,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: nonRespecte
                                ? DashboardTokens.negative
                                    .withValues(alpha: 0.95)
                                : DashboardTokens.cardBoxBorder,
                            width: 1.5,
                          ),
                          color: nonRespecte
                              ? DashboardTokens.negative
                                  .withValues(alpha: 0.2)
                              : Colors.transparent,
                        ),
                        child: nonRespecte
                            ? const Icon(
                                Icons.close,
                                size: 11,
                                color: DashboardTokens.negative,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it.label,
                        style: TextStyle(
                          color: nonRespecte
                              ? DashboardTokens.negative
                                  .withValues(alpha: 0.92)
                              : DashboardTokens.onMatteEmphasis,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleId(String id) {
    setState(() {
      if (_nonRespectSelection.contains(id)) {
        _nonRespectSelection.remove(id);
      } else {
        _nonRespectSelection.add(id);
      }
    });
    widget.onNonRespectSelectionChanged?.call(Set<String>.from(_nonRespectSelection));
    _overlay?.markNeedsBuild();
  }

  @override
  void dispose() {
    _closeOverlay();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = widget.checklistRespectPercent.round().clamp(0, 100);
    final label = p >= 100
        ? l.ajouterTradeChecklistClosedLabel100
        : l.ajouterTradeChecklistClosedLabelLow;
    final labelColor =
        p >= 100 ? DashboardTokens.accent : DashboardTokens.onMatteEmphasis;
    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleOverlay(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            key: _fieldKey,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: DashboardTokens.scaffoldMatte,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DashboardTokens.cardBoxBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: labelColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.expand_more,
                  size: 20,
                  color: DashboardTokens.labelGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

