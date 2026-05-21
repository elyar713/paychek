// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

extension _AjouterTradePageStateDialogs on _AjouterTradePageState {
  Future<void> _openAddCustomActifDialog() async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    var cls = _assetClass;

    final result = await showDialog<({AjouterTradeAssetClass cls, String symbol})>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setM) {
            return Dialog(
              backgroundColor: const Color(0xFF0A0A0A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF222222)),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              size: 16,
                              color: DashboardTokens.accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${l.actionAdd} ${l.ajouterTradeFieldActif}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: '',
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Color(0xFF555555),
                              ),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.labelMarket,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<AjouterTradeAssetClass>(
                          key: ValueKey(cls),
                          initialValue: cls,
                          dropdownColor: const Color(0xFF111111),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF111111),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF222222)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: DashboardTokens.accent.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          items: [
                            for (final c in AjouterTradeAssetClass.values)
                              DropdownMenuItem(
                                value: c,
                                child: Text(c.name.toUpperCase()),
                              ),
                          ],
                          onChanged: (v) => setM(() => cls = v ?? cls),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l.ajouterTradeFieldActif,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'USD/MXN',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF666666),
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF111111),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF222222)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: DashboardTokens.accent.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, color: Color(0xFF1A1A1A)),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  final sym = controller.text.trim().toUpperCase();
                                  if (sym.isEmpty) return;
                                  Navigator.pop(ctx, (cls: cls, symbol: sym));
                                },
                                child: Text(l.actionAdd),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF888888),
                                  side: const BorderSide(color: Color(0xFF333333)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(l.cancel),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;
    await AjouterTradeCustomActifsStorage.add(result.cls, result.symbol);
    if (!mounted) return;

    // Si l'utilisateur ajoute dans le marché courant, on sélectionne l'actif direct.
    if (result.cls == _assetClass) {
      setState(() => _actif = result.symbol);
      _requestGainRecalc();
    } else {
      setState(() {});
    }
  }

  void _resetForNextTrade() {
    _ajouterTradeCloseStrategieMenu(this);
    _ajouterTradeCloseCommission(this);
    _ajouterTradeCloseTradeDateTimeOverlay(this);

    setState(() {
      _editingTradeId = null;
      _editingPortfolioId = null;
      _side = AjouterTradeSide.long;
      _assetClass = AjouterTradeAssetClass.forex;
      final opts = ajouterTradeActifsPour(
        _assetClass,
        locale: Localizations.localeOf(context),
      );
      final fav = _favoriteActifByMarche[_assetClass];
      _actif = (fav != null && opts.contains(fav)) ? fav : opts.first;

      _quantiteController.clear();
      _prixPositionController.clear();
      _entreeController.clear();
      _sortieController.clear();
      _commissionFeeController.clear();

      _entreeDateTime = DateTime.now();
      _sortieDateTime = DateTime.now();
      _breakeven = false;
      _positionEnCours = false;
      _avantNews = false;
      _apresNews = false;

      _strategieRespectPct = 50;

      _strategieChoisie = strategieSetupDefaultCardDataList().first.title;
      _strategieNonRespectIds = {};
      _planAnalyseSelectedReport = _draftDefaultPlanAnalyseSnapshot(
        Localizations.localeOf(context),
      );
      _planAnalyseNonRespectIds = {};
      _checklistNonRespectIds = {};
      _etatMomentNonRespectIds = {};

      _tradeMindset = 'none';
      _authorizeDisciplineWhenFeeling = false;

      _psychTagSelected.clear();
      _psychTagInputVisible = false;
      _psychTagNewController.clear();

      _tradeScreenshot = null;
      _tradeScreenshotBytes = null;
      _tradeLinkedAnalyseReport = null;
      _tradeLinkedAnalysePdfBytes = null;
      _tradeLinkedAnalysePdfFileName = null;
      _tradeLinkedAnalysePdfGenerating = false;
      _tradeNoteController.clear();
      _selectedCsvSoftware = null;
      _lastImportedFileName = null;
      _clearPerfLitePreserve();
    });

    _refreshPlanAnalyseFromStorage();

    _requestGainRecalc();
  }
}