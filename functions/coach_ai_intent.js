/** Détection d'intention / focus Coach IA. */
function paychekNormalizeCoachLocale(raw) {
  const lc = `${raw ?? ""}`.trim().toLowerCase().split("_")[0].split("-")[0];
  if (["fr", "en", "es", "de", "pt", "ko"].includes(lc)) return lc;
  return "en";
}

/** Langue de réponse : priorité au texte de la question, sinon locale client. */
function paychekAiCoachDetectResponseLocale(question, clientLocale) {
  const q = `${question ?? ""}`.trim().toLowerCase();
  if (!q) return paychekNormalizeCoachLocale(clientLocale);

  let en = 0;
  let fr = 0;
  if (/[àâäéèêëïîôùûüç]/.test(q)) fr += 2;

  const enMarkers = new Set([
    "the", "what", "why", "how", "when", "where", "which", "should", "could",
    "would", "can", "do", "does", "did", "is", "are", "was", "were", "my",
    "your", "help", "please", "today", "yesterday", "week", "month",
    "performance", "strategy", "checklist", "analysis", "mental", "tell",
    "explain", "show", "list", "trade", "trades", "about", "with", "this",
    "that", "have", "has", "had",
  ]);
  const frMarkers = new Set([
    "le", "la", "les", "un", "une", "des", "du", "de", "et", "est", "sont",
    "pour", "pourquoi", "comment", "quand", "quel", "quelle", "quels",
    "quelles", "mon", "ma", "mes", "ton", "ta", "tes", "aide", "expliquer",
    "montre", "liste", "aujourd", "semaine", "mois", "strategie", "analyse",
    "discipline", "psychologie", "psycho", "avec", "cette", "cela", "suis",
    "ai", "pas", "plus", "moins",
  ]);

  for (const w of q.match(/[a-zàâäéèêëïîôùûüç']+/g) || []) {
    if (enMarkers.has(w)) en++;
    if (frMarkers.has(w)) fr++;
  }

  if (/\b(how do|how can|how should|what is|what are|what was|why do|why did|why is|tell me|show me|help me|can you|could you|should i|i have|i had|my trades)\b/.test(q)) {
    en += 2;
  }
  if (/\b(comment |pourquoi |est-ce que|qu'est-ce|quels? |quelles? |aujourd'hui|j'ai |c'est |donne-moi|aide-moi)\b/.test(q)) {
    fr += 2;
  }

  const scores = {en, fr, de: 0, es: 0, pt: 0, ko: 0};
  if (/[äöüß]/.test(q)) scores.de += 3;
  if (/[ñ¿¡]/.test(q)) scores.es += 3;
  if (/[ãõ]/.test(q)) scores.pt += 2;
  if (/[가-힣]/.test(q)) scores.ko += 5;

  const deMarkers = new Set([
    "der", "die", "das", "und", "ist", "sind", "ich", "mein", "meine", "dein",
    "warum", "wie", "wann", "welche", "welcher", "heute", "woche", "monat",
    "strategie", "analyse", "disziplin", "hilfe", "bitte", "nicht", "mehr",
  ]);
  const esMarkers = new Set([
    "el", "la", "los", "las", "una", "por", "porque", "cómo", "como", "cuando",
    "cuál", "cual", "mi", "tu", "hoy", "semana", "mes", "estrategia", "disciplina",
    "ayuda", "más", "mas", "menos",
  ]);
  const ptMarkers = new Set([
    "os", "as", "uma", "são", "sao", "porque", "quando", "qual", "meu", "minha",
    "hoje", "semana", "mês", "mes", "estratégia", "estrategia", "disciplina",
    "ajuda", "não", "nao", "mais", "menos",
  ]);
  const koMarkers = new Set([
    "오늘", "이번", "주", "월", "전략", "분석", "규율", "도움", "트레이드", "거래",
    "왜", "어떻게", "무엇", "내", "나의",
  ]);

  for (const w of q.match(/[a-zàâäéèêëïîôùûüçäöüßñãõ가-힣']+/g) || []) {
    if (deMarkers.has(w)) scores.de++;
    if (esMarkers.has(w)) scores.es++;
    if (ptMarkers.has(w)) scores.pt++;
    if (koMarkers.has(w)) scores.ko++;
  }

  if (/\b(wie |warum |was ist|kann ich|können sie|hilf mir)\b/.test(q)) scores.de += 2;
  if (/\b(cómo |por qué |qué es|puedes |ayúdame|muéstrame)\b/.test(q)) scores.es += 2;
  if (/\b(como |por que |o que |podes |ajuda-me|mostra-me)\b/.test(q)) scores.pt += 2;
  if (/(어떻게|왜|무엇|도와|알려)/.test(q)) scores.ko += 2;

  const ranked = Object.entries(scores).sort((a, b) => b[1] - a[1]);
  const top = ranked[0];
  const second = ranked.length > 1 ? ranked[1][1] : 0;
  if (top[1] >= 1 && top[1] > second) return top[0];
  return paychekNormalizeCoachLocale(clientLocale);
}

/** Fautes fréquentes (miroir Flutter coach_ai_query_text.dart). */
function paychekAiCoachNormalizeQuestion(question) {
  let q = `${question ?? ""}`.toLowerCase().trim();
  if (!q) return q;
  q = q.replace(/['`´]/g, "'");
  const reps = {
    chekliste: "checklist",
    cheklist: "checklist",
    checklit: "checklist",
    checlist: "checklist",
    someil: "sommeil",
    sommeill: "sommeil",
    sommei: "sommeil",
    somil: "sommeil",
    dimlinue: "diminue",
    diminiu: "diminue",
    performence: "performance",
    perfomance: "performance",
    pyscho: "psycho",
    psyhco: "psycho",
    winrat: "winrate",
    winrte: "winrate",
    aujourdhui: "aujourd'hui",
    ajourdhui: "aujourd'hui",
    regler: "régler",
    regle: "régler",
    strategie: "stratégie",
    ameliore: "améliorer",
    ameliorer: "améliorer",
    audti: "audit",
    audite: "audit",
    trede: "trade",
    impatien: "impatience",
  };
  for (const [from, to] of Object.entries(reps)) {
    q = q.replace(new RegExp(`\\b${from}\\b`, "g"), to);
  }
  return q;
}

function paychekAiCoachHelpCenterKnowledge(locale) {
  const fr =
    "REFERENTIEL HELP CENTER PAYCHEK:\n" +
    "- Add Trade: enregistrer un trade avec checklists, etat mental, strategie, execution et contexte.\n" +
    "- Trade Page - Journal: consulter l'historique, filtrer, ouvrir chaque trade et completer les champs manquants.\n" +
    "- Calendar: suivi journalier, historique cumulatif et KPI objectif pour la regularite.\n" +
    "- Checklist: planifier rappels, marquer les taches faites, utiliser la checklist comme garde-fou avant execution.\n" +
    "- Dashboard: vue centrale (capital, winrate, discipline, cartes resumees) pour pilotage quotidien.\n" +
    "- Mental State: suivre les emotions (peur, confiance, fatigue...) et mesurer leur impact sur la performance.\n" +
    "- My Strategy: definir regles d'or, sessions, setups, templates et exigences de conformite.\n" +
    "- My Analysis: analyser contexte initial, confluence et rapport d'analyse pour decisions plus propres.\n" +
    "- Performance: audit statistique complet (KPI, discipline, comportement, seuils strategie, export rapport).";

  const en =
    "PAYCHEK HELP CENTER KNOWLEDGE BASE:\n" +
    "- Add Trade: log a trade with checklist, mental state, strategy, execution, and context.\n" +
    "- Trade Page - Journal: browse history, filter entries, open each trade, and complete missing fields.\n" +
    "- Calendar: daily tracking, cumulative history, and objective KPI monitoring.\n" +
    "- Checklist: schedule reminders, mark tasks done, and use checklist as a pre-execution guardrail.\n" +
    "- Dashboard: central view (capital, winrate, discipline, summary cards) for daily control.\n" +
    "- Mental State: track emotions (fear, confidence, fatigue...) and evaluate performance impact.\n" +
    "- My Strategy: define golden rules, sessions, setups, templates, and compliance requirements.\n" +
    "- My Analysis: review initial context, confluence, and analysis report for cleaner decisions.\n" +
    "- Performance: full statistical audit (KPIs, discipline, behavior, strategy thresholds, report export).";

  const de =
    "PAYCHEK HELP CENTER (DE):\n" +
    "- Trade hinzufügen: Trade mit Checkliste, Mentalzustand, Strategie erfassen.\n" +
    "- Trade-Journal: Historie, Filter, fehlende Felder pro Trade.\n" +
    "- Kalender: Tages-PnL, Monatsziele.\n" +
    "- Checklist: Tagesaufgaben, Erinnerungen.\n" +
    "- Dashboard: Kapital, Winrate, Disziplin.\n" +
    "- Mentalzustand: Schlaf, Emotionen, Fokus.\n" +
    "- Meine Strategie: Setups, Regeln, Sessions.\n" +
    "- Meine Analyse: Tagesplan, Konfluenz, Bericht.\n" +
    "- Performance: KPIs, Paychek Lens, Overtrading.";
  const es =
    "PAYCHEK HELP CENTER (ES):\n" +
    "- Añadir trade: registrar con checklist, estado mental, estrategia.\n" +
    "- Diario Trade: historial, filtros, campos faltantes.\n" +
    "- Calendario: PnL diario/mensual, objetivos.\n" +
    "- Checklist: tareas del día.\n" +
    "- Dashboard: capital, winrate, disciplina.\n" +
    "- Estado mental: sueño, emociones, foco.\n" +
    "- Mi estrategia: setups, reglas, sesiones.\n" +
    "- Mi análisis: plan del día, informe.\n" +
    "- Performance: KPIs, Paychek Lens.";
  const pt =
    "PAYCHEK HELP CENTER (PT):\n" +
    "- Adicionar trade: checklist, estado mental, estratégia.\n" +
    "- Diário Trade: histórico, filtros.\n" +
    "- Calendário: PnL, objetivos.\n" +
    "- Checklist: tarefas do dia.\n" +
    "- Dashboard: capital, winrate, disciplina.\n" +
    "- Estado mental: sono, emoções.\n" +
    "- Minha estratégia: setups, regras.\n" +
    "- Minha análise: plano do dia.\n" +
    "- Performance: KPIs, Paychek Lens.";
  const ko =
    "PAYCHEK HELP CENTER (KO):\n" +
    "- 트레이드 추가: 체크리스트, 멘탈, 전략 기록.\n" +
    "- 트레이드 저널: 기록, 필터.\n" +
    "- 캘린더: 일/월 PnL, 목표.\n" +
    "- 체크리스트: 오늘 할 일.\n" +
    "- 대시보드: 자본, 승률, 규율.\n" +
    "- 멘탈 상태: 수면, 감정.\n" +
    "- 내 전략: 셋업, 규칙.\n" +
    "- 내 분석: 일일 계획.\n" +
    "- 퍼포먼스: KPI, Paychek Lens.";

  const table = {fr, en, de, es, pt, ko};
  return table[locale] || en;
}

function paychekAiCoachShouldUseHelpCenter(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (!q) return false;
  if (/(help\s*center|comment utiliser|comment faire|ou se trouve|où se trouve|fonctionnalit|workflow|guide|tutoriel|how to|where is|where can|feature|screen|app page)/i.test(q)) {
    return true;
  }
  if (/comment (modifier|changer|éditer|editer|ajouter|créer|creer|supprimer|configurer)/i.test(q)) {
    return true;
  }
  if (/(modifier|changer|éditer|editer|ajouter|créer|creer|configurer).{0,30}(checklist|trade|stratégie|strategie|analyse|mental|performance|calendrier|dashboard)/i.test(q)) {
    return true;
  }
  if (/^(comment|où|ou|where|how)\b/i.test(q.trim()) &&
    /checklist|trade|stratégie|strategie|analyse|mental|performance|calendrier|dashboard|paychek/i.test(q)) {
    return true;
  }
  if (/à quoi sert|a quoi sert|à sert|a sert|sert à quoi|sert a quoi|c'est quoi|cest quoi|what is|what does|explique|expliquer/i.test(q) &&
    /checklist|trade|strat|analyse|analysis|mental|performance|calendrier|dashboard|engrenage|feeling|principe|capital|csv|tag|coach|réglage|reglage|paychek/i.test(q)) {
    return true;
  }
  if (/engrenage|engrenage|⚙/i.test(q)) return true;
  if (/menu\s+plus|bouton\s+plus/i.test(q)) return true;
  return false;
}

function paychekAiCoachExtractMentalQuery(question) {
  const q = paychekAiCoachNormalizeQuestion(question);
  const stop = new Set([
    "quelle", "quel", "quoi", "comment", "combien", "quand", "performance",
    "rendement", "winrate", "bilan", "trade", "trades", "mon", "ma", "mes",
  ]);
  const low = /moins de|peu de|faible|bas\b|low\b|moins\b/.test(q);
  const high = /plus de|beaucoup de|élevé|eleve|high\b|fort\b|plus\b/.test(q);
  const polarity = low && !high ? "low" : (high && !low ? "high" : "neutral");

  const metricKeys = [
    "sommeil", "someil", "sommeill", "sleep", "dormi", "focus", "confiance", "confidence", "peur", "fear",
    "stress", "fatigue", "fomo", "tilt", "cupidité", "cupidite", "greed",
    "énergie", "energie", "émotionnel", "emotionnel", "méditation", "meditation",
  ];
  for (const key of metricKeys) {
    if (q.includes(key)) {
      return {kind: "metric", label: key, polarity};
    }
  }

  const emotionKeys = [
    "peur", "fear", "cupidité", "cupidite", "greed", "frustré", "frustre",
    "excité", "excite", "fomo", "tilt", "revenge", "vengeance",
  ];
  for (const key of emotionKeys) {
    if (q.includes(key)) {
      return {kind: "emotion", label: key, polarity};
    }
  }

  const whenMatch = q.match(
      /(?:quand|when).{0,40}(?:j.?ai|je suis|i am|i'm)\s+(?:(?:moins|peu|plus|beaucoup)\s+de\s+)?([a-zàâäéèêëïîôùûüç\-]{3,24})/i,
  );
  if (whenMatch && whenMatch[1]) {
    const captured = whenMatch[1].trim().toLowerCase();
    if (captured && !stop.has(captured)) {
      return {kind: "metric", label: captured, polarity};
    }
  }
  return null;
}

function paychekAiCoachIsPsychologyWhyQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (/c.?est quoi|c quoi|quelle psycho|quel psycho|what.{0,16}psycho/.test(q)) {
    return /fomo|tilt|revenge|peur|fear|frustr|cupidit|greed|stress|overtrade|émotion|emotion/.test(q);
  }
  const why = /pourquoi|why|comment se fait|d'où vient|d'ou vient|what caused/.test(q);
  if (!why) return false;
  return /fomo|tilt|revenge|peur|fear|frustr|cupidit|greed|stress|overtrade|émotion|emotion/.test(q);
}

function paychekAiCoachIsMetricPerformanceLinkQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  const hasMetric = /sommeil|someil|sommeill|sleep|dormi|\bnuit\b|focus|confiance|peur|fear|énergie|energie|stress|fatigue/.test(q);
  const hasPerf = /winrate|wr\b|pnl|rendement|performance|diminu|baisse|monte|gagn|perd/.test(q);
  const hasWhen = /\bquand\b|\bwhen\b/.test(q);
  const hasPolarity = /moins|plus|faible|bas\b|peu de|beaucoup|élevé|eleve/.test(q);
  return hasMetric && hasPerf && (hasWhen || hasPolarity);
}

function paychekAiCoachIsMentalPerformanceQuestion(question) {
  if (paychekAiCoachIsMetricPerformanceLinkQuestion(question)) return true;
  if (!paychekAiCoachExtractMentalQuery(question)) return false;
  const q = `${question ?? ""}`.toLowerCase();
  const coachingOnly = /comment\s+(améliorer|ameliorer|mieux|travailler|booster|renforcer)|conseil|astuce|tip|how\s+to\s+improve/.test(q);
  const performanceIntent = /performance|winrate|pnl|rendement|résultat|resultat|bilan|gagn|perd|quoi comme|quel.*résultat/.test(q);
  const whenIntent = /\bquand\b|\bwhen\b/.test(q);
  const polarityIntent = /moins de|plus de|peu de|beaucoup|faible|élevé|eleve|high|low|moins d'/.test(q);
  if (coachingOnly && !performanceIntent && !whenIntent) return false;
  return performanceIntent || whenIntent || polarityIntent;
}

function paychekAiCoachIsStoryFollowUpQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (q.length < 12) return false;
  return /comment|regler|régler|gérer|gerer|maitriser|maîtriser|éviter|eviter|cette psycho|cet psycho|cette pyscho|gerer cette|gérer cette|cette fonction|cet(te)? fonctionnal|avec (cette |l.)?app|dans paychek|pour (ça|ca)|ce pattern|taguer|utiliser paychek/.test(q);
}

function paychekAiCoachResolveFocusFromContext(contextData, question) {
  const turns = contextData?.conversation?.priorTurns;
  if (Array.isArray(turns) && turns.length > 0) {
    const last = turns[turns.length - 1];
    if (last?.role === "assistant" && last?.focus === "coaching_story" &&
      paychekAiCoachIsStoryFollowUpQuestion(question)) {
      return "story_followup";
    }
  }
  return "";
}

function paychekAiCoachIsCoachingStoryQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (/c.?est quoi|c quoi|quelle psycho|quel psycho|quoi comme psycho|what.{0,16}psycho|quel(le)?\s+probl[eè]me|what.{0,12}problem/.test(q)) {
    if (/trade|tp\b|take profit|gagnant|gain|perte|clotur|position|retourn|lacher|lâcher|attendre|patience|impatien|fomo|niveau|prix|marché|marche|psycho|émotion|emotion/.test(q)) {
      return q.length >= 40;
    }
  }
  if (/aujourd'hui|aujourdhui|today/.test(q) &&
      /attendre|patience|impatien|niveau|fomo|trop t[oô]t|prix/.test(q) &&
      /probl[eè]me|pourquoi|pas r[eé]ussir|n.arrive pas|difficile/.test(q)) {
    return true;
  }
  if (/comment (je peux |tu peux )?(régler|regler|régle|regle|gérer|gerer|maitriser|maîtriser|éviter|eviter)/.test(q)) {
    if (/psycho|pyscho|fomo|tilt|revenge|renvers|émotion|emotion|inquiétude|inquietude/.test(q)) {
      if (/aujourd'hui|sl\b|pullback|trade|analyse|position/.test(q)) {
        return true;
      }
    }
  }
  if (q.length < 70) return false;
  let signals = 0;
  if (/j'ai|j'ai|je suis|aujourd'hui|aujourdhui|ce matin/.test(q)) signals++;
  if (/rentré|rentre|entré|entre|position|sl\b|stop loss|zone/.test(q)) signals++;
  if (/clôtur|clos|sorti|fermé|ferme|couper|renvers/.test(q)) signals++;
  if (/fomo|pyscho|psycho|inquiétude|inquietude|peur|stress|tilt|revenge|renvers|frustr/.test(q)) signals++;
  if (/marché|marche|parti|perte|analyse/.test(q)) signals++;
  if (signals < 2) return false;
  if (/qu'en penses|que penses|pense[s-]? tu|ton avis|what do you think|ques[- ]?ce que tu pense|que ton pense/.test(q)) {
    return true;
  }
  return signals >= 3 && q.length > 140;
}

function paychekAiCoachMentionsChecklistTerm(q) {
  return /che?ck\s*list|checklist|checkliste|cheklist|chekliste/.test(q);
}

function paychekAiCoachIsChecklistTradesAuditQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (!paychekAiCoachMentionsChecklistTerm(q)) return false;
  if (!/\btrades?\b|journal/.test(q)) return false;
  if (/audit|bilan|discipline|enregistr|non.?respect|respect|manquant|couverture|combien|taux|pourcent/.test(q)) {
    return true;
  }
  return /peux|possible|tu peux|faire un|faire une/.test(q) && /audit|bilan|analys/.test(q);
}

function paychekAiCoachIsTradeListQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (/pourquoi|why|comment se fait|d'où vient|d'ou vient|what caused/.test(q)) return false;
  if (paychekAiCoachIsCoachingStoryQuestion(question)) return false;
  if (paychekAiCoachIsChecklistTradesAuditQuestion(question)) return false;
  if (paychekAiCoachMentionsChecklistTerm(q)) return false;
  if (/quel(le)?s?\s+trade|quels\s+trades|montre.{0,30}trade|affiche.{0,30}trade|donne.{0,30}trade|voir.{0,30}trade|quels trades.{0,20}(tag|fomo|tilt|revenge|psycho)|(?:^|\s)liste.{0,30}trade/.test(q)) {
    return true;
  }
  if (/\btrade/.test(q) && /fomo|tilt|revenge|peur|fear|frustr|cupidit|greed|stress|overtrade/.test(q)) {
    return /quel|quels|montre|liste|affiche|donne|voir/.test(q);
  }
  return false;
}

function paychekAiCoachIsGeneralPerformanceQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (/checklist|analyse|analysis|plan d.?analyse|strat(é|e)gie|strategy|état mental|etat mental|mental state|fomo|tilt|peur|sommeil|someil|sleep|non.?respect/.test(q)) {
    return false;
  }
  if (/\bquand\b/.test(q) && /winrate|pnl|rendement|diminu|baisse/.test(q) &&
      /moins|plus|faible|bas\b|peu de|someil|sommeil|sleep|focus|peur|stress|fatigue/.test(q)) {
    return false;
  }
  return /dit moi.{0,30}(ma |mon )?performance|(ma|mon)\s+performance|quel.*performance|quelle.*performance|performance\s+(actuelle|globale|générale|generale)|mon\s+(winrate|pnl|rendement)|comment.*performance/.test(q);
}

function paychekAiCoachNormalizeFocus(raw) {
  const f = `${raw ?? ""}`.trim().toLowerCase();
  if (!f) return "";
  const map = {
    analyse: "analysis",
    strategie: "strategy",
    mental_emotion: "mental_emotion",
    non_respect: "non_respect",
    psychology_why: "psychology_why",
  };
  return map[f] || f;
}

function paychekAiCoachIsPricingQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase().trim();
  if (!q) return false;
  if (/prix d.?entr|prix de sortie|entry price|exit price|take profit|stop loss|\btp\b|\bsl\b|lot\b|paire\b|eur\/usd|position\b/.test(q)) {
    return false;
  }
  const pricingIntent = /prix|tarif|tarifs|co[uû]te|combien|pricing|subscription|abonnement|upgrade|formule|paywall|essai|trial|lite|pro\b|premium|gratuit|free plan/.test(q);
  if (!pricingIntent) return false;
  return /app|appli|application|paychek|abonnement|upgrade|formule|essai|trial|lite|pro\b|premium|gratuit|cette appli|this app|the app|l.app|l.appli|souscrire|subscribe|site web|website/.test(q);
}

function paychekAiCoachIsTodayChecklistQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (!/che?ck\s*list|checklist|checkliste|cheklist|chekliste|tâches? du jour|taches? du jour/.test(q)) {
    return false;
  }
  if (/performance|winrate|pnl|bilan|non.?respect|enregistr|audit|combien|sur mes trades|discipline enregistr/.test(q)) {
    return false;
  }
  if (/aujourd'hui|aujourdhui|today|du jour|ce matin|ce soir|this morning|this evening/.test(q)) {
    return true;
  }
  return /dis.?moi|montre|quelle est|quel est|what is|show me|ma checklist|mon checklist|la checklist/.test(q);
}

function paychekAiCoachIsTodayAnalysisQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (!/\banalyse\b|\banalysis\b|plan d.?analyse|mon analyse|ma analyse|my analysis/.test(q)) {
    return false;
  }
  if (/prix d.?entr|prix de sortie|entry price|exit price|take profit|stop loss|\btp\b|\bsl\b|lot\b/.test(q)) {
    return false;
  }
  if (/performance|winrate|pnl|bilan|non.?respect|enregistr|audit|combien|sur mes trades|discipline/.test(q)) {
    return false;
  }
  if (/aujourd'hui|aujourdhui|today|du jour|ce matin|this morning|this evening/.test(q)) {
    return true;
  }
  return /dis.?moi|montre|quelle est|quel est|what is|show me|mon analyse|ma analyse|my analysis|l'analyse/.test(q);
}

function paychekAiCoachIsTodayStrategyQuestion(question) {
  if (paychekAiCoachIsPillarImprovementQuestion(question)) return false;
  const q = paychekAiCoachNormalizeQuestion(question);
  if (!/strat(é|e)gie|strategy|\bsetup\b|mon setup|ma stratégie|ma strategie|my strategy/.test(q)) {
    return false;
  }
  if (/performance|winrate|pnl|bilan|non.?respect|enregistr|audit|combien|sur mes trades|discipline|améliorer|ameliorer|ameliore|solution|conseil|proposes?/.test(q)) {
    return false;
  }
  if (/aujourd'hui|aujourdhui|today|du jour|ce matin|this morning|this evening/.test(q)) {
    return true;
  }
  return /dis.?moi|montre|quelle est ma strat|quel est ma strat|what is my strategy|show me my|mon setup|my setup|la stratégie du jour|la strategie du jour/.test(q);
}

function paychekAiCoachIsMonthCalendarQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (!/calendrier|calendar|objectif|mois|month/.test(q)) return false;
  if (/comment|how to|où |ou |where |configurer|modifier|engrenage|⚙|help/.test(q)) return false;
  if (/aujourd'hui|today|du jour/.test(q) && !/\b(mois|month|objectif|mensuel|monthly)\b/.test(q)) return false;
  if (/performance globale|bilan complet|70 trade|non.?respect|audit discipline|4 pilier/.test(q)) return false;
  return /\b(mois|month|objectif|mensuel|monthly|progression|progres|ce mois|this month)\b/.test(q);
}

function paychekAiCoachIsTodayCalendarQuestion(question) {
  if (paychekAiCoachIsMonthCalendarQuestion(question)) return false;
  const q = `${question ?? ""}`.toLowerCase();
  if (!/calendrier|calendar|ma journée|my day|journée trading/.test(q)) return false;
  if (/état mental|etat mental|mental state|checklist|analyse|analysis|strat(é|e)gie|strategy/.test(q)) return false;
  if (/comment|how to|où |ou |where |configurer|modifier|engrenage|⚙/.test(q)) return false;
  if (/performance globale|bilan complet|70 trade|non.?respect|audit discipline/.test(q)) return false;
  if (/aujourd'hui|aujourdhui|today|du jour|ce matin|this morning|this evening/.test(q)) return true;
  return /dis.?moi|montre|quelle est|quel est|what is|show me|mon calendrier|my calendar/.test(q);
}

function paychekAiCoachIsPerformanceLensQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (/comment|how to|où |ou |where |configurer|modifier|engrenage|⚙/.test(q)) return false;
  return /paychek lens|\blens\b|score discipline|discipline score|trades non renseign|non renseignés|œil|oeil|\beye\b/.test(q);
}

function paychekAiCoachIsPerformanceOvertradingQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (/comment|how to|où |ou |where /.test(q)) return false;
  return /overtrad|over.?trad|trop de trade|trop trade|volume.{0,25}jour|trades?.{0,12}(par|\/| per ) jour|journée.{0,20}volume|journal.{0,15}volume/.test(q);
}

function paychekAiCoachIsFocusedTopicFollowUp(question, priorFocus) {
  const allowed = new Set([
    "performance_overtrading", "performance_lens", "performance_summary",
    "calendar_month", "calendar_today", "strategy_today", "analysis_today",
    "checklist_today", "mental_today", "app_pricing", "coaching_story",
  ]);
  if (!priorFocus || !allowed.has(priorFocus)) return false;
  const q = `${question ?? ""}`.toLowerCase().trim();
  if (q.length > 90) return false;
  return /point (le )?plus important|le plus important|most important|what matters|en résumé|resume|résume|the key|essentiel|conclusion|priorit|qu.?est.?ce qui compte|what should i focus|en bref|in short/.test(q);
}

function paychekAiCoachIsTodayMentalStateQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (!/état mental|etat mental|mental state|mon mental|ma journée mental/.test(q)) return false;
  if (/aujourd'hui|aujourdhui|today|ce matin|ce soir|du jour|this morning|this evening/.test(q)) {
    return true;
  }
  if (/performance|winrate|pnl|bilan|non.?respect|enregistr|audit|combien de trade/.test(q)) {
    return false;
  }
  return /dis.?moi|tu peux me dire|quel est|quelle est|what is my|tell me|comment suis|comment je suis/.test(q);
}

function paychekAiCoachIsConversationalFollowUp(question, lastFocus) {
  if (!lastFocus) return false;
  if (lastFocus === "trade_list" || lastFocus === "app_help" || lastFocus === "app_help_hybrid") {
    return true;
  }
  const q = `${question ?? ""}`.toLowerCase().trim();
  if (!q || q.length > 200) return false;
  if (paychekAiCoachHasExplicitNewTopic(question) && q.length > 80) return false;
  if (paychekAiCoachIsStoryFollowUpQuestion(question)) return false;
  if (paychekAiCoachIsFocusedTopicFollowUp(question, lastFocus)) return false;
  if (/^(et |aussi |oui|non|ok|d.accord|donc|sinon|puis|ensuite|alors |pour |concernant |par contre |du coup )/.test(q)) {
    return true;
  }
  if (/\b(ça|ca|celui|celle|ta réponse|tu as dit|avant|précédent|precedent|comme tu dis)\b/.test(q)) {
    return true;
  }
  return q.length < 95 && /\?/.test(q);
}

function paychekAiCoachHasExplicitNewTopic(question) {
  const q = `${question ?? ""}`.toLowerCase().trim();
  if (q.length > 220) return true;
  if (/quel(le)?s?\s+trade|quels\s+trades|montre.{0,30}trade|liste.{0,30}trade|affiche.{0,30}trade|combien de trade|audit|bilan/.test(q)) {
    return true;
  }
  if (/checklist|analyse|strat(é|e)gie|strategy|état mental|etat mental|mental|fomo|tilt|revenge|performance|winrate|pnl|non.?respect/.test(q) &&
      !/du jour|today|aujourd'hui|aujourdhui/.test(q)) {
    return true;
  }
  if (/comment (faire|utiliser|modifier|ajouter)|où se trouve|help center|mode d.emploi/.test(q)) {
    return true;
  }
  return false;
}

function paychekAiCoachIsPillarReinforcementQuestion(question) {
  const q = paychekAiCoachNormalizeQuestion(question);
  return /quels? points?|quel(le)?s? points?|quelle point|point.{0,35}renforcer|renforcer|renforce|faiblesse|travail.{0,30}renforcer|priorit|what.{0,25}strengthen|what.{0,25}focus on|ou concentrer|sur quoi me concentrer/.test(q);
}

function paychekAiCoachIsPillarImprovementQuestion(question) {
  if (paychekAiCoachIsPillarReinforcementQuestion(question)) return true;
  const q = paychekAiCoachNormalizeQuestion(question);
  if (!q) return false;
  if (/dis.?moi|montre|quelle est|quel est|what is|show me|la stratégie du jour|la strategie du jour|today.?s strategy/.test(q)) {
    return false;
  }
  if (/où\s+(est|se trouve)|where\s+is|comment\s+(modifier|ajouter|créer|creer|configurer|accéder|acceder)/.test(q) &&
      /page|onglet|menu|bouton|engrenage|⚙/.test(q)) {
    return false;
  }
  const hasTopic =
    /strat(é|e)gie|strategy|setup|playbook|checklist|analyse|analysis|plan|état mental|etat mental|mental state|discipline|respect|pilier/.test(q);
  if (!hasTopic) return false;
  return (
    /dit.?moi.{0,30}(astuce|conseil|solution)|\bastuces?\b/.test(q) ||
    /comment\s+(j.?)?\s*(améliorer|ameliorer|ameliore|mieux|travailler|booster|renforcer|optimiser|atteindre|viser|passer|monter|augmenter)/.test(q) ||
    /je\s+veux\s+(améliorer|ameliorer|ameliore|mieux|travailler|booster|renforcer|optimiser)/.test(q) ||
    /j'?aimerais\s+(améliorer|ameliorer|ameliore)/.test(q) ||
    /how\s+(can\s+)?i\s+improve|how\s+to\s+improve|what\s+should\s+i\s+do/.test(q) ||
    /conseils?\s+pour|plan\s+pour|roadmap/.test(q) ||
    /quelle(s)?\s+solution/.test(q) ||
    /(solution|conseil|astuce).{0,35}(améliorer|ameliorer|ameliore|mieux)/.test(q) ||
    /(améliorer|ameliorer|ameliore).{0,35}(solution|conseil|astuce)/.test(q) ||
    /donne[\s-]?moi.{0,40}(solution|conseil|astuce)/.test(q) ||
    /give\s+me.{0,40}(solution|tip|advice)/.test(q) ||
    /(que\s+(me\s+)?|tu\s+(me\s+)?)proposes?/.test(q) ||
    /que\s+faire\s+pour/.test(q) ||
    /aide[\s-]?moi\s+(à|a)\s+(améliorer|ameliorer|ameliore)/.test(q) ||
    /besoin\s+d.?aide\s+(sur|pour).{0,20}(strat|checklist|analyse|mental|discipline)/.test(q)
  );
}

function paychekAiCoachResolveFocus(question, priorFocus) {
  question = paychekAiCoachNormalizeQuestion(question);
  const q = question;
  if (paychekAiCoachIsFocusedTopicFollowUp(question, priorFocus)) return priorFocus;
  if (priorFocus && paychekAiCoachIsConversationalFollowUp(question, priorFocus) &&
      !paychekAiCoachHasExplicitNewTopic(question)) {
    return "conversation_followup";
  }
  if (paychekAiCoachIsPricingQuestion(question)) return "app_pricing";
  if (paychekAiCoachIsPillarImprovementQuestion(question)) return "pillar_improvement";
  if (paychekAiCoachIsTodayChecklistQuestion(question)) return "checklist_today";
  if (paychekAiCoachIsTodayAnalysisQuestion(question)) return "analysis_today";
  if (paychekAiCoachIsTodayStrategyQuestion(question)) return "strategy_today";
  if (paychekAiCoachIsMonthCalendarQuestion(question)) return "calendar_month";
  if (paychekAiCoachIsTodayCalendarQuestion(question)) return "calendar_today";
  if (paychekAiCoachIsPerformanceLensQuestion(question)) return "performance_lens";
  if (paychekAiCoachIsPerformanceOvertradingQuestion(question)) return "performance_overtrading";
  if (paychekAiCoachIsMentalPerformanceQuestion(question)) return "mental_emotion";
  if (paychekAiCoachIsGeneralPerformanceQuestion(question)) return "performance_summary";
  if (paychekAiCoachIsTodayMentalStateQuestion(question)) return "mental_today";
  if (paychekAiCoachShouldUseHelpCenter(question)) return "app_help";
  if (/(combien|nombre|nb|how many).{0,25}trade|trade.{0,25}(combien|nombre|nb|how many)/.test(q)) {
    return "trade_count";
  }
  if (paychekAiCoachIsCoachingStoryQuestion(question)) return "coaching_story";
  if (paychekAiCoachIsChecklistTradesAuditQuestion(question)) return "checklist";
  if (paychekAiCoachIsTradeListQuestion(question)) return "trade_list";
  if (paychekAiCoachIsStoryFollowUpQuestion(question)) return "story_followup";
  if (/(non.?respect|non respect|pas respect|point.{0,20}respect|respect.{0,30}(perte|perd|loss)|(perte|perd|loss).{0,30}respect|violation)/.test(q)) {
    return "non_respect";
  }
  if (paychekAiCoachIsPsychologyWhyQuestion(question)) return "psychology_why";
  if (/checklist/.test(q)) return "checklist";
  if (/analyse|analysis|plan d.?analyse/.test(q)) return "analysis";
  if (/strat(é|e)gie|strategy/.test(q)) return "strategy";
  if (/état mental|etat mental|mental state/.test(q)) return "mental";
  if (/performance|bilan|winrate|pnl|rendement/.test(q)) return "full";
  return "coach";
}


module.exports = {
  paychekNormalizeCoachLocale,
  paychekAiCoachDetectResponseLocale,
  paychekAiCoachNormalizeQuestion,
  paychekAiCoachHelpCenterKnowledge,
  paychekAiCoachShouldUseHelpCenter,
  paychekAiCoachExtractMentalQuery,
  paychekAiCoachIsPsychologyWhyQuestion,
  paychekAiCoachIsMetricPerformanceLinkQuestion,
  paychekAiCoachIsMentalPerformanceQuestion,
  paychekAiCoachIsStoryFollowUpQuestion,
  paychekAiCoachResolveFocusFromContext,
  paychekAiCoachIsCoachingStoryQuestion,
  paychekAiCoachMentionsChecklistTerm,
  paychekAiCoachIsChecklistTradesAuditQuestion,
  paychekAiCoachIsTradeListQuestion,
  paychekAiCoachIsGeneralPerformanceQuestion,
  paychekAiCoachNormalizeFocus,
  paychekAiCoachIsPricingQuestion,
  paychekAiCoachIsTodayChecklistQuestion,
  paychekAiCoachIsTodayAnalysisQuestion,
  paychekAiCoachIsTodayStrategyQuestion,
  paychekAiCoachIsMonthCalendarQuestion,
  paychekAiCoachIsTodayCalendarQuestion,
  paychekAiCoachIsPerformanceLensQuestion,
  paychekAiCoachIsPerformanceOvertradingQuestion,
  paychekAiCoachIsFocusedTopicFollowUp,
  paychekAiCoachIsTodayMentalStateQuestion,
  paychekAiCoachIsConversationalFollowUp,
  paychekAiCoachHasExplicitNewTopic,
  paychekAiCoachIsPillarReinforcementQuestion,
  paychekAiCoachIsPillarImprovementQuestion,
  paychekAiCoachResolveFocus,
};
