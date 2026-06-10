part of 'analyse_oled_plan_ui.dart';

// --- Header sticky ---

class AnalyseOledStickyHeader extends StatelessWidget {
  const AnalyseOledStickyHeader({
    super.key,
    required this.controller,
    required this.onSave,
  });

  final AnalyseController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final c = controller;
        final p = computeAnalyseGlobalConfidencePercent(
          feuille: c.confidenceFeuille,
          structure: c.confidenceStructure,
          indicators: c.confidenceIndicators,
          smc: c.confidenceSmc,
          impactFeuille: c.impactFeuille,
          impactStructure: c.impactStructure,
          impactIndicators: c.impactIndicators,
          impactSmc: c.impactSmc,
          contextEnabled: c.contextEnabled,
          structureEnabled: c.structureEnabled,
          indicatorsEnabled: c.indicatorsEnabled,
          smcEnabled: c.smcEnabled,
        );
        final color = AnalyseTokens.confidenceColorForPercent(p);
        return Container(
          decoration: BoxDecoration(
            color: AnalyseTokens.headerBg,
            border: Border(bottom: BorderSide(color: AnalyseTokens.headerBorder)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.analyseConfidenceBarCaption,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: AnalyseTokens.zinc500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$p%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1.05,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Material(
                color: AnalyseTokens.oledGreen,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onSave,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.badgeCheck, size: 14, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          l.analyseOledSaveButton,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnalyseOledSaveBanner extends StatelessWidget {
  const AnalyseOledSaveBanner({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: AnalyseTokens.sectionCardPadding,
      decoration: BoxDecoration(
        color: const Color(0xFF051C15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AnalyseTokens.oledGreen),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.badgeCheck, color: AnalyseTokens.oledGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.analyseOledPlanSavedBannerTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  l.analyseOledPlanSavedBannerSubtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AnalyseTokens.oledGreen,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onDismiss,
            child: Text(
              l.analyseOledPlanSavedBannerClose,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AnalyseTokens.oledGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Metadonnees ---

class AnalyseOledMetadataSection extends StatelessWidget {
  const AnalyseOledMetadataSection({
    super.key,
    required this.controller,
    this.contexteDateLayerLink,
    this.onTapDate,
  });

  final AnalyseController controller;
  final LayerLink? contexteDateLayerLink;
  final VoidCallback? onTapDate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final c = controller;
        return ClipRRect(
          borderRadius: BorderRadius.circular(AnalyseTokens.radiusCard),
          child: Container(
          padding: AnalyseTokens.sectionCardPadding,
          decoration: AnalyseTokens.oledStepDecoration(),
          child: LayoutBuilder(
            builder: (context, lc) {
              final cols = lc.maxWidth >= 720;
              final children = [
                _metaField(
                  label: l.analyseOledAssetSymbolLabel,
                  child: _symbolInput(context, c),
                ),
                _metaField(
                  label: l.analyseOledThesisStrategyLabel,
                  child: _textInput(
                    context: context,
                    value: c.nomAnalyse,
                    hint: l.analyseOledThesisHint,
                    mono: false,
                    onChanged: (v) => c.nomAnalyse = v,
                  ),
                ),
                _metaField(
                  label: l.analyseOledExecutionDateLabel,
                  child: _dateTap(c),
                ),
              ];
              if (cols) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0) const SizedBox(width: 24),
                      Expanded(child: children[i]),
                    ],
                  ],
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(height: 20),
                    children[i],
                  ],
                ],
              );
            },
          ),
        ),
        );
      },
    );
  }

  Widget _metaField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AnalyseTokens.oledSectionLabel),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _symbolInput(BuildContext context, AnalyseController c) {
    return Container(
      decoration: AnalyseTokens.fieldDecoration,
      child: TextFormField(
        initialValue: c.analyseActif,
        scrollPadding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom + 120,
        ),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          prefixText: '\$ ',
          prefixStyle: TextStyle(
            color: AnalyseTokens.zinc600,
            fontWeight: FontWeight.w800,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onChanged: (v) => c.analyseActif = v,
      ),
    );
  }

  Widget _textInput({
    required BuildContext context,
    required String value,
    required String hint,
    required bool mono,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: AnalyseTokens.fieldDecoration,
      child: TextFormField(
        initialValue: value,
        scrollPadding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom + 120,
        ),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AnalyseTokens.zinc600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dateTap(AnalyseController c) {
    final inner = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AnalyseTokens.fieldDecoration,
          child: Text(
            c.contexteAnalyseDateLabel,
            style: AnalyseTokens.inputBodyStyle,
          ),
        ),
      ),
    );
    if (contexteDateLayerLink != null) {
      return CompositedTransformTarget(link: contexteDateLayerLink!, child: inner);
    }
    return inner;
  }
}

// --- Colonne etape ---

class AnalyseOledStepShell extends StatelessWidget {
  const AnalyseOledStepShell({
    super.key,
    required this.title,
    required this.topAccent,
    required this.watermarkIcon,
    required this.watermarkColor,
    required this.timeframeValue,
    required this.timeframeOptions,
    required this.onTimeframeChanged,
    required this.child,
    this.sectionEnabled,
    this.onSectionEnabledChanged,
  });

  final String title;
  final Color topAccent;
  final IconData watermarkIcon;
  final Color watermarkColor;
  final String timeframeValue;
  final List<String> timeframeOptions;
  final ValueChanged<String?> onTimeframeChanged;
  final Widget child;
  final bool? sectionEnabled;
  final ValueChanged<bool>? onSectionEnabledChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(AnalyseTokens.radiusCard),
          child: Container(
            decoration: AnalyseTokens.oledStepDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: 2, color: topAccent),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        watermarkIcon,
                        size: 96,
                        color: watermarkColor.withValues(alpha: 0.1),
                      ),
                    ),
                    Padding(
                      padding: AnalyseTokens.sectionCardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              if (sectionEnabled != null &&
                                  onSectionEnabledChanged != null) ...[
                                const SizedBox(width: 12),
                                AnalyseOledFunnelToolbar(
                                  enabled: sectionEnabled!,
                                  onEnabledChanged: onSectionEnabledChanged!,
                                ),
                              ],
                              const SizedBox(width: 12),
                              _tfDropdown(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          child,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
  }

  Widget _tfDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AnalyseTokens.inputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AnalyseTokens.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: timeframeOptions.contains(timeframeValue)
              ? timeframeValue
              : timeframeOptions.first,
          isDense: true,
          dropdownColor: AnalyseTokens.cardBg,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AnalyseTokens.zinc300,
          ),
          items: [
            for (final o in timeframeOptions)
              DropdownMenuItem(value: o, child: Text(o)),
          ],
          onChanged: onTimeframeChanged,
        ),
      ),
    );
  }
}
// ?????? Puces OLED ??????

/// Puces phase march? : colonne pleine largeur sur mobile, rang?e ?gale sur ?cran large.
class _OledMarketPhaseChips extends StatelessWidget {
  const _OledMarketPhaseChips({
    required this.controller,
    required this.locale,
  });

  final AnalyseController controller;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final chips = <Widget>[
      for (final p in AnalysePhase.values)
        OledChipButton(
          label: ctxLabelPhase(p, locale),
          selected: c.phasePick.enumVal == p,
          activeBorder: AnalyseTokens.oledBlue,
          activeBg: const Color(0x331E3A8A),
          activeFg: AnalyseTokens.oledBlue,
          onTap: () => c.phasePick = ContextePick.enumOf(p),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertical =
            constraints.maxWidth < AnalyseTokens.layoutBreakpointFeuilleGrid;
        if (stackVertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < chips.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                chips[i],
              ],
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < chips.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: chips[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class OledChipButton extends StatelessWidget {
  const OledChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.activeBorder,
    this.activeBg,
    this.activeFg,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? activeBorder;
  final Color? activeBg;
  final Color? activeFg;

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? (activeBorder ?? AnalyseTokens.oledBlue)
        : AnalyseTokens.cardBorder;
    final bg = selected
        ? (activeBg ?? AnalyseTokens.inputBg)
        : AnalyseTokens.inputBg;
    final fg = selected
        ? (activeFg ?? Colors.white)
        : AnalyseTokens.zinc400;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: selected ? 1.5 : 1),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: border.withValues(alpha: 0.25),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 14, color: fg),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                          color: fg,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: fg,
                    height: 1.15,
                  ),
                ),
        ),
      ),
    );
  }
}

Widget oledFieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AnalyseTokens.oledSectionLabel),
    );

/// Titre de sous-section + interrupteur (sans texte ? section active ?).
Widget oledSectionTitleRow(
  String title, {
  required bool enabled,
  required ValueChanged<bool> onEnabledChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(title, style: AnalyseTokens.oledSectionLabel),
        ),
        AnalyseOledFunnelToolbar(
          enabled: enabled,
          onEnabledChanged: onEnabledChanged,
        ),
      ],
    ),
  );
}

Widget oledDeepInput({
  required String value,
  required String hint,
  required ValueChanged<String> onChanged,
  Color? focusBorder,
}) {
  return Container(
    decoration: AnalyseTokens.fieldDecorationDeep,
    child: TextFormField(
      initialValue: value,
      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AnalyseTokens.zinc700, fontSize: 12),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: onChanged,
    ),
  );
}

Widget oledPlusButton({required VoidCallback onTap, Color accent = AnalyseTokens.oledIndigo}) {
  return Material(
    color: accent,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(LucideIcons.plus, size: 14, color: Colors.black),
      ),
    ),
  );
}

Widget oledInputWithPlus({
  required String value,
  required String hint,
  required ValueChanged<String> onChanged,
  required VoidCallback onPlusTap,
  Color accent = AnalyseTokens.oledIndigo,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: oledDeepInput(value: value, hint: hint, onChanged: onChanged),
      ),
      const SizedBox(width: 6),
      oledPlusButton(onTap: onPlusTap, accent: accent),
    ],
  );
}

Widget _oledConfidenceSlider({
  required int confidence,
  required ValueChanged<int> onConfidenceChanged,
  required int impactPercent,
  required VoidCallback onImpactTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AnalyseConfidenceSlider(
        value: confidence,
        onChanged: onConfidenceChanged,
        impactPercent: impactPercent,
        onImpactTap: onImpactTap,
      ),
      const SizedBox(height: 16),
    ],
  );
}

// ?????? Grille principale ??????

class AnalyseOledPlanGrid extends StatelessWidget {
  const AnalyseOledPlanGrid({
    super.key,
    required this.controller,
    required this.wide,
  });

  final AnalyseController controller;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final volume = AnalyseOledVolumeProfileBlock(
      controller: controller,
      standaloneCard: !wide,
    );
    final htf = AnalyseOledHtfSection(
      controller: controller,
      showVolumeProfile: wide,
    );
    final mtf = AnalyseOledMtfSection(controller: controller);
    final ltf = AnalyseOledLtfSection(controller: controller);
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: htf),
          const SizedBox(width: 32),
          Expanded(child: mtf),
          const SizedBox(width: 32),
          Expanded(child: ltf),
        ],
      );
    }
    return Column(
      children: [
        htf,
        const SizedBox(height: 16),
        mtf,
        const SizedBox(height: 16),
        volume,
        const SizedBox(height: 16),
        ltf,
      ],
    );
  }
}
