import 'package:flutter/material.dart';

import '../analyse/analyse_report_snapshot.dart';
import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_plan_analyse_feedback_items.dart';
import 'ajouter_trade_shell_scope.dart';

/// Menu déroulant (overlay) style STRATÉGIE — liste les éléments du rapport d’analyse
/// et permet de cocher ce qui n’a pas été respecté (multi-choix).
class AjouterTradePlanAnalyseFeedbackMenu extends StatefulWidget {
  const AjouterTradePlanAnalyseFeedbackMenu({
    super.key,
    required this.planRespectPercent,
    required this.selectedReport,
    this.onNonRespectSelectionChanged,
  });

  final double planRespectPercent;
  final AnalyseReportSnapshot? selectedReport;
  final ValueChanged<Set<String>>? onNonRespectSelectionChanged;

  @override
  State<AjouterTradePlanAnalyseFeedbackMenu> createState() =>
      _AjouterTradePlanAnalyseFeedbackMenuState();
}

class _AjouterTradePlanAnalyseFeedbackMenuState
    extends State<AjouterTradePlanAnalyseFeedbackMenu> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlay;
  final ScrollController _scroll = ScrollController();

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
  void didUpdateWidget(covariant AjouterTradePlanAnalyseFeedbackMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    var cleared = false;
    final old = oldWidget.selectedReport;
    final cur = widget.selectedReport;
    final changed = (old?.actif != cur?.actif) || (old?.sousTitre != cur?.sousTitre);
    if (changed) {
      _nonRespectSelection.clear();
      cleared = true;
    }
    final oldP = oldWidget.planRespectPercent.round().clamp(0, 100);
    final newP = widget.planRespectPercent.round().clamp(0, 100);
    if (oldP < 95 && newP >= 95) {
      _nonRespectSelection.clear();
      cleared = true;
    }
    if (cleared) {
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
        final p = widget.planRespectPercent.round().clamp(0, 100);
        final report = widget.selectedReport;
        final items = report == null
            ? const <PlanAnalyseFeedbackEntry>[]
            : planAnalyseFeedbackEntriesFor(report, l);
        final showPrompt = p < 95;
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
                            if (report == null)
                              Text(
                                l.ajouterTradePlanPickReportAbove,
                                style: const TextStyle(
                                  color: DashboardTokens.muted,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              )
                            else if (p >= 100) ...[
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
                                  l.ajouterTradePlanFeedbackBravo,
                                  style: const TextStyle(
                                    color: DashboardTokens.accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ] else if (p >= 95) ...[
                              Text(
                                l.ajouterTradePlanFeedbackAlmost100,
                                style: const TextStyle(
                                  color: DashboardTokens.muted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ] else ...[
                              Text(
                                '${report.actif} — ${report.sousTitre}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: DashboardTokens.onMatteEmphasis,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (showPrompt) ...[
                                Text(
                                  l.ajouterTradePlanFeedbackWhichMissed,
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
                              ...items.asMap().entries.map((e) {
                                final i = e.key;
                                final it = e.value;
                                return switch (it) {
                                  PlanAnalyseFeedbackSectionHeader(:final title) =>
                                    _sectionHeader(title, isFirst: i == 0),
                                  PlanAnalyseFeedbackRow row => _checkRow(l, row),
                                };
                              }),
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

  Widget _sectionHeader(String title, {required bool isFirst}) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 10, bottom: 6),
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

  Widget _checkRow(AppLocalizations l, PlanAnalyseFeedbackRow it) {
    final on = _nonRespectSelection.contains(it.id);
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
                    checked: on,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: on
                                ? DashboardTokens.negative
                                    .withValues(alpha: 0.95)
                                : DashboardTokens.cardBoxBorder,
                            width: 1.5,
                          ),
                          color: on
                              ? DashboardTokens.negative
                                  .withValues(alpha: 0.2)
                              : Colors.transparent,
                        ),
                        child: on
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
                          color: on
                              ? DashboardTokens.negative
                                  .withValues(alpha: 0.92)
                              : DashboardTokens.onMatteEmphasis,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      if (it.hint != null && it.hint!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          it.hint!,
                          style: const TextStyle(
                            color: DashboardTokens.muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            height: 1.25,
                          ),
                        ),
                      ],
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
    final report = widget.selectedReport;
    final p = widget.planRespectPercent.round().clamp(0, 100);
    final label = report == null
        ? '—'
        : (p >= 100
            ? l.ajouterTradePlanClosedLabel100
            : l.ajouterTradePlanClosedLabelLow);
    final labelColor =
        (report != null && p >= 100) ? DashboardTokens.accent : DashboardTokens.onMatteEmphasis;
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
