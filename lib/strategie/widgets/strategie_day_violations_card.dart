import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ajouter_trade/ajouter_trade_page_non_respect_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../reglage/user_portfolio_scope.dart';
import '../../trade/trade_journal_scope.dart';
import '../../trade/trade_models.dart';
import '../strategie_horaires_sessions_storage.dart';
import '../strategie_tokens.dart';
import 'strategie_setup_cards_content.dart';

String _dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

bool _minutesInSessionWindow(int mins, StrategieSessionPersisted s) {
  final start = s.startHour * 60 + s.startMinute;
  if (s.endHour == null || s.endMinute == null) {
    return mins >= start;
  }
  final end = s.endHour! * 60 + s.endMinute!;
  if (end >= start) {
    return mins >= start && mins <= end;
  }
  return mins >= start || mins <= end;
}

int? _tradeEntryMinutes(TradeListItem t) => t.entreeAt.hour * 60 + t.entreeAt.minute;

class _ViolationAgg {
  _ViolationAgg({required this.label, required this.count});
  final String label;
  final int count;
}

/// Carte : affiche les points stratégie non respectés pour le jour sélectionné dans le calendrier.
class StrategieDayViolationsCard extends StatefulWidget {
  const StrategieDayViolationsCard({
    super.key,
    required this.selectedDay,
  });

  final ValueNotifier<DateTime?> selectedDay;

  @override
  State<StrategieDayViolationsCard> createState() =>
      _StrategieDayViolationsCardState();
}

class _StrategieDayViolationsCardState extends State<StrategieDayViolationsCard> {
  String? _selectedStrategieTitle;

  String _t6(
    String code,
    String fr,
    String en,
    String es,
    String de,
    String pt,
    String ko,
  ) {
    final c = code.toLowerCase();
    if (c.startsWith('fr')) return fr;
    if (c.startsWith('es')) return es;
    if (c.startsWith('de')) return de;
    if (c.startsWith('pt')) return pt;
    if (c.startsWith('ko')) return ko;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final journal = TradeJournalScope.of(context);
    final pf = UserPortfolioScope.of(context);

    return ValueListenableBuilder<DateTime?>(
      valueListenable: widget.selectedDay,
      builder: (context, day, _) {
        final picked = day ?? DateTime.now();
        // Changer de jour => réinitialiser le filtre stratégie si elle n'est plus présente.
        final k = _dayKey(picked);

        final journalTrades = journal.itemsForPortfolio(pf.activePortfolioId);
        final dayTrades = journalTrades
            .where((t) => _dayKey(t.entreeAt) == k)
            .toList(growable: false);

        final usedStrategies = <String>{
          for (final t in dayTrades)
            if (t.strategieTitle.trim().isNotEmpty) t.strategieTitle.trim(),
        }.toList()
          ..sort();

        final selectedTitle = _selectedStrategieTitle;
        final effectiveSelectedTitle =
            (selectedTitle != null && usedStrategies.contains(selectedTitle))
                ? selectedTitle
                : null;
        if (selectedTitle != null && effectiveSelectedTitle == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _selectedStrategieTitle = null);
          });
        }

        double? avgPct;
        if (dayTrades.isNotEmpty) {
          var s = 0.0;
          for (final t in dayTrades) {
            s += t.strategiePct;
          }
          avgPct = s / dayTrades.length;
        }

        final nonRespectCounts = <String, int>{};
        for (final t in dayTrades) {
          if (effectiveSelectedTitle != null &&
              t.strategieTitle.trim() != effectiveSelectedTitle) {
            continue;
          }
          for (final id in t.strategieNonRespectIds) {
            final kk = '${t.strategieTitle}\u001E$id';
            nonRespectCounts[kk] = (nonRespectCounts[kk] ?? 0) + 1;
          }
        }

        final labelAggs = <_ViolationAgg>[];
        for (final e in nonRespectCounts.entries) {
          final parts = e.key.split('\u001E');
          if (parts.length != 2) continue;
          final st = parts[0];
          final id = parts[1];
          final label = labelForStrategieNonRespectId(
            id,
            st,
            l: l,
            locale: locale,
          );
          labelAggs.add(_ViolationAgg(label: label, count: e.value));
        }
        labelAggs.sort((a, b) => b.count.compareTo(a.count));

        return FutureBuilder<List<StrategieSessionPersisted>>(
          future: StrategieHorairesSessionsStorage.load(),
          builder: (context, snap) {
            final sessions = snap.data ?? const <StrategieSessionPersisted>[];
            final noTrade = sessions.where((s) => s.isNoTradeZone).toList();
            var noTradeHits = 0;
            if (noTrade.isNotEmpty) {
              for (final t in dayTrades) {
                if (effectiveSelectedTitle != null &&
                    t.strategieTitle.trim() != effectiveSelectedTitle) {
                  continue;
                }
                final mins = _tradeEntryMinutes(t);
                if (mins == null) continue;
                var inNoTrade = false;
                for (final s in noTrade) {
                  if (_minutesInSessionWindow(mins, s)) {
                    inNoTrade = true;
                    break;
                  }
                }
                if (inNoTrade) noTradeHits++;
              }
            }

            final allViolations = <_ViolationAgg>[
              ...labelAggs,
              if (noTradeHits > 0)
                _ViolationAgg(
                  label: _t6(
                    locale.languageCode,
                    'Pendant une session No Trade',
                    'During a No Trade session',
                    'Durante una sesión No Trade',
                    'Während einer No-Trade-Session',
                    'Durante uma sessão No Trade',
                    '노트레이드 세션 중',
                  ),
                  count: noTradeHits,
                ),
            ];

            final isPerfect =
                (avgPct != null && avgPct >= 99.5) && allViolations.isEmpty;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StrategieTokens.innerCardBg,
                borderRadius: BorderRadius.circular(StrategieTokens.radiusMd),
                border: Border.all(color: StrategieTokens.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.ajouterTradeDisciplineSliderStrategieRespected,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: StrategieTokens.horairesGold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: StrategieTokens.labelMuted,
                          ),
                        ),
                      ),
                      if (avgPct != null)
                        Text(
                          '${avgPct.round()}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: avgPct >= 95
                                ? StrategieTokens.emerald
                                : StrategieTokens.titleGrey,
                          ),
                        )
                      else
                        Text(
                          '—',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: StrategieTokens.labelMuted,
                          ),
                        ),
                    ],
                  ),
                  if (usedStrategies.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final title in usedStrategies)
                          _StrategieTitlePill(
                            title: title,
                            selected: effectiveSelectedTitle == title,
                            onTap: () {
                              setState(() {
                                if (_selectedStrategieTitle == title) {
                                  _selectedStrategieTitle = null;
                                } else {
                                  _selectedStrategieTitle = title;
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (dayTrades.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        _t6(
                          locale.languageCode,
                          'Aucun trade ce jour.',
                          'No trades on this day.',
                          'Sin trades este día.',
                          'Keine Trades an diesem Tag.',
                          'Sem trades neste dia.',
                          '해당 날짜에 트레이드가 없습니다.',
                        ),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF777777),
                        ),
                      ),
                    )
                  else if (isPerfect)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        l.ajouterTradeStrategieFeedbackBravo,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: StrategieTokens.emerald,
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.ajouterTradeStrategieFeedbackWhichMissed,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final v in allViolations.take(12))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${v.count}×',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: StrategieTokens.riskRed,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    v.label,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                      color: const Color(0xFFE5E5E5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StrategieTitlePill extends StatelessWidget {
  const _StrategieTitlePill({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final data = strategieSetupCardDataPourTitre(title);
    final col = data?.dotColor ?? const Color(0xFF9CA3AF);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? col.withValues(alpha: 0.12) : const Color(0xFF0A0A0B),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? col.withValues(alpha: 0.95) : col.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: col,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: col,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


