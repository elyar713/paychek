import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_shell_scope.dart';
import 'ajouter_trade_strategie_feedback_retroaction.dart';
import '../strategie/widgets/strategie_setup_cards_content.dart';
import '../shared/paychek_frame_callbacks.dart';

/// Menu déroulant (overlay) comme le choix de stratégie : rétroaction selon le % « Stratégie respectée ».
class AjouterTradeStrategieFeedbackMenu extends StatefulWidget {
  const AjouterTradeStrategieFeedbackMenu({
    super.key,
    required this.strategieRespectPercent,
    required this.strategieTitle,
    this.onNonRespectSelectionChanged,
  });

  final double strategieRespectPercent;
  final String strategieTitle;

  /// Identifiants stables des éléments cochés comme « non respectés » (multi-sélection).
  final ValueChanged<Set<String>>? onNonRespectSelectionChanged;

  @override
  State<AjouterTradeStrategieFeedbackMenu> createState() =>
      _AjouterTradeStrategieFeedbackMenuState();
}

class _AjouterTradeStrategieFeedbackMenuState
    extends State<AjouterTradeStrategieFeedbackMenu> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlay;

  /// Coche = élément **non** respecté (multi-choix).
  final Set<String> _nonRespectSelection = <String>{};

  void _clearNonRespectIfOffAddTradeTab() {
    final scope = AjouterTradeShellScope.maybeOf(context);
    if (scope == null || scope.shellTabIndex == 2) return;
    _closeOverlay();
    if (_nonRespectSelection.isEmpty) return;
    _nonRespectSelection.clear();
    PaychekFrameCallbacks.runPostFrame(() {
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
  void didUpdateWidget(AjouterTradeStrategieFeedbackMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    var cleared = false;
    if (oldWidget.strategieTitle != widget.strategieTitle) {
      _nonRespectSelection.clear();
      cleared = true;
    }
    final oldP = oldWidget.strategieRespectPercent.round().clamp(0, 100);
    final newP = widget.strategieRespectPercent.round().clamp(0, 100);
    if (oldP < 95 && newP >= 95) {
      _nonRespectSelection.clear();
      cleared = true;
    }
    if (cleared) {
      // Évite de déclencher un setState du parent pendant son build
      // (le parent écoute souvent ce callback via setState).
      PaychekFrameCallbacks.runPostFrame(() {
        if (!mounted) return;
        widget.onNonRespectSelectionChanged
            ?.call(Set<String>.from(_nonRespectSelection));
      });
      _overlay?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _closeOverlay();
    super.dispose();
  }

  void _closeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _toggleOverlay(BuildContext context) {
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
    final maxH = (showBelow ? spaceBelow : spaceAbove).clamp(160, 400).toDouble();
    final p = widget.strategieRespectPercent.round().clamp(0, 100);
    final data = strategieSetupCardDataPourTitre(widget.strategieTitle);

    final entry = OverlayEntry(
      builder: (overlayCtx) {
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
                      border: Border.all(
                        color: DashboardTokens.cardBoxBorder,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: AjouterTradeStrategieFeedbackRetroactionBody(
                          p: p,
                          data: data,
                          nonRespectSelection: _nonRespectSelection,
                          onToggleNonRespect: _toggleNonRespect,
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

  void _toggleNonRespect(String id) {
    if (_nonRespectSelection.contains(id)) {
      _nonRespectSelection.remove(id);
    } else {
      _nonRespectSelection.add(id);
    }
    _overlay?.markNeedsBuild();
    widget.onNonRespectSelectionChanged
        ?.call(Set<String>.from(_nonRespectSelection));
  }

  String _libelleFerme(int p, AppLocalizations l) {
    if (p >= 100) return l.ajouterTradeStrategieClosedLabel100;
    if (p >= 95) return l.ajouterTradeStrategieClosedLabel95;
    return l.ajouterTradeStrategieClosedLabelLow;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = widget.strategieRespectPercent.round().clamp(0, 100);

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
              border: Border.all(
                color: DashboardTokens.cardBoxBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _libelleFerme(p, l),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p >= 100
                          ? DashboardTokens.accent
                          : DashboardTokens.onMatteEmphasis,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 20,
                  color: p >= 100
                      ? DashboardTokens.accent.withValues(alpha: 0.85)
                      : DashboardTokens.labelGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
