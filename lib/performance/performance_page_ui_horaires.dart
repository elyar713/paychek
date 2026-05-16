part of 'performance_page.dart';

extension _PerformancePageUiHoraires on _PerformancePageState {
  Widget _horaireNonRespectBadgeRow(int count, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _kBorder),
            ),
            child: Text(
              '$count×',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _kRed,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: const Color(0xFFBBBBBB),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardTimeSlots(
    List<TimeSlotStat> slots,
    HoraireTradingViolationStats hv,
  ) {
    final code = Localizations.localeOf(context).languageCode;
    String t(String fr, String en, String es, String de, String pt, String ko) =>
        perf6(code, fr, en, es, de, pt, ko);
    final s = slots.length >= 3
        ? slots
        : [
            const TimeSlotStat(label: '-', sub: '', winRate: 0, count: 0),
            const TimeSlotStat(label: '-', sub: '', winRate: 0, count: 0),
            const TimeSlotStat(label: '-', sub: '', winRate: 0, count: 0),
          ];
    Color cFor(int i) {
      if (i == 0) return _kGreen;
      if (i == 2) return _kRed;
      return Colors.white;
    }

    IconData iconFor(int i) =>
        i == 0 ? LucideIcons.sunrise : (i == 1 ? LucideIcons.sun : LucideIcons.moon);

    final hasHoraireViolation = hv.sessionsConfigurees &&
        (hv.horsCreaneauxAutorises > 0 ||
            hv.pendantFenetreNoTrade > 0 ||
            hv.sansHeureEntree > 0);

    return _dashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            LucideIcons.sun,
            t('Horaires de Performance', 'Performance hours', 'Horarios de rendimiento', 'Performance-Zeiten', 'Horários de desempenho', '성과 시간대'),
          ),
          const SizedBox(height: 8),
          Text(
            t(
              'Winrate par plage horaire (période filtrée).',
              'Win rate by time range (filtered period).',
              'Win rate por franja horaria (período filtrado).',
              'Gewinnrate nach Tageszeit (gefilterter Zeitraum).',
              'Win rate por faixa de horário (período filtrado).',
              '시간대별 승률(필터 기간).',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF888888),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle(
            LucideIcons.sunrise,
            t('Par plage horaire', 'By time range', 'Por franja horaria', 'Nach Zeitfenster', 'Por faixa de horário', '시간대별'),
          ),
          const SizedBox(height: 6),
          Text(
            t(
              'Créneaux matin, journée et soir.',
              'Morning, daytime and evening windows.',
              'Franjas de mañana, día y noche.',
              'Morgens, tagsüber und abends.',
              'Janelas de manhã, dia e noite.',
              '아침·낮·저녁 구간.',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFF888888),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < 3; i++) ...[
            _timeSlotRow(
              iconFor(i),
              s[i].label,
              s[i].sub,
              '${(s[i].winRate * 100).round()}% WR',
              s[i].winRate,
              cFor(i),
            ),
            if (i < 2) const SizedBox(height: 14),
          ],
          if (!hv.sessionsConfigurees) ...[
            const SizedBox(height: 20),
            Text(
              t(
                'Ajoutez des sessions dans l’onglet Stratégie pour lister les écarts d’horaire.',
                'Add sessions in the Strategy tab to list schedule deviations.',
                'Agrega sesiones en la pestaña Estrategia para listar los desvíos de horario.',
                'Fügen Sie Sessions im Strategie-Tab hinzu, um Zeitabweichungen zu listen.',
                'Adicione sessões na aba Estratégia para listar desvios de horário.',
                '전략 탭에서 세션을 추가하면 일정 차이를 나열합니다.',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: const Color(0xFF888888),
                height: 1.4,
              ),
            ),
          ] else if (hasHoraireViolation) ...[
            const SizedBox(height: 20),
            Text(
              t(
                'Horaire non respecté (sessions Stratégie - agrégé sur la période)',
                'Schedule violations (Strategy sessions - aggregated for period)',
                'Horario no respetado (sesiones de estrategia - agregado en el período)',
                'Zeitplan nicht eingehalten (Strategie-Sessions - aggregiert)',
                'Horário não respeitado (sessões de estratégia - agregado no período)',
                '일정 위반(전략 세션 - 기간 합산)',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF888888),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            if (hv.horsCreaneauxAutorises > 0)
              _horaireNonRespectBadgeRow(
                hv.horsCreaneauxAutorises,
                t('Hors créneaux autorisés', 'Outside allowed windows', 'Fuera de ventanas permitidas', 'Außerhalb erlaubter Fenster', 'Fora das janelas permitidas', '허용 시간 외'),
              ),
            if (hv.pendantFenetreNoTrade > 0)
              _horaireNonRespectBadgeRow(
                hv.pendantFenetreNoTrade,
                t('Pendant session No Trade', 'During No Trade session', 'Durante sesión No Trade', 'Während No-Trade-Session', 'Durante sessão No Trade', '노 트레이드 세션 중'),
              ),
            if (hv.sansHeureEntree > 0)
              _horaireNonRespectBadgeRow(
                hv.sansHeureEntree,
                t(
                  'Sans heure d’entrée (session non vérifiable)',
                  'No entry time (session not verifiable)',
                  'Sin hora de entrada (sesión no verificable)',
                  'Ohne Eintrittszeit (Session nicht prüfbar)',
                  'Sem hora de entrada (sessão não verificável)',
                  '진입 시각 없음(세션 확인 불가)',
                ),
              ),
          ] else if (hv.sessionsConfigurees) ...[
            const SizedBox(height: 20),
            Text(
              t(
                'Aucun écart d’horaire sur cette période.',
                'No schedule deviation for this period.',
                'Sin desvío de horario en este período.',
                'Keine Zeitplanabweichung in diesem Zeitraum.',
                'Nenhum desvio de horário neste período.',
                '이 기간에 일정 차이 없음.',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: const Color(0xFF888888),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeSlotRow(IconData icon, String title, String sub, String wr, double w, Color c) {
    final dim = title.startsWith('19');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _kGrey),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: dim ? const Color(0xFF888888) : Colors.white,
                  ),
                  children: [
                    TextSpan(text: title),
                    TextSpan(
                      text: sub.isEmpty ? '' : ' $sub',
                      style: GoogleFonts.plusJakartaSans(fontSize: 9, color: _kGrey, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            Text(wr, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: c)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: w.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: const Color(0xFF111111),
            color: c,
          ),
        ),
      ],
    );
  }
}
