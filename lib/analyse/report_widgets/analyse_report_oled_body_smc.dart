part of 'analyse_report_oled_body.dart';

class _SmcBlock extends StatelessWidget {
  const _SmcBlock({
    required this.snapshot,
    this.onPrepToggle,
  });

  final AnalyseReportSnapshot snapshot;
  final ValueChanged<String>? onPrepToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final obLines = AnalyseReportOledBody._lines(snapshot.smcOb, snapshot.smcObExtras);
    final fvgLines = AnalyseReportOledBody._lines(snapshot.smcFvg, snapshot.smcFvgExtras);
    final liqLines = AnalyseReportOledBody._lines(snapshot.smcLiq, snapshot.smcLiquidityExtras);
    final showFib = snapshot.smcFibOteLabel.trim().isNotEmpty ||
        !analyseReportOledValueIsEmpty(snapshot.smcFibPrice);

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
          if (obLines.isNotEmpty) ...[
            _SmcFieldGroup(
              label: l.analyseOrderBlock,
              lines: obLines,
              prepId: AnalysePrepCheckIds.smcOb,
              onPrepToggle: onPrepToggle,
              snapshot: snapshot,
            ),
            const SizedBox(height: _ReportCompact.gapBlock),
          ],
          if (fvgLines.isNotEmpty) ...[
            _SmcFieldGroup(
              label: l.analyseFvg,
              lines: fvgLines,
              prepId: AnalysePrepCheckIds.smcFvg,
              onPrepToggle: onPrepToggle,
              snapshot: snapshot,
            ),
            const SizedBox(height: _ReportCompact.gapBlock),
          ],
          if (liqLines.isNotEmpty) ...[
            _SmcFieldGroup(
              label: l.analyseReportOledLiquidity,
              lines: liqLines,
              prepId: AnalysePrepCheckIds.smcLiq,
              onPrepToggle: onPrepToggle,
              snapshot: snapshot,
            ),
            const SizedBox(height: _ReportCompact.gapBlock),
          ],
          if (showFib)
            _SmcFibRow(
              snapshot: snapshot,
              onPrepToggle: onPrepToggle,
            ),
          if (snapshot.noteSmc.trim().isNotEmpty) ...[
            const SizedBox(height: _ReportCompact.gapBlock),
            _ReadonlyField(
              label: l.ajouterTradePlanRowNotes,
              value: snapshot.noteSmc,
              multiline: true,
              prepId: AnalysePrepCheckIds.smcNote,
              onPrepToggle: onPrepToggle,
              snapshot: snapshot,
            ),
          ],
        ],
      ),
    );
  }
}

class _SmcFieldGroup extends StatelessWidget {
  const _SmcFieldGroup({
    required this.label,
    required this.lines,
    this.prepId,
    this.onPrepToggle,
    this.snapshot,
  });

  final String label;
  final List<String> lines;
  final String? prepId;
  final ValueChanged<String>? onPrepToggle;
  final AnalyseReportSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (prepId != null &&
                onPrepToggle != null &&
                snapshot != null) ...[
              AnalyseReportPrepCheckBox(
                checked: snapshotIsPrepChecked(snapshot!, prepId!),
                onToggle: () => onPrepToggle!(prepId!),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(label, style: AnalyseTokens.oledSmcFieldLabel),
            ),
          ],
        ),
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
  const _EntryBlock({
    required this.snapshot,
    this.onPrepToggle,
  });

  final AnalyseReportSnapshot snapshot;
  final ValueChanged<String>? onPrepToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final headChildren = <Widget>[];
    if (!analyseReportOledValueIsEmpty(snapshot.indicatorsTf)) {
      headChildren.add(
        Expanded(
          child: _ReadonlyField(
            label: l.analyseTimeframeLabelShort,
            value: snapshot.indicatorsTf,
            prepId: AnalysePrepCheckIds.indTf,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
      );
    }
    if (!analyseReportOledValueIsEmpty(snapshot.indicateursOutils)) {
      if (headChildren.isNotEmpty) {
        headChildren.add(const SizedBox(width: _ReportCompact.gapRow));
      }
      headChildren.add(
        Expanded(
          child: _ReadonlyField(
            label: l.analyseReportOledFieldSignals,
            value: snapshot.indicateursOutils,
            prepId: AnalysePrepCheckIds.indOutils,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (headChildren.isNotEmpty) head,
        if (headChildren.isNotEmpty && snapshot.noteIndicators.trim().isNotEmpty)
          const SizedBox(height: _ReportCompact.gapField),
        if (snapshot.noteIndicators.trim().isNotEmpty)
          _ReadonlyField(
            label: l.analyseReportOledFieldActionPlan,
            value: snapshot.noteIndicators,
            multiline: true,
            prepId: AnalysePrepCheckIds.indNote,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
      ],
    );
  }
}

class _SmcFibRow extends StatelessWidget {
  const _SmcFibRow({
    required this.snapshot,
    this.onPrepToggle,
  });

  final AnalyseReportSnapshot snapshot;
  final ValueChanged<String>? onPrepToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final showOte = snapshot.smcFibOteLabel.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (onPrepToggle != null &&
                !analyseReportOledValueIsEmpty(snapshot.smcFibPrice)) ...[
              AnalyseReportPrepCheckBox(
                checked: snapshotIsPrepChecked(
                  snapshot,
                  AnalysePrepCheckIds.smcFibPrix,
                ),
                onToggle: () => onPrepToggle!(AnalysePrepCheckIds.smcFibPrix),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                l.analyseFibShort,
                style: AnalyseTokens.oledSmcFieldLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (showOte) ...[
              if (onPrepToggle != null) ...[
                AnalyseReportPrepCheckBox(
                  checked: snapshotIsPrepChecked(
                    snapshot,
                    AnalysePrepCheckIds.smcOte,
                  ),
                  onToggle: () => onPrepToggle!(AnalysePrepCheckIds.smcOte),
                ),
                const SizedBox(width: 4),
              ],
              _NeutralPill(label: snapshot.smcFibOteLabel),
              const SizedBox(width: _ReportCompact.gapRow),
            ],
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
      ],
    );
  }
}
