import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../analyse/analyse_report_snapshot.dart';
import '../analyse/analyse_tokens.dart';
import '../l10n/app_localizations.dart';
import '../analyse/report_widgets/analyse_report_structure_ui.dart'
    show dashboardStructureSupportResistanceRow;
import '../analyse/report_widgets/analyse_report_ui_primitives.dart'
    show
        AnalyseReportNoteBand,
        analyseReportBiasPill,
        analyseReportContexteTfTrendPhaseRow;
import '../analyse/widgets/analyse_gauge.dart';
import '../checklist/checklist_tokens.dart';
import '../web/web_dashboard_analyse_preview.dart';
import 'dashboard_tokens.dart';

/// Raccourci sous la checklist : aperçu tendance / structure / actif / jauge, chevron → page Analyse.
class DashboardAnalyseShortcut extends StatelessWidget {
  const DashboardAnalyseShortcut({
    super.key,
    required this.snapshot,
    required this.onOpenAnalyse,
    this.cardBackgroundColor,
  });

  /// `null` : titre « Mon analyse » + chevron uniquement (comme checklist vide).
  final AnalyseReportSnapshot? snapshot;
  final VoidCallback onOpenAnalyse;

  final Color? cardBackgroundColor;

  static String _dash(String v) {
    final t = v.trim();
    return t.isEmpty ? '-' : t;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebDashboardAnalysePreview(
        snapshot: snapshot,
        onOpenAnalyse: onOpenAnalyse,
        cardBackgroundColor: cardBackgroundColor,
      );
    }
    final l = AppLocalizations.of(context)!;
    final s = snapshot;
    if (s == null) {
      return ColoredBox(
        color: cardBackgroundColor ?? DashboardTokens.scaffoldMatte,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_graph_outlined,
                size: 18,
                color: ChecklistTokens.sectionTitleOnCardStyle.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.dashboardAnalyseShortcutTitle,
                  style: ChecklistTokens.sectionTitleOnCardStyle.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpenAnalyse,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: ChecklistTokens.sectionTitleOnCardStyle.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ColoredBox(
      color: cardBackgroundColor ?? DashboardTokens.scaffoldMatte,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_graph_outlined,
                  size: 18,
                  color: ChecklistTokens.sectionTitleOnCardStyle.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.dashboardAnalyseShortcutTitle,
                    style: ChecklistTokens.sectionTitleOnCardStyle.copyWith(
                      fontSize: 10,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onOpenAnalyse,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 24,
                        color: ChecklistTokens.sectionTitleOnCardStyle.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ChecklistTokens.sectionHeaderToItemsGap),
            DecoratedBox(
              decoration: AnalyseTokens.reportPanelDecorationForBiasLabel(
                s.biasLabel,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _dash(s.actif),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AnalyseTokens.matteText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                              if (s.sousTitre.trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  s.sousTitre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AnalyseTokens.muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: 110,
                              height: 110,
                              child: AnalyseGauge(
                                feuille: s.gaugeFeuille,
                                structure: s.gaugeStructure,
                                indicators: s.gaugeIndicators,
                                smc: s.gaugeSmc,
                                impactFeuille: s.gaugeImpactFeuille,
                                impactStructure: s.gaugeImpactStructure,
                                impactIndicators: s.gaugeImpactIndicators,
                                impactSmc: s.gaugeImpactSmc,
                                contextEnabled: s.gaugeContextEnabled,
                                structureEnabled: s.gaugeStructureEnabled,
                                indicatorsEnabled: s.gaugeIndicatorsEnabled,
                                smcEnabled: s.gaugeSmcEnabled,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (s.gaugeContextEnabled) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: analyseReportBiasPill(context, s),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 11,
                                color: AnalyseTokens.muted2,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                s.contexteDateLabel ?? '\u2014',
                                style: AnalyseTokens.inlineMutedStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      analyseReportContexteTfTrendPhaseRow(
                        context,
                        contexteTfLine: s.contexteTfLine,
                        trendLabel: s.trendLabel,
                        trendBg: s.trendBg,
                        trendFg: s.trendFg,
                        phaseLabel: s.phaseLabel,
                        phaseBg: s.phaseBg,
                        phaseFg: s.phaseFg,
                      ),
                      if (s.noteContexte.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        AnalyseReportNoteBand(text: s.noteContexte),
                      ],
                    ],
                    if (s.gaugeContextEnabled && s.gaugeStructureEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: AnalyseTokens.cardBorder,
                        ),
                      ),
                    if (s.gaugeStructureEnabled) ...[
                      if (!s.gaugeContextEnabled) const SizedBox(height: 14),
                      Text(l.analyseStructure, style: AnalyseTokens.labelStyle),
                      const SizedBox(height: 6),
                      Text(
                        '${_dash(s.structureTf)} - ${_dash(s.chartisme)}',
                        style: const TextStyle(
                          color: AnalyseTokens.matteText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      dashboardStructureSupportResistanceRow(
                        context: context,
                        supportLabel: l.analyseSupport,
                        supportValue: _dash(s.support),
                        resistLabel: l.analyseResistShort,
                        resistValue: _dash(s.resistance),
                        headerStyle: AnalyseTokens.labelStyle,
                        supportValueStyle: const TextStyle(
                          color: AnalyseTokens.accentGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        resistValueStyle: const TextStyle(
                          color: AnalyseTokens.accentRed,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        structureExtraSupports: s.structureExtraSupports,
                        structureExtraResistances: s.structureExtraResistances,
                        uppercaseHeaders: false,
                      ),
                      for (final copy in s.structureCopies ?? const []) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: AnalyseTokens.cardBorder,
                          ),
                        ),
                        Text(
                          '${_dash(copy.structureTf)} - ${_dash(copy.chartisme)}',
                          style: const TextStyle(
                            color: AnalyseTokens.matteText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        dashboardStructureSupportResistanceRow(
                          context: context,
                          supportLabel: l.analyseSupport,
                          supportValue: _dash(copy.support),
                          resistLabel: l.analyseResistShort,
                          resistValue: _dash(copy.resistance),
                          headerStyle: AnalyseTokens.labelStyle,
                          supportValueStyle: const TextStyle(
                            color: AnalyseTokens.accentGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            height: 1.2,
                          ),
                          resistValueStyle: const TextStyle(
                            color: AnalyseTokens.accentRed,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            height: 1.2,
                          ),
                          structureExtraSupports: copy.structureExtraSupports,
                          structureExtraResistances:
                              copy.structureExtraResistances,
                          uppercaseHeaders: false,
                        ),
                      ],
                      if (s.noteStructure.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        AnalyseReportNoteBand(text: s.noteStructure),
                      ],
                    ],
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



