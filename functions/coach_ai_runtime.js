/** Appels Gemini + quota + callable Coach IA. */
const intent = require("./coach_ai_intent");
const prompt = require("./coach_ai_prompt");

function createCoachAiCallable(deps) {
  const {onCall, HttpsError, admin, paychekTrialRemainderMsForUid} = deps;
  const {
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
  } = intent;
  const {
    paychekAiCoachNarrativeFormat,
    paychekAiCoachStoryFollowUpFormat,
    paychekAiCoachPricingFormat,
    paychekAiCoachMentalTodayFormat,
    paychekAiCoachChecklistTodayFormat,
    paychekAiCoachAnalysisTodayFormat,
    paychekAiCoachStrategyTodayFormat,
    paychekAiCoachCalendarTodayFormat,
    paychekAiCoachCalendarMonthFormat,
    paychekAiCoachFocusInstructions,
    paychekAiCoachSystemPrompt,
  } = prompt;

  function paychekExtractGeminiText(payload) {
    const candidates = Array.isArray(payload?.candidates) ?
      payload.candidates :
      [];
    for (const c of candidates) {
      const parts = Array.isArray(c?.content?.parts) ? c.content.parts : [];
      const texts = parts
          .map((p) => `${p?.text ?? ""}`.trim())
          .filter(Boolean);
      if (texts.length > 0) return texts.join("\n");
    }
    return "";
  }
  
  function paychekAiCoachLooksTruncated(text, finishReason = "") {
    const t = `${text ?? ""}`.trim();
    const reason = `${finishReason ?? ""}`.trim().toUpperCase();
    if (reason === "MAX_TOKENS") return true;
    if (t.length < 20) return true;
    if (t.length < 80) return false;
    return !/[.!?…。]$/.test(t);
  }
  
  function paychekAiCoachParseContextJson(contextJson) {
    if (!contextJson) return null;
    try {
      return JSON.parse(contextJson);
    } catch (_) {
      return null;
    }
  }
  
  async function paychekAiCoachGenerate({
    endpoint,
    locale,
    question,
    contextJson,
    systemPrompt,
    maxOutputTokens = 1000,
    continuationFrom = "",
  }) {
    const parsedCtx = paychekAiCoachParseContextJson(contextJson);
    const priorTurns = parsedCtx?.conversation?.priorTurns;
    const contents = [];
    if (Array.isArray(priorTurns)) {
      for (const t of priorTurns) {
        const txt = `${t?.text ?? ""}`.trim();
        if (!txt) continue;
        const role = t?.role === "assistant" ? "model" : "user";
        contents.push({role, parts: [{text: txt}]});
      }
    }
    contents.push({
      role: "user",
      parts: [{text: question}],
    });
    if (contextJson) {
      contents.push({
        role: "user",
        parts: [{
          text:
            "CONTEXTE APP PAYCHEK (JSON, peut être partiel):\n" +
            contextJson +
            "\n\nInstruction: si conversation.priorTurns est non vide, lis d'abord le fil — " +
            "la question actuelle est la suite (ne réponds pas comme si c'était le 1er message). " +
            "Puis réponds selon questionFocus du JSON et la question utilisateur. " +
            "Ne répète pas un script fixe. Utilise les champs pertinents au focus.",
        }],
      });
    }
    if (continuationFrom) {
      contents.push({
        role: "user",
        parts: [{
          text:
            "La réponse précédente semble tronquée. Continue exactement où tu t'es arrêté, " +
            "sans répéter le début. Dernière partie reçue:\n" +
            continuationFrom.slice(-500),
        }],
      });
    }
  
    const generationConfig = {
      temperature: 0.35,
      maxOutputTokens,
    };
    if (`${endpoint}`.includes("gemini-2.5")) {
      generationConfig.thinkingConfig = {thinkingBudget: 0};
    }
    const body = {
      system_instruction: {
        parts: [{text: systemPrompt || paychekAiCoachSystemPrompt(locale)}],
      },
      contents,
      generationConfig,
    };
  
    const res = await fetch(endpoint, {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify(body),
    });
    const raw = await res.text();
    let parsed = null;
    try {
      parsed = JSON.parse(raw);
    } catch (_) {
      parsed = null;
    }
    if (!res.ok) {
      const detail = `${parsed?.error?.message ?? raw}`.slice(0, 260);
      throw new HttpsError(
          "internal",
          `AI provider error (${res.status}): ${detail}`,
      );
    }
    return {
      answer: paychekExtractGeminiText(parsed),
      usageMetadata: parsed?.usageMetadata ?? null,
      finishReason: `${parsed?.candidates?.[0]?.finishReason ?? ""}`,
    };
  }
  
  async function paychekReadAiAgentApiKey(db) {
    const snap = await db
        .collection("paychek_app_config")
        .doc("stripe_keys")
        .get();
    if (!snap.exists) return "";
    const d = snap.data() || {};
    return `${d.aiAgentApiKey ?? ""}`.trim();
  }
  
  const PAYCHEK_AI_COACH_USAGE_COLLECTION = "paychek_ai_coach_usage";
  const PAYCHEK_AI_COACH_DAILY_QUOTA_TRIAL = 30;
  const PAYCHEK_AI_COACH_DAILY_QUOTA_PRO = 100;
  
  async function paychekAiCoachResolvePlan(db, uid) {
    const userSnap = await db.collection("paychek_users").doc(uid).get();
    const d = userSnap.exists ? (userSnap.data() || {}) : {};
    const tier = `${d.subscriptionTier || ""}`.trim().toLowerCase();
    const isPro = tier === "pro" || d.isPremium === true;
    if (isPro) return "pro";
    const trialMs = await paychekTrialRemainderMsForUid(db, uid);
    if (trialMs > 0) return "trial";
    return "lite";
  }
  
  function paychekAiCoachQuotaForPlan(plan) {
    if (plan === "pro") return PAYCHEK_AI_COACH_DAILY_QUOTA_PRO;
    return PAYCHEK_AI_COACH_DAILY_QUOTA_TRIAL;
  }
  
  function paychekAiCoachUtcDayKey(now = new Date()) {
    const y = now.getUTCFullYear();
    const m = String(now.getUTCMonth() + 1).padStart(2, "0");
    const d = String(now.getUTCDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
  }
  
  async function paychekAiCoachConsumeQuota(db, uid, plan) {
    const dayKey = paychekAiCoachUtcDayKey();
    const quota = paychekAiCoachQuotaForPlan(plan);
    const ref = db.collection(PAYCHEK_AI_COACH_USAGE_COLLECTION).doc(uid);
  
    const nextUsed = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const data = snap.exists ? (snap.data() || {}) : {};
      const storedDay = `${data.dayKey ?? ""}`.trim();
      const currentUsedRaw = Number(data.used ?? 0);
      const currentUsed = Number.isFinite(currentUsedRaw) ? currentUsedRaw : 0;
      const baseUsed = storedDay === dayKey ? currentUsed : 0;
      if (baseUsed >= quota) {
        throw new HttpsError(
            "resource-exhausted",
            `Quota quotidien AI Coach atteint (${quota}/jour).`,
        );
      }
      const newUsed = baseUsed + 1;
      tx.set(ref, {
        uid,
        plan,
        dayKey,
        used: newUsed,
        quota,
        updatedAt: admin.firestore.Timestamp.now(),
      }, {merge: true});
      return newUsed;
    });
  
    return {used: nextUsed, quota, dayKey};
  }
  
  /**
   * Coach IA (Gemini) — callable sécurisé.
   * Clé API lue côté serveur dans `paychek_app_config/stripe_keys.aiAgentApiKey`.
   */
  const paychekAiCoach = onCall(
      {
        region: "europe-west1",
        timeoutSeconds: 60,
        memory: "256MiB",
      },
      async (request) => {
        if (!request.auth) {
          throw new HttpsError("unauthenticated", "Connexion requise.");
        }
  
        let question = `${request.data?.question ?? ""}`.trim();
        if (!question) {
          throw new HttpsError("invalid-argument", "Question requise.");
        }
        if (question.length > 1600) {
          throw new HttpsError("invalid-argument", "Question trop longue.");
        }
  
        const clientLocale = paychekNormalizeCoachLocale(request.data?.locale);
        question = paychekAiCoachNormalizeQuestion(question);
        const locale = paychekAiCoachDetectResponseLocale(question, clientLocale);
        const modelRaw = `${request.data?.model ?? "gemini-2.5-flash"}`.trim();
        const model = modelRaw.startsWith("gemini-") ? modelRaw : "gemini-2.5-flash";
        const contextData = request.data?.context;
        const contextJson =
          contextData && typeof contextData === "object" ?
            JSON.stringify(contextData).slice(0, 7000) :
            "";
        const clientFocus = paychekAiCoachNormalizeFocus(contextData?.questionFocus);
        const priorFromCtx = paychekAiCoachNormalizeFocus(
            contextData?.conversation?.priorAssistantFocus);
        const contextFollowUp = paychekAiCoachResolveFocusFromContext(contextData, question);
        const focus = clientFocus || contextFollowUp ||
          paychekAiCoachResolveFocus(question, priorFromCtx || "");
        const systemPrompt = paychekAiCoachSystemPrompt(locale, {
          includeHelpCenter: true,
          focus,
        });
  
        const db = admin.firestore();
        const apiKey = await paychekReadAiAgentApiKey(db);
        if (!apiKey) {
          throw new HttpsError(
              "failed-precondition",
              "Clé API Agent AI absente dans la configuration admin.",
          );
        }
  
        let plan = await paychekAiCoachResolvePlan(db, request.auth.uid);
        if (request.auth.token.admin === true) {
          plan = "pro";
        } else if (plan !== "pro" && plan !== "trial") {
          throw new HttpsError(
              "permission-denied",
              "AI Coach est disponible en essai actif ou en plan Pro.",
          );
        }
        const quotaState = await paychekAiCoachConsumeQuota(
            db,
            request.auth.uid,
            plan,
        );
  
        const endpoint =
        `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(apiKey)}`;
  
        const outputCap = focus === "app_help" ? 900 : 2400;
        const first = await paychekAiCoachGenerate({
          endpoint,
          locale,
          question,
          contextJson,
          systemPrompt,
          maxOutputTokens: outputCap,
        });
        let answer = first.answer;
        let usageMetadata = first.usageMetadata;
        let finishReason = first.finishReason;
        let continueCount = 0;
        const maxContinues = focus === "app_help" ? 1 : 6;
        while (
          paychekAiCoachLooksTruncated(answer, finishReason) &&
          continueCount < maxContinues
        ) {
          continueCount += 1;
          const next = await paychekAiCoachGenerate({
            endpoint,
            locale,
            question,
            contextJson,
            systemPrompt,
            maxOutputTokens: 1800,
            continuationFrom: answer,
          });
          if (next.answer.trim().isNotEmpty) {
            answer = `${answer.trimRight()}\n${next.answer.trimLeft()}`;
          } else {
            break;
          }
          usageMetadata = next.usageMetadata ?? usageMetadata;
          finishReason = next.finishReason || finishReason;
        }
        if (paychekAiCoachLooksTruncated(answer, finishReason)) {
          const rewritePrompt = locale === "fr" ?
            `Réécris la réponse complète, adaptée au focus ${focus}, sans template générique, ` +
              "et termine toutes les phrases." :
            `Rewrite the full answer for focus ${focus}, no generic template, ` +
              "and finish all sentences.";
          const compact = await paychekAiCoachGenerate({
            endpoint,
            locale,
            question: rewritePrompt,
            contextJson,
            systemPrompt,
            maxOutputTokens: 1800,
          });
          if (compact.answer.trim().isNotEmpty) {
            answer = compact.answer;
            usageMetadata = compact.usageMetadata ?? usageMetadata;
            finishReason = compact.finishReason || finishReason;
          }
        }
        if (!answer) {
          throw new HttpsError(
              "internal",
              "Réponse IA vide. Réessayez avec une question plus précise.",
          );
        }
  
        return {
          ok: true,
          model,
          locale,
          plan,
          quota: quotaState,
          answer,
          usageMetadata,
        };
      },
  );
  
  /**
   * Callable : après paiement Stripe, l’app demande une synchro (webhook + recherche API).
   */
  
  return {paychekAiCoach};

  return paychekAiCoach;
}

module.exports = {createCoachAiCallable};
