import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../analyse_confluence_score.dart';
import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';
import 'analyse_report_ui_primitives.dart';

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
  static const padNote = 8.0;
  static const ringRadius = 22.0;
  static const gapColumns = 12.0;
  static const columnsBreakpoint = 720.0;
}

/// Rapport figé : une seule carte (hero + 3 colonnes), sections sans cartes imbriquées.
class AnalyseReportOledBody extends StatelessWidget {
  const AnalyseReportOledBody({
    super.key,
    required this.snapshot,
    this.topBar,
  });

  final AnalyseReportSnapshot snapshot;
  /// Barre d’actions (ex. titre Rapport + icônes) intégrée en haut de la carte.
  final Widget? topBar;

  static List<String> _lines(String main, List<String> extras) {
    final out = <String>[];
    final m = main.trim();
    if (m.isNotEmpty && m != '—') out.add(m);
    for (final e in extras) {
      final t = e.trim();
      if (t.isNotEmpty) out.add(t);
    }
    if (out.isEmpty) return const ['—'];
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final s = snapshot;
    final confColor = oledConfluenceColor(s.confluenceScore);

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
                    confluenceColor: confColor,
                  ),
                  const SizedBox(height: _ReportCompact.gapSection),
                  _ReportThreeColumns(snapshot: s),
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
  const _ReportThreeColumns({required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final s = snapshot;
    final sectionFundamental = _ReportOledSection(
      title: 'FONDAMENTAL',
      accent: AnalyseTokens.oledBlue,
      icon: LucideIcons.landmark,
      confidence: s.gaugeContextEnabled ? s.gaugeFeuille : null,
      child: s.gaugeContextEnabled
          ? _FundamentalBlock(snapshot: s, stacked: true)
          : const _ReportColumnOff(),
    );

    final sectionVolume = s.gaugeVolumeProfileEnabled
        ? _ReportOledSection(
            title: 'VOLUME PROFILE',
            accent: AnalyseTokens.zinc500,
            icon: LucideIcons.barChart3,
            child: _VolumeBlock(snapshot: s),
          )
        : null;

    final sectionZone = _ReportOledSection(
      title: 'ZONE CLÉ',
      accent: AnalyseTokens.oledIndigo,
      icon: LucideIcons.layers,
      confidence: s.gaugeStructureEnabled ? s.gaugeStructure : null,
      child: s.gaugeStructureEnabled
          ? _StructureBlock(snapshot: s, stacked: true)
          : const _ReportColumnOff(),
    );

    final sectionSmc = s.gaugeSmcEnabled
        ? _ReportOledSection(
            title: 'SMC',
            accent: AnalyseTokens.oledIndigo,
            icon: LucideIcons.box,
            confidence: s.gaugeSmc,
            child: _SmcBlock(snapshot: s),
          )
        : null;

    final sectionEntry = _ReportOledSection(
      title: 'ENTRÉE',
      accent: AnalyseTokens.oledGreen,
      icon: LucideIcons.activity,
      confidence: s.gaugeIndicatorsEnabled ? s.gaugeIndicators : null,
      child: s.gaugeIndicatorsEnabled
          ? _EntryBlock(snapshot: s)
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
    return Text(
      'Section masquée',
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
    required this.confluenceColor,
  });

  final AnalyseReportSnapshot snapshot;
  final Color confluenceColor;

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
        _ConfluenceRing(score: snapshot.confluenceScore, color: confluenceColor),
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
          analyseReportBiasPill(context, snapshot),
        ],
      ],
    );
  }
}

class _ConfluenceRing extends StatelessWidget {
  const _ConfluenceRing({required this.score, required this.color});

  final int score;
  final Color color;

  static const _r = _ReportCompact.ringRadius;
  static const _stroke = 3.0;

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
    required this.progressColor,
    required this.dashOffset,
    required this.circumference,
  });

  final double radius;
  final double stroke;
  final Color progressColor;
  final double dashOffset;
  final double circumference;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final track = Paint()
      ..color = const Color(0xFF14151B)
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

class _FundamentalBlock extends StatelessWidget {
  const _FundamentalBlock({required this.snapshot, this.stacked = false});

  final AnalyseReportSnapshot snapshot;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final tfRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ReadonlyField(label: 'TIMEFRAME', value: snapshot.contexteTfLine)),
        const SizedBox(width: _ReportCompact.gapRow),
        Expanded(child: _ReadonlyField(label: 'TENDANCE', value: snapshot.trendLabel)),
        const SizedBox(width: _ReportCompact.gapRow),
        Expanded(child: _ReadonlyField(label: 'PHASE', value: snapshot.phaseLabel)),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tfRow,
        if (snapshot.noteStructure.trim().isNotEmpty) ...[
          const SizedBox(height: _ReportCompact.gapField),
          _ReadonlyField(label: 'STRUCTURE', value: snapshot.noteStructure, multiline: true),
        ],
        if (snapshot.noteContexte.trim().isNotEmpty) ...[
          const SizedBox(height: _ReportCompact.gapField),
          _ReadonlyField(label: 'NOTES MACRO', value: snapshot.noteContexte, multiline: true),
        ],
      ],
    );
  }
}

class _StructureBlock extends StatelessWidget {
  const _StructureBlock({required this.snapshot, this.stacked = false});

  final AnalyseReportSnapshot snapshot;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final head = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ReadonlyField(label: 'TIMEFRAME', value: snapshot.structureTf)),
        const SizedBox(width: _ReportCompact.gapRow),
        Expanded(child: _ReadonlyField(label: 'CHARTISME', value: snapshot.chartisme)),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        head,
        const SizedBox(height: _ReportCompact.gapField),
        _SrRow(
          support: snapshot.support,
          resistance: snapshot.resistance,
        ),
      ],
    );
  }
}

/// Support / résistance : préfixe S / R + prix uniquement.
class _SrLevelField extends StatelessWidget {
  const _SrLevelField({
    required this.prefix,
    required this.price,
    required this.accent,
  });

  final String prefix;
  final String price;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final display = price.trim().isEmpty ? '—' : price.trim();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _ReportCompact.padFieldX,
        vertical: _ReportCompact.padFieldY,
      ),
      decoration: AnalyseTokens.reportFieldDecoration,
      child: Row(
        children: [
          Text(
            prefix,
            style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 9),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              display,
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SrRow extends StatelessWidget {
  const _SrRow({
    required this.support,
    required this.resistance,
  });

  final String support;
  final String resistance;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SrLevelField(
            prefix: 'S',
            price: support,
            accent: AnalyseTokens.oledGreen,
          ),
        ),
        const SizedBox(width: _ReportCompact.gapRow),
        Expanded(
          child: _SrLevelField(
            prefix: 'R',
            price: resistance,
            accent: AnalyseTokens.oledRed,
          ),
        ),
      ],
    );
  }
}

class _SmcBlock extends StatelessWidget {
  const _SmcBlock({required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final obLines = AnalyseReportOledBody._lines(snapshot.smcOb, snapshot.smcObExtras);
    final fvgLines = AnalyseReportOledBody._lines(snapshot.smcFvg, snapshot.smcFvgExtras);
    final liqLines = AnalyseReportOledBody._lines(snapshot.smcLiq, snapshot.smcLiquidityExtras);

    return Container(
      padding: const EdgeInsets.all(_ReportCompact.padSmcPanel),
      decoration: BoxDecoration(
        color: AnalyseTokens.smcPanelBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xCC312E81)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SmcFieldGroup(label: 'Order Block (OB)', lines: obLines),
          const SizedBox(height: _ReportCompact.gapBlock),
          _SmcFieldGroup(label: 'Fair Value Gap (FVG)', lines: fvgLines),
          const SizedBox(height: _ReportCompact.gapBlock),
          _SmcFieldGroup(label: 'Liquidité', lines: liqLines),
          const SizedBox(height: _ReportCompact.gapBlock),
          Text('Fibonacci', style: AnalyseTokens.oledSmcFieldLabel),
          const SizedBox(height: 4),
          Row(
            children: [
              if (snapshot.smcFibOteLabel.isNotEmpty)
                _NeutralPill(label: snapshot.smcFibOteLabel),
              if (snapshot.smcFibOteLabel.isNotEmpty) const SizedBox(width: _ReportCompact.gapRow),
              Expanded(
                child: Text(
                  snapshot.smcFibPrice,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AnalyseTokens.zinc200,
                  ),
                ),
              ),
            ],
          ),
          if (snapshot.noteSmc.trim().isNotEmpty) ...[
            const SizedBox(height: _ReportCompact.gapBlock),
            _NoteBox(text: snapshot.noteSmc),
          ],
        ],
      ),
    );
  }
}

class _SmcFieldGroup extends StatelessWidget {
  const _SmcFieldGroup({required this.label, required this.lines});

  final String label;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AnalyseTokens.oledSmcFieldLabel),
        const SizedBox(height: 4),
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          _DeepValueBox(text: lines[i]),
        ],
      ],
    );
  }
}

class _EntryBlock extends StatelessWidget {
  const _EntryBlock({required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final head = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ReadonlyField(label: 'TIMEFRAME', value: snapshot.indicatorsTf)),
        const SizedBox(width: _ReportCompact.gapRow),
        Expanded(
          child: _ReadonlyField(label: 'SIGNAUX', value: snapshot.indicateursOutils),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        head,
        const SizedBox(height: _ReportCompact.gapField),
        _ReadonlyField(
          label: "PLAN D'ACTION",
          value: snapshot.noteIndicators,
          multiline: true,
        ),
      ],
    );
  }
}

class _VolumeBlock extends StatelessWidget {
  const _VolumeBlock({required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _VpTile(label: 'POC', value: snapshot.poc)),
            const SizedBox(width: _ReportCompact.gapRow),
            Expanded(child: _VpTile(label: 'VAH', value: snapshot.vah)),
            const SizedBox(width: _ReportCompact.gapRow),
            Expanded(child: _VpTile(label: 'VAL', value: snapshot.val)),
          ],
        ),
        if (snapshot.noteVolume.trim().isNotEmpty) ...[
          const SizedBox(height: _ReportCompact.gapField),
          _NoteBox(text: snapshot.noteVolume),
        ],
      ],
    );
  }
}

class _VpTile extends StatelessWidget {
  const _VpTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: _ReportCompact.padFieldY,
        horizontal: _ReportCompact.padFieldX,
      ),
      decoration: AnalyseTokens.reportFieldDecoration,
      child: Column(
        children: [
          Text(label, style: AnalyseTokens.oledMicroLabel),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final v = value.trim().isEmpty ? '—' : value.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AnalyseTokens.oledSectionLabel.copyWith(color: AnalyseTokens.zinc500),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: _ReportCompact.padFieldX,
            vertical: multiline ? _ReportCompact.padFieldMultilineY : _ReportCompact.padFieldY,
          ),
          decoration: AnalyseTokens.reportFieldDecoration,
          child: Text(
            v,
            maxLines: multiline ? null : 2,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AnalyseTokens.zinc200,
              height: multiline ? 1.3 : 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeepValueBox extends StatelessWidget {
  const _DeepValueBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: _ReportCompact.padFieldX,
        vertical: _ReportCompact.padFieldY,
      ),
      decoration: AnalyseTokens.reportFieldDecoration,
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_ReportCompact.padNote),
      decoration: AnalyseTokens.reportFieldDecoration,
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AnalyseTokens.zinc400,
          height: 1.3,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _NeutralPill extends StatelessWidget {
  const _NeutralPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: AnalyseTokens.reportFieldDecoration,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AnalyseTokens.zinc300,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
