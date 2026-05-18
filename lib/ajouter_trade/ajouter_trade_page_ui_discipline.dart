// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

extension _AjouterTradePageUiDiscipline on _AjouterTradePageState {
  Widget _ajouterTradeGainMindsetColumn(
    BuildContext context,
    AppLocalizations l,
    Locale locale,
    TextStyle? labelStyle,
    TextStyle? mutedStyle,
    TextStyle? titleStyle,
    TextStyle? entreeSortieDtStyle,
    TextStyle? checkboxLabelStyle, {
    required BoxDecoration disciplineCardDec,
    required Color sectionHeaderColor,
  }) {
    return ListenableBuilder(
      listenable: _gainSectionListenable(context),
      builder: (context, _) {
        final capStore = UserCapitalScope.of(context);
        final pf = UserPortfolioScope.of(context);
        final cap = pf.effectiveCapitalAmount(capStore);
        final sym = pf.effectiveCurrencySymbol(capStore);
        final gross = _tradeGainEstimate();
        final feeRaw =
            parseAjouterTradeAmount(_commissionFeeController.text) ?? 0;
        final fee = feeRaw < 0 ? 0.0 : feeRaw;
        final gain = _resolveTradeGainForPanel(formulaGross: gross, fee: fee);
        final sortieVide = _sortieController.text.trim().isEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: DashboardTokens.cardPadding,
              decoration: disciplineCardDec,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.ajouterTradeCapitalGainHeading,
                    style:
                        (labelStyle ??
                                const TextStyle(
                                  color: DashboardTokens.onMatteEmphasis,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 0.35,
                                ))
                            .copyWith(
                              color: sectionHeaderColor,
                              fontSize: 9,
                              letterSpacing: 0.35,
                            ),
                  ),
                  const SizedBox(height: 8),
                  AjouterTradeCapitalGainPanel(
                    cap: cap,
                    sym: sym,
                    gain: gain,
                    commission: fee,
                    sortieVide: sortieVide,
                    positionEnCours: _positionEnCours,
                    breakeven: _breakeven,
                    commissionLayerLink: _commissionLayerLink,
                    onOpenCommission: () =>
                        _ajouterTradeToggleCommissionPopover(this, context),
                    titleStyle: titleStyle,
                    mutedStyle: mutedStyle,
                  ),
                ],
              ),
            ),
            _liteLockPremiumSections(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: DashboardTokens.cardPadding,
                    decoration: disciplineCardDec,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                l.ajouterTradeMindsetPrompt,
                                style: mutedStyle?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Tooltip(
                              message: l.ajouterTradeDisciplineSettingsTooltip,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                icon: Icon(
                                  Icons.settings_outlined,
                                  size: 18,
                                  color: _disciplineGearIconLooksActive()
                                      ? sectionHeaderColor
                                      : DashboardTokens.muted,
                                ),
                                onPressed: () {
                                  showAjouterTradeDisciplineSettingsSheet(
                                    context: context,
                                    initial: AjouterTradeDisciplinePrefs(
                                      authorizeWhenFeeling:
                                          _authorizeDisciplineWhenFeeling,
                                      strategie: _sectionStrategieEnabled,
                                      planAnalyse: _sectionPlanEnabled,
                                      checklist: _sectionChecklistEnabled,
                                      etatMoment: _sectionEtatEnabled,
                                    ),
                                    onChanged: (p) {
                                      setState(() {
                                        _authorizeDisciplineWhenFeeling =
                                            p.authorizeWhenFeeling;
                                        _sectionStrategieEnabled = p.strategie;
                                        _sectionPlanEnabled = p.planAnalyse;
                                        _sectionChecklistEnabled = p.checklist;
                                        _sectionEtatEnabled = p.etatMoment;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: FilledButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_tradeMindset == 'principe') {
                                        _tradeMindset = 'none';
                                      } else {
                                        _tradeMindset = 'principe';
                                        _authorizeDisciplineWhenFeeling = true;
                                      }
                                    });
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _tradeMindset == 'principe'
                                        ? (kIsWeb
                                              ? PaychekWebTokens.accentEmerald
                                              : DashboardTokens.accent)
                                        : DashboardTokens.cardBoxBorder,
                                    foregroundColor:
                                        DashboardTokens.onMatteEmphasis,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l.tradeMindsetPrinciple,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: FilledButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_tradeMindset == 'feeling') {
                                        _tradeMindset = 'none';
                                        _authorizeDisciplineWhenFeeling = true;
                                      } else {
                                        _tradeMindset = 'feeling';
                                        _authorizeDisciplineWhenFeeling = false;
                                      }
                                    });
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _tradeMindset == 'feeling'
                                        ? DashboardTokens.negative
                                        : DashboardTokens.cardBoxBorder,
                                    foregroundColor:
                                        DashboardTokens.onMatteEmphasis,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.psychology_alt_rounded,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l.tradeMindsetFeeling,
                                        style: const TextStyle(
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
                        ),
                        ListenableBuilder(
                          listenable: Listenable.merge([
                            widget.checklistController,
                            MentalStateController.instance,
                          ]),
                          builder: (context, _) {
                            return AjouterTradeDisciplineMindsetSummary(
                              checklistPercent: _checklistRingPercent,
                              mentalScore: _mentalRingScore,
                              sectionHeaderColor: sectionHeaderColor,
                            );
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: ajouterTradeDisciplineSectionsWithSeparators([
                            if (_sectionStrategieEnabled)
                              _wrapDisciplineBlock(
                                _gateStrategie,
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AjouterTradeStrategieSection(
                                      labelStyle: labelStyle,
                                      strategieRespectPct: _strategieRespectPct,
                                      onStrategieRespectPctChanged: (v) =>
                                          setState(() => _strategieRespectPct = v),
                                      strategiePicker: Builder(
                                        builder: (ctx) {
                                          final setups = StrategieSetupsStore
                                              .notifier
                                              .value;
                                          final titres = setups
                                              .map((e) => e.title)
                                              .toList();
                                          if (setups.isEmpty) {
                                            return const SizedBox.shrink();
                                          }
                                          if (!titres.contains(
                                            _strategieChoisie,
                                          )) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                                  if (!mounted) return;
                                                  setState(
                                                    () => _strategieChoisie =
                                                        titres.first,
                                                  );
                                                });
                                          }
                                          final value =
                                              titres.contains(_strategieChoisie)
                                              ? _strategieChoisie
                                              : titres.first;
                                          final selected = setups
                                              .where((e) => e.title == value)
                                              .toList();
                                          final dotColor = selected.isNotEmpty
                                              ? selected.first.dotColor
                                              : DashboardTokens.accent;
                                          return CompositedTransformTarget(
                                            link: _strategieLayerLink,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () =>
                                                    _ajouterTradeToggleStrategieMenu(
                                                      this,
                                                      ctx,
                                                      setups,
                                                    ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  key: _strategieFieldKey,
                                                  height: 36,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: DashboardTokens
                                                        .scaffoldMatte,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    border: Border.all(
                                                      color: DashboardTokens
                                                          .cardBoxBorder,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 9,
                                                        height: 9,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: dotColor,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Text(
                                                          value,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                            color: DashboardTokens
                                                                .onMatteEmphasis,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.expand_more,
                                                        size: 20,
                                                        color: DashboardTokens
                                                            .labelGrey,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      feedbackMenu:
                                          AjouterTradeStrategieFeedbackMenu(
                                            key: ValueKey<int>(
                                              _feedbackUiEpoch,
                                            ),
                                            strategieRespectPercent:
                                                _strategieRespectPct,
                                            strategieTitle: _strategieChoisie,
                                            onNonRespectSelectionChanged:
                                                (ids) {
                                                  setState(() {
                                                    _strategieNonRespectIds =
                                                        Set<String>.from(ids);
                                                  });
                                                },
                                          ),
                                    ),
                                    AjouterTradeNonRespectChoixList(
                                      ids: _strategieNonRespectIds,
                                      strategieChoisie: _strategieChoisie,
                                      mutedStyle: mutedStyle,
                                    ),
                                    AjouterTradeDisciplineRespectLine(
                                      respectPercent: _strategieRespectPct,
                                      nonRespectIds: _strategieNonRespectIds,
                                      labelForId: (id) =>
                                          labelForStrategieNonRespectId(
                                            id,
                                            _strategieChoisie,
                                            l: l,
                                            locale: locale,
                                          ),
                                      mutedStyle: mutedStyle,
                                    ),
                                  ],
                                ),
                              ),
                            if (_sectionPlanEnabled)
                              _wrapDisciplineBlock(
                                _gatePlan,
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AjouterTradePlanAnalyseSection(
                                      labelStyle: labelStyle,
                                      planPickerTop:
                                          AjouterTradePlanAnalyseMenu(
                                            showDemoReports: true,
                                            selectedSnapshot:
                                                _planAnalyseSelectedReport,
                                            onSelectedSnapshotChanged: (s) {
                                              setState(() {
                                                _planAnalyseSelectedReport = s;
                                                _planAnalyseNonRespectIds = {};
                                              });
                                            },
                                            onReportsLoaded:
                                                _onPlanAnalyseReportsLoaded,
                                          ),
                                      planPickerBottom:
                                          AjouterTradePlanAnalyseFeedbackMenu(
                                            key: ValueKey<int>(
                                              _feedbackUiEpoch,
                                            ),
                                            planRespectPercent: _planPctForFeedback,
                                            selectedReport:
                                                _planAnalyseSelectedReport,
                                            onNonRespectSelectionChanged:
                                                (ids) {
                                                  setState(() {
                                                    _planAnalyseNonRespectIds =
                                                        Set<String>.from(ids);
                                                  });
                                                },
                                          ),
                                    ),
                                    AjouterTradeNonRespectGenericList(
                                      ids: _planAnalyseNonRespectIds,
                                      mutedStyle: mutedStyle,
                                      labelForId: (id) {
                                        final s = _planAnalyseSelectedReport;
                                        if (s == null) return id;
                                        final entries =
                                            planAnalyseFeedbackEntriesFor(s, l);
                                        for (final e in entries) {
                                          if (e is PlanAnalyseFeedbackRow &&
                                              e.id == id) {
                                            final v = (e.hint ?? '').trim();
                                            return v.isEmpty
                                                ? e.label
                                                : '${e.label} : $v';
                                          }
                                        }
                                        return id;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            if (_sectionChecklistEnabled)
                              _wrapDisciplineBlock(
                                _gateChecklist,
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      l.dashboardChecklistHeading,
                                      style:
                                          (labelStyle ??
                                                  const TextStyle(
                                                    color: DashboardTokens
                                                        .onMatteEmphasis,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 10,
                                                    letterSpacing: 0.35,
                                                  ))
                                              .copyWith(
                                                color: sectionHeaderColor,
                                                fontSize: 9,
                                                letterSpacing: 0.35,
                                              ),
                                    ),
                                    const SizedBox(height: 6),
                                    AjouterTradeChecklistFeedbackMenu(
                                      key: ValueKey<int>(_feedbackUiEpoch),
                                      checklistRespectPercent:
                                          _checklistPctForFeedback,
                                      controller: widget.checklistController,
                                      onNonRespectSelectionChanged: (ids) {
                                        setState(() {
                                          _checklistNonRespectIds =
                                              Set<String>.from(ids);
                                        });
                                      },
                                    ),
                                    AjouterTradeNonRespectGenericList(
                                      ids: _checklistNonRespectIds,
                                      mutedStyle: mutedStyle,
                                      labelForId: (id) {
                                        final parts = id.split(':');
                                        if (parts.length != 2) return id;
                                        final sectionId = parts[0];
                                        final itemId = parts[1];
                                        for (final s
                                            in widget
                                                .checklistController
                                                .sections) {
                                          if (s.id != sectionId) continue;
                                          for (final it in s.items) {
                                            if (it.id == itemId) {
                                              return it.label;
                                            }
                                          }
                                        }
                                        return id;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            if (_sectionEtatEnabled)
                              _wrapDisciplineBlock(
                                _gateEtat,
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      l.ajouterTradeSectionEtatMoment,
                                      style:
                                          (labelStyle ??
                                                  const TextStyle(
                                                    color: DashboardTokens
                                                        .onMatteEmphasis,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 10,
                                                    letterSpacing: 0.35,
                                                  ))
                                              .copyWith(
                                                color: sectionHeaderColor,
                                                fontSize: 9,
                                                letterSpacing: 0.35,
                                              ),
                                    ),
                                    const SizedBox(height: 6),
                                    AjouterTradeEtatMomentFeedbackMenu(
                                      key: ValueKey<int>(_feedbackUiEpoch),
                                      etatMomentPercent: _etatPctForFeedback,
                                      controller:
                                          MentalStateController.instance,
                                      onNonRespectSelectionChanged: (ids) {
                                        setState(() {
                                          _etatMomentNonRespectIds =
                                              Set<String>.from(ids);
                                        });
                                      },
                                    ),
                                    AjouterTradeNonRespectGenericList(
                                      ids: _etatMomentNonRespectIds,
                                      mutedStyle: mutedStyle,
                                      labelForId: (id) {
                                        final parts = id.split(':');
                                        if (parts.length != 2) return id;
                                        final kind = parts[0];
                                        final key = parts[1];
                                        final c =
                                            MentalStateController.instance;
                                        if (kind == 'moment') {
                                          for (final m in c.moment) {
                                            if (m.id == key) return m.label;
                                          }
                                        }
                                        if (kind == 'emotion') {
                                          for (final e in c.emotions) {
                                            if (e.id == key) return e.label;
                                          }
                                        }
                                        return id;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
