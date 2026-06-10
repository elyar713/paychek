part of 'analyse_oled_plan_ui.dart';

class AnalyseOledMtfSection extends StatefulWidget {
  const AnalyseOledMtfSection({super.key, required this.controller});

  final AnalyseController controller;

  @override
  State<AnalyseOledMtfSection> createState() => _AnalyseOledMtfSectionState();
}

class _AnalyseOledMtfSectionState extends State<AnalyseOledMtfSection> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
        return AnalyseOledStepShell(
          title: l.analyseOledSectionKeyZonesSmc,
          topAccent: AnalyseTokens.oledIndigo,
          watermarkIcon: LucideIcons.layers,
          watermarkColor: AnalyseTokens.oledIndigo,
          timeframeValue: c.structureTf,
          timeframeOptions: analyseStructureTfOptions(c),
          onTimeframeChanged: (v) => applyAnalyseStructureTfChange(c, v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              oledSectionTitleRow(
                l.analyseOledKeyZoneToggle,
                enabled: c.structureEnabled,
                onEnabledChanged: (v) => c.structureEnabled = v,
              ),
              if (c.structureEnabled) ...[
                _oledConfidenceSlider(
                  confidence: c.confidenceStructure,
                  onConfidenceChanged: (v) => c.confidenceStructure = v,
                  impactPercent: c.impactStructureDisplay,
                  onImpactTap: () {
                    final f = c.impactFeuille;
                    final s = c.impactStructure;
                    final i = c.impactIndicators;
                    final m = c.impactSmc;
                    showAnalyseImpactModal(
                      context,
                      label: l.analyseImpactShort,
                      initialImpact: s,
                      onApply: (w) => c.impactStructure = w,
                      onCancelRestore: () => c.restoreImpactsSnapshot(f, s, i, m),
                    );
                  },
                ),
                const SizedBox(height: 12),
                oledFieldLabel(l.analyseReportOledFieldChartism),
                oledDeepInput(
                  value: c.structureDernierPoint,
                  hint: l.analyseOledStructureChartHint,
                  onChanged: (v) => c.structureDernierPoint = v,
                ),
                const SizedBox(height: 12),
                _srLevelPanel(
                  title: l.analyseOledSupportsUpper,
                  levelHint: l.analyseOledLevelHint,
                  titleColor: AnalyseTokens.oledGreen,
                  value: c.structureSupportMaj,
                  onChanged: (v) => c.structureSupportMaj = v,
                  extras: c.extraSupports,
                  onExtraChanged: c.updateExtraSupport,
                  onRemoveExtra: c.removeExtraSupport,
                  onAdd: () => c.addExtraSupport(AnalyseStructureExtraLevel()),
                  accent: AnalyseTokens.oledGreen,
                ),
                const SizedBox(height: 12),
                _srLevelPanel(
                  title: l.analyseOledResistancesUpper,
                  levelHint: l.analyseOledLevelHint,
                  titleColor: AnalyseTokens.oledRed,
                  value: c.structureResistanceMaj,
                  onChanged: (v) => c.structureResistanceMaj = v,
                  extras: c.extraResistances,
                  onExtraChanged: c.updateExtraResistance,
                  onRemoveExtra: c.removeExtraResistance,
                  onAdd: () => c.addExtraResistance(AnalyseStructureExtraLevel()),
                  accent: AnalyseTokens.oledRed,
                ),
              ],
              const SizedBox(height: 24),
              oledSectionTitleRow(
                l.analyseReportOledSectionSmc,
                enabled: c.smcEnabled,
                onEnabledChanged: (v) => c.smcEnabled = v,
              ),
              if (c.smcEnabled) ...[
                _oledConfidenceSlider(
                  confidence: c.confidenceSmc,
                  onConfidenceChanged: (v) => c.confidenceSmc = v,
                  impactPercent: c.impactSmcDisplay,
                  onImpactTap: () {
                    final f = c.impactFeuille;
                    final s = c.impactStructure;
                    final i = c.impactIndicators;
                    final m = c.impactSmc;
                    showAnalyseImpactModal(
                      context,
                      label: l.analyseImpactSmc,
                      initialImpact: m,
                      onApply: (w) => c.impactSmc = w,
                      onCancelRestore: () => c.restoreImpactsSnapshot(f, s, i, m),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AnalyseTokens.smcPanelBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xCC312E81)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _oledSmcFieldBlock(
                        label: l.analyseOrderBlock,
                        value: c.smcZone,
                        hint: l.analyseOledSmcObHint,
                        onChanged: (v) => c.smcZone = v,
                        extras: c.smcZoneExtras,
                        onExtraChanged: c.setSmcZoneExtraAt,
                        onRemoveExtra: c.removeSmcZoneExtraAt,
                        onAdd: () => c.addSmcZoneExtra(''),
                        accent: AnalyseTokens.oledIndigo,
                      ),
                      const SizedBox(height: 12),
                      _oledSmcFieldBlock(
                        label: l.analyseFvg,
                        value: c.smcFvg,
                        hint: l.analyseOledSmcFvgHint,
                        onChanged: (v) => c.smcFvg = v,
                        extras: c.smcFvgExtras,
                        onExtraChanged: c.setSmcFvgExtraAt,
                        onRemoveExtra: c.removeSmcFvgExtraAt,
                        onAdd: () => c.addSmcFvgExtra(''),
                        accent: AnalyseTokens.oledIndigo,
                      ),
                      const SizedBox(height: 12),
                      _oledSmcFieldBlock(
                        label: l.analyseOledLiquidityShort,
                        value: c.smcLiquidityPools,
                        hint: l.analyseOledSmcLiqHint,
                        onChanged: (v) => c.smcLiquidityPools = v,
                        extras: c.smcLiquidityExtras,
                        onExtraChanged: c.setSmcLiquidityExtraAt,
                        onRemoveExtra: c.removeSmcLiquidityExtraAt,
                        onAdd: () => c.addSmcLiquidityExtra(''),
                        accent: AnalyseTokens.oledIndigo,
                      ),
                      const SizedBox(height: 12),
                      Text(l.analyseFibShort, style: AnalyseTokens.oledSmcFieldLabel),
                      const SizedBox(height: 4),
                      AnalyseSmcFibLevelChips(
                        levels: AnalyseSmcFibLevelChips.defaultLevels,
                        selected: c.smcFibLevel,
                        onChanged: (v) => c.smcFibLevel = v,
                      ),
                      const SizedBox(height: 8),
                      oledDeepInput(
                        value: c.smcFibPrice,
                        hint: l.analyseOledFibPriceHint,
                        onChanged: (v) => c.smcFibPrice = v,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                oledFieldLabel(l.analyseOledZoneSynthesis),
                Container(
                  decoration: AnalyseTokens.fieldDecoration,
                  child: TextFormField(
                    initialValue: c.notesSmc,
                    maxLines: 2,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AnalyseTokens.zinc200,
                    ),
                    decoration: InputDecoration(
                      hintText: l.analyseOledZoneSynthesisHint,
                      hintStyle: TextStyle(
                        color: AnalyseTokens.zinc600,
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10),
                    ),
                    onChanged: (v) => c.notesSmc = v,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _oledSmcFieldBlock({
    required String label,
    required String value,
    required String hint,
    required ValueChanged<String> onChanged,
    required List<String> extras,
    required void Function(int index, String value) onExtraChanged,
    required void Function(int index) onRemoveExtra,
    required VoidCallback onAdd,
    required Color accent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AnalyseTokens.oledSmcFieldLabel),
        const SizedBox(height: 4),
        oledInputWithPlus(
          value: value,
          hint: hint,
          onChanged: onChanged,
          onPlusTap: onAdd,
          accent: accent,
        ),
        for (var i = 0; i < extras.length; i++) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onLongPress: () => onRemoveExtra(i),
            child: oledDeepInput(
              value: extras[i],
              hint: hint,
              onChanged: (v) => onExtraChanged(i, v),
            ),
          ),
        ],
      ],
    );
  }

  Widget _srLevelPanel({
    required String title,
    required String levelHint,
    required Color titleColor,
    required String value,
    required ValueChanged<String> onChanged,
    required List<AnalyseStructureExtraLevel> extras,
    required void Function(int index, String price) onExtraChanged,
    required void Function(int index) onRemoveExtra,
    required VoidCallback onAdd,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AnalyseTokens.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AnalyseTokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AnalyseTokens.oledSectionLabel.copyWith(color: titleColor),
          ),
          const SizedBox(height: 8),
          oledInputWithPlus(
            value: value,
            hint: levelHint,
            onChanged: onChanged,
            onPlusTap: onAdd,
            accent: accent,
          ),
          for (var i = 0; i < extras.length; i++) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onLongPress: () => onRemoveExtra(i),
              child: oledDeepInput(
                value: extras[i].price,
                hint: levelHint,
                onChanged: (v) => onExtraChanged(i, v),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ?????? LTF ??????

class AnalyseOledLtfSection extends StatefulWidget {
  const AnalyseOledLtfSection({super.key, required this.controller});

  final AnalyseController controller;

  @override
  State<AnalyseOledLtfSection> createState() => _AnalyseOledLtfSectionState();
}

class _AnalyseOledLtfSectionState extends State<AnalyseOledLtfSection> {
  final _customSetup = TextEditingController();

  @override
  void dispose() {
    _customSetup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
        return AnalyseOledStepShell(
          title: l.analyseReportOledSectionEntry,
          topAccent: AnalyseTokens.oledGreen,
          watermarkIcon: LucideIcons.activity,
          watermarkColor: AnalyseTokens.oledGreen,
          timeframeValue: c.indicatorsTf,
          timeframeOptions: analyseLtfTfOptions(c),
          onTimeframeChanged: (v) => applyAnalyseIndicatorsTfChange(c, v),
          sectionEnabled: c.indicatorsEnabled,
          onSectionEnabledChanged: (v) => c.indicatorsEnabled = v,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (c.indicatorsEnabled) ...[
                _oledConfidenceSlider(
                  confidence: c.confidenceIndicators,
                  onConfidenceChanged: (v) => c.confidenceIndicators = v,
                  impactPercent: c.impactIndicatorsDisplay,
                  onImpactTap: () {
                    final f = c.impactFeuille;
                    final s = c.impactStructure;
                    final i = c.impactIndicators;
                    final m = c.impactSmc;
                    showAnalyseImpactModal(
                      context,
                      label: l.analyseImpactIndicators,
                      initialImpact: i,
                      onApply: (w) => c.impactIndicators = w,
                      onCancelRestore: () => c.restoreImpactsSnapshot(f, s, i, m),
                    );
                  },
                ),
              ],
              if (!c.indicatorsEnabled) const SizedBox.shrink() else ...[
              oledFieldLabel(l.ajouterTradePlanRowOutils),
              const SizedBox(height: 8),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (var j = 0; j < c.indicators.length; j++)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _setupChip(
                                label: c.indicators[j],
                                active: c.indicatorSetupIsSelected(c.indicators[j]),
                                onTap: () => c.toggleIndicatorsSetupSelection(
                                  c.indicators[j],
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => c.removeIndicatorAt(j),
                                  customBorder: const CircleBorder(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: AnalyseTokens.zinc500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: AnalyseTokens.fieldDecoration,
                            child: TextField(
                              controller: _customSetup,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: l.analyseOledAddSignalHint,
                                hintStyle: TextStyle(
                                  color: AnalyseTokens.zinc600,
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            final t = _customSetup.text.trim();
                            if (t.isEmpty) return;
                            c.addCustomIndicator(t);
                            _customSetup.clear();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AnalyseTokens.zinc700,
                            foregroundColor: AnalyseTokens.zinc200,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AnalyseTokens.zinc600),
                            ),
                          ),
                          child: Text(
                            l.analyseAddShort,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              oledFieldLabel(l.analyseOledActionPlanLabel),
              Container(
                decoration: AnalyseTokens.fieldDecoration,
                child: TextFormField(
                  initialValue: c.notesIndicators,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AnalyseTokens.zinc200),
                  decoration: InputDecoration(
                    hintText: l.analyseOledActionPlanHint,
                    hintStyle: TextStyle(color: AnalyseTokens.zinc600, fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  onChanged: (v) => c.notesIndicators = v,
                ),
              ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _setupChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF051C15) : AnalyseTokens.inputBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AnalyseTokens.oledGreen : AnalyseTokens.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AnalyseTokens.oledGreen : AnalyseTokens.zinc600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active ? AnalyseTokens.oledGreen : AnalyseTokens.zinc400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
