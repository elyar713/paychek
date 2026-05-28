/**
 * Callable sendStaffSupportEmail: Resend HTTP first if key set; else or on failure, SMTP (Nodemailer).
 * Trigger notifyStaffOnSupportTicketCreated: staff + user ack emails.
 *
 * Primary: PAYCHEK_RESEND_API_KEY + verified domain on resend.com for PAYCHEK_MAIL_FROM.
 * Fallback: PAYCHEK_SMTP_HOST, PORT, SECURE, USER + secret PAYCHEK_SMTP_PASSWORD.
 *
 * Deploy:
 *   firebase deploy --only functions:sendStaffSupportEmail,functions:notifyStaffOnSupportTicketCreated,
 *                      functions:paychekWelcomeEmailOnSignup,
 *                      functions:managePaychekStaffAdmin,functions:paychekStripeWebhook,
 *                      functions:syncPaychekStripeEntitlement,
 *                      functions:adminSyncPaychekStripeEntitlement,
 *                      functions:adminNotifyUserRefundEmail
 *
 * Webhook `checkout.session.completed` : active Pro + envoie l’e-mail « Accès Pro confirmé » (Resend ou SMTP).
 */

/** À synchroniser avec [lib/admin/admin_superadmin_gate.dart]. */
const PAYCHEK_SUPERADMIN_EMAILS = ["elyar713@gmail.com"];

function normalizedRequestEmail(token) {
  return `${token?.email ?? ""}`.trim().toLowerCase();
}

function callerIsPaychekSuperadmin(request) {
  if (!request.auth) return false;
  if (request.auth.token.superadmin === true) return true;
  const em = normalizedRequestEmail(request.auth.token);
  return PAYCHEK_SUPERADMIN_EMAILS.includes(em);
}

const {onCall, onRequest, HttpsError} = require("firebase-functions/v2/https");
const {onDocumentCreated, onDocumentWritten} =
  require("firebase-functions/v2/firestore");
const {defineSecret, defineString} = require("firebase-functions/params");
const express = require("express");
const nodemailer = require("nodemailer");
const admin = require("firebase-admin");

admin.initializeApp();
const Stripe = require("stripe");
const emailI18n = require("./email_i18n");

const paychekSmtpPassword = defineSecret("PAYCHEK_SMTP_PASSWORD");

const paychekSmtpHost = defineString("PAYCHEK_SMTP_HOST", {
  default: "",
  description: "Hôte SMTP sortant (vide si envoi uniquement via Resend)",
});
const paychekSmtpPort = defineString("PAYCHEK_SMTP_PORT", {
  default: "587",
});
const paychekSmtpSecure = defineString("PAYCHEK_SMTP_SECURE", {
  default: "false",
  description: "true = SSL implicite (ex. port 465) ; false = STARTTLS (ex. 587)",
});
const paychekSmtpUser = defineString("PAYCHEK_SMTP_USER", {
  default: "",
  description: "Identifiant SMTP (souvent l’e-mail du compte chez le fournisseur)",
});
const paychekMailFrom = defineString("PAYCHEK_MAIL_FROM", {
  default: "contact@paychek.pro",
});
const paychekMailBcc = defineString("PAYCHEK_MAIL_BCC", {
  default: "contact@paychek.pro",
});

/**
 * Resend API key (tried first when set). See https://resend.com
 */
const paychekResendApiKey = defineString("PAYCHEK_RESEND_API_KEY", {
  default: "",
  description: "Resend API key (primary); SMTP used if Resend fails or key empty",
});

/** Secret key Stripe (sk_live_… / sk_test_) — utilisé pour vérifier les webhooks. */
const paychekStripeSecretKey = defineSecret("PAYCHEK_STRIPE_SECRET_KEY");
/** Signing secret du endpoint Webhook (whsec_…). */
const paychekStripeWebhookSecret = defineSecret("PAYCHEK_STRIPE_WEBHOOK_SECRET");

const COMPANY_NAME = "Paychek";
/** Lien Base de connaissances dans l’e-mail automatique — à ajuster selon votre site réel. */
const KNOWLEDGE_BASE_URL_FR = "https://paychek.pro/";
/** Politique de confidentialité (site web). */
const PAYCHEK_PRIVACY_PAGE_URL_FR = "https://paychek.pro/privacy.html";

/** Jours Pro affichés dans l’e-mail de bienvenue (cohérent avec l’essai post-inscription). */
const PAYCHEK_WELCOME_TRIAL_DAYS = 7;

/** Identité / transport : lire les paramètres au moment de l’envoi (pas au chargement du module). */
function paychekSmtpIdentity() {
  const host = paychekSmtpHost.value().trim();
  const user = paychekSmtpUser.value().trim();
  const mailFrom = paychekMailFrom.value().trim() || user;
  const mailBcc = paychekMailBcc.value().trim() || mailFrom;
  const port = parseInt(`${paychekSmtpPort.value()}`.trim(), 10);
  const portSafe = Number.isFinite(port) && port > 0 ? port : 587;
  const secureFlag = `${paychekSmtpSecure.value()}`.trim().toLowerCase() === "true";
  const secure = secureFlag || portSafe === 465;
  return {host, user, mailFrom, mailBcc, port: portSafe, secure};
}

function normalizeSmtpPassword(raw) {
  if (typeof raw !== "string") return "";
  return raw.replace(/^\uFEFF/, "").trim();
}

function isSmtpAuthFailure(err) {
  if (!err || typeof err !== "object") return false;
  const code = typeof err.code === "string" ? err.code : "";
  if (code === "EAUTH") return true;
  const rc = err.responseCode;
  if (typeof rc === "number" && (rc === 535 || rc === 534)) return true;
  const resp = `${err.response || ""}`;
  if (/535|authentication failed|invalid credentials|5\.7\.8/i.test(resp)) {
    return true;
  }
  return false;
}

/**
 * Texte renvoyé au client (callable) pour les échecs SMTP courants.
 */
function smtpErrorMessageForClient(err) {
  if (isSmtpAuthFailure(err)) {
    return (
      "SMTP refuse l’authentification. Vérifier PAYCHEK_SMTP_USER, secret PAYCHEK_SMTP_PASSWORD, " +
      "et les paramètres PAYCHEK_SMTP_HOST / PAYCHEK_SMTP_PORT / PAYCHEK_SMTP_SECURE (console Firebase), " +
      "puis redeploy."
    );
  }
  const rc = typeof err.responseCode === "number" ? err.responseCode : 0;
  const blob = `${err.response || ""} ${err.message || err}`.toLowerCase();
  if (rc === 550 && /too many sending failures|5\.2\.0/.test(blob)) {
    return (
      "Le serveur SMTP limite ou bloque l’envoi (« trop d’échecs »). " +
      "Vérifier le fournisseur, les destinataires (replyEmail), ou configurer PAYCHEK_RESEND_API_KEY. " +
      "La réponse est bien enregistrée dans l’application."
    );
  }
  if (rc === 554 || /spam|blacklist|blocked|policy rejection/.test(blob)) {
    return (
      "Le serveur refuse le message (anti-spam / politique). Vérifier SPF/DKIM du domaine d'expédition " +
      "ou tester avec une autre adresse destinataire."
    );
  }
  const rcStr = rc ? ` [${rc}]` : "";
  return (
    "Échec envoi SMTP" +
    rcStr +
    ". " +
    String(err.response || err.message || err).slice(0, 200)
  );
}

/** Message callable : Resend (sans responseCode SMTP) ou SMTP. */
function outboundErrorMessageForClient(err) {
  const m = `${err && err.message ? err.message : err}`;
  if (/^Resend:|Resend HTTP/i.test(m)) {
    return (
      m.slice(0, 260) +
      (m.length > 260 ? "…" : "") +
      " — Vérifier PAYCHEK_RESEND_API_KEY et le domaine sur resend.com."
    );
  }
  return smtpErrorMessageForClient(err);
}

/** Erreurs où un second essai (autre mode TLS / port) peut aider depuis le réseau GCP. */
function isSmtpProbablyNetworkOrTls(err) {
  if (!err || typeof err !== "object") return false;
  if (isSmtpAuthFailure(err)) return false;
  const code = typeof err.code === "string" ? err.code : "";
  if (
    ["ETIMEDOUT", "ECONNRESET", "ECONNREFUSED", "ENOTFOUND", "EPIPE", "ESOCKET"]
      .includes(code)
  ) {
    return true;
  }
  const msg = `${err.message || err}`.toLowerCase();
  if (msg.includes("timeout") || msg.includes("timed out")) return true;
  if (msg.includes("greeting") && msg.includes("timeout")) return true;
  if (msg.includes("ssl") && msg.includes("wrong version")) return true;
  return false;
}

/**
 * Premier essai avec les paramètres PAYCHEK_SMTP_* ; en cas d’échec « réseau/TLS »,
 * second essai sur l’autre couple 465 SSL implicite ↔ 587 STARTTLS (même hôte).
 */
async function sendPaychekMailWithOptionalFallback(mailOptions, pass, logCtx) {
  const id = paychekSmtpIdentity();
  if (!id.host || !id.user) {
    throw new Error("PAYCHEK_SMTP_HOST / PAYCHEK_SMTP_USER manquants.");
  }
  const auth = {user: id.user, pass};
  const tls = {minVersion: "TLSv1.2"};
  const common = {
    host: id.host,
    auth,
    connectionTimeout: 60_000,
    greetingTimeout: 30_000,
    socketTimeout: 120_000,
    tls,
  };
  const primary = {
    port: id.port,
    secure: id.secure,
  };
  const fallback =
    id.port === 465 && id.secure ?
      {port: 587, secure: false} :
      {port: 465, secure: true};
  const profiles = [
    {
      name: `${primary.port}+secure=${primary.secure}`,
      transportOpts: {
        ...common,
        port: primary.port,
        secure: primary.secure,
        ...(primary.secure ? {} : {requireTLS: true}),
      },
    },
    {
      name: `${fallback.port}+secure=${fallback.secure}`,
      transportOpts: {
        ...common,
        port: fallback.port,
        secure: fallback.secure,
        ...(fallback.secure ? {} : {requireTLS: true}),
      },
    },
  ];

  let lastErr;
  for (let i = 0; i < profiles.length; i++) {
    const {name, transportOpts} = profiles[i];
    const transport = nodemailer.createTransport(transportOpts);
    try {
      await transport.sendMail(mailOptions);
      if (i > 0) {
        console.warn("sendPaychekMail: succès après repli", name, logCtx || "");
      } else {
        console.log("sendPaychekMail: ok", name, logCtx || "");
      }
      return;
    } catch (err) {
      lastErr = err;
      console.error("sendPaychekMail: échec", name, logCtx || "", err);
    } finally {
      try {
        transport.close();
      } catch (_) {
        /* ignore */
      }
    }
    if (i === 0 && !isSmtpProbablyNetworkOrTls(lastErr)) break;
  }
  throw lastErr;
}

/** Découpe une liste d’adresses pour l’API Resend (chaîne ou tableau Nodemailer). */
function paychekNormalizeRecipientList(raw) {
  if (raw == null) return [];
  if (Array.isArray(raw)) {
    return raw
        .map((x) => `${x ?? ""}`.trim())
        .filter((s) => s.includes("@"));
  }
  const s = `${raw}`.trim();
  if (!s) return [];
  return s
      .split(/[,;]/)
      .map((p) => p.trim())
      .filter((p) => p.includes("@"));
}

/**
 * Envoi via API Resend (HTTPS). `from` doit correspondre à un domaine / sender vérifié Resend.
 * @returns {Promise<void>}
 */
async function sendPaychekMailViaResend(apiKey, mailOptions, logCtx) {
  const to = paychekNormalizeRecipientList(mailOptions.to);
  if (to.length === 0) {
    throw new Error("Resend: destinataire « to » manquant.");
  }
  const bcc = paychekNormalizeRecipientList(mailOptions.bcc);
  const from = `${mailOptions.from ?? ""}`.trim();
  const subject = `${mailOptions.subject ?? ""}`.trim();
  const html = typeof mailOptions.html === "string" ? mailOptions.html : "";
  const text = typeof mailOptions.text === "string" ? mailOptions.text : "";
  if (!from || !subject || (!html && !text)) {
    throw new Error("Resend: from, subject ou corps manquant.");
  }

  const body = {
    from,
    to,
    subject,
    ...(html ? {html} : {}),
    ...(text ? {text} : {}),
    ...(bcc.length > 0 ? {bcc} : {}),
  };
  const rt = mailOptions.replyTo;
  if (typeof rt === "string" && rt.trim().includes("@")) {
    body.reply_to = rt.trim();
  }

  const atts = Array.isArray(mailOptions.attachments) ?
    mailOptions.attachments :
    [];
  if (atts.length > 0) {
    body.attachments = atts.map((a) => {
      const fn = `${a.filename ?? "piece-jointe"}`.trim() || "piece-jointe";
      let buf = a.content;
      if (!Buffer.isBuffer(buf) && buf instanceof Uint8Array) {
        buf = Buffer.from(buf);
      }
      if (!Buffer.isBuffer(buf)) {
        throw new Error(`Resend: pièce jointe non buffer (${fn}).`);
      }
      return {
        filename: fn,
        content: buf.toString("base64"),
        ...(a.contentType ? {content_type: `${a.contentType}`.trim()} : {}),
      };
    });
  }

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey.trim()}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  const rawText = await res.text();
  let parsed;
  try {
    parsed = JSON.parse(rawText);
  } catch (_) {
    parsed = null;
  }
  if (!res.ok) {
    const detail =
      parsed && typeof parsed.message === "string" ?
        parsed.message :
        rawText.slice(0, 400);
    throw new Error(`Resend HTTP ${res.status}: ${detail}`);
  }
  console.log("sendPaychekMailViaResend: ok", logCtx || "", parsed?.id || "");
}

/**
 * Outbound mail: Resend first when PAYCHEK_RESEND_API_KEY set; else or on failure, SMTP.
 */
async function sendPaychekMailOutbound(mailOptions, passRaw, logCtx) {
  const pass = normalizeSmtpPassword(passRaw);
  const resendKey = `${paychekResendApiKey.value()}`.trim();
  const id = paychekSmtpIdentity();
  const smtpReady = Boolean(id.host && id.user && pass);

  if (resendKey) {
    try {
      await sendPaychekMailViaResend(resendKey, mailOptions, logCtx);
      return; // Sortir après l'envoi réussi via Resend
    } catch (resendErr) {
      console.warn("sendPaychekMail: Resend failed", logCtx || "", resendErr);
      if (!smtpReady) {
        const msg =
          resendErr && typeof resendErr.message === "string" ?
            resendErr.message :
            String(resendErr);
        throw new Error("Resend: " + msg.slice(0, 240) + " (no SMTP fallback.)");
      }
      // Si Resend échoue, mais que SMTP est configuré, on ne sort pas, on continue vers SMTP.
    }
  }

  // Si Resend n'était pas configuré, ou s'il a échoué et que SMTP est prêt.
  if (smtpReady) {
    await sendPaychekMailWithOptionalFallback(mailOptions, pass, logCtx);
    return; // Sortir après l'envoi réussi via SMTP
  }

  // Si aucun des canaux n'était prêt.
  throw new Error(
      resendKey ?
          "SMTP fallback incomplete: PAYCHEK_SMTP_HOST, PAYCHEK_SMTP_USER, secret PAYCHEK_SMTP_PASSWORD." :
          "Set PAYCHEK_RESEND_API_KEY or PAYCHEK_SMTP_* + PAYCHEK_SMTP_PASSWORD secret.",
  );
}

/** Champ `ticketRef` côté app (ex. PC-K4M9Q2XB), sinon raccourci de l’ID Firestore. */
function humanTicketLabel(ticketData, ticketId) {
  const r = `${ticketData?.ticketRef ?? ""}`.trim();
  if (r.length >= 6) {
    return r;
  }
  return ticketId.length > 14 ? `${ticketId.substring(0, 12)}…` : ticketId;
}

/** Ligne « référence » pour le mail client. */
function footerClientTicketRef(locale, ticketData, ticketId) {
  const r = `${ticketData?.ticketRef ?? ""}`.trim();
  const ref = r.length >= 6 ? r : ticketId;
  return emailI18n.pack(locale).footerTicketRef(ref);
}

function ackSubjectLine(kindFr, description) {
  const ex = `${description ?? ""}`.replace(/\s+/g, " ").trim();
  if (ex.length <= 60) {
    return ex.length > 0 ? `${kindFr} — ${ex}` : kindFr;
  }
  return `${kindFr} — ${ex.slice(0, 57)}…`;
}

/** Extrait du message utilisateur pour l’accusé de réception (texte brut, tronqué). */
function buildAcknowledgmentDescriptionPreview(ticketData, locale) {
  const raw = `${ticketData.description ?? ""}`.replace(/\s+/g, " ").trim();
  if (!raw) return emailI18n.pack(locale).noMessagePreview;
  const max = 500;
  return raw.length > max ? `${raw.slice(0, max)}…` : raw;
}

function buildUserAcknowledgmentText(ticketData, ticketLabels, locale) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  const p = emailI18n.pack(loc).ack;
  const displayNameRaw = `${ticketData.replyDisplayName ?? ""}`.trim();
  const greeting = displayNameRaw ?
    p.greetingNamed(displayNameRaw) :
    p.greeting;
  const sujetConcern = `${ticketLabels.sujetLine}`;
  const delay = emailI18n.pack(loc).responseDelay;

  return (
    `${greeting}\n\n` +
    p.body(sujetConcern, delay, KNOWLEDGE_BASE_URL_FR, COMPANY_NAME) +
    `\n${p.refLine(ticketLabels.label)}\n` +
    `${p.openedLine(ticketLabels.opened)}\n`
  );
}

function buildUserAcknowledgmentHtml(ticketData, ticketLabels, locale) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  const strings = emailI18n.pack(loc).ack;
  const ticketLabel = escapeHtml(ticketLabels.label);
  const nomUtilisateur = escapeHtml(ticketUserGreetingName(ticketData));
  const ackDelay = escapeHtml(emailI18n.pack(loc).responseDelay);
  const messagePreview = plainTextToHtmlBr(
      buildAcknowledgmentDescriptionPreview(ticketData, loc),
  );
  const supportHref = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const followTicketHref = supportHref;

  return `<!DOCTYPE html>
<html lang="${loc}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${escapeHtml(strings.htmlTitle)}</title>
    <style>
        body, table, td, a { text-decoration: none; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
        table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
        img { -ms-interpolation-mode: bicubic; border: 0; height: auto; line-height: 100%; outline: none; }
        
        body {
            background-color: #000000;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            width: 100% !important;
        }

        .container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            background-color: #000000;
            border: 1px solid #1a1a1a;
        }

        .header {
            padding: 60px 20px 40px 20px;
            text-align: center;
        }

        .brand-logo {
            font-size: 22px;
            font-weight: 900;
            color: #ffffff;
            letter-spacing: 6px;
            text-transform: uppercase;
        }

        .content {
            padding: 0 50px 50px 50px;
            color: #ffffff;
            line-height: 1.6;
        }

        .support-badge {
            border: 1px solid #c5a059;
            color: #c5a059;
            padding: 6px 14px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            display: inline-block;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        h1 {
            color: #ffffff;
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 20px;
            line-height: 1.1;
        }

        .ticket-box {
            background-color: #0a0a0a;
            border: 1px solid #1a1a1a;
            border-radius: 8px;
            padding: 25px;
            margin: 40px 0;
        }

        .ticket-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-size: 13px;
        }

        .ticket-label { color: #666666; text-transform: uppercase; letter-spacing: 1px; }
        .ticket-value { color: #ffffff; font-weight: 600; text-align: right; }

        .divider {
            height: 1px;
            background: #1a1a1a;
            margin: 15px 0;
        }

        .message-preview {
            margin-top: 40px;
        }

        .preview-title {
            color: #ffffff;
            font-size: 14px;
            font-weight: 700;
            text-transform: uppercase;
            margin-bottom: 10px;
            letter-spacing: 1px;
        }

        .preview-content {
            color: #888888;
            font-size: 14px;
            background: #050505;
            padding: 15px;
            border-left: 1px solid #c5a059;
            font-style: italic;
        }

        .footer {
            padding: 50px;
            text-align: center;
            font-size: 10px;
            color: #333333;
            letter-spacing: 1px;
            text-transform: uppercase;
            border-top: 1px solid #1a1a1a;
        }

        @media screen and (max-width: 600px) {
            .content { padding: 0 25px 50px 25px !important; }
            h1 { font-size: 26px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="brand-logo">PAYCHEK</div>
        </div>

        <div class="content">
            <div style="text-align: center;">
                <div class="support-badge">${strings.badge}</div>
                <h1>${strings.h1}</h1>
                <p style="color: #888888; font-size: 16px;">${strings.htmlGreeting(nomUtilisateur)}</p>
            </div>

            <div class="ticket-box">
                <div class="ticket-info">
                    <span class="ticket-label">${strings.refLabel}</span>
                    <span class="ticket-value">#${ticketLabel}</span>
                </div>
                <div class="divider"></div>
                <div class="ticket-info">
                    <span class="ticket-label">${strings.delayLabel}</span>
                    <span class="ticket-value" style="color: #c5a059;">${ackDelay}</span>
                </div>
            </div>

            <div class="message-preview">
                <div class="preview-title">${strings.previewTitle}</div>
                <div class="preview-content">
                    ${messagePreview}
                </div>
            </div>

            <p style="text-align: center; color: #444444; font-size: 12px; margin-top: 50px;">
                ${strings.footerNote}
            </p>
        </div>

        <div class="footer">
            <p>
                <strong>PAYCHEK SUPPORT LABS</strong> — PRECISION & RIGOR.<br><br>
                <a href="${supportHref}" style="color: #555555;">${strings.helpCenter}</a> &nbsp;•&nbsp; <a href="${followTicketHref}" style="color: #555555;">${strings.followTicket}</a>
            </p>
        </div>
    </div>
</body>
</html>`;
}

function escapeHtml(s) {
  return String(s ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

/** Document Firestore `paychek_app_config/email_templates` (HTML optionnel). */
const PAYCHEK_EMAIL_TEMPLATES_DOC_ID = "email_templates";

async function paychekLoadEmailTemplateOverrides(db) {
  const snap = await db.collection("paychek_app_config").doc(
      PAYCHEK_EMAIL_TEMPLATES_DOC_ID,
  ).get();
  if (!snap.exists) return {};
  return snap.data() ?? {};
}

/**
 * HTML personnalisé Firestore (`welcomeSignupHtml` = FR) ou variante par locale
 * (`welcomeSignupHtml_de`, `welcomeSignupHtml_en`, …).
 * @param {Record<string, unknown>} tplData
 * @param {string} locale
 */
function paychekWelcomeSignupHtmlOverride(tplData, locale) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  const perLocale = `${tplData[`welcomeSignupHtml_${loc}`] ?? ""}`.trim();
  if (perLocale) return perLocale;
  if (loc === "fr") {
    return `${tplData.welcomeSignupHtml ?? ""}`.trim();
  }
  return "";
}

/**
 * Idem pour l’e-mail Pro (`proAccessConfirmedHtml` = FR).
 * @param {Record<string, unknown>} tplData
 * @param {string} locale
 */
function paychekProAccessHtmlOverride(tplData, locale) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  const perLocale = `${tplData[`proAccessConfirmedHtml_${loc}`] ?? ""}`.trim();
  if (perLocale) return perLocale;
  if (loc === "fr") {
    return `${tplData.proAccessConfirmedHtml ?? ""}`.trim();
  }
  return "";
}

function paychekApplyEmailPlaceholders(template, vars) {
  let out = `${template}`;
  for (const [key, val] of Object.entries(vars)) {
    const token = `{{${key}}}`;
    out = out.split(token).join(`${val}`);
  }
  return paychekApplyLegacyMaquetteTokens(out, vars);
}

/**
 * Maquettes HTML collées dans Firestore avec libellés entre crochets / #TK-…
 * (sans jetons {{}}) : substitution de secours après {{cle}}.
 * @param {string} out
 * @param {Record<string, string|undefined|null>} vars
 */
/** Variantes HTML / maquettes pour le prénom dans les e-mails de bienvenue. */
function paychekNormalizeWelcomeTemplateTokens(html) {
  let h = `${html}`.normalize("NFC");
  h = h.split("[Pr&#233;nom]").join("[Prénom]");
  h = h.split("[Pr&eacute;nom]").join("[Prénom]");
  h = h.split("[Prenom]").join("[Prénom]");
  h = h.split("[PRENOM]").join("[Prénom]");
  h = h.split("［Prénom］").join("[Prénom]");
  return h;
}

function paychekApplyLegacyMaquetteTokens(out, vars) {
  let o = paychekNormalizeWelcomeTemplateTokens(out);
  const prenom =
    vars.firstName != null && `${vars.firstName}`.trim() !== "" ?
      String(vars.firstName) :
      vars.nomUtilisateur != null && `${vars.nomUtilisateur}`.trim() !== "" ?
        String(vars.nomUtilisateur) :
        "Trader";
  o = o.split("[Prénom]").join(prenom);
  if (vars.messagePreview != null && `${vars.messagePreview}`.trim() !== "") {
    const mp = String(vars.messagePreview);
    o = o.split("[Aperçu du message de l'utilisateur...]").join(mp);
    o = o.split("[Aperçu du message de l'utilisateur…]").join(mp);
  }
  if (vars.messageHtml != null && `${vars.messageHtml}`.trim() !== "") {
    const mh = String(vars.messageHtml);
    o = o.replace(
        /\[Insérer ici la réponse détaillée de l['\u2019]agent support\.[\s\S]*?\]/g,
        mh,
    );
  }
  if (vars.nomAgent != null && `${vars.nomAgent}`.trim() !== "") {
    const na = String(vars.nomAgent);
    o = o.split("[Nom de l'Agent]").join(na);
    o = o.split("[Nom de l’Agent]").join(na);
  }
  if (vars.ticketLabel != null && `${vars.ticketLabel}`.trim() !== "") {
    const ref = String(vars.ticketLabel).replace(/^#/, "");
    o = o.replace(/#TK-[0-9]+/gi, `#${ref}`);
  }
  if (vars.ticketStatusLabel != null && `${vars.ticketStatusLabel}`.trim() !== "") {
    o = o.split("Résolu / En attente").join(String(vars.ticketStatusLabel));
  }
  const periodEnd =
    vars.periodEndFr != null && `${vars.periodEndFr}`.trim() !== "" ?
      String(vars.periodEndFr) :
      vars.validUntil != null && `${vars.validUntil}`.trim() !== "" ?
        String(vars.validUntil) :
        "";
  if (periodEnd !== "") {
    o = o.split("[Date de fin]").join(periodEnd);
    o = o.split("[Date de renouvellement]").join(periodEnd);
    o = o.split("[Date anniversaire]").join(periodEnd);
    o = o.split("[Valide jusqu'au]").join(periodEnd);
    o = o.split("[Valide jusqu’au]").join(periodEnd);
  }
  return o;
}

/**
 * @param {unknown} raw
 * @return {FirebaseFirestore.Timestamp | null}
 */
function paychekCoerceFirestoreTimestamp(raw) {
  if (raw == null) return null;
  if (raw instanceof admin.firestore.Timestamp) return raw;
  if (typeof raw === "object" && typeof raw.toDate === "function") {
    try {
      raw.toDate();
      return /** @type {FirebaseFirestore.Timestamp} */ (raw);
    } catch (_) {
      /* ignore */
    }
  }
  if (typeof raw === "object") {
    const sec =
      typeof raw.seconds === "number" ?
        raw.seconds :
        typeof raw._seconds === "number" ?
          raw._seconds :
          null;
    if (sec != null) {
      const ns =
        typeof raw.nanoseconds === "number" ?
          raw.nanoseconds :
          typeof raw._nanoseconds === "number" ?
            raw._nanoseconds :
            0;
      return admin.firestore.Timestamp.fromMillis(
          sec * 1000 + Math.floor(ns / 1e6),
      );
    }
  }
  return null;
}

/**
 * @param {import("stripe").Stripe.Subscription} sub
 * @param {FirebaseFirestore.Timestamp | null} proSinceUtc
 */
function paychekPeriodFromStripeSubscription(sub, proSinceUtc) {
  /** @type {FirebaseFirestore.Timestamp | null} */
  let currentPeriodEnd = null;
  let nextProSince = proSinceUtc;
  if (typeof sub.current_period_end === "number" && sub.current_period_end > 0) {
    currentPeriodEnd = admin.firestore.Timestamp.fromMillis(
        sub.current_period_end * 1000,
    );
  }
  if (
      !currentPeriodEnd &&
      sub.items &&
      Array.isArray(sub.items.data)
  ) {
    for (const item of sub.items.data) {
      if (
        typeof item.current_period_end === "number" &&
        item.current_period_end > 0
      ) {
        currentPeriodEnd = admin.firestore.Timestamp.fromMillis(
            item.current_period_end * 1000,
        );
        break;
      }
    }
  }
  if (typeof sub.current_period_start === "number" && sub.current_period_start > 0) {
    nextProSince = admin.firestore.Timestamp.fromMillis(
        sub.current_period_start * 1000,
    );
  }
  return {currentPeriodEnd, proSinceUtc: nextProSince};
}

/** Retours à la ligne -> <br> (contenu déjà échappé). */
function plainTextToHtmlBr(text) {
  return escapeHtml(text).replace(/\r\n|\r|\n/g, "<br>");
}

function ticketUserGreetingName(ticketData) {
  const dn = `${ticketData.replyDisplayName ?? ""}`.trim();
  if (dn) return dn;
  const em = `${ticketData.replyEmail ?? ""}`.trim();
  if (em.includes("@")) {
    const loc = em.split("@")[0];
    return loc.length > 0 ?
      loc.charAt(0).toUpperCase() + loc.slice(1) :
      "Client";
  }
  return "Client";
}

function staffInitialsFromEmail(email) {
  const e = `${email ?? ""}`.trim().toLowerCase();
  if (!e.includes("@")) return "PC";
  const local = e.split("@")[0].replace(/[^a-z]/gi, "");
  if (local.length >= 2) return local.slice(0, 2).toUpperCase();
  if (local.length === 1) return (local[0] + local[0]).toUpperCase();
  return "PC";
}

function staffDisplayNameFromEmail(email) {
  const e = `${email ?? ""}`.trim();
  if (!e.includes("@")) return "Support PAYCHEK";
  const local = e.split("@")[0];
  return local.length > 0 ?
    local.charAt(0).toUpperCase() + local.slice(1) :
    "Support PAYCHEK";
}

/** Prénom saisi dans la console (paychek_admin_profiles). */
async function paychekAdminProfileFirstName(db, staffUid) {
  const u = `${staffUid ?? ""}`.trim();
  if (!u) return "";
  const snap = await db.collection("paychek_admin_profiles").doc(u).get();
  if (!snap.exists) return "";
  return `${snap.data()?.firstName ?? ""}`.trim();
}

/** Initiales à partir du prénom enregistré (2 premières lettres utiles). */
function initialsFromFirstName(firstName) {
  const raw = `${firstName ?? ""}`.trim();
  if (!raw) return "";
  const letters = raw.normalize("NFKD").replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-zA-Z]/g, "");
  if (letters.length >= 2) return letters.slice(0, 2).toUpperCase();
  if (letters.length === 1) return (letters[0] + letters[0]).toUpperCase();
  const ch = [...raw][0];
  return ch ?
    `${ch}${ch}`.toUpperCase() :
    "";
}

function supportCsatMailtoHref(ticketLabel, ratingKey, mailFromAddr) {
  const subj = encodeURIComponent(
    `[PAYCHEK] Avis ticket ${ticketLabel} — ${ratingKey}`,
  );
  const bod = encodeURIComponent(
    `Référence : ${ticketLabel}\nÉvaluation : ${ratingKey}\n\n`,
  );
  return `mailto:${mailFromAddr}?subject=${subj}&body=${bod}`;
}

/** Fragment HTML « pièce jointe » pour les mails réponse staff (déjà échappé). */
function buildStaffSupportAttachmentBlock(attachmentShownFileName, locale) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  const safeAttachName =
    typeof attachmentShownFileName === "string" &&
      attachmentShownFileName.trim().length > 0 ?
      escapeHtml(attachmentShownFileName.trim()) :
      "";
  if (!safeAttachName.length) return "";
  return (
    `<p style="color:#94a3b8;font-size:13px;line-height:1.55;margin:-8px 0 22px;">` +
      emailI18n.pack(loc).attachmentBlock(safeAttachName) +
    `</p>`
  );
}

async function resolveUserAcknowledgmentHtml(db, ticketData, ticketLabels, locale) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  let custom = "";
  try {
    const data = await paychekLoadEmailTemplateOverrides(db);
    custom = `${data.userAcknowledgmentHtml ?? ""}`.trim();
  } catch (e) {
    console.warn("resolveUserAcknowledgmentHtml: lecture Firestore", e);
  }
  if (!custom) return buildUserAcknowledgmentHtml(ticketData, ticketLabels, loc);

  const supportHrefEsc = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const vars = {
    ticketLabel: escapeHtml(ticketLabels.label),
    opened: escapeHtml(ticketLabels.opened),
    sujet: escapeHtml(ticketLabels.sujetLine),
    nomUtilisateur: escapeHtml(ticketUserGreetingName(ticketData)),
    ackDelay: escapeHtml(emailI18n.pack(loc).responseDelay),
    messagePreview: plainTextToHtmlBr(
        buildAcknowledgmentDescriptionPreview(ticketData, loc),
    ),
    priorityLabel: escapeHtml(
        `${ticketLabels.kindFr ?? ""}`.trim() || "Standard",
    ),
    supportHref: supportHrefEsc,
    followTicketHref: supportHrefEsc,
  };
  return paychekApplyEmailPlaceholders(custom, vars);
}

async function resolveStaffSupportReplyHtml(db, opts) {
  const loc = emailI18n.normalizePaychekEmailLocale(opts.locale);
  let custom = "";
  try {
    const data = await paychekLoadEmailTemplateOverrides(db);
    custom = `${data.staffSupportReplyHtml ?? ""}`.trim();
  } catch (e) {
    console.warn("resolveStaffSupportReplyHtml: lecture Firestore", e);
  }

  const ticketLabel = `${opts.ticketLabel}`;
  const nomUtilisateur = `${opts.nomUtilisateur}`;
  const sujetTicketPlain = `${opts.sujetTicketPlain}`;
  const messageBodyPlain = `${opts.messageBodyPlain}`;
  const initialesAgent = `${opts.initialesAgent}`;
  const nomAgent = `${opts.nomAgent}`;
  const attachmentShownFileName = opts.attachmentShownFileName;
  const mailFromForCsat = `${opts.mailFromForCsat}`;

  if (!custom) {
    return buildStaffSupportReplyHtml({
      ticketLabel,
      nomUtilisateur,
      sujetTicketPlain,
      messageBodyPlain,
      initialesAgent,
      nomAgent,
      attachmentShownFileName,
      mailFromForCsat,
      locale: loc,
    });
  }

  const safeLabel = escapeHtml(ticketLabel);
  const safeNom = escapeHtml(nomUtilisateur);
  const safeSujet = escapeHtml(sujetTicketPlain);
  const messageHtml = plainTextToHtmlBr(messageBodyPlain);
  const safeInit = escapeHtml(initialesAgent);
  const safeAgent = escapeHtml(nomAgent);
  const pjBlock = buildStaffSupportAttachmentBlock(attachmentShownFileName, loc);
  const csat = emailI18n.pack(loc).csat;

  const csatPoor = supportCsatMailtoHref(ticketLabel, csat.poor, mailFromForCsat);
  const csatOk = supportCsatMailtoHref(ticketLabel, csat.ok, mailFromForCsat);
  const csatGood = supportCsatMailtoHref(ticketLabel, csat.good, mailFromForCsat);
  const csatGreat = supportCsatMailtoHref(ticketLabel, csat.great, mailFromForCsat);

  const supportHrefEsc = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const journalHrefEsc = supportHrefEsc;
  const ticketStatusLabel = escapeHtml(emailI18n.pack(loc).ticketStatusPending);

  return paychekApplyEmailPlaceholders(custom, {
    ticketLabel: safeLabel,
    nomUtilisateur: safeNom,
    sujet: safeSujet,
    messageHtml,
    pjBlock,
    initialesAgent: safeInit,
    nomAgent: safeAgent,
    csatPoor,
    csatOk,
    csatGood,
    csatGreat,
    supportHref: supportHrefEsc,
    journalHref: journalHrefEsc,
    ticketStatusLabel,
  });
}

/**
 * E-mail HTML « réponse support » (template PAYCHEK).
 * Les jetons {{csat*}} (mailto) restent disponibles pour un HTML personnalisé Firestore.
 */
function buildStaffSupportReplyHtml({
  ticketLabel,
  nomUtilisateur,
  sujetTicketPlain,
  messageBodyPlain,
  initialesAgent,
  nomAgent,
  attachmentShownFileName,
  mailFromForCsat,
  locale,
}) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  const strings = emailI18n.pack(loc).staffReply;
  const safeLabel = escapeHtml(ticketLabel);
  const safeNom = escapeHtml(nomUtilisateur);
  const safeSujet = escapeHtml(sujetTicketPlain);
  const messageHtml = plainTextToHtmlBr(messageBodyPlain);
  const safeInit = escapeHtml(initialesAgent).trim();
  const safeAgent = escapeHtml(nomAgent);

  const pjBlock = buildStaffSupportAttachmentBlock(attachmentShownFileName, loc);

  const supportHref = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const journalHref = supportHref;

  return `<!DOCTYPE html>
<html lang="${loc}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${escapeHtml(strings.htmlTitle)}</title>
    <style>
        body, table, td, a { text-decoration: none; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
        table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
        img { -ms-interpolation-mode: bicubic; border: 0; height: auto; line-height: 100%; outline: none; }
        
        body {
            background-color: #000000;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            width: 100% !important;
        }

        .container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            background-color: #000000;
            border: 1px solid #1a1a1a;
        }

        .header {
            padding: 60px 20px 40px 20px;
            text-align: center;
        }

        .brand-logo {
            font-size: 22px;
            font-weight: 900;
            color: #ffffff;
            letter-spacing: 6px;
            text-transform: uppercase;
        }

        .content {
            padding: 0 50px 50px 50px;
            color: #ffffff;
            line-height: 1.6;
        }

        .reply-badge {
            border: 1px solid #c5a059;
            color: #c5a059;
            padding: 6px 14px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            display: inline-block;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        h1 {
            color: #ffffff;
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 20px;
            line-height: 1.1;
        }

        .agent-message {
            background-color: #050505;
            border-radius: 12px;
            padding: 30px;
            margin: 30px 0;
            border-left: 3px solid #c5a059;
            color: #dddddd;
            font-size: 15px;
            line-height: 1.8;
        }

        .agent-signature {
            margin-top: 25px;
            padding-top: 15px;
            border-top: 1px solid #1a1a1a;
            color: #666666;
            font-size: 13px;
        }

        .ticket-meta {
            margin-top: 40px;
            padding: 20px;
            background-color: #0a0a0a;
            border: 1px solid #1a1a1a;
            border-radius: 8px;
        }

        .meta-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 12px;
        }

        .meta-label { color: #444444; text-transform: uppercase; letter-spacing: 1px; }
        .meta-value { color: #888888; }

        .footer {
            padding: 50px;
            text-align: center;
            font-size: 10px;
            color: #333333;
            letter-spacing: 1px;
            text-transform: uppercase;
            border-top: 1px solid #1a1a1a;
        }

        @media screen and (max-width: 600px) {
            .content { padding: 0 25px 50px 25px !important; }
            h1 { font-size: 26px; }
            .agent-message { padding: 20px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="brand-logo">PAYCHEK</div>
        </div>

        <div class="content">
            <div style="text-align: center;">
                <div class="reply-badge">${strings.badge}</div>
                <h1>${strings.h1}</h1>
                <p style="color: #888888; font-size: 15px;">${strings.intro(safeNom)}</p>
                <p style="color: #666666; font-size: 13px; margin-top: 8px;">${strings.subjectLine(safeSujet)}</p>
            </div>

            <div class="agent-message">
                ${messageHtml}
                ${pjBlock}
                <div class="agent-signature">
                    <strong>${safeAgent}</strong>${safeInit ? ` <span style="color:#555555;">· ${safeInit}</span>` : ""}<br>
                    ${strings.supportLine}
                </div>
            </div>

            <div class="ticket-meta">
                <div class="meta-row">
                    <span class="meta-label">${strings.refLabel}</span>
                    <span class="meta-value">#${safeLabel}</span>
                </div>
            </div>

            <p style="text-align: center; color: #444444; font-size: 11px; margin-top: 40px; text-transform: uppercase; letter-spacing: 1px;">
                ${strings.footerNote}
            </p>
        </div>

        <div class="footer">
            <p>
                <strong>PAYCHEK SUPPORT LABS</strong> — PRECISION & RIGOR.<br><br>
                <a href="${supportHref}" style="color: #555555;">${strings.helpCenter}</a> &nbsp;•&nbsp; <a href="${journalHref}" style="color: #555555;">${strings.myJournal}</a>
            </p>
        </div>
    </div>
</body>
</html>`;
}

function asciiSafeEmailAttachmentFileName(raw) {
  const s = `${raw ?? ""}`.trim();
  const tail = s.length > 200 ? s.slice(s.length - 200) : s;
  if (!tail) return "piece-jointe";
  let out = "";
  for (let i = 0; i < tail.length; i++) {
    const c = tail[i];
    out += /[a-zA-Z0-9._-]/.test(c) ? c : "_";
  }
  return out.replace(/_+/g, "_").replace(/^_|_$/g, "") || "piece-jointe";
}

/**
 * Télécharge une PJ staff depuis Storage (Admin SDK) pour l’e-mail.
 * Chemin attendu : support_staff_attachments/{ownerUid}/{ticketId}/{fileName}
 */
async function fetchStaffSupportReplyAttachment({
  storagePathRaw,
  fileNameHint,
  contentTypeHint,
  ticketOwnerUid,
  ticketId,
}) {
  const sp = `${storagePathRaw ?? ""}`.trim();
  if (!sp) return null;

  const owner = `${ticketOwnerUid ?? ""}`.trim();
  const tid = `${ticketId ?? ""}`.trim();
  if (!owner || !tid) {
    throw new HttpsError(
        "invalid-argument",
        "Ticket sans propriétaire pour la pièce jointe.",
    );
  }

  const expectedPrefix = `support_staff_attachments/${owner}/${tid}/`;
  if (!sp.startsWith(expectedPrefix) || sp.includes("..")) {
    throw new HttpsError(
        "invalid-argument",
        "Chemin Storage de la pièce jointe invalide.",
    );
  }

  const fileNameTail = sp.slice(expectedPrefix.length);
  if (
    !fileNameTail ||
    fileNameTail.includes("/") ||
    !/^[a-zA-Z0-9._-]{1,240}$/.test(fileNameTail)
  ) {
    throw new HttpsError(
        "invalid-argument",
        "Nom de fichier Storage invalide.",
    );
  }

  const bucket = admin.storage().bucket();
  const f = bucket.file(sp);
  const [exists] = await f.exists();
  if (!exists) {
    console.warn("sendStaffSupportEmail: fichier Storage introuvable", sp);
    return null;
  }

  const [meta] = await f.getMetadata();
  const sizeNum = Number(meta.size || 0);
  const maxAttach = 10 * 1024 * 1024;
  if (sizeNum > maxAttach) {
    throw new HttpsError(
        "failed-precondition",
        "Pièce jointe trop volumineuse (max 10 Mo).",
    );
  }

  const [buffer] = await f.download();

  let fn =
    typeof fileNameHint === "string" && fileNameHint.trim().length > 0 ?
      fileNameHint.trim() :
      fileNameTail;
  if (fn.length > 240) fn = fn.slice(fn.length - 240);

  let mime =
    typeof contentTypeHint === "string" && contentTypeHint.trim().length > 0 ?
      contentTypeHint.trim() :
      `${meta.contentType ?? ""}`.trim();
  if (!mime) mime = "application/octet-stream";

  return {
    filename: fn,
    mime,
    buf: buffer,
  };
}

exports.sendStaffSupportEmail = onCall(
  {
    region: "europe-west1",
    secrets: [paychekSmtpPassword],
    timeoutSeconds: 180,
    memory: "512MiB",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Connexion requise.");
    }
    if (request.auth.token.admin !== true) {
      throw new HttpsError("permission-denied", "Réservé aux administrateurs.");
    }

    const ticketIdRaw = request.data?.ticketId;
    const messageBodyRaw = request.data?.messageBody;
    const ticketId =
      typeof ticketIdRaw === "string" ? ticketIdRaw.trim() : "";
    const messageBody =
      typeof messageBodyRaw === "string" ? messageBodyRaw.trim() : "";
    const attachmentStoragePathRaw =
      `${request.data?.attachmentStoragePath ?? ""}`.trim();
    const attachmentFileNameRaw =
      `${request.data?.attachmentFileName ?? ""}`.trim();
    const attachmentContentTypeRaw =
      `${request.data?.attachmentContentType ?? ""}`.trim();

    if (!ticketId || ticketId.length > 256) {
      throw new HttpsError("invalid-argument", "ticketId invalide.");
    }
    if (!messageBody || messageBody.length > 20000) {
      throw new HttpsError("invalid-argument", "Message vide ou trop long.");
    }

    const rawPass = paychekSmtpPassword.value();
    const pass = normalizeSmtpPassword(rawPass);
    const resendKey = `${paychekResendApiKey.value()}`.trim();
    const id = paychekSmtpIdentity();
    const smtpReady = Boolean(id.host && id.user && pass);

    if (!resendKey && !smtpReady) {
      if (!pass) {
        throw new HttpsError(
            "failed-precondition",
            "Set PAYCHEK_RESEND_API_KEY (Resend, recommended) or secret PAYCHEK_SMTP_PASSWORD for SMTP.",
        );
      }
      throw new HttpsError(
          "failed-precondition",
          "Incomplete SMTP: PAYCHEK_SMTP_HOST and PAYCHEK_SMTP_USER empty but SMTP password is set. " +
          "Fill SMTP fields or set PAYCHEK_RESEND_API_KEY for Resend-only.",
      );
    }

    if (resendKey && !`${id.mailFrom}`.includes("@")) {
      throw new HttpsError(
          "failed-precondition",
          "PAYCHEK_MAIL_FROM invalide pour l’envoi (Resend ou SMTP).",
      );
    }

    const db = admin.firestore();
    const ref = db.collection("paychek_support_tickets").doc(ticketId);
    const snap = await ref.get();

    if (!snap.exists) {
      throw new HttpsError("not-found", "Ticket introuvable.");
    }

    const t = snap.data();
    const to = `${t.replyEmail ?? ""}`.trim();
    if (!to.includes("@")) {
      throw new HttpsError(
        "failed-precondition",
        "Le ticket n’a pas d’adresse replyEmail.",
      );
    }

    const kind = `${t.kind ?? "other"}`.trim() || "other";
    const label = humanTicketLabel(t, ticketId);
    const staffFromToken = `${request.auth.token.email ?? ""}`.trim();
    const ticketOwnerUid = `${t.userId ?? ""}`.trim();
    const locale = await emailI18n.paychekResolveEmailLocale(
        db,
        ticketOwnerUid,
        t,
    );
    const kindLocalized = emailI18n.kindLabel(locale, kind);
    const subject = emailI18n.pack(locale).staffReplySubject(kindLocalized, label);
    const staffReplyStrings = emailI18n.pack(locale).staffReply;

    let mailAttachments = [];
    if (attachmentStoragePathRaw) {
      if (!attachmentFileNameRaw) {
        throw new HttpsError(
            "invalid-argument",
            "attachmentFileName requis avec attachmentStoragePath.",
        );
      }
      try {
        const att = await fetchStaffSupportReplyAttachment({
          storagePathRaw: attachmentStoragePathRaw,
          fileNameHint: attachmentFileNameRaw,
          contentTypeHint: attachmentContentTypeRaw,
          ticketOwnerUid,
          ticketId,
        });
        if (!att) {
          throw new HttpsError(
              "failed-precondition",
              "Pièce jointe introuvable dans Storage.",
          );
        }
        mailAttachments = [{
          filename: asciiSafeEmailAttachmentFileName(att.filename),
          content: att.buf,
          contentType: att.mime,
        }];
      } catch (e) {
        if (e instanceof HttpsError) throw e;
        console.error("sendStaffSupportEmail: lecture Storage PJ", e);
        throw new HttpsError(
            "failed-precondition",
            "Impossible de récupérer la pièce jointe pour l’e-mail.",
        );
      }
    }

    let agentFirstName = "";
    try {
      agentFirstName = await paychekAdminProfileFirstName(db, request.auth.uid);
    } catch (e) {
      console.warn("sendStaffSupportEmail paychekAdminProfileFirstName", e);
    }
    /** HTML : uniquement le prénom `paychek_admin_profiles`; pas d’e-mail comme nom. */
    const nomAgentAffiche = agentFirstName || "Support PAYCHEK";
    const initialesAgentAffiche = agentFirstName ?
      initialsFromFirstName(agentFirstName) :
      staffInitialsFromEmail(staffFromToken);

    const pjLine = mailAttachments.length > 0 ?
      staffReplyStrings.attachmentLine(mailAttachments[0].filename) :
      "";

    const textBody =
      `${messageBody}${pjLine}\n\n` +
      "---\n" +
      `${staffReplyStrings.textFooter(label)}\n\n` +
      `${footerClientTicketRef(locale, t, ticketId)}\n` +
      (staffFromToken.includes("@") ?
        `Support Paychek : ${staffFromToken}\n` :
        "") +
      `${staffReplyStrings.thanks}\n`;

    const htmlBody = await resolveStaffSupportReplyHtml(db, {
      ticketLabel: label,
      nomUtilisateur: ticketUserGreetingName(t),
      sujetTicketPlain: ackSubjectLine(kindLocalized, t.description),
      messageBodyPlain: messageBody,
      initialesAgent: initialesAgentAffiche,
      nomAgent: nomAgentAffiche,
      attachmentShownFileName: mailAttachments.length > 0 ?
        mailAttachments[0].filename :
        "",
      mailFromForCsat: id.mailFrom,
      locale,
    });

    try {
      await sendPaychekMailOutbound(
          {
            from: `"Paychek Support" <${id.mailFrom}>`,
            to,
            bcc: id.mailBcc,
            // Même adresse que From ; l’agent reste cité dans le corps.
            replyTo: id.mailFrom,
            subject,
            text: textBody,
            html: htmlBody,
            attachments: mailAttachments,
          },
          rawPass,
          JSON.stringify({flow: "staffReply", ticketId}),
      );
    } catch (err) {
      console.error("sendStaffSupportEmail: envoi", err);
      throw new HttpsError("failed-precondition", outboundErrorMessageForClient(err));
    }

    return {ok: true};
  },
);

/** E-mail à la boîte équipe dès qu’un document `paychek_support_tickets` est créé (app utilisateur). */
exports.notifyStaffOnSupportTicketCreated = onDocumentCreated(
  {
    document: "paychek_support_tickets/{ticketId}",
    region: "europe-west1",
    secrets: [paychekSmtpPassword],
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const rawPass = paychekSmtpPassword.value();
    const pass = normalizeSmtpPassword(rawPass);
    const resendKey = `${paychekResendApiKey.value()}`.trim();
    const id = paychekSmtpIdentity();
    const smtpReady = Boolean(id.host && id.user && pass);

    if (!resendKey && !smtpReady) {
      if (!pass) {
        console.error(
            "notifyStaffOnSupportTicketCreated: ni PAYCHEK_RESEND_API_KEY ni secret SMTP",
        );
      } else {
        console.error(
            "notifyStaffOnSupportTicketCreated: PAYCHEK_SMTP_HOST / USER manquants",
        );
      }
      return;
    }

    const t = snapshot.data();
    const ticketId = event.params.ticketId;
    const replyEmail = `${t.replyEmail ?? ""}`.trim();
    const uid = `${t.userId ?? ""}`.trim();
    const kind = `${t.kind ?? "other"}`.trim() || "other";
    const desc = `${t.description ?? ""}`.trim();
    const attachmentPending = t.attachmentPending === true;
    const attachmentPathRaw = `${t.attachmentStoragePath ?? ""}`.trim();
    const hasPath = attachmentPathRaw.length > 0;

    const label = humanTicketLabel(t, ticketId);
    const preview =
      desc.length > 2000 ? `${desc.substring(0, 2000)}…` : desc;

    const attachLine = hasPath ?
      "oui (fichier enregistré dans Storage)" :
      attachmentPending ?
        "en cours au moment du mail (voir ticket si upload après)" :
        "non";

    const textBody =
      "Nouvelle demande depuis l’application Paychek.\n\n" +
      `Référence dossier : ${label}\n` +
      `ID Firestore : ${ticketId}\n` +
      `Type : ${kind}\n` +
      `E-mail de réponse (client) : ${replyEmail || "(manquant)"}\n` +
      `UID Firebase : ${uid || "—"}\n` +
      `Pièce jointe : ${attachLine}\n\n` +
      "--- Contenu ---\n" +
      `${preview || "(vide)"}\n\n` +
      "Répondre via le back-office Support (ticket lié).\n";

    try {
      await sendPaychekMailOutbound(
          {
            from: `"Paychek — nouveau ticket" <${id.mailFrom}>`,
            to: id.mailBcc,
            subject: `Paychek — Nouveau ticket · ${kind} (#${label})`,
            text: textBody,
            replyTo: replyEmail.includes("@") ? replyEmail : id.mailFrom,
          },
          rawPass,
          JSON.stringify({flow: "staffNotify", ticketId}),
      );
    } catch (err) {
      console.error("notifyStaffOnSupportTicketCreated: échec SMTP (équipe)", err);
    }

    // Accusé de réception — utilisateur (To) + copie équipe (Bcc).
    if (replyEmail.includes("@")) {
      try {
        const db = admin.firestore();
        const locale = await emailI18n.paychekResolveEmailLocale(db, uid, t);
        const kindLocalized = emailI18n.kindLabel(locale, kind);
        const opened = emailI18n.formatOpeningDate(locale, t.createdAt);
        const sujetLine = ackSubjectLine(kindLocalized, desc);
        const ackLabels = {
          label,
          opened,
          sujetLine,
          kindFr: kindLocalized,
        };
        const ackBody = buildUserAcknowledgmentText(t, ackLabels, locale);
        const ackHtml = await resolveUserAcknowledgmentHtml(
            db,
            t,
            ackLabels,
            locale,
        );
        const ackSubjectPrefix = emailI18n.pack(locale).ackSubjectPrefix(label);
        const ackSubject =
          `${ackSubjectPrefix}` +
          `${sujetLine.replace(/\r?\n/g, " ").slice(0, 100)}${sujetLine.length > 100 ? "…" : ""}`;

        await sendPaychekMailOutbound(
            {
              from: `"${COMPANY_NAME} Support" <${id.mailFrom}>`,
              to: replyEmail,
              bcc: id.mailBcc,
              replyTo: id.mailFrom,
              subject: ackSubject.slice(0, 250),
              text: ackBody,
              html: ackHtml,
            },
            rawPass,
            JSON.stringify({flow: "userAck", ticketId}),
        );
      } catch (err) {
        console.error(
          "notifyStaffOnSupportTicketCreated: échec SMTP (accusé utilisateur)",
          err,
        );
      }
    }
  },
);

/**
 * Accorde ou retire le claim `admin` pour un utilisateur existant dans Firebase Authentication.
 * Réservé aux super-admins ([PAYCHEK_SUPERADMIN_EMAILS] ou claim `superadmin: true`).
 */
exports.managePaychekStaffAdmin = onCall(
  {
    region: "europe-west1",
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Connexion requise.");
    }
    if (!callerIsPaychekSuperadmin(request)) {
      throw new HttpsError(
          "permission-denied",
          "Réservé au super-administrateur Paychek.",
      );
    }

    const actionRaw = `${request.data?.action ?? ""}`.trim().toLowerCase();
    const targetEmailRaw = `${request.data?.targetEmail ?? ""}`.trim();
    const targetEmail = targetEmailRaw.toLowerCase();

    if (targetEmail.includes("@") === false) {
      throw new HttpsError("invalid-argument", "targetEmail invalide.");
    }

    let grant;
    if (actionRaw === "grant") {
      grant = true;
    } else if (actionRaw === "revoke") {
      grant = false;
    } else {
      throw new HttpsError("invalid-argument", "action : grant ou revoke.");
    }

    if (!grant &&
        PAYCHEK_SUPERADMIN_EMAILS.includes(targetEmail)) {
      throw new HttpsError(
          "failed-precondition",
          "Impossible de retirer l’admin au compte super-admin configuré.",
      );
    }

    try {
      const existing = await admin.auth().getUserByEmail(targetEmail);
      const prev = existing.customClaims && typeof existing.customClaims === "object" ?
        {...existing.customClaims} :
        {};
      let nextClaims;
      if (grant) {
        nextClaims = {...prev, admin: true};
      } else {
        nextClaims = {...prev};
        delete nextClaims.admin;
        if (Object.keys(nextClaims).length === 0) {
          nextClaims = {};
        }
      }

      await admin.auth().setCustomUserClaims(existing.uid, nextClaims);

      if (grant) {
        const ip = request.data?.initialProfile;
        if (ip && typeof ip === "object") {
          const clip = (v, max) => `${v ?? ""}`.trim().slice(0, max);
          const firstName = clip(ip.firstName, 120);
          const lastName = clip(ip.lastName, 120);
          const roleTitle = clip(ip.roleTitle, 200);
          const phone = clip(ip.phone, 40);
          const hasProfile =
              firstName || lastName || roleTitle || phone;
          if (hasProfile) {
            /** @type {Record<string, unknown>} */
            const merged = {
              email: targetEmail,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            if (firstName) merged.firstName = firstName;
            if (lastName) merged.lastName = lastName;
            if (roleTitle) merged.roleTitle = roleTitle;
            if (phone) merged.phone = phone;
            await admin
              .firestore()
              .collection("paychek_admin_profiles")
              .doc(existing.uid)
              .set(merged, {merge: true});
          }
          const dn = [firstName, lastName].filter(Boolean).join(" ").trim();
          if (dn.length > 0) {
            try {
              await admin.auth().updateUser(existing.uid, {
                displayName: dn,
              });
            } catch (updateErr) {
              console.warn(
                "managePaychekStaffAdmin updateUser(displayName)",
                updateErr,
              );
            }
          }
        }
      }

      const fresh = await admin.auth().getUser(existing.uid);

      return {
        ok: true,
        targetUid: existing.uid,
        targetEmail,
        claimsAdmin:
          !!(fresh.customClaims && fresh.customClaims.admin === true),
      };
    } catch (err) {
      if (err && err.code === "auth/user-not-found") {
        throw new HttpsError(
            "not-found",
            `Aucun utilisateur Firebase avec l’e-mail « ${targetEmail} ».`,
        );
      }
      console.error("managePaychekStaffAdmin", err);
      throw new HttpsError(
          "internal",
          typeof err.message === "string" ? err.message : "Erreur serveur.",
      );
    }
  },
);

/**
 * Webhook Stripe : active l’abonnement (`subscriber_entitlements` + `paychek_users`)
 * sur `checkout.session.completed`.
 *
 * UID : `client_reference_id` (app) ou, à défaut, email checkout → `paychek_users`.
 *
 * Stripe Dashboard → Webhooks → URL :
 *   https://europe-west1-paychek-trading.cloudfunctions.net/paychekStripeWebhook
 * Événement : checkout.session.completed
 */

/**
 * @param {import("stripe").Stripe.Checkout.Session} session
 * @return {string[]}
 */
function paychekCheckoutEmailCandidates(session) {
  const seen = new Set();
  const out = [];
  const push = (raw) => {
    const t = `${raw ?? ""}`.trim();
    if (!t) return;
    for (const v of [t, t.toLowerCase()]) {
      if (!seen.has(v)) {
        seen.add(v);
        out.push(v);
      }
    }
  };
  push(session.customer_details?.email);
  push(session.customer_email);
  return out;
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {import("stripe").Stripe.Checkout.Session} session
 * @param {import("stripe").Stripe} stripe
 * @return {Promise<string>}
 */
async function paychekResolveUidFromCheckoutSession(db, session, stripe) {
  const direct = `${session.client_reference_id || ""}`.trim();
  if (direct) return direct;

  const emails = paychekCheckoutEmailCandidates(session);
  const customerId =
    typeof session.customer === "string" ?
      session.customer :
      session.customer?.id || "";
  if (customerId) {
    try {
      const customer = await stripe.customers.retrieve(customerId);
      if (customer && !customer.deleted) {
        const fromCustomer = paychekCheckoutEmailCandidates({
          customer_details: {email: customer.email},
          customer_email: customer.email,
        });
        for (const e of fromCustomer) {
          if (!emails.includes(e)) emails.push(e);
        }
      }
    } catch (e) {
      console.warn("paychekStripeWebhook: customer email", e);
    }
  }

  for (const email of emails) {
    const snap = await db
        .collection("paychek_users")
        .where("email", "==", email)
        .limit(2)
        .get();
    if (snap.empty) continue;
    if (snap.size > 1) {
      console.warn(
          "paychekStripeWebhook: email ambigu",
          email,
          snap.docs.map((d) => d.id),
      );
    }
    console.log(
        "paychekStripeWebhook: uid via email",
        snap.docs[0].id,
        email,
        session.id,
    );
    return snap.docs[0].id;
  }
  return "";
}

/**
 * Corps brut Stripe (ne jamais re-sérialiser un objet JSON — casse la signature).
 * @param {import("express").Request} req
 * @return {Buffer}
 */
function paychekStripeWebhookRawBody(req) {
  if (req.rawBody && Buffer.isBuffer(req.rawBody)) return req.rawBody;
  if (Buffer.isBuffer(req.body)) return req.body;
  if (typeof req.body === "string" && req.body.length > 0) {
    return Buffer.from(req.body, "utf8");
  }
  return Buffer.alloc(0);
}

/**
 * @param {import("stripe").Stripe} stripe
 * @param {Buffer} rawBody
 * @param {string} sig
 * @param {string} whSecret
 */
function paychekConstructStripeEvent(stripe, rawBody, sig, whSecret) {
  const candidates = `${whSecret ?? ""}`
      .split(",")
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
  const secrets = candidates.length > 0 ? candidates : [`${whSecret ?? ""}`.trim()];
  let lastErr;
  for (const secret of secrets) {
    if (!secret) continue;
    try {
      return stripe.webhooks.constructEvent(rawBody, sig, secret);
    } catch (e) {
      lastErr = e;
    }
  }
  throw lastErr || new Error("Webhook secret invalide");
}

function paychekEscapeStripeSearchValue(v) {
  return `${v ?? ""}`.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
}

function paychekCheckoutSessionIsPaid(session) {
  return (
    session.payment_status === "paid" ||
    session.payment_status === "no_payment_required"
  );
}

function paychekProMailTxnSuffix(session) {
  let pi = session.payment_intent;
  if (pi && typeof pi === "object" && typeof pi.id === "string") {
    pi = pi.id;
  }
  if (typeof pi === "string" && pi.length > 8) {
    return pi.replace(/^pi_/, "").slice(-14).toUpperCase();
  }
  const sid = `${session.id || ""}`;
  const raw = sid.replace(/^cs_[^_]+_/, "");
  const tail = raw.slice(-14).toUpperCase();
  return tail || sid.slice(-12).toUpperCase();
}

/**
 * @param {FirebaseFirestore.Timestamp|null|undefined} ts
 * @return {string}
 */
function paychekFormatFrenchDateParis(ts) {
  if (!ts || typeof ts.toDate !== "function") return "—";
  return ts.toDate().toLocaleDateString("fr-FR", {
    dateStyle: "long",
    timeZone: "Europe/Paris",
  });
}

/**
 * E-mail « Accès Pro confirmé » (HTML fourni).
 * @param {{clientName: string, periodEndFr: string, txnSuffix: string}} v
 *        — valeurs déjà échappées (escapeHtml).
 */
function buildProAccessConfirmedHtml(v, locale) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  const s = emailI18n.pack(loc).pro;
  const supportHref = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const privacyHref = escapeHtml(PAYCHEK_PRIVACY_PAGE_URL_FR);
  return `<!DOCTYPE html>
<html lang="${loc}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${escapeHtml(s.htmlTitle)}</title>
    <style>
        body, table, td, a { text-decoration: none; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
        table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
        img { -ms-interpolation-mode: bicubic; border: 0; height: auto; line-height: 100%; outline: none; }

        body {
            background-color: #000000;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            width: 100% !important;
        }

        .container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            background-color: #000000;
            border: 1px solid #1a1a1a;
        }

        .header {
            padding: 60px 20px 40px 20px;
            text-align: center;
        }

        .brand-logo {
            font-size: 22px;
            font-weight: 900;
            color: #ffffff;
            letter-spacing: 6px;
            text-transform: uppercase;
        }

        .gold-text {
            color: #c5a059 !important;
            font-weight: 800;
        }

        .success-badge {
            border: 1px solid #c5a059;
            color: #c5a059;
            padding: 6px 14px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            display: inline-block;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        h1 {
            color: #ffffff;
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 20px;
            line-height: 1.1;
        }

        .receipt-card {
            background-color: #080808;
            border: 1px solid #1a1a1a;
            border-radius: 8px;
            padding: 30px;
            margin: 40px 0;
        }

        .receipt-table {
            width: 100%;
            border-collapse: collapse;
        }

        .receipt-table td {
            padding: 0 0 12px 0;
            font-size: 14px;
            vertical-align: top;
        }

        .receipt-label { color: #555555; text-transform: uppercase; letter-spacing: 1px; font-size: 11px; }
        .receipt-value { color: #ffffff; font-weight: 500; text-align: right; }

        .divider {
            height: 1px;
            background: #1a1a1a;
            margin: 20px 0;
        }

        .feature-item {
            margin-bottom: 35px;
            padding-left: 20px;
            border-left: 2px solid #c5a059;
        }

        .feature-title {
            color: #ffffff;
            font-size: 15px;
            font-weight: 700;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .feature-desc {
            color: #777777;
            font-size: 14px;
            line-height: 1.5;
        }

        .footer {
            padding: 50px;
            text-align: center;
            font-size: 10px;
            color: #333333;
            letter-spacing: 1px;
            text-transform: uppercase;
            border-top: 1px solid #1a1a1a;
        }

        @media screen and (max-width: 600px) {
            .content { padding: 0 25px 50px 25px !important; }
            h1 { font-size: 26px; }
            .receipt-card { padding: 20px; }
            .receipt-table td { font-size: 13px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="brand-logo">PAYCHEK</div>
        </div>

        <div class="content" style="padding: 0 50px 50px 50px;">
            <div style="text-align: center;">
                <div class="success-badge">${s.badge}</div>
                <h1>${s.h1}</h1>
                <p style="color: #666666; font-size: 16px; margin-bottom: 0;">${s.intro}</p>
            </div>

            <div class="receipt-card">
                <table class="receipt-table" role="presentation" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td class="receipt-label">${s.clientLabel}</td>
                    <td class="receipt-value">${v.clientName}</td>
                </tr>
                <tr>
                    <td class="receipt-label">${s.planLabel}</td>
                    <td class="receipt-value"><span class="gold-text">PRO</span> ACCESS</td>
                </tr>
                </table>
                <div class="divider"></div>
                <table class="receipt-table" role="presentation" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td class="receipt-label">${s.statusLabel}</td>
                    <td class="receipt-value" style="color: #c5a059;">${s.statusActive}</td>
                </tr>
                <tr>
                    <td class="receipt-label">${s.validUntilLabel}</td>
                    <td class="receipt-value">${v.periodEndFr}</td>
                </tr>
                </table>
            </div>

            <div style="margin-top: 50px;">
                <div class="feature-item">
                    <div class="feature-title">${s.featTitle}</div>
                    <div class="feature-desc">${s.featDesc}</div>
                </div>
            </div>

            <p style="text-align: center; font-size: 11px; color: #333333; margin-top: 40px; text-transform: uppercase; letter-spacing: 1px;">
                ${s.txnLine(v.txnSuffix)}
            </p>
        </div>

        <div class="footer">
            <p>
                <strong>PAYCHEK LABS</strong> — L'EXCELLENCE DANS LA DISCIPLINE.<br><br>
                <a href="${supportHref}" style="color: #555555;">${emailI18n.pack(loc).welcome.support}</a> &nbsp;•&nbsp; <a href="${privacyHref}" style="color: #555555;">${emailI18n.pack(loc).welcome.privacy}</a>
            </p>
        </div>
    </div>
</body>
</html>`;
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} passRaw
 * @param {string} uid
 * @param {import("stripe").Stripe.Checkout.Session} session
 * @param {FirebaseFirestore.Timestamp|null|undefined} periodEndTs
 */
async function paychekSendProAccessConfirmedEmail(db, passRaw, uid, session, periodEndTs) {
  const id = paychekSmtpIdentity();
  const resendKey = `${paychekResendApiKey.value()}`.trim();
  const pass = normalizeSmtpPassword(passRaw);
  const smtpReady = Boolean(id.host && id.user && pass);
  if (!resendKey && !smtpReady) {
    console.warn(
        "paychekProWelcomeEmail: ni PAYCHEK_RESEND_API_KEY ni SMTP complet",
    );
    return;
  }
  if (resendKey && !`${id.mailFrom}`.includes("@")) {
    console.warn("paychekProWelcomeEmail: PAYCHEK_MAIL_FROM invalide");
    return;
  }

  const emails = paychekCheckoutEmailCandidates(session);
  const userSnap = await db.collection("paychek_users").doc(uid).get();
  const u = userSnap.exists ? userSnap.data() : {};
  const to = emails[0] || `${u.email ?? ""}`.trim();
  if (!to.includes("@")) {
    console.warn("paychekProWelcomeEmail: destinataire absent", uid);
    return;
  }

  const firstName = `${u.firstName ?? ""}`.trim();
  const lastName = `${u.lastName ?? ""}`.trim();
  let clientLine =
    firstName || lastName ?
      `${firstName} ${lastName}`.trim() :
      `${u.displayName ?? ""}`.trim();
  if (!clientLine) {
    clientLine = to.split("@")[0] || "Client";
  }

  const locale = await emailI18n.paychekResolveEmailLocale(db, uid, u);
  const periodEndFr = emailI18n.paychekFormatPeriodEndDate(locale, periodEndTs);
  const txnSuffix = paychekProMailTxnSuffix(session);

  const safeClient = escapeHtml(clientLine);
  const safeEnd = escapeHtml(periodEndFr);
  const safeTxn = escapeHtml(txnSuffix);

  let customHtml = "";
  try {
    const tplData = await paychekLoadEmailTemplateOverrides(db);
    customHtml = paychekProAccessHtmlOverride(tplData, locale);
  } catch (e) {
    console.warn("paychekProWelcomeEmail: lecture template Firestore", e);
  }

  const supportHrefEsc = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const privacyHrefEsc = escapeHtml(PAYCHEK_PRIVACY_PAGE_URL_FR);

  const placeholderVars = {
    clientName: safeClient,
    periodEndFr: safeEnd,
    periodEnd: safeEnd,
    validUntil: safeEnd,
    dateFin: safeEnd,
    dateFinAbonnement: safeEnd,
    txnSuffix: safeTxn,
    supportHref: supportHrefEsc,
    privacyHref: privacyHrefEsc,
  };

  const html = customHtml ?
    paychekApplyEmailPlaceholders(customHtml, placeholderVars) :
    buildProAccessConfirmedHtml({
      clientName: safeClient,
      periodEndFr: safeEnd,
      txnSuffix: safeTxn,
    }, locale);

  const text = emailI18n.pack(locale).pro.text(
      clientLine,
      periodEndFr,
      txnSuffix,
  );

  await sendPaychekMailOutbound(
      {
        from: `"Paychek" <${id.mailFrom}>`,
        to,
        bcc: id.mailBcc,
        replyTo: id.mailFrom,
        subject: emailI18n.pack(locale).proSubject,
        text,
        html,
      },
      passRaw,
      JSON.stringify({flow: "proWelcome", uid, sessionId: session.id}),
  );
}

/**
 * @param {Record<string, unknown>} fsData
 * @param {import("firebase-admin/auth").UserRecord} authUser
 */
function greetingFirstNameWelcome(fsData, authUser) {
  const email = `${authUser.email ?? fsData.email ?? ""}`.trim();
  const fsFirst = `${fsData.firstName ?? ""}`.trim();
  const fsDn = `${fsData.displayName ?? ""}`.trim();
  const authDn = `${authUser.displayName ?? ""}`.trim();

  const capitalizeToken = (tok) => {
    const t = `${tok}`.trim();
    if (!t) return "";
    return t.charAt(0).toUpperCase() + t.slice(1).toLowerCase();
  };

  if (fsFirst) {
    const firstTok = fsFirst.split(/\s+/)[0];
    return capitalizeToken(firstTok) || "Trader";
  }
  const dn = fsDn || authDn;
  if (dn) {
    const firstTok = dn.split(/\s+/)[0];
    return capitalizeToken(firstTok) || "Trader";
  }
  if (email.includes("@")) {
    const local = email.split("@")[0];
    const rough = local.replace(/[.+_]+/g, " ").trim();
    const firstTok = rough.split(/\s+/)[0] || local;
    return capitalizeToken(firstTok) || "Trader";
  }
  return "Trader";
}

/**
 * @param {{firstName: string, trialDays: number|string, supportHref: string, privacyHref: string}} v
 * Valeurs déjà échappées pour insertion HTML.
 */
function buildWelcomeSignupHtml(v, locale) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  const s = emailI18n.pack(loc).welcome;
  const fn = v.firstName;
  const td = v.trialDays;
  const sh = v.supportHref;
  const ph = v.privacyHref;
  return `<!DOCTYPE html>
<html lang="${loc}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${escapeHtml(s.htmlTitle)}</title>
    <style>
        body, table, td, a { text-decoration: none; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
        table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
        img { -ms-interpolation-mode: bicubic; border: 0; height: auto; line-height: 100%; outline: none; }
        
        body {
            background-color: #000000;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            width: 100% !important;
        }

        .container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            background-color: #000000;
            border: 1px solid #1a1a1a;
        }

        .header {
            padding: 60px 20px 40px 20px;
            text-align: center;
        }

        .brand-logo {
            font-size: 22px;
            font-weight: 900;
            color: #ffffff;
            letter-spacing: 6px;
            text-transform: uppercase;
        }

        .content {
            padding: 0 50px 50px 50px;
            color: #ffffff;
            line-height: 1.6;
        }

        .welcome-badge {
            border: 1px solid #ffffff;
            color: #ffffff;
            padding: 6px 14px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            display: inline-block;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        h1 {
            color: #ffffff;
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 20px;
            line-height: 1.1;
        }

        .trial-box {
            background-color: #0a0a0a;
            border: 1px solid #c5a059;
            border-radius: 8px;
            padding: 30px;
            margin: 40px 0;
            text-align: center;
        }

        .trial-title {
            color: #c5a059;
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 10px;
        }

        .trial-days {
            font-size: 48px;
            font-weight: 900;
            color: #ffffff;
            line-height: 1;
            margin-bottom: 10px;
        }

        .quote-box {
            border-left: 2px solid #333333;
            padding-left: 20px;
            margin: 40px 0;
            font-style: italic;
            color: #888888;
        }

        .feature-item {
            margin-bottom: 30px;
            display: flex;
            align-items: flex-start;
        }

        .feature-dot {
            color: #c5a059;
            margin-right: 15px;
            font-weight: bold;
        }

        .feature-title {
            color: #ffffff;
            font-size: 14px;
            font-weight: 700;
            text-transform: uppercase;
            margin-bottom: 5px;
            letter-spacing: 1px;
        }

        .feature-desc {
            color: #666666;
            font-size: 14px;
        }

        .cta-container {
            text-align: center;
            margin: 50px 0;
        }

        .btn {
            background-color: #ffffff;
            color: #000000 !important;
            padding: 20px 40px;
            border-radius: 4px;
            font-weight: 800;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 2px;
            display: inline-block;
        }

        .footer {
            padding: 50px;
            text-align: center;
            font-size: 10px;
            color: #333333;
            letter-spacing: 1px;
            text-transform: uppercase;
            border-top: 1px solid #1a1a1a;
        }

        @media screen and (max-width: 600px) {
            .content { padding: 0 25px 50px 25px !important; }
            h1 { font-size: 26px; }
            .trial-days { font-size: 38px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="brand-logo">PAYCHEK</div>
        </div>

        <div class="content">
            <div style="text-align: center;">
                <div class="welcome-badge">${s.badge}</div>
                <h1>${s.h1}</h1>
                <p style="color: #888888; font-size: 16px;">${s.intro(fn)}</p>
            </div>

            <div class="trial-box">
                <div class="trial-title">${s.trialTitle}</div>
                <div class="trial-days">${s.trialDays(td)}</div>
                <p style="color: #888888; font-size: 14px; margin: 0;">${s.trialDesc}</p>
            </div>

            <div class="quote-box">
                "${s.quote}"
            </div>

            <div class="feature-grid">
                <div class="feature-item">
                    <div class="feature-dot">→</div>
                    <div>
                        <div class="feature-title">${s.feat1Title}</div>
                        <div class="feature-desc">${s.feat1Desc}</div>
                    </div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot">→</div>
                    <div>
                        <div class="feature-title">${s.feat2Title}</div>
                        <div class="feature-desc">${s.feat2Desc}</div>
                    </div>
                </div>
            </div>

            <p style="text-align: center; color: #444444; font-size: 11px; text-transform: uppercase; letter-spacing: 1px; margin-top: 50px;">
                ${s.noCard}
            </p>
        </div>

        <div class="footer">
            <p>
                <strong>PAYCHEK LABS</strong> — DISCIPLINE IS FREEDOM.<br><br>
                <a href="${sh}" style="color: #555555;">${s.support}</a> &nbsp;•&nbsp; <a href="${ph}" style="color: #555555;">${s.privacy}</a>
            </p>
        </div>
    </div>
</body>
</html>`;
}

async function resolveWelcomeSignupHtml(db, varsRaw, locale) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  let customHtml = "";
  try {
    const tplData = await paychekLoadEmailTemplateOverrides(db);
    customHtml = paychekWelcomeSignupHtmlOverride(tplData, loc);
  } catch (e) {
    console.warn("welcomeSignupEmail: lecture template Firestore", e);
  }

  const safeFirst = escapeHtml(varsRaw.firstName);
  const safeTrial = escapeHtml(`${varsRaw.trialDays}`);
  const supportHrefEsc = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const privacyHrefEsc = escapeHtml(PAYCHEK_PRIVACY_PAGE_URL_FR);

  return customHtml ?
    paychekApplyEmailPlaceholders(
        paychekNormalizeWelcomeTemplateTokens(customHtml),
        {
          firstName: safeFirst,
          nomUtilisateur: safeFirst,
          trialDays: safeTrial,
          supportHref: supportHrefEsc,
          privacyHref: privacyHrefEsc,
        },
    ) :
    buildWelcomeSignupHtml({
      firstName: safeFirst,
      trialDays: safeTrial,
      supportHref: supportHrefEsc,
      privacyHref: privacyHrefEsc,
    }, loc);
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} passRaw
 * @param {{uid: string, to: string, firstName: string, trialDays: number|string}} payload
 */
async function paychekSendWelcomeSignupEmail(db, passRaw, payload) {
  const id = paychekSmtpIdentity();
  const resendKey = `${paychekResendApiKey.value()}`.trim();
  const pass = normalizeSmtpPassword(passRaw);
  const smtpReady = Boolean(id.host && id.user && pass);
  if (!resendKey && !smtpReady) {
    console.warn(
        "welcomeSignupEmail: ni PAYCHEK_RESEND_API_KEY ni SMTP complet",
    );
    return;
  }
  if (resendKey && !`${id.mailFrom}`.includes("@")) {
    console.warn("welcomeSignupEmail: PAYCHEK_MAIL_FROM invalide");
    return;
  }

  const to = `${payload.to ?? ""}`.trim();
  if (!to.includes("@")) {
    console.warn("welcomeSignupEmail: destinataire absent", payload.uid);
    return;
  }

  const firstNameRaw = `${payload.firstName ?? ""}`.trim() || "Trader";
  const trialDays = payload.trialDays ?? PAYCHEK_WELCOME_TRIAL_DAYS;
  const locale = await emailI18n.paychekResolveEmailLocale(
      db,
      payload.uid,
      null,
  );

  const html = await resolveWelcomeSignupHtml(db, {
    firstName: firstNameRaw,
    trialDays,
  }, locale);

  const text = emailI18n.pack(locale).welcome.text(firstNameRaw, trialDays);

  await sendPaychekMailOutbound(
      {
        from: `"Paychek" <${id.mailFrom}>`,
        to,
        bcc: id.mailBcc,
        replyTo: id.mailFrom,
        subject: emailI18n.pack(locale).welcomeSubject,
        text,
        html,
      },
      passRaw,
      JSON.stringify({flow: "welcomeSignup", uid: payload.uid}),
  );
}

/**
 * E-mail de bienvenue : déclenché à la création / mise à jour de `paychek_users/{uid}`.
 * Attend `firstName` ou `displayName` Auth pour éviter `[Prénom]` littéral (course web).
 */
exports.paychekWelcomeEmailOnSignup = onDocumentWritten(
  {
    document: "paychek_users/{userId}",
    region: "europe-west1",
    secrets: [paychekSmtpPassword],
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;

    const uid = `${event.params.userId ?? ""}`.trim();
    if (!uid) return;

    const fsData = after.data() ?? {};
    if (fsData.welcomeSignupEmailSentAt) return;

    const rawPass = paychekSmtpPassword.value();
    const pass = normalizeSmtpPassword(rawPass);
    const resendKey = `${paychekResendApiKey.value()}`.trim();
    const id = paychekSmtpIdentity();
    const smtpReady = Boolean(id.host && id.user && pass);

    if (!resendKey && !smtpReady) {
      if (!pass) {
        console.error(
            "paychekWelcomeEmailOnSignup: ni PAYCHEK_RESEND_API_KEY ni secret SMTP",
        );
      } else {
        console.error(
            "paychekWelcomeEmailOnSignup: PAYCHEK_SMTP_HOST / USER manquants",
        );
      }
      return;
    }

    /** @type {import("firebase-admin/auth").UserRecord | null} */
    let authUser = null;
    try {
      authUser = await admin.auth().getUser(uid);
    } catch (e) {
      console.warn("paychekWelcomeEmailOnSignup: getUser échoué", uid, e);
      return;
    }

    const fsFirst = `${fsData.firstName ?? ""}`.trim();
    const fsDn = `${fsData.displayName ?? ""}`.trim();
    const authDn = `${authUser.displayName ?? ""}`.trim();
    const before = event.data?.before;
    const isCreate = !before?.exists;
    if (isCreate && !fsFirst && !fsDn && !authDn) {
      return;
    }

    const to = `${authUser.email ?? fsData.email ?? ""}`.trim();
    if (!to.includes("@")) {
      console.warn("paychekWelcomeEmailOnSignup: pas d’e-mail pour", uid);
      return;
    }

    const freshSnap = await after.ref.get();
    const freshData = freshSnap.data() ?? fsData;
    const firstName = greetingFirstNameWelcome(freshData, authUser);
    const db = admin.firestore();

    try {
      await paychekSendWelcomeSignupEmail(db, rawPass, {
        uid,
        to,
        firstName,
        trialDays: PAYCHEK_WELCOME_TRIAL_DAYS,
      });
      await after.ref.set(
          {welcomeSignupEmailSentAt: admin.firestore.FieldValue.serverTimestamp()},
          {merge: true},
      );
    } catch (err) {
      console.error("paychekWelcomeEmailOnSignup: envoi", err);
    }
  },
);

/** @param {string} secretKey */
function paychekStripeKeyMode(secretKey) {
  let k = `${secretKey ?? ""}`.trim();
  if (k.charCodeAt(0) === 0xfeff) k = k.slice(1).trim();
  if ((k.startsWith('"') && k.endsWith('"')) || (k.startsWith("'") && k.endsWith("'"))) {
    k = k.slice(1, -1).trim();
  }
  if (k.startsWith("sk_test_") || k.startsWith("rk_test_")) return "test";
  if (k.startsWith("sk_live_") || k.startsWith("rk_live_")) return "live";
  return "unknown";
}

/** @param {string} secretKey */
function paychekStripeKeyModeHint(secretKey) {
  const mode = paychekStripeKeyMode(secretKey);
  if (mode !== "unknown") return mode;
  const k = `${secretKey ?? ""}`.trim().slice(0, 12);
  return `inconnu (début clé: ${k || "vide"} — attendu sk_test_/sk_live_)`;
}

/**
 * @param {import("stripe").Stripe.Checkout.Session} session
 * @param {Set<string>} emails
 */
function paychekCheckoutSessionMatchesEmails(session, emails) {
  const candidates = paychekCheckoutEmailCandidates(session);
  for (const c of candidates) {
    if (emails.has(c) || emails.has(c.toLowerCase())) return true;
  }
  return false;
}

/**
 * @param {import("stripe").Stripe} stripe
 * @param {import("stripe").Stripe.Checkout.Session} session
 */
async function paychekStripePeriodFromSession(stripe, session) {
  /** @type {FirebaseFirestore.Timestamp | null} */
  let currentPeriodEnd = null;
  /** @type {FirebaseFirestore.Timestamp | null} */
  let proSinceUtc = null;

  const applySub = (sub) => {
    const p = paychekPeriodFromStripeSubscription(sub, proSinceUtc);
    currentPeriodEnd = p.currentPeriodEnd || currentPeriodEnd;
    proSinceUtc = p.proSinceUtc;
  };

  const subRef = session.subscription;
  if (subRef && typeof subRef === "object" && !Array.isArray(subRef)) {
    applySub(/** @type {import("stripe").Stripe.Subscription} */ (subRef));
  } else if (typeof subRef === "string") {
    try {
      const sub = await stripe.subscriptions.retrieve(subRef);
      applySub(sub);
    } catch (e) {
      console.warn("paychekStripe: subscription period", e);
    }
  }

  if (!currentPeriodEnd && session.id) {
    try {
      const full = await stripe.checkout.sessions.retrieve(session.id, {
        expand: ["subscription"],
      });
      const exp = full.subscription;
      if (exp && typeof exp === "object" && !Array.isArray(exp)) {
        applySub(/** @type {import("stripe").Stripe.Subscription} */ (exp));
      } else if (typeof exp === "string") {
        const sub = await stripe.subscriptions.retrieve(exp);
        applySub(sub);
      }
    } catch (e) {
      console.warn("paychekStripe: session expand subscription", e);
    }
  }

  if (!proSinceUtc) {
    const sc = session.created;
    if (typeof sc === "number" && sc > 0) {
      proSinceUtc = admin.firestore.Timestamp.fromMillis(sc * 1000);
    } else {
      proSinceUtc = admin.firestore.Timestamp.fromMillis(Date.now());
    }
  }
  return {currentPeriodEnd, proSinceUtc};
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {import("stripe").Stripe} stripe
 * @param {string} uid
 * @param {import("stripe").Stripe.Checkout.Session} session
 * @param {unknown} periodEndHint
 * @return {Promise<FirebaseFirestore.Timestamp | null>}
 */
async function paychekResolveProEmailPeriodEndTs(db, stripe, uid, session, periodEndHint) {
  let ts = paychekCoerceFirestoreTimestamp(periodEndHint);
  if (ts) return ts;

  try {
    const ent = await db.collection("subscriber_entitlements").doc(uid).get();
    if (ent.exists) {
      ts = paychekCoerceFirestoreTimestamp(ent.data()?.currentPeriodEnd);
      if (ts) return ts;
    }
  } catch (e) {
    console.warn("paychekProEmail: entitlements", e);
  }

  try {
    const user = await db.collection("paychek_users").doc(uid).get();
    if (user.exists) {
      ts = paychekCoerceFirestoreTimestamp(
          user.data()?.subscriptionCurrentPeriodEnd,
      );
      if (ts) return ts;
    }
  } catch (e) {
    console.warn("paychekProEmail: paychek_users", e);
  }

  if (stripe && session) {
    const p = await paychekStripePeriodFromSession(stripe, session);
    if (p.currentPeriodEnd) return p.currentPeriodEnd;
  }

  return null;
}

/** Aligné sur `kPaychekTrialDuration` (Dart) — 7 j après inscription si pas d’override. */
const PAYCHEK_TRIAL_MS = 7 * 24 * 60 * 60 * 1000;

/**
 * @param {FirebaseFirestore.Timestamp} ts
 * @return {number}
 */
function paychekWebProLicenseEndUtcMillis(ts) {
  const d = ts.toDate();
  return Date.UTC(
      d.getUTCFullYear() + 1,
      d.getUTCMonth(),
      d.getUTCDate(),
      d.getUTCHours(),
      d.getUTCMinutes(),
      d.getUTCSeconds(),
      d.getUTCMilliseconds(),
  );
}

/**
 * Millisecondes restantes dans la fenêtre d’essai « accès plein » si le compte n’est pas encore Pro.
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @return {Promise<number>}
 */
async function paychekTrialRemainderMsForUid(db, uid) {
  const snap = await db.collection("paychek_users").doc(uid).get();
  if (!snap.exists) return 0;
  const d = snap.data() || {};
  const tier = `${d.subscriptionTier || ""}`.trim().toLowerCase();
  if (tier === "pro" || d.isPremium === true) return 0;

  const created = d.createdAt;
  if (!created || typeof created.toMillis !== "function") return 0;
  const createdMs = created.toMillis();

  let trialEndMs;
  const ov = d.trialFreemiumOverrideUntil;
  if (ov && typeof ov.toMillis === "function") {
    trialEndMs = ov.toMillis();
  } else {
    trialEndMs = createdMs + PAYCHEK_TRIAL_MS;
  }

  const nowMs = Date.now();
  if (nowMs >= trialEndMs) return 0;
  return trialEndMs - nowMs;
}

/**
 * Prolonge la fin de période Pro du temps d’essai non consommé (ex. achat Pro au 3ᵉ jour → +4 j).
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {FirebaseFirestore.Timestamp | null} currentPeriodEnd
 * @param {FirebaseFirestore.Timestamp | null} proSinceUtc
 * @return {Promise<FirebaseFirestore.Timestamp | null>}
 */
async function paychekApplyTrialRemainderToPeriodEnd(
    db,
    uid,
    currentPeriodEnd,
    proSinceUtc,
) {
  const remainderMs = await paychekTrialRemainderMsForUid(db, uid);
  if (remainderMs <= 0) return currentPeriodEnd;
  console.log(
      "paychekStripe: crédit essai appliqué (ms restantes)",
      uid,
      remainderMs,
  );

  if (currentPeriodEnd && typeof currentPeriodEnd.toMillis === "function") {
    return admin.firestore.Timestamp.fromMillis(
        currentPeriodEnd.toMillis() + remainderMs,
    );
  }
  if (proSinceUtc && typeof proSinceUtc.toMillis === "function") {
    const baseMs = paychekWebProLicenseEndUtcMillis(proSinceUtc);
    return admin.firestore.Timestamp.fromMillis(baseMs + remainderMs);
  }
  return currentPeriodEnd;
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {object} opts
 * @return {Promise<boolean>} false si déjà traité (idempotence session)
 */
async function paychekGrantProEntitlement(db, uid, opts) {
  const {
    stripeCheckoutSessionId = null,
    stripeCustomerId = null,
    stripeMode = null,
    stripeSubscriptionId = null,
    proSinceUtc,
    currentPeriodEnd = null,
    provider = "stripe",
  } = opts;

  const entRef = db.collection("subscriber_entitlements").doc(uid);
  let prevSnapForMerge = null;
  if (stripeCheckoutSessionId) {
    const prev = await entRef.get();
    prevSnapForMerge = prev;
    if (
      prev.exists &&
      prev.data() &&
      prev.data().stripeCheckoutSessionId === stripeCheckoutSessionId
    ) {
      return false;
    }
  }

  let mergedPeriodEnd = currentPeriodEnd;
  if (
      currentPeriodEnd &&
      typeof currentPeriodEnd.toMillis === "function"
  ) {
    const snap =
      prevSnapForMerge || (await entRef.get());
    const prevEnd =
      snap.exists &&
      snap.data() &&
      snap.data().currentPeriodEnd &&
      typeof snap.data().currentPeriodEnd.toMillis === "function" ?
        snap.data().currentPeriodEnd :
        null;
    if (prevEnd) {
      const nextMs = currentPeriodEnd.toMillis();
      const prevMs = prevEnd.toMillis();
      mergedPeriodEnd = admin.firestore.Timestamp.fromMillis(
          Math.max(prevMs, nextMs),
      );
    }
  }

  const batch = db.batch();
  batch.set(
      entRef,
      {
        active: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        provider,
        proSinceUtc:
          proSinceUtc ||
          admin.firestore.Timestamp.fromMillis(Date.now()),
        ...(stripeCheckoutSessionId ?
          {stripeCheckoutSessionId} :
          {}),
        ...(stripeCustomerId ? {stripeCustomerId} : {}),
        ...(stripeMode ? {stripeMode} : {}),
        ...(stripeSubscriptionId ? {stripeSubscriptionId} : {}),
        ...(mergedPeriodEnd ? {currentPeriodEnd: mergedPeriodEnd} : {}),
      },
      {merge: true},
  );

  const effectiveProSince =
    proSinceUtc ||
    admin.firestore.Timestamp.fromMillis(Date.now());
  const userPatch = {
    subscriptionTier: "pro",
    isPremium: true,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    subscriptionTierUpdatedAt:
      admin.firestore.FieldValue.serverTimestamp(),
    subscriptionProSinceUtc: effectiveProSince,
  };
  if (mergedPeriodEnd) {
    userPatch.subscriptionCurrentPeriodEnd = mergedPeriodEnd;
  }
  if (provider === "stripe") {
    userPatch.paymentMethod = "stripe";
  }
  if (stripeCustomerId) {
    userPatch.stripeCustomerId = stripeCustomerId;
  }
  batch.set(db.collection("paychek_users").doc(uid), userPatch, {merge: true});

  await batch.commit();
  return true;
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {import("stripe").Stripe} stripe
 * @param {string} uid
 * @param {import("stripe").Stripe.Checkout.Session} session
 */
async function paychekGrantProFromCheckoutSession(db, stripe, uid, session) {
  let {currentPeriodEnd, proSinceUtc} =
    await paychekStripePeriodFromSession(stripe, session);
  currentPeriodEnd = await paychekApplyTrialRemainderToPeriodEnd(
      db,
      uid,
      currentPeriodEnd,
      proSinceUtc,
  );
  const granted = await paychekGrantProEntitlement(db, uid, {
    stripeCheckoutSessionId: session.id,
    stripeCustomerId:
      typeof session.customer === "string" ?
        session.customer :
        session.customer?.id || null,
    stripeMode: session.mode || null,
    stripeSubscriptionId:
      typeof session.subscription === "string" ?
        session.subscription :
        null,
    proSinceUtc,
    currentPeriodEnd,
  });
  if (granted) {
    console.log("paychekStripe: abonnement activé", uid, session.id);
  }
  return granted;
}

/**
 * @param {import("stripe").Stripe} stripe
 * @param {import("stripe").Stripe.Subscription} sub
 * @param {string|null} stripeCustomerId
 */
async function paychekGrantProFromSubscription(
    db,
    uid,
    sub,
    stripeCustomerId,
) {
  let currentPeriodEnd = sub.current_period_end ?
    admin.firestore.Timestamp.fromMillis(sub.current_period_end * 1000) :
    null;
  const proSinceUtc = sub.current_period_start ?
    admin.firestore.Timestamp.fromMillis(sub.current_period_start * 1000) :
    admin.firestore.Timestamp.fromMillis(Date.now());
  currentPeriodEnd = await paychekApplyTrialRemainderToPeriodEnd(
      db,
      uid,
      currentPeriodEnd,
      proSinceUtc,
  );
  const customerId =
    stripeCustomerId ||
    (typeof sub.customer === "string" ? sub.customer : sub.customer?.id) ||
    null;
  return paychekGrantProEntitlement(db, uid, {
    stripeCustomerId: customerId,
    stripeSubscriptionId: sub.id,
    proSinceUtc,
    currentPeriodEnd,
  });
}

/**
 * Cherche un paiement / abonnement Stripe pour lier le compte Firebase.
 * @param {import("stripe").Stripe} stripe
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {string} email
 * @param {string} stripeKeyMode
 * @param {string} stripeSecretKeyRedacted — pour diagnostic (préfixe seulement)
 * @return {Promise<{active: boolean, reason: string, stripeKeyMode: string}>}
 */
async function paychekSyncStripeEntitlementForUser(
    stripe,
    db,
    uid,
    email,
    stripeKeyMode,
    stripeSecretKeyRedacted,
) {
  const fail = (reason) => ({active: false, reason, stripeKeyMode});
  const ok = (reason) => ({active: true, reason, stripeKeyMode});

  const uidEsc = paychekEscapeStripeSearchValue(uid);
  try {
    const found = await stripe.checkout.sessions.search({
      query: `client_reference_id:'${uidEsc}' AND status:'complete'`,
      limit: 5,
    });
    for (const session of found.data) {
      if (paychekCheckoutSessionIsPaid(session)) {
        await paychekGrantProFromCheckoutSession(db, stripe, uid, session);
        return ok("checkout_client_reference_id");
      }
    }
  } catch (e) {
    console.warn("paychekSyncStripe: checkout uid search", e);
  }

  const emails = new Set();
  const em = `${email ?? ""}`.trim();
  if (em) {
    emails.add(em);
    emails.add(em.toLowerCase());
  }

  for (const lookup of emails) {
    const emailEsc = paychekEscapeStripeSearchValue(lookup);
    try {
      const byEmail = await stripe.checkout.sessions.search({
        query: `customer_details.email:'${emailEsc}' AND status:'complete'`,
        limit: 10,
      });
      for (const session of byEmail.data) {
        if (paychekCheckoutSessionIsPaid(session)) {
          await paychekGrantProFromCheckoutSession(db, stripe, uid, session);
          return ok("checkout_email");
        }
      }
    } catch (e) {
      console.warn("paychekSyncStripe: checkout email search", e);
    }
  }

  for (const lookup of emails) {
    let customers;
    try {
      customers = await stripe.customers.list({email: lookup, limit: 5});
    } catch (e) {
      console.warn("paychekSyncStripe: customers.list", e);
      continue;
    }
    for (const customer of customers.data) {
      let subs;
      try {
        subs = await stripe.subscriptions.list({
          customer: customer.id,
          status: "all",
          limit: 20,
        });
      } catch (e) {
        console.warn("paychekSyncStripe: subscriptions.list", e);
        continue;
      }
      for (const sub of subs.data) {
        if (sub.status === "active" || sub.status === "trialing") {
          await paychekGrantProFromSubscription(
              db,
              uid,
              sub,
              customer.id,
          );
          console.log("paychekSyncStripe: actif via subscription", uid, sub.id);
          return ok("subscription_active");
        }
      }

      let sessions;
      try {
        sessions = await stripe.checkout.sessions.list({
          customer: customer.id,
          limit: 15,
        });
      } catch (e) {
        console.warn("paychekSyncStripe: checkout.sessions.list", e);
        continue;
      }
      for (const session of sessions.data) {
        if (
          session.status === "complete" &&
          paychekCheckoutSessionIsPaid(session)
        ) {
          await paychekGrantProFromCheckoutSession(db, stripe, uid, session);
          console.log(
              "paychekSyncStripe: actif via checkout client",
              uid,
              session.id,
          );
          return ok("checkout_customer");
        }
      }
    }
  }

  try {
    const recent = await stripe.checkout.sessions.list({limit: 50});
    for (const session of recent.data) {
      if (!paychekCheckoutSessionMatchesEmails(session, emails)) continue;
      if (
        session.status === "complete" &&
        paychekCheckoutSessionIsPaid(session)
      ) {
        await paychekGrantProFromCheckoutSession(db, stripe, uid, session);
        return ok("checkout_recent_list");
      }
    }
  } catch (e) {
    console.warn("paychekSyncStripe: recent checkout list", e);
  }

  const modeLabel =
    stripeKeyMode === "test" ?
      "test (sk_test_…)" :
      stripeKeyMode === "live" ?
        "live (sk_live_…)" :
        paychekStripeKeyModeHint(stripeSecretKeyRedacted);

  const modeFailureHint =
    stripeKeyMode === "unknown" ?
      " Corrige FIREBASE_SECRET PAYCHEK_STRIPE_SECRET_KEY : Secret key " +
      "complète sk_test_… ou sk_live_… (Developers → API keys), " +
      "pas pk_…, pas whsec_…. Republie adminSyncPaychekStripeEntitlement. " :
      "";

  if (!em) {
    return fail(
        "Aucun e-mail sur paychek_users. Le checkout Stripe doit utiliser " +
        `le même e-mail que Firebase. Mode clé : ${modeLabel}.${modeFailureHint}`,
    );
  }
  return fail(
      `Aucun paiement Stripe en mode ${modeLabel} pour « ${em} » ` +
      "(50 derniers checkouts scannés). Dans Stripe Dashboard (même mode " +
      "test/live que la clé), ouvre Paiements → vérifie l’e-mail du client. " +
      "S’il est différent, refais un paiement depuis l’app connectée avec " +
      "cet e-mail ou passe le compte en Pro à la main." +
      modeFailureHint,
  );
}

/**
 * @param {import("stripe").Stripe} stripe
 * @param {import("stripe").Stripe.Event} event
 * @param {string} passRaw secret SMTP (vide si Resend seul)
 */
async function paychekHandleStripeEvent(stripe, event, passRaw) {
  if (event.type !== "checkout.session.completed") return;

  const session = /** @type {import("stripe").Stripe.Checkout.Session} */ (
    event.data.object
  );
  const db = admin.firestore();
  const uid = await paychekResolveUidFromCheckoutSession(db, session, stripe);
  if (!uid) {
    console.warn(
        "paychekStripeWebhook: uid introuvable (client_reference_id + email)",
        session.id,
        paychekCheckoutEmailCandidates(session),
    );
    return;
  }

  if (!paychekCheckoutSessionIsPaid(session)) {
    console.warn(
        "paychekStripeWebhook: session non payée",
        session.id,
        session.payment_status,
    );
    return;
  }

  const granted = await paychekGrantProFromCheckoutSession(db, stripe, uid, session);
  if (!granted) return;

  try {
    const uSnap = await db.collection("paychek_users").doc(uid).get();
    const periodEnd = await paychekResolveProEmailPeriodEndTs(
        db,
        stripe,
        uid,
        session,
        uSnap.data()?.subscriptionCurrentPeriodEnd,
    );
    await paychekSendProAccessConfirmedEmail(db, passRaw, uid, session, periodEnd);
  } catch (e) {
    console.warn("paychekStripeWebhook: e-mail accès Pro", e);
  }
}

function paychekNormalizeCoachLocale(raw) {
  const lc = `${raw ?? ""}`.trim().toLowerCase();
  if (["fr", "en", "es", "de", "pt", "ko"].includes(lc)) return lc;
  return "en";
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

  return locale === "fr" ? fr : en;
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
  const q = `${question ?? ""}`.toLowerCase();
  const stop = new Set([
    "quelle", "quel", "quoi", "comment", "combien", "quand", "performance",
    "rendement", "winrate", "bilan", "trade", "trades", "mon", "ma", "mes",
  ]);
  const low = /moins de|peu de|faible|bas\b|low\b|moins\b/.test(q);
  const high = /plus de|beaucoup de|élevé|eleve|high\b|fort\b|plus\b/.test(q);
  const polarity = low && !high ? "low" : (high && !low ? "high" : "neutral");

  const metricKeys = [
    "sommeil", "sleep", "focus", "confiance", "confidence", "peur", "fear",
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

function paychekAiCoachIsMentalPerformanceQuestion(question) {
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
  if (/c.?est quoi|c quoi|quelle psycho|quel psycho|quoi comme psycho|what.{0,16}psycho/.test(q)) {
    if (/trade|tp\b|take profit|gagnant|gain|perte|clotur|position|retourn|lacher|lâcher/.test(q)) {
      return q.length >= 50;
    }
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

function paychekAiCoachIsTradeListQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (/pourquoi|why|comment se fait|d'où vient|d'ou vient|what caused/.test(q)) return false;
  if (paychekAiCoachIsCoachingStoryQuestion(question)) return false;
  if (/quel(le)?s?\s+trade|quels\s+trades|montre.{0,30}trade|liste.{0,30}trade|affiche.{0,30}trade|donne.{0,30}trade|voir.{0,30}trade|quels trades.{0,20}(tag|fomo|tilt|revenge|psycho)/.test(q)) {
    return true;
  }
  if (/\btrade/.test(q) && /fomo|tilt|revenge|peur|fear|frustr|cupidit|greed|stress|overtrade/.test(q)) {
    return /quel|quels|montre|liste|affiche|donne|voir/.test(q);
  }
  return false;
}

function paychekAiCoachIsGeneralPerformanceQuestion(question) {
  const q = `${question ?? ""}`.toLowerCase();
  if (/checklist|analyse|analysis|plan d.?analyse|strat(é|e)gie|strategy|état mental|etat mental|mental state|fomo|tilt|peur|sommeil|non.?respect/.test(q)) {
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
  const q = `${question ?? ""}`.toLowerCase();
  if (!/strat(é|e)gie|strategy|\bsetup\b|mon setup|ma stratégie|ma strategie|my strategy/.test(q)) {
    return false;
  }
  if (/performance|winrate|pnl|bilan|non.?respect|enregistr|audit|combien|sur mes trades|discipline/.test(q)) {
    return false;
  }
  if (/aujourd'hui|aujourdhui|today|du jour|ce matin|this morning|this evening/.test(q)) {
    return true;
  }
  return /dis.?moi|montre|quelle est|quel est|what is|show me|ma stratégie|ma strategie|mon setup|my strategy|la stratégie|la strategie/.test(q);
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

function paychekAiCoachResolveFocus(question, priorFocus) {
  const q = `${question ?? ""}`.toLowerCase();
  if (paychekAiCoachIsFocusedTopicFollowUp(question, priorFocus)) return priorFocus;
  if (paychekAiCoachIsPricingQuestion(question)) return "app_pricing";
  if (paychekAiCoachIsTodayChecklistQuestion(question)) return "checklist_today";
  if (paychekAiCoachIsTodayAnalysisQuestion(question)) return "analysis_today";
  if (paychekAiCoachIsTodayStrategyQuestion(question)) return "strategy_today";
  if (paychekAiCoachIsMonthCalendarQuestion(question)) return "calendar_month";
  if (paychekAiCoachIsTodayCalendarQuestion(question)) return "calendar_today";
  if (paychekAiCoachIsPerformanceLensQuestion(question)) return "performance_lens";
  if (paychekAiCoachIsPerformanceOvertradingQuestion(question)) return "performance_overtrading";
  if (paychekAiCoachIsGeneralPerformanceQuestion(question)) return "performance_summary";
  if (paychekAiCoachIsTodayMentalStateQuestion(question)) return "mental_today";
  if (paychekAiCoachShouldUseHelpCenter(question)) return "app_help";
  if (/(combien|nombre|nb|how many).{0,25}trade|trade.{0,25}(combien|nombre|nb|how many)/.test(q)) {
    return "trade_count";
  }
  if (paychekAiCoachIsCoachingStoryQuestion(question)) return "coaching_story";
  if (paychekAiCoachIsTradeListQuestion(question)) return "trade_list";
  if (paychekAiCoachIsStoryFollowUpQuestion(question)) return "story_followup";
  if (paychekAiCoachIsMentalPerformanceQuestion(question)) return "mental_emotion";
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

function paychekAiCoachNarrativeFormat(locale) {
  if (locale === "fr") {
    return "FORMAT OBLIGATOIRE: intro 2-3 phrases (pattern psycho + UNE question de cadrage) puis EXACTEMENT 4 lignes « 1. … 2. … 3. … 4. … » — chaque ligne ENTIÈRE sur une seule ligne, format « N. (Biais) texte ». " +
      "Interdit: « (Biais) » sans numéro sur la ligne, numéro seul, paragraphes non numérotés, inventaire trades journal. Max 200 mots. ";
  }
  return "MANDATORY FORMAT: 2-3 sentence intro (pattern + one framing question) then exactly 4 full single lines \"1.\"–\"4.\" each starting with \"N. (Bias) text\". " +
    "Forbidden: bias on its own line, number alone on a line, unnumbered blocks, journal trade list. Max 200 words. ";
}

function paychekAiCoachStoryFollowUpFormat(locale) {
  if (locale === "fr") {
    return "FORMAT: 1 phrase d'intro liée au récit (priorTurns), puis 5 lignes « 1. » à « 5. » — chaque ligne complète sur UNE seule ligne. Max 180 mots. ";
  }
  return "FORMAT: 1 intro sentence from priorTurns, then 5 full single lines \"1.\" to \"5.\". Max 180 words. ";
}

function paychekAiCoachPricingFormat(locale) {
  if (locale === "fr") {
    return "FORMAT: intro 1-2 phrases adaptée à la question, puis 4-5 lignes « 1. » à « 5. » sur une seule ligne. Utilise pricingContext (prix US$, essai 7j, Lite vs Pro). Max 160 mots. ";
  }
  return "FORMAT: 1-2 sentence intro tailored to the question, then 4-5 single lines \"1.\"–\"5.\". Use pricingContext JSON. Max 160 words. ";
}

function paychekAiCoachMentalTodayFormat(locale) {
  if (locale === "fr") {
    return "FORMAT: intro 1-2 phrases adaptée à la question, puis 4 lignes « 1. » à « 4. » sur une seule ligne. Utilise mentalTodayContext (score, sections, émotions). Max 180 mots. ";
  }
  return "FORMAT: 1-2 sentence intro, then 4 single lines \"1.\"–\"4.\". Use mentalTodayContext JSON. Max 180 words. ";
}

function paychekAiCoachChecklistTodayFormat(locale) {
  if (locale === "fr") {
    return "FORMAT: 1 phrase d'intro courte, puis 4 lignes « 1. » à « 4. » sur une seule ligne. Utilise checklistTodayContext (items cochés/non cochés du jour). Max 160 mots. ";
  }
  return "FORMAT: 1 short intro sentence, then 4 single lines \"1.\"–\"4.\". Use checklistTodayContext (today's checked/unchecked items). Max 160 words. ";
}

function paychekAiCoachAnalysisTodayFormat(locale) {
  if (locale === "fr") {
    return "FORMAT: 1 phrase d'intro courte, puis 4 lignes « 1. » à « 4. » sur une seule ligne. Utilise analysisTodayContext (actif, bias, niveaux, confluence). Max 170 mots. ";
  }
  return "FORMAT: 1 short intro sentence, then 4 single lines \"1.\"–\"4.\". Use analysisTodayContext (asset, bias, levels, confluence). Max 170 words. ";
}

function paychekAiCoachStrategyTodayFormat(locale) {
  if (locale === "fr") {
    return "FORMAT: 1 phrase d'intro courte, puis 4 lignes « 1. » à « 4. » sur une seule ligne. Utilise strategyTodayContext (setup, signal, risque, règles). Max 170 mots. ";
  }
  return "FORMAT: 1 short intro sentence, then 4 single lines \"1.\"–\"4.\". Use strategyTodayContext (setup, signal, risk, rules). Max 170 words. ";
}

function paychekAiCoachCalendarTodayFormat(locale) {
  if (locale === "fr") {
    return "FORMAT: 1 intro courte, puis 4 lignes « 1. » à « 4. ». Utilise calendarTodayContext (PnL/trades jour, checklist/mental/setup, monthProgress). Max 170 mots. ";
  }
  return "FORMAT: 1 short intro, then 4 lines \"1.\"–\"4.\". Use calendarTodayContext. Max 170 words. ";
}

function paychekAiCoachCalendarMonthFormat(locale) {
  if (locale === "fr") {
    return "FORMAT: 1 intro courte, puis 4-5 lignes « 1. » à « 5. ». Utilise calendarMonthContext (PnL mois, objectif, jours verts/rouges). Max 180 mots. ";
  }
  return "FORMAT: 1 short intro, then 4-5 lines. Use calendarMonthContext. Max 180 words. ";
}

function paychekAiCoachFocusInstructions(locale, focus) {
  const narrativeFmt = paychekAiCoachNarrativeFormat(locale);
  const storyFollowFmt = paychekAiCoachStoryFollowUpFormat(locale);
  const pricingFmt = paychekAiCoachPricingFormat(locale);
  const mentalTodayFmt = paychekAiCoachMentalTodayFormat(locale);
  const checklistTodayFmt = paychekAiCoachChecklistTodayFormat(locale);
  const analysisTodayFmt = paychekAiCoachAnalysisTodayFormat(locale);
  const strategyTodayFmt = paychekAiCoachStrategyTodayFormat(locale);
  const calendarTodayFmt = paychekAiCoachCalendarTodayFormat(locale);
  const calendarMonthFmt = paychekAiCoachCalendarMonthFormat(locale);
  const fr = {
    full: "FOCUS=audit global. Réponse personnalisée selon les chiffres JSON. " +
      "Tu peux structurer, mais ne répète jamais un script générique. " +
      "Priorise: écarts discipline, cause technique vs psycho, 3 actions concrètes.",
    checklist: "FOCUS=checklist discipline sur les TRADES (enregistrée / non-respect), PAS la page Checklist du jour. " +
      "Ne fais pas un audit complet des 4 piliers. Pas de titre BILAN PAYCHEK. " +
      "INTERDIT: inventer une checklist générique avant/pendant/après trade si checklistTodayContext est absent. " +
      "Ton coach direct, 120-180 mots, basé sur recordedDiscipline.checklist et nonRespectCount.checklistItems.",
    analysis: "FOCUS=plan d'analyse discipline sur les TRADES (enregistrée / non-respect), PAS la page Analyse du jour. " +
      "Ne fais pas un audit complet des 4 piliers. Pas de titre BILAN PAYCHEK. " +
      "INTERDIT: inventer une analyse générique HTF/structure si analysisTodayContext est absent. " +
      "Ton coach direct, 120-180 mots, basé sur recordedDiscipline.analysisPlan et nonRespectCount.analysisItems.",
    strategy: "FOCUS=stratégie discipline sur les TRADES (enregistrée / non-respect), PAS la page Stratégie du jour. " +
      "Ne fais pas un audit complet des 4 piliers. Pas de titre BILAN PAYCHEK. " +
      "INTERDIT: inventer une stratégie générique si strategyTodayContext est absent. " +
      "Ton coach direct, 120-180 mots, basé sur recordedDiscipline.strategy et nonRespectCount.strategyItems.",
    mental: "FOCUS=état mental uniquement. Réponds seulement sur l'état mental. " +
      "Ne fais pas un audit complet des 4 piliers. Pas de titre BILAN PAYCHEK. " +
      "Ton coach direct, 120-220 mots.",
    mental_emotion: "FOCUS=performance liée à un curseur/émotion de l'état mental PAYCHEK. " +
      "Utilise mentalEmotionFocus + mentalStateCoverage (tradesWithEtatMental, split médiane). " +
      "onEmotionDays = trades niveau bas (ou émotion matchée), otherEtatDays = niveau haut. " +
      "Si onEmotionDays.trades=0 mais tradesWithEtatMental>0, explique-le clairement (seuil médiane, curseur manquant) " +
      "et analyse quand même otherEtatDays + couverture. Réponse complète, naturelle, coach réaliste. " +
      "Pas de BILAN PAYCHEK global.",
    coach: "FOCUS=coaching libre (conseils, amélioration, mindset). " +
      "Réponse naturelle et complète. Si mentalEmotionFocus est dans le JSON, appuie-toi dessus. " +
      "Pas de template rigide, pas de BILAN PAYCHEK automatique.",
    non_respect: "FOCUS=non-respect et pertes. Utilise nonRespectImpact.topViolations (label, pillar, count, lossRateWhenViolatedPercent, pnlSumWhenViolated). " +
      "Liste les 3-6 points les plus liés aux pertes avec chiffres. Pour chaque point, explique en 1-2 phrases la psychologie trader typique (FOMO, revenge, fatigue, etc.) — hypothèse coach, pas diagnostic médical. " +
      "Réponse complète, naturelle, priorise stratégie/analyse/checklist/mental selon les chiffres. Pas de BILAN PAYCHEK global.",
    story_followup: "FOCUS=suite après coaching_story — comment gérer la psycho du récit (revenge, FOMO, etc.). " +
      storyFollowFmt +
      "Lis conversation.priorTurns + paychekUiSteps. 5 actions PAYCHEK personnalisées (TAG Revenge/TILT si pertinent, Checklist, État mental, ⚙ Session, revue trades tagués). Pas d'audit discipline.",
    coaching_story: "FOCUS=récit de trade / session + coaching psycho (gain virtuel, TP non touché, refus de couper, FOMO, revenge, etc.). " +
      narrativeFmt +
      "Utilise coachingStoryFocus.themes + coachingStoryFocus.coachInstructions. " +
      "INTERDIT: liste trades journal (paire/date/PnL), audit discipline, ENREGISTRÉ/NON ENREGISTRÉ, winrate global. " +
      "Tag Revenge/Cupidité: une phrase max si pertinent.",
    psychology_why: "FOCUS=pourquoi une émotion/tag (ex. FOMO). " + narrativeFmt +
      "Intro + question, puis 4 causes numérotées. Si psychologyWhyFocus.tagStats: 1 phrase chiffres (WR, PnL). " +
      "Sinon taguer sur Ajouter trade. Ligne 5. optionnelle « Entraînement PAYCHEK » modeste (routine 4 semaines). " +
      "Pas de BILAN PAYCHEK global, pas de sermon recordedDiscipline.",
    app_pricing: "FOCUS=tarifs app PAYCHEK (pas prix de trade). " + pricingFmt +
      "Utilise pricingContext + pricingContext.coachInstructions. Adapte à la question (essai ? mensuel ? Pro ?). " +
      "Prix officiels depuis JSON (monthlyUsd, quarterlyUsd, annualUsd). INTERDIT « consulte le site » sans chiffres. Pas d'audit trading.",
    mental_today: "FOCUS=état mental DU JOUR (page État mental), pas audit discipline. " + mentalTodayFmt +
      "Utilise mentalTodayContext + coachInstructions. Adapte à la question. " +
      "Si responseRules.style=mental_today_brief_followup: max 90 mots, réponds UNIQUEMENT à la suite (priorTurns), pas d'audit. " +
      "INTERDIT: winrate global, ENREGISTRÉ/NON ENREGISTRÉ, X/70 trades, recordedDiscipline. Si hasDataToday=false → fillHintPath.",
    checklist_today: "FOCUS=checklist DU JOUR (page Checklist PAYCHEK), pas audit discipline des trades. " + checklistTodayFmt +
      "Utilise checklistTodayContext + coachInstructions. Cite LEURS items (checked true/false). " +
      "Si responseRules.style=checklist_today_brief_followup: max 90 mots, réponds UNIQUEMENT via priorTurns (ex. point le plus important). " +
      "INTERDIT: modèle générique avant/pendant/après trade, winrate, X/70 trades, ENREGISTRÉ/NON ENREGISTRÉ. Si hasItemsDueToday=false → fillHintPath.",
    analysis_today: "FOCUS=analyse DU JOUR (page Analyse / Mon Analyse), pas audit discipline des trades. " + analysisTodayFmt +
      "Utilise analysisTodayContext + coachInstructions. Cite LEUR actif, bias, tendance, phase, confiance, confluence, S/R. " +
      "Si responseRules.style=analysis_today_brief_followup: max 90 mots, réponds UNIQUEMENT via priorTurns. " +
      "INTERDIT: modèle générique d'analyse, winrate, X/70 trades, ENREGISTRÉ/NON ENREGISTRÉ. Si hasDataToday=false → fillHintPath.",
    strategy_today: "FOCUS=stratégie DU JOUR (page Stratégie / setup épinglé), pas audit discipline des trades. " + strategyTodayFmt +
      "Utilise strategyTodayContext + coachInstructions. Cite LEUR setup, signal, TF, pattern, règles, riskManagement, goldRules. " +
      "Si responseRules.style=strategy_today_brief_followup: max 90 mots, réponds UNIQUEMENT via priorTurns. " +
      "INTERDIT: modèle générique de stratégie, winrate, X/70 trades, ENREGISTRÉ/NON ENREGISTRÉ. Si hasDataToday=false → fillHintPath.",
    calendar_today: "FOCUS=synthèse calendrier DU JOUR (trades + discipline + mois), pas audit global. " + calendarTodayFmt +
      "Utilise calendarTodayContext + coachInstructions. Cite PnL/trades du jour, checklist/mental/setup si présents, monthProgress. " +
      "Si brief followup: max 90 mots via priorTurns. INTERDIT: sermon X/70, ENREGISTRÉ/NON ENREGISTRÉ.",
    calendar_month: "FOCUS=mois calendrier PAYCHEK (objectif + PnL + winrate + jours verts/rouges), pas audit 4 piliers. " + calendarMonthFmt +
      "Utilise calendarMonthContext + coachInstructions. Si monthlyObjective absent → fillHintPath. " +
      "Si brief followup: max 90 mots via priorTurns. INTERDIT: audit X/70 global.",
    app_help: "FOCUS=aide app PAYCHEK — mode notice courte (comment faire / où cliquer). " +
      "Règles strictes: 80-110 mots max; 4-6 puces ou lignes numérotées; pas de paragraphe d'intro type « excellente initiative ». " +
      "INTERDIT d'utiliser tradesTotal, winrate, PnL, recordedDiscipline, tradeJournal ou sermon discipline — le JSON app_help n'en contient pas. " +
      "Priorité: appHelpGuide.paychekUiSteps puis appHelpGuide.body. Réponds uniquement où cliquer dans PAYCHEK. " +
      "Utilise paychekUiSteps (topicId) : une réponse courte max, l’app affiche déjà les étapes numérotées. " +
      "Plusieurs engrenages selon l’écran : Ajouter trade (discipline Principe/Feeling, capital, quantité), État mental (poids %), Calendrier (objectifs). Ne confonds pas avec la page État mental si topicId=discipline_gear. " +
      "Ex. modifier checklist → Dashboard/Plus → Checklist → menu ⋯ section → Éditer.",
    trade_count: "FOCUS=nombre de trades. Réponds uniquement sur les volumes, clôturés, gagnants, perdants, winrate et PnL. " +
      "Pas d'audit complet 4 piliers, pas de BILAN PAYCHEK automatique.",
    trade_list: "FOCUS=liste de trades filtrés (tags psych). Utilise tradeListQuery.trades du JSON : une ligne par trade (paire, date, PnL, tags). " +
      "Ne liste PAS les trades uniquement dans un paragraphe — l'app affiche déjà les cartes. Donne 1-2 phrases max (compte + conseil taguer si vide). " +
      "N'invente pas de trades ; n'associe pas Revenge à TILT sauf si le tag est présent.",
    performance_summary: "FOCUS=page Performance — split discipline complète vs incomplète. " +
      "Utilise performanceSummaryContext / performanceSplit + paychekLens. Respecte period/periodLabel. " +
      "FORMAT: intro + 4 lignes (global, enregistrés, incomplets, conseil). INTERDIT: liste trades, audit X/70, ENREGISTRÉ. Max 170 mots.",
    performance_lens: "FOCUS=Paychek Lens (page Performance). Utilise performanceLensContext (axes, compositeDisciplinePercent). " +
      "FORMAT: intro + 4 lignes. INTERDIT: audit global 70 trades. Max 160 mots.",
    performance_overtrading: "FOCUS=Journée & volume / overtrading (page Performance). Utilise performanceOvertradingContext buckets. " +
      "FORMAT: intro + 4 lignes avec chiffres des tranches. INTERDIT: sermon sans buckets. Max 160 mots.",
  };
  const en = {
    full: "FOCUS=global audit. Personalized answer from JSON stats. No generic script.",
    checklist: "FOCUS=checklist on TRADES (recorded/non-respect), NOT today's Checklist page. No full 4-pillar audit. " +
      "FORBIDDEN: generic before/during/after trade checklist template unless checklistTodayContext is present.",
    analysis: "FOCUS=analysis plan on TRADES (recorded/non-respect), NOT today's Analysis page. No full 4-pillar audit. " +
      "FORBIDDEN: generic HTF/structure analysis template unless analysisTodayContext is present.",
    strategy: "FOCUS=strategy on TRADES (recorded/non-respect), NOT today's Strategy page. No full 4-pillar audit. " +
      "FORBIDDEN: generic strategy template unless strategyTodayContext is present.",
    mental: "FOCUS=mental state only. No full audit template.",
    mental_emotion: "FOCUS=targeted mental state question (emotion or slider: focus, sleep, fear). " +
      "Use mentalEmotionFocus JSON (kind, polarity, onEmotionDays vs otherEtatDays). " +
      "Friendly coach tone. Do not refuse if mentalEmotionFocus exists. No full audit template.",
    coach: "FOCUS=free coaching. Natural human-like answer, no fixed template.",
    non_respect: "FOCUS=rule violations vs losses. Use nonRespectImpact JSON. List top items with stats and trader psychology insight. No full audit template.",
    story_followup: "FOCUS=after coaching_story — how to manage THEIR psycho (revenge, FOMO…) with PAYCHEK. " +
      storyFollowFmt +
      "Read priorTurns + paychekUiSteps. 5 personalized PAYCHEK actions on single lines. No discipline audit.",
    coaching_story: "FOCUS=user trade story + psycho coaching. " + narrativeFmt +
      "Use coachingStoryFocus.themes. No journal trade list, no discipline audit.",
    psychology_why: "FOCUS=why emotion/tag (e.g. FOMO). " + narrativeFmt +
      "Use tagStats if present. Optional line 5. modest PAYCHEK training. No full audit.",
    app_pricing: "FOCUS=PAYCHEK app pricing (not trade prices). " + pricingFmt +
      "Use pricingContext JSON. Adapt to question. Never say check website without numbers. No trading audit.",
    mental_today: "FOCUS=today's mental state page, NOT discipline audit. " + mentalTodayFmt +
      "Use mentalTodayContext. If brief follow-up style: max 90 words from priorTurns only. " +
      "FORBIDDEN: global winrate, recorded/incomplete audit, X/70 trades.",
    checklist_today: "FOCUS=today's PAYCHEK Checklist page tasks. " + checklistTodayFmt +
      "Use checklistTodayContext. List THEIR items checked/unchecked. " +
      "If brief follow-up: max 90 words from priorTurns. FORBIDDEN: generic trade checklist template, X/70 audit.",
    analysis_today: "FOCUS=today's PAYCHEK Analysis page (Mon Analyse). " + analysisTodayFmt +
      "Use analysisTodayContext. Cite asset, bias, trend, phase, confidence, confluence, S/R. " +
      "If brief follow-up: max 90 words from priorTurns. FORBIDDEN: generic analysis template, X/70 audit.",
    strategy_today: "FOCUS=today's PAYCHEK Strategy page (starred setup). " + strategyTodayFmt +
      "Use strategyTodayContext. If brief follow-up: max 90 words from priorTurns. FORBIDDEN: generic strategy template, X/70 audit.",
    calendar_today: "FOCUS=today's Calendar synthesis (trades + discipline + month). " + calendarTodayFmt +
      "Use calendarTodayContext. If brief follow-up: max 90 words. FORBIDDEN: X/70 global audit.",
    calendar_month: "FOCUS=current month Calendar (goal + PnL + winrate). " + calendarMonthFmt +
      "Use calendarMonthContext. If brief follow-up: max 90 words. FORBIDDEN: X/70 pillar audit.",
    app_help: "FOCUS=short app how-to. Max 80-110 words, numbered steps only, no intro fluff. " +
      "FORBIDDEN: trade stats, winrate, PnL, discipline lecture. Use appHelpGuide.paychekUiSteps first.",
    trade_count: "FOCUS=trade counts only. Answer only counts/closed/wins/losses/winrate/pnl. No full 4-pillar audit.",
    trade_list: "FOCUS=filtered trade list. Use tradeListQuery.trades from JSON. Max 2 sentences; UI shows one row per trade. Do not invent trades.",
    performance_summary: "FOCUS=Performance page — recorded vs incomplete discipline split. " +
      "Use performanceSummaryContext / performanceSplit + paychekLens. Respect period. FORMAT: intro + 4 lines. " +
      "FORBIDDEN: trade list, X/70 audit. Max 170 words.",
    performance_lens: "FOCUS=Paychek Lens. Use performanceLensContext. FORMAT: intro + 4 lines. FORBIDDEN: global 70-trade audit. Max 160 words.",
    performance_overtrading: "FOCUS=Day & volume / overtrading. Use performanceOvertradingContext buckets with numbers. Max 160 words.",
  };
  const table = locale === "fr" ? fr : en;
  return table[focus] || table.coach;
}

function paychekAiCoachSystemPrompt(locale, options = {}) {
  const includeHelpCenter = options.includeHelpCenter !== false;
  const focus = options.focus || "coach";
  const helpCenterKb = paychekAiCoachHelpCenterKnowledge(locale);
  const prompts = {
    fr: "Tu es le Coach AI de PAYCHEK. " +
      "Tu réponds au trading, discipline, psychologie, stratégie, checklist, performance, " +
      "et aux questions d’utilisation de l’application PAYCHEK (fonctionnalités, pages, workflow). " +
      "Règle absolue: adapte chaque réponse à la question exacte de l'utilisateur. " +
      "Varie le style selon la question; réponses complètes et naturelles (pas de limite de mots rigide). " +
      "N'utilise le référentiel Help Center PAYCHEK que pour les questions d'utilisation de l'app. " +
      "Interdis les conseils médicaux, légaux et fiscaux. " +
      "N'affiche un avertissement risque financier que si l'utilisateur demande explicitement " +
      "un signal d'investissement (acheter/vendre, entrée/sortie, prediction de prix). " +
      "Utilise en priorité les données JSON de contexte (tradeJournal = journal Trade récent, performanceSplit, mentalEmotionFocus, etc.). " +
      "Si tradeJournal.recentTrades est présent, tu peux citer des trades précis (paire, date, PnL) — ne invente pas. " +
      "Sois honnête et direct. " +
      "Si une donnée manque, dis 'non disponible' sans poser 5 questions. " +
      "Ne laisse jamais une phrase inachevée. " +
      "Sortie en texte brut uniquement (pas de markdown, pas de **). " +
      paychekAiCoachFocusInstructions(locale, focus),
    en: "You are PAYCHEK AI Coach. " +
      "Answer about trading, discipline, psychology, strategy, checklist, performance, " +
      "and PAYCHEK app usage questions (features, pages, workflow). " +
      "Absolute rule: adapt every answer to the exact user question. " +
      "Never repeat the same template for all requests. " +
      "Use Help Center knowledge only for app-usage questions. " +
      "Refuse medical, legal, and tax topics. " +
      "Show a financial risk disclaimer only when the user explicitly asks for investment signals. " +
      "Prioritize JSON context (tradeJournal = recent Trade tab journal, performanceSplit, etc.). " +
      "Cite specific trades from tradeJournal.recentTrades when relevant; do not invent. " +
      "Be honest and direct. " +
      "Never leave a sentence unfinished. Plain text only (no markdown). " +
      paychekAiCoachFocusInstructions(locale, focus),
    es: "Eres el Coach AI de PAYCHEK. " +
      "Responde sobre trading, disciplina, psicología, estrategia, checklist, rendimiento " +
      "y uso de la app PAYCHEK (funciones, páginas, flujo). " +
      "Rechaza temas médicos, legales y fiscales. " +
      "Formato: 1) diagnóstico breve 2) impacto estadístico 3) 3 acciones medibles.",
    de: "Du bist der PAYCHEK AI Coach. " +
      "Antworte zu Trading, Disziplin, Psychologie, Strategie, Checkliste, Performance " +
      "und zur Nutzung der PAYCHEK-App (Funktionen, Seiten, Workflow). " +
      "Lehne medizinische, rechtliche und steuerliche Themen ab. " +
      "Format: 1) kurze Diagnose 2) statistische Wirkung 3) 3 messbare Maßnahmen.",
    pt: "Você é o Coach AI da PAYCHEK. " +
      "Responda sobre trading, disciplina, psicologia, estratégia, checklist, performance " +
      "e uso do app PAYCHEK (funcionalidades, páginas, fluxo). " +
      "Recuse temas médicos, legais e fiscais. " +
      "Formato: 1) diagnóstico breve 2) impacto estatístico 3) 3 ações mensuráveis.",
    ko: "당신은 PAYCHEK AI 코치입니다. " +
      "트레이딩, 규율, 심리, 전략, 체크리스트, 퍼포먼스와 " +
      "PAYCHEK 앱 사용법(기능, 페이지, 흐름)에 답변하세요. " +
      "의료/법률/세무 주제는 거절하세요. " +
      "형식: 1) 짧은 진단 2) 통계적 영향 3) 측정 가능한 3가지 행동.",
  };
  const selected = prompts[locale] || prompts.en;
  if (!includeHelpCenter) return selected;
  return `${selected}\n\n${helpCenterKb}`;
}

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
          "\n\nInstruction: réponds selon questionFocus du JSON et la question utilisateur. " +
          "Ne répète pas un script fixe. Utilise uniquement les champs pertinents au focus.",
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
exports.paychekAiCoach = onCall(
    {
      region: "europe-west1",
      timeoutSeconds: 60,
      memory: "256MiB",
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Connexion requise.");
      }

      const question = `${request.data?.question ?? ""}`.trim();
      if (!question) {
        throw new HttpsError("invalid-argument", "Question requise.");
      }
      if (question.length > 1600) {
        throw new HttpsError("invalid-argument", "Question trop longue.");
      }

      const locale = paychekNormalizeCoachLocale(request.data?.locale);
      const modelRaw = `${request.data?.model ?? "gemini-2.5-flash"}`.trim();
      const model = modelRaw.startsWith("gemini-") ? modelRaw : "gemini-2.5-flash";
      const contextData = request.data?.context;
      const contextJson =
        contextData && typeof contextData === "object" ?
          JSON.stringify(contextData).slice(0, 7000) :
          "";
      const clientFocus = paychekAiCoachNormalizeFocus(contextData?.questionFocus);
      const contextFollowUp = paychekAiCoachResolveFocusFromContext(contextData, question);
      const focus = clientFocus || contextFollowUp || paychekAiCoachResolveFocus(question);
      const useHelpCenter = focus === "app_help";
      const systemPrompt = paychekAiCoachSystemPrompt(locale, {
        includeHelpCenter: useHelpCenter,
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

      const plan = await paychekAiCoachResolvePlan(db, request.auth.uid);
      if (plan !== "pro" && plan !== "trial") {
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
exports.syncPaychekStripeEntitlement = onCall(
    {
      region: "europe-west1",
      secrets: [paychekStripeSecretKey],
      timeoutSeconds: 60,
      memory: "256MiB",
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Connexion requise.");
      }
      const key = paychekStripeSecretKey.value().trim();
      if (!key) {
        throw new HttpsError(
            "failed-precondition",
            "Stripe non configuré (secret manquant).",
        );
      }
      const stripe = new Stripe(key);
      const db = admin.firestore();
      const uid = request.auth.uid;
      const email = normalizedRequestEmail(request.auth.token);
      const stripeKeyMode = paychekStripeKeyMode(key);
      const result = await paychekSyncStripeEntitlementForUser(
          stripe,
          db,
          uid,
          email,
          stripeKeyMode,
          key,
      );
      return result;
    },
);

/**
 * Console admin : force la synchro Stripe → Firestore pour un utilisateur cible.
 */
exports.adminSyncPaychekStripeEntitlement = onCall(
    {
      region: "europe-west1",
      secrets: [paychekStripeSecretKey],
      timeoutSeconds: 60,
      memory: "256MiB",
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Connexion requise.");
      }
      if (request.auth.token.admin !== true) {
        throw new HttpsError(
            "permission-denied",
            "Réservé aux administrateurs.",
        );
      }
      const targetUid = `${request.data?.targetUserId ?? ""}`.trim();
      if (!targetUid) {
        throw new HttpsError(
            "invalid-argument",
            "targetUserId requis.",
        );
      }
      const key = paychekStripeSecretKey.value().trim();
      if (!key) {
        throw new HttpsError(
            "failed-precondition",
            "Stripe non configuré (secret manquant).",
        );
      }
      const stripe = new Stripe(key);
      const db = admin.firestore();
      const stripeKeyMode = paychekStripeKeyMode(key);
      let email = "";
      try {
        const snap = await db.collection("paychek_users").doc(targetUid).get();
        if (snap.exists) {
          email = `${snap.data()?.email ?? ""}`.trim().toLowerCase();
        }
      } catch (e) {
        console.warn("adminSyncPaychekStripe: paychek_users", e);
      }
      const result = await paychekSyncStripeEntitlementForUser(
          stripe,
          db,
          targetUid,
          email,
          stripeKeyMode,
          key,
      );
      return {...result, targetUserId: targetUid};
    },
);

/**
 * Prénom / salutation pour l’e-mail remboursement (doc `paychek_users`).
 * @param {Record<string, unknown>|undefined|null} data
 */
function paychekRefundGreetingFirstNameFromUserDoc(data) {
  const fsFirst = `${data?.firstName ?? ""}`.trim();
  if (fsFirst) {
    const tok = fsFirst.split(/\s+/)[0];
    return tok ?
      tok.charAt(0).toUpperCase() + tok.slice(1).toLowerCase() :
      "Client";
  }
  const dn = `${data?.displayName ?? ""}`.trim();
  if (dn) {
    const tok = dn.split(/\s+/)[0];
    return tok ?
      tok.charAt(0).toUpperCase() + tok.slice(1).toLowerCase() :
      "Client";
  }
  const em = `${data?.email ?? ""}`.trim();
  if (em.includes("@")) {
    const local = em.split("@")[0].replace(/[.+_]+/g, " ").trim();
    const tok = local.split(/\s+/)[0] || local;
    return tok ?
      tok.charAt(0).toUpperCase() + tok.slice(1).toLowerCase() :
      "Client";
  }
  return "Client";
}

/**
 * @param {{ firstName: string, amountDisplay: string, approvalDateFr: string, supportHref: string, privacyHref: string }} v
 *        — valeurs déjà passées par escapeHtml où nécessaire.
 */
function buildRefundConfirmedHtml(v, locale) {
  const loc = emailI18n.normalizePaychekEmailLocale(locale);
  const s = emailI18n.pack(loc).refund;
  const refundDelay = emailI18n.pack(loc).refundDelay;
  return `<!DOCTYPE html>
<html lang="${loc}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${escapeHtml(s.htmlTitle)}</title>
    <style>
        body, table, td, a { text-decoration: none; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
        table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
        img { -ms-interpolation-mode: bicubic; border: 0; height: auto; line-height: 100%; outline: none; }
        
        body {
            background-color: #000000;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            width: 100% !important;
        }

        .container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            background-color: #000000;
            border: 1px solid #1a1a1a;
        }

        .header {
            padding: 60px 20px 40px 20px;
            text-align: center;
        }

        .brand-logo {
            font-size: 22px;
            font-weight: 900;
            color: #ffffff;
            letter-spacing: 6px;
            text-transform: uppercase;
        }

        .content {
            padding: 0 50px 50px 50px;
            color: #ffffff;
            line-height: 1.6;
        }

        .status-badge {
            border: 1px solid #c5a059;
            color: #c5a059;
            padding: 6px 14px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            display: inline-block;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        h1 {
            color: #ffffff;
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 20px;
            line-height: 1.1;
        }

        .refund-box {
            background-color: #080808;
            border: 1px solid #1a1a1a;
            border-radius: 8px;
            padding: 30px;
            margin: 40px 0;
        }

        .refund-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            font-size: 14px;
        }

        .refund-label { color: #555555; text-transform: uppercase; letter-spacing: 1px; font-size: 11px; }
        .refund-value { color: #ffffff; font-weight: 500; }

        .divider {
            height: 1px;
            background: #1a1a1a;
            margin: 20px 0;
        }

        .note-box {
            background: rgba(197, 160, 89, 0.05);
            border: 1px dashed #c5a059;
            padding: 20px;
            border-radius: 8px;
            margin-top: 30px;
        }

        .note-text {
            color: #c5a059;
            font-size: 13px;
            margin: 0;
            line-height: 1.5;
        }

        .footer {
            padding: 50px;
            text-align: center;
            font-size: 10px;
            color: #333333;
            letter-spacing: 1px;
            text-transform: uppercase;
            border-top: 1px solid #1a1a1a;
        }

        @media screen and (max-width: 600px) {
            .content { padding: 0 25px 50px 25px !important; }
            h1 { font-size: 26px; }
            .refund-box { padding: 20px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="brand-logo">PAYCHEK</div>
        </div>

        <div class="content">
            <div style="text-align: center;">
                <div class="status-badge">${s.badge}</div>
                <h1>${s.h1}</h1>
                <p style="color: #888888; font-size: 15px;">${s.intro(v.firstName, v.amountDisplay)}</p>
            </div>

            <div class="refund-box">
                <div class="refund-row">
                    <span class="refund-label">${s.amountLabel}</span>
                    <span class="refund-value" style="color: #c5a059; font-weight: 700;">${v.amountDisplay}</span>
                </div>
                <div class="refund-row">
                    <span class="refund-label">${s.approvalLabel}</span>
                    <span class="refund-value">${v.approvalDateFr}</span>
                </div>
                <div class="divider"></div>
                <div class="refund-row">
                    <span class="refund-label">${s.delayLabel}</span>
                    <span class="refund-value" style="color: #c5a059;">${refundDelay}</span>
                </div>
            </div>

            <div class="note-box">
                <p class="note-text">
                    ${s.note}
                </p>
            </div>

            <p style="text-align: center; color: #444444; font-size: 11px; margin-top: 50px; line-height: 1.8;">
                ${s.thanks}
            </p>
        </div>

        <div class="footer">
            <p>
                <strong>PAYCHEK LABS</strong> — PRECISION & RIGOR.<br><br>
                <a href="${v.supportHref}" style="color: #555555;">${emailI18n.pack(loc).welcome.support}</a> &nbsp;•&nbsp; <a href="${v.privacyHref}" style="color: #555555;">${emailI18n.pack(loc).welcome.privacy}</a>
            </p>
        </div>
    </div>
</body>
</html>`;
}

/**
 * E-mail informatif (montant saisi par l’admin) — le remboursement Stripe est effectué séparément.
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} passRaw
 * @param {string} uid
 * @param {string} toEmail
 * @param {string} amountLabelPlain — libellé montant (ex. « 35 $ », « 29,99 € »), non HTML.
 */
async function paychekSendRefundNotifyEmail(
    db,
    passRaw,
    uid,
    toEmail,
    amountLabelPlain,
) {
  const id = paychekSmtpIdentity();
  const resendKey = `${paychekResendApiKey.value()}`.trim();
  const pass = normalizeSmtpPassword(passRaw);
  const smtpReady = Boolean(id.host && id.user && pass);
  if (!resendKey && !smtpReady) {
    throw new Error(
        "Ni PAYCHEK_RESEND_API_KEY ni SMTP complet — impossible d’envoyer l’e-mail.",
    );
  }
  const to = `${toEmail ?? ""}`.trim();
  if (!to.includes("@")) {
    throw new Error("Destinataire e-mail manquant.");
  }

  let u = {};
  try {
    const snap = await db.collection("paychek_users").doc(uid).get();
    u = snap.exists ? snap.data() ?? {} : {};
  } catch (e) {
    console.warn("refundEmail: lecture paychek_users", e);
  }

  const locale = await emailI18n.paychekResolveEmailLocale(db, uid, u);
  const firstNameRaw = paychekRefundGreetingFirstNameFromUserDoc(u);
  const fn = escapeHtml(firstNameRaw);
  const amountDisplay = escapeHtml(amountLabelPlain);
  const approvalDatePlain = emailI18n.formatApprovalDate(locale, new Date());
  const approvalDateFr = escapeHtml(approvalDatePlain);
  const supportHref = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const privacyHref = escapeHtml(PAYCHEK_PRIVACY_PAGE_URL_FR);
  const refundDelay = emailI18n.pack(locale).refundDelay;

  const html = buildRefundConfirmedHtml({
    firstName: fn,
    amountDisplay,
    approvalDateFr,
    supportHref,
    privacyHref,
  }, locale);

  const text = emailI18n.pack(locale).refund.text(
      firstNameRaw,
      amountLabelPlain,
      approvalDatePlain,
      refundDelay,
  );

  await sendPaychekMailOutbound(
      {
        from: `"Paychek" <${id.mailFrom}>`,
        to,
        bcc: id.mailBcc,
        replyTo: id.mailFrom,
        subject: emailI18n.pack(locale).refundSubject,
        text,
        html,
      },
      passRaw,
      JSON.stringify({flow: "refundNotifyEmail", uid, amount: amountLabelPlain}),
  );
}

/**
 * Admin : envoie uniquement un e-mail informatif de remboursement (montant saisi à la main).
 * Le virement Stripe est effectué séparément depuis le Dashboard Stripe.
 */
exports.adminNotifyUserRefundEmail = onCall(
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
        throw new HttpsError(
            "permission-denied",
            "Réservé aux administrateurs.",
        );
      }
      const targetUid = `${request.data?.targetUserId ?? ""}`.trim();
      if (!targetUid) {
        throw new HttpsError(
            "invalid-argument",
            "targetUserId requis.",
        );
      }
      const amountLabel = `${request.data?.amountLabel ?? ""}`.trim();
      if (!amountLabel || amountLabel.length > 80) {
        throw new HttpsError(
            "invalid-argument",
            "Montant / libellé requis (80 caractères max), ex. « 35 $ » ou « 29,99 € ».",
        );
      }
      if (/[<>]/.test(amountLabel)) {
        throw new HttpsError(
            "invalid-argument",
            "Les caractères < et > ne sont pas autorisés.",
        );
      }

      const rawPass = paychekSmtpPassword.value();
      const db = admin.firestore();

      let userEmail = "";
      try {
        const uSnap = await db.collection("paychek_users").doc(targetUid).get();
        if (!uSnap.exists) {
          throw new HttpsError(
              "not-found",
              "Utilisateur introuvable dans paychek_users.",
          );
        }
        userEmail = `${uSnap.data()?.email ?? ""}`.trim();
      } catch (e) {
        if (e instanceof HttpsError) throw e;
        console.warn("adminNotifyUserRefundEmail: lecture paychek_users", e);
        throw new HttpsError("internal", "Lecture profil impossible.");
      }
      if (!userEmail.includes("@")) {
        throw new HttpsError(
            "failed-precondition",
            "Ce profil n’a pas d’adresse e-mail pour l’envoi.",
        );
      }

      try {
        await paychekSendRefundNotifyEmail(
            db,
            rawPass,
            targetUid,
            userEmail,
            amountLabel,
        );
      } catch (err) {
        console.error("adminNotifyUserRefundEmail: envoi", err);
        throw new HttpsError(
            "failed-precondition",
            outboundErrorMessageForClient(err),
        );
      }

      return {
        ok: true,
        targetUserId: targetUid,
        amountLabel,
      };
    },
);

/**
 * Console admin : liste des Checkout Sessions Stripe (aperçu, sans exposer la clé secrète).
 */
exports.adminListStripeCheckoutSessions = onCall(
    {
      region: "europe-west1",
      secrets: [paychekStripeSecretKey],
      timeoutSeconds: 45,
      memory: "256MiB",
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Connexion requise.");
      }
      if (request.auth.token.admin !== true) {
        throw new HttpsError(
            "permission-denied",
            "Réservé aux administrateurs.",
        );
      }
      const key = paychekStripeSecretKey.value().trim();
      if (!key) {
        throw new HttpsError(
            "failed-precondition",
            "Stripe non configuré (secret manquant).",
        );
      }
      let limit = Number(request.data?.limit);
      if (!Number.isFinite(limit) || limit < 1) limit = 25;
      if (limit > 50) limit = 50;

      const stripe = new Stripe(key);
      const stripeKeyMode = paychekStripeKeyMode(key);

      let sessions;
      try {
        const res = await stripe.checkout.sessions.list({limit});
        sessions = res.data;
      } catch (e) {
        console.error("adminListStripeCheckoutSessions list", e);
        throw new HttpsError(
            "internal",
            `${e && e.message ? e.message : "Erreur API Stripe."}`,
        );
      }

      const rows = sessions.map((s) => {
        const email =
          `${s.customer_details?.email ?? ""}`.trim() ||
          `${s.customer_email ?? ""}`.trim();
        const pi =
          typeof s.payment_intent === "string" ?
            s.payment_intent :
            s.payment_intent?.id || "";
        return {
          checkoutSessionId: s.id,
          paymentIntentId: pi,
          amountTotal: s.amount_total,
          currency: `${s.currency ?? "usd"}`.toLowerCase(),
          paymentStatus: `${s.payment_status ?? ""}`,
          status: `${s.status ?? ""}`,
          email,
          created: typeof s.created === "number" ? s.created : 0,
        };
      });

      return {
        ok: true,
        stripeKeyMode,
        sessions: rows,
      };
    },
);

/**
 * Express : conserve le buffer exact via `verify` (requis Firebase / Cloud Run + Stripe).
 */
const paychekStripeWebhookApp = express();
paychekStripeWebhookApp.post(
    "/",
    express.json({
      verify: (req, res, buf) => {
        req.rawBody = buf;
      },
    }),
    async (req, res) => {
      const key = paychekStripeSecretKey.value().trim();
      const whSecret = paychekStripeWebhookSecret.value().trim();
      if (!key || !whSecret) {
        console.error("paychekStripeWebhook: secrets Stripe manquants");
        res.status(500).send("Stripe not configured");
        return;
      }
      if (!whSecret.includes("whsec_")) {
        console.warn(
            "paychekStripeWebhook: PAYCHEK_STRIPE_WEBHOOK_SECRET doit " +
            "être le Signing secret whsec_… du endpoint Stripe (pas sk_…).",
        );
      }

      const stripe = new Stripe(key);
      const sig = req.headers["stripe-signature"];
      if (!sig || typeof sig !== "string") {
        res.status(400).send("Missing stripe-signature");
        return;
      }

      const rawBody = paychekStripeWebhookRawBody(req);
      if (!rawBody.length) {
        console.warn(
            "paychekStripeWebhook: corps vide (rawBody manquant après parse)",
        );
        res.status(400).send("Empty body");
        return;
      }

      let event;
      try {
        event = paychekConstructStripeEvent(stripe, rawBody, sig, whSecret);
      } catch (err) {
        const msg = err && err.message ? String(err.message) : String(err);
        console.warn(
            "paychekStripeWebhook: signature",
            msg,
            "rawBytes=",
            rawBody.length,
        );
        res.status(400).send(`Webhook signature: ${msg}`);
        return;
      }

      try {
        await paychekHandleStripeEvent(
            stripe,
            event,
            paychekSmtpPassword.value(),
        );
      } catch (err) {
        console.error("paychekStripeWebhook: handler", err);
        res.status(500).send("Handler error");
        return;
      }

      res.status(200).json({received: true});
    },
);

exports.paychekStripeWebhook = onRequest(
    {
      region: "europe-west1",
      secrets: [
        paychekStripeSecretKey,
        paychekStripeWebhookSecret,
        paychekSmtpPassword,
      ],
      timeoutSeconds: 30,
      memory: "256MiB",
      cors: false,
      invoker: "public",
    },
    paychekStripeWebhookApp,
);
