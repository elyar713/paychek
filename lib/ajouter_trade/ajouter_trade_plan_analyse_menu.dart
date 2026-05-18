import 'package:flutter/material.dart';

import '../analyse/analyse_controller.dart';
import '../analyse/analyse_default_demo_seed.dart';
import '../analyse/analyse_report_snapshot.dart';
import '../analyse/analyse_reports_storage.dart';
import '../analyse/analyse_tokens.dart';
import '../dashboard/dashboard_tokens.dart';
import 'ajouter_trade_shell_scope.dart';

/// Rapports démo (GOLD, EUR/USD) — défaut brouillon Ajouter trade si le stockage est vide.
List<AnalyseReportSnapshot> ajouterTradePlanAnalyseDemoSnapshotsSync(
  Locale locale,
) {
  final c = AnalyseController();
  applyAnalyseDefaultGoldBreakoutDemo(c, locale: locale);
  final gold = AnalyseReportSnapshot.fromController(c, locale: locale);
  applyAnalyseDefaultEuroUsdWeeklySwingDemo(c, locale: locale);
  final eur = AnalyseReportSnapshot.fromController(c, locale: locale);
  c.dispose();
  return [gold, eur];
}

/// Bloc "Plan d'analyse" — copie visuelle du dropdown Stratégie.
///
/// - Si [showDemoReports] = true : liste et affiche les rapports démo (GOLD, EUR/USD)
///   comme la page "Mon Analyse".
/// - Sinon : vide (`—`).
class AjouterTradePlanAnalyseMenu extends StatefulWidget {
  const AjouterTradePlanAnalyseMenu({
    super.key,
    this.showDemoReports = false,
    this.selectedSnapshot,
    this.onSelectedSnapshotChanged,
    this.onReportsLoaded,
  });

  final bool showDemoReports;
  final AnalyseReportSnapshot? selectedSnapshot;
  final ValueChanged<AnalyseReportSnapshot?>? onSelectedSnapshotChanged;

  /// Liste disque + rapport courant (confiance à jour pour le parent).
  final void Function(
    List<AnalyseReportSnapshot> reports,
    AnalyseReportSnapshot? current,
  )? onReportsLoaded;

  @override
  State<AjouterTradePlanAnalyseMenu> createState() =>
      _AjouterTradePlanAnalyseMenuState();
}

class _AjouterTradePlanAnalyseMenuState extends State<AjouterTradePlanAnalyseMenu> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlay;

  List<AnalyseReportSnapshot> _reports = const [];
  int _selectedIdx = 0;
  bool _didLoadReports = false;
  String? _reportsLocaleTag;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.showDemoReports) {
      final locale = Localizations.localeOf(context);
      final tag = locale.toString();
      if (!_didLoadReports || _reportsLocaleTag != tag) {
        _didLoadReports = true;
        _reportsLocaleTag = tag;
        _reloadReports(locale);
      }
    }
    final scope = AjouterTradeShellScope.maybeOf(context);
    if (scope != null && scope.shellTabIndex != 2) {
      _closeOverlay();
    }
  }

  @override
  void didUpdateWidget(covariant AjouterTradePlanAnalyseMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.showDemoReports && widget.showDemoReports) {
      final locale = Localizations.localeOf(context);
      _didLoadReports = true;
      _reportsLocaleTag = locale.toString();
      _reloadReports(locale);
    }
    final sel = widget.selectedSnapshot;
    if (sel == null || _reports.isEmpty) return;
    final idx = _reports.indexWhere(
      (r) => r.actif == sel.actif && r.sousTitre == sel.sousTitre,
    );
    if (idx >= 0 && idx != _selectedIdx) {
      _selectedIdx = idx;
    }
  }

  Future<void> _reloadReports(Locale locale) async {
    if (!widget.showDemoReports) return;
    final stored = await AnalyseReportsStorage.loadAll();
    final next = stored.isNotEmpty
        ? stored
        : ajouterTradePlanAnalyseDemoSnapshotsSync(locale);
    if (!mounted) return;
    setState(() {
      _reports = next;
      _selectedIdx = _selectedIdx.clamp(0, (_reports.length - 1).clamp(0, 999));
    });
    _notifyReportsLoaded();
  }

  void _notifyReportsLoaded() {
    widget.onReportsLoaded?.call(_reports, _currentSnapshot);
  }

  AnalyseReportSnapshot? get _currentSnapshot {
    final sel = widget.selectedSnapshot;
    if (sel != null) return sel;
    if (!widget.showDemoReports || _reports.isEmpty) return null;
    return _reports[_selectedIdx.clamp(0, _reports.length - 1)];
  }

  String get _fieldLabel {
    if (!widget.showDemoReports) return '—';
    return _currentSnapshot?.actif ?? '—';
  }

  void _closeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  Future<void> _toggleOverlay(BuildContext context) async {
    if (_overlay != null) {
      _closeOverlay();
      return;
    }
    await _reloadReports(Localizations.localeOf(context));
    if (!context.mounted) return;
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
    final showBelow = spaceBelow >= 160 || spaceBelow >= spaceAbove;
    final maxH = (showBelow ? spaceBelow : spaceAbove).clamp(140, 260).toDouble();

    final entry = OverlayEntry(
      builder: (_) {
        final hasReports = widget.showDemoReports && _reports.isNotEmpty;

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
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!hasReports)
                              const Text(
                                '—',
                                style: TextStyle(
                                  color: DashboardTokens.muted,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              )
                            else ...[
                              for (var i = 0; i < _reports.length; i++)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      final snap = _reports[i];
                                      setState(() => _selectedIdx = i);
                                      widget.onSelectedSnapshotChanged
                                          ?.call(snap);
                                      _overlay?.markNeedsBuild();
                                      _closeOverlay();
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Text(
                                                  _reports[i].actif,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: i == _selectedIdx
                                                        ? DashboardTokens
                                                            .onMatteEmphasis
                                                        : DashboardTokens
                                                            .labelGrey,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _reports[i].sousTitre,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color:
                                                        DashboardTokens.muted,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_reports[i].globalConfidencePercent}%',
                                            style: TextStyle(
                                              color: AnalyseTokens
                                                  .confidenceColorForPercent(
                                                _reports[i]
                                                    .globalConfidencePercent,
                                              ),
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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

  @override
  void dispose() {
    _closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    _fieldLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DashboardTokens.onMatteEmphasis,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (_currentSnapshot != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${_currentSnapshot!.globalConfidencePercent}%',
                    style: TextStyle(
                      color: AnalyseTokens.confidenceColorForPercent(
                        _currentSnapshot!.globalConfidencePercent,
                      ),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
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

