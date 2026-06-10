part of 'coach_ai_page.dart';

extension _CoachAiPageContext on _CoachAiPageState {
  Future<Map<String, dynamic>> _buildAuditContextAsync({
    String? forQuestion,
    required String languageCode,
    String? priorAssistantFocus,
  }) async {
    final priorFocus = priorAssistantFocus ??
        (_messages.length >= 2 ? _lastAssistantFocus() : null);
    final resolvedFocus = forQuestion == null
        ? 'coach'
        : CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus);

    if (forQuestion != null &&
        resolvedFocus == 'conversation_followup' &&
        priorFocus != null) {
      final threaded = _buildAuditContext(
        forQuestion: forQuestion,
        languageCode: languageCode,
        priorAssistantFocus: priorFocus,
        questionFocusOverride: priorFocus,
      );
      threaded['conversation'] = _conversationContextBlock(
        priorAssistantFocus: priorFocus,
      );
      threaded['responseRules'] = <String, dynamic>{
        ...(threaded['responseRules'] as Map<String, dynamic>? ?? {}),
        'style': 'thread_continuation',
        'threadContinuation': true,
        'maxWords': 200,
      };
      threaded['coachInstructions'] = languageCode == 'fr'
          ? 'FOCUS=suite de conversation. Lis conversation.priorTurns : la question actuelle prolonge ou précise le message précédent. '
              'Ne réponds pas comme si c’était la première question. Réutilise le sujet du fil puis apporte la nouvelle réponse.'
          : 'FOCUS=conversation follow-up. Read conversation.priorTurns; the current question continues the thread. '
              'Do not answer as if it were the first message.';
      return threaded;
    }

    if (forQuestion != null &&
        CoachAiConversation.isStoryFollowUp(forQuestion, priorFocus)) {
      return <String, dynamic>{
        'questionFocus': 'story_followup',
        'paychekUiSteps': CoachAiConversation.storyFollowUpSteps(languageCode),
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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

    if (forQuestion != null &&
        CoachAiFocus.resolve(forQuestion, priorAssistantFocus: priorFocus) ==
            CoachAiFocus.pillarImprovement) {
      final snap = _computeAuditSnapshot();
      final pillarId = CoachAiPillarCoaching.resolvePillarId(forQuestion);
      final pillar = switch (pillarId) {
        'checklist' => snap.disciplinePillars[0],
        'analysis' => snap.disciplinePillars[1],
        'mental' => snap.disciplinePillars[3],
        _ => snap.disciplinePillars[2],
      };
      final lang = languageCode;
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.pillarImprovement,
        'pillarImprovementContext': CoachAiPillarCoaching.contextToJson(
          pillarId: pillarId,
          pillarTitle: CoachAiPillarCoaching.pillarTitle(pillarId, lang),
          tradesTotal: snap.tradesTotal,
          recorded: pillar.recorded,
          missing: pillar.missing,
          nonRespect: pillar.nonRespect,
          winrateRecorded: pillar.winrateRecorded,
          pnlRecorded: pillar.pnlRecorded,
          targetPercent: CoachAiPillarCoaching.extractTargetPercent(forQuestion),
          languageCode: lang,
        ),
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
        'responseRules': <String, dynamic>{
          'style': 'pillar_improvement_numbered',
          'noDisciplineAudit': true,
          'noPillarStats': true,
          'noTradeJournalAudit': true,
          'maxWords': 200,
          'format': 'intro_then_1_to_5_single_lines',
        },
        'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      };
    }

    if (forQuestion != null && CoachAiFocus.resolve(forQuestion) == CoachAiFocus.coachingStory) {
      final story = CoachAiCoachingStory.buildFocus(
        _coachJournalTrades(),
        forQuestion,
      );
      return <String, dynamic>{
        'questionFocus': 'coaching_story',
        if (story != null)
          'coachingStoryFocus': CoachAiCoachingStory.focusToJson(
            story,
            languageCode: languageCode,
          ),
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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
          _coachJournalTrades(),
          languageCode,
        ),
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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
      final trades = _coachJournalTrades();
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.calendarToday,
        'calendarTodayContext': await CoachAiCalendar.todayContextToJson(
          trades,
          languageCode,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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
      final trades = _coachJournalTrades();
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.calendarMonth,
        'calendarMonthContext': await CoachAiCalendar.monthContextToJson(
          trades,
          languageCode,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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
      final trades = _coachJournalTrades();
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.performanceSummary,
        'performanceSummaryContext': await CoachAiPerformanceFocus.summaryContextToJson(
          trades,
          languageCode,
          forQuestion,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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
      final trades = _coachJournalTrades();
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.performanceLens,
        'performanceLensContext': await CoachAiPerformanceFocus.lensContextToJson(
          trades,
          languageCode,
          forQuestion,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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
      final trades = _coachJournalTrades();
      return <String, dynamic>{
        'questionFocus': CoachAiFocus.performanceOvertrading,
        'performanceOvertradingContext':
            await CoachAiPerformanceFocus.overtradingContextToJson(
          trades,
          languageCode,
          forQuestion,
          briefFollowUp: briefFollowUp,
        ),
        'conversation': _conversationContextBlock(priorAssistantFocus: priorFocus),
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
      priorAssistantFocus: priorFocus,
    );
    base['conversation'] = _conversationContextBlock(priorAssistantFocus: priorFocus);
    if (forQuestion != null &&
        priorFocus != null &&
        CoachAiConversation.isConversationalFollowUp(forQuestion, priorFocus)) {
      base['responseRules'] = <String, dynamic>{
        ...(base['responseRules'] as Map<String, dynamic>? ?? {}),
        'threadContinuation': true,
      };
    }
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
    String? priorAssistantFocus,
    String? questionFocusOverride,
  }) {
    final snap = _computeAuditSnapshot();
    final matchQ = forQuestion == null
        ? ''
        : CoachAiQueryText.forMatching(forQuestion);
    final focus = questionFocusOverride ??
        (forQuestion == null
            ? 'coach'
            : CoachAiFocus.resolve(
                matchQ,
                priorAssistantFocus: priorAssistantFocus,
              ));
    final mentalQuery =
        forQuestion == null ? null : CoachAiMentalAnalysis.extractMentalQuery(forQuestion);
    final emotionStats = mentalQuery == null
        ? null
        : CoachAiMentalAnalysis.buildStatsForQuery(
            _coachJournalTrades(),
            mentalQuery,
          );
    final trades = _coachJournalTrades();
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
    final relatedTradesPreview = storyFocus != null &&
            focus == 'coaching_story' &&
            forQuestion != null
        ? CoachAiRelatedTrades.build(
            trades,
            forQuestion,
            themes: storyFocus.themes,
          )
        : null;
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
      if (relatedTradesPreview != null)
        'relatedTradesPreview': <String, dynamic>{
          'title': relatedTradesPreview.title,
          'subtitle': relatedTradesPreview.subtitle,
          'journalTotal': relatedTradesPreview.journalTotal,
          'count': relatedTradesPreview.rows.length,
          'trades': [
            for (final row in relatedTradesPreview.rows)
              <String, dynamic>{
                'pair': row.pair,
                'date': row.dateLabel,
                'pnl': row.pnl,
                'psychTags': row.psychTags,
              },
          ],
        },
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
      'portfolioScope': coachAiPortfolioScopeJson(context),
      'tradeJournal': CoachAiTradeJournalContext.build(
        trades,
        portfolioScope: coachAiPortfolioScopeJson(context),
      ),
      'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
