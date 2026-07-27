/**
 * Safeguard licenses (trial + paid Stripe Pro).
 *
 * Trial (licence.html « Activer ») :
 * - Auth required. One trial per Firebase Auth uid.
 * - Trial keys: plan=trial, expiresAt=now+7d, maxActivations=1.
 *
 * Paid Pro (Stripe Payment Link / checkout.session.completed) :
 * - Webhook or claimSafeguardPurchase mints plan=pro, expiresAt=now+1y.
 * - Idempotent per Stripe checkout session id.
 * - Links userId + email; emails the key; licence page prefers Pro over trial.
 *
 * NT / Safeguard desktop client MUST call activateSafeguardLicense with:
 *   { licenseKey|key, machineId|machineFingerprint|machine_fingerprint|hwid,
 *     machineName? , locale? }
 * Email is NOT required. Optional Bearer auth may still bind userId/userEmail.
 */

const crypto = require("crypto");

const COL_LICENSES = "safeguard_licenses";
const COL_REQUESTS = "safeguard_activation_requests";
const COL_TRIAL_CLAIMS = "safeguard_trial_claims";
const COL_TRIAL_MACHINES = "safeguard_trial_machines";
const COL_STRIPE_PURCHASES = "safeguard_stripe_purchases";
const RATE_WINDOW_MS = 60 * 60 * 1000;
const RATE_MAX = 3;
const TRIAL_DAYS = 7;
const TRIAL_MS = TRIAL_DAYS * 24 * 60 * 60 * 1000;
const PRO_DAYS = 365;
const PRO_MS = PRO_DAYS * 24 * 60 * 60 * 1000;
const SAFEGUARD_PAGE_URL = "https://paychek.pro/safeguard.html";
const SAFEGUARD_DOWNLOAD_URL =
  "https://paychek.pro/downloads/PaychekSafeguard-Windows.zip?v=20260727-no-console";

const COPY = {
  en: {
    subjectKey: "Paychek Safeguard — your 7-day trial key",
    subjectPro: "Paychek Safeguard — your 1-year Pro key",
    greeting: (name) => (name ? `Hi ${name},` : "Hi,"),
    bodyKey:
      "Here is your Paychek Safeguard 7-day free trial key for NinjaTrader 8.\n\n" +
      "Key: {{KEY}}\n\n" +
      "Valid until: {{EXPIRES}}\n\n" +
      "Download: {{DOWNLOAD}}\n" +
      "Product page: {{PAGE}}\n\n" +
      "This trial can be activated on one PC only. Enter the key in Safeguard to activate.\n" +
      "If you did not request this email, contact support.",
    bodyPro:
      "Thank you for purchasing Paychek Safeguard Pro for NinjaTrader 8.\n\n" +
      "Key: {{KEY}}\n\n" +
      "Valid until: {{EXPIRES}}\n\n" +
      "Download: {{DOWNLOAD}}\n" +
      "Product page: {{PAGE}}\n\n" +
      "Enter this key in Safeguard to activate (one PC). Your previous trial key is superseded on the licence page.\n" +
      "If you did not make this purchase, contact support.",
    htmlTitleKey: "Safeguard 7-day trial",
    htmlTitlePro: "Safeguard Pro — 1 year",
    htmlKeyLabel: "License key",
    htmlExpiresLabel: "Valid until",
    htmlDownloadLabel: "Download software",
    htmlPageLabel: "Product page",
    alreadyUsed:
      "You have already used your Safeguard free trial on this account.",
    alreadyLicensed:
      "This account already has a Safeguard license.",
    machineRequired:
      "Machine ID required to activate a trial (send machineId or machineFingerprint).",
    machineAlreadyUsedTrial:
      "This PC has already used a Safeguard free trial. Buy Pro or use another computer.",
    purchaseNotFound:
      "No matching Safeguard payment was found for this account.",
    purchaseNotPaid: "This Stripe checkout is not paid yet.",
    purchaseNotYours: "This payment does not belong to your Paychek account.",
    purchaseNotSafeguard: "This checkout is not a Safeguard purchase.",
  },
  fr: {
    subjectKey: "Paychek Safeguard — votre clé d’essai 7 jours",
    subjectPro: "Paychek Safeguard — votre clé Pro 1 an",
    greeting: (name) => (name ? `Bonjour ${name},` : "Bonjour,"),
    bodyKey:
      "Voici votre clé d’essai gratuit Paychek Safeguard (7 jours) pour NinjaTrader 8.\n\n" +
      "Clé : {{KEY}}\n\n" +
      "Valable jusqu’au : {{EXPIRES}}\n\n" +
      "Téléchargement : {{DOWNLOAD}}\n" +
      "Page produit : {{PAGE}}\n\n" +
      "Cet essai ne peut être activé que sur un seul PC. Saisissez la clé dans Safeguard pour activer.\n" +
      "Si vous n’avez pas demandé cet e-mail, contactez le support.",
    bodyPro:
      "Merci pour votre achat Paychek Safeguard Pro pour NinjaTrader 8.\n\n" +
      "Clé : {{KEY}}\n\n" +
      "Valable jusqu’au : {{EXPIRES}}\n\n" +
      "Téléchargement : {{DOWNLOAD}}\n" +
      "Page produit : {{PAGE}}\n\n" +
      "Saisissez cette clé dans Safeguard pour activer (un PC). Votre clé d’essai est remplacée sur la page licence.\n" +
      "Si vous n’êtes pas à l’origine de cet achat, contactez le support.",
    htmlTitleKey: "Essai Safeguard 7 jours",
    htmlTitlePro: "Safeguard Pro — 1 an",
    htmlKeyLabel: "Clé de licence",
    htmlExpiresLabel: "Valable jusqu’au",
    htmlDownloadLabel: "Télécharger le logiciel",
    htmlPageLabel: "Page produit",
    alreadyUsed:
      "Vous avez déjà utilisé l’essai gratuit Safeguard sur ce compte.",
    alreadyLicensed:
      "Ce compte possède déjà une licence Safeguard.",
    machineRequired:
      "Identifiant machine requis pour activer un essai (envoyez machineId ou machineFingerprint).",
    machineAlreadyUsedTrial:
      "Ce PC a déjà utilisé un essai gratuit Safeguard. Passez en Pro ou utilisez un autre ordinateur.",
    purchaseNotFound:
      "Aucun paiement Safeguard correspondant n’a été trouvé pour ce compte.",
    purchaseNotPaid: "Ce checkout Stripe n’est pas encore payé.",
    purchaseNotYours: "Ce paiement n’appartient pas à votre compte Paychek.",
    purchaseNotSafeguard: "Ce checkout n’est pas un achat Safeguard.",
  },
};

function pack(locale) {
  return COPY[locale === "fr" ? "fr" : "en"];
}

function normalizeEmail(raw) {
  return `${raw ?? ""}`.trim().toLowerCase();
}

function isValidEmail(em) {
  return em.includes("@") && em.length <= 320 && !/\s/.test(em);
}

function activationCount(data) {
  const acts = data && data.activations;
  return Array.isArray(acts) ? acts.length : 0;
}

function isTrialLicense(data) {
  if (!data || typeof data !== "object") return false;
  if (data.isTrial === true) return true;
  const plan = `${data.plan || ""}`.trim().toLowerCase();
  const type = `${data.type || ""}`.trim().toLowerCase();
  return plan === "trial" || type === "trial";
}

function pickBestLicense(docs) {
  let best = null;
  let bestMeta = null;
  const now = Date.now();

  function meta(data) {
    const trial = isTrialLicense(data);
    const expMs = expiresAtMs(data);
    const createdRaw = data && data.createdAt;
    let createdMs = 0;
    if (createdRaw && typeof createdRaw.toMillis === "function") {
      createdMs = createdRaw.toMillis();
    } else if (createdRaw instanceof Date) {
      createdMs = createdRaw.getTime();
    }
    const expired = expMs != null && now >= expMs;
    return {
      trial,
      expired,
      expMs: expMs != null ? expMs : (trial ? 0 : Number.MAX_SAFE_INTEGER),
      createdMs,
      acts: activationCount(data),
    };
  }

  function better(am, bm) {
    if (am.trial !== bm.trial) return !am.trial;
    if (am.expired !== bm.expired) return !am.expired;
    if (am.expMs !== bm.expMs) return am.expMs > bm.expMs;
    if (am.createdMs !== bm.createdMs) return am.createdMs > bm.createdMs;
    if (am.acts !== bm.acts) return am.acts > bm.acts;
    return false;
  }

  for (const doc of docs) {
    const d = doc.data() || {};
    if (d.revoked === true) continue;
    const m = meta(d);
    if (!best || better(m, bestMeta)) {
      best = doc;
      bestMeta = m;
    }
  }
  return best;
}

async function queryLicensesBy(db, field, value) {
  if (!value) return [];
  const snap = await db
      .collection(COL_LICENSES)
      .where(field, "==", value)
      .limit(20)
      .get();
  return snap.docs;
}

/**
 * Normalize a Safeguard key to PAYC-XXXX-XXXX-XXXX.
 * Extracts an embedded PAYC… token from noisy pastes ("Key: …", "Clé : …", emails).
 */
function normalizeSafeguardLicenseKey(raw) {
  const text = `${raw ?? ""}`.toUpperCase();
  const embedded = text.match(
      /PAYC[\s\-]*([A-F0-9]{4})[\s\-]*([A-F0-9]{4})[\s\-]*([A-F0-9]{4})/,
  );
  if (embedded) {
    return `PAYC-${embedded[1]}-${embedded[2]}-${embedded[3]}`;
  }
  const cleaned = text.replace(/[^A-Z0-9]/g, "");
  const paycAt = cleaned.indexOf("PAYC");
  let body =
    paycAt >= 0 ? cleaned.slice(paycAt + 4) : cleaned;
  // Keep hex-looking body only (ignore trailing junk after a clean 12).
  const hexBody = (body.match(/^[A-F0-9]+/) || [""])[0];
  body = hexBody || body;
  if (body.length < 12) {
    body = body.padEnd(12, "0");
  } else if (body.length > 12) {
    body = body.slice(0, 12);
  }
  return `PAYC-${body.slice(0, 4)}-${body.slice(4, 8)}-${body.slice(8, 12)}`;
}

function compactSafeguardLicenseKey(key) {
  return `${key ?? ""}`.toUpperCase().replace(/[^A-Z0-9]/g, "");
}

function generateSafeguardLicenseKey() {
  const hex = "0123456789ABCDEF";
  let body = "";
  for (let i = 0; i < 12; i++) {
    body += hex[crypto.randomInt(0, hex.length)];
  }
  return normalizeSafeguardLicenseKey(`PAYC${body}`);
}

/**
 * Resolve a license document by canonical doc id, then by key / keyNormalized fields.
 * Mint uses doc(id)=PAYC-… and field key=same; older/admin rows may differ.
 */
async function resolveLicenseByKey(db, key) {
  const normalized = normalizeSafeguardLicenseKey(key);
  const compact = compactSafeguardLicenseKey(normalized);
  const col = db.collection(COL_LICENSES);

  const primaryRef = col.doc(normalized);
  const primarySnap = await primaryRef.get();
  if (primarySnap.exists) {
    return {ref: primaryRef, id: primarySnap.id, data: primarySnap.data() || {}};
  }

  const queries = [
    col.where("key", "==", normalized).limit(3),
    col.where("keyNormalized", "==", compact).limit(3),
    col.where("key", "==", compact).limit(3),
    // Older admin rows sometimes stored keyPrefix without dashes.
    col.where("keyPrefix", "==", compact).limit(3),
  ];
  for (const q of queries) {
    try {
      const snap = await q.get();
      if (!snap.empty) {
        const doc = snap.docs[0];
        return {ref: doc.ref, id: doc.id, data: doc.data() || {}};
      }
    } catch (err) {
      // Missing composite index should not block primary doc-id lookup.
      console.warn("resolveLicenseByKey query", err && err.message ? err.message : err);
    }
  }

  // Soft scan fallback (small collections / legacy auto-id docs).
  try {
    const scan = await col.limit(500).get();
    for (const doc of scan.docs) {
      const d = doc.data() || {};
      const candidates = [doc.id, d.key, d.keyNormalized, d.keyPrefix, d.licenseKey]
          .filter(Boolean)
          .map((x) => compactSafeguardLicenseKey(normalizeSafeguardLicenseKey(`${x}`)));
      if (candidates.includes(compact)) {
        console.warn("resolveLicenseByKey soft-scan hit", {
          docIdPrefix: `${doc.id}`.slice(0, 9),
          compactLen: compact.length,
        });
        return {ref: doc.ref, id: doc.id, data: d};
      }
    }
  } catch (err) {
    console.warn("resolveLicenseByKey soft-scan", err && err.message ? err.message : err);
  }
  return null;
}

function formatExpiresForEmail(date, locale) {
  try {
    return new Intl.DateTimeFormat(locale === "fr" ? "fr-FR" : "en-GB", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(date);
  } catch (_e) {
    return date.toISOString();
  }
}

function expiresAtMs(data) {
  const raw = data && data.expiresAt;
  if (!raw) return null;
  if (typeof raw.toMillis === "function") return raw.toMillis();
  if (raw instanceof Date) return raw.getTime();
  const n = Number(raw);
  return Number.isFinite(n) && n > 0 ? n : null;
}

function isLicenseExpired(data, nowMs = Date.now()) {
  const ms = expiresAtMs(data);
  return ms != null && nowMs >= ms;
}

/**
 * Resolve HWID from activateSafeguardLicense payload.
 * Canonical: machineId. Aliases match Safeguard desktop local fingerprint fields.
 */
function resolveMachineId(payload) {
  const raw =
    payload?.machineId ||
    payload?.machine_id ||
    payload?.machineFingerprint ||
    payload?.machine_fingerprint ||
    payload?.hwid ||
    payload?.HWID ||
    "";
  return `${raw}`.trim().slice(0, 128);
}

function trialMachineDocId(machineId) {
  return crypto.createHash("sha256").update(machineId, "utf8").digest("hex");
}

function escapeHtmlLocal(s) {
  return `${s ?? ""}`
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
}

function simpleHtml({title, greeting, bodyHtml, footerNote}) {
  return `<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${title}</title></head>
<body style="margin:0;padding:0;background:#050505;color:#e5e5e5;font-family:Arial,Helvetica,sans-serif;">
  <div style="max-width:560px;margin:0 auto;padding:40px 24px;">
    <p style="font-size:11px;letter-spacing:.2em;text-transform:uppercase;color:#c5a059;font-weight:700;margin:0 0 24px;">PAYCHEK</p>
    <h1 style="color:#fff;font-size:22px;margin:0 0 16px;">${title}</h1>
    <p style="color:#9ca3af;font-size:14px;line-height:1.6;margin:0 0 12px;">${greeting}</p>
    <div style="color:#d1d5db;font-size:14px;line-height:1.7;">${bodyHtml}</div>
    ${footerNote ? `<p style="color:#6b7280;font-size:12px;margin-top:32px;line-height:1.5;">${footerNote}</p>` : ""}
    <p style="color:#444;font-size:11px;margin-top:40px;">PAYCHEK LABS</p>
  </div>
</body>
</html>`;
}

function downloadLinksHtml(strings, escapeHtml) {
  return (
    `<div style="margin:18px 0 8px;">` +
    `<a href="${SAFEGUARD_DOWNLOAD_URL}" style="display:inline-block;margin:0 8px 8px 0;padding:10px 16px;background:#C5A059;color:#111;text-decoration:none;border-radius:999px;font-size:12px;font-weight:700;letter-spacing:.04em;text-transform:uppercase;">${escapeHtml(strings.htmlDownloadLabel || "Download")}</a>` +
    `<a href="${SAFEGUARD_PAGE_URL}" style="display:inline-block;margin:0 0 8px 0;padding:10px 16px;background:transparent;color:#e5e5e5;text-decoration:none;border:1px solid rgba(255,255,255,.2);border-radius:999px;font-size:12px;font-weight:700;letter-spacing:.04em;text-transform:uppercase;">${escapeHtml(strings.htmlPageLabel || "Product page")}</a>` +
    `</div>` +
    `<p style="color:#6b7280;font-size:12px;line-height:1.5;margin:0;">` +
    `${escapeHtml(strings.htmlDownloadLabel || "Download")}: ${escapeHtml(SAFEGUARD_DOWNLOAD_URL)}<br>` +
    `${escapeHtml(strings.htmlPageLabel || "Page")}: ${escapeHtml(SAFEGUARD_PAGE_URL)}` +
    `</p>`
  );
}

function applySafeguardMailLinks(text) {
  return `${text ?? ""}`
      .replaceAll("{{DOWNLOAD}}", SAFEGUARD_DOWNLOAD_URL)
      .replaceAll("{{PAGE}}", SAFEGUARD_PAGE_URL);
}

function buildAdminSafeguardMail({
  locale,
  key,
  expiresLabel,
  note,
  name,
  escapeHtml = escapeHtmlLocal,
}) {
  const fr = locale === "fr";
  const greeting = fr ?
    (name ? `Bonjour ${name},` : "Bonjour,") :
    (name ? `Hi ${name},` : "Hi,");
  const subject = fr ?
    "Paychek Safeguard — votre clé d’activation" :
    "Paychek Safeguard — your activation key";
  const title = fr ? "Clé Paychek Safeguard" : "Paychek Safeguard key";
  const intro = fr ?
    "Voici votre clé Paychek Safeguard pour NinjaTrader 8." :
    "Here is your Paychek Safeguard key for NinjaTrader 8.";
  const expiresLine = fr ? "Valable jusqu’au" : "Valid until";
  const noteLabel = fr ? "Note" : "Note";
  const outro = fr ?
    "Téléchargez le logiciel, puis saisissez cette clé dans Safeguard pour activer votre accès." :
    "Download the software, then enter this key in Safeguard to activate your access.";
  const downloadLabel = fr ? "Télécharger le logiciel" : "Download software";
  const pageLabel = fr ? "Page produit" : "Product page";
  const noteHtml = note ?
    `<div style="margin-top:12px;font-size:12px;color:#9ca3af;">${escapeHtml(noteLabel)}: <strong style="color:#e5e5e5;">${escapeHtml(note)}</strong></div>` :
    "";
  const bodyText =
    `${intro}\n\n` +
    `Key: ${key}\n\n` +
    `${expiresLine}: ${expiresLabel}\n\n` +
    (note ? `${noteLabel}: ${note}\n\n` : "") +
    `Download: ${SAFEGUARD_DOWNLOAD_URL}\n` +
    `Product page: ${SAFEGUARD_PAGE_URL}\n\n` +
    `${outro}`;
  const bodyHtml =
    `<p>${escapeHtml(intro)}</p>` +
    `<div style="margin:20px 0;padding:16px 18px;background:#0a0a0a;border:1px solid rgba(255,255,255,0.1);border-radius:12px;">` +
    `<div style="font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:#9ca3af;margin-bottom:8px;">${escapeHtml(fr ? "Clé de licence" : "License key")}</div>` +
    `<div style="font-family:Consolas,Monaco,monospace;font-size:18px;font-weight:700;color:#FBBF24;letter-spacing:.06em;">${escapeHtml(key)}</div>` +
    `<div style="margin-top:12px;font-size:12px;color:#9ca3af;">${escapeHtml(expiresLine)}: <strong style="color:#e5e5e5;">${escapeHtml(expiresLabel)}</strong></div>` +
    noteHtml +
    `</div>` +
    downloadLinksHtml(
        {htmlDownloadLabel: downloadLabel, htmlPageLabel: pageLabel},
        escapeHtml,
    ) +
    `<p style="color:#9ca3af;margin-top:16px;">${escapeHtml(outro)}</p>`;
  return {
    subject,
    text: `${greeting}\n\n${bodyText}\n\n— Paychek`,
    html: simpleHtml({
      title: escapeHtml(title),
      greeting: escapeHtml(greeting),
      bodyHtml,
      footerNote: "",
    }),
  };
}

function checkoutSessionPaid(session) {
  return (
    session &&
    (session.payment_status === "paid" ||
      session.payment_status === "no_payment_required")
  );
}

function checkoutEmailCandidates(session) {
  const seen = new Set();
  const out = [];
  const push = (raw) => {
    const t = normalizeEmail(raw);
    if (!t || seen.has(t)) return;
    seen.add(t);
    out.push(t);
  };
  push(session?.customer_details?.email);
  push(session?.customer_email);
  return out;
}

function metadataLooksLikeSafeguard(meta) {
  if (!meta || typeof meta !== "object") return false;
  const blob = [
    meta.product,
    meta.paychek_product,
    meta.type,
    meta.sku,
    meta.item,
    meta.name,
  ]
      .map((v) => `${v ?? ""}`.toLowerCase())
      .join(" ");
  return blob.includes("safeguard");
}

/**
 * Journal Payment Links are subscriptions; Safeguard is a one-time (~1 year) payment.
 * Also match metadata / line-item product name containing "safeguard".
 *
 * @param {FirebaseFirestore.Firestore} db
 * @param {import("stripe").Stripe} stripe
 * @param {import("stripe").Stripe.Checkout.Session} session
 * @return {Promise<boolean>}
 */
async function isSafeguardCheckoutSession(db, stripe, session) {
  if (!session) return false;
  if (metadataLooksLikeSafeguard(session.metadata)) return true;

  const mode = `${session.mode || ""}`.trim().toLowerCase();
  if (mode === "subscription") return false;

  let lineHit = false;
  try {
    const full = await stripe.checkout.sessions.retrieve(session.id, {
      expand: ["line_items.data.price.product"],
    });
    const items = full.line_items?.data || [];
    for (const item of items) {
      const product = item.price && item.price.product;
      const productName =
        product && typeof product === "object" ? `${product.name || ""}` : "";
      const blob = `${item.description || ""} ${productName}`.toLowerCase();
      if (blob.includes("safeguard")) {
        lineHit = true;
        break;
      }
    }
    if (metadataLooksLikeSafeguard(full.metadata)) return true;
  } catch (e) {
    console.warn("isSafeguardCheckoutSession: expand line_items", e);
  }
  if (lineHit) return true;

  if (mode === "payment") {
    // Prefer matching configured Payment Link when available.
    try {
      const billing = await db.collection("paychek_app_config").doc("billing").get();
      const sgUrl = `${(billing.data() || {}).safeguardPaymentUrl || ""}`.trim();
      const plink =
        typeof session.payment_link === "string" ?
          session.payment_link :
          session.payment_link?.id || "";
      if (plink && sgUrl) {
        try {
          const pl = await stripe.paymentLinks.retrieve(plink);
          const url = `${pl.url || ""}`;
          if (url && (sgUrl.includes(plink) || sgUrl === url ||
            url.replace(/\/$/, "") === sgUrl.replace(/\/$/, ""))) {
            return true;
          }
        } catch (e) {
          console.warn("isSafeguardCheckoutSession: paymentLinks.retrieve", e);
        }
      }
      // Only Safeguard uses a one-time Payment Link in Admin Config.
      if (sgUrl) return true;
    } catch (e) {
      console.warn("isSafeguardCheckoutSession: billing config", e);
    }
    return true;
  }
  return false;
}

/**
 * @param {object} opts
 * @param {FirebaseFirestore.Firestore} opts.db
 * @param {typeof import("firebase-admin")} opts.admin
 * @param {import("stripe").Stripe.Checkout.Session} opts.session
 * @param {string} [opts.uid]
 * @param {string} [opts.deliveryEmail]
 * @param {string} [opts.locale]
 * @param {string} [opts.source]
 * @param {string} [opts.passRaw]
 * @param {Function} opts.sendPaychekMailOutbound
 * @param {Function} opts.paychekSmtpIdentity
 * @param {Function} opts.escapeHtml
 * @param {Function} [opts.outboundErrorMessageForClient]
 * @return {Promise<{ok:boolean,status:string,licenseKey?:string,expiresAt?:string,deliveryEmail?:string,alreadyIssued?:boolean}>}
 */
async function issuePaidSafeguardFromStripe(opts) {
  const {
    db,
    admin,
    session,
    uid: uidIn,
    deliveryEmail: emailIn,
    locale: localeIn,
    source = "stripe_webhook",
    passRaw = "",
    sendPaychekMailOutbound,
    paychekSmtpIdentity,
    escapeHtml,
    outboundErrorMessageForClient,
  } = opts;

  const sessionId = `${session?.id || ""}`.trim();
  if (!sessionId) {
    return {ok: false, status: "missing_session"};
  }
  if (!checkoutSessionPaid(session)) {
    return {ok: false, status: "not_paid"};
  }

  const locale = `${localeIn || "en"}`.trim().toLowerCase() === "fr" ? "fr" : "en";
  const strings = pack(locale);
  const purchaseRef = db.collection(COL_STRIPE_PURCHASES).doc(sessionId);

  const existingPurchase = await purchaseRef.get();
  if (existingPurchase.exists) {
    const prev = existingPurchase.data() || {};
    const key = `${prev.licenseKey || prev.licenseId || ""}`.trim();
    if (key) {
      // Ensure userId link if claim provides uid later.
      const uid = `${uidIn || ""}`.trim();
      if (uid) {
        try {
          const licRef = db.collection(COL_LICENSES).doc(key);
          const licSnap = await licRef.get();
          if (licSnap.exists && !licSnap.data()?.userId) {
            await licRef.set({userId: uid}, {merge: true});
          }
          await purchaseRef.set({userId: uid}, {merge: true});
        } catch (e) {
          console.warn("issuePaidSafeguardFromStripe: relink uid", e);
        }
      }
      const expMs = expiresAtMs(prev) ||
        (prev.expiresAt && typeof prev.expiresAt.toMillis === "function" ?
          prev.expiresAt.toMillis() :
          null);
      return {
        ok: true,
        status: "already_issued",
        alreadyIssued: true,
        licenseKey: key,
        expiresAt: expMs ? new Date(expMs).toISOString() : null,
        deliveryEmail: normalizeEmail(prev.deliveryEmail) || null,
      };
    }
  }

  const emails = checkoutEmailCandidates(session);
  const deliveryEmail = normalizeEmail(emailIn) || emails[0] || "";
  const uid = `${uidIn || ""}`.trim();
  const authEmail = emails[0] || deliveryEmail;

  let firstName = "";
  if (uid) {
    try {
      const uSnap = await db.collection("paychek_users").doc(uid).get();
      const u = uSnap.exists ? uSnap.data() || {} : {};
      firstName = `${u.firstName || ""}`.trim() ||
        `${u.displayName || ""}`.trim().split(/\s+/)[0] || "";
    } catch (_e) {/* ignore */}
  }

  const expiresDate = new Date(Date.now() + PRO_MS);
  const expiresAt = admin.firestore.Timestamp.fromDate(expiresDate);
  let mintedKey = null;

  for (let attempt = 0; attempt < 8; attempt++) {
    const key = generateSafeguardLicenseKey();
    const licenseRef = db.collection(COL_LICENSES).doc(key);
    try {
      await db.runTransaction(async (tx) => {
        const purchaseAgain = await tx.get(purchaseRef);
        if (purchaseAgain.exists) {
          const prev = purchaseAgain.data() || {};
          const existingKey = `${prev.licenseKey || prev.licenseId || ""}`.trim();
          if (existingKey) {
            mintedKey = existingKey;
            return;
          }
        }
        const licSnap = await tx.get(licenseRef);
        if (licSnap.exists) {
          const collision = new Error("KEY_COLLISION");
          collision.code = "KEY_COLLISION";
          throw collision;
        }
        tx.set(licenseRef, {
          key,
          keyNormalized: compactSafeguardLicenseKey(key),
          plan: "pro",
          type: "pro",
          note: "Stripe Safeguard Pro (1 year)",
          maxActivations: 1,
          revoked: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          createdByUid: "system_stripe",
          createdByEmail: "stripe@paychek.pro",
          source: "stripe_purchase",
          stripeCheckoutSessionId: sessionId,
          stripePaymentIntentId:
            typeof session.payment_intent === "string" ?
              session.payment_intent :
              session.payment_intent?.id || null,
          stripeMode: session.mode || "payment",
          stripePaymentLinkId:
            typeof session.payment_link === "string" ?
              session.payment_link :
              session.payment_link?.id || null,
          ...(uid ? {userId: uid} : {}),
          ...(authEmail ? {userEmail: authEmail} : {}),
          ...(deliveryEmail ? {deliveryEmail} : {}),
          expiresAt,
          proDays: PRO_DAYS,
          activations: [],
        });
        tx.set(purchaseRef, {
          sessionId,
          licenseId: key,
          licenseKey: key,
          userId: uid || null,
          userEmail: authEmail || null,
          deliveryEmail: deliveryEmail || null,
          expiresAt,
          amountTotal: session.amount_total ?? null,
          currency: `${session.currency || ""}`.toLowerCase() || null,
          source,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        if (uid) {
          tx.set(
              db.collection("paychek_users").doc(uid),
              {
                safeguardProLicenseId: key,
                safeguardProExpiresAt: expiresAt,
                safeguardProStripeSessionId: sessionId,
                safeguardProDeliveryEmail: deliveryEmail || null,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              {merge: true},
          );
        }
        mintedKey = key;
      });
      if (mintedKey) break;
    } catch (err) {
      if (err && err.code === "KEY_COLLISION") continue;
      console.error("issuePaidSafeguardFromStripe: mint tx", err);
      throw err;
    }
  }

  if (!mintedKey) {
    return {ok: false, status: "mint_failed"};
  }

  // Prefer Pro on licence page: mark active trial licenses as superseded (not revoked).
  if (uid) {
    try {
      const trials = await queryLicensesBy(db, "userId", uid);
      const batch = db.batch();
      let n = 0;
      for (const doc of trials) {
        const d = doc.data() || {};
        if (doc.id === mintedKey) continue;
        if (d.revoked === true) continue;
        if (!isTrialLicense(d)) continue;
        batch.set(
            doc.ref,
            {
              supersededBy: mintedKey,
              supersededAt: admin.firestore.FieldValue.serverTimestamp(),
              supersededReason: "stripe_pro_purchase",
            },
            {merge: true},
        );
        n++;
      }
      if (n > 0) await batch.commit();
    } catch (e) {
      console.warn("issuePaidSafeguardFromStripe: supersede trial", e);
    }
  }

  if (deliveryEmail && isValidEmail(deliveryEmail)) {
    const id = paychekSmtpIdentity();
    const greeting = escapeHtml(strings.greeting(firstName));
    const expiresLabel = formatExpiresForEmail(expiresDate, locale);
    const bodyText = applySafeguardMailLinks(
        strings.bodyPro
            .replace("{{KEY}}", mintedKey)
            .replace("{{EXPIRES}}", expiresLabel),
    );
    const bodyHtml =
      `<p>${escapeHtml(bodyText.split("\n\n")[0])}</p>` +
      `<div style="margin:20px 0;padding:16px 18px;background:#0a0a0a;border:1px solid rgba(255,255,255,0.1);border-radius:12px;">` +
      `<div style="font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:#9ca3af;margin-bottom:8px;">${escapeHtml(strings.htmlKeyLabel)}</div>` +
      `<div style="font-family:Consolas,Monaco,monospace;font-size:18px;font-weight:700;color:#FBBF24;letter-spacing:.06em;">${escapeHtml(mintedKey)}</div>` +
      `<div style="margin-top:12px;font-size:12px;color:#9ca3af;">${escapeHtml(strings.htmlExpiresLabel)}: <strong style="color:#e5e5e5;">${escapeHtml(expiresLabel)}</strong></div>` +
      `</div>` +
      downloadLinksHtml(strings, escapeHtml) +
      `<p style="color:#9ca3af;margin-top:16px;">${escapeHtml(
          bodyText.split("\n\n").slice(-1).join(" ").trim() || "",
      )}</p>`;
    try {
      await sendPaychekMailOutbound(
          {
            from: `"Paychek" <${id.mailFrom}>`,
            to: deliveryEmail,
            bcc: id.mailBcc,
            replyTo: id.mailFrom,
            subject: strings.subjectPro,
            text: `${strings.greeting(firstName)}\n\n${bodyText}\n\n— Paychek`,
            html: simpleHtml({
              title: escapeHtml(strings.htmlTitlePro),
              greeting,
              bodyHtml,
              footerNote: "",
            }),
          },
          passRaw,
          JSON.stringify({
            flow: "safeguardProMint",
            uid: uid || null,
            sessionId,
            licenseId: mintedKey,
          }),
      );
    } catch (err) {
      console.error("issuePaidSafeguardFromStripe: email", err);
      if (outboundErrorMessageForClient) {
        console.warn(
            "issuePaidSafeguardFromStripe: email failed after mint",
            outboundErrorMessageForClient(err),
        );
      }
    }
  }

  try {
    await db.collection(COL_REQUESTS).add({
      userId: uid || null,
      authEmail: authEmail || null,
      deliveryEmail: deliveryEmail || null,
      status: "minted_pro_stripe",
      licenseId: mintedKey,
      licenseKeyFingerprint: crypto
          .createHash("sha256")
          .update(mintedKey)
          .digest("hex")
          .slice(0, 16),
      stripeCheckoutSessionId: sessionId,
      expiresAt,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      source,
      locale,
    });
  } catch (e) {
    console.warn("issuePaidSafeguardFromStripe: request log", e);
  }

  console.log(
      "safeguardStripe: Pro minted",
      mintedKey,
      sessionId,
      uid || "(no uid)",
      deliveryEmail || "(no email)",
  );

  return {
    ok: true,
    status: "minted",
    licenseKey: mintedKey,
    expiresAt: expiresDate.toISOString(),
    deliveryEmail: deliveryEmail || null,
    alreadyIssued: false,
  };
}

/**
 * Find a paid Safeguard checkout for this uid/email when session_id is unknown.
 * @param {import("stripe").Stripe} stripe
 * @param {string} uid
 * @param {string} email
 * @return {Promise<import("stripe").Stripe.Checkout.Session|null>}
 */
async function findRecentSafeguardCheckoutSession(stripe, uid, email) {
  const uidEsc = `${uid || ""}`.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
  if (uidEsc) {
    try {
      const found = await stripe.checkout.sessions.search({
        query: `client_reference_id:'${uidEsc}' AND status:'complete'`,
        limit: 10,
      });
      for (const s of found.data || []) {
        if (!checkoutSessionPaid(s)) continue;
        if (`${s.mode || ""}`.toLowerCase() === "subscription") continue;
        if (`${s.mode || ""}`.toLowerCase() === "payment" ||
          metadataLooksLikeSafeguard(s.metadata)) {
          return s;
        }
      }
    } catch (e) {
      console.warn("findRecentSafeguardCheckoutSession: uid search", e);
    }
  }
  const em = normalizeEmail(email);
  if (em) {
    const emEsc = em.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
    try {
      const found = await stripe.checkout.sessions.search({
        query: `customer_details.email:'${emEsc}' AND status:'complete'`,
        limit: 15,
      });
      for (const s of found.data || []) {
        if (!checkoutSessionPaid(s)) continue;
        if (`${s.mode || ""}`.toLowerCase() === "subscription") continue;
        if (`${s.mode || ""}`.toLowerCase() === "payment" ||
          metadataLooksLikeSafeguard(s.metadata)) {
          return s;
        }
      }
    } catch (e) {
      console.warn("findRecentSafeguardCheckoutSession: email search", e);
    }
  }
  return null;
}

function sessionBelongsToCaller(session, uid, authEmail) {
  const ref = `${session.client_reference_id || ""}`.trim();
  if (uid && ref && ref === uid) return true;
  const emails = checkoutEmailCandidates(session);
  const em = normalizeEmail(authEmail);
  if (em && emails.includes(em)) return true;
  return false;
}

function createSafeguardLicenseExports(deps) {
  const {
    onCall,
    HttpsError,
    admin,
    paychekSmtpPassword,
    paychekStripeSecretKey,
    sendPaychekMailOutbound,
    paychekSmtpIdentity,
    outboundErrorMessageForClient,
    escapeHtml,
  } = deps;

  const requestSafeguardLicenseCode = onCall(
      {
        region: "europe-west1",
        secrets: [paychekSmtpPassword],
        timeoutSeconds: 60,
        memory: "256MiB",
      },
      async (request) => {
        if (!request.auth) {
          throw new HttpsError("unauthenticated", "Connexion requise.");
        }

        const uid = request.auth.uid;
        const authEmail = normalizeEmail(request.auth.token?.email);
        // Delivery address only — claim uniqueness is always uid, never email.
        const requestedEmail = normalizeEmail(
            request.data?.email || authEmail,
        );
        const localeRaw = `${request.data?.locale ?? "en"}`.trim().slice(0, 8).toLowerCase();
        const locale = localeRaw === "fr" ? "fr" : "en";
        const strings = pack(locale);

        if (!isValidEmail(requestedEmail)) {
          throw new HttpsError("invalid-argument", "E-mail invalide.");
        }

        const db = admin.firestore();
        const rateRef = db.collection("safeguard_activation_rate").doc(uid);
        await db.runTransaction(async (tx) => {
          const rateSnap = await tx.get(rateRef);
          const rate = rateSnap.exists ? rateSnap.data() || {} : {};
          const windowStartMs =
            rate.windowStart && typeof rate.windowStart.toMillis === "function" ?
              rate.windowStart.toMillis() :
              0;
          const expired = !windowStartMs ||
            Date.now() - windowStartMs > RATE_WINDOW_MS;
          const count = expired ? 0 : Number(rate.count || 0);
          if (count >= RATE_MAX) {
            throw new HttpsError(
                "resource-exhausted",
                locale === "fr" ?
                  "Trop de demandes. Réessayez dans une heure." :
                  "Too many requests. Try again in an hour.",
            );
          }
          tx.set(
              rateRef,
              {
                count: count + 1,
                windowStart: expired ?
                  admin.firestore.FieldValue.serverTimestamp() :
                  rate.windowStart ||
                    admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              {merge: true},
          );
        });

        // Bind / block by uid only — do not treat email as account identity.
        const byUid = await queryLicensesBy(db, "userId", uid);
        const existingLicense = pickBestLicense(byUid);
        if (existingLicense) {
          throw new HttpsError("already-exists", strings.alreadyLicensed);
        }

        const claimRef = db.collection(COL_TRIAL_CLAIMS).doc(uid);
        const userRef = db.collection("paychek_users").doc(uid);

        let firstName = "";
        try {
          const uSnap = await userRef.get();
          const u = uSnap.exists ? uSnap.data() || {} : {};
          firstName = `${u.firstName || ""}`.trim() ||
            `${u.displayName || ""}`.trim().split(/\s+/)[0] || "";
          if (u.safeguardTrialClaimedAt) {
            throw new HttpsError("already-exists", strings.alreadyUsed);
          }
        } catch (err) {
          if (err instanceof HttpsError) throw err;
          /* ignore profile read failures */
        }

        const claimSnap = await claimRef.get();
        if (claimSnap.exists) {
          throw new HttpsError("already-exists", strings.alreadyUsed);
        }

        const expiresDate = new Date(Date.now() + TRIAL_MS);
        const expiresAt = admin.firestore.Timestamp.fromDate(expiresDate);

        let mintedKey = null;
        let licenseId = null;

        for (let attempt = 0; attempt < 8; attempt++) {
          const key = generateSafeguardLicenseKey();
          const licenseRef = db.collection(COL_LICENSES).doc(key);
          try {
            await db.runTransaction(async (tx) => {
              const claimAgain = await tx.get(claimRef);
              const licSnap = await tx.get(licenseRef);
              if (claimAgain.exists) {
                throw new HttpsError("already-exists", strings.alreadyUsed);
              }
              if (licSnap.exists) {
                const collision = new Error("KEY_COLLISION");
                collision.code = "KEY_COLLISION";
                throw collision;
              }
              tx.set(licenseRef, {
                key,
                keyNormalized: compactSafeguardLicenseKey(key),
                plan: "trial",
                type: "trial",
                note: "Self-serve 7-day free trial",
                maxActivations: 1,
                revoked: false,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                createdByUid: "system_trial",
                createdByEmail: "trial@paychek.pro",
                source: "self_serve_trial",
                userId: uid,
                // Optional contact fields; claim identity remains userId/uid.
                userEmail: authEmail || requestedEmail,
                deliveryEmail: requestedEmail,
                expiresAt,
                trialDays: TRIAL_DAYS,
                activations: [],
              });
              tx.set(claimRef, {
                userId: uid,
                authEmail: authEmail || null,
                deliveryEmail: requestedEmail,
                licenseId: key,
                licenseKey: key,
                expiresAt,
                claimedAt: admin.firestore.FieldValue.serverTimestamp(),
                locale,
                source: "licence_page",
              });
              tx.set(
                  userRef,
                  {
                    safeguardTrialClaimedAt:
                      admin.firestore.FieldValue.serverTimestamp(),
                    safeguardTrialLicenseId: key,
                    safeguardTrialExpiresAt: expiresAt,
                    safeguardTrialDeliveryEmail: requestedEmail,
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                  },
                  {merge: true},
              );
            });
            mintedKey = key;
            licenseId = key;
            break;
          } catch (err) {
            if (err instanceof HttpsError) throw err;
            if (err && err.code === "KEY_COLLISION") continue;
            console.error("requestSafeguardLicenseCode: mint tx", err);
            throw new HttpsError(
                "internal",
                locale === "fr" ?
                  "Impossible de créer la licence d’essai." :
                  "Could not create the trial license.",
            );
          }
        }

        if (!mintedKey || !licenseId) {
          throw new HttpsError(
              "internal",
              locale === "fr" ?
                "Impossible de générer une clé unique." :
                "Could not generate a unique key.",
          );
        }

        const id = paychekSmtpIdentity();
        const passRaw = paychekSmtpPassword.value();
        const greeting = escapeHtml(strings.greeting(firstName));
        const expiresLabel = formatExpiresForEmail(expiresDate, locale);
        const bodyText = applySafeguardMailLinks(
            strings.bodyKey
                .replace("{{KEY}}", mintedKey)
                .replace("{{EXPIRES}}", expiresLabel),
        );

        const bodyHtml =
          `<p>${escapeHtml(bodyText.split("\n\n")[0])}</p>` +
          `<div style="margin:20px 0;padding:16px 18px;background:#0a0a0a;border:1px solid rgba(255,255,255,0.1);border-radius:12px;">` +
          `<div style="font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:#9ca3af;margin-bottom:8px;">${escapeHtml(strings.htmlKeyLabel)}</div>` +
          `<div style="font-family:Consolas,Monaco,monospace;font-size:18px;font-weight:700;color:#FBBF24;letter-spacing:.06em;">${escapeHtml(mintedKey)}</div>` +
          `<div style="margin-top:12px;font-size:12px;color:#9ca3af;">${escapeHtml(strings.htmlExpiresLabel)}: <strong style="color:#e5e5e5;">${escapeHtml(expiresLabel)}</strong></div>` +
          `</div>` +
          downloadLinksHtml(strings, escapeHtml) +
          `<p style="color:#9ca3af;margin-top:16px;">${escapeHtml(
              bodyText
                  .split("\n\n")
                  .slice(-1)
                  .join(" ")
                  .trim() || "",
          )}</p>`;

        try {
          await sendPaychekMailOutbound(
              {
                from: `"Paychek" <${id.mailFrom}>`,
                to: requestedEmail,
                bcc: id.mailBcc,
                replyTo: id.mailFrom,
                subject: strings.subjectKey,
                text: `${strings.greeting(firstName)}\n\n${bodyText}\n\n— Paychek`,
                html: simpleHtml({
                  title: escapeHtml(strings.htmlTitleKey),
                  greeting,
                  bodyHtml,
                  footerNote: "",
                }),
              },
              passRaw,
              JSON.stringify({
                flow: "safeguardTrialMint",
                uid,
                licenseId,
              }),
          );
        } catch (err) {
          console.error("requestSafeguardLicenseCode: send key", err);
          // License already minted — still return code to UI; surface mail error lightly.
          console.warn(
              "requestSafeguardLicenseCode: email failed after mint",
              outboundErrorMessageForClient(err),
          );
        }

        await db.collection(COL_REQUESTS).add({
          userId: uid,
          authEmail,
          deliveryEmail: requestedEmail,
          status: "minted_trial",
          licenseId,
          licenseKeyFingerprint: crypto
              .createHash("sha256")
              .update(mintedKey)
              .digest("hex")
              .slice(0, 16),
          expiresAt,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          source: "licence_page",
          locale,
        });

        return {
          ok: true,
          status: "minted",
          deliveryEmail: requestedEmail,
          licenseKey: mintedKey,
          expiresAt: expiresDate.toISOString(),
          trialDays: TRIAL_DAYS,
          maxActivations: 1,
        };
      },
  );

  /**
   * Bind a Safeguard license to one machine (NinjaTrader / desktop).
   * Enforces revoked, expiresAt, maxActivations, and (for trials only)
   * one free trial per machineId via safeguard_trial_machines.
   */
  const activateSafeguardLicense = onCall(
      {
        region: "europe-west1",
        timeoutSeconds: 30,
        memory: "256MiB",
      },
      async (request) => {
        const rawKey = `${request.data?.licenseKey || request.data?.key || ""}`.trim();
        const machineId = resolveMachineId(request.data);
        const machineName = `${
          request.data?.machineName ||
          request.data?.machine_name ||
          request.data?.hostname ||
          ""
        }`.trim().slice(0, 120);
        const localeRaw = `${request.data?.locale ?? "en"}`.trim().slice(0, 8).toLowerCase();
        const locale = localeRaw === "fr" ? "fr" : "en";
        const strings = pack(locale);

        if (!rawKey) {
          throw new HttpsError(
              "invalid-argument",
              locale === "fr" ? "Clé manquante." : "License key missing.",
          );
        }
        if (!machineId || machineId.length < 4) {
          throw new HttpsError("invalid-argument", strings.machineRequired);
        }

        const key = normalizeSafeguardLicenseKey(rawKey);
        if (!/^PAYC-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}$/.test(key)) {
          throw new HttpsError(
              "invalid-argument",
              locale === "fr" ?
                "Format de clé invalide. Attendu : PAYC-XXXX-XXXX-XXXX." :
                "Invalid license key format. Expected PAYC-XXXX-XXXX-XXXX.",
          );
        }
        const db = admin.firestore();
        const resolved = await resolveLicenseByKey(db, key);
        // Temporary debug — redact full key in logs.
        console.info("activateSafeguardLicense lookup", {
          licenseKeyReceivedLen: rawKey.length,
          licenseKeyReceivedPrefix: rawKey.slice(0, 8),
          normalized: key,
          compact: compactSafeguardLicenseKey(key),
          found: !!resolved,
          machineIdPrefix: machineId.slice(0, 8),
          hasAuth: !!(request.auth && request.auth.uid),
        });
        if (!resolved) {
          throw new HttpsError(
              "not-found",
              locale === "fr" ?
                "Clé introuvable. Copiez le code exact PAYC-XXXX-XXXX-XXXX depuis paychek.pro/licence (sans le texte « Clé : »)." :
                "License key not found. Copy the exact PAYC-XXXX-XXXX-XXXX code from paychek.pro/licence (not the « Key: » label).",
          );
        }
        const licenseRef = resolved.ref;
        // Canonical key from the stored license (doc id or key field).
        const canonicalKey = normalizeSafeguardLicenseKey(
            resolved.data.key || resolved.id || key,
        );
        const trialMachineRef = db
            .collection(COL_TRIAL_MACHINES)
            .doc(trialMachineDocId(machineId));

        const result = await db.runTransaction(async (tx) => {
          const snap = await tx.get(licenseRef);
          if (!snap.exists) {
            throw new HttpsError(
                "not-found",
                locale === "fr" ?
                  "Clé introuvable. Copiez le code exact depuis paychek.pro/licence." :
                  "License key not found. Copy the exact code from paychek.pro/licence.",
            );
          }
          const data = snap.data() || {};
          // Code-only activate: do not require email and do not reject on email mismatch.
          if (data.revoked === true) {
            throw new HttpsError(
                "failed-precondition",
                locale === "fr" ? "Licence révoquée." : "License revoked.",
            );
          }
          if (isLicenseExpired(data)) {
            throw new HttpsError(
                "failed-precondition",
                locale === "fr" ? "Licence expirée." : "License expired.",
            );
          }

          const trial = isTrialLicense(data);
          // Read trial-machine doc only for trials (paid Pro is never blocked by it).
          const trialMachineSnap = trial ? await tx.get(trialMachineRef) : null;
          const trialMachineData =
            trialMachineSnap && trialMachineSnap.exists ?
              trialMachineSnap.data() || {} :
              null;

          const max = Math.max(1, Math.min(5, Number(data.maxActivations) || 1));
          const acts = Array.isArray(data.activations) ?
            data.activations.slice() :
            [];
          const existingIdx = acts.findIndex(
              (a) =>
                a &&
                (`${a.machineId || ""}` === machineId ||
                  `${a.machineFingerprint || ""}` === machineId),
          );
          if (existingIdx >= 0) {
            // Re-bind / idempotent activate: backfill trial-machine record if missing.
            if (trial && !trialMachineData) {
              tx.set(trialMachineRef, {
                machineIdHash: trialMachineDocId(machineId),
                machineIdPrefix: machineId.slice(0, 8),
                uid:
                  (request.auth && request.auth.uid) ||
                  data.userId ||
                  null,
                licenseId: canonicalKey,
                activatedAt: admin.firestore.FieldValue.serverTimestamp(),
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                source: "activate_backfill",
              });
            }
            return {
              ok: true,
              status: "already_active",
              licenseKey: canonicalKey,
              plan: trial ? "trial" : "pro",
              type: trial ? "trial" : "pro",
              maxActivations: max,
              activationCount: acts.length,
              expiresAt: expiresAtMs(data) ?
                new Date(expiresAtMs(data)).toISOString() :
                null,
            };
          }
          if (acts.length >= max) {
            throw new HttpsError(
                "resource-exhausted",
                locale === "fr" ?
                  "Cette licence est déjà activée sur un autre PC (limite atteinte)." :
                  "This license is already activated on another PC (limit reached).",
            );
          }

          if (trial && trialMachineData) {
            const priorLicense = normalizeSafeguardLicenseKey(
                `${trialMachineData.licenseId || ""}`,
            );
            // Any prior trial use on this HWID blocks, unless it is this same key.
            if (priorLicense !== canonicalKey) {
              throw new HttpsError(
                  "failed-precondition",
                  strings.machineAlreadyUsedTrial,
              );
            }
          }

          const entry = {
            machineId,
            machineName: machineName || null,
            activatedAt: admin.firestore.Timestamp.now(),
          };
          if (request.auth && request.auth.uid) {
            entry.activatedByUid = request.auth.uid;
          }
          acts.push(entry);
          const patch = {
            activations: acts,
            lastActivatedAt: admin.firestore.FieldValue.serverTimestamp(),
            lastActivatedMachineId: machineId,
            // Backfill canonical key fields so future lookups stay consistent.
            key: data.key || canonicalKey,
            keyNormalized:
              data.keyNormalized || compactSafeguardLicenseKey(canonicalKey),
          };
          // Link paid keys to the activating account so licence.html finds them by uid.
          if (request.auth && request.auth.uid && !data.userId) {
            patch.userId = request.auth.uid;
          }
          if (
            request.auth &&
            request.auth.token &&
            request.auth.token.email &&
            !data.userEmail
          ) {
            // Optional: bind userEmail only when Bearer auth is present.
            patch.userEmail = `${request.auth.token.email}`.trim().toLowerCase();
          }
          tx.update(licenseRef, patch);

          if (trial) {
            tx.set(
                trialMachineRef,
                {
                  machineIdHash: trialMachineDocId(machineId),
                  machineIdPrefix: machineId.slice(0, 8),
                  uid:
                    (request.auth && request.auth.uid) ||
                    data.userId ||
                    null,
                  licenseId: canonicalKey,
                  activatedAt: admin.firestore.FieldValue.serverTimestamp(),
                  createdAt: trialMachineData ?
                    trialMachineData.createdAt ||
                      admin.firestore.FieldValue.serverTimestamp() :
                    admin.firestore.FieldValue.serverTimestamp(),
                  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                  source: "activate_trial",
                },
                {merge: true},
            );
          }

          return {
            ok: true,
            status: "activated",
            licenseKey: canonicalKey,
            plan: trial ? "trial" : "pro",
            type: trial ? "trial" : "pro",
            maxActivations: max,
            activationCount: acts.length,
            expiresAt: expiresAtMs(data) ?
              new Date(expiresAtMs(data)).toISOString() :
              null,
          };
        });

        return result;
      },
  );

  /**
   * After Stripe Payment Link redirect (or manual re-process): verify session and
   * mint a 1-year Pro Safeguard key linked to the signed-in user.
   * Body: { sessionId?: string, locale?: string }
   * If sessionId omitted, searches recent paid one-time checkouts for this uid/email.
   */
  const claimSafeguardPurchase = onCall(
      {
        region: "europe-west1",
        secrets: [paychekSmtpPassword, paychekStripeSecretKey],
        timeoutSeconds: 60,
        memory: "256MiB",
      },
      async (request) => {
        if (!request.auth) {
          throw new HttpsError("unauthenticated", "Connexion requise.");
        }
        const Stripe = require("stripe");
        const key = `${paychekStripeSecretKey.value()}`.trim();
        if (!key) {
          throw new HttpsError(
              "failed-precondition",
              "Stripe non configuré (secret manquant).",
          );
        }

        const uid = request.auth.uid;
        const authEmail = normalizeEmail(request.auth.token?.email);
        const localeRaw = `${request.data?.locale ?? "en"}`.trim().slice(0, 8).toLowerCase();
        const locale = localeRaw === "fr" ? "fr" : "en";
        const strings = pack(locale);
        const sessionIdIn = `${
          request.data?.sessionId ||
          request.data?.session_id ||
          request.data?.checkoutSessionId ||
          ""
        }`.trim();

        const stripe = new Stripe(key);
        const db = admin.firestore();

        let session = null;
        if (sessionIdIn) {
          try {
            session = await stripe.checkout.sessions.retrieve(sessionIdIn);
          } catch (e) {
            console.warn("claimSafeguardPurchase: retrieve", e);
            throw new HttpsError("not-found", strings.purchaseNotFound);
          }
        } else {
          session = await findRecentSafeguardCheckoutSession(
              stripe,
              uid,
              authEmail,
          );
          if (!session) {
            throw new HttpsError("not-found", strings.purchaseNotFound);
          }
        }

        if (!checkoutSessionPaid(session)) {
          throw new HttpsError("failed-precondition", strings.purchaseNotPaid);
        }
        if (!sessionBelongsToCaller(session, uid, authEmail)) {
          throw new HttpsError("permission-denied", strings.purchaseNotYours);
        }
        const isSg = await isSafeguardCheckoutSession(db, stripe, session);
        if (!isSg) {
          throw new HttpsError(
              "failed-precondition",
              strings.purchaseNotSafeguard,
          );
        }

        try {
          const result = await issuePaidSafeguardFromStripe({
            db,
            admin,
            session,
            uid,
            deliveryEmail: authEmail || checkoutEmailCandidates(session)[0],
            locale,
            source: "claim_callable",
            passRaw: paychekSmtpPassword.value(),
            sendPaychekMailOutbound,
            paychekSmtpIdentity,
            escapeHtml,
            outboundErrorMessageForClient,
          });
          if (!result.ok) {
            throw new HttpsError(
                "internal",
                locale === "fr" ?
                  "Impossible d’émettre la licence Pro." :
                  "Could not issue the Pro license.",
            );
          }
          return result;
        } catch (err) {
          if (err instanceof HttpsError) throw err;
          console.error("claimSafeguardPurchase", err);
          throw new HttpsError(
              "internal",
              locale === "fr" ?
                "Impossible d’émettre la licence Pro." :
                "Could not issue the Pro license.",
          );
        }
      },
  );

  const adminSendSafeguardLicenseEmail = onCall(
      {
        region: "europe-west1",
        secrets: [paychekSmtpPassword],
        timeoutSeconds: 60,
        memory: "256MiB",
      },
      async (request) => {
        if (!request.auth) {
          throw new HttpsError("unauthenticated", "Connexion requise.");
        }
        if (request.auth.token.admin !== true) {
          throw new HttpsError("permission-denied", "Réservé aux administrateurs.");
        }

        const licenseKey = normalizeSafeguardLicenseKey(request.data?.licenseKey || "");
        const rawEmail = normalizeEmail(request.data?.email);
        const note = `${request.data?.note ?? ""}`.trim().slice(0, 240);
        const locale = `${request.data?.locale ?? "fr"}`.trim().toLowerCase() === "en" ?
          "en" :
          "fr";
        if (!isValidEmail(rawEmail)) {
          throw new HttpsError("invalid-argument", "E-mail invalide.");
        }
        if (!/^PAYC-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}$/.test(licenseKey)) {
          throw new HttpsError("invalid-argument", "Clé invalide.");
        }

        const db = admin.firestore();
        const resolved = await resolveLicenseByKey(db, licenseKey);
        if (!resolved) {
          throw new HttpsError("not-found", "Licence introuvable.");
        }
        const data = resolved.data || {};
        const expMs = expiresAtMs(data);
        const expiresDate = expMs ? new Date(expMs) : null;
        const expiresLabel = expiresDate ?
          formatExpiresForEmail(expiresDate, locale) :
          (locale === "fr" ? "Sans expiration" : "No expiry");

        const mail = buildAdminSafeguardMail({
          locale,
          key: licenseKey,
          expiresLabel,
          note,
          name: "",
          escapeHtml,
        });
        const id = paychekSmtpIdentity();

        try {
          await sendPaychekMailOutbound(
              {
                from: `"Paychek" <${id.mailFrom}>`,
                to: rawEmail,
                bcc: id.mailBcc,
                replyTo: id.mailFrom,
                subject: mail.subject,
                text: mail.text,
                html: mail.html,
              },
              paychekSmtpPassword.value(),
              JSON.stringify({
                flow: "adminSafeguardLicenseMail",
                licenseId: resolved.id,
                email: rawEmail,
              }),
          );
        } catch (err) {
          console.error("adminSendSafeguardLicenseEmail", err);
          throw new HttpsError(
              "failed-precondition",
              outboundErrorMessageForClient(err),
          );
        }

        await resolved.ref.set(
            {
              deliveryEmail: rawEmail,
              lastAdminEmailedAt: admin.firestore.FieldValue.serverTimestamp(),
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            {merge: true},
        );

        return {
          ok: true,
          email: rawEmail,
          licenseKey,
        };
      },
  );

  return {
    requestSafeguardLicenseCode,
    activateSafeguardLicense,
    claimSafeguardPurchase,
    adminSendSafeguardLicenseEmail,
  };
}

module.exports = {
  createSafeguardLicenseExports,
  normalizeSafeguardLicenseKey,
  compactSafeguardLicenseKey,
  generateSafeguardLicenseKey,
  resolveLicenseByKey,
  resolveMachineId,
  isTrialLicense,
  trialMachineDocId,
  isSafeguardCheckoutSession,
  issuePaidSafeguardFromStripe,
  findRecentSafeguardCheckoutSession,
  COL_TRIAL_MACHINES,
  COL_STRIPE_PURCHASES,
  TRIAL_DAYS,
  PRO_DAYS,
};
