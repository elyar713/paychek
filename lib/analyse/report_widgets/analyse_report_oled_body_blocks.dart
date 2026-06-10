part of 'analyse_report_oled_body.dart';

class _FundamentalBlock extends StatelessWidget {
  const _FundamentalBlock({
    required this.snapshot,
    this.onPrepToggle,
  });

  final AnalyseReportSnapshot snapshot;
  final ValueChanged<String>? onPrepToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tfRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ReadonlyField(
            label: l.analyseTimeframeLabelShort,
            value: snapshot.contexteTfLine,
            prepId: AnalysePrepCheckIds.ctxTimeframe,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
        const SizedBox(width: _ReportCompact.gapRow),
        Expanded(
          child: _ReadonlyField(
            label: l.analyseTrend,
            value: snapshot.trendLabel,
            prepId: AnalysePrepCheckIds.ctxTrend,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
        const SizedBox(width: _ReportCompact.gapRow),
        Expanded(
          child: _ReadonlyField(
            label: l.analysePhase,
            value: snapshot.phaseLabel,
            prepId: AnalysePrepCheckIds.ctxPhase,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tfRow,
        if (snapshot.noteStructure.trim().isNotEmpty) ...[
          const SizedBox(height: _ReportCompact.gapField),
          _ReadonlyField(
            label: l.analyseStructure,
            value: snapshot.noteStructure,
            multiline: true,
            prepId: AnalysePrepCheckIds.structNote,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ],
        if (snapshot.noteContexte.trim().isNotEmpty) ...[
          const SizedBox(height: _ReportCompact.gapField),
          _ReadonlyField(
            label: l.analyseReportOledFieldMacroNotes,
            value: snapshot.noteContexte,
            multiline: true,
            prepId: AnalysePrepCheckIds.ctxNote,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ],
      ],
    );
  }
}

class _StructureBlock extends StatelessWidget {
  const _StructureBlock({
    required this.snapshot,
    this.onPrepToggle,
  });

  final AnalyseReportSnapshot snapshot;
  final ValueChanged<String>? onPrepToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final headChildren = <Widget>[];
    if (!analyseReportOledValueIsEmpty(snapshot.structureTf)) {
      headChildren.add(
        Expanded(
          child: _ReadonlyField(
            label: l.analyseTimeframeLabelShort,
            value: snapshot.structureTf,
            prepId: AnalysePrepCheckIds.structTf,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
      );
    }
    if (!analyseReportOledValueIsEmpty(snapshot.chartisme)) {
      if (headChildren.isNotEmpty) {
        headChildren.add(const SizedBox(width: _ReportCompact.gapRow));
      }
      headChildren.add(
        Expanded(
          child: _ReadonlyField(
            label: l.analyseReportOledFieldChartism,
            value: snapshot.chartisme,
            prepId: AnalysePrepCheckIds.structChartisme,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
      );
    }
    final head = headChildren.isEmpty
        ? const SizedBox.shrink()
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: headChildren,
          );

    final showSupport = !analyseReportOledValueIsEmpty(snapshot.support);
    final showResistance = !analyseReportOledValueIsEmpty(snapshot.resistance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (headChildren.isNotEmpty) head,
        if (headChildren.isNotEmpty && (showSupport || showResistance))
          const SizedBox(height: _ReportCompact.gapField),
        if (showSupport || showResistance)
          _SrRow(
            support: snapshot.support,
            resistance: snapshot.resistance,
            showSupport: showSupport,
            showResistance: showResistance,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
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
    this.prepId,
    this.onPrepToggle,
    this.snapshot,
  });

  final String prefix;
  final String price;
  final Color accent;
  final String? prepId;
  final ValueChanged<String>? onPrepToggle;
  final AnalyseReportSnapshot? snapshot;

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
          if (prepId != null &&
              onPrepToggle != null &&
              snapshot != null &&
              !analyseReportOledValueIsEmpty(price)) ...[
            AnalyseReportPrepCheckBox(
              checked: snapshotIsPrepChecked(snapshot!, prepId!),
              onToggle: () => onPrepToggle!(prepId!),
            ),
            const SizedBox(width: 4),
          ],
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
    required this.showSupport,
    required this.showResistance,
    this.onPrepToggle,
    this.snapshot,
  });

  final String support;
  final String resistance;
  final bool showSupport;
  final bool showResistance;
  final ValueChanged<String>? onPrepToggle;
  final AnalyseReportSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (showSupport) {
      children.add(
        Expanded(
          child: _SrLevelField(
            prefix: 'S',
            price: support,
            accent: AnalyseTokens.oledGreen,
            prepId: AnalysePrepCheckIds.structSupport,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
      );
    }
    if (showSupport && showResistance) {
      children.add(const SizedBox(width: _ReportCompact.gapRow));
    }
    if (showResistance) {
      children.add(
        Expanded(
          child: _SrLevelField(
            prefix: 'R',
            price: resistance,
            accent: AnalyseTokens.oledRed,
            prepId: AnalysePrepCheckIds.structResistance,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
