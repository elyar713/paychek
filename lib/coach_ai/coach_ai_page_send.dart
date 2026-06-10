part of 'coach_ai_page.dart';

extension _CoachAiPageSend on _CoachAiPageState {
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
    if (code == 'internal') {
      final detail = message?.trim();
      if (detail != null &&
          detail.isNotEmpty &&
          detail.toUpperCase() != 'INTERNAL') {
        return detail;
      }
      return 'Coach cloud momentanément indisponible. '
          'Une réponse locale a été utilisée si possible.';
    }
    return message ?? 'Erreur AI Coach';
  }

  Future<String> _buildPillarLocalAnswer({
    required String question,
    required String languageCode,
  }) async {
    final snap = _computeAuditSnapshot();
    final pillarId = CoachAiPillarCoaching.resolvePillarId(question);
    final pillar = switch (pillarId) {
      'checklist' => snap.disciplinePillars[0],
      'analysis' => snap.disciplinePillars[1],
      'mental' => snap.disciplinePillars[3],
      _ => snap.disciplinePillars[2],
    };
    final pillarStats = CoachAiPillarCoaching.statsFromPillars(
      tradesTotal: snap.tradesTotal,
      pillars: [
        for (final i in [0, 1, 2, 3])
          (
            id: switch (i) {
              0 => 'checklist',
              1 => 'analysis',
              2 => 'strategy',
              _ => 'mental',
            },
            title: snap.disciplinePillars[i].title,
            recorded: snap.disciplinePillars[i].recorded,
            nonRespect: snap.disciplinePillars[i].nonRespect,
            winrateRecorded: snap.disciplinePillars[i].winrateRecorded,
            pnlRecorded: snap.disciplinePillars[i].pnlRecorded,
          ),
      ],
    );
    final strategyPillar = pillarStats.firstWhere((p) => p.id == 'strategy');
    if (CoachAiPillarCoaching.isTrainingSystemQuestion(question) ||
        (pillarId == 'strategy' &&
            CoachAiPillarCoaching.isImprovementQuestion(question))) {
      return CoachAiPillarCoaching.buildLocalAnswer(
        pillarId: pillarId,
        pillarTitle: CoachAiPillarCoaching.pillarTitle(pillarId, languageCode),
        tradesTotal: snap.tradesTotal,
        recorded: pillar.recorded,
        missing: pillar.missing,
        nonRespect: pillar.nonRespect,
        winrateRecorded: pillar.winrateRecorded,
        pnlRecorded: pillar.pnlRecorded,
        targetPercent: CoachAiPillarCoaching.extractTargetPercent(question),
        languageCode: languageCode,
      );
    }
    if (CoachAiPillarCoaching.isStrategyOpinionQuestion(question)) {
      final setupSnap = await CoachAiStrategyToday.buildTodaySnapshot();
      return CoachAiPillarCoaching.buildLocalStrategyOpinionAnswer(
        hasSetup: setupSnap.hasData,
        setupTitle: setupSnap.setupTitle,
        patternHint: setupSnap.pattern.trim(),
        strategy: strategyPillar,
        languageCode: languageCode,
      );
    }
    if (CoachAiPillarCoaching.isReinforcementQuestion(question)) {
      return CoachAiPillarCoaching.buildLocalReinforcementAnswer(
        pillars: pillarStats,
        highlightPillarId: pillarId,
        languageCode: languageCode,
        topViolationLabels: _strategyViolationLabels(),
      );
    }
    return CoachAiPillarCoaching.buildLocalAnswer(
      pillarId: pillarId,
      pillarTitle: CoachAiPillarCoaching.pillarTitle(pillarId, languageCode),
      tradesTotal: snap.tradesTotal,
      recorded: pillar.recorded,
      missing: pillar.missing,
      nonRespect: pillar.nonRespect,
      winrateRecorded: pillar.winrateRecorded,
      pnlRecorded: pillar.pnlRecorded,
      targetPercent: CoachAiPillarCoaching.extractTargetPercent(question),
      languageCode: languageCode,
    );
  }

  List<String> _strategyViolationLabels() {
    final report = CoachAiNonRespectAnalysis.buildReport(
      context,
      _coachJournalTrades(),
    );
    if (report == null) return const [];
    return [
      for (final item in report.topItems)
        if (item.pillar == 'strategy') item.label,
    ].take(3).toList();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      final target = _scrollCtrl.position.maxScrollExtent + 120;
      _scrollCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
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

  Map<String, dynamic> _conversationContextBlock({String? priorAssistantFocus}) {
    if (_messages.isEmpty) return const {};
    final priorTurns = CoachAiConversation.priorTurnsToJson(
      texts: _messages.map((m) => m.text).toList(),
      isUserFlags: _messages.map((m) => m.isUser).toList(),
      isErrorFlags: _messages.map((m) => m.isError).toList(),
      responseFocuses: _messages.map((m) => m.responseFocus).toList(),
      excludeLastCount: 1,
    );
    final threadMode = priorTurns.isNotEmpty &&
        priorAssistantFocus != null &&
        priorAssistantFocus != 'trade_list' &&
        priorAssistantFocus != 'app_help' &&
        priorAssistantFocus != 'app_help_hybrid';
    return <String, dynamic>{
      'priorTurns': priorTurns,
      'priorAssistantFocus': ?priorAssistantFocus,
      if (threadMode) 'threadMode': true,
    };
  }

  Future<void> _emitLocalCoachingStoryAnswer({
    required String rawQuestion,
    required String languageCode,
  }) async {
    final trades = _coachJournalTrades();
    final localAnswer = CoachAiCoachingStory.buildLocalAnswer(
      question: rawQuestion,
      languageCode: languageCode,
      trades: trades,
    );
    if (!mounted) return;
    _coachMutate(() {
      _sending = false;
      _messages.add(
        _CoachAiMessage(
          text: localAnswer,
          isUser: false,
          relatedUserQuestion: rawQuestion,
          responseFocus: CoachAiFocus.coachingStory,
        ),
      );
    });
    _scrollToBottom();
  }

  Future<void> _emitLocalPillarAnswer({
    required String rawQuestion,
    required String languageCode,
  }) async {
    String localAnswer;
    try {
      localAnswer = await _buildPillarLocalAnswer(
        question: rawQuestion,
        languageCode: languageCode,
      );
    } catch (_) {
      localAnswer = CoachAiPillarCoaching.buildEmergencyFallback(languageCode);
    }
    if (!mounted) return;
    _coachMutate(() {
      _sending = false;
      _messages.add(
        _CoachAiMessage(
          text: localAnswer,
          isUser: false,
          relatedUserQuestion: rawQuestion,
          responseFocus: CoachAiFocus.pillarImprovement,
        ),
      );
    });
    _scrollToBottom();
  }

  Future<void> _askCoach() async {
    final rawQuestion = _questionCtrl.text.trim();
    if (rawQuestion.isEmpty || _sending) return;
    final question = CoachAiQueryText.forMatching(rawQuestion);
    _questionCtrl.clear();
    _coachMutate(() {
      _sending = true;
      _messages.add(_CoachAiMessage(text: rawQuestion, isUser: true));
    });
    _scrollToBottom();

    final lang = _responseLang(rawQuestion);
    final locale = Locale(lang);
    final priorFocus = _lastAssistantFocus();

    // Récit psycho / feeling : local (pas cloud).
    if (CoachAiCoachingStory.isCoachingStoryQuestion(rawQuestion)) {
      await _emitLocalCoachingStoryAnswer(
        rawQuestion: rawQuestion,
        languageCode: lang,
      );
      return;
    }

    // Coaching stratégie : toujours local en premier (pas d’appel cloud / pas d’audit).
    if (CoachAiPillarCoaching.shouldAnswerLocally(
      rawQuestion,
      priorFocus: priorFocus,
    )) {
      await _emitLocalPillarAnswer(rawQuestion: rawQuestion, languageCode: lang);
      return;
    }

    final focus = CoachAiFocus.resolve(rawQuestion, priorAssistantFocus: priorFocus);
    final preferCloudThread = CoachAiConversation.shouldPreferCloudWithThread(
      question: question,
      priorAssistantFocus: priorFocus,
      resolvedFocus: focus,
    );

    if (focus == 'trade_list' && !preferCloudThread) {
      final report = CoachAiTradeListQuery.build(
        _coachJournalTrades(),
        question,
      );
      if (!mounted) return;
      _coachMutate(() {
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

    if (focus == 'app_help' && !preferCloudThread) {
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
      final hybrid = CoachAiAppHelp.usesHybridHelpLayout(question);
      final answerText = hybrid
          ? CoachAiAppHelp.formatHybridHelpAnswer(
              intro: CoachAiAppHelp.workflowCoachIntro(lang),
              steps: steps,
              languageCode: lang,
              title: title,
            )
          : CoachAiAppHelp.formatStepsAnswer(
              steps,
              languageCode: lang,
              title: title,
            );
      if (!mounted) return;
      _coachMutate(() {
        _sending = false;
        _messages.add(
          _CoachAiMessage(
            text: answerText,
            isUser: false,
            relatedUserQuestion: question,
            responseFocus: hybrid ? 'app_help_hybrid' : 'app_help',
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    if (focus == CoachAiFocus.pillarImprovement) {
      await _emitLocalPillarAnswer(rawQuestion: rawQuestion, languageCode: lang);
      return;
    }

    if (focus == CoachAiFocus.coachingStory) {
      await _emitLocalCoachingStoryAnswer(
        rawQuestion: rawQuestion,
        languageCode: lang,
      );
      return;
    }

    final auditContext = await _buildAuditContextAsync(
      forQuestion: question,
      languageCode: lang,
      priorAssistantFocus: priorFocus,
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final portfolioScope = coachAiPortfolioScopeJson(context);
    auditContext['paychekAppSnapshot'] = await CoachAiAppSnapshot.buildCompact(
      l10n: l10n,
      trades: _coachJournalTrades(),
      languageCode: lang,
      portfolioScope: portfolioScope,
    );
    auditContext['portfolioScope'] = portfolioScope;
    if (!mounted) return;
    auditContext['responseLanguage'] = lang;
    final dataFirst = CoachAiAppSnapshot.dataFirstCoachInstructions(lang);
    final existingCoach = auditContext['coachInstructions'];
    if (existingCoach is String && existingCoach.trim().isNotEmpty) {
      auditContext['coachInstructions'] = '$dataFirst\n$existingCoach';
    } else {
      auditContext['coachInstructions'] = dataFirst;
    }
    final res = await PaychekAiCoachCloud.ask(
      question: rawQuestion,
      locale: locale,
      context: auditContext,
    );
    if (!mounted) return;

    String? localFallback;
    final wantsLocalStory = focus == CoachAiFocus.coachingStory ||
        CoachAiCoachingStory.isCoachingStoryQuestion(rawQuestion);
    final wantsLocalPillar = CoachAiPillarCoaching.shouldAnswerLocally(
          rawQuestion,
          priorFocus: priorFocus,
        ) ||
        focus == CoachAiFocus.pillarImprovement ||
        (focus == 'strategie' &&
            CoachAiPillarCoaching.looksLikeStrategyCoaching(
              rawQuestion,
              priorFocus: priorFocus,
            ));
    if (!res.ok && wantsLocalStory) {
      localFallback = CoachAiCoachingStory.buildLocalAnswer(
        question: rawQuestion,
        languageCode: lang,
        trades: _coachJournalTrades(),
      );
    } else if (!res.ok && wantsLocalPillar) {
      try {
        localFallback = await _buildPillarLocalAnswer(
          question: rawQuestion,
          languageCode: lang,
        );
      } catch (_) {
        localFallback = CoachAiPillarCoaching.buildEmergencyFallback(lang);
      }
    }
    if (!res.ok && (localFallback == null || localFallback.trim().isEmpty)) {
      localFallback = CoachAiPillarCoaching.buildEmergencyFallback(lang);
    }

    _coachMutate(() {
      _sending = false;
      _quotaUsed = res.quotaUsed;
      _quotaLimit = res.quotaLimit;
      final cloudText = res.ok ? res.answer?.trim() : null;
      final answer = cloudText != null && cloudText.isNotEmpty
          ? cloudText
          : (localFallback ?? _friendlyError(res.code, res.message));
      _messages.add(
        _CoachAiMessage(
          text: answer,
          isUser: false,
          isError: !res.ok && localFallback == null,
          relatedUserQuestion: rawQuestion,
          responseFocus: focus == 'conversation_followup'
              ? (priorFocus ?? focus)
              : (wantsLocalStory && localFallback != null
                  ? CoachAiFocus.coachingStory
                  : (wantsLocalPillar && localFallback != null
                      ? CoachAiFocus.pillarImprovement
                      : focus)),
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
    final trades = _coachJournalTrades();
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
}
