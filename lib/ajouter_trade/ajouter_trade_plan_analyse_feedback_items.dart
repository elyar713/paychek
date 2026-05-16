import 'package:flutter/material.dart';

import '../analyse/analyse_phase_locale.dart';
import '../analyse/analyse_report_snapshot.dart';
import '../l10n/app_localizations.dart';

/// Entrée dans la liste (en-tête de section ou ligne cochable).
sealed class PlanAnalyseFeedbackEntry {
  const PlanAnalyseFeedbackEntry();
}

/// Libellé de section (texte gris au-dessus d’un groupe de critères).
final class PlanAnalyseFeedbackSectionHeader extends PlanAnalyseFeedbackEntry {
  const PlanAnalyseFeedbackSectionHeader(this.title);

  final String title;
}

/// Ligne cochable : [label] court (ex. « Support »), [hint] = valeur (ex. « 2200 »).
final class PlanAnalyseFeedbackRow extends PlanAnalyseFeedbackEntry {
  const PlanAnalyseFeedbackRow({
    required this.id,
    required this.label,
    this.hint,
  });

  final String id;
  final String label;
  final String? hint;
}

String _dash(String? v) {
  final t = v?.trim() ?? '';
  return t.isEmpty ? '—' : t;
}

void _pushRow(
  List<PlanAnalyseFeedbackRow> buf,
  String id,
  String label,
  String? hint,
) {
  buf.add(PlanAnalyseFeedbackRow(id: id, label: label, hint: hint));
}

void _flushSection(
  List<PlanAnalyseFeedbackEntry> out,
  String title,
  List<PlanAnalyseFeedbackRow> rows,
) {
  if (rows.isEmpty) return;
  out.add(PlanAnalyseFeedbackSectionHeader(title));
  out.addAll(rows);
}

/// Liste ordonnée : en-têtes de section + lignes (valeurs en hint).
List<PlanAnalyseFeedbackEntry> planAnalyseFeedbackEntriesFor(
  AnalyseReportSnapshot s,
  AppLocalizations l,
) {
  final out = <PlanAnalyseFeedbackEntry>[];
  final phaseLocale = Locale(l.localeName);

  if (s.gaugeContextEnabled) {
    final main = <PlanAnalyseFeedbackRow>[];
    _pushRow(main, 'ctx_bias', l.ajouterTradePlanRowBias, s.biasLabel);
    _pushRow(main, 'ctx_timeframe', l.ajouterTradePlanRowTimeframeHtf, s.contexteTfLine);
    _pushRow(
      main,
      'ctx_phase',
      l.ajouterTradePlanRowPhase,
      localizeStoredAnalysePhase(s.phaseLabel, phaseLocale),
    );
    _pushRow(main, 'ctx_trend', l.analyseTrendLabel, s.trendLabel);
    final n = s.noteContexte.trim();
    if (n.isNotEmpty) {
      _pushRow(main, 'ctx_note', l.ajouterTradePlanRowNotes, n);
    }
    _flushSection(out, l.analyseTrend, main);

    final copies = s.contexteCopies;
    if (copies != null && copies.isNotEmpty) {
      for (var i = 0; i < copies.length; i++) {
        final c = copies[i];
        final p = i + 1;
        final block = <PlanAnalyseFeedbackRow>[];
        _pushRow(block, 'ctx_c${p}_bias', l.ajouterTradePlanRowBias, c.biasLabel);
        _pushRow(block, 'ctx_c${p}_tf', l.ajouterTradePlanRowTimeframeHtf, c.contexteTfLine);
        _pushRow(
          block,
          'ctx_c${p}_phase',
          l.ajouterTradePlanRowPhase,
          localizeStoredAnalysePhase(c.phaseLabel, phaseLocale),
        );
        _pushRow(block, 'ctx_c${p}_trend', l.analyseTrendLabel, c.trendLabel);
        _flushSection(out, '${l.analyseTrend} — ${l.analyseCopyNumber(p)}', block);
      }
    }
  }

  if (s.gaugeStructureEnabled) {
    final main = <PlanAnalyseFeedbackRow>[];
    _pushRow(main, 'struct_tf', l.analyseTimeframeLabelShort, s.structureTf);
    _pushRow(main, 'struct_chartisme', l.ajouterTradePlanRowLastPoint, s.chartisme);
    _pushRow(main, 'struct_support', l.analyseSupportLower, s.support);
    _pushRow(main, 'struct_resistance', l.analyseResistLower, s.resistance);
    final es = s.structureExtraSupports;
    if (es != null) {
      for (var i = 0; i < es.length; i++) {
        final e = es[i];
        final tenue = e.tenueLabel;
        final h = tenue == null || tenue.isEmpty
            ? e.priceLabel
            : '${e.priceLabel} • $tenue';
        _pushRow(
          main,
          'struct_extra_support_$i',
          l.ajouterTradePlanRowExtraSupport(i + 1),
          h,
        );
      }
    }
    final er = s.structureExtraResistances;
    if (er != null) {
      for (var i = 0; i < er.length; i++) {
        final e = er[i];
        final tenue = e.tenueLabel;
        final h = tenue == null || tenue.isEmpty
            ? e.priceLabel
            : '${e.priceLabel} • $tenue';
        _pushRow(
          main,
          'struct_extra_resistance_$i',
          l.ajouterTradePlanRowExtraResistance(i + 1),
          h,
        );
      }
    }
    final ns = s.noteStructure.trim();
    if (ns.isNotEmpty) {
      _pushRow(main, 'struct_note', l.ajouterTradePlanRowNotes, ns);
    }
    _flushSection(out, l.analyseStructure, main);

    final sc = s.structureCopies;
    if (sc != null && sc.isNotEmpty) {
      for (var i = 0; i < sc.length; i++) {
        final c = sc[i];
        final p = i + 1;
        final block = <PlanAnalyseFeedbackRow>[];
        _pushRow(block, 'struct_c${p}_tf', l.analyseTimeframeLabelShort, c.structureTf);
        _pushRow(block, 'struct_c${p}_chartisme', l.ajouterTradePlanRowLastPoint, c.chartisme);
        _pushRow(block, 'struct_c${p}_support', l.analyseSupportLower, c.support);
        _pushRow(block, 'struct_c${p}_resistance', l.analyseResistLower, c.resistance);
        for (var j = 0; j < c.structureExtraSupports.length; j++) {
          final e = c.structureExtraSupports[j];
          final tenue = e.tenueLabel;
          final h = tenue == null || tenue.isEmpty
              ? e.priceLabel
              : '${e.priceLabel} • $tenue';
          _pushRow(
            block,
            'struct_c${p}_exs_$j',
            l.ajouterTradePlanRowExtraSupport(j + 1),
            h,
          );
        }
        for (var j = 0; j < c.structureExtraResistances.length; j++) {
          final e = c.structureExtraResistances[j];
          final tenue = e.tenueLabel;
          final h = tenue == null || tenue.isEmpty
              ? e.priceLabel
              : '${e.priceLabel} • $tenue';
          _pushRow(
            block,
            'struct_c${p}_exr_$j',
            l.ajouterTradePlanRowExtraResistance(j + 1),
            h,
          );
        }
        _flushSection(out, '${l.analyseStructure} — ${l.analyseCopyNumber(p)}', block);
      }
    }
  }

  if (s.gaugeIndicatorsEnabled) {
    final main = <PlanAnalyseFeedbackRow>[];
    _pushRow(main, 'ind_tf', l.analyseTimeframeLabelShort, s.indicatorsTf);
    _pushRow(main, 'ind_outils', l.ajouterTradePlanRowOutils, s.indicateursOutils);
    final ni = s.noteIndicators.trim();
    if (ni.isNotEmpty) {
      _pushRow(main, 'ind_note', l.ajouterTradePlanRowNotes, ni);
    }
    _flushSection(out, l.strategieIndicators, main);

    final ic = s.indicatorsCopies;
    if (ic != null && ic.isNotEmpty) {
      for (var i = 0; i < ic.length; i++) {
        final c = ic[i];
        final p = i + 1;
        final block = <PlanAnalyseFeedbackRow>[];
        _pushRow(block, 'ind_c${p}_tf', l.analyseTimeframeLabelShort, c.indicatorsTf);
        _pushRow(block, 'ind_c${p}_outils', l.ajouterTradePlanRowOutils, c.indicateursOutils);
        final n = c.noteIndicators.trim();
        if (n.isNotEmpty) {
          _pushRow(block, 'ind_c${p}_note', l.ajouterTradePlanRowNotes, n);
        }
        _flushSection(out, '${l.strategieIndicators} — ${l.analyseCopyNumber(p)}', block);
      }
    }
  }

  if (s.gaugeSmcEnabled) {
    final main = <PlanAnalyseFeedbackRow>[];
    _pushRow(main, 'smc_ob', 'Order block', _dash(s.smcOb));
    _pushRow(main, 'smc_fvg', 'FVG', _dash(s.smcFvg));
    _pushRow(main, 'smc_liq', l.ajouterTradePlanRowLiquidity, _dash(s.smcLiq));
    _pushRow(main, 'smc_fib_prix', l.ajouterTradePlanRowFibPrice, _dash(s.smcFibPrice));
    final ote = s.smcFibOteLabel.trim();
    if (ote.isNotEmpty) {
      _pushRow(main, 'smc_ote', 'OTE', ote);
    }
    final ns = s.noteSmc.trim();
    if (ns.isNotEmpty) {
      _pushRow(main, 'smc_note', l.ajouterTradePlanRowNotes, ns);
    }
    _flushSection(out, 'SMC', main);

    final sc = s.smcCopies;
    if (sc != null && sc.isNotEmpty) {
      for (var i = 0; i < sc.length; i++) {
        final c = sc[i];
        final p = i + 1;
        final block = <PlanAnalyseFeedbackRow>[];
        _pushRow(block, 'smc_c${p}_ob', 'Order block', _dash(c.smcOb));
        _pushRow(block, 'smc_c${p}_fvg', 'FVG', _dash(c.smcFvg));
        _pushRow(block, 'smc_c${p}_liq', l.ajouterTradePlanRowLiquidity, _dash(c.smcLiq));
        _pushRow(block, 'smc_c${p}_fib', l.ajouterTradePlanRowFibPrice, _dash(c.smcFibPrice));
        final cot = c.smcFibOteLabel.trim();
        if (cot.isNotEmpty) {
          _pushRow(block, 'smc_c${p}_ote', 'OTE', cot);
        }
        final n = c.noteSmc.trim();
        if (n.isNotEmpty) {
          _pushRow(block, 'smc_c${p}_note', l.ajouterTradePlanRowNotes, n);
        }
        _flushSection(out, 'SMC — ${l.analyseCopyNumber(p)}', block);
      }
    }
  }

  if (s.gaugeVolumeProfileEnabled) {
    final main = <PlanAnalyseFeedbackRow>[];
    _pushRow(main, 'vol_poc', l.analyseVolumePoc, _dash(s.poc));
    _pushRow(main, 'vol_vah', l.analyseVolumeVah, _dash(s.vah));
    _pushRow(main, 'vol_val', l.analyseVolumeVal, _dash(s.val));
    final nv = s.noteVolume.trim();
    if (nv.isNotEmpty) {
      _pushRow(main, 'vol_note', l.ajouterTradePlanRowNotes, nv);
    }
    _flushSection(out, l.ajouterTradePlanSectionVolume, main);
  }

  return out;
}
