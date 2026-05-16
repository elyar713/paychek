import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../../questionnaire/user_capital_scope.dart';
import '../../reglage/user_portfolio_scope.dart';
import '../strategie_feedback_reference.dart';
import '../gestion_risque_edit_notifier.dart';
import '../strategie_gestion_risque_storage.dart';
import '../strategie_firestore_sync.dart';
import '../strategie_realtime_notifier.dart';
import '../strategie_tokens.dart';
import '../widgets/strategie_section_frame.dart';
import 'strategie_gestion_risque_section_display.dart';
import 'strategie_gestion_risque_section_menu.dart';

/// Gestion du risque — **sans** ligne Capital (maquette). Grille 2×2 en [Table] (évite [IntrinsicHeight]+[Expanded] dans le scroll).
/// Montants sous % : calculés depuis [UserCapitalStore] et les % courants (mise à jour à la saisie en mode Modifier).
class StrategieGestionRisqueSection extends StatefulWidget {
  const StrategieGestionRisqueSection({
    super.key,
    required this.editNotifier,
  });

  /// Synchronisé avec le [Listener] page entière ([StrategiePage]).
  final GestionRisqueEditNotifier editNotifier;

  @override
  State<StrategieGestionRisqueSection> createState() =>
      _StrategieGestionRisqueSectionState();
}

class _RiskEditSnapshot {
  const _RiskEditSnapshot({
    required this.riskPct,
    required this.lossPct,
    required this.tradesPerDay,
    required this.rrRatio,
  });
  final double riskPct;
  final double lossPct;
  final int tradesPerDay;
  final double rrRatio;
}

class _StrategieGestionRisqueSectionState
    extends State<StrategieGestionRisqueSection> {
  static const double _fallbackCapital = 10000;
  static const double _cellGap = 14;
  static const double _cellHalfGap = _cellGap / 2;

  double _riskPct = 1;
  double _lossPct = 3;
  int _tradesPerDay = 3;
  double _rrRatio = 2;

  bool _editMode = false;
  _RiskEditSnapshot? _editSnapshot;

  bool _showDisableToggles = false;
  List<bool>? _disableSnapshot;
  final List<bool> _cellEnabled = [true, true, true, true];

  late final TextEditingController _riskCtrl;
  late final TextEditingController _lossCtrl;
  late final TextEditingController _tradeCtrl;
  late final TextEditingController _rrCtrl;

  final GlobalKey _riskEditKey = GlobalKey();
  final GlobalKey _lossEditKey = GlobalKey();
  final GlobalKey _tradeEditKey = GlobalKey();
  final GlobalKey _rrEditKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _switchRiskKey = GlobalKey();
  final GlobalKey _switchLossKey = GlobalKey();
  final GlobalKey _switchTradeKey = GlobalKey();
  final GlobalKey _switchRrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _riskCtrl = TextEditingController();
    _lossCtrl = TextEditingController();
    _tradeCtrl = TextEditingController();
    _rrCtrl = TextEditingController();
    _syncControllersFromState();
    _loadPersistedGestion();
    StrategieRealtimeNotifier.tick.addListener(_onStrategieRemoteTick);
  }

  void _onStrategieRemoteTick() {
    if (_editMode || _showDisableToggles) return;
    unawaited(_loadPersistedGestion());
  }

  Future<void> _loadPersistedGestion() async {
    final p = await StrategieGestionRisqueStorage.load();
    if (!mounted) return;
    setState(() {
      _riskPct = p.riskPct;
      _lossPct = p.lossPct;
      _tradesPerDay = p.tradesPerDay;
      _rrRatio = p.rrRatio;
      _syncControllersFromState();
    });
  }

  @override
  void dispose() {
    StrategieRealtimeNotifier.tick.removeListener(_onStrategieRemoteTick);
    widget.editNotifier.onCommitOutside = null;
    widget.editNotifier.onCommitDisableOutside = null;
    widget.editNotifier.onForceCloseGestionRisqueEdit = null;
    _riskCtrl.dispose();
    _lossCtrl.dispose();
    _tradeCtrl.dispose();
    _rrCtrl.dispose();
    super.dispose();
  }

  void _syncControllersFromState() {
    _riskCtrl.text = StrategieGestionRisqueFormat.formatNumEdit(_riskPct);
    _lossCtrl.text = StrategieGestionRisqueFormat.formatNumEdit(_lossPct);
    _tradeCtrl.text = '$_tradesPerDay';
    _rrCtrl.text = StrategieGestionRisqueFormat.formatNumEdit(_rrRatio);
  }

  /// Premier appui : édition. En édition : ré-appui = **annuler** (pas de validation ici).
  /// La validation se fait en appuyant **en dehors** des cases noires.
  void _onMenuModify() {
    if (_editMode) {
      _cancelEdit();
    } else {
      _startEdit();
    }
  }

  void _startEdit() {
    widget.editNotifier.onForceCloseHorairesEdit?.call();
    widget.editNotifier.onForceCloseSetupsEdit?.call();
    setState(() {
      if (_showDisableToggles) {
        _showDisableToggles = false;
        _disableSnapshot = null;
      }
      _editSnapshot = _RiskEditSnapshot(
        riskPct: _riskPct,
        lossPct: _lossPct,
        tradesPerDay: _tradesPerDay,
        rrRatio: _rrRatio,
      );
      _editMode = true;
      _syncControllersFromState();
    });
  }

  void _commitEdit() {
    final snap = _editSnapshot;
    if (snap == null) return;

    final r = StrategieGestionRisqueFormat.parseFlexible(_riskCtrl.text) ??
        snap.riskPct;
    final l = StrategieGestionRisqueFormat.parseFlexible(_lossCtrl.text) ??
        snap.lossPct;
    final t = int.tryParse(_tradeCtrl.text.trim()) ?? snap.tradesPerDay;
    final rr = StrategieGestionRisqueFormat.parseFlexible(_rrCtrl.text) ??
        snap.rrRatio;

    setState(() {
      _riskPct = r > 0 ? r : snap.riskPct;
      _lossPct = l > 0 ? l : snap.lossPct;
      _tradesPerDay = t > 0 ? t : snap.tradesPerDay;
      _rrRatio = rr > 0 ? rr : snap.rrRatio;
      _editMode = false;
      _editSnapshot = null;
      _syncControllersFromState();
    });
    StrategieGestionRisqueStorage.save(
      StrategieGestionRisqueParams(
        riskPct: _riskPct,
        lossPct: _lossPct,
        tradesPerDay: _tradesPerDay,
        rrRatio: _rrRatio,
      ),
    );
    // Fire-and-forget : sync cloud.
    unawaited(StrategieFirestoreSync.pushIfSignedIn());
  }

  void _cancelEdit() {
    if (!_editMode) return;
    final snap = _editSnapshot;
    setState(() {
      if (snap != null) {
        _riskPct = snap.riskPct;
        _lossPct = snap.lossPct;
        _tradesPerDay = snap.tradesPerDay;
        _rrRatio = snap.rrRatio;
      }
      _editMode = false;
      _editSnapshot = null;
      _syncControllersFromState();
    });
  }

  /// Premier appui : affiche les interrupteurs (snapshot pour annuler).
  /// En mode config : ré-appui = **annuler** ; validation = tap **ailleurs** sur la page.
  void _onMenuDisableFactors() {
    widget.editNotifier.onForceCloseHorairesEdit?.call();
    widget.editNotifier.onForceCloseSetupsEdit?.call();
    if (_showDisableToggles) {
      _cancelDisableMode();
      return;
    }
    if (_editMode) {
      _cancelEdit();
    }
    setState(() {
      _disableSnapshot = List<bool>.from(_cellEnabled);
      _showDisableToggles = true;
    });
  }

  void _commitDisableMode() {
    if (!_showDisableToggles) return;
    setState(() {
      _showDisableToggles = false;
      _disableSnapshot = null;
    });
  }

  void _cancelDisableMode() {
    if (!_showDisableToggles) return;
    final snap = _disableSnapshot;
    setState(() {
      if (snap != null) {
        for (var i = 0; i < 4; i++) {
          _cellEnabled[i] = snap[i];
        }
      }
      _showDisableToggles = false;
      _disableSnapshot = null;
    });
  }

  void _syncEditNotifier() {
    final n = widget.editNotifier;
    n.isEditing = _editMode;
    n.editKeys = [_riskEditKey, _lossEditKey, _tradeEditKey, _rrEditKey];
    n.menuKey = _menuKey;
    n.onCommitOutside = _commitEdit;
    n.isConfiguringDisable = _showDisableToggles && !_editMode;
    n.disableExcludeKeys = [
      _switchRiskKey,
      _switchLossKey,
      _switchTradeKey,
      _switchRrKey,
    ];
    n.onCommitDisableOutside = _commitDisableMode;
    n.onForceCloseGestionRisqueEdit = () {
      if (_editMode) _cancelEdit();
      if (_showDisableToggles) _cancelDisableMode();
    };
  }

  double _liveRiskPct() {
    if (_editMode) {
      return StrategieGestionRisqueFormat.parseFlexible(_riskCtrl.text) ??
          _riskPct;
    }
    return _riskPct;
  }

  double _liveLossPct() {
    if (_editMode) {
      return StrategieGestionRisqueFormat.parseFlexible(_lossCtrl.text) ??
          _lossPct;
    }
    return _lossPct;
  }

  Color _cellMainColor(int index, Color base) {
    if (!_cellEnabled[index]) return StrategieTokens.labelMuted;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final gr = StrategieFeedbackReference.gestionRisque(locale);
    _syncEditNotifier();
    final store = UserCapitalScope.of(context);
    final pf = UserPortfolioScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([store, pf]),
      builder: (context, _) {
        final capital =
            pf.effectiveCapitalAmount(store) ?? _fallbackCapital;
        final sym = pf.effectiveCurrencySymbol(store);
        final rPct = _liveRiskPct();
        final lPct = _liveLossPct();
        final subRisk = StrategieGestionRisqueFormat.riskAmountLine(
          capital,
          rPct / 100.0,
          sym,
        );
        final subLoss = StrategieGestionRisqueFormat.riskAmountLine(
          capital,
          lPct / 100.0,
          sym,
        );

        final showToggles = _showDisableToggles && !_editMode;

        return StrategieSectionFrame(
          backgroundColor: StrategieTokens.mesReglesSectionCardBg,
          leadingIcon: LucideIcons.shield,
          title: l.ajouterTradeStrategieRiskManagement,
          titleColor: StrategieTokens.titleGrey,
          trailingMenu: KeyedSubtree(
            key: _menuKey,
            child: buildStrategieGestionRisquePopupMenu(
              onModify: _onMenuModify,
              onDisableFactors: _onMenuDisableFactors,
            ),
          ),
          child: Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: _cellHalfGap,
                        bottom: _cellGap,
                      ),
                      child: StrategieGestionRisqueRiskCell(
                        editKey: _riskEditKey,
                        onEnterEditTap: _editMode ? null : _startEdit,
                        label: gr[0].label,
                        editMode: _editMode,
                        displayMain:
                            StrategieGestionRisqueFormat.pctDisplay(_riskPct),
                        editingController: _riskCtrl,
                        onEditingChanged: () => setState(() {}),
                        decimalField: true,
                        mainColor: _cellMainColor(0, Colors.white),
                        captionUnderMain: null,
                        sub: subRisk,
                        subMuted: !_cellEnabled[0],
                        showToggle: showToggles,
                        toggleValue: _cellEnabled[0],
                        onToggleChanged: (v) =>
                            setState(() => _cellEnabled[0] = v),
                        toggleAreaKey: _switchRiskKey,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: _cellHalfGap,
                        bottom: _cellGap,
                      ),
                      child: StrategieGestionRisqueRiskCell(
                        editKey: _lossEditKey,
                        onEnterEditTap: _editMode ? null : _startEdit,
                        label: gr[1].label,
                        editMode: _editMode,
                        displayMain:
                            StrategieGestionRisqueFormat.pctDisplay(_lossPct),
                        editingController: _lossCtrl,
                        onEditingChanged: () => setState(() {}),
                        decimalField: true,
                        mainColor: _cellMainColor(1, StrategieTokens.riskRed),
                        captionUnderMain: null,
                        sub: subLoss,
                        subMuted: !_cellEnabled[1],
                        showToggle: showToggles,
                        toggleValue: _cellEnabled[1],
                        onToggleChanged: (v) =>
                            setState(() => _cellEnabled[1] = v),
                        toggleAreaKey: _switchLossKey,
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(right: _cellHalfGap),
                      child: StrategieGestionRisqueRiskCell(
                        editKey: _tradeEditKey,
                        onEnterEditTap: _editMode ? null : _startEdit,
                        label: gr[2].label,
                        editMode: _editMode,
                        displayMain: '$_tradesPerDay',
                        editingController: _tradeCtrl,
                        onEditingChanged: () => setState(() {}),
                        decimalField: false,
                        mainColor: _cellMainColor(2, Colors.white),
                        captionUnderMain: l.strategieGestionCaptionMaximum,
                        sub: null,
                        subMuted: !_cellEnabled[2],
                        showToggle: showToggles,
                        toggleValue: _cellEnabled[2],
                        onToggleChanged: (v) =>
                            setState(() => _cellEnabled[2] = v),
                        toggleAreaKey: _switchTradeKey,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(left: _cellHalfGap),
                      child: StrategieGestionRisqueRiskCell(
                        editKey: _rrEditKey,
                        onEnterEditTap: _editMode ? null : _startEdit,
                        label: gr[3].label,
                        editMode: _editMode,
                        displayMain:
                            StrategieGestionRisqueFormat.rrDisplay(_rrRatio),
                        editingController: _rrCtrl,
                        onEditingChanged: () => setState(() {}),
                        decimalField: true,
                        mainColor: _cellMainColor(3, StrategieTokens.ratioTeal),
                        captionUnderMain: l.strategieGestionCaptionMinimum,
                        sub: null,
                        subMuted: !_cellEnabled[3],
                        showToggle: showToggles,
                        toggleValue: _cellEnabled[3],
                        onToggleChanged: (v) =>
                            setState(() => _cellEnabled[3] = v),
                        toggleAreaKey: _switchRrKey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
