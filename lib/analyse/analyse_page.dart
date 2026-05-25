import 'dart:async' show unawaited;
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'analyse_controller.dart';
import 'analyse_entry_tf_storage.dart';
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
import 'analyse_oled_plan_ui.dart';
import 'analyse_tokens.dart';
import '../l10n/app_localizations.dart';
import '../strategie/strategie_setups_store.dart';
import '../widgets/paychek_page_header.dart';

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
  bool _showSaveBanner = false;

  /// Incrémenté au crayon : force la reconstruction des champs OLED (initialValue).
  int _generatorContentEpoch = 0;

  /// Index du rapport en cours de réédition (crayon) — masqué dans la liste, remplacé à la sauvegarde.
  int? _editingReportIndex;

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
    unawaited(AnalyseEntryTfStorage.applyToController(_c));
    _strategieSetupIndex = ValueNotifier<int>(0);
    StrategieSetupsStore.ensureLoaded();
    unawaited(_restoreStoredReportsIfAny());
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


  @override
  void dispose() {
    AnalyseRealtimeNotifier.tick.removeListener(_onRemoteAnalyseTick);
    AnalyseRealtimeNotifier.reportsTick.removeListener(_onAnalyseReportsDiskTick);
    _strategieSetupIndex.dispose();
    super.dispose();
  }

  /// Un rapport démo figé sous le générateur ; le contrôleur reste vierge (modifiable).
  void _seedDemoReportOnly() {
    _reportEntries = [
      AnalyseStackedReportEntry(
        snapshot: buildAnalyseDashboardPreviewSnapshot(),
        embedKey: _nextReportEmbedKey++,
      ),
    ];
  }

  Future<void> _restoreStoredReportsIfAny() async {
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
    setState(_seedDemoReportOnly);
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

  void _onSavePlan() {
    FocusManager.instance.primaryFocus?.unfocus();
    final locale = Localizations.localeOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final snap = AnalyseReportSnapshot.fromController(_c, locale: locale);
      _commitReportFromGenerator(snap);
    });
  }

  /// Nouveau rapport en tête, ou remplacement du rapport ouvert au crayon.
  void _commitReportFromGenerator(AnalyseReportSnapshot snap) {
    final editIdx = _editingReportIndex;
    final wasEditingStar = _lastEditedWasStarred;
    _editingReportIndex = null;
    _lastEditedWasStarred = false;

    final AnalyseStackedReportEntry entry;
    if (editIdx != null &&
        editIdx >= 0 &&
        editIdx < _reportEntries.length) {
      final prev = _reportEntries[editIdx];
      entry = AnalyseStackedReportEntry(
        snapshot: snap,
        embedKey: prev.embedKey,
        screenshotBytes: _c.draftReportScreenshotBytes ?? prev.screenshotBytes,
      );
    } else {
      entry = AnalyseStackedReportEntry(
        snapshot: snap,
        embedKey: _nextReportEmbedKey++,
        screenshotBytes: _c.draftReportScreenshotBytes,
      );
    }

    setState(() {
      _showSaveBanner = true;
      if (editIdx != null &&
          editIdx >= 0 &&
          editIdx < _reportEntries.length) {
        final list = List<AnalyseStackedReportEntry>.from(_reportEntries);
        list[editIdx] = entry;
        _reportEntries = list;
      } else {
        _reportEntries = [entry, ..._reportEntries];
      }
    });

    if (wasEditingStar) {
      AnalyseStarredReportStorage.save(snap).then((_) {
        if (!mounted) return;
        setState(() => _storedDashboardStarSnapshot = snap);
        AnalyseRealtimeNotifier.bump();
      });
    }
    _persistCurrentReports();
    _c.resetAfterReportValidation();
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showSaveBanner = false);
    });
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
    final l = AppLocalizations.of(context)!;

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
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxContent = math.min(
                    AnalyseTokens.pageContentMaxWidth,
                    constraints.maxWidth,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PaychekPageHeader(
                        onBack: _handleBack,
                        title: l.analysePageHeroTitle,
                        subtitle: l.analysePageHeroSubtitle,
                        subtitleMaxLines: 2,
                        maxContentWidth: AnalyseTokens.pageMaxWidthDashboard,
                      ),
                      AnalyseOledStickyHeader(
                        controller: _c,
                        onSave: _onSavePlan,
                      ),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: maxContent),
                            child: AnalysePageScrollContent(
                          controller: _c,
                          generatorContentEpoch: _generatorContentEpoch,
                          editingReportIndex: _editingReportIndex,
                          showSaveBanner: _showSaveBanner,
                          onDismissSaveBanner: () {
                            if (mounted) setState(() => _showSaveBanner = false);
                          },
                              strategieVisibleSetupIndex: _strategieSetupIndex,
                              reportEntries: _reportEntries,
                              initialScrollToReports:
                                  widget.initialScrollToReports ?? false,
                              scrollTargetReportIndex: _scrollTargetReportIndex,
                              reportStarred: _reportStarredAt,
                              onToggleReportStar: _toggleDashboardStarAt,
                              onReportValidated: _commitReportFromGenerator,
                              onEditReport: (index) {
                                if (index < 0 ||
                                    index >= _reportEntries.length) {
                                  return;
                                }
                                final entry = _reportEntries[index];
                                final snap = entry.snapshot;
                                final wasStarred =
                                    AnalyseStarredReportStorage.matches(
                                      _storedDashboardStarSnapshot,
                                      snap,
                                    );
                                _lastEditedWasStarred = wasStarred;
                                _editingReportIndex = index;
                                applyAnalyseReportToController(_c, snap);
                                _c.setDraftReportScreenshot(entry.screenshotBytes);
                                setState(() => _generatorContentEpoch++);
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
                                  if (_editingReportIndex == index) {
                                    _editingReportIndex = null;
                                  } else if (_editingReportIndex != null &&
                                      _editingReportIndex! > index) {
                                    _editingReportIndex =
                                        _editingReportIndex! - 1;
                                  }
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
                        ),
                      ),
                  ],
                );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
