import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../analyse_prep_checks.dart';
import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';
import '../widgets/analyse_prep_check_box.dart';
import 'analyse_report_ui_primitives.dart';

part 'analyse_report_oled_body_blocks.dart';
part 'analyse_report_oled_body_smc.dart';
part 'analyse_report_oled_body_volume.dart';

/// Espacements rapport (version compacte).
abstract final class _ReportCompact {
  static const gapSection = 8.0;
  static const gapBlock = 6.0;
  static const gapField = 6.0;
  static const gapRow = 6.0;
  static const padFusedBody = EdgeInsets.fromLTRB(10, 10, 10, 10);
  static const padSmcPanel = 10.0;
  static const padFieldX = 8.0;
  static const padFieldY = 6.0;
  static const padFieldMultilineY = 8.0;
  static const gapColumns = 12.0;
  static const columnsBreakpoint = 720.0;
}

/// Rapport figé : une seule carte (hero + 3 colonnes), sections sans cartes imbriquées.
class AnalyseReportOledBody extends StatelessWidget {
  const AnalyseReportOledBody({
    super.key,
    required this.snapshot,
    this.topBar,
    this.onPrepToggle,
  });

  final AnalyseReportSnapshot snapshot;
  /// Barre d’actions (ex. titre Rapport + icônes) intégrée en haut de la carte.
  final Widget? topBar;
  /// Routine pré-trade sur le rapport figé (hors PDF).
  final ValueChanged<String>? onPrepToggle;

  static List<String> _lines(String main, List<String> extras) {
    final out = <String>[];
    final m = main.trim();
    if (m.isNotEmpty && m != '—') out.add(m);
    for (final e in extras) {
      final t = e.trim();
      if (t.isNotEmpty) out.add(t);
    }
    if (out.isEmpty) return const [];
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final s = snapshot;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AnalyseTokens.radiusCard),
      child: Container(
        decoration: AnalyseTokens.oledStepDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (topBar != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: topBar!,
              ),
              const Divider(height: 1, thickness: 1, color: AnalyseTokens.cardBorder),
            ],
            Padding(
              padding: _ReportCompact.padFusedBody,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReportHero(
                    snapshot: s,
                    onPrepToggle: onPrepToggle,
                  ),
                  const SizedBox(height: _ReportCompact.gapSection),
                  _ReportThreeColumns(
                    snapshot: s,
                    onPrepToggle: onPrepToggle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3 colonnes : FONDAMENTAL (+ VP) | ZONE CLÉ & SMC | ENTRÉE.
class _ReportThreeColumns extends StatelessWidget {
  const _ReportThreeColumns({
    required this.snapshot,
    this.onPrepToggle,
  });

  final AnalyseReportSnapshot snapshot;
  final ValueChanged<String>? onPrepToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = snapshot;
    final sectionFundamental = _ReportOledSection(
      title: l.analyseReportOledSectionFundamental,
      accent: AnalyseTokens.oledBlue,
      icon: LucideIcons.landmark,
      confidence: s.gaugeContextEnabled ? s.gaugeFeuille : null,
      child: s.gaugeContextEnabled
          ? _FundamentalBlock(snapshot: s, onPrepToggle: onPrepToggle)
          : const _ReportColumnOff(),
    );

    final sectionVolume = s.gaugeVolumeProfileEnabled
        ? _ReportOledSection(
            title: l.analyseReportOledSectionVolumeProfile,
            accent: AnalyseTokens.zinc500,
            icon: LucideIcons.barChart3,
            child: _VolumeBlock(snapshot: s, onPrepToggle: onPrepToggle),
          )
        : null;

    final sectionZone = _ReportOledSection(
      title: l.analyseReportOledSectionKeyZone,
      accent: AnalyseTokens.oledIndigo,
      icon: LucideIcons.layers,
      confidence: s.gaugeStructureEnabled ? s.gaugeStructure : null,
      child: s.gaugeStructureEnabled
          ? _StructureBlock(snapshot: s, onPrepToggle: onPrepToggle)
          : const _ReportColumnOff(),
    );

    final sectionSmc = s.gaugeSmcEnabled
        ? _ReportOledSection(
            title: l.analyseReportOledSectionSmc,
            accent: AnalyseTokens.oledIndigo,
            icon: LucideIcons.box,
            confidence: s.gaugeSmc,
            child: _SmcBlock(snapshot: s, onPrepToggle: onPrepToggle),
          )
        : null;

    final sectionEntry = _ReportOledSection(
      title: l.analyseReportOledSectionEntry,
      accent: AnalyseTokens.oledGreen,
      icon: LucideIcons.activity,
      confidence: s.gaugeIndicatorsEnabled ? s.gaugeIndicators : null,
      child: s.gaugeIndicatorsEnabled
          ? _EntryBlock(snapshot: s, onPrepToggle: onPrepToggle)
          : const _ReportColumnOff(),
    );

    final colLeft = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sectionFundamental,
        if (sectionVolume != null) ...[
          const SizedBox(height: _ReportCompact.gapBlock),
          sectionVolume,
        ],
        const SizedBox(height: _ReportCompact.gapBlock),
        sectionEntry,
      ],
    );

    final colZoneSmc = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sectionZone,
        if (sectionSmc != null) ...[
          const SizedBox(height: _ReportCompact.gapBlock),
          sectionSmc,
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _ReportCompact.columnsBreakpoint;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: colLeft),
              const SizedBox(width: _ReportCompact.gapColumns),
              Expanded(child: colZoneSmc),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            colLeft,
            const SizedBox(height: _ReportCompact.gapSection),
            colZoneSmc,
          ],
        );
      },
    );
  }
}

class _ReportColumnOff extends StatelessWidget {
  const _ReportColumnOff();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Text(
      l.analyseReportOledSectionHidden,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AnalyseTokens.zinc600,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _ReportHero extends StatelessWidget {
  const _ReportHero({
    required this.snapshot,
    this.onPrepToggle,
  });

  final AnalyseReportSnapshot snapshot;
  final ValueChanged<String>? onPrepToggle;

  static String _heroValue(String raw) {
    final v = raw.trim();
    return v.isEmpty ? '—' : v;
  }

  @override
  Widget build(BuildContext context) {
    final actif = _heroValue(snapshot.actif);
    final these = _heroValue(snapshot.sousTitre);
    final date = _heroValue(snapshot.contexteDateLabel ?? '');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${snapshot.globalConfidencePercent}%',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: snapshot.globalConfidenceColor,
            height: 1.05,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actif,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AnalyseTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                these,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AnalyseTokens.zinc200,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AnalyseTokens.zinc500,
                ),
              ),
            ],
          ),
        ),
        if (snapshot.gaugeContextEnabled) ...[
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onPrepToggle != null) ...[
                AnalyseReportPrepCheckBox(
                  checked: snapshotIsPrepChecked(
                    snapshot,
                    AnalysePrepCheckIds.ctxBias,
                  ),
                  onToggle: () => onPrepToggle!(AnalysePrepCheckIds.ctxBias),
                ),
                const SizedBox(width: 6),
              ],
              analyseReportBiasPill(context, snapshot),
            ],
          ),
        ],
      ],
    );
  }
}

/// Titre de section à l’intérieur de la carte fusionnée (sans carte séparée).
class _ReportOledSection extends StatelessWidget {
  const _ReportOledSection({
    required this.title,
    required this.accent,
    required this.icon,
    required this.child,
    this.confidence,
  });

  final String title;
  final Color accent;
  final IconData icon;
  final Widget child;
  final int? confidence;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 2,
              height: 14,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 12, color: accent.withValues(alpha: 0.85)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: AnalyseTokens.oledSectionLabel.copyWith(color: accent),
              ),
            ),
            if (confidence != null)
              Text(
                '$confidence%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AnalyseTokens.confidenceColorForPercent(confidence!),
                ),
              ),
          ],
        ),
        const SizedBox(height: _ReportCompact.gapBlock),
        child,
      ],
    );
  }
}
