import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mon_app_finder/l10n/app_localizations.dart';

import 'analyse_controller.dart';
import 'analyse_default_demo_seed.dart';
import 'analyse_realtime_notifier.dart';
import 'analyse_page_content.dart';
import 'analyse_report_apply.dart';
import 'analyse_report_pdf.dart';
import 'analyse_report_snapshot.dart';
import 'analyse_report_snapshot_codec.dart';
import 'analyse_reports_storage.dart';
import 'analyse_firestore_sync.dart';
import 'analyse_starred_report_storage.dart';
import 'analyse_tokens.dart';
import '../strategie/strategie_setups_store.dart';

class AnalysePage extends StatefulWidget {
  const AnalysePage({
    super.key,
    this.onNavigateToDashboard,
    this.onCloseAsTab,
    this.initialScrollToReports = false,
    this.revealSnapshot,
  });

  final VoidCallback? onNavigateToDashboard;
  final VoidCallback? onCloseAsTab;

  /// [bool?] : tolère les instances d’écran conservées au hot reload (slot null → faux).
  final bool? initialScrollToReports;

  /// Aperçu affiché sur l’accueil : sert à faire défiler jusqu’au même rapport embarqué.
  final AnalyseReportSnapshot? revealSnapshot;

  @override
  State<AnalysePage> createState() => _AnalysePageState();
}

class _AnalysePageState extends State<AnalysePage> {
  late final AnalyseController _c;
  late final ValueNotifier<int> _strategieSetupIndex;
  List<AnalyseStackedReportEntry> _reportEntries = [];

  /// Prochaine clé [ValueKey] pour un nouveau bloc rapport (démo + validations).
  int _nextReportEmbedKey = 1;
  AnalyseReportSnapshot? _storedDashboardStarSnapshot;
  bool _lastEditedWasStarred = false;

  bool get _embeddedInTabShell => widget.onCloseAsTab != null;

  void _handleBack() {
    if (_embeddedInTabShell) {
      widget.onCloseAsTab!.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    AnalyseRealtimeNotifier.tick.addListener(_onRemoteAnalyseTick);
    AnalyseRealtimeNotifier.reportsTick.addListener(_onAnalyseReportsDiskTick);
    AnalyseStarredReportStorage.load().then((s) {
      if (!mounted) return;
      setState(() => _storedDashboardStarSnapshot = s);
    });
    _c = AnalyseController();
    _strategieSetupIndex = ValueNotifier<int>(0);
    StrategieSetupsStore.ensureLoaded();
    _reportEntries = _buildDemoEntries(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
    _c.resetAfterReportValidation();
    _restoreStoredReportsIfAny();
  }

  void _onRemoteAnalyseTick() {
    if (!mounted) return;
    // Ne pas relire toute la liste des rapports ici : [bump] est aussi appelé après
    // l’épinglage locale ; [reportsTick] / [_onAnalyseReportsDiskTick] gère le disque.
    unawaited(
      AnalyseStarredReportStorage.load().then((s) {
        if (!mounted) return;
        setState(() => _storedDashboardStarSnapshot = s);
      }),
    );
  }

  void _onAnalyseReportsDiskTick() {
    if (!mounted) return;
    unawaited(() async {
      await _restoreStoredReportsIfAny();
      if (!mounted) return;
      final s = await AnalyseStarredReportStorage.load();
      if (!mounted) return;
      setState(() => _storedDashboardStarSnapshot = s);
    }());
  }


  List<AnalyseStackedReportEntry> _buildDemoEntries(Locale locale) {
    applyAnalyseDefaultGoldBreakoutDemo(_c, locale: locale);
    final goldSnap = AnalyseReportSnapshot.fromController(_c, locale: locale);
    final goldKey = _nextReportEmbedKey++;
    applyAnalyseDefaultEuroUsdWeeklySwingDemo(_c, locale: locale);
    final eurSnap = AnalyseReportSnapshot.fromController(_c, locale: locale);
    final eurKey = _nextReportEmbedKey++;
    return [
      AnalyseStackedReportEntry(snapshot: goldSnap, embedKey: goldKey),
      AnalyseStackedReportEntry(snapshot: eurSnap, embedKey: eurKey),
    ];
  }

  @override
  void dispose() {
    AnalyseRealtimeNotifier.tick.removeListener(_onRemoteAnalyseTick);
    AnalyseRealtimeNotifier.reportsTick.removeListener(_onAnalyseReportsDiskTick);
    _strategieSetupIndex.dispose();
    super.dispose();
  }

  Future<void> _restoreStoredReportsIfAny() async {
    final platformLoc = WidgetsBinding.instance.platformDispatcher.locale;
    final stored = await AnalyseReportsStorage.loadAll();
    if (!mounted) return;
    if (stored.isNotEmpty) {
      setState(() {
        _reportEntries = [
          for (final s in stored)
            AnalyseStackedReportEntry(
              snapshot: s,
              embedKey: _nextReportEmbedKey++,
            ),
        ];
      });
      return;
    }
    final appLoc = Localizations.localeOf(context);
    if (appLoc.languageCode != platformLoc.languageCode) {
      setState(() {
        _reportEntries = _buildDemoEntries(appLoc);
      });
      _c.resetAfterReportValidation();
    }
  }

  Future<void> _persistCurrentReports() async {
    await AnalyseReportsStorage.saveAll(
      [for (final e in _reportEntries) e.snapshot],
    );
    // Fire-and-forget : sync cloud.
    AnalyseFirestoreSync.pushIfSignedIn();
    // Liste disque alignée : autres écrans peuvent relire sans course avec l’étoile.
    AnalyseRealtimeNotifier.bumpReports();
    // Rafraîchit les aperçus dashboard (local) immédiatement.
    AnalyseRealtimeNotifier.bump();
  }

  /// Index du bloc rapport à amener dans la vue (depuis le raccourci accueil).
  int get _scrollTargetReportIndex {
    if (!(widget.initialScrollToReports ?? false)) return 0;
    final target = widget.revealSnapshot;
    if (target == null) return 0;
    for (var i = 0; i < _reportEntries.length; i++) {
      if (analyseSnapshotsEqualForStar(target, _reportEntries[i].snapshot)) {
        return i;
      }
    }
    return 0;
  }

  bool _reportStarredAt(int index) {
    if (index < 0 || index >= _reportEntries.length) return false;
    return AnalyseStarredReportStorage.matches(
      _storedDashboardStarSnapshot,
      _reportEntries[index].snapshot,
    );
  }

  Future<void> _toggleDashboardStarAt(int index) async {
    if (index < 0 || index >= _reportEntries.length) return;
    final snap = _reportEntries[index].snapshot;
    final on = AnalyseStarredReportStorage.matches(
      _storedDashboardStarSnapshot,
      snap,
    );
    if (on) {
      await AnalyseStarredReportStorage.clear();
      if (!mounted) return;
      setState(() => _storedDashboardStarSnapshot = null);
      AnalyseFirestoreSync.pushIfSignedIn();
      AnalyseRealtimeNotifier.bump();
    } else {
      await AnalyseStarredReportStorage.save(snap);
      if (!mounted) return;
      setState(() => _storedDashboardStarSnapshot = snap);
      // Les démos ne sont pas encore sur disque : sans persistance, le dashboard
      // efface l’étoile car [AnalyseReportsStorage] est vide.
      await _persistCurrentReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxW =
        math.min(AnalyseTokens.pageMaxWidthDashboard, media.size.width);

    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        return PopScope(
          canPop: !_embeddedInTabShell,
          onPopInvokedWithResult: (didPop, result) {
            if (_embeddedInTabShell) {
              if (!didPop) widget.onCloseAsTab!.call();
              return;
            }
            if (didPop) widget.onNavigateToDashboard?.call();
          },
          child: Scaffold(
            backgroundColor: AnalyseTokens.bg,
            body: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.9),
                          radius: 1.4,
                          colors: [
                            AnalyseTokens.accentGreen.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: IconButton(
                                    onPressed: _handleBack,
                                    style: IconButton.styleFrom(
                                      foregroundColor: AnalyseTokens.muted2,
                                      padding: const EdgeInsets.all(10),
                                      minimumSize: const Size(40, 40),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    tooltip:
                                        MaterialLocalizations.of(context)
                                            .backButtonTooltip,
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 2,
                                      top: 6,
                                      right: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .analysePageHeroTitle,
                                          style: const TextStyle(
                                            color: AnalyseTokens.matteText,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            height: 1.15,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .analysePageHeroSubtitle,
                                          style: TextStyle(
                                            color: AnalyseTokens.muted2,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            height: 1.4,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: AnalyseTokens.cardBorder.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                          Expanded(
                            child: AnalysePageScrollContent(
                              controller: _c,
                              strategieVisibleSetupIndex: _strategieSetupIndex,
                              reportEntries: _reportEntries,
                              initialScrollToReports:
                                  widget.initialScrollToReports ?? false,
                              scrollTargetReportIndex: _scrollTargetReportIndex,
                              reportStarred: _reportStarredAt,
                              onToggleReportStar: _toggleDashboardStarAt,
                              onReportValidated: (s) {
                                final shot = _c.draftReportScreenshotBytes;
                                final wasEditingStar = _lastEditedWasStarred;
                                _lastEditedWasStarred = false;
                                setState(() {
                                  // Ajoute en haut de liste (historique).
                                  _reportEntries = [
                                    AnalyseStackedReportEntry(
                                      snapshot: s,
                                      embedKey: _nextReportEmbedKey++,
                                      screenshotBytes: shot,
                                    ),
                                    ..._reportEntries,
                                  ];
                                });
                                if (wasEditingStar) {
                                  AnalyseStarredReportStorage.save(s).then((_) {
                                    if (!mounted) return;
                                    setState(() => _storedDashboardStarSnapshot = s);
                                    AnalyseRealtimeNotifier.bump();
                                  });
                                }
                                _persistCurrentReports();
                              },
                              onEditReport: (index) {
                                if (index < 0 ||
                                    index >= _reportEntries.length) {
                                  return;
                                }
                                final snap = _reportEntries[index].snapshot;
                                final wasStarred =
                                    AnalyseStarredReportStorage.matches(
                                      _storedDashboardStarSnapshot,
                                      snap,
                                    );
                                _lastEditedWasStarred = wasStarred;
                                final previousShot =
                                    _reportEntries[index].screenshotBytes;
                                applyAnalyseReportToController(_c, snap);
                                _c.setDraftReportScreenshot(previousShot);
                                setState(() {
                                  _reportEntries =
                                      List<AnalyseStackedReportEntry>.from(
                                        _reportEntries,
                                      )..removeAt(index);
                                });
                                _persistCurrentReports();
                              },
                              onExportPdf: (index) {
                                if (index < 0 ||
                                    index >= _reportEntries.length) {
                                  return;
                                }
                                final e = _reportEntries[index];
                                exportAnalyseReportPdf(
                                  context,
                                  snapshot: e.snapshot,
                                  imageBytes: e.screenshotBytes,
                                );
                              },
                              onDeleteReport: (index) {
                                if (index < 0 ||
                                    index >= _reportEntries.length) {
                                  return;
                                }
                                final deleting = _reportEntries[index].snapshot;
                                final wasStarred =
                                    AnalyseStarredReportStorage.matches(
                                      _storedDashboardStarSnapshot,
                                      deleting,
                                    );
                                setState(() {
                                  _reportEntries =
                                      List<AnalyseStackedReportEntry>.from(
                                        _reportEntries,
                                      )..removeAt(index);
                                });
                                if (wasStarred) {
                                  AnalyseStarredReportStorage.clear().then((_) {
                                    if (!mounted) return;
                                    setState(() => _storedDashboardStarSnapshot = null);
                                    AnalyseRealtimeNotifier.bump();
                                  });
                                }
                                _persistCurrentReports();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
