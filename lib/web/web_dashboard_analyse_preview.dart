import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../analyse/analyse_report_snapshot.dart';
import '../analyse/analyse_tokens.dart';
import '../analyse/report_widgets/analyse_report_structure_ui.dart'
    show dashboardStructureLevelColumn;
import '../analyse/report_widgets/analyse_report_ui_primitives.dart'
    show analyseReportBiasPill;
import '../dashboard/widgets/donut_ring.dart';
import '../l10n/app_localizations.dart';
import 'paychek_web_tokens.dart';

/// Aperçu « Mon analyse » aligné maquette web (titres italiques, donut confiance, citation bord gauche vert).
class WebDashboardAnalysePreview extends StatelessWidget {
  const WebDashboardAnalysePreview({
    super.key,
    required this.snapshot,
    required this.onOpenAnalyse,
    this.cardBackgroundColor,
  });

  final AnalyseReportSnapshot? snapshot;
  final VoidCallback onOpenAnalyse;

  /// Transparent si la carte est dans [WebDashboardPairedCard].
  final Color? cardBackgroundColor;

  /// La carte garde sa largeur ; le contenu est un peu resserré et centré (~92 %).
  static const double _innerContentWidthFactor = 0.92;

  static String _dash(String v) {
    final t = v.trim();
    return t.isEmpty ? '\u2014' : t;
  }

  static TextStyle _labelUpperGrey(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
      color: PaychekWebTokens.textGray500,
      height: 1.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = snapshot;
    final bg = cardBackgroundColor ?? Colors.transparent;

    if (s == null) {
      return ColoredBox(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final innerW =
                  (constraints.maxWidth * _innerContentWidthFactor).clamp(
                        0.0,
                        double.infinity,
                      );
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: innerW,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart_rounded,
                        size: 16,
                        color: PaychekWebTokens.textGray500,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.dashboardAnalyseShortcutTitle.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: PaychekWebTokens.textGray500,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: onOpenAnalyse,
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: PaychekWebTokens.textGray500
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return ColoredBox(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final innerW =
                (constraints.maxWidth * _innerContentWidthFactor).clamp(0.0, double.infinity);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: innerW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          size: 16,
                          color: PaychekWebTokens.textGray500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.dashboardAnalyseShortcutTitle.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: PaychekWebTokens.textGray500,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: onOpenAnalyse,
                          icon: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: PaychekWebTokens.textGray500
                                .withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dash(s.actif),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.italic,
                                  height: 1.15,
                                ),
                              ),
                              if (s.sousTitre.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  s.sousTitre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: PaychekWebTokens.textGray500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DonutRing(
                              progress:
                                  (s.globalConfidencePercent.clamp(0, 100)) /
                                      100.0,
                              centerPrimary: '${s.globalConfidencePercent}%',
                              showInnerSecondary: false,
                              size: 60,
                              strokeWidth: 5,
                              ringColor: s.globalConfidenceColor,
                              trackColor: const Color(0xFF1F2937),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l.mentalConfidence.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: PaychekWebTokens.accentMint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (s.gaugeContextEnabled) ...[
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: analyseReportBiasPill(context, s),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: PaychekWebTokens.textGray500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                s.contexteDateLabel ?? '\u2014',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: PaychekWebTokens.textGray500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _WebTfTrendPhaseRow(
                        snapshot: s,
                        labelStyle: _labelUpperGrey(context),
                        compact: true,
                      ),
                      if (s.noteContexte.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _WebAnalyseQuoteBand(text: s.noteContexte),
                      ],
                    ],
                    if (s.gaugeContextEnabled && s.gaugeStructureEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: PaychekWebTokens.borderGray800
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    if (s.gaugeStructureEnabled) ...[
                      if (!s.gaugeContextEnabled) const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _WebKvColumn(
                              label: l.analyseStructure,
                              value:
                                  '${_dash(s.structureTf)} - ${_dash(s.chartisme)}',
                              valueStyle: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                              labelStyle: _labelUpperGrey(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: dashboardStructureLevelColumn(
                              context: context,
                              mainLabel: l.analyseSupport,
                              mainValue: _dash(s.support),
                              headerStyle: _labelUpperGrey(context),
                              valueStyle: GoogleFonts.plusJakartaSans(
                                color: AnalyseTokens.accentGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                              extras: s.structureExtraSupports ??
                                  const <AnalyseReportStructureExtraLine>[],
                              extraPrefix: 'S',
                              extraValueColor: AnalyseTokens.accentGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: dashboardStructureLevelColumn(
                              context: context,
                              mainLabel: l.analyseResistShort,
                              mainValue: _dash(s.resistance),
                              headerStyle: _labelUpperGrey(context),
                              valueStyle: GoogleFonts.plusJakartaSans(
                                color: AnalyseTokens.accentRed,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                              extras: s.structureExtraResistances ??
                                  const <AnalyseReportStructureExtraLine>[],
                              extraPrefix: 'R',
                              extraValueColor: AnalyseTokens.accentRed,
                            ),
                          ),
                        ],
                      ),
                      for (final copy
                          in s.structureCopies ?? const <AnalyseReportStructureCopy>[]) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: PaychekWebTokens.borderGray800
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _WebKvColumn(
                                label: l.analyseStructure,
                                value:
                                    '${_dash(copy.structureTf)} - ${_dash(copy.chartisme)}',
                                valueStyle: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                                labelStyle: _labelUpperGrey(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: dashboardStructureLevelColumn(
                                context: context,
                                mainLabel: l.analyseSupport,
                                mainValue: _dash(copy.support),
                                headerStyle: _labelUpperGrey(context),
                                valueStyle: GoogleFonts.plusJakartaSans(
                                  color: AnalyseTokens.accentGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                                extras: copy.structureExtraSupports,
                                extraPrefix: 'S',
                                extraValueColor: AnalyseTokens.accentGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: dashboardStructureLevelColumn(
                                context: context,
                                mainLabel: l.analyseResistShort,
                                mainValue: _dash(copy.resistance),
                                headerStyle: _labelUpperGrey(context),
                                valueStyle: GoogleFonts.plusJakartaSans(
                                  color: AnalyseTokens.accentRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                                extras: copy.structureExtraResistances,
                                extraPrefix: 'R',
                                extraValueColor: AnalyseTokens.accentRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (s.noteStructure.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _WebAnalyseQuoteBand(text: s.noteStructure),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WebTfTrendPhaseRow extends StatelessWidget {
  const _WebTfTrendPhaseRow({
    required this.snapshot,
    required this.labelStyle,
    this.compact = false,
  });

  final AnalyseReportSnapshot snapshot;
  final TextStyle labelStyle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = snapshot;
    final fs = compact ? 12.0 : 13.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _WebKvColumn(
            label: l.analyseTimeframeLabelShort,
            value: s.contexteTfLine,
            labelStyle: labelStyle,
            valueStyle: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: fs,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(width: compact ? 4 : 6),
        Expanded(
          child: _WebKvColumn(
            label: l.analyseTrend,
            value: s.trendLabel,
            labelStyle: labelStyle,
            valueStyle: GoogleFonts.plusJakartaSans(
              color: s.trendFg,
              fontSize: fs,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(width: compact ? 4 : 6),
        Expanded(
          child: _WebKvColumn(
            label: l.analysePhase,
            value: s.phaseLabel,
            labelStyle: labelStyle,
            valueStyle: GoogleFonts.plusJakartaSans(
              color: s.phaseFg,
              fontSize: fs,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _WebKvColumn extends StatelessWidget {
  const _WebKvColumn({
    required this.label,
    required this.value,
    required this.valueStyle,
    required this.labelStyle,
  });

  final String label;
  final String value;
  final TextStyle valueStyle;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: labelStyle),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: valueStyle,
        ),
      ],
    );
  }
}

class _WebAnalyseQuoteBand extends StatelessWidget {
  const _WebAnalyseQuoteBand({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: PaychekWebTokens.accentMint,
            width: 3,
          ),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: PaychekWebTokens.textGray400,
          fontSize: 12,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }
}
