// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

/// Données figées au clic « Enregistrer » (avant navigation / reset du formulaire).
class _TradeSaveCapture {
  _TradeSaveCapture({
    required this.store,
    required this.portfolioId,
    required this.localeTag,
    required this.actif,
    required this.assetClass,
    required this.side,
    required this.editingTradeId,
    required this.editingPortfolioId,
    required this.entreeAt,
    required this.sortieAt,
    required this.breakeven,
    required this.positionEnCours,
    required this.avantNews,
    required this.apresNews,
    required this.quantiteLabel,
    required this.prixEntreeLabel,
    required this.prixSortieLabel,
    required this.screenshotPath,
    required this.screenshotBytes,
    required this.net,
    required this.fee,
    required this.performanceLite,
    required this.tradeMindset,
    required this.strategieTitle,
    required this.planSelected,
    required this.planStoredReports,
    required this.checklistRingPercent,
    required this.mentalRingScore,
    required this.strategieRespectPct,
    required this.strategieNonRespectIds,
    required this.planNonRespectIds,
    required this.checklistNonRespectIds,
    required this.etatNonRespectIds,
    required this.checklistLinkedExplicit,
    required this.etatLinkedExplicit,
    required this.psychTags,
    required this.accountEntitlement,
    this.linkedAnalyseReport,
    this.linkedAnalysePdfBytes,
    this.linkedAnalysePdfFileName,
    this.userNote,
  });

  final TradeJournalStore store;
  final String portfolioId;
  final String localeTag;
  final String actif;
  final AjouterTradeAssetClass assetClass;
  final AjouterTradeSide side;
  final String? editingTradeId;
  final String? editingPortfolioId;
  final DateTime entreeAt;
  final DateTime? sortieAt;
  final bool breakeven;
  final bool positionEnCours;
  final bool avantNews;
  final bool apresNews;
  final String? quantiteLabel;
  final String? prixEntreeLabel;
  final String? prixSortieLabel;
  final String? screenshotPath;
  final Uint8List? screenshotBytes;
  final double net;
  final double fee;
  final bool performanceLite;
  final String tradeMindset;
  final String strategieTitle;
  final AnalyseReportSnapshot? planSelected;
  final List<AnalyseReportSnapshot> planStoredReports;
  final int checklistRingPercent;
  final double mentalRingScore;
  final double strategieRespectPct;
  final Set<String> strategieNonRespectIds;
  final Set<String> planNonRespectIds;
  final Set<String> checklistNonRespectIds;
  final Set<String> etatNonRespectIds;
  final bool checklistLinkedExplicit;
  final bool etatLinkedExplicit;
  final List<String> psychTags;
  final AccountEntitlementSnapshot? accountEntitlement;
  final AnalyseReportSnapshot? linkedAnalyseReport;
  final Uint8List? linkedAnalysePdfBytes;
  final String? linkedAnalysePdfFileName;
  final String? userNote;
}

String? _normalizeTradeUserNote(String raw) {
  final t = raw.trim();
  return t.isEmpty ? null : t;
}

extension _AjouterTradePageStateSave on _AjouterTradePageState {
  String? _tradeSaveValidationError(AppLocalizations l) {
    final qty = parseAjouterTradeAmount(_quantiteController.text);
    if (qty == null || qty <= 0) {
      return l.ajouterTradeErrorQtyPositive;
    }
    final entree = parseAjouterTradeAmount(_entreeController.text);
    if (entree == null || entree <= 0) {
      return l.ajouterTradeErrorEntryPrice;
    }
    if (!_breakeven && !_positionEnCours) {
      final sortie = parseAjouterTradeAmount(_sortieController.text);
      if (sortie == null || sortie <= 0) {
        return l.ajouterTradeErrorExitOrFlags;
      }
    }
    if (_tradeLinkedAnalyseReport != null &&
        (_tradeLinkedAnalysePdfGenerating ||
            _tradeLinkedAnalysePdfBytes == null ||
            _tradeLinkedAnalysePdfBytes!.isEmpty)) {
      return l.ajouterTradeAnalysePdfNotReady;
    }
    return null;
  }

  _TradeSaveCapture? _captureTradeSavePayload(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final validationError = _tradeSaveValidationError(l);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return null;
    }

    final gross = _tradeGainEstimate();
    final feeRaw = parseAjouterTradeAmount(_commissionFeeController.text) ?? 0;
    final fee = feeRaw < 0 ? 0.0 : feeRaw;
    final net = _resolveTradeNetForSave(formulaGross: gross, fee: fee);
    final keepPerfLite =
        _perfLiteBaselineNet != null && _perfLiteImportInputsUnchanged();
    final performanceLite = keepPerfLite && _tradeMindset == 'none';

    final entryDay = DateTime(
      _entreeDateTime.year,
      _entreeDateTime.month,
      _entreeDateTime.day,
    );
    final mentalC = MentalStateController.instance;
    final mentalHistorical = mentalC.overallScoreForCalendarDay(entryDay);
    final newsFlags = resolveTradeNewsTimingFlagsFromController(
      entreeAt: _entreeDateTime,
      checklist: widget.checklistController,
      manualFallback: TradeNewsTimingFlags(
        avantNews: _avantNews,
        apresNews: _apresNews,
      ),
    );

    var tradeMindset = _tradeMindset;
    if (_sessionAutoTagEnabled) {
      final store = TradeJournalScope.of(context);
      final portfolioId = _editingPortfolioId ??
          UserPortfolioScope.of(context).activePortfolioId;
      final m = resolveTradeSessionMindset(
        entreeAt: _entreeDateTime,
        existing: store.items,
        rules: _sessionMindsetRules,
        portfolioId: portfolioId,
        excludeTradeId: _editingTradeId,
      );
      tradeMindset = tradeMindsetToAjouterTradeKey(m);
    }

    return _TradeSaveCapture(
      store: TradeJournalScope.of(context),
      portfolioId:
          _editingPortfolioId ??
          UserPortfolioScope.of(context).activePortfolioId,
      localeTag: Localizations.localeOf(context).toString(),
      actif: _actif,
      assetClass: _assetClass,
      side: _side,
      editingTradeId: _editingTradeId,
      editingPortfolioId: _editingPortfolioId,
      entreeAt: _entreeDateTime,
      sortieAt: _positionEnCours ? null : _sortieDateTime,
      breakeven: _breakeven,
      positionEnCours: _positionEnCours,
      avantNews: newsFlags.avantNews,
      apresNews: newsFlags.apresNews,
      quantiteLabel: _quantiteController.text.trim().isEmpty
          ? null
          : _quantiteController.text.trim(),
      prixEntreeLabel: _entreeController.text.trim().isEmpty
          ? null
          : _entreeController.text.trim(),
      prixSortieLabel: (_breakeven || _positionEnCours)
          ? null
          : (_sortieController.text.trim().isEmpty
                ? null
                : _sortieController.text.trim()),
      screenshotPath: kIsWeb ? null : _tradeScreenshot?.path,
      screenshotBytes: kIsWeb ? _tradeScreenshotBytes : null,
      net: net,
      fee: fee,
      performanceLite: performanceLite,
      tradeMindset: tradeMindset,
      strategieTitle: _strategieChoisie,
      planSelected: _planAnalyseSelectedReport,
      planStoredReports: List<AnalyseReportSnapshot>.from(
        _planAnalyseStoredReports,
      ),
      checklistRingPercent: widget.checklistController
              .hasChecklistCheckedOnDay(entryDay)
          ? widget.checklistController.completionPercentOnDay(entryDay)
          : 0,
      mentalRingScore: mentalHistorical ?? 0,
      strategieRespectPct: _strategieRespectPct,
      strategieNonRespectIds: Set<String>.from(_strategieNonRespectIds),
      planNonRespectIds: Set<String>.from(_planAnalyseNonRespectIds),
      checklistNonRespectIds: Set<String>.from(_checklistNonRespectIds),
      etatNonRespectIds: Set<String>.from(_etatMomentNonRespectIds),
      checklistLinkedExplicit:
          widget.checklistController.hasChecklistCheckedOnDay(entryDay) ||
          _checklistNonRespectIds.isNotEmpty,
      etatLinkedExplicit:
          mentalHistorical != null || _etatMomentNonRespectIds.isNotEmpty,
      psychTags: List<String>.from(_psychTagSelected),
      accountEntitlement: widget.accountEntitlement,
      linkedAnalyseReport: _tradeLinkedAnalyseReport,
      linkedAnalysePdfBytes: _tradeLinkedAnalysePdfBytes,
      linkedAnalysePdfFileName: _tradeLinkedAnalysePdfFileName,
      userNote: _normalizeTradeUserNote(_tradeNoteController.text),
    );
  }

  TradeMindset _mapMindsetFromCapture(String tradeMindset) {
    return switch (tradeMindset) {
      'feeling' => TradeMindset.feeling,
      'principe' => TradeMindset.principe,
      _ => TradeMindset.none,
    };
  }

  TradeSide _mapSideFromCapture(AjouterTradeSide side) {
    return side == AjouterTradeSide.long ? TradeSide.achat : TradeSide.vente;
  }

  TradeListItem _buildTradeItemFromCapture(
    _TradeSaveCapture c, {
    required List<AnalyseReportSnapshot> storedReports,
  }) {
    final planReport = c.planSelected == null
        ? null
        : (findStoredAnalyseReportMatch(c.planSelected, storedReports) ??
              c.planSelected);
    final discipline = disciplinePctForSave(storedReports: storedReports);
    final planLinkedExplicit = planReport != null ||
        (c.linkedAnalysePdfBytes != null && c.linkedAnalysePdfBytes!.isNotEmpty);
    const strategieLinkedExplicit = true;
    final savedPlanPct =
        planReport != null ? discipline.planPct : 0.0;
    final id =
        c.editingTradeId ?? DateTime.now().microsecondsSinceEpoch.toString();
    final net = c.net;
    final amountLabel =
        '${net >= 0 ? '+' : ''}${net.toStringAsFixed(2).replaceAll('.', ',')}\$';
    final dateLine = DateFormat(
      "dd MMMM yyyy '•' HH:mm",
      c.localeTag,
    ).format(c.entreeAt.toLocal());

    return TradeListItem(
      id: id,
      pair: c.actif,
      side: _mapSideFromCapture(c.side),
      amountLabel: amountLabel,
      gainAmount: net,
      commissionAmount: c.fee,
      dateLine: dateLine,
      entreeAt: c.entreeAt,
      sortieAt: c.sortieAt,
      breakeven: c.breakeven,
      avantNews: c.avantNews,
      apresNews: c.apresNews,
      quantiteLabel: c.quantiteLabel,
      screenshotPath: c.screenshotPath,
      screenshotBytes: c.screenshotBytes,
      prixEntreeLabel: c.prixEntreeLabel,
      prixSortieLabel: c.prixSortieLabel,
      checklistPct:
          c.checklistLinkedExplicit ? c.checklistRingPercent.toDouble() : 0,
      planPct: savedPlanPct,
      strategiePct: discipline.strategiePct,
      etatPct: c.etatLinkedExplicit ? c.mentalRingScore : 0,
      mindset: _mapMindsetFromCapture(c.tradeMindset),
      mindsetExplicit: c.tradeMindset != 'none',
      planLinkedExplicit: planLinkedExplicit,
      strategieLinkedExplicit: strategieLinkedExplicit,
      checklistLinkedExplicit: c.checklistLinkedExplicit,
      etatLinkedExplicit: c.etatLinkedExplicit,
      strategieTitle: c.strategieTitle,
      planReport: planReport,
      linkedAnalyseReport:
          (c.linkedAnalysePdfBytes != null && c.linkedAnalysePdfBytes!.isNotEmpty)
          ? c.linkedAnalyseReport
          : null,
      linkedAnalysePdfBytes: c.linkedAnalysePdfBytes,
      linkedAnalysePdfFileName: c.linkedAnalysePdfFileName,
      strategieNonRespectIds: Set<String>.from(c.strategieNonRespectIds),
      planNonRespectIds: Set<String>.from(c.planNonRespectIds),
      checklistNonRespectIds: Set<String>.from(c.checklistNonRespectIds),
      etatNonRespectIds: Set<String>.from(c.etatNonRespectIds),
      isProfit: net >= 0,
      assetClass: c.assetClass,
      performanceLite: c.performanceLite,
      portfolioId: c.portfolioId,
      psychTags: List<String>.from(c.psychTags),
      userNote: c.userNote,
      syncRev: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// `true` si le trade a bien été enregistré.
  Future<bool> _saveTradeToJournal(BuildContext context) async {
    final capture = _captureTradeSavePayload(context);
    if (capture == null) return false;

    final storedReports = await AnalyseReportsStorage.loadAll();
    final item = _buildTradeItemFromCapture(
      capture,
      storedReports: storedReports,
    );
    final planReport = item.planReport;

    final isEdit = capture.editingTradeId != null;
    if (isEdit) {
      capture.store.update(item);
      if (mounted) {
        setState(() {
          _editingTradeId = null;
          _editingPortfolioId = null;
        });
      }
    } else {
      final ent = capture.accountEntitlement;
      final isPro = ent?.isPro == true;
      final inFullTrial = ent?.trialActive == true;
      if (!isPro &&
          !inFullTrial &&
          !TradeLiteMonthlyLimit.canAddNonPro(capture.store.items, delta: 1)) {
        if (context.mounted) {
          final l = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l.ajouterTradeLiteMonthlyLimitReached(
                  TradeLiteMonthlyLimit.maxTradesPerCalendarMonthNonPro,
                ),
              ),
            ),
          );
        }
        return false;
      }
      capture.store.add(item);
    }

    if (mounted) {
      setState(() {
        _planAnalyseStoredReports = storedReports;
        if (planReport != null) {
          _planAnalyseSelectedReport = planReport;
        }
        _strategieNonRespectIds = {};
        _planAnalyseNonRespectIds = {};
        _checklistNonRespectIds = {};
        _etatMomentNonRespectIds = {};
        _feedbackUiEpoch++;
      });
    }
    return true;
  }

  void _applyFavoriteActifForClass(AjouterTradeAssetClass c) {
    final opts = ajouterTradeActifsPour(
      c,
      locale: Localizations.localeOf(context),
    );
    final fav = _favoriteActifByMarche[c];
    if (fav != null && opts.contains(fav)) {
      _actif = fav;
    } else if (!opts.contains(_actif)) {
      _actif = opts.first;
    }
  }
}
