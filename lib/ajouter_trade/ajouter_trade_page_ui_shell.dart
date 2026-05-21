// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

extension _AjouterTradePageUi on _AjouterTradePageState {
  Widget buildAjouterTradePageContent(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: DashboardTokens.onMatteEmphasis,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        );
    final mutedStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: DashboardTokens.muted,
          height: 1.45,
          fontSize: 13,
        );
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: DashboardTokens.labelGrey,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 0.35,
        );
    final entreeSortieDtStyle =
        Theme.of(context).textTheme.labelSmall?.copyWith(
              color: DashboardTokens.muted,
              fontWeight: FontWeight.w500,
              fontSize: 9.5,
              height: 1.2,
            );
    final checkboxLabelStyle =
        Theme.of(context).textTheme.labelSmall?.copyWith(
              color: DashboardTokens.labelGrey,
              fontWeight: FontWeight.w600,
              fontSize: 9.5,
              height: 1.15,
            );

    Widget liteLockDisciplineExtras(Widget child) {
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

    final webDisciplineCardDec = kIsWeb
        ? PaychekWebTokens.shellCardDecoration()
        : DashboardTokens.cardBoxDecoration();
    final webSectionLabelColor = kIsWeb
        ? PaychekWebTokens.sectionLabelCopper
        : DashboardTokens.titleGold;

    Widget buildDirectionBar() {
      return AjouterTradeDirectionBar(
        side: _side,
        longColor: kIsWeb
            ? PaychekWebTokens.accentEmerald
            : _AjouterTradePageState._longFill,
        shortColor: _AjouterTradePageState._shortFill,
        onLong: () {
          setState(() => _side = AjouterTradeSide.long);
          _requestGainRecalc();
        },
        onShort: () {
          setState(() => _side = AjouterTradeSide.short);
          _requestGainRecalc();
        },
      );
    }

    Widget buildInstrumentCard() {
      return AjouterTradeInstrumentCard(
        assetClass: _assetClass,
        actif: _actif,
        quantiteController: _quantiteController,
        prixPositionController: _prixPositionController,
        entreeController: _entreeController,
        sortieController: _sortieController,
        entreeDateTime: _entreeDateTime,
        sortieDateTime: _sortieDateTime,
        breakeven: _breakeven,
        positionEnCours: _positionEnCours,
        avantNews: _avantNews,
        apresNews: _apresNews,
        labelStyle: labelStyle,
        entreeSortieDtStyle: entreeSortieDtStyle,
        checkboxLabelStyle: checkboxLabelStyle,
        onMarcheChanged: (v) {
          setState(() {
            _assetClass = v;
            _applyFavoriteActifForClass(v);
            _clearPerfLitePreserve();
          });
          _requestGainRecalc();
        },
        persistedFavoriteActif: _favoriteActifByMarche[_assetClass],
        onPersistFavoriteToggle: (symbol, {required add}) {
          setState(() {
            if (add) {
              _favoriteActifByMarche[_assetClass] = symbol;
            } else {
              _favoriteActifByMarche.remove(_assetClass);
            }
          });
          if (add) {
            AjouterTradeFavoriteActifStorage.save(
              _assetClass,
              symbol,
            );
          } else {
            AjouterTradeFavoriteActifStorage.clear(_assetClass);
          }
        },
        onActifChanged: (v) => setState(() {
          _actif = v;
          _clearPerfLitePreserve();
        }),
        onBreakevenChanged: (v) {
          setState(() {
            _breakeven = v;
            if (v) {
              _positionEnCours = false;
              _sortieController.clear();
            }
          });
          _requestGainRecalc();
        },
        onPositionEnCoursChanged: (v) {
          setState(() {
            _positionEnCours = v;
            if (v) {
              _breakeven = false;
              _sortieController.clear();
            }
          });
          _requestGainRecalc();
        },
        onAvantNewsChanged: (v) => setState(() => _avantNews = v),
        onApresNewsChanged: (v) => setState(() => _apresNews = v),
        requestGainRecalc: _requestGainRecalc,
        onOpenAddCustomActif: _openAddCustomActifDialog,
        entreeDateLayerLink: _entreeDateLayerLink,
        sortieDateLayerLink: _sortieDateLayerLink,
        entreeDateRowKey: _entreeDateRowKey,
        sortieDateRowKey: _sortieDateRowKey,
        entreeDatePickerOpen: _tradeDateTimeOverlay != null &&
            _tradeDateTimeOverlayForEntree == true,
        sortieDatePickerOpen: _tradeDateTimeOverlay != null &&
            _tradeDateTimeOverlayForEntree == false,
        onEntreeDateTimeTap: () => _ajouterTradeToggleTradeDateTimeOverlay(
              this,
              context,
              entree: true,
            ),
        onSortieDateTimeTap: () => _ajouterTradeToggleTradeDateTimeOverlay(
              this,
              context,
              entree: false,
            ),
        cardDecoration:
            kIsWeb ? PaychekWebTokens.shellCardDecoration() : null,
      );
    }

    final psychCard = AjouterTradePsychTagsCard(
      labels: _psychTagLabels,
      selected: _psychTagSelected,
      onToggle: _togglePsychTag,
      onRemoveTag: _removePsychTag,
      showNewTagField: _psychTagInputVisible,
      newTagController: _psychTagNewController,
      newTagFocus: _psychTagNewFocus,
      onNewTagSubmitted: _commitNewPsychTag,
      onPlusTap: _onPsychTagPlusTap,
      titleStyle: titleStyle,
      cardDecoration: kIsWeb ? PaychekWebTokens.shellCardDecoration() : null,
      sectionTitleColor: kIsWeb ? PaychekWebTokens.sectionLabelCopper : null,
    );

    final screenshotCard = AjouterTradeScreenshotSection(
      file: _tradeScreenshot,
      bytes: _tradeScreenshotBytes,
      labelStyle: labelStyle,
      mutedStyle: mutedStyle,
      onPick: () {
        _pickTradeScreenshot();
      },
      onRemove: () => setState(() {
        _tradeScreenshot = null;
        _tradeScreenshotBytes = null;
      }),
      cardDecoration: kIsWeb ? PaychekWebTokens.shellCardDecoration() : null,
      sectionTitleColor: kIsWeb ? PaychekWebTokens.sectionLabelCopper : null,
    );
    final csvCard = AjouterTradeCsvSection(
      labelStyle: labelStyle,
      mutedStyle: mutedStyle,
      selectedSource: _selectedCsvSoftware,
      options: _AjouterTradePageState._csvSoftwareOptions,
      onSourceChanged: (value) {
        setState(() => _selectedCsvSoftware = value);
      },
      onImportTap: () => _importFromSelectedCsvSource(context),
      importedFileName: _lastImportedFileName,
      cardDecoration: kIsWeb ? PaychekWebTokens.shellCardDecoration() : null,
      sectionTitleColor: kIsWeb ? PaychekWebTokens.sectionLabelCopper : null,
    );
    final analyseCard = AjouterTradeAnalyseAttachmentCard(
      labelStyle: labelStyle,
      mutedStyle: mutedStyle,
      selectedReport: _tradeLinkedAnalyseReport,
      pdfFileName: _tradeLinkedAnalysePdfFileName,
      pdfGenerating: _tradeLinkedAnalysePdfGenerating,
      onReportSelected: _onTradeLinkedAnalyseSelected,
      onClear: _clearTradeLinkedAnalyse,
      compact: true,
      cardDecoration: kIsWeb ? PaychekWebTokens.shellCardDecoration() : null,
      sectionTitleColor: kIsWeb ? PaychekWebTokens.sectionLabelCopper : null,
    );

    final noteCard = AjouterTradeNoteCard(
      controller: _tradeNoteController,
      labelStyle: labelStyle,
      mutedStyle: mutedStyle,
      cardDecoration: kIsWeb ? PaychekWebTokens.shellCardDecoration() : null,
      sectionTitleColor: kIsWeb ? PaychekWebTokens.sectionLabelCopper : null,
    );

    Widget screenshotCsvAnalyseRow({double columnGap = 12}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: liteLockDisciplineExtras(screenshotCard)),
          SizedBox(width: columnGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                liteLockDisciplineExtras(csvCard),
                SizedBox(height: columnGap >= 16 ? 10 : 8),
                liteLockDisciplineExtras(analyseCard),
              ],
            ),
          ),
        ],
      );
    }

    Widget extrasBelowInstrument({double gap = 20}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          screenshotCsvAnalyseRow(
            columnGap: gap >= 20 ? 16 : 12,
          ),
          SizedBox(height: gap >= 20 ? 16 : 12),
          liteLockDisciplineExtras(noteCard),
        ],
      );
    }

    if (kIsWeb) {
      return ColoredBox(
        color: PaychekWebTokens.scaffoldBg,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AjouterTradeWebTopBar(
                onBack: widget.onBack,
                onSave: () async {
                  final ok = await _saveTradeToJournal(context);
                  if (ok && context.mounted) {
                    widget.onNavigateToTrade?.call();
                  }
                },
                onSaveAndNext: () async {
                  final ok = await _saveTradeToJournal(context);
                  if (!context.mounted) return;
                  if (ok) _resetForNextTrade();
                },
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final pad = const EdgeInsets.fromLTRB(28, 12, 28, 48);
                    final wide = c.maxWidth >= 960;
                    if (!wide) {
                      return SingleChildScrollView(
                        padding: pad,
                        child: Form(
                          canPop: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              buildDirectionBar(),
                              const SizedBox(height: 20),
                              buildInstrumentCard(),
                              const SizedBox(height: 20),
                              _ajouterTradeGainMindsetColumn(
                                context,
                                l,
                                locale,
                                labelStyle,
                                mutedStyle,
                                titleStyle,
                                entreeSortieDtStyle,
                                checkboxLabelStyle,
                                disciplineCardDec: webDisciplineCardDec,
                                sectionHeaderColor: webSectionLabelColor,
                              ),
                              const SizedBox(height: 20),
                              liteLockDisciplineExtras(psychCard),
                              const SizedBox(height: 20),
                              extrasBelowInstrument(),
                            ],
                          ),
                        ),
                      );
                    }
                    // Deux défilements verticaux séparés : avec un seul scroll, la colonne droite (discipline très
                    // longue) fixait la hauteur totale et la carte CSV à gauche disparaissait en haut de page au scroll.
                    // Contrôleurs dans un StatefulWidget séparé (hot reload ne réinitialise pas les nouveaux champs de PageState).
                    return Padding(
                      padding: pad,
                      child: Form(
                        canPop: false,
                        child: _AjouterTradeWebWideDoubleColumn(
                          leftColumn: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            buildDirectionBar(),
                            const SizedBox(height: 24),
                            buildInstrumentCard(),
                            const SizedBox(height: 24),
                            extrasBelowInstrument(gap: 24),
                          ],
                        ),
                        rightColumn: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ajouterTradeGainMindsetColumn(
                              context,
                              l,
                              locale,
                              labelStyle,
                              mutedStyle,
                              titleStyle,
                              entreeSortieDtStyle,
                              checkboxLabelStyle,
                              disciplineCardDec: webDisciplineCardDec,
                              sectionHeaderColor: webSectionLabelColor,
                            ),
                            const SizedBox(height: 24),
                            liteLockDisciplineExtras(psychCard),
                          ],
                        ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ColoredBox(
      color: DashboardTokens.scaffoldMatte,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaychekPageHeader(
              onBack: widget.onBack,
              title: l.ajouterTradePageTitle,
              subtitle: perf6(
                locale.languageCode,
                'Saisissez les détails du trade et la discipline.',
                'Enter trade details and discipline.',
                'Introduce los datos del trade y la disciplina.',
                'Trade-Details und Disziplin erfassen.',
                'Preencha os dados do trade e a disciplina.',
                '트레이드 정보와 규율을 입력하세요.',
              ),
              maxContentWidth: 1180,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  32 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      canPop: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildDirectionBar(),
                          const SizedBox(height: 20),
                          buildInstrumentCard(),
                          const SizedBox(height: 20),
                          _ajouterTradeGainMindsetColumn(
                            context,
                            l,
                            locale,
                            labelStyle,
                            mutedStyle,
                            titleStyle,
                            entreeSortieDtStyle,
                            checkboxLabelStyle,
                            disciplineCardDec: webDisciplineCardDec,
                            sectionHeaderColor: webSectionLabelColor,
                          ),
                          const SizedBox(height: 20),
                          liteLockDisciplineExtras(psychCard),
                          const SizedBox(height: 20),
                          extrasBelowInstrument(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () async {
                        final ok = await _saveTradeToJournal(context);
                        if (ok && context.mounted) {
                          widget.onNavigateToTrade?.call();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: DashboardTokens.accent,
                        foregroundColor: DashboardTokens.onMatteEmphasis,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l.save,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        final ok = await _saveTradeToJournal(context);
                        if (!context.mounted) return;
                        if (ok) _resetForNextTrade();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DashboardTokens.onMatteEmphasis,
                        side: const BorderSide(
                          color: DashboardTokens.accent,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l.ajouterTradeSaveAndNext,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
