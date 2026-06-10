part of 'analyse_report_oled_body.dart';

class _VolumeBlock extends StatelessWidget {
  const _VolumeBlock({
    required this.snapshot,
    this.onPrepToggle,
  });

  final AnalyseReportSnapshot snapshot;
  final ValueChanged<String>? onPrepToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final showPoc = !analyseReportOledValueIsEmpty(snapshot.poc);
    final showVah = !analyseReportOledValueIsEmpty(snapshot.vah);
    final showVal = !analyseReportOledValueIsEmpty(snapshot.val);
    final tiles = <Widget>[];
    if (showPoc) {
      tiles.add(
        Expanded(
          child: _VpTile(
            label: 'POC',
            value: snapshot.poc,
            prepId: AnalysePrepCheckIds.volPoc,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
      );
    }
    if (showVah) {
      if (tiles.isNotEmpty) tiles.add(const SizedBox(width: _ReportCompact.gapRow));
      tiles.add(
        Expanded(
          child: _VpTile(
            label: 'VAH',
            value: snapshot.vah,
            prepId: AnalysePrepCheckIds.volVah,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
      );
    }
    if (showVal) {
      if (tiles.isNotEmpty) tiles.add(const SizedBox(width: _ReportCompact.gapRow));
      tiles.add(
        Expanded(
          child: _VpTile(
            label: 'VAL',
            value: snapshot.val,
            prepId: AnalysePrepCheckIds.volVal,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (tiles.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tiles,
          ),
        if (snapshot.noteVolume.trim().isNotEmpty) ...[
          const SizedBox(height: _ReportCompact.gapField),
          _ReadonlyField(
            label: l.ajouterTradePlanRowNotes,
            value: snapshot.noteVolume,
            multiline: true,
            prepId: AnalysePrepCheckIds.volNote,
            onPrepToggle: onPrepToggle,
            snapshot: snapshot,
          ),
        ],
      ],
    );
  }
}

class _VpTile extends StatelessWidget {
  const _VpTile({
    required this.label,
    required this.value,
    this.prepId,
    this.onPrepToggle,
    this.snapshot,
  });

  final String label;
  final String value;
  final String? prepId;
  final ValueChanged<String>? onPrepToggle;
  final AnalyseReportSnapshot? snapshot;

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
          Row(
            children: [
              if (prepId != null &&
                  onPrepToggle != null &&
                  snapshot != null) ...[
                AnalyseReportPrepCheckBox(
                  checked: snapshotIsPrepChecked(snapshot!, prepId!),
                  onToggle: () => onPrepToggle!(prepId!),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(label, style: AnalyseTokens.oledMicroLabel),
              ),
            ],
          ),
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
    this.prepId,
    this.onPrepToggle,
    this.snapshot,
  });

  final String label;
  final String value;
  final bool multiline;
  final String? prepId;
  final ValueChanged<String>? onPrepToggle;
  final AnalyseReportSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final v = value.trim().isEmpty ? '—' : value.trim();
    final showPrep = prepId != null &&
        onPrepToggle != null &&
        snapshot != null &&
        !analyseReportOledValueIsEmpty(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (showPrep) ...[
              AnalyseReportPrepCheckBox(
                checked: snapshotIsPrepChecked(snapshot!, prepId!),
                onToggle: () => onPrepToggle!(prepId!),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                label,
                style: AnalyseTokens.oledSectionLabel.copyWith(
                  color: AnalyseTokens.zinc500,
                ),
              ),
            ),
          ],
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
