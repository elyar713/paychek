/**
 * Enrichit les trades « vides » (import CSV / performanceLite) du compte démo
 * web01@paychek.pro pour captures App Store — sans toucher aux autres comptes.
 *
 * PowerShell :
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="C:\chemin\compte-service.json"
 *   cd c:\Users\elyar\mon_app_finder\functions
 *   node scripts\enrich_demo_trades_web01.js              # aperçu
 *   node scripts\enrich_demo_trades_web01.js --apply      # écrit Firestore
 *   node scripts\enrich_demo_trades_web01.js --fix-markets --apply  # paires + marchés
 *
 * Optionnel : node scripts\enrich_demo_trades_web01.js --apply --email autre@paychek.pro
 */

const admin = require("firebase-admin");

const DEFAULT_EMAIL = "web01@paychek.pro";
const JOURNAL_DOC = "journal_trades_v1";

const STRATEGIES = [
  "Breakout with Volume",
  "Pullback to Support",
  "Range Reversal",
  "Head and Shoulders (Pullback)",
  "Trend Continuation",
];

const PSYCH_WIN = ["DISCIPLINE", "PATIENCE", "FOCUS"];
const PSYCH_LOSS = ["FOMO", "TILT", "REVENGE", "IMPATIENCE"];

const NOTES_WIN = [
  "Entrée propre sur retest — plan respecté, sortie au TP1.",
  "Session Londres : breakout validé, gestion du risque OK.",
  "Trade A+ : confluence structure + volume. Rien à ajouter.",
  "Respect du plan d'analyse. Journée disciplinée.",
];

const NOTES_LOSS = [
  "Sortie au SL — entrée un peu tardive après la news.",
  "Erreur de sizing : j'aurais dû réduire avant la session US.",
  "Plan ignoré sur le dernier tiers — leçon pour demain.",
  "Overtrading en fin de session. Pause nécessaire.",
];

const NOTES_BE = [
  "BE serré après extension — capital préservé.",
  "Sortie à l'équilibre, marché indécis en fin de range.",
];

const CHECKLIST_MISS = [
  "analyse:a1",
  "analyse:a2",
  "analyse:a3",
  "risque:r1",
  "risque:r2",
  "psy:p1",
  "news:n1",
];

const PLAN_MISS = ["ctx_phase", "ctx_trend", "struct_support", "smc_ob"];

const ETAT_MISS = ["moment:focus", "moment:risk", "moment:confidence"];

const STRAT_MISS = ["mes_regles_0", "setup_signal", "mes_regles_2"];

function parseArgs(argv) {
  const apply = argv.includes("--apply");
  const fixMarkets = argv.includes("--fix-markets");
  const emailIdx = argv.indexOf("--email");
  const email =
    emailIdx >= 0 && argv[emailIdx + 1]
      ? argv[emailIdx + 1].trim()
      : DEFAULT_EMAIL;
  return {apply, email, fixMarkets};
}

const MAJORS = new Set([
  "USD", "EUR", "GBP", "JPY", "CHF", "AUD", "CAD", "NZD",
  "HKD", "SGD", "SEK", "NOK", "ZAR", "TRY", "MXN", "PLN",
]);

/** CFD / indices (pas les contrats CME NQ·MNQ·ES·MES). */
const INDEX_ROOTS = new Set([
  "NAS100", "US100", "US500", "US30", "US2000", "SP500",
  "NASDAQ", "NDX", "GER40", "DE40", "UK100", "FRA40", "EU50",
  "JPN225", "HK50", "AUS200", "CHINA50", "SWI20", "VIX",
]);

/** Contrats futures échangés (racines CME / micro). */
const FUTURE_ROOTS = [
  "MNQ", "MES", "M2K", "MYM", "MCL", "MGC", "MBT", "MET",
  "NQ", "ES", "YM", "RTY", "CL", "NG", "HG", "GC", "SI", "ZB", "ZN",
];

function isForexSixLetters(compact) {
  if (compact.length !== 6 || !/^[A-Z]+$/.test(compact)) return false;
  return MAJORS.has(compact.slice(0, 3)) && MAJORS.has(compact.slice(3));
}

function isForexSlashed(pair) {
  const slash = pair.indexOf("/");
  if (slash <= 0 || slash >= pair.length - 1) return false;
  const a = pair.slice(0, slash).toUpperCase();
  const b = pair.slice(slash + 1).toUpperCase();
  return /^[A-Z]{3,4}$/.test(a) && /^[A-Z]{3,4}$/.test(b) &&
    MAJORS.has(a) && MAJORS.has(b);
}

/** Affichage journal : EURUSD → EUR/USD, conserve MNQ / NAS100 / etc. */
function normalizeDisplayPair(raw) {
  const trimmed = (raw || "").trim();
  if (!trimmed) return trimmed;

  if (/^or\s*\(\s*xau\s*\)$/i.test(trimmed)) return "XAU/USD";

  const upper = trimmed.toUpperCase();
  if (isForexSlashed(upper)) return upper.replace(/\s/g, "");

  const compact = upper.replace(/[\s._-]/g, "");
  if (isForexSixLetters(compact)) {
    return `${compact.slice(0, 3)}/${compact.slice(3)}`;
  }

  if (compact === "XAUUSD" || compact === "XAUUSDT") return "XAU/USD";

  return trimmed.replace(/\s+/g, " ").trim();
}

function matchesRoot(compact, root) {
  if (!compact.startsWith(root)) return false;
  if (compact === root) return true;
  const rest = compact.slice(root.length);
  return /^[\d._\-!]/.test(rest) || /[FGHJKMNQUVXZ]\d/i.test(rest);
}

/**
 * NAS100 / NASDAQ → indice ; NQ / MNQ / ES / MES → future.
 */
function resolveDemoAssetClass(pair) {
  const display = normalizeDisplayPair(pair);
  const compact = display.replace(/[\s/._-]/g, "").toUpperCase();

  if (/XAU|XAG|GOLD|SILVER|WTI|BRENT|OIL/.test(compact)) {
    return "matieresPremieres";
  }
  if (/BTC|ETH|SOL|XRP|CRYPTO/.test(compact)) {
    return "crypto";
  }

  if (compact.includes("!")) return "future";

  for (const root of FUTURE_ROOTS) {
    if (matchesRoot(compact, root)) return "future";
  }

  for (const root of INDEX_ROOTS) {
    if (matchesRoot(compact, root)) return "indice";
  }

  if (isForexSlashed(display) || isForexSixLetters(compact)) {
    return "forex";
  }

  return "forex";
}

function hashStr(s) {
  let h = 0;
  for (let i = 0; i < s.length; i++) {
    h = (h * 31 + s.charCodeAt(i)) | 0;
  }
  return Math.abs(h);
}

function inferAssetClass(pair) {
  return resolveDemoAssetClass(pair);
}

function defaultPrices(pair, side, gain, seed) {
  const p = (pair || "EURUSD").toUpperCase();
  const isBuy = side !== "vente";
  const mult = isBuy ? 1 : -1;
  const mag = Math.abs(gain || 0);

  if (/XAU|GOLD/.test(p)) {
    const entry = 2150 + (seed % 80);
    const move = Math.max(0.5, Math.min(12, mag / 100 || 3));
    const exit = entry - mult * move;
    return {
      qty: "1",
      entry: entry.toFixed(2),
      exit: exit.toFixed(2),
    };
  }
  if (/BTC/.test(p)) {
    const entry = 95000 + (seed % 5000);
    const move = Math.max(50, Math.min(800, mag * 2 || 200));
    const exit = entry - mult * move;
    return {
      qty: "0.10",
      entry: entry.toFixed(0),
      exit: exit.toFixed(0),
    };
  }
  if (/NAS|US30|US500/.test(p)) {
    const entry = 21000 + (seed % 800);
    const move = Math.max(5, Math.min(120, mag / 5 || 25));
    const exit = entry - mult * move;
    return {
      qty: "1",
      entry: entry.toFixed(0),
      exit: exit.toFixed(0),
    };
  }
  const entry = 1.08 + (seed % 100) / 10000;
  const move = Math.max(0.0003, Math.min(0.004, (mag || 50) / 50000));
  const exit = entry - mult * move;
  return {
    qty: "1",
    entry: entry.toFixed(5),
    exit: exit.toFixed(5),
  };
}

function pick(arr, seed) {
  return arr[seed % arr.length];
}

function pickSome(arr, seed, max) {
  const n = 1 + (seed % max);
  const out = [];
  for (let i = 0; i < n; i++) {
    const v = arr[(seed + i * 7) % arr.length];
    if (!out.includes(v)) out.push(v);
  }
  return out;
}

function disciplinePercents(trade, seed) {
  const gain = trade.gainAmount ?? 0;
  const closed = !!trade.sortieAt;
  const isWin = closed && gain > 0 && !trade.breakeven;
  const isLoss = closed && gain < 0;
  const isBe = trade.breakeven || (closed && gain === 0);

  if (isWin) {
    return {
      checklist: 78 + (seed % 23),
      plan: 72 + (seed % 28),
      strategie: 75 + (seed % 25),
      etat: 68 + (seed % 32),
    };
  }
  if (isLoss) {
    return {
      checklist: 52 + (seed % 28),
      plan: 48 + (seed % 32),
      strategie: 55 + (seed % 30),
      etat: 35 + (seed % 35),
    };
  }
  if (isBe) {
    return {
      checklist: 65 + (seed % 25),
      plan: 60 + (seed % 30),
      strategie: 62 + (seed % 28),
      etat: 58 + (seed % 32),
    };
  }
  // position ouverte
  return {
    checklist: 70 + (seed % 30),
    plan: 65 + (seed % 35),
    strategie: 68 + (seed % 32),
    etat: 60 + (seed % 40),
  };
}

function isTradeIncomplete(t) {
  if (t.performanceLite === true) return true;

  const cl = Number(t.checklistPct) || 0;
  const pl = Number(t.planPct) || 0;
  const st = Number(t.strategiePct) || 0;
  const et = Number(t.etatPct) || 0;
  const noDiscipline = cl === 0 && pl === 0 && st === 0 && et === 0;

  if (noDiscipline && !t.strategieLinkedExplicit) return true;
  if (!(t.strategieTitle || "").trim()) return true;
  if (!t.mindsetExplicit && noDiscipline) return true;
  if (t.sortieAt && (!t.prixEntreeLabel || !t.prixSortieLabel)) return true;
  if (!t.quantiteLabel) return true;
  if (!t.userNote || !String(t.userNote).trim()) return true;

  return false;
}

function enrichTrade(trade, index) {
  const seed = hashStr(`${trade.id}:${index}`);
  const gain = Number(trade.gainAmount) || 0;
  const closed = !!trade.sortieAt;
  const isLoss = closed && gain < 0;
  const isBe = trade.breakeven || (closed && gain === 0);
  const pct = disciplinePercents(trade, seed);

  const prices = defaultPrices(
    trade.pair,
    trade.side,
    gain,
    seed,
  );

  const mindset =
    isLoss && seed % 4 === 0 ? "feeling" : "principe";

  let note;
  if (isBe) note = pick(NOTES_BE, seed);
  else if (isLoss) note = pick(NOTES_LOSS, seed);
  else note = pick(NOTES_WIN, seed);

  const psychPool = isLoss ? PSYCH_LOSS : PSYCH_WIN;
  const psychTags =
    isLoss && seed % 3 !== 0 ? [pick(psychPool, seed)] : [];

  const clMiss =
    pct.checklist < 85 ? pickSome(CHECKLIST_MISS, seed, 2) : [];
  const plMiss = pct.plan < 80 ? pickSome(PLAN_MISS, seed + 1, 2) : [];
  const etMiss = pct.etat < 70 ? pickSome(ETAT_MISS, seed + 2, 2) : [];
  const stMiss =
    pct.strategie < 80 ? pickSome(STRAT_MISS, seed + 3, 1) : [];

  const commission =
    Number(trade.commissionAmount) > 0
      ? trade.commissionAmount
      : 2 + (seed % 7);

  const syncRev = Date.now() + index;

  return {
    ...trade,
    performanceLite: false,
    mindset,
    mindsetExplicit: true,
    strategieLinkedExplicit: true,
    checklistLinkedExplicit: pct.checklist > 0,
    planLinkedExplicit: pct.plan > 0,
    etatLinkedExplicit: pct.etat > 0,
    strategieTitle: pick(STRATEGIES, seed),
    checklistPct: pct.checklist,
    planPct: pct.plan,
    strategiePct: pct.strategie,
    etatPct: pct.etat,
    quantiteLabel: trade.quantiteLabel || prices.qty,
    prixEntreeLabel: trade.prixEntreeLabel || prices.entry,
    prixSortieLabel: trade.sortieAt
      ? trade.prixSortieLabel || prices.exit
      : trade.prixSortieLabel ?? null,
    commissionAmount: commission,
    pair: normalizeDisplayPair(trade.pair),
    assetClass: resolveDemoAssetClass(trade.pair),
    psychTags: (trade.psychTags && trade.psychTags.length)
      ? trade.psychTags
      : psychTags,
    userNote: (trade.userNote && String(trade.userNote).trim())
      ? trade.userNote
      : note,
    checklistNonRespectIds: clMiss,
    planNonRespectIds: plMiss,
    etatNonRespectIds: etMiss,
    strategieNonRespectIds: stMiss,
    syncRev,
  };
}

function fixTradeMarkets(trade, index) {
  const pair = normalizeDisplayPair(trade.pair);
  const assetClass = resolveDemoAssetClass(trade.pair);
  const changed = pair !== trade.pair || assetClass !== trade.assetClass;
  if (!changed) return {trade, changed: false};
  return {
    trade: {
      ...trade,
      pair,
      assetClass,
      syncRev: Date.now() + index,
    },
    changed: true,
  };
}

function stripForFirestore(trade) {
  const m = {...trade};
  delete m.screenshotBytesB64;
  delete m.linkedAnalysePdfBytesB64;
  return m;
}

async function resolveUid(email) {
  try {
    const u = await admin.auth().getUserByEmail(email);
    return u.uid;
  } catch (e) {
    const db = admin.firestore();
    const q = await db
      .collection("paychek_users")
      .where("email", "==", email)
      .limit(1)
      .get();
    if (!q.empty) return q.docs[0].id;
    throw new Error(`Utilisateur introuvable pour ${email}: ${e.message}`);
  }
}

async function main() {
  const {apply, email, fixMarkets} = parseArgs(process.argv.slice(2));

  if (
    !process.env.GOOGLE_APPLICATION_CREDENTIALS ||
    `${process.env.GOOGLE_APPLICATION_CREDENTIALS}`.trim() === ""
  ) {
    console.error(
      "GOOGLE_APPLICATION_CREDENTIALS manquant (JSON compte de service Firebase).",
    );
    process.exit(1);
  }

  admin.initializeApp();
  const db = admin.firestore();

  const uid = await resolveUid(email);
  console.log(`Compte cible : ${email}`);
  console.log(`UID          : ${uid}`);
  const modeLabel = fixMarkets
    ? (apply ? "FIX-MARKETS APPLY" : "FIX-MARKETS dry-run")
    : (apply ? "APPLY (écriture)" : "DRY-RUN (aperçu)");
  console.log(`Mode         : ${modeLabel}`);
  console.log("");

  const ref = db
    .collection("paychek_users")
    .doc(uid)
    .collection("sync_data")
    .doc(JOURNAL_DOC);

  const snap = await ref.get();
  if (!snap.exists) {
    console.error("Aucun journal Firestore (journal_trades_v1).");
    process.exit(1);
  }

  const data = snap.data() || {};
  const items = Array.isArray(data.items) ? data.items : [];
  console.log(`Trades totaux : ${items.length}`);

  let nextItems;
  let changeCount = 0;

  if (fixMarkets) {
    nextItems = items.map((t, i) => {
      const {trade, changed} = fixTradeMarkets(t, i);
      if (changed) changeCount++;
      return trade;
    });
    console.log(`Corrections paire/classe : ${changeCount} / ${items.length}`);
    const byClass = {};
    for (const t of nextItems) {
      byClass[t.assetClass || "?"] = (byClass[t.assetClass || "?"] || 0) + 1;
    }
    console.log("Répartition marchés :", byClass);
    const pairs = [...new Set(nextItems.map((t) => t.pair))].sort();
    console.log("Paires uniques :", pairs.join(", "));
    console.log("");
    if (changeCount === 0) {
      console.log("Rien à corriger — paires et marchés déjà OK.");
      return;
    }
  } else {
    let incomplete = 0;
    let enriched = 0;
    nextItems = items.map((t, i) => {
      if (!isTradeIncomplete(t)) return t;
      incomplete++;
      enriched++;
      return enrichTrade(t, i);
    });
    changeCount = enriched;

    console.log(`Incomplets    : ${incomplete}`);
    console.log(`À enrichir    : ${enriched}`);
    console.log(`Déjà complets : ${items.length - incomplete}`);
    console.log("");

    if (enriched === 0) {
      console.log("Rien à modifier — tous les trades sont déjà détaillés.");
      return;
    }

    const samples = nextItems
      .filter((t, i) => isTradeIncomplete(items[i]))
      .slice(0, 5);
    console.log("Exemples (après enrichissement) :");
    for (const s of samples) {
      console.log(
        `  • ${s.pair} [${s.assetClass}] ${s.side} ${s.amountLabel} | CL ${s.checklistPct}%`,
      );
    }
    console.log("");
  }

  if (!apply) {
    console.log(
      "Dry-run terminé. Relance avec --apply pour écrire dans Firestore.",
    );
    console.log(
      "Après écriture : reconnecte web01@paychek.pro (ou tire-toi l’app) pour resync.",
    );
    return;
  }

  const cloudMaps = nextItems.map(stripForFirestore);
  await ref.set({
    v: data.v ?? 1,
    items: cloudMaps,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    enrichedForAppStoreDemoAt: admin.firestore.FieldValue.serverTimestamp(),
    enrichedBy: "scripts/enrich_demo_trades_web01.js",
  });

  console.log("OK — journal mis à jour dans Firestore.");
  console.log(
    "Ouvre l’app avec web01@paychek.pro pour resynchroniser les trades enrichis.",
  );
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
