import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../trade/trade_journal_scope.dart';
import '../trade/trade_models.dart';
import '../widgets/paychek_page_header.dart';
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
import 'coach_ai_app_pricing.dart';
import 'coach_ai_coaching_story.dart';
import 'coach_ai_focus.dart';
import 'coach_ai_conversation.dart';
import 'coach_ai_response_format.dart';
import 'coach_ai_trade_journal_context.dart';
import 'coach_ai_trade_list_query.dart';

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

  final List<_CoachAiMessage> _messages = <_CoachAiMessage>[];
  bool _sending = false;
  int? _quotaUsed;
  int? _quotaLimit;

  @override
  void initState() {
    super.initState();
    _messages.add(
      const _CoachAiMessage(
        text: 'Bonjour, je suis ton AI Coach. Pose-moi une question sur ton trading, ta discipline, ta stratégie ou l’utilisation de PAYCHEK.',
        isUser: false,
      ),
    );
  }

  String _friendlyError(String? code, String? message) {
    if (code == 'failed-precondition') {
      return 'API Agent AI non configurée côté admin.';
    }
    if (code == 'resource-exhausted') {
      return 'Quota quotidien atteint. Réessaie demain.';
    }
    if (code == 'permission-denied') {
      return 'AI Coach est réservé à l’essai actif ou au plan Pro.';
    }
    return message ?? 'Erreur AI Coach';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String? _lastAssistantFocus() {
    for (var i = _messages.length - 1; i >= 0; i--) {
      final m = _messages[i];
      if (!m.isUser && !m.isError) return m.responseFocus;
    }
    return null;
  }

  Map<String, dynamic> _conversationContextBlock() {
    if (_messages.isEmpty) return const {};
    return <String, dynamic>{
      'priorTurns': CoachAiConversation.priorTurnsToJson(
        texts: _messages.map((m) => m.text).toList(),
        isUserFlags: _messages.map((m) => m.isUser).toList(),
        isErrorFlags: _messages.map((m) => m.isError).toList(),
        responseFocuses: _messages.map((m) => m.responseFocus).toList(),
        excludeLastCount: 1,
      ),
    };
  }

  Future<void> _askCoach() async {
    final question = _questionCtrl.text.trim();
    if (question.isEmpty || _sending) return;
    _questionCtrl.clear();
    setState(() {
      _sending = true;
      _messages.add(_CoachAiMessage(text: question, isUser: true));
    });
    _scrollToBottom();

    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;
    final priorFocus = _lastAssistantFocus();
    final focus = CoachAiFocus.resolve(question, priorAssistantFocus: priorFocus);

    if (focus == 'trade_list') {
      final report = CoachAiTradeListQuery.build(
        TradeJournalScope.of(context).items,
        question,
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _messages.add(
          _CoachAiMessage(
            text: report.headline,
            isUser: false,
            relatedUserQuestion: question,
            responseFocus: 'trade_list',
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    if (focus == 'app_help') {
      final steps = CoachAiAppHelp.uiStepsForQuestion(question, lang);
      final title = CoachAiAppHelp.localCardTitle(question, lang) ??
          () {
            final slug = CoachAiAppHelp.resolveGuideSlug(question);
            if (slug == null) return null;
            return helpCenterArticles
                .where((a) => a.slug == slug)
                .map((a) => a.frenchTitle)
                .firstOrNull;
          }();
      if (!mounted) return;
      setState(() {
        _sending = false;
        _messages.add(
          _CoachAiMessage(
            text: CoachAiAppHelp.formatStepsAnswer(
              steps,
              languageCode: lang,
              title: title,
            ),
            isUser: false,
            relatedUserQuestion: question,
            responseFocus: 'app_help',
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    final auditContext = await _buildAuditContextAsync(
      forQuestion: question,
      languageCode: lang,
    );
    final res = await PaychekAiCoachCloud.ask(
      question: question,
      locale: locale,
      context: auditContext,
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _quotaUsed = res.quotaUsed;
      _quotaLimit = res.quotaLimit;
      _messages.add(
        _CoachAiMessage(
          text: res.ok ? (res.answer ?? '') : _friendlyError(res.code, res.message),
          isUser: false,
          isError: !res.ok,
          relatedUserQuestion: question,
          responseFocus: focus,
        ),
      );
    });
    _scrollToBottom();
  }

  ({
    int tradesTotal,
    int tradesClosed,
    int wins,
    int losses,
    int breakevenOrFlat,
    double winratePercent,
    double pnlTotal,
    int performanceLite,
    List<_CoachDisciplinePillar> disciplinePillars,
  }) _computeAuditSnapshot() {
    final trades = TradeJournalScope.of(context).items;
    final total = trades.length;
    int closed = 0;
    int wins = 0;
    int losses = 0;
    int be = 0;
    int performanceLite = 0;
    double pnl = 0;

    _CoachDisciplinePillar buildPillar({
      required String title,
      required IconData icon,
      required bool Function(TradeListItem t) isRecorded,
      required int Function(TradeListItem t) nonRespectCount,
    }) {
      var recorded = 0;
      var missing = 0;
      var nonRespect = 0;
      var recordedClosed = 0;
      var winsRecorded = 0;
      var lossesRecorded = 0;
      var pnlRecorded = 0.0;

      for (final t in trades) {
        nonRespect += nonRespectCount(t);
        if (!isRecorded(t)) {
          missing++;
          continue;
        }
        recorded++;
        if (t.isClosed) {
          recordedClosed++;
          pnlRecorded += t.gainAmount;
          if (t.countsAsClosedWin) winsRecorded++;
          if (t.countsAsClosedLoss) lossesRecorded++;
        }
      }

      return _CoachDisciplinePillar(
        title: title,
        icon: icon,
        recorded: recorded,
        missing: missing,
        nonRespect: nonRespect,
        total: total,
        recordedClosed: recordedClosed,
        winsRecorded: winsRecorded,
        lossesRecorded: lossesRecorded,
        pnlRecorded: double.parse(pnlRecorded.toStringAsFixed(2)),
      );
    }

    for (final t in trades) {
      pnl += t.gainAmount;
      if (t.performanceLite) performanceLite++;
      if (t.isClosed) {
        closed++;
        if (t.countsAsClosedWin) wins++;
        if (t.countsAsClosedLoss) losses++;
        if (t.countsAsClosedBreakevenOrFlat) be++;
      }
    }
    final winrate = closed > 0 ? (wins * 100 / closed) : 0.0;

    final pillars = <_CoachDisciplinePillar>[
      buildPillar(
        title: 'Checklist',
        icon: Icons.checklist_rounded,
        isRecorded: (t) => t.checklistLinkedExplicit,
        nonRespectCount: (t) => t.checklistNonRespectIds.length,
      ),
      buildPillar(
        title: 'Analyse',
        icon: Icons.insights_outlined,
        isRecorded: (t) => t.planLinkedExplicit,
        nonRespectCount: (t) => t.planNonRespectIds.length,
      ),
      buildPillar(
        title: 'Stratégie',
        icon: Icons.account_tree_outlined,
        isRecorded: (t) => t.strategieLinkedExplicit,
        nonRespectCount: (t) => t.strategieNonRespectIds.length,
      ),
      buildPillar(
        title: 'État mental',
        icon: Icons.psychology_outlined,
        isRecorded: (t) => t.etatLinkedExplicit,
        nonRespectCount: (t) => t.etatNonRespectIds.length,
      ),
    ];

    return (
      tradesTotal: total,
      tradesClosed: closed,
      wins: wins,
      losses: losses,
      breakevenOrFlat: be,
      winratePercent: double.parse(winrate.toStringAsFixed(1)),
      pnlTotal: double.parse(pnl.toStringAsFixed(2)),
      performanceLite: performanceLite,
      disciplinePillars: pillars,
    );
  }

  _CoachDisciplinePillar? _pillarForFocus(
    List<_CoachDisciplinePillar> pillars,
    String focus,
  ) {
    return switch (focus) {
      'checklist' => pillars[0],
      'analyse' => pillars[1],
      'strategie' => pillars[2],
      'mental' => pillars[3],
      _ => null,
    };
  }

  Future<Map<String, dynamic>> _buildAuditContextAsync({
    String? forQuestion,
    required String languageCode,
  }) async {
    final priorFocus = _messages.length >= 2 ? _lastAssistantFocus() : null;

    if (forQuestion != null &&
        CoachAiConversation.isStoryFollowUp(forQuestion, priorFocus)) {
      return <String, dynamic>{
        'questionFocus': 'story_followup',
        'paychekUiSteps': CoachAiConversation.storyFollowUpSteps(languageCode),
        'conversation': _conversationContextBlock(),
        'coachInstructions': CoachAiResponseFormat.storyFollowUpInstructions(languageCode),
        'responseRules': <String, dynamic>{
          'style': 'story_followup_numbered',
          'linksToPriorCoachingStory': true,
          'noDisciplineAudit': true,
          'maxWords': 180,
          'format': 'intro_then_1_to_5_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null && CoachAiFocus.resolve(forQuestion) == CoachAiFocus.coachingStory) {
      final story = CoachAiCoachingStory.buildFocus(
        TradeJournalScope.of(context).items,
        forQuestion,
      );
      return <String, dynamic>{
        'questionFocus': 'coaching_story',
        if (story != null)
          'coachingStoryFocus': CoachAiCoachingStory.focusToJson(
            story,
            languageCode: languageCode,
          ),
        'conversation': _conversationContextBlock(),
        'responseRules': <String, dynamic>{
          'style': 'empathic_coach_numbered',
          'noDisciplineAudit': true,
          'noPillarStats': true,
          'maxWords': 200,
          'format': 'intro_plus_framing_question_then_1_2_3_4',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null &&
        CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus) ==
            CoachAiFocus.mentalToday) {
      final l10n = AppLocalizations.of(context)!;
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.mentalToday,
        'mentalTodayContext': CoachAiMentalAnalysis.todayContextToJson(
          l10n,
          TradeJournalScope.of(context).items,
          languageCode,
        ),
        'conversation': _conversationContextBlock(),
        'responseRules': <String, dynamic>{
          'style': CoachAiConversation.isFocusedTopicFollowUp(forQuestion, priorFocus)
              ? 'mental_today_brief_followup'
              : 'mental_today_numbered',
          'noDisciplineAudit': true,
          'noPillarStats': true,
          'noTradeJournalAudit': true,
          'maxWords':
              CoachAiConversation.isFocusedTopicFollowUp(forQuestion, priorFocus) ? 90 : 180,
          'format': 'intro_then_1_to_4_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null &&
        CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus) ==
            CoachAiFocus.checklistToday) {
      final briefFollowUp =
          CoachAiConversation.isFocusedTopicFollowUp(forQuestion, priorFocus);
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.checklistToday,
        'checklistTodayContext': await CoachAiChecklistToday.todayContextToJson(
          languageCode,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(),
        'responseRules': <String, dynamic>{
          'style': briefFollowUp ? 'checklist_today_brief_followup' : 'checklist_today_numbered',
          'noDisciplineAudit': true,
          'noPillarStats': true,
          'noTradeJournalAudit': true,
          'maxWords': briefFollowUp ? 90 : 160,
          'format': briefFollowUp ? 'brief_answer_only' : 'intro_then_1_to_4_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null &&
        CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus) ==
            CoachAiFocus.analysisToday) {
      final briefFollowUp =
          CoachAiConversation.isFocusedTopicFollowUp(forQuestion, priorFocus);
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.analysisToday,
        'analysisTodayContext': await CoachAiAnalysisToday.todayContextToJson(
          languageCode,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(),
        'responseRules': <String, dynamic>{
          'style': briefFollowUp ? 'analysis_today_brief_followup' : 'analysis_today_numbered',
          'noDisciplineAudit': true,
          'noPillarStats': true,
          'noTradeJournalAudit': true,
          'maxWords': briefFollowUp ? 90 : 170,
          'format': briefFollowUp ? 'brief_answer_only' : 'intro_then_1_to_4_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null &&
        CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus) ==
            CoachAiFocus.strategyToday) {
      final briefFollowUp =
          CoachAiConversation.isFocusedTopicFollowUp(forQuestion, priorFocus);
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.strategyToday,
        'strategyTodayContext': await CoachAiStrategyToday.todayContextToJson(
          languageCode,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(),
        'responseRules': <String, dynamic>{
          'style': briefFollowUp ? 'strategy_today_brief_followup' : 'strategy_today_numbered',
          'noDisciplineAudit': true,
          'noPillarStats': true,
          'noTradeJournalAudit': true,
          'maxWords': briefFollowUp ? 90 : 170,
          'format': briefFollowUp ? 'brief_answer_only' : 'intro_then_1_to_4_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null &&
        CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus) ==
            CoachAiFocus.calendarToday) {
      final briefFollowUp =
          CoachAiConversation.isFocusedTopicFollowUp(forQuestion, priorFocus);
      final trades = TradeJournalScope.of(context).items;
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.calendarToday,
        'calendarTodayContext': await CoachAiCalendar.todayContextToJson(
          trades,
          languageCode,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(),
        'responseRules': <String, dynamic>{
          'style': briefFollowUp ? 'calendar_today_brief_followup' : 'calendar_today_numbered',
          'noDisciplineAudit': true,
          'noPillarStats': true,
          'noTradeJournalAudit': true,
          'maxWords': briefFollowUp ? 90 : 170,
          'format': briefFollowUp ? 'brief_answer_only' : 'intro_then_1_to_4_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null &&
        CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus) ==
            CoachAiFocus.calendarMonth) {
      final briefFollowUp =
          CoachAiConversation.isFocusedTopicFollowUp(forQuestion, priorFocus);
      final trades = TradeJournalScope.of(context).items;
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.calendarMonth,
        'calendarMonthContext': await CoachAiCalendar.monthContextToJson(
          trades,
          languageCode,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(),
        'responseRules': <String, dynamic>{
          'style': briefFollowUp ? 'calendar_month_brief_followup' : 'calendar_month_numbered',
          'noDisciplineAudit': true,
          'noPillarStats': true,
          'noTradeJournalAudit': true,
          'maxWords': briefFollowUp ? 90 : 180,
          'format': briefFollowUp ? 'brief_answer_only' : 'intro_then_1_to_5_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null &&
        CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus) ==
            CoachAiFocus.performanceSummary) {
      final briefFollowUp =
          CoachAiConversation.isFocusedTopicFollowUp(forQuestion, priorFocus);
      final trades = TradeJournalScope.of(context).items;
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.performanceSummary,
        'performanceSummaryContext': await CoachAiPerformanceFocus.summaryContextToJson(
          trades,
          languageCode,
          forQuestion,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(),
        'responseRules': <String, dynamic>{
          'style': briefFollowUp ? 'performance_summary_brief_followup' : 'performance_summary_numbered',
          'noDisciplineAudit': true,
          'noTradeJournalAudit': true,
          'maxWords': briefFollowUp ? 90 : 170,
          'format': briefFollowUp ? 'brief_answer_only' : 'intro_then_1_to_4_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null &&
        CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus) ==
            CoachAiFocus.performanceLens) {
      final briefFollowUp =
          CoachAiConversation.isFocusedTopicFollowUp(forQuestion, priorFocus);
      final trades = TradeJournalScope.of(context).items;
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.performanceLens,
        'performanceLensContext': await CoachAiPerformanceFocus.lensContextToJson(
          trades,
          languageCode,
          forQuestion,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(),
        'responseRules': <String, dynamic>{
          'style': briefFollowUp ? 'performance_lens_brief_followup' : 'performance_lens_numbered',
          'noDisciplineAudit': true,
          'noTradeJournalAudit': true,
          'maxWords': briefFollowUp ? 90 : 160,
          'format': briefFollowUp ? 'brief_answer_only' : 'intro_then_1_to_4_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null &&
        CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus) ==
            CoachAiFocus.performanceOvertrading) {
      final briefFollowUp =
          CoachAiConversation.isFocusedTopicFollowUp(forQuestion, priorFocus);
      final trades = TradeJournalScope.of(context).items;
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.performanceOvertrading,
        'performanceOvertradingContext':
            await CoachAiPerformanceFocus.overtradingContextToJson(
          trades,
          languageCode,
          forQuestion,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(),
        'responseRules': <String, dynamic>{
          'style': briefFollowUp
              ? 'performance_overtrading_brief_followup'
              : 'performance_overtrading_numbered',
          'noDisciplineAudit': true,
          'noTradeJournalAudit': true,
          'maxWords': briefFollowUp ? 90 : 160,
          'format': briefFollowUp ? 'brief_answer_only' : 'intro_then_1_to_4_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null && CoachAiFocus.resolve(forQuestion) == CoachAiFocus.appPricing) {
      final l10n = AppLocalizations.of(context)!;
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.appPricing,
        'pricingContext': CoachAiAppPricing.contextToJson(l10n, languageCode),
        'responseRules': <String, dynamic>{
          'style': 'pricing_numbered',
          'noTradeStats': true,
          'noDisciplineAudit': true,
          'maxWords': 160,
          'format': 'intro_then_1_to_5_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null && CoachAiFocus.resolve(forQuestion) == CoachAiFocus.appHelp) {
      final guide = await CoachAiAppHelp.guideContextForQuestion(
        forQuestion,
        languageCode: languageCode,
      );
      return <String, dynamic>{
        'questionFocus': 'app_help',
        'appHelpGuide': guide ??
            <String, dynamic>{
              'matched': false,
              'hint': 'Question utilisation PAYCHEK.',
            },
        'responseRules': <String, dynamic>{
          'style': 'short_how_to',
          'maxWords': 110,
          'noTradeStats': true,
          'noCoachingSermon': true,
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }
    final base = _buildAuditContext(
      forQuestion: forQuestion,
      languageCode: languageCode,
    );
    base['conversation'] = _conversationContextBlock();
    if (forQuestion == null) return base;
    final guide = await CoachAiAppHelp.guideContextForQuestion(
      forQuestion,
      languageCode: languageCode,
    );
    if (guide != null) {
      base['appHelpGuide'] = guide;
    }
    return base;
  }

  Map<String, dynamic> _buildAuditContext({
    String? forQuestion,
    String languageCode = 'fr',
  }) {
    final snap = _computeAuditSnapshot();
    final focus = forQuestion == null ? 'coach' : CoachAiFocus.resolve(forQuestion);
    final mentalQuery =
        forQuestion == null ? null : CoachAiMentalAnalysis.extractMentalQuery(forQuestion);
    final emotionStats = mentalQuery == null
        ? null
        : CoachAiMentalAnalysis.buildStatsForQuery(
            TradeJournalScope.of(context).items,
            mentalQuery,
          );
    final trades = TradeJournalScope.of(context).items;
    final nonRespectReport = forQuestion == null
        ? null
        : CoachAiNonRespectAnalysis.buildReport(context, trades);
    final psychWhyFocus = forQuestion == null
        ? null
        : CoachAiPsychAnalysis.buildFocus(trades, forQuestion);
    final perfSplit = focus == 'performance_summary'
        ? CoachAiPerformanceSummary.build(trades)
        : null;
    final tradeListReport = focus == 'trade_list' && forQuestion != null
        ? CoachAiTradeListQuery.build(trades, forQuestion)
        : null;
    final storyFocus = forQuestion == null
        ? null
        : CoachAiCoachingStory.buildFocus(trades, forQuestion);
    final missing = <String, dynamic>{};
    final recorded = <String, dynamic>{};
    for (final p in snap.disciplinePillars) {
      final key = switch (p.title) {
        'Checklist' => 'checklist',
        'Analyse' => 'analysisPlan',
        'Stratégie' => 'strategy',
        _ => 'mentalState',
      };
      missing[key] = p.missing;
      recorded[key] = p.recorded;
    }

    return <String, dynamic>{
      'questionFocus': focus,
      if (emotionStats != null)
        'mentalEmotionFocus': CoachAiMentalAnalysis.statsToJson(emotionStats),
      if (nonRespectReport != null && focus == 'non_respect')
        'nonRespectImpact': CoachAiNonRespectAnalysis.reportToJson(nonRespectReport),
      if (psychWhyFocus != null && focus == 'psychology_why')
        'psychologyWhyFocus': CoachAiPsychAnalysis.focusToJson(
          psychWhyFocus,
          languageCode: languageCode,
        ),
      if (perfSplit != null)
        'performanceSplit': CoachAiPerformanceSummary.splitToJson(perfSplit),
      if (tradeListReport != null)
        'tradeListQuery': CoachAiTradeListQuery.reportToJson(tradeListReport),
      if (storyFocus != null && focus == 'coaching_story')
        'coachingStoryFocus': CoachAiCoachingStory.focusToJson(
          storyFocus,
          languageCode: languageCode,
        ),
      'tradesTotal': snap.tradesTotal,
      'tradesClosed': snap.tradesClosed,
      'wins': snap.wins,
      'losses': snap.losses,
      'breakevenOrFlat': snap.breakevenOrFlat,
      'winratePercent': snap.winratePercent,
      'pnlTotal': snap.pnlTotal,
      'tradesWithoutFullPerformanceData': snap.performanceLite,
      'recordedDiscipline': recorded,
      'missingDiscipline': missing,
      'nonRespectCount': <String, dynamic>{
        'checklistItems': snap.disciplinePillars[0].nonRespect,
        'analysisItems': snap.disciplinePillars[1].nonRespect,
        'strategyItems': snap.disciplinePillars[2].nonRespect,
        'mentalItems': snap.disciplinePillars[3].nonRespect,
      },
      'tradeJournal': CoachAiTradeJournalContext.build(trades),
      'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
    };
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

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

  Widget _buildCalendarTodayCard(_CoachAiMessage m, String question) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = CoachAiCalendar.todayCardTitle(lang);
    final body = m.text.trim();
    final trades = TradeJournalScope.of(context).items;

    Color pnlColor(double v) {
      if (v > 0) return const Color(0xFF34D399);
      if (v < 0) return const Color(0xFFF87171);
      return const Color(0xFF9CA3AF);
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
              color: const Color(0xFF134E4A).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF115E59)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.calendar_today_rounded, size: 17, color: Color(0xFF2DD4BF)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: FutureBuilder<CalendarTodaySnapshot>(
                future: CoachAiCalendar.buildTodaySnapshot(trades),
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: _coachText(
                                size: 15,
                                color: const Color(0xFF2DD4BF),
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (data != null)
                            Text(
                              data.dateLabel,
                              style: _coachText(size: 12, color: const Color(0xFF6B7280)),
                            ),
                        ],
                      ),
                      if (data != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatMoneyLocal(data.pnlToday),
                                style: _coachText(
                                  size: 18,
                                  color: pnlColor(data.pnlToday),
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              lang == 'fr'
                                  ? '${data.tradesToday} trade${data.tradesToday > 1 ? 's' : ''}'
                                  : '${data.tradesToday} trade${data.tradesToday == 1 ? '' : 's'}',
                              style: _coachText(size: 13, color: const Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (data.checklistPercent != null)
                              _analysisChip(
                                lang == 'fr'
                                    ? 'Checklist ${data.checklistPercent}%'
                                    : 'Checklist ${data.checklistPercent}%',
                                const Color(0xFFF59E0B),
                              ),
                            if (data.mentalScore != null)
                              _analysisChip(
                                lang == 'fr'
                                    ? 'Mental ${data.mentalScore}%'
                                    : 'Mental ${data.mentalScore}%',
                                const Color(0xFF34D399),
                              ),
                            for (final setup in data.setupsUsedToday.take(2))
                              _analysisChip(setup, const Color(0xFFC084FC)),
                          ],
                        ),
                        if (data.monthlyObjective != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            lang == 'fr'
                                ? 'Mois : ${formatMoneyLocal(data.monthPnl)} / objectif ${formatMoneyLocal(data.monthlyObjective!)}'
                                : 'Month: ${formatMoneyLocal(data.monthPnl)} / goal ${formatMoneyLocal(data.monthlyObjective!)}',
                            style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ],
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CoachAiFormattedNarrative(text: body),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarMonthCard(_CoachAiMessage m, String question) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = CoachAiCalendar.monthCardTitle(lang);
    final body = m.text.trim();
    final trades = TradeJournalScope.of(context).items;

    Color pnlColor(double v) {
      if (v > 0) return const Color(0xFF34D399);
      if (v < 0) return const Color(0xFFF87171);
      return const Color(0xFF9CA3AF);
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
              color: const Color(0xFF134E4A).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF115E59)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.calendar_month_rounded, size: 17, color: Color(0xFF2DD4BF)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: FutureBuilder<CalendarMonthSnapshot>(
                future: CoachAiCalendar.buildMonthSnapshot(trades, lang),
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?.monthLabel ?? title,
                        style: _coachText(
                          size: 15,
                          color: const Color(0xFF2DD4BF),
                          weight: FontWeight.w800,
                        ),
                      ),
                      if (data != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          formatMoneyLocal(data.monthPnl),
                          style: _coachText(
                            size: 18,
                            color: pnlColor(data.monthPnl),
                            weight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _analysisChip(
                              lang == 'fr'
                                  ? '${data.monthTrades} trades · WR ${data.monthWinratePercent}%'
                                  : '${data.monthTrades} trades · WR ${data.monthWinratePercent}%',
                              const Color(0xFF60A5FA),
                            ),
                            _analysisChip(
                              lang == 'fr'
                                  ? '${data.greenDays}J+ / ${data.redDays}J-'
                                  : '${data.greenDays} green / ${data.redDays} red',
                              const Color(0xFF34D399),
                            ),
                            if (data.objectiveProgressPercent != null)
                              _analysisChip(
                                lang == 'fr'
                                    ? 'Objectif ${data.objectiveProgressPercent}%'
                                    : 'Goal ${data.objectiveProgressPercent}%',
                                const Color(0xFFF59E0B),
                              ),
                          ],
                        ),
                      ],
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CoachAiFormattedNarrative(text: body),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyTodayCard(_CoachAiMessage m, String question) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = CoachAiStrategyToday.todayCardTitle(lang);
    final body = m.text.trim();

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
              color: const Color(0xFF581C87).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF7E22CE)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.track_changes_rounded, size: 17, color: Color(0xFFC084FC)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: FutureBuilder<StrategyTodaySnapshot>(
                future: CoachAiStrategyToday.buildTodaySnapshot(),
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: _coachText(
                          size: 15,
                          color: const Color(0xFFC084FC),
                          weight: FontWeight.w800,
                        ),
                      ),
                      if (data != null && data.hasData) ...[
                        const SizedBox(height: 10),
                        if (data.setupTitle.isNotEmpty)
                          Text(
                            data.setupTitle,
                            style: _coachText(
                              size: 14,
                              color: const Color(0xFFF3F4F6),
                              weight: FontWeight.w800,
                            ),
                          ),
                        if (data.signalText.isNotEmpty && data.signalText != '—') ...[
                          const SizedBox(height: 6),
                          Text(
                            data.signalText,
                            style: _coachText(size: 13, color: const Color(0xFFD1D5DB)),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (data.timeframes.isNotEmpty && data.timeframes != '—')
                              _analysisChip(data.timeframes, const Color(0xFF7C3AED)),
                            if (data.pattern.isNotEmpty && data.pattern != '—')
                              _analysisChip(data.pattern, const Color(0xFF2563EB)),
                            if (data.indicateurs.isNotEmpty && data.indicateurs != '—')
                              _analysisChip(data.indicateurs, const Color(0xFF059669)),
                            _analysisChip(
                              lang == 'fr'
                                  ? 'Risque ${data.riskPct}% · RR ${data.rrRatio}'
                                  : 'Risk ${data.riskPct}% · RR ${data.rrRatio}',
                              const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                        if (data.rules.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          for (final rule in data.rules.take(3))
                            if (rule.heading.isNotEmpty || rule.body.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  rule.heading.isNotEmpty
                                      ? '${rule.heading}${rule.body.isNotEmpty ? ' — ${rule.body}' : ''}'
                                      : rule.body,
                                  style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                                ),
                              ),
                        ],
                      ],
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CoachAiFormattedNarrative(text: body),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTodayCard(_CoachAiMessage m, String question) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = CoachAiAnalysisToday.todayCardTitle(lang);
    final body = m.text.trim();

    Color confidenceColor(int score) {
      if (score >= 70) return const Color(0xFF34D399);
      if (score >= 40) return const Color(0xFFFBBF24);
      return const Color(0xFFF87171);
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
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF1D4ED8)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.insights_outlined, size: 17, color: Color(0xFF60A5FA)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: FutureBuilder<AnalysisTodaySnapshot>(
                future: CoachAiAnalysisToday.buildTodaySnapshot(),
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: _coachText(
                                size: 15,
                                color: const Color(0xFF60A5FA),
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (data != null && data.hasData)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: confidenceColor(data.globalConfidencePercent)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: confidenceColor(data.globalConfidencePercent)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                '${data.globalConfidencePercent}%',
                                style: _coachText(
                                  size: 13,
                                  color: confidenceColor(data.globalConfidencePercent),
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (data != null && data.hasData) ...[
                        const SizedBox(height: 10),
                        if (data.actif.isNotEmpty)
                          Text(
                            data.actif,
                            style: _coachText(
                              size: 14,
                              color: const Color(0xFFF3F4F6),
                              weight: FontWeight.w800,
                            ),
                          ),
                        if (data.sousTitre.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            data.sousTitre,
                            style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (data.biasLabel.isNotEmpty)
                              _analysisChip(data.biasLabel, const Color(0xFF2563EB)),
                            if (data.trendLabel.isNotEmpty)
                              _analysisChip(data.trendLabel, const Color(0xFF7C3AED)),
                            if (data.phaseLabel.isNotEmpty)
                              _analysisChip(data.phaseLabel, const Color(0xFF059669)),
                            if (data.confluenceScore > 0)
                              _analysisChip(
                                lang == 'fr'
                                    ? 'Confluence ${data.confluenceScore}'
                                    : 'Confluence ${data.confluenceScore}',
                                const Color(0xFFF59E0B),
                              ),
                          ],
                        ),
                        if (data.contexteTfLine.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            data.contexteTfLine,
                            style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                        if (data.support.isNotEmpty || data.resistance.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            [
                              if (data.support.isNotEmpty) 'S ${data.support}',
                              if (data.resistance.isNotEmpty) 'R ${data.resistance}',
                            ].join('  ·  '),
                            style: _coachText(size: 13, color: const Color(0xFFD1D5DB)),
                          ),
                        ],
                        if (!data.isToday && data.contexteDateLabel.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            lang == 'fr'
                                ? 'Date analyse : ${data.contexteDateLabel}'
                                : 'Analysis date: ${data.contexteDateLabel}',
                            style: _coachText(size: 11, color: const Color(0xFF6B7280)),
                          ),
                        ],
                      ],
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CoachAiFormattedNarrative(text: body),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: _coachText(size: 11, color: color, weight: FontWeight.w700),
      ),
    );
  }

  Widget _buildChecklistTodayCard(_CoachAiMessage m, String question) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = CoachAiChecklistToday.todayCardTitle(lang);
    final body = m.text.trim();

    Color scoreColor(int score) {
      if (score >= 80) return const Color(0xFF34D399);
      if (score >= 40) return const Color(0xFFFBBF24);
      return const Color(0xFFF87171);
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
              color: const Color(0xFF78350F).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF92400E)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.checklist_rounded, size: 17, color: Color(0xFFFBBF24)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: FutureBuilder<ChecklistTodaySnapshot>(
                future: CoachAiChecklistToday.buildTodaySnapshot(),
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: _coachText(
                                size: 15,
                                color: const Color(0xFFFBBF24),
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (data != null && data.hasItemsDueToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: scoreColor(data.percent).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: scoreColor(data.percent).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                '${data.percent}%',
                                style: _coachText(
                                  size: 13,
                                  color: scoreColor(data.percent),
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (data != null && data.hasItemsDueToday) ...[
                        const SizedBox(height: 10),
                        for (final section in data.sections) ...[
                          if (section.title.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              section.title,
                              style: _coachText(
                                size: 12,
                                color: const Color(0xFF9CA3AF),
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                          for (final item in section.items)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    item.checked
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    size: 16,
                                    color: item.checked
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: _coachText(
                                        size: 13,
                                        color: item.checked
                                            ? const Color(0xFFD1D5DB)
                                            : const Color(0xFF9CA3AF),
                                        weight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CoachAiFormattedNarrative(text: body),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentalTodayCard(_CoachAiMessage m, String question) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final snap = CoachAiMentalAnalysis.buildTodaySnapshot(
      l10n,
      TradeJournalScope.of(context).items,
    );
    final bd = snap.breakdown;
    final title = CoachAiMentalAnalysis.todayCardTitle(lang);
    final body = m.text.trim();

    Color scoreColor(int score) {
      if (score >= 50) return const Color(0xFF34D399);
      return const Color(0xFFF87171);
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
            child: const Icon(Icons.psychology_outlined, size: 17, color: Color(0xFF34D399)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: _coachText(size: 15, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                      ),
                      if (bd != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: scoreColor(bd.overallPercent).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: scoreColor(bd.overallPercent).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            '${bd.overallPercent}%',
                            style: _coachText(
                              size: 13,
                              color: scoreColor(bd.overallPercent),
                              weight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    CoachAiFormattedNarrative(text: body),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentalEmotionCard(_CoachAiMessage m, String question) {
    final mentalQuery =
        CoachAiMentalAnalysis.extractMentalQuery(question) ??
        const CoachMentalQuery(kind: 'emotion', label: 'émotion');
    final stats = CoachAiMentalAnalysis.buildStatsForQuery(
      TradeJournalScope.of(context).items,
      mentalQuery,
    );
    final query = stats?.query ?? mentalQuery;
    final title = CoachAiMentalAnalysis.displayTitle(query);
    final compareParts = _mentalCompareLabels(query).split('|');
    final leftTitle = compareParts.first;
    final rightTitle = compareParts.length > 1 ? compareParts[1] : 'Autre';

    String? verdict;
    if (stats != null) {
      if (stats.matchedTrades == 0 && stats.otherEtatTrades > 0) {
        verdict =
            'Aucun trade en $leftTitle — compare surtout la colonne $rightTitle (${stats.otherEtatTrades} trades).';
      } else if (stats.matchedClosed > 0 && stats.otherClosed > 0) {
        final wrDiff = stats.matchedWinrate - stats.otherWinrate;
        if (wrDiff.abs() >= 8) {
          verdict = wrDiff < 0
              ? 'Winrate ${wrDiff.abs().toStringAsFixed(0)} pts plus bas en $leftTitle.'
              : 'Winrate ${wrDiff.abs().toStringAsFixed(0)} pts plus haut en $leftTitle.';
        }
      }
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
            child: const Icon(Icons.psychology_outlined, size: 17, color: Color(0xFF34D399)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _coachMentalFocusTitle(title)),
                      if (query.polarity == 'low')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F1D1D).withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFF87171).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'BAS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              color: const Color(0xFFF87171),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (query.polarity == 'high')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'HAUT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              color: const Color(0xFF34D399),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (stats == null) ...[
                    const SizedBox(height: 10),
                    Text(
                      mentalQuery.kind == 'metric'
                          ? 'Renseigne ton état mental sur tes jours de trade pour activer cette comparaison.'
                          : 'Renseigne les émotions du jour sur tes trades pour activer cette comparaison.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        height: 1.45,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (stats != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1F2937)),
                      ),
                      child: _coachCoverageLine(
                        tradesEtat: stats.tradesWithEtatMental,
                        tradesMetric:
                            stats.query.kind == 'metric' ? stats.tradesWithMetricValue : null,
                        metricLabel: stats.query.kind == 'metric' ? stats.query.label : null,
                        split: stats.query.kind == 'metric' ? stats.splitValueUsed : null,
                      ),
                    ),
                    if (verdict != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF422006).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                verdict,
                                style: _coachText(
                                  size: 13.5,
                                  height: 1.4,
                                  color: const Color(0xFFFDE68A),
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _coachMentalCompareColumn(
                            title: leftTitle,
                            subtitle: 'Focus demandé',
                            trades: stats.matchedTrades,
                            closed: stats.matchedClosed,
                            winrate: stats.matchedWinrate,
                            pnl: stats.matchedPnl,
                            isPrimary: true,
                          ),
                          const SizedBox(width: 10),
                          _coachMentalCompareColumn(
                            title: rightTitle,
                            subtitle: 'Comparaison',
                            trades: stats.otherEtatTrades,
                            closed: stats.otherClosed,
                            winrate: stats.otherWinrate,
                            pnl: stats.otherPnl,
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _CoachExpandableInsight(text: m.text),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paychekTrainingRoutineCard() {
    const steps = <(IconData, String, String)>[
      (Icons.checklist_rtl_outlined, 'Chaque jour', 'Checklist + état mental (2 min)'),
      (Icons.insights_outlined, 'Avant chaque trade', 'Plan d\'analyse + stratégie'),
      (Icons.sell_outlined, 'Après le trade', 'Tag psych (FOMO, TILT…) + non-respect si besoin'),
      (Icons.calendar_month_outlined, '4 semaines', 'Saisie régulière → patterns chiffrés dans PAYCHEK'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF14532D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entraînement PAYCHEK (modeste, mais efficace)',
            style: _coachText(size: 13.5, color: const Color(0xFF6EE7B7), weight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'La discipline demande de la constance — pas la perfection.',
            style: _coachText(size: 12.5, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          for (final s in steps) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(s.$1, size: 16, color: const Color(0xFF34D399)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${s.$2}  ',
                            style: _coachText(size: 13, color: const Color(0xFF34D399), weight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: s.$3,
                            style: _coachText(size: 13, color: const Color(0xFFD1D5DB), weight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoachingStoryCard(_CoachAiMessage m, String question) {
    final focus = CoachAiCoachingStory.buildFocus(
      TradeJournalScope.of(context).items,
      question,
    );
    final themes = focus?.themes ?? <String>[];
    final lang = Localizations.localeOf(context).languageCode;
    final subtitle = CoachAiFocus.coachingStoryCardSubtitle(
      languageCode: lang,
      asksHowToFix: focus?.asksHowToFix ?? false,
      asksOpinion: focus?.asksOpinion ?? false,
    );

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
              color: const Color(0xFF422006).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.45)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.forum_outlined, size: 17, color: Color(0xFFF59E0B)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Coach',
                          style: _coachText(size: 16, color: const Color(0xFFF59E0B), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: subtitle,
                          style: _coachText(size: 16, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (themes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final t in themes)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF422006).withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                            ),
                            child: Text(
                              t,
                              style: _coachText(size: 12, color: const Color(0xFFFDE68A), weight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _CoachExpandableInsight(text: m.text),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPsychWhyCard(_CoachAiMessage m, String question) {
    final focus = CoachAiPsychAnalysis.buildFocus(
      TradeJournalScope.of(context).items,
      question,
    );
    final tag = focus?.tagQuery ?? 'émotion';
    final stats = focus?.tagStats;

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
            child: const Icon(Icons.psychology_alt_outlined, size: 17, color: Color(0xFF34D399)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pourquoi ',
                          style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: tag,
                          style: _coachText(size: 16, color: const Color(0xFFF59E0B), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' ?',
                          style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (stats != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _performanceMetricChip('Trades tagués', '${stats.trades}'),
                        _performanceMetricChip(
                          'Winrate',
                          '${stats.winrate}%',
                          color: stats.closed > 0
                              ? (stats.winrate >= 50
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFF87171))
                              : const Color(0xFF9CA3AF),
                        ),
                        _performanceMetricChip(
                          'PnL',
                          '${stats.pnl}',
                          color: stats.pnl >= 0
                              ? const Color(0xFF34D399)
                              : const Color(0xFFF87171),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tague tes trades sur Ajouter un trade (section TAG) pour que PAYCHEK relie $tag à tes résultats.',
                      style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _paychekTrainingRoutineCard(),
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _CoachExpandableInsight(text: m.text),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNonRespectCard(_CoachAiMessage m) {
    final report = CoachAiNonRespectAnalysis.buildReport(
      context,
      TradeJournalScope.of(context).items,
    );

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
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: 'Non-respect',
                          style: _coachText(size: 16, color: const Color(0xFFF87171), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' & pertes',
                          style: _coachText(size: 16, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (report == null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Aucun point « non respecté » enregistré sur tes trades pour l’instant. '
                      'Coche-les sur Ajouter un trade pour que le Coach calcule l’impact.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        height: 1.45,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (report != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _performanceMetricChip(
                          'Trades avec écart',
                          '${report.tradesWithAnyViolation}',
                          color: const Color(0xFF9CA3AF),
                        ),
                        _performanceMetricChip(
                          'Pertes (clôturées)',
                          '${report.closedLossesWithViolation}',
                          color: const Color(0xFFF87171),
                        ),
                        _performanceMetricChip(
                          'Gains (clôturés)',
                          '${report.closedWinsWithViolation}',
                          color: const Color(0xFF34D399),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...report.topItems.take(6).map((v) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: CoachAiNonRespectAnalysis.pillarLabel(v.pillar),
                                      style: _coachText(
                                        size: 13,
                                        color: switch (v.pillar) {
                                          'strategy' => const Color(0xFF34D399),
                                          'analysisPlan' => const Color(0xFF60A5FA),
                                          'checklist' => const Color(0xFFF59E0B),
                                          _ => const Color(0xFFA78BFA),
                                        },
                                        weight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '  ·  ',
                                      style: _coachText(size: 13, color: const Color(0xFF4B5563), weight: FontWeight.w700),
                                    ),
                                    TextSpan(
                                      text: v.label,
                                      style: _coachText(size: 12.5, color: Colors.white, weight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _performanceMetricChip(
                                    'Fois',
                                    '${v.count}',
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  _performanceMetricChip(
                                    'Pertes liées',
                                    '${v.onClosedLosses}',
                                    color: v.onClosedLosses > 0
                                        ? const Color(0xFFF87171)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                  if (v.onClosedLosses + v.onClosedWins > 0)
                                    _performanceMetricChip(
                                      '% perte',
                                      '${v.lossRateWhenViolatedPercent}%',
                                      color: v.lossRateWhenViolatedPercent >= 50
                                          ? const Color(0xFFF87171)
                                          : const Color(0xFF34D399),
                                    ),
                                  _performanceMetricChip(
                                    'PnL',
                                    '${v.pnlSumWhenViolated}',
                                    color: v.pnlSumWhenViolated >= 0
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFFF87171),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _coachNarrativeBlock(m.text, maxLines: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeListCard(_CoachAiMessage m, String question) {
    final report = CoachAiTradeListQuery.build(
      TradeJournalScope.of(context).items,
      question,
    );
    final tag = CoachAiPsychAnalysis.extractTagQuery(question);

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
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Trades',
                          style: _coachText(size: 16, color: const Color(0xFFA78BFA), weight: FontWeight.w800),
                        ),
                        if (tag != null)
                          TextSpan(
                            text: ' · $tag',
                            style: _coachText(size: 16, color: Colors.white, weight: FontWeight.w800),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.headline,
                    style: _coachText(size: 12, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                  ),
                  if (report.rows.isEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      report.hint,
                      style: _coachText(size: 13.5, color: const Color(0xFF6B7280), weight: FontWeight.w500),
                    ),
                  ],
                  if (report.rows.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    for (final row in report.rows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      row.pair,
                                      style: _coachText(size: 14, color: Colors.white, weight: FontWeight.w800),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    row.sideLabel,
                                    style: _coachText(size: 10, color: const Color(0xFF6B7280), weight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    row.isClosed
                                        ? '${row.pnl >= 0 ? '+' : ''}${row.pnl}'
                                        : 'Ouvert',
                                    style: _coachText(
                                      size: 13,
                                      color: row.isClosed
                                          ? (row.pnl >= 0
                                              ? const Color(0xFF34D399)
                                              : const Color(0xFFF87171))
                                          : const Color(0xFFF59E0B),
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                row.dateLabel,
                                style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (row.psychTags.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final t in row.psychTags)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: row.matchedTags
                                                  .any((m) => m.toLowerCase() == t.toLowerCase())
                                              ? const Color(0xFF4C1D95).withValues(alpha: 0.45)
                                              : const Color(0xFF1F2937),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: row.matchedTags
                                                    .any((m) => m.toLowerCase() == t.toLowerCase())
                                                ? const Color(0xFFA78BFA)
                                                : const Color(0xFF374151),
                                          ),
                                        ),
                                        child: Text(
                                          t,
                                          style: _coachText(
                                            size: 10,
                                            color: row.matchedTags
                                                    .any((m) => m.toLowerCase() == t.toLowerCase())
                                                ? const Color(0xFFE9D5FF)
                                                : const Color(0xFF9CA3AF),
                                            weight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                  if (report.hint.isNotEmpty && report.rows.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      report.hint,
                      style: _coachText(size: 12.5, color: const Color(0xFF6B7280), weight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryFollowUpCard(_CoachAiMessage m, String question) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = CoachAiFocus.storyFollowUpCardTitle(lang);
    final body = m.text.trim();
    final fallbackSteps = CoachAiConversation.storyFollowUpSteps(lang);

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
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: _coachText(size: 15, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' · mode d’emploi',
                          style: _coachText(size: 15, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    CoachAiFormattedNarrative(text: body),
                  ] else ...[
                    const SizedBox(height: 12),
                    for (var i = 0; i < fallbackSteps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: _coachText(size: 13, color: const Color(0xFF6EE7B7), weight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fallbackSteps[i],
                                style: _coachText(size: 14, color: const Color(0xFFE5E7EB), weight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppPricingCard(_CoachAiMessage m) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = CoachAiAppPricing.cardTitle(lang);
    final subtitle = CoachAiAppPricing.cardSubtitle(lang);
    final body = m.text.trim();

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
              color: const Color(0xFF422006).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.45)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.payments_outlined, size: 17, color: Color(0xFFF59E0B)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: _coachText(size: 15, color: const Color(0xFFF59E0B), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: subtitle,
                          style: _coachText(size: 15, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    CoachAiFormattedNarrative(text: body),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppHelpCard(_CoachAiMessage m, String question, {required String focus}) {
    final lang = Localizations.localeOf(context).languageCode;
    final steps = CoachAiAppHelp.uiStepsForQuestion(question, lang);
    final slug = CoachAiAppHelp.resolveGuideSlug(question);
    final title = CoachAiAppHelp.localCardTitle(question, lang) ??
        (slug == null
            ? 'Aide PAYCHEK'
            : helpCenterArticles
                .where((a) => a.slug == slug)
                .map((a) => a.frenchTitle)
                .firstOrNull ??
                'Aide PAYCHEK');

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
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: _coachText(size: 15, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' · mode d’emploi',
                          style: _coachText(size: 15, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (steps.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    for (var i = 0; i < steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: _coachText(size: 13, color: const Color(0xFF6EE7B7), weight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                steps[i],
                                style: _coachText(size: 14, color: const Color(0xFFE5E7EB), weight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  if (m.text.trim().isNotEmpty && steps.isEmpty) ...[
                    const SizedBox(height: 8),
                    CoachAiFormattedNarrative(text: m.text),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOvertradingCard(_CoachAiMessage m, String question) {
    final lang = Localizations.localeOf(context).languageCode;
    final body = m.text.trim();
    final trades = TradeJournalScope.of(context).items;
    final period = CoachAiPerformanceFocus.resolvePeriod(question);
    final periodLabel = CoachAiPerformanceFocus.periodLabel(period, lang);

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
              color: const Color(0xFF7C2D12).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF9A3412)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.speed_rounded, size: 17, color: Color(0xFFFB923C)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'fr' ? 'Overtrading · $periodLabel' : 'Overtrading · $periodLabel',
                    style: _coachText(size: 15, color: const Color(0xFFFB923C), weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  for (final bucket in CoachAiPerformanceFocus.overtradingSnapshots(
                    trades,
                    lang,
                    question,
                  ))
                    if (bucket.hasData)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                bucket.label,
                                style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                              ),
                            ),
                            Text(
                              '${bucket.winratePercent}% WR · ${bucket.tradeCount} trades',
                              style: _coachText(size: 12, color: const Color(0xFFD1D5DB)),
                            ),
                          ],
                        ),
                      ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    CoachAiFormattedNarrative(text: body),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceLensCard(_CoachAiMessage m, String question) {
    final lang = Localizations.localeOf(context).languageCode;
    final body = m.text.trim();
    final trades = TradeJournalScope.of(context).items;
    final period = CoachAiPerformanceFocus.resolvePeriod(question);
    final periodLabel = CoachAiPerformanceFocus.periodLabel(period, lang);
    final composite = CoachAiPerformanceFocus.compositeDisciplinePercent(trades, question);

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
            child: const Icon(Icons.visibility_outlined, size: 17, color: Color(0xFF34D399)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Paychek Lens · $periodLabel',
                          style: _coachText(size: 15, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                      ),
                      if (composite != null)
                        Text(
                          '$composite%',
                          style: _coachText(size: 14, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final axis in CoachAiPerformanceFocus.lensAxisSnapshots(trades, lang, question))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${axis.label} : ${axis.qualifiedCount}/${axis.totalCount}',
                        style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                      ),
                    ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    CoachAiFormattedNarrative(text: body),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummaryCard(_CoachAiMessage m, String question) {
    final lang = Localizations.localeOf(context).languageCode;
    final period = CoachAiPerformanceFocus.resolvePeriod(question);
    final periodLabel = CoachAiPerformanceFocus.periodLabel(period, lang);
    final split = CoachAiPerformanceSummary.build(
      CoachAiPerformanceFocus.filterJournalItems(
        TradeJournalScope.of(context).items,
        period,
      ),
    );
    final recorded = split.fullyRecorded;
    final incomplete = split.disciplineIncomplete;
    final global = split.global;

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
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: 'Performance',
                          style: _coachText(size: 16, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' · $periodLabel',
                          style: _coachText(size: 16, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Journal : ${global.tradesTotal} trades · ${global.tradesClosed} clôturés · '
                    'PnL ${global.pnlTotal >= 0 ? '+' : ''}${global.pnlTotal} · '
                    'WR ${global.winratePercent}%',
                    style: _coachText(size: 13, color: const Color(0xFF6B7280), weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _coachMentalCompareColumn(
                          title: 'Enregistrés',
                          subtitle: '4/4 discipline',
                          trades: recorded.tradesTotal,
                          closed: recorded.tradesClosed,
                          winrate: recorded.winratePercent,
                          pnl: recorded.pnlTotal,
                          isPrimary: true,
                        ),
                        const SizedBox(width: 10),
                        _coachMentalCompareColumn(
                          title: 'Non enregistrés',
                          subtitle: 'Donnée(s) manquante(s)',
                          trades: incomplete.tradesTotal,
                          closed: incomplete.tradesClosed,
                          winrate: incomplete.winratePercent,
                          pnl: incomplete.pnlTotal,
                          isPrimary: false,
                        ),
                      ],
                    ),
                  ),
                  if (incomplete.tradesTotal > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Complète checklist, analyse, stratégie et état mental sur tes trades '
                      'pour une performance PAYCHEK fiable.',
                      style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w500),
                    ),
                  ],
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _CoachExpandableInsight(text: m.text),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAuditCard(_CoachAiMessage m, {required String focus}) {
    final snap = _computeAuditSnapshot();
    final diagnosis = _extractSectionBody(m.text, '3');
    final actions = _extractSectionBody(m.text, '4');
    final focusedPillar = _pillarForFocus(snap.disciplinePillars, focus);
    final isFull = focus == 'full';
    final pillar = focusedPillar;
    final isPillarFocus = pillar != null;
    final isTradeCountFocus = focus == 'trade_count';
    final showDetailed = isFull || isPillarFocus;

    Widget infoBlock({
      required IconData icon,
      required String title,
      required String body,
    }) {
      if (body.isEmpty) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.33),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: const Color(0xFF34D399)),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                height: 1.45,
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.26),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📊', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 8),
                      Text(
                        isPillarFocus ? 'Focus ${pillar.title}' : 'Bilan Paychek',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 27 / 2,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPillarFocus
                        ? 'Analyse ciblée sur ${pillar.title.toLowerCase()} (trades enregistrés uniquement).'
                        : 'Voici un récapitulatif de votre activité :',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.4,
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isFull) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _kpiTile('Trades totaux', '${snap.tradesTotal}'),
                        _kpiTile('Trades clôturés', '${snap.tradesClosed}'),
                        _kpiTile('Gagnants', '${snap.wins}'),
                        _kpiTile('Perdants', '${snap.losses}'),
                        _kpiTile('Winrate', '${snap.winratePercent}%'),
                        _kpiTile(
                          'PnL total',
                          '${snap.pnlTotal}',
                          valueColor: snap.pnlTotal >= 0
                              ? const Color(0xFF34D399)
                              : const Color(0xFFF87171),
                        ),
                      ],
                    ),
                  ],
                  if (showDetailed) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Audit discipline',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (isPillarFocus) _disciplinePillarCard(pillar)
                        else
                          for (final pillar in snap.disciplinePillars)
                            _disciplinePillarCard(pillar),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF14532D)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Color(0xFF34D399),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pour calculer les performances, PAYCHEK prend en compte '
                              'uniquement les trades enregistrés (checklist, analyse, '
                              'stratégie, état mental). '
                              'Si tu veux un bilan sur tous tes trades, complète les '
                              'données manquantes depuis la page Ajouter un trade.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.2,
                                height: 1.45,
                                color: const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Diagnostic performance',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bilan calculé uniquement sur les trades enregistrés de chaque section.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isPillarFocus) _performancePillarSection(pillar)
                    else
                      for (final pillar in snap.disciplinePillars)
                        _performancePillarSection(pillar),
                  ],
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _coachNarrativeBlock(
                      diagnosis.isNotEmpty && !isTradeCountFocus ? diagnosis : m.text,
                      maxLines: isPillarFocus ? 4 : (isTradeCountFocus ? 3 : 5),
                    ),
                  ],
                  if (isFull && diagnosis.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    infoBlock(
                      icon: Icons.analytics_outlined,
                      title: 'Analyse coach',
                      body: diagnosis,
                    ),
                  ],
                  if (isFull && actions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    infoBlock(
                      icon: Icons.flag_circle_outlined,
                      title: 'Plan d\'action',
                      body: actions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
        if (focus == 'app_help') {
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

    return Material(
      color: const Color(0xFF050505),
      child: SafeArea(
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
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 12),
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
                                    enabled: !_sending,
                                    minLines: 1,
                                    maxLines: 5,
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
