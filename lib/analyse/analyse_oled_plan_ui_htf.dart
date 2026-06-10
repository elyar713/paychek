part of 'analyse_oled_plan_ui.dart';

class AnalyseOledHtfSection extends StatelessWidget {
  const AnalyseOledHtfSection({
    super.key,
    required this.controller,
    this.showVolumeProfile = true,
  });

  final AnalyseController controller;

  /// Sur desktop : bloc VP sous FONDAMENTAL. Sur mobile : g?r? par [AnalyseOledPlanGrid].
  final bool showVolumeProfile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final c = controller;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnalyseOledStepShell(
          title: l.analyseReportOledSectionFundamental,
          topAccent: AnalyseTokens.oledBlue,
          watermarkIcon: LucideIcons.landmark,
          watermarkColor: AnalyseTokens.oledBlue,
          timeframeValue: analyseHtfDropdownValue(c),
          timeframeOptions: analyseHtfDropdownOptions(c),
          onTimeframeChanged: (v) => applyAnalyseHtfDropdownChange(c, v),
          sectionEnabled: c.contextEnabled,
          onSectionEnabledChanged: (v) => c.contextEnabled = v,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (c.contextEnabled) ...[
                _oledConfidenceSlider(
                  confidence: c.confidenceFeuille,
                  onConfidenceChanged: (v) => c.confidenceFeuille = v,
                  impactPercent: c.impactFeuilleDisplay,
                  onImpactTap: () {
                    final f = c.impactFeuille;
                    final s = c.impactStructure;
                    final i = c.impactIndicators;
                    final m = c.impactSmc;
                    showAnalyseImpactModal(
                      context,
                      label: l.analyseImpactFeuille,
                      initialImpact: f,
                      onApply: (w) => c.impactFeuille = w,
                      onCancelRestore: () => c.restoreImpactsSnapshot(f, s, i, m),
                    );
                  },
                ),
              ],
              if (!c.contextEnabled) const SizedBox.shrink() else ...[
              oledFieldLabel(l.ajouterTradePlanRowBias),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OledChipButton(
                      label: l.analyseSideBuy,
                      icon: LucideIcons.trendingUp,
                      selected: c.bias == AnalyseDirectionBias.achat,
                      activeBorder: AnalyseTokens.oledGreen,
                      activeBg: const Color(0xFF051C15),
                      activeFg: AnalyseTokens.oledGreen,
                      onTap: () => c.bias = AnalyseDirectionBias.achat,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OledChipButton(
                      label: l.analyseSideSell,
                      icon: LucideIcons.trendingDown,
                      selected: c.bias == AnalyseDirectionBias.vente,
                      activeBorder: AnalyseTokens.oledRed,
                      activeBg: const Color(0xFF1C090D),
                      activeFg: AnalyseTokens.oledRed,
                      onTap: () => c.bias = AnalyseDirectionBias.vente,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OledChipButton(
                      label: l.analyseSideWatch,
                      icon: LucideIcons.eye,
                      selected: c.bias == AnalyseDirectionBias.surveiller,
                      activeBorder: AnalyseTokens.oledAmber,
                      activeBg: const Color(0xFF1F1505),
                      activeFg: AnalyseTokens.oledAmber,
                      onTap: () => c.bias = AnalyseDirectionBias.surveiller,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              oledFieldLabel(l.analyseTrendLabel),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OledChipButton(
                      label: l.analyseTrendBullish,
                      selected: c.localTrendPick.enumVal == AnalyseLocalTrend.haussiere,
                      activeBorder: AnalyseTokens.oledGreen,
                      activeBg: const Color(0xFF051C15),
                      activeFg: AnalyseTokens.oledGreen,
                      onTap: () => c.localTrendPick = ContextePick.enumOf(AnalyseLocalTrend.haussiere),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OledChipButton(
                      label: l.analyseTrendBearish,
                      selected: c.localTrendPick.enumVal == AnalyseLocalTrend.baissiere,
                      activeBorder: AnalyseTokens.oledRed,
                      activeBg: const Color(0xFF1C090D),
                      activeFg: AnalyseTokens.oledRed,
                      onTap: () => c.localTrendPick = ContextePick.enumOf(AnalyseLocalTrend.baissiere),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OledChipButton(
                      label: l.analyseTrendRange,
                      selected: c.localTrendPick.enumVal == AnalyseLocalTrend.range,
                      activeBorder: AnalyseTokens.zinc500,
                      activeBg: AnalyseTokens.zinc700,
                      activeFg: AnalyseTokens.zinc200,
                      onTap: () => c.localTrendPick = ContextePick.enumOf(AnalyseLocalTrend.range),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              oledFieldLabel(l.ajouterTradePlanRowPhase),
              const SizedBox(height: 8),
              _OledMarketPhaseChips(controller: c, locale: locale),
              const SizedBox(height: 20),
              oledFieldLabel(l.analyseStructureSectionTitle),
              Container(
                decoration: AnalyseTokens.fieldDecoration,
                child: TextFormField(
                  initialValue: c.notesStructure,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AnalyseTokens.zinc200),
                  decoration: InputDecoration(
                    hintText: l.analyseOledStructureChartHint,
                    hintStyle: TextStyle(color: AnalyseTokens.zinc600, fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  onChanged: (v) => c.notesStructure = v,
                ),
              ),
              const SizedBox(height: 20),
              oledFieldLabel(l.analyseOledMacroNotesLabel),
              Container(
                decoration: AnalyseTokens.fieldDecoration,
                child: TextFormField(
                  initialValue: c.notesTimeframe,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AnalyseTokens.zinc200),
                  decoration: InputDecoration(
                    hintText: l.analyseOledMacroNotesHint,
                    hintStyle: TextStyle(color: AnalyseTokens.zinc600, fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  onChanged: (v) => c.notesTimeframe = v,
                ),
              ),
              ],
            ],
          ),
        ),
            if (showVolumeProfile) ...[
              const SizedBox(height: 24),
              AnalyseOledVolumeProfileBlock(controller: controller),
            ],
          ],
        );
      },
    );
  }
}

/// Volume profile : sous FONDAMENTAL (desktop) ou au-dessus d'ENTR??E (mobile).
class AnalyseOledVolumeProfileBlock extends StatelessWidget {
  const AnalyseOledVolumeProfileBlock({
    super.key,
    required this.controller,
    this.standaloneCard = false,
  });

  final AnalyseController controller;

  /// Mobile : carte pleine largeur comme les sections Performance.
  final bool standaloneCard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final c = controller;
        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            oledSectionTitleRow(
              l.analyseReportOledSectionVolumeProfile,
              enabled: c.volumeProfileEnabled,
              onEnabledChanged: (v) => c.volumeProfileEnabled = v,
            ),
            if (c.volumeProfileEnabled) ...[
              const SizedBox(height: 12),
              Container(
                padding: standaloneCard
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(16),
                decoration: standaloneCard
                    ? null
                    : BoxDecoration(
                        color: AnalyseTokens.vpPanelBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AnalyseTokens.cardBorder),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: _oledMiniTfDropdown(
                        c.volumeProfileTf,
                        analyseVolumeTfOptions(c),
                        (v) {
                          if (v != null) c.volumeProfileTf = v;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _oledVpField(
                            l.analyseVolumePoc,
                            c.volumeProfilePoc,
                            (v) => c.volumeProfilePoc = v,
                            priceHint: l.analyseHintPriceDots,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _oledVpField(
                            l.analyseVolumeVah,
                            c.volumeProfileVah,
                            (v) => c.volumeProfileVah = v,
                            priceHint: l.analyseHintPriceDots,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _oledVpField(
                            l.analyseVolumeVal,
                            c.volumeProfileVal,
                            (v) => c.volumeProfileVal = v,
                            priceHint: l.analyseHintPriceDots,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        );

        if (!standaloneCard) return body;

        return ClipRRect(
          borderRadius: BorderRadius.circular(AnalyseTokens.radiusCard),
          child: Container(
            decoration: AnalyseTokens.oledStepDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: 2, color: AnalyseTokens.zinc500),
                Padding(
                  padding: AnalyseTokens.sectionCardPadding,
                  child: body,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _oledVpField(
  String label,
  String value,
  ValueChanged<String> onChanged, {
  required String priceHint,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AnalyseTokens.oledMicroLabel.copyWith(color: AnalyseTokens.zinc500)),
      const SizedBox(height: 4),
      oledDeepInput(value: value, hint: priceHint, onChanged: onChanged),
    ],
  );
}

Widget _oledMiniTfDropdown(
  String value,
  List<String> options,
  ValueChanged<String?> onChanged,
) {
  return DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: options.contains(value) ? value : options.first,
      isDense: true,
      dropdownColor: AnalyseTokens.cardBg,
      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AnalyseTokens.zinc400),
      items: [for (final o in options) DropdownMenuItem(value: o, child: Text(o))],
      onChanged: onChanged,
    ),
  );
}

/// Tous les timeframes chart (M1 ??? Monthly) + libell?s personnalis?s ?ventuels.
List<String> analyseOledChartTfOptions({List<String> custom = const []}) {
  final out = AnalyseStructureChartTf.values.map((e) => e.label).toList();
  for (final label in custom) {
    final t = label.trim();
    if (t.isNotEmpty && !out.contains(t)) out.add(t);
  }
  return out;
}

List<String> analyseHtfDropdownOptions(AnalyseController c) =>
    analyseOledChartTfOptions(custom: c.htfCustomLabels);

String analyseHtfDropdownValue(AnalyseController c) {
  final pick = c.htfPick;
  if (pick.isEnum) return ctxLabelHtf(pick.enumVal!);
  final custom = pick.custom?.trim();
  if (custom != null && custom.isNotEmpty) return custom;
  return AnalyseStructureChartTf.daily.label;
}

void applyAnalyseHtfDropdownChange(AnalyseController c, String? label) {
  if (label == null) return;
  for (final t in AnalyseTimeframe.values) {
    if (ctxLabelHtf(t) == label) {
      c.htfPick = ContextePick.enumOf(t);
      return;
    }
  }
  c.htfPick = ContextePick.customLabel(label);
}

List<String> analyseStructureTfOptions(AnalyseController c) =>
    analyseOledChartTfOptions(custom: c.structureTfCustom);

List<String> analyseLtfTfOptions(AnalyseController c) =>
    analyseOledChartTfOptions(custom: c.indicatorsTfCustom);

List<String> analyseVolumeTfOptions(AnalyseController c) =>
    analyseOledChartTfOptions(custom: c.volumeProfileTfCustom);

void applyAnalyseStructureTfChange(AnalyseController c, String? label) {
  if (label == null) return;
  c.structureTf = label;
}

void applyAnalyseIndicatorsTfChange(AnalyseController c, String? label) {
  if (label == null) return;
  c.indicatorsTf = label;
  unawaited(AnalyseEntryTfStorage.saveFromController(c));
}
