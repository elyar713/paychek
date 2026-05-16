import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../calendrier/calendrier_constants.dart';
import '../../calendrier/calendrier_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../reglage/user_portfolio_scope.dart';
import '../../trade/trade_journal_scope.dart';
import '../strategie_setups_store.dart';
import '../strategie_setup_usage_store.dart';
import '../strategie_tokens.dart';
import '../widgets/strategie_calendrier_grid.dart';
import '../widgets/strategie_section_frame.dart';

/// Calendrier : quels jours quelles stratégies (données **Ajouter trade** + marques manuelles optionnelles).
class StrategieCalendrierSection extends StatefulWidget {
  const StrategieCalendrierSection({
    super.key,
    required this.visibleSetupIndex,
    this.titleSuffix,
    this.sectionBackground,
    this.selectedDayNotifier,
  });

  final ValueNotifier<int> visibleSetupIndex;

  /// Ex. jauge de confiance ([AnalyseGauge]) synchronisée avec l’en-tête Analyse.
  final Widget? titleSuffix;

  /// Fond de carte (ex. [AnalyseTokens.cardBg] sur la page Analyse).
  final Color? sectionBackground;

  /// Permet à la page (et à d’autres cartes) de connaître le jour sélectionné.
  final ValueNotifier<DateTime?>? selectedDayNotifier;

  @override
  State<StrategieCalendrierSection> createState() =>
      _StrategieCalendrierSectionState();
}

class _StrategieCalendrierSectionState extends State<StrategieCalendrierSection> {
  late DateTime _focusedMonth;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    StrategieSetupUsageStore.ensureLoaded();
    final n = DateTime.now();
    _focusedMonth = DateTime(n.year, n.month);
    _selected = DateTime(n.year, n.month, n.day);
    widget.selectedDayNotifier?.value = _selected;
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  int _leadingBlankDays(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final firstColDart =
        loc.firstDayOfWeekIndex == 0 ? 7 : loc.firstDayOfWeekIndex;
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    return ((first.weekday - firstColDart) % 7 + 7) % 7;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final journal = TradeJournalScope.of(context);
    final pf = UserPortfolioScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.visibleSetupIndex,
        StrategieSetupsStore.notifier,
        StrategieSetupUsageStore.notifier,
        journal,
        pf,
      ]),
      builder: (context, _) {
        final setups = StrategieSetupsStore.notifier.value;
        final journalTrades = journal.itemsForPortfolio(pf.activePortfolioId);
        final idx =
            widget.visibleSetupIndex.value.clamp(0, setups.isEmpty ? 0 : setups.length - 1);
        final setup = setups.isEmpty ? null : setups[idx];

        final titleStyle = GoogleFonts.plusJakartaSans(
          color: StrategieTokens.horairesGold,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          height: 1,
        );

        if (setup == null) {
          return StrategieSectionFrame(
            leadingIcon: LucideIcons.calendarDays,
            title: l.strategieSectionTradeCalendar,
            titleColor: StrategieTokens.titleGrey,
            titleSuffix: widget.titleSuffix,
            backgroundColor: widget.sectionBackground,
            child: Text(
              l.strategieCalendarNeedSetupForUsage,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: StrategieTokens.labelMuted,
                height: 1.35,
              ),
            ),
          );
        }

        final loc = MaterialLocalizations.of(context);
        final daysInMonth =
            DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
        final leading = _leadingBlankDays(context);
        final today = DateTime.now();
        final usageMap = StrategieSetupUsageStore.notifier.value;

        return StrategieSectionFrame(
          leadingIcon: LucideIcons.calendarDays,
          title: l.strategieSectionTradeCalendar,
          titleColor: StrategieTokens.titleGrey,
          titleSuffix: widget.titleSuffix,
          backgroundColor: widget.sectionBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.strategieCalendarDotsExplain,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: StrategieTokens.labelMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: StrategieTokens.labelMuted,
                      size: kNavIconSize,
                    ),
                    onPressed: _prevMonth,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                  Expanded(
                    child: Text(
                      loc.formatMonthYear(_focusedMonth),
                      style: titleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: StrategieTokens.emerald,
                      size: kNavIconSize,
                    ),
                    onPressed: _nextMonth,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: kCalendarBodyMaxWidth),
                  child: StrategieCalendrierGrid(
                    focusedMonth: _focusedMonth,
                    selected: _selected,
                    today: today,
                    journalTrades: journalTrades,
                    usageBySetupTitle: usageMap,
                    selectedSetupTitle: setup.title,
                    leadingBlankDays: leading,
                    daysInMonth: daysInMonth,
                    languageCode: Localizations.localeOf(context).languageCode,
                    firstDayOfWeekIndex: loc.firstDayOfWeekIndex,
                    onDaySelected: (date) => setState(() {
                      _selected = date;
                      widget.selectedDayNotifier?.value = date;
                    }),
                    onToggleSelectedUsage: (day) {
                      StrategieSetupUsageStore.toggleDay(
                        setup.title,
                        dayKey(day),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
