/// Format texte coach aligné sur [CoachAiFormattedNarrative] (intro + 1. 2. 3. 4.).
abstract final class CoachAiResponseFormat {
  /// Répare les réponses LLM mal formées : « (Biais…) » seul, « 1 » sur une ligne, etc.
  static String normalizeNarrative(String raw) {
    if (raw.trim().isEmpty) return raw;

    final lines = raw
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return raw;

    final intro = <String>[];
    final items = <String>[];
    var autoN = 1;
    String? holdNum;

    void pushItem(String num, String content) {
      var c = content.trim();
      if (c.isEmpty) return;
      if (RegExp(r'^(Biais|Bias)\s', caseSensitive: false).hasMatch(c) && !c.startsWith('(')) {
        c = '($c';
        if (!c.endsWith(')')) c = '$c)';
      }
      items.add('$num. $c');
      final parsed = int.tryParse(num);
      if (parsed != null && parsed >= autoN) autoN = parsed + 1;
    }

    for (final line in lines) {
      final fullNum = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line);
      if (fullNum != null) {
        holdNum = null;
        pushItem(fullNum.group(1)!, fullNum.group(2)!);
        continue;
      }
      if (RegExp(r'^\d+$').hasMatch(line)) {
        holdNum = line;
        continue;
      }

      final parenBias = RegExp(r'^\(([^)]+)\)\s*(.*)$').firstMatch(line);
      final brokenBias = RegExp(r'^(Biais|Bias)\s+([^)]+)\)\s*(.*)$', caseSensitive: false).firstMatch(line);
      if (parenBias != null || brokenBias != null) {
        final num = holdNum ?? '$autoN';
        holdNum = null;
        if (parenBias != null) {
          final rest = parenBias.group(2)?.trim() ?? '';
          pushItem(num, '(${parenBias.group(1)})${rest.isEmpty ? '' : ' $rest'}');
        } else {
          final rest = brokenBias!.group(3)?.trim() ?? '';
          pushItem(num, '(Biais ${brokenBias.group(2)?.trim()})${rest.isEmpty ? '' : ' $rest'}');
        }
        continue;
      }

      if (items.isEmpty && intro.length < 8) {
        intro.add(line);
      } else if (items.isNotEmpty) {
        final last = items.removeLast();
        items.add('$last $line');
      } else {
        intro.add(line);
      }
    }

    if (items.isEmpty) return raw;
    final introText = intro.join(' ').trim();
    if (introText.isEmpty) return items.join('\n');
    return '$introText\n\n${items.join('\n')}';
  }

  static String narrativeInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'MANDATORY OUTPUT (plain text, no markdown): '
          'Short intro (2-3 sentences): name the main psychological pattern and end with ONE short framing question. '
          'Then EXACTLY 4 numbered lines starting with "1." "2." "3." "4." — each line: "(Bias name) " then 1-2 sentences. '
          'Forbidden: unnumbered paragraphs, "Hope:" style bullet lists, listing journal trades by pair/date, '
          '4-pillar discipline audit, recordedDiscipline sermon. Max 200 words.';
    }
    return 'FORMAT DE SORTIE OBLIGATOIRE (texte brut, pas de markdown) : '
        'Intro courte (2-3 phrases) : nomme le pattern psycho principal et termine par UNE question de cadrage courte. '
        'Puis EXACTEMENT 4 lignes numérotées "1." "2." "3." "4." — chaque ligne ENTIÈRE sur une seule ligne, commençant par "N. (Nom du biais) " puis 1-2 phrases. '
        'Interdit : "(Biais…)" sur une ligne séparée du numéro, numéro seul sur une ligne, paragraphes sans numéros. '
        'Pas d\'inventaire trades journal, pas d\'audit discipline. Max 200 mots.';
  }

  static String storyFollowUpInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'MANDATORY: Read conversation.priorTurns (Revenge, FOMO, etc.). '
          'One intro sentence, then exactly 5 full lines "1." … "5." — each = one concrete PAYCHEK action for THEIR pattern. '
          'Each line on a single line (number + text). Max 180 words. No discipline audit.';
    }
    return 'FORMAT OBLIGATOIRE : lis conversation.priorTurns (revenge, FOMO, etc.). '
        'Une phrase d\'intro, puis 5 lignes complètes « 1. » … « 5. » — chaque ligne = action PAYCHEK concrète pour LEUR récit (TAG Revenge si pertinent, Checklist, État mental, ⚙ Session, revue trades tagués). '
        'Chaque point sur UNE seule ligne (numéro + texte). Max 180 mots. Pas d\'audit discipline.';
  }

  static String pricingInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=PAYCHEK app pricing (NOT trade prices). Use pricingContext JSON only — never say "check the website" without numbers. '
          'Adapt to the exact question (trial? monthly? Lite vs Pro?). '
          'FORMAT: 1-2 sentence intro answering them directly, then 4-5 numbered lines "1."–"5." on single lines. '
          'Cover only what they asked + essentials: Lite vs Pro, US\$ prices from JSON, 7-day trial, where to subscribe in-app. '
          'Max 160 words. No trading audit.';
    }
    return 'FOCUS=tarifs app PAYCHEK (PAS prix de trade). Utilise uniquement pricingContext — interdit « consulte le site » sans chiffres. '
        'Adapte à la question exacte (essai ? mensuel ? Lite vs Pro ?). '
        'FORMAT : intro 1-2 phrases qui répond directement, puis 4-5 lignes « 1. » à « 5. » sur une seule ligne chacune. '
        'Ne cite que ce qui est pertinent + l’essentiel : Lite vs Pro, prix US\$ du JSON, essai 7 jours, où souscrire dans l’app. '
        'Max 160 mots. Pas d’audit trading.';
  }

  static String performanceSummaryInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=PAYCHEK Performance page summary (recorded vs incomplete discipline split). '
          'Use performanceSummaryContext / performanceSplit + paychekLens only. '
          'FORMAT: 1 short intro, then 4 single lines "1."–"4." (global WR/PnL, fullyRecorded vs disciplineIncomplete, key gap, one tip). '
          'Respect period/periodLabel. FORBIDDEN: trade list, X/70 pillar audit sermon, ENREGISTRÉ blocks. Max 170 words.';
    }
    return 'FOCUS=résumé page Performance PAYCHEK (discipline complète vs incomplète). '
        'Utilise performanceSummaryContext / performanceSplit + paychekLens uniquement. '
        'FORMAT : 1 intro courte, puis 4 lignes « 1. » à « 4. » (WR/PnL global, enregistrés vs incomplets, écart clé, conseil). '
        'Respecte period/periodLabel. INTERDIT : liste trades, sermon audit 4 piliers, blocs ENREGISTRÉ. Max 170 mots.';
  }

  static String performanceSummaryFollowUpInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=brief follow-up after performance_summary. Read priorTurns — max 90 words. No full audit.';
    }
    return 'FOCUS=suite brève après performance_summary. Lis priorTurns — max 90 mots. Pas d’audit complet.';
  }

  static String performanceLensInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=Paychek Lens (Performance page). Use performanceLensContext only. '
          'FORMAT: 1 intro, then 4 lines (composite score, weakest axis, strongest/missing axis, tip). '
          'Cite axes qualified/total. FORBIDDEN: global 70-trade audit. Max 160 words.';
    }
    return 'FOCUS=Paychek Lens (page Performance). Utilise performanceLensContext uniquement. '
        'FORMAT : 1 intro, puis 4 lignes (score composite, axe le plus faible, axe manquant, conseil). '
        'Cite axes qualified/total. INTERDIT : audit global 70 trades. Max 160 mots.';
  }

  static String performanceLensFollowUpInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=brief follow-up after performance_lens. priorTurns only. Max 90 words.';
    }
    return 'FOCUS=suite brève après performance_lens. priorTurns uniquement. Max 90 mots.';
  }

  static String performanceOvertradingInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=day volume / overtrading (Performance → Day & volume). Use performanceOvertradingContext buckets. '
          'FORMAT: 1 intro, then 4 lines (best bucket WR, worst bucket WR, pattern insight, tip). '
          'FORBIDDEN: generic overtrading lecture without bucket numbers. Max 160 words.';
    }
    return 'FOCUS=volume journalier / overtrading (Performance → Journée & volume). Utilise buckets du JSON. '
        'FORMAT : 1 intro, puis 4 lignes (meilleure tranche WR, pire tranche, pattern, conseil). '
        'INTERDIT : sermon overtrade sans chiffres des tranches. Max 160 mots.';
  }

  static String performanceOvertradingFollowUpInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=brief follow-up after performance_overtrading. priorTurns only. Max 90 words.';
    }
    return 'FOCUS=suite brève après performance_overtrading. priorTurns uniquement. Max 90 mots.';
  }

  static String calendarTodayInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=today\'s PAYCHEK Calendar synthesis (trades + discipline + month context), NOT global discipline audit. '
          'Use calendarTodayContext only. '
          'FORMAT: 1 short intro, then 4 single lines "1."–"4." (PnL/trades today, checklist/mental/setup if present, month progress vs objective, one tip). '
          'If no activity today: say so calmly — invite fillHintPath. '
          'FORBIDDEN: generic calendar sermon, X/70 trades audit, ENREGISTRÉ/NON ENREGISTRÉ. Max 170 words.';
    }
    return 'FOCUS=synthèse calendrier DU JOUR (trades + discipline + mois), PAS audit discipline global. '
        'Utilise uniquement calendarTodayContext. '
        'FORMAT : 1 intro courte, puis 4 lignes « 1. » à « 4. » (PnL/trades du jour, checklist/mental/setup si dispo, progression mois vs objectif, conseil). '
        'Si pas d’activité aujourd’hui : le dire — inviter fillHintPath. '
        'INTERDIT : sermon calendrier générique, audit X/70 trades, ENREGISTRÉ/NON ENREGISTRÉ. Max 170 mots.';
  }

  static String calendarTodayFollowUpInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=brief follow-up after calendar_today. Read priorTurns — answer ONLY the new question. Max 90 words. No audit.';
    }
    return 'FOCUS=suite brève après calendar_today. Lis priorTurns — réponds UNIQUEMENT à la nouvelle question. Max 90 mots. Pas d’audit.';
  }

  static String calendarMonthInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=current month on PAYCHEK Calendar (objective + PnL + winrate + green/red days), NOT global audit. '
          'Use calendarMonthContext only. '
          'FORMAT: 1 short intro, then 4–5 single lines "1."–"5." (month PnL, trades, winrate, objective progress, coaching tip). '
          'If monthlyObjective is null: invite fillHintPath to set goal. '
          'FORBIDDEN: X/70 pillar audit, ENREGISTRÉ/NON ENREGISTRÉ. Max 180 words.';
    }
    return 'FOCUS=mois en cours sur Calendrier PAYCHEK (objectif + PnL + winrate + jours verts/rouges), PAS audit global. '
        'Utilise uniquement calendarMonthContext. '
        'FORMAT : 1 intro courte, puis 4–5 lignes « 1. » à « 5. » (PnL mois, trades, winrate, avancement objectif, conseil). '
        'Si monthlyObjective absent : inviter fillHintPath pour définir l’objectif. '
        'INTERDIT : audit 4 piliers X/70, ENREGISTRÉ/NON ENREGISTRÉ. Max 180 mots.';
  }

  static String calendarMonthFollowUpInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=brief follow-up after calendar_month. Read priorTurns — answer ONLY the new question. Max 90 words.';
    }
    return 'FOCUS=suite brève après calendar_month. Lis priorTurns — réponds UNIQUEMENT à la nouvelle question. Max 90 mots.';
  }

  static String strategyTodayInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=today\'s PAYCHEK Strategy page (setup + risk + rules), NOT trade discipline audit. '
          'Use strategyTodayContext only — cite THEIR setup title, signal, timeframes, pattern, rules, riskManagement, goldRules. '
          'FORMAT: 1 short intro sentence, then 4 single lines "1."–"4." (active setup, entry signal/rules, risk limits, one tip for today). '
          'If hasDataToday=false: invite fillHintPath — no invented generic strategy. '
          'FORBIDDEN: generic strategy template, global winrate, X/70 trades, ENREGISTRÉ/NON ENREGISTRÉ. Max 170 words.';
    }
    return 'FOCUS=stratégie DU JOUR (page Stratégie PAYCHEK), PAS audit discipline des trades. '
        'Utilise uniquement strategyTodayContext — cite LEUR setup, signal, TF, pattern, règles, riskManagement, goldRules. '
        'FORMAT : 1 phrase d’intro courte, puis 4 lignes « 1. » à « 4. » (setup actif, signal/règles, limites risque, conseil du jour). '
        'Si hasDataToday=false : inviter fillHintPath — interdit d’inventer une stratégie générique. '
        'INTERDIT : modèle générique, winrate global, X/70 trades, ENREGISTRÉ/NON ENREGISTRÉ. Max 170 mots.';
  }

  static String strategyTodayFollowUpInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=brief follow-up on the PREVIOUS strategy_today answer. '
          'Read conversation.priorTurns — answer ONLY the new question (e.g. most important point). '
          'Max 2-3 sentences OR 1 intro + 2 numbered lines. No discipline audit, no trade stats.';
    }
    return 'FOCUS=suite brève après strategy_today. '
        'Lis conversation.priorTurns — réponds UNIQUEMENT à la nouvelle question (ex. point le plus important). '
        'Max 2-3 phrases OU 1 intro + 2 lignes numérotées. Pas d’audit discipline, pas de stats trades.';
  }

  static String analysisTodayInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=today\'s PAYCHEK Analysis page (Mon Analyse), NOT trade discipline audit. '
          'Use analysisTodayContext only — cite THEIR asset, bias, trend, phase, confidence, confluence, S/R. '
          'FORMAT: 1 short intro sentence, then 4 single lines "1."–"4." (bias+TF, key levels, confluence/confidence, one trading tip). '
          'If hasDataToday=false: invite fillHintPath — no invented generic analysis. '
          'If isAnalysisDateToday=false but has data: say analysis date vs today briefly. '
          'FORBIDDEN: generic analysis template, global winrate, X/70 trades, ENREGISTRÉ/NON ENREGISTRÉ. Max 170 words.';
    }
    return 'FOCUS=analyse DU JOUR (page Analyse PAYCHEK), PAS audit discipline des trades. '
        'Utilise uniquement analysisTodayContext — cite LEUR actif, bias, tendance, phase, confiance, confluence, S/R. '
        'FORMAT : 1 phrase d’intro courte, puis 4 lignes « 1. » à « 4. » (bias+TF, niveaux clés, confluence/confiance, conseil). '
        'Si hasDataToday=false : inviter fillHintPath — interdit d’inventer une analyse générique. '
        'Si isAnalysisDateToday=false mais données présentes : mentionner la date d’analyse vs aujourd’hui. '
        'INTERDIT : modèle générique, winrate global, X/70 trades, ENREGISTRÉ/NON ENREGISTRÉ. Max 170 mots.';
  }

  static String analysisTodayFollowUpInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=brief follow-up on the PREVIOUS analysis_today answer. '
          'Read conversation.priorTurns — answer ONLY the new question (e.g. most important point). '
          'Max 2-3 sentences OR 1 intro + 2 numbered lines. No discipline audit, no trade stats.';
    }
    return 'FOCUS=suite brève après analysis_today. '
        'Lis conversation.priorTurns — réponds UNIQUEMENT à la nouvelle question (ex. point le plus important). '
        'Max 2-3 phrases OU 1 intro + 2 lignes numérotées. Pas d’audit discipline, pas de stats trades.';
  }

  static String checklistTodayInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=today\'s PAYCHEK Checklist page (tasks due today), NOT trade discipline audit. '
          'Use checklistTodayContext only — list THEIR items with checked true/false. '
          'FORMAT: 1 short intro sentence, then 4 single lines "1."–"4." (completion %, done vs pending items, priority unchecked, one tip). '
          'If hasItemsDueToday=false: invite fillHintPath — no invented generic checklist. '
          'FORBIDDEN: before/during/after trade template, global winrate, X/70 trades, ENREGISTRÉ/NON ENREGISTRÉ. Max 160 words.';
    }
    return 'FOCUS=checklist DU JOUR (page Checklist PAYCHEK), PAS audit discipline des trades. '
        'Utilise uniquement checklistTodayContext — cite LEURS items (checked true/false). '
        'FORMAT : 1 phrase d’intro courte, puis 4 lignes « 1. » à « 4. » (% complétion, fait / reste, priorité non cochée, conseil). '
        'Si hasItemsDueToday=false : inviter fillHintPath — interdit d’inventer une checklist générique avant/pendant/après trade. '
        'INTERDIT : modèle générique trading, winrate global, X/70 trades, ENREGISTRÉ/NON ENREGISTRÉ. Max 160 mots.';
  }

  static String checklistTodayFollowUpInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=brief follow-up on the PREVIOUS checklist_today answer. '
          'Read conversation.priorTurns — answer ONLY the new question (e.g. most important point). '
          'Max 2-3 sentences OR 1 intro + 2 numbered lines. No discipline audit, no trade stats, no generic checklist template.';
    }
    return 'FOCUS=suite brève après checklist_today. '
        'Lis conversation.priorTurns — réponds UNIQUEMENT à la nouvelle question (ex. point le plus important). '
        'Max 2-3 phrases OU 1 intro + 2 lignes numérotées. Pas d’audit discipline, pas de stats trades, pas de checklist générique.';
  }

  static String mentalTodayInstructions(String languageCode) {
    if (languageCode == 'en') {
      return 'FOCUS=today\'s mental state (Mental state page), NOT discipline audit / recorded trades. '
          'Use mentalTodayContext only. Adapt intro to their question. '
          'FORMAT: 1-2 sentence intro, then exactly 4 single lines "1."–"4." (score, strongest/weakest area, emotions, trading tip for today). '
          'If hasDataToday=false: invite to fill fillHintPath — no fake stats. '
          'FORBIDDEN: global winrate, ENREGISTRÉ/NON ENREGISTRÉ, X/70 trades audit. Max 180 words.';
    }
    return 'FOCUS=état mental DU JOUR (page État mental), PAS audit discipline / trades enregistrés. '
        'Utilise uniquement mentalTodayContext. Intro adaptée à la question. '
        'FORMAT : intro 1-2 phrases, puis 4 lignes « 1. » à « 4. » sur une seule ligne (score, point fort/faible, émotions, conseil trading du jour). '
        'Si hasDataToday=false : inviter fillHintPath — pas de stats inventées. '
        'INTERDIT : winrate global, ENREGISTRÉ/NON ENREGISTRÉ, audit X/70 trades. Max 180 mots.';
  }
}
