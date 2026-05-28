import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import 'analyse_confluence_score.dart';
import 'analyse_controller.dart';
import 'analyse_entry_tf_storage.dart';
import 'analyse_impact_modal.dart';
import 'analyse_models.dart';
import 'analyse_page_content_contexte_options.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_confidence_slider.dart';
import 'widgets/analyse_oled_funnel_toolbar.dart';
import 'widgets/analyse_smc_fib_chips.dart';

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
        final score = computeOledConfluenceScore(controller);
        final color = oledConfluenceColor(score);
        final status = oledConfluenceStatusLabel(score, l);
        return Container(
          decoration: BoxDecoration(
            color: AnalyseTokens.headerBg,
            border: Border(bottom: BorderSide(color: AnalyseTokens.headerBorder)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              _ConfluenceRing(score: score, color: color),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.analyseOledConfluenceLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: AnalyseTokens.zinc500,
                    ),
                  ),
                  Text(
                    status,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 0.4,
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

class _ConfluenceRing extends StatelessWidget {
  const _ConfluenceRing({required this.score, required this.color});

  final int score;
  final Color color;

  static const _r = 22.0;
  static const _stroke = 4.0;

  @override
  Widget build(BuildContext context) {
    final norm = _r - _stroke * 2;
    final c = 2 * math.pi * norm;
    final offset = c - (score / 100) * c;
    return SizedBox(
      width: _r * 2,
      height: _r * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(_r * 2, _r * 2),
            painter: _RingPainter(
              radius: norm,
              stroke: _stroke,
              trackColor: const Color(0xFF14151B),
              progressColor: color,
              dashOffset: offset,
              circumference: c,
            ),
          ),
          Text(
            '$score%',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.radius,
    required this.stroke,
    required this.trackColor,
    required this.progressColor,
    required this.dashOffset,
    required this.circumference,
  });

  final double radius;
  final double stroke;
  final Color trackColor;
  final Color progressColor;
  final double dashOffset;
  final double circumference;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final prog = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, radius, track);
    final sweep = 2 * math.pi * (1 - dashOffset / circumference);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      prog,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.dashOffset != dashOffset || old.progressColor != progressColor;
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
                  child: _symbolInput(c),
                ),
                _metaField(
                  label: l.analyseOledThesisStrategyLabel,
                  child: _textInput(
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

  Widget _symbolInput(AnalyseController c) {
    return Container(
      decoration: AnalyseTokens.fieldDecoration,
      child: TextFormField(
        initialValue: c.analyseActif,
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
    required String value,
    required String hint,
    required bool mono,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: AnalyseTokens.fieldDecoration,
      child: TextFormField(
        initialValue: value,
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
// —— Puces OLED ——

/// Puces phase marché : colonne pleine largeur sur mobile, rangée égale sur écran large.
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
    this.emoji,
    this.activeBorder,
    this.activeBg,
    this.activeFg,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;
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
          child: Text(
            '${emoji ?? ''}$label',
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

/// Titre de sous-section + interrupteur (sans texte « section active »).
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

// —— Grille principale ——

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

class AnalyseOledHtfSection extends StatelessWidget {
  const AnalyseOledHtfSection({
    super.key,
    required this.controller,
    this.showVolumeProfile = true,
  });

  final AnalyseController controller;

  /// Sur desktop : bloc VP sous FONDAMENTAL. Sur mobile : géré par [AnalyseOledPlanGrid].
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
              Row(
                children: [
                  Expanded(
                    child: OledChipButton(
                      label: l.analyseSideBuy,
                      emoji: '🟢 ',
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
                      emoji: '🔴 ',
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
                      emoji: '🟡 ',
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
              oledFieldLabel(l.analyseCurrentMarketPhase),
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

/// Volume profile : sous FONDAMENTAL (desktop) ou au-dessus d'ENTRÉE (mobile).
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

/// Tous les timeframes chart (M1 … Monthly) + libellés personnalisés éventuels.
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

// —— LTF ——

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
              oledFieldLabel(l.analyseOledSignalsLabel),
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
                          onTap: () =>
                              c.toggleIndicatorsSetupSelection(c.indicators[j]),
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
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: l.analyseOledAddSignalHint,
                          hintStyle: TextStyle(color: AnalyseTokens.zinc600, fontSize: 12),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AnalyseTokens.zinc600),
                      ),
                    ),
                    child: Text(
                      l.analyseAddShort,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
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
