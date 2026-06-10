part of 'coach_ai_page.dart';

extension _CoachAiPageUi on _CoachAiPageState {
  String _extractSectionBody(String text, String sectionNumber) {
    final normalized = text.replaceAll('\r\n', '\n');
    final start = RegExp('^\\s*$sectionNumber\\)', multiLine: true).firstMatch(normalized);
    if (start == null) return '';
    final afterStart = normalized.substring(start.end).trimLeft();
    final next = RegExp(r'^\s*[0-9]+\)', multiLine: true).firstMatch(afterStart);
    final body = next == null
        ? afterStart
        : afterStart.substring(0, next.start);
    return body
        .replaceAll(RegExp(r'^\s*[-*]\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  Widget _kpiTile(String label, String value, {Color? valueColor}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: valueColor ?? const Color(0xFF34D399),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _disciplinePillarCard(_CoachDisciplinePillar pillar) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(pillar.icon, size: 15, color: const Color(0xFF34D399)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pillar.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ENREGISTRÉ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pillar.recorded}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        color: const Color(0xFF34D399),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NON ENREG.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pillar.missing}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        color: const Color(0xFFF87171),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${pillar.recordedPercent}% complété · ${pillar.nonRespect} non-respect',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              height: 1.35,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _performanceMetricChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: _coachText(
              size: 9.2,
              color: const Color(0xFF9CA3AF),
              weight: FontWeight.w800,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: _coachText(
              size: 13,
              color: color ?? Colors.white,
              weight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _performancePillarSection(_CoachDisciplinePillar pillar) {
    final winrate = pillar.winrateRecorded.toStringAsFixed(1);
    final pnlColor = pillar.pnlRecorded >= 0
        ? const Color(0xFF34D399)
        : const Color(0xFFF87171);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Icon(pillar.icon, size: 16, color: const Color(0xFF34D399)),
                const SizedBox(width: 8),
                Text(
                  pillar.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _performanceMetricChip(
                  'Enregistrés',
                  '${pillar.recorded}/${pillar.total}',
                  color: const Color(0xFF34D399),
                ),
                _performanceMetricChip(
                  'Non enregistrés',
                  '${pillar.missing}',
                  color: const Color(0xFFF87171),
                ),
                _performanceMetricChip(
                  'Winrate (enreg.)',
                  '$winrate%',
                  color: pillar.recordedClosed > 0
                      ? const Color(0xFF34D399)
                      : const Color(0xFF9CA3AF),
                ),
                _performanceMetricChip(
                  'PnL (enreg.)',
                  '${pillar.pnlRecorded}',
                  color: pillar.recordedClosed > 0 ? pnlColor : const Color(0xFF9CA3AF),
                ),
                _performanceMetricChip(
                  'Non-respect',
                  '${pillar.nonRespect}',
                  color: pillar.nonRespect > 0
                      ? const Color(0xFFF87171)
                      : const Color(0xFF34D399),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _coachText({
    double size = 14,
    Color color = const Color(0xFFD1D5DB),
    FontWeight weight = FontWeight.w500,
    double height = 1.45,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: height,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  Widget _coachMentalFocusTitle(String title) {
    final colon = title.indexOf(':');
    if (colon < 0) {
      return Text(title, style: _coachText(size: 15, color: Colors.white, weight: FontWeight.w800));
    }
    final prefix = title.substring(0, colon + 1);
    final focus = title.substring(colon + 1).trim();
    return RichText(
      text: TextSpan(
        style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
        children: [
          TextSpan(text: prefix),
          const TextSpan(text: '\n'),
          TextSpan(
            text: focus,
            style: _coachText(size: 16, color: const Color(0xFF34D399), weight: FontWeight.w800, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _coachCoverageLine({
    required int tradesEtat,
    required int? tradesMetric,
    required String? metricLabel,
    required double? split,
  }) {
    final spans = <TextSpan>[
      TextSpan(
        text: '$tradesEtat',
        style: _coachText(size: 12, color: const Color(0xFF34D399), weight: FontWeight.w800),
      ),
      TextSpan(
        text: ' trades avec état mental',
        style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
      ),
    ];
    if (tradesMetric != null && metricLabel != null) {
      spans.addAll([
        TextSpan(text: '  ·  ', style: _coachText(size: 13, color: const Color(0xFF4B5563), weight: FontWeight.w700)),
        TextSpan(
          text: '$tradesMetric',
          style: _coachText(size: 12, color: const Color(0xFF60A5FA), weight: FontWeight.w800),
        ),
        TextSpan(
          text: ' avec curseur ',
          style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
        ),
        TextSpan(
          text: metricLabel,
          style: _coachText(size: 13, color: const Color(0xFF93C5FD), weight: FontWeight.w800),
        ),
      ]);
    }
    if (split != null) {
      spans.addAll([
        TextSpan(text: '  ·  ', style: _coachText(size: 13, color: const Color(0xFF4B5563), weight: FontWeight.w700)),
        TextSpan(
          text: 'seuil ',
          style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
        ),
        TextSpan(
          text: '~${split.toStringAsFixed(0)}',
          style: _coachText(size: 12, color: const Color(0xFFF59E0B), weight: FontWeight.w800),
        ),
      ]);
    }
    return RichText(text: TextSpan(children: spans));
  }

  Widget _coachWinrateBar(double percent, {Color? fill}) {
    final p = percent.clamp(0, 100) / 100;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: p,
        minHeight: 6,
        backgroundColor: const Color(0xFF1F2937),
        color: fill ?? const Color(0xFF34D399),
      ),
    );
  }

  Widget _coachMentalCompareColumn({
    required String title,
    required String subtitle,
    required int trades,
    required int closed,
    required double winrate,
    required double pnl,
    required bool isPrimary,
  }) {
    final pnlColor =
        pnl >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171);
    final borderColor =
        isPrimary ? const Color(0xFF10B981) : const Color(0xFF374151);
    final bg = isPrimary
        ? const Color(0xFF064E3B).withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.28);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isPrimary ? 1.2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: _coachText(
                size: 13,
                letterSpacing: 0.7,
                color: isPrimary ? const Color(0xFF6EE7B7) : const Color(0xFFCBD5E1),
                weight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: _coachText(
                size: 12.5,
                color: isPrimary ? const Color(0xFF34D399) : const Color(0xFF9CA3AF),
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$trades',
              style: _coachText(
                size: 28,
                height: 1,
                color: isPrimary ? Colors.white : const Color(0xFFE5E7EB),
                weight: FontWeight.w800,
              ),
            ),
            Text(
              'TRADES',
              style: _coachText(
                size: 9.5,
                color: const Color(0xFF6B7280),
                weight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'WINRATE',
                  style: _coachText(
                    size: 10,
                    color: const Color(0xFFE5E7EB),
                    weight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                Text(
                  closed > 0 ? '${winrate.toStringAsFixed(1)}%' : '—',
                  style: _coachText(
                    size: 14,
                    color: closed > 0
                        ? (winrate >= 50
                            ? const Color(0xFF34D399)
                            : const Color(0xFFF87171))
                        : const Color(0xFF6B7280),
                    weight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _coachWinrateBar(
              closed > 0 ? winrate : 0,
              fill: winrate >= 50
                  ? const Color(0xFF34D399)
                  : const Color(0xFFF87171),
            ),
            const SizedBox(height: 10),
            Text(
              'PnL',
              style: _coachText(
                size: 10,
                color: const Color(0xFFE5E7EB),
                weight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              closed > 0 ? pnl.toStringAsFixed(1) : '—',
              style: _coachText(
                size: 18,
                color: closed > 0 ? pnlColor : const Color(0xFF6B7280),
                weight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mentalCompareLabels(CoachMentalQuery query) {
    if (query.kind == 'emotion') {
      return 'Avec ${query.label}|Sans ${query.label}';
    }
    return switch (query.polarity) {
      'high' => 'Niveau haut|Niveau bas',
      _ => 'Niveau bas|Niveau haut',
    };
  }

  Widget _coachNarrativeBlock(String text, {int maxLines = 5}) {
    final body = text.trim();
    if (body.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: maxLines < 99
          ? Text(
              body,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                height: 1.5,
                color: const Color(0xFFD1D5DB),
                fontWeight: FontWeight.w500,
              ),
            )
          : CoachAiFormattedNarrative(text: body),
    );
  }
}
