import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_shell_scope.dart';
import '../etat_mental/mental_state_controller.dart';

/// Une seule case "État du moment" (overlay) pour cocher les points non respectés,
/// en s'appuyant sur la liste des métriques de la page État mental.
class AjouterTradeEtatMomentFeedbackMenu extends StatefulWidget {
  const AjouterTradeEtatMomentFeedbackMenu({
    super.key,
    required this.etatMomentPercent,
    required this.controller,
    this.onNonRespectSelectionChanged,
  });

  final double etatMomentPercent;
  final MentalStateController controller;
  final ValueChanged<Set<String>>? onNonRespectSelectionChanged;

  @override
  State<AjouterTradeEtatMomentFeedbackMenu> createState() =>
      _AjouterTradeEtatMomentFeedbackMenuState();
}

sealed class _EtatEntry {
  const _EtatEntry();
}

final class _EtatHeader extends _EtatEntry {
  const _EtatHeader(this.title);
  final String title;
}

final class _EtatRow extends _EtatEntry {
  const _EtatRow({required this.id, required this.label, required this.value});
  final String id;
  final String label;
  final int value;
}

class _AjouterTradeEtatMomentFeedbackMenuState
    extends State<AjouterTradeEtatMomentFeedbackMenu> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlay;
  final ScrollController _scroll = ScrollController();

  /// Coche = élément non respecté.
  final Set<String> _nonRespectSelection = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AjouterTradeShellScope.maybeOf(context);
    if (scope != null && scope.shellTabIndex != 2) {
      _closeOverlay();
    }
  }

  @override
  void didUpdateWidget(covariant AjouterTradeEtatMomentFeedbackMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldP = oldWidget.etatMomentPercent.round().clamp(0, 100);
    final newP = widget.etatMomentPercent.round().clamp(0, 100);
    if (oldP != newP) {
      _overlay?.markNeedsBuild();
    }
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

  List<_EtatEntry> _entries(AppLocalizations l) {
    final out = <_EtatEntry>[];
    out.add(_EtatHeader(l.ajouterTradeEtatHeaderMoment));
    for (final m in widget.controller.moment) {
      out.add(
        _EtatRow(
          id: 'moment:${m.id}',
          label: m.label,
          value: m.value.round().clamp(0, 100),
        ),
      );
    }
    out.add(_EtatHeader(l.ajouterTradeEtatHeaderEmotions));
    for (final e in widget.controller.emotions) {
      out.add(
        _EtatRow(
          id: 'emotion:${e.id}',
          label: e.label,
          value: e.value.round().clamp(0, 100),
        ),
      );
    }
    return out;
  }

  void _toggleOverlay(BuildContext context) {
    if (_overlay != null) {
      _closeOverlay();
      return;
    }

    final l = AppLocalizations.of(context)!;

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
    final maxH = (showBelow ? spaceBelow : spaceAbove).clamp(160, 360).toDouble();

    final entry = OverlayEntry(
      builder: (_) {
        final p = widget.etatMomentPercent.round().clamp(0, 100);
        final showPrompt = p < 95;
        final entries = _entries(l);

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
                targetAnchor:
                    showBelow ? Alignment.bottomLeft : Alignment.topLeft,
                followerAnchor:
                    showBelow ? Alignment.topLeft : Alignment.bottomLeft,
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
                            if (p >= 100)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                                decoration: BoxDecoration(
                                  color: DashboardTokens.accent
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: DashboardTokens.accent
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  l.ajouterTradeEtatClosedLabel100,
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
                                l.ajouterTradeEtatFeedbackAlmost100,
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
                                  l.ajouterTradeEtatFeelingPrompt,
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
                                if (e is _EtatHeader) _header(e.title),
                                if (e is _EtatRow) _row(l, e),
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

  Widget _row(AppLocalizations l, _EtatRow it) {
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
                      const SizedBox(height: 2),
                      Text(
                        '${it.value}%',
                        style: const TextStyle(
                          color: DashboardTokens.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          height: 1.25,
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
    final p = widget.etatMomentPercent.round().clamp(0, 100);
    final label = p >= 100
        ? l.ajouterTradeEtatClosedLabel100
        : l.ajouterTradeEtatClosedLabelLow;
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

