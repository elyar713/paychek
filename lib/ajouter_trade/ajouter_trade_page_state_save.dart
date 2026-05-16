// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

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
    return null;
  }

  void _saveTradeToJournal(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final validationError = _tradeSaveValidationError(l);
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    final gross = _tradeGainEstimate();
    final feeRaw = parseAjouterTradeAmount(_commissionFeeController.text) ?? 0;
    final fee = feeRaw < 0 ? 0.0 : feeRaw;
    final net = _resolveTradeNetForSave(formulaGross: gross, fee: fee);
    final keepPerfLite =
        _perfLiteBaselineNet != null && _perfLiteImportInputsUnchanged();
    /// Dès qu’un mindset explicite est choisi, on sort du mode « lite » pour Performance / Lens.
    final performanceLite = keepPerfLite && _tradeMindset == 'none';

    final store = TradeJournalScope.of(context);
    final portfolioId =
        _editingPortfolioId ?? UserPortfolioScope.of(context).activePortfolioId;
    final id =
        _editingTradeId ?? DateTime.now().microsecondsSinceEpoch.toString();
    final syncRev = DateTime.now().millisecondsSinceEpoch;
    final amountLabel =
        '${net >= 0 ? '+' : ''}${net.toStringAsFixed(2).replaceAll('.', ',')}\$';

    final item = TradeListItem(
      id: id,
      pair: _actif,
      side: _mapSide(),
      amountLabel: amountLabel,
      gainAmount: net,
      commissionAmount: fee,
      dateLine: _formatTradeDateLine(_entreeDateTime),
      entreeAt: _entreeDateTime,
      sortieAt: _positionEnCours ? null : _sortieDateTime,
      breakeven: _breakeven,
      avantNews: _avantNews,
      apresNews: _apresNews,
      quantiteLabel: _quantiteController.text.trim().isEmpty
          ? null
          : _quantiteController.text.trim(),
      screenshotPath: kIsWeb ? null : _tradeScreenshot?.path,
      screenshotBytes: kIsWeb ? _tradeScreenshotBytes : null,
      prixEntreeLabel: _entreeController.text.trim().isEmpty
          ? null
          : _entreeController.text.trim(),
      prixSortieLabel: (_breakeven || _positionEnCours)
          ? null
          : (_sortieController.text.trim().isEmpty
                ? null
                : _sortieController.text.trim()),
      checklistPct: _checklistRespectPct,
      planPct: _planRespectPct,
      strategiePct: _strategieRespectPct,
      etatPct: _etatMomentPct,
      mindset: _mapMindset(),
      strategieTitle: _strategieChoisie,
      planReport: _planAnalyseSelectedReport,
      strategieNonRespectIds: Set<String>.from(_strategieNonRespectIds),
      planNonRespectIds: Set<String>.from(_planAnalyseNonRespectIds),
      checklistNonRespectIds: Set<String>.from(_checklistNonRespectIds),
      etatNonRespectIds: Set<String>.from(_etatMomentNonRespectIds),
      isProfit: net >= 0,
      assetClass: _assetClass,
      // Reste « lite » tant que l’import est intact et aucun mindset n’a été choisi.
      performanceLite: performanceLite,
      portfolioId: portfolioId,
      psychTags: List<String>.from(_psychTagSelected),
      syncRev: syncRev,
    );

    final isEdit = _editingTradeId != null;
    if (isEdit) {
      store.update(item);
      setState(() {
        _editingTradeId = null;
        _editingPortfolioId = null;
      });
    } else {
      final ent = widget.accountEntitlement;
      final isPro = ent?.isPro == true;
      final inFullTrial = ent?.trialActive == true;
      if (!isPro &&
          !inFullTrial &&
          !TradeLiteMonthlyLimit.canAddNonPro(store.items, delta: 1)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.ajouterTradeLiteMonthlyLimitReached(
                TradeLiteMonthlyLimit.maxTradesPerCalendarMonthNonPro,
              ),
            ),
          ),
        );
        return;
      }
      store.add(item);
    }

    setState(() {
      _strategieNonRespectIds = {};
      _planAnalyseNonRespectIds = {};
      _checklistNonRespectIds = {};
      _etatMomentNonRespectIds = {};
      _feedbackUiEpoch++;
    });
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