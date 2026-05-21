part of 'ajouter_trade_page.dart';

class _AjouterTradePageState extends State<AjouterTradePage> {
  void _onShellBodyIndexChanged() {
    if (widget.shellBodyIndex.value != 2) {
      _ajouterTradeCloseCommission(this);
      _ajouterTradeCloseStrategieMenu(this);
      _ajouterTradeCloseTradeDateTimeOverlay(this);
    }
  }

  /// Lite : principe / feeling / stratégie / plan — tap → paywall (hors bloc capital & gain).
  Widget _liteLockPremiumSections(Widget child) {
    if (!widget.liteFreemiumRestricted) return child;
    final t = widget.onLiteFreemiumRestrictedTap;
    if (t == null) {
      return IgnorePointer(
        ignoring: true,
        child: Opacity(opacity: 0.5, child: child),
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IgnorePointer(
          ignoring: true,
          child: Opacity(opacity: 0.5, child: child),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: t,
              splashColor: Colors.white10,
              highlightColor: Colors.white10,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }

  static const Color _longFill = Color(0xFF1EB48A);
  static const Color _shortFill = Color(0xFFE53935);

  AjouterTradeSide _side = AjouterTradeSide.long;
  AjouterTradeAssetClass _assetClass = AjouterTradeAssetClass.forex;

  /// Actif favori persisté par marché (étoile dans la liste déroulante).
  final Map<AjouterTradeAssetClass, String> _favoriteActifByMarche = {};
  String _actif = ajouterTradeActifsPour(AjouterTradeAssetClass.forex).first;

  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _prixPositionController = TextEditingController();
  final TextEditingController _entreeController = TextEditingController();
  final TextEditingController _sortieController = TextEditingController();
  final TextEditingController _tradeNoteController = TextEditingController();
  DateTime _entreeDateTime = DateTime.now();
  DateTime _sortieDateTime = DateTime.now();
  bool _breakeven = false;
  bool _positionEnCours = false;
  bool _avantNews = false;
  bool _apresNews = false;

  AnalyseReportSnapshot? _tradeLinkedAnalyseReport;
  Uint8List? _tradeLinkedAnalysePdfBytes;
  String? _tradeLinkedAnalysePdfFileName;
  bool _tradeLinkedAnalysePdfGenerating = false;

  /// Import CSV minimal ([TradeListItem.performanceLite]) : conserve le P&L journal (net)
  /// tant que l'utilisateur ne modifie pas entrée/sortie/qty/instrument — l'estimation du
  /// widget est une approximation USD et peut diverger (-0,12 \$ vs -0,02 \$).
  double? _perfLiteBaselineNet;
  double _perfLiteBaselineCommission = 0;
  String? _perfLiteEditQty;
  String? _perfLiteEditEntree;
  String? _perfLiteEditSortie;
  bool? _perfLiteEditBreakeven;
  bool? _perfLiteEditPositionEnCours;
  String? _perfLiteEditPair;
  AjouterTradeAssetClass? _perfLiteEditAssetClass;
  AjouterTradeSide? _perfLiteEditSide;

  double _strategieRespectPct = 50;

  String _strategieChoisie = strategieSetupDefaultCardDataList().first.title;

  Set<String> _strategieNonRespectIds = {};
  Set<String> _checklistNonRespectIds = {};
  Set<String> _etatMomentNonRespectIds = {};

  AnalyseReportSnapshot? _planAnalyseSelectedReport;

  /// Cache des rapports Mon Analyse (aligné sur [AnalyseReportsStorage]).
  List<AnalyseReportSnapshot> _planAnalyseStoredReports = const [];

  Set<String> _planAnalyseNonRespectIds = {};

  /// Incrémenté après chaque enregistrement pour forcer le remontage des menus rétroaction (cases internes).
  int _feedbackUiEpoch = 0;

  /// "T'as fait ce trade avec" : sélection unique.
  String _tradeMindset = 'none'; // 'none' | 'principe' | 'feeling'

  /// En mode Feeling : autorisation explicite pour remplir les blocs discipline.
  bool _authorizeDisciplineWhenFeeling = false;

  bool _sectionStrategieEnabled = true;
  bool _sectionPlanEnabled = true;
  bool _sectionChecklistEnabled = true;
  bool _sectionEtatEnabled = true;

  /// Test engrenage : auto-tag Principe / Feeling selon l’ordre du jour.
  bool _sessionAutoTagEnabled = false;
  int _plannedTradesPerDay = 2;

  bool _disciplineFeelingAllowsInput() =>
      _tradeMindset != 'feeling' || _authorizeDisciplineWhenFeeling;

  bool get _gateStrategie =>
      _sectionStrategieEnabled && _disciplineFeelingAllowsInput();

  bool get _gatePlan => _sectionPlanEnabled && _disciplineFeelingAllowsInput();

  bool get _gateChecklist =>
      _sectionChecklistEnabled && _disciplineFeelingAllowsInput();

  bool get _gateEtat => _sectionEtatEnabled && _disciplineFeelingAllowsInput();

  bool _disciplineGearIconLooksActive() {
    if (_tradeMindset == 'feeling' && !_authorizeDisciplineWhenFeeling) {
      return false;
    }
    return _sectionStrategieEnabled ||
        _sectionPlanEnabled ||
        _sectionChecklistEnabled ||
        _sectionEtatEnabled;
  }

  /// Repères bas de page (FOMO, TILT, …) — cases sélectionnables + ajout.
  List<String> _psychTagLabels = ['FOMO', 'TILT', 'Revenge', 'Blind'];
  final Set<String> _psychTagSelected = <String>{};
  bool _factoryPsychFourthSynced = false;

  bool _psychTagInputVisible = false;
  final TextEditingController _psychTagNewController = TextEditingController();
  final FocusNode _psychTagNewFocus = FocusNode();

  /// Capture d'écran optionnelle (graphique / setup).
  XFile? _tradeScreenshot;
  Uint8List? _tradeScreenshotBytes;
  static const List<CsvSoftwareOption> _csvSoftwareOptions =
      <CsvSoftwareOption>[
        CsvSoftwareOption(
          label: 'MT4',
          assetPath: 'assets/logos/csv_sources/mt4.png',
        ),
        CsvSoftwareOption(
          label: 'MT5',
          assetPath: 'assets/logos/csv_sources/mt5.png',
        ),
        CsvSoftwareOption(
          label: 'TradingView',
          assetPath: 'assets/logos/csv_sources/tradingview.png',
        ),
        CsvSoftwareOption(
          label: 'Tradovate',
          assetPath: 'assets/logos/csv_sources/ctrader.png',
        ),
        CsvSoftwareOption(
          label: 'cTrader',
          assetPath: 'assets/logos/csv_sources/tradovate.png',
        ),
        CsvSoftwareOption(
          label: 'NinjaTrader',
          assetPath: 'assets/logos/csv_sources/ninjatrader.png',
        ),
        CsvSoftwareOption(
          label: 'Quantower',
          assetPath: 'assets/logos/csv_sources/quanttower.png',
        ),
        CsvSoftwareOption(
          label: 'ATAS',
          assetPath: 'assets/logos/csv_sources/atas.png',
        ),
        CsvSoftwareOption(
          label: 'Rithmic',
          assetPath: 'assets/logos/csv_sources/rithmic.png',
        ),
      ];
  String? _selectedCsvSoftware;
  String? _lastImportedFileName;
  String? _editingTradeId;
  String? _editingPortfolioId;

  void _togglePsychTag(String label) {
    setState(() {
      if (_psychTagSelected.contains(label)) {
        _psychTagSelected.remove(label);
      } else {
        _psychTagSelected.add(label);
      }
    });
  }

  void _removePsychTag(String label) {
    setState(() {
      _psychTagLabels = List<String>.from(_psychTagLabels)..remove(label);
      _psychTagSelected.remove(label);
    });
  }

  void _onPsychTagPlusTap() {
    setState(() {
      _psychTagInputVisible = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _psychTagNewFocus.requestFocus();
    });
  }

  final ValueNotifier<int> _gainRecalcTick = ValueNotifier(0);

  final TextEditingController _commissionFeeController =
      TextEditingController();
  final LayerLink _commissionLayerLink = LayerLink();
  OverlayEntry? _commissionOverlay;

  final LayerLink _strategieLayerLink = LayerLink();
  final GlobalKey _strategieFieldKey = GlobalKey();
  OverlayEntry? _strategieMenuOverlay;

  final LayerLink _entreeDateLayerLink = LayerLink();
  final LayerLink _sortieDateLayerLink = LayerLink();
  final GlobalKey _entreeDateRowKey = GlobalKey();
  final GlobalKey _sortieDateRowKey = GlobalKey();
  OverlayEntry? _tradeDateTimeOverlay;

  /// `null` si fermé ; `true` = entrée, `false` = sortie.
  bool? _tradeDateTimeOverlayForEntree;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_factoryPsychFourthSynced) return;
    final blind = AppLocalizations.of(context)!.ajouterTradePsychTagBlind;
    if (_psychTagLabels.length >= 4) {
      final old = _psychTagLabels[3];
      if (old == 'Blind' ||
          old == 'À l\'aveugle' ||
          old == 'À l\u{2019}aveugle') {
        _factoryPsychFourthSynced = true;
        if (old != blind) {
          setState(() {
            _psychTagLabels = List<String>.from(_psychTagLabels)..[3] = blind;
            if (_psychTagSelected.remove(old)) {
              _psychTagSelected.add(blind);
            }
          });
        } else {
          _factoryPsychFourthSynced = true;
        }
      }
    }
  }

  void _onAnalyseReportsStorageTick() {
    _refreshPlanAnalyseFromStorage();
  }

  Future<void> _refreshPlanAnalyseFromStorage() async {
    final stored = await AnalyseReportsStorage.loadAll();
    if (!mounted) return;
    setState(() {
      _planAnalyseStoredReports = stored;
      final sel = _planAnalyseSelectedReport;
      if (sel != null) {
        final fresh = findStoredAnalyseReportMatch(sel, stored);
        if (fresh != null) {
          _planAnalyseSelectedReport = fresh;
        }
      } else {
        final pick = pickStoredAnalyseReportDefaultPreferGold(stored);
        if (pick != null) {
          _planAnalyseSelectedReport = pick;
        }
      }
    });
  }

  void _onPlanAnalyseReportsLoaded(
    List<AnalyseReportSnapshot> reports,
    AnalyseReportSnapshot? current,
  ) {
    if (!mounted) return;
    setState(() {
      _planAnalyseStoredReports = reports;
      if (current != null) {
        _planAnalyseSelectedReport = current;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    AnalyseRealtimeNotifier.reportsTick.addListener(_onAnalyseReportsStorageTick);
    _planAnalyseSelectedReport = _draftDefaultPlanAnalyseSnapshot(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
    _refreshPlanAnalyseFromStorage();
    AjouterTradeCustomActifsStorage.load().then((_) {
      if (!mounted) return;
      setState(() {});
    });
    AjouterTradeFavoriteActifStorage.loadAll().then((favs) {
      if (!mounted) return;
      setState(() {
        _favoriteActifByMarche
          ..clear()
          ..addAll(favs);
        final editing = widget.editTrade?.value != null;
        if (!editing) {
          _applyFavoriteActifForClass(_assetClass);
        }
      });
    });
    widget.editTrade?.addListener(_onEditTradeChanged);
    widget.checklistController.addListener(_onChecklistSectionsChanged);
    widget.shellBodyIndex.addListener(_onShellBodyIndexChanged);
    _loadDisciplinePrefsFromStorage();
    _applyNewsFlagsFromChecklist();
    _sortieController.addListener(_onSortieTextChanged);
    StrategieSetupsStore.ensureLoaded().then((_) {
      if (!mounted) return;
      final titres = StrategieSetupsStore.notifier.value
          .map((e) => e.title)
          .toList();
      if (titres.isEmpty) return;
      if (!titres.contains(_strategieChoisie)) {
        setState(() => _strategieChoisie = titres.first);
      }
    });
  }

  void _onSortieTextChanged() {
    if (!mounted) return;
    final hasSortie = _sortieController.text.trim().isNotEmpty;
    if (!hasSortie) return;
    // Si l'utilisateur renseigne un prix de sortie :
    // - ce n'est plus une position en cours
    // - ce n'est pas un breakeven (le calcul doit s'activer)
    if (!_positionEnCours && !_breakeven) return;
    setState(() {
      _positionEnCours = false;
      _breakeven = false;
    });
    _requestGainRecalc();
  }
  void _requestGainRecalc() {
    _gainRecalcTick.value++;
  }

  Listenable _gainSectionListenable(BuildContext context) {
    return Listenable.merge([
      UserCapitalScope.of(context),
      UserPortfolioScope.of(context),
      _quantiteController,
      _entreeController,
      _sortieController,
      _prixPositionController,
      _commissionFeeController,
      _gainRecalcTick,
    ]);
  }

  double? _tradeGainEstimate() {
    return estimateAjouterTradeMonetaryGain(
      breakeven: _breakeven,
      positionEnCours: _positionEnCours,
      sortieText: _sortieController.text,
      quantiteText: _quantiteController.text,
      entreeText: _entreeController.text,
      assetClass: _assetClass,
      actif: _actif,
      side: _side,
    );
  }

  void _clearPerfLitePreserve() {
    _perfLiteBaselineNet = null;
    _perfLiteBaselineCommission = 0;
    _perfLiteEditQty = null;
    _perfLiteEditEntree = null;
    _perfLiteEditSortie = null;
    _perfLiteEditBreakeven = null;
    _perfLiteEditPositionEnCours = null;
    _perfLiteEditPair = null;
    _perfLiteEditAssetClass = null;
    _perfLiteEditSide = null;
  }

  static String _normLiteQtyPriceField(String? s) =>
      (s ?? '').trim().replaceAll(' ', '');

  static String _normLitePairField(String? s) =>
      (s ?? '').trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();

  bool _perfLiteImportInputsUnchanged() {
    if (_perfLiteBaselineNet == null) return false;
    final ac = _perfLiteEditAssetClass ?? AjouterTradeAssetClass.forex;
    if (_assetClass != ac) return false;
    if (_normLitePairField(_actif) != _normLitePairField(_perfLiteEditPair)) {
      return false;
    }
    if (_side != (_perfLiteEditSide ?? _side)) return false;
    if (_breakeven != (_perfLiteEditBreakeven ?? false)) return false;
    if (_positionEnCours !=
        (_perfLiteEditPositionEnCours ?? false)) {
      return false;
    }
    return _normLiteQtyPriceField(_quantiteController.text) ==
            _normLiteQtyPriceField(_perfLiteEditQty) &&
        _normLiteQtyPriceField(_entreeController.text) ==
            _normLiteQtyPriceField(_perfLiteEditEntree) &&
        _normLiteQtyPriceField(_sortieController.text) ==
            _normLiteQtyPriceField(_perfLiteEditSortie);
  }

  /// Net affiché / enregistré : priorité au P&L importé tant que rien de pertinent n'a changé.
  double? _resolveTradeGainForPanel({
    required double? formulaGross,
    required double fee,
  }) {
    if (_perfLiteBaselineNet != null && _perfLiteImportInputsUnchanged()) {
      return _perfLiteBaselineNet! - (fee - _perfLiteBaselineCommission);
    }
    if (formulaGross == null) return null;
    return formulaGross - fee;
  }

  double _resolveTradeNetForSave({
    required double? formulaGross,
    required double fee,
  }) {
    if (_perfLiteBaselineNet != null && _perfLiteImportInputsUnchanged()) {
      return _perfLiteBaselineNet! - (fee - _perfLiteBaselineCommission);
    }
    if (formulaGross != null) return formulaGross - fee;
    return 0.0;
  }

  String _formatTradeDateLine(DateTime d) {
    final loc = Localizations.localeOf(context).toString();
    return DateFormat("dd MMMM yyyy '•' HH:mm", loc).format(d.toLocal());
  }

  Widget _wrapDisciplineBlock(bool enabled, Widget child) {
    return AbsorbPointer(
      absorbing: !enabled,
      child: Opacity(opacity: enabled ? 1.0 : 0.38, child: child),
    );
  }

  @override
  void dispose() {
    AnalyseRealtimeNotifier.reportsTick
        .removeListener(_onAnalyseReportsStorageTick);
    widget.editTrade?.removeListener(_onEditTradeChanged);
    widget.checklistController.removeListener(_onChecklistSectionsChanged);
    widget.shellBodyIndex.removeListener(_onShellBodyIndexChanged);
    _sortieController.removeListener(_onSortieTextChanged);
    _ajouterTradeCloseStrategieMenu(this);
    _ajouterTradeCloseCommission(this);
    _ajouterTradeCloseTradeDateTimeOverlay(this, suppressRebuild: true);
    _commissionFeeController.dispose();
    _gainRecalcTick.dispose();
    _quantiteController.dispose();
    _prixPositionController.dispose();
    _entreeController.dispose();
    _sortieController.dispose();
    _tradeNoteController.dispose();
    _psychTagNewController.dispose();
    _psychTagNewFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.shellBodyIndex,
      builder: (context, _) {
        return AjouterTradeShellScope(
          shellTabIndex: widget.shellBodyIndex.value,
          child: buildAjouterTradePageContent(context),
        );
      },
    );
  }
}

AnalyseReportSnapshot? _draftDefaultPlanAnalyseSnapshot(Locale locale) {
  final list = ajouterTradePlanAnalyseDemoSnapshotsSync(locale);
  return list.isEmpty ? null : list.first;
}
