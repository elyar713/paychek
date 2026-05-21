// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

extension _AjouterTradePageStateEdit on _AjouterTradePageState {
  void _onEditTradeChanged() {
    final t = widget.editTrade?.value;
    if (!mounted || t == null) return;
    _applyEditTrade(t);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.editTrade?.value?.id == t.id) {
        widget.editTrade?.value = null;
      }
    });
  }

  void _applyEditTrade(TradeListItem t) {
    setState(() {
      _editingTradeId = t.id;
      _editingPortfolioId = t.portfolioId;

      _assetClass = t.assetClass ?? AjouterTradeAssetClass.forex;
      _actif = t.pair;
      _side = t.side == TradeSide.achat
          ? AjouterTradeSide.long
          : AjouterTradeSide.short;

      _entreeDateTime = t.entreeAt;
      _sortieDateTime = t.sortieAt ?? DateTime.now();
      _breakeven = t.breakeven;
      _positionEnCours = t.sortieAt == null;
      _avantNews = t.avantNews;
      _apresNews = t.apresNews;

      _quantiteController.text = (t.quantiteLabel ?? '');
      _entreeController.text = (t.prixEntreeLabel ?? '');
      _sortieController.text = (t.prixSortieLabel ?? '');

      _strategieRespectPct = t.strategiePct;

      _strategieChoisie = t.strategieTitle;
      _planAnalyseSelectedReport =
          t.planReport ??
          _draftDefaultPlanAnalyseSnapshot(Localizations.localeOf(context));

      _strategieNonRespectIds = Set<String>.from(t.strategieNonRespectIds);
      _planAnalyseNonRespectIds = Set<String>.from(t.planNonRespectIds);
      _checklistNonRespectIds = Set<String>.from(t.checklistNonRespectIds);
      _etatMomentNonRespectIds = Set<String>.from(t.etatNonRespectIds);

      if (t.mindset == TradeMindset.none ||
          t.performanceLite ||
          !t.mindsetExplicit) {
        _tradeMindset = 'none';
      } else {
        _tradeMindset = t.mindset == TradeMindset.feeling
            ? 'feeling'
            : 'principe';
      }
      _authorizeDisciplineWhenFeeling = true;

      _prixPositionController.clear();
      _commissionFeeController.text = t.commissionAmount <= 0
          ? ''
          : t.commissionAmount.toStringAsFixed(2).replaceAll('.', ',');
      _tradeScreenshot =
          (t.screenshotPath == null || t.screenshotPath!.trim().isEmpty)
          ? null
          : XFile(t.screenshotPath!);
      _tradeScreenshotBytes = t.screenshotBytes;

      _tradeLinkedAnalyseReport = t.linkedAnalyseReport;
      _tradeLinkedAnalysePdfBytes = t.linkedAnalysePdfBytes;
      _tradeLinkedAnalysePdfFileName = t.linkedAnalysePdfFileName;
      _tradeLinkedAnalysePdfGenerating = false;

      _tradeNoteController.text = t.userNote ?? '';

      final blind = AppLocalizations.of(context)!.ajouterTradePsychTagBlind;
      final basePreset = ['FOMO', 'TILT', 'Revenge', blind];
      _psychTagLabels = List<String>.from(basePreset);
      for (final tag in t.psychTags) {
        if (!_psychTagLabels.contains(tag)) {
          _psychTagLabels = List<String>.from(_psychTagLabels)..add(tag);
        }
      }
      _psychTagSelected
        ..clear()
        ..addAll(t.psychTags);

      if (t.performanceLite) {
        _perfLiteBaselineNet = t.gainAmount;
        _perfLiteBaselineCommission = t.commissionAmount;
        _perfLiteEditQty = t.quantiteLabel ?? '';
        _perfLiteEditEntree = t.prixEntreeLabel ?? '';
        _perfLiteEditSortie = t.prixSortieLabel ?? '';
        _perfLiteEditBreakeven = t.breakeven;
        _perfLiteEditPositionEnCours = t.sortieAt == null;
        _perfLiteEditPair = t.pair;
        _perfLiteEditAssetClass = t.assetClass ?? AjouterTradeAssetClass.forex;
        _perfLiteEditSide = t.side == TradeSide.achat
            ? AjouterTradeSide.long
            : AjouterTradeSide.short;
      } else {
        _clearPerfLitePreserve();
      }
    });
    _applyNewsFlagsFromChecklist();
    if (t.linkedAnalyseReport != null &&
        (t.linkedAnalysePdfBytes == null || t.linkedAnalysePdfBytes!.isEmpty)) {
      unawaited(_ensureTradeLinkedAnalysePdf());
    }
    _requestGainRecalc();
  }
}