import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../trade/trade_journal_helper.dart';
import '../trade/trade_models.dart';
import '../widgets/paychek_page_header.dart';
import '../shared/paychek_keyboard_insets.dart';
import 'coach_ai_performance_focus.dart';
import 'coach_ai_calendar.dart';
import '../calendrier/calendrier_utils.dart';
import 'coach_ai_strategy_today.dart';
import 'coach_ai_analysis_today.dart';
import 'coach_ai_checklist_today.dart';
import 'coach_ai_cloud.dart';
import 'coach_ai_mental_analysis.dart';
import 'coach_ai_formatted_narrative.dart';
import 'coach_ai_non_respect_analysis.dart';
import 'coach_ai_performance_summary.dart';
import 'coach_ai_psych_analysis.dart';
import '../help_center/help_center_catalog.dart';
import 'coach_ai_app_help.dart';
import 'coach_ai_app_snapshot.dart';
import 'coach_ai_app_pricing.dart';
import 'coach_ai_coaching_story.dart';
import 'coach_ai_pillar_coaching.dart';
import 'coach_ai_focus.dart';
import 'coach_ai_conversation.dart';
import 'coach_ai_locale.dart';
import 'coach_ai_query_text.dart';
import 'coach_ai_response_format.dart';
import 'coach_ai_trade_journal_context.dart';
import 'coach_ai_related_trades.dart';
import 'coach_ai_trade_list_query.dart';

part 'coach_ai_page_send.dart';
part 'coach_ai_page_context.dart';
part 'coach_ai_page_ui.dart';
part 'coach_ai_page_cards_today.dart';
part 'coach_ai_page_cards_story.dart';
part 'coach_ai_page_cards_perf.dart';

class CoachAiPage extends StatefulWidget {
  const CoachAiPage({super.key, this.onCloseInShell});

  final VoidCallback? onCloseInShell;

  @override
  State<CoachAiPage> createState() => _CoachAiPageState();
}

class _CoachAiMessage {
  const _CoachAiMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.relatedUserQuestion,
    this.responseFocus,
  });

  final String text;
  final bool isUser;
  final bool isError;
  final String? relatedUserQuestion;
  final String? responseFocus;
}

class _CoachDisciplinePillar {
  const _CoachDisciplinePillar({
    required this.title,
    required this.icon,
    required this.recorded,
    required this.missing,
    required this.nonRespect,
    required this.total,
    required this.recordedClosed,
    required this.winsRecorded,
    required this.lossesRecorded,
    required this.pnlRecorded,
  });

  final String title;
  final IconData icon;
  final int recorded;
  final int missing;
  final int nonRespect;
  final int total;
  final int recordedClosed;
  final int winsRecorded;
  final int lossesRecorded;
  final double pnlRecorded;

  int get recordedPercent => total > 0 ? (recorded * 100 / total).round() : 0;

  double get winrateRecorded =>
      recordedClosed > 0 ? (winsRecorded * 100 / recordedClosed) : 0.0;
}


class _CoachAiPageState extends State<CoachAiPage> {
  final TextEditingController _questionCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _questionFocus = FocusNode();

  final List<_CoachAiMessage> _messages = <_CoachAiMessage>[];
  bool _sending = false;
  int? _quotaUsed;
  int? _quotaLimit;
  bool _welcomeSeeded = false;

  void _coachMutate(VoidCallback fn) => setState(fn);

  @override
  void initState() {
    super.initState();
    _questionFocus.addListener(_onQuestionFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    purgeOrphanJournalTrades(context);
    if (_welcomeSeeded) return;
    _welcomeSeeded = true;
    _messages.add(
      _CoachAiMessage(
        text: _coachWelcomeText(_appLanguageCode),
        isUser: false,
      ),
    );
  }

  String get _appLanguageCode =>
      Localizations.localeOf(context).languageCode;

  String _responseLang(String? question) => CoachAiQueryText.responseLanguageCode(
        question ?? '',
        fallback: _appLanguageCode,
      );

  /// Journal du portefeuille actif uniquement (pas les comptes supprimés / démo).
  List<TradeListItem> _coachJournalTrades() => coachAiJournalTrades(context);

  static String _coachWelcomeText(String languageCode) =>
      CoachAiLocale.welcomeMessage(languageCode);

  void _onQuestionFocusChange() {
    if (!_questionFocus.hasFocus) return;
    _scrollToBottom();
  }

  @override
  void dispose() {
    _questionFocus.removeListener(_onQuestionFocusChange);
    _questionFocus.dispose();
    _questionCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final onBack = PaychekPageHeader.resolveBack(context, onCloseInShell: widget.onCloseInShell);

    Widget bubble(_CoachAiMessage m) {
      final textStyle = m.isUser
          ? GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.45,
              color: const Color(0xFFECFDF5),
              fontWeight: FontWeight.w600,
            )
          : GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFFD1D5DB),
              fontWeight: FontWeight.w500,
            );

      if (!m.isUser && !m.isError) {
        final q = m.relatedUserQuestion ?? '';
        final focus = m.responseFocus ?? CoachAiFocus.resolve(q);
        if (focus == CoachAiFocus.calendarMonth) {
          return _buildCalendarMonthCard(m, q);
        }
        if (focus == CoachAiFocus.calendarToday) {
          return _buildCalendarTodayCard(m, q);
        }
        if (focus == CoachAiFocus.strategyToday) {
          return _buildStrategyTodayCard(m, q);
        }
        if (focus == CoachAiFocus.analysisToday) {
          return _buildAnalysisTodayCard(m, q);
        }
        if (focus == CoachAiFocus.checklistToday) {
          return _buildChecklistTodayCard(m, q);
        }
        if (focus == CoachAiFocus.mentalToday) {
          return _buildMentalTodayCard(m, q);
        }
        if (focus == 'mental_emotion') {
          return _buildMentalEmotionCard(m, q);
        }
        if (focus == 'non_respect') {
          return _buildNonRespectCard(m);
        }
        if (focus == 'psychology_why') {
          return _buildPsychWhyCard(m, q);
        }
        if (focus == 'coaching_story') {
          return _buildCoachingStoryCard(m, q);
        }
        if (focus == CoachAiFocus.pillarImprovement) {
          return _buildPillarImprovementCard(m, q);
        }
        if (focus == CoachAiFocus.performanceOvertrading) {
          return _buildPerformanceOvertradingCard(m, q);
        }
        if (focus == CoachAiFocus.performanceLens) {
          return _buildPerformanceLensCard(m, q);
        }
        if (focus == CoachAiFocus.performanceSummary) {
          return _buildPerformanceSummaryCard(m, q);
        }
        if (focus == 'story_followup') {
          return _buildStoryFollowUpCard(m, q);
        }
        if (focus == CoachAiFocus.appPricing) {
          return _buildAppPricingCard(m);
        }
        if (focus == 'app_help' || focus == 'app_help_hybrid') {
          return _buildAppHelpCard(m, q, focus: focus);
        }
        if (focus == 'trade_list') {
          return _buildTradeListCard(m, q);
        }
        if (focus != 'coach') {
          return _buildAiAuditCard(m, focus: focus);
        }
      }

      final card = Container(
        constraints: const BoxConstraints(maxWidth: 780),
        padding: EdgeInsets.symmetric(
          horizontal: m.isUser ? 14 : 16,
          vertical: m.isUser ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: m.isUser
              ? const Color(0xFF10B981).withValues(alpha: 0.12)
              : (m.isError
                  ? const Color(0xFF7F1D1D).withValues(alpha: 0.25)
                  : const Color(0xFF0A0A0A)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: m.isUser
                ? const Color(0xFF14532D)
                : (m.isError ? const Color(0xFFB91C1C) : const Color(0xFF1F2937)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(m.text, style: textStyle),
      );

      if (m.isUser) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Align(alignment: Alignment.centerRight, child: card),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 2, right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF14532D)),
              ),
              alignment: Alignment.center,
              child: const Text('✨', style: TextStyle(fontSize: 14)),
            ),
            Flexible(child: card),
          ],
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hPad = constraints.maxWidth >= 1200 ? 28.0 : 16.0;
            final maxW = math.min(960.0, math.max(0.0, constraints.maxWidth - (2 * hPad)));
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF050505).withValues(alpha: 0.72),
                    border: Border(
                      bottom: BorderSide(color: const Color(0xFF1F2937).withValues(alpha: 0.65)),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: Colors.white.withValues(alpha: 0.84),
                        tooltip: 'Retour',
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFF1F2937)),
                        ),
                        child: Text(
                          (_quotaUsed ?? 0) > 0 && (_quotaLimit ?? 0) > 0
                              ? 'Quota : $_quotaUsed/$_quotaLimit'
                              : 'AI COACH',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            letterSpacing: 0.6,
                            color: const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '👤',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: PaychekKeyboardInsets.addBottom(
                      EdgeInsets.fromLTRB(hPad, 16, hPad, 12),
                      context,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxW),
                        child: Column(
                          children: [
                            for (final m in _messages) bubble(m),
                            if (_sending)
                              bubble(
                                const _CoachAiMessage(
                                  text: 'AI Coach réfléchit...',
                                  isUser: false,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF050505),
                    border: Border(
                      top: BorderSide(color: const Color(0xFF1F2937).withValues(alpha: 0.65)),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF121212),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF1F2937)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.34),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _questionCtrl,
                                    focusNode: _questionFocus,
                                    enabled: !_sending,
                                    minLines: 1,
                                    maxLines: 5,
                                    scrollPadding:
                                        PaychekKeyboardInsets.fieldScrollPadding(
                                      context,
                                      extra: 80,
                                    ),
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _askCoach(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Pose ta question au coach...',
                                      hintStyle: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: const Color(0xFF6B7280),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                                  child: Material(
                                    color: _sending ? const Color(0xFF374151) : const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                      onTap: _sending ? null : _askCoach,
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        width: 38,
                                        height: 38,
                                        child: Center(
                                          child: _sending
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.black,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.send_rounded,
                                                  size: 19,
                                                  color: Colors.black,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PAYCHEK AI COACH V2.0',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              letterSpacing: 1.0,
                              color: const Color(0xFF4B5563),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CoachExpandableInsight extends StatefulWidget {
  const _CoachExpandableInsight({required this.text});

  final String text;

  @override
  State<_CoachExpandableInsight> createState() => _CoachExpandableInsightState();
}

class _CoachExpandableInsightState extends State<_CoachExpandableInsight> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final body = widget.text.trim();
    if (body.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: const Color(0xFF34D399),
                ),
                const SizedBox(width: 6),
                Text(
                  _expanded ? 'Masquer l’analyse du coach' : 'Lire l’analyse du coach',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: const Color(0xFF6EE7B7),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.33),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: CoachAiFormattedNarrative(text: body),
          ),
      ],
    );
  }
}
