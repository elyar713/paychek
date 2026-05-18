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
/** Délai annoncé dans l’accusé de réception (texte FR). */
const ACK_RESPONSE_DELAY_FR = "48 heures";
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
function footerClientTicketRef(ticketData, ticketId) {
  const r = `${ticketData?.ticketRef ?? ""}`.trim();
  if (r.length >= 6) {
    return `Référence dossier : ${r}`;
  }
  return `Référence dossier : ${ticketId}`;
}

function kindLabelFr(kindRaw) {
  const k = `${kindRaw ?? ""}`.trim();
  switch (k) {
  case "account":
    return "Compte";
  case "billing":
    return "Facturation";
  case "feature":
    return "Idée / fonctionnalité";
  case "other":
  default:
    return k === "" ? "Autre demande" : k;
  }
}

function ackSubjectLine(kindFr, description) {
  const ex = `${description ?? ""}`.replace(/\s+/g, " ").trim();
  if (ex.length <= 60) {
    return ex.length > 0 ? `${kindFr} — ${ex}` : kindFr;
  }
  return `${kindFr} — ${ex.slice(0, 57)}…`;
}

/** `createdAt` Firestore Timestamp ou absent. */
function formatOpeningDateFrench(createdAt) {
  let d;
  if (createdAt && typeof createdAt.toDate === "function") {
    d = createdAt.toDate();
  } else {
    d = new Date();
  }
  return d.toLocaleString("fr-FR", {
    dateStyle: "long",
    timeStyle: "short",
    timeZone: "Europe/Paris",
  });
}

/** Extrait du message utilisateur pour l’accusé de réception (texte brut, tronqué). */
function buildAcknowledgmentDescriptionPreview(ticketData) {
  const raw = `${ticketData.description ?? ""}`.replace(/\s+/g, " ").trim();
  if (!raw) return "(aucun texte saisi)";
  const max = 500;
  return raw.length > max ? `${raw.slice(0, max)}…` : raw;
}

function buildUserAcknowledgmentText(ticketData, ticketLabels) {
  const displayNameRaw = `${ticketData.replyDisplayName ?? ""}`.trim();
  const greeting = displayNameRaw ?
    `Bonjour ${displayNameRaw},` :
    "Bonjour,";
  const sujetConcern = `${ticketLabels.sujetLine}`;

  return (
    `${greeting}\n\n` +
    `Nous vous informons que nous avons bien reçu votre demande ` +
    `concernant « ${sujetConcern} ». ` +
    "Un membre de notre équipe technique a été assigné à votre dossier.\n\n" +
    "Récapitulatif de votre ticket :\n\n" +
    `Numéro de référence : #${ticketLabels.label}\n` +
    `Date d’ouverture : ${ticketLabels.opened}\n` +
    "Statut actuel : En cours de traitement\n\n" +
    "Nous nous efforçons de répondre à toutes les demandes sous un délai de " +
    `${ACK_RESPONSE_DELAY_FR}. ` +
    "En attendant, vous pouvez consulter notre base de connaissances :\n" +
    `${KNOWLEDGE_BASE_URL_FR}\n\n` +
    "Vous recevrez une notification dès qu'une mise à jour sera disponible. " +
    "Si vous avez des informations complémentaires à ajouter, " +
    `répondez simplement à cet e-mail (ou écrivez-nous depuis l’application ${COMPANY_NAME}).\n\n` +
    "Cordialement,\n\n" +
    `L'équipe Support ${COMPANY_NAME}`
  );
}

function buildUserAcknowledgmentHtml(ticketData, ticketLabels) {
  const ticketLabel = escapeHtml(ticketLabels.label);
  const nomUtilisateur = escapeHtml(ticketUserGreetingName(ticketData));
  const ackDelay = escapeHtml("48 heures");
  const messagePreview = plainTextToHtmlBr(
      buildAcknowledgmentDescriptionPreview(ticketData),
  );
  const supportHref = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const followTicketHref = supportHref;

  return `<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ticket de Support PAYCHEK</title>
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
                <div class="support-badge">Requête Reçue</div>
                <h1>Nous analysons votre demande.</h1>
                <p style="color: #888888; font-size: 16px;">Bonjour ${nomUtilisateur}, votre ticket de support a été ouvert.</p>
            </div>

            <div class="ticket-box">
                <div class="ticket-info">
                    <span class="ticket-label">Référence</span>
                    <span class="ticket-value">#${ticketLabel}</span>
                </div>
                <div class="divider"></div>
                <div class="ticket-info">
                    <span class="ticket-label">Délai estimé</span>
                    <span class="ticket-value" style="color: #c5a059;">${ackDelay}</span>
                </div>
            </div>

            <div class="message-preview">
                <div class="preview-title">Rappel de votre message</div>
                <div class="preview-content">
                    ${messagePreview}
                </div>
            </div>

            <p style="text-align: center; color: #444444; font-size: 12px; margin-top: 50px;">
                Vous recevrez une notification dès qu'un analyste aura traité votre dossier. 
                Inutile de renvoyer une demande pour la même requête.
            </p>
        </div>

        <div class="footer">
            <p>
                <strong>PAYCHEK SUPPORT LABS</strong> — PRECISION & RIGOR.<br><br>
                <a href="${supportHref}" style="color: #555555;">Centre d'aide</a> &nbsp;•&nbsp; <a href="${followTicketHref}" style="color: #555555;">Suivre mon ticket</a>
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
  return o;
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
function buildStaffSupportAttachmentBlock(attachmentShownFileName) {
  const safeAttachName =
    typeof attachmentShownFileName === "string" &&
      attachmentShownFileName.trim().length > 0 ?
      escapeHtml(attachmentShownFileName.trim()) :
      "";
  if (!safeAttachName.length) return "";
  return (
    `<p style="color:#94a3b8;font-size:13px;line-height:1.55;margin:-8px 0 22px;">` +
      `<strong style="color:#ffffff;">Pièce jointe</strong>&nbsp;: ` +
      `${safeAttachName} — ce fichier est joint à cet e-mail.` +
    `</p>`
  );
}

async function resolveUserAcknowledgmentHtml(db, ticketData, ticketLabels) {
  let custom = "";
  try {
    const data = await paychekLoadEmailTemplateOverrides(db);
    custom = `${data.userAcknowledgmentHtml ?? ""}`.trim();
  } catch (e) {
    console.warn("resolveUserAcknowledgmentHtml: lecture Firestore", e);
  }
  if (!custom) return buildUserAcknowledgmentHtml(ticketData, ticketLabels);

  const supportHrefEsc = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const vars = {
    ticketLabel: escapeHtml(ticketLabels.label),
    opened: escapeHtml(ticketLabels.opened),
    sujet: escapeHtml(ticketLabels.sujetLine),
    nomUtilisateur: escapeHtml(ticketUserGreetingName(ticketData)),
    ackDelay: escapeHtml(ACK_RESPONSE_DELAY_FR),
    messagePreview: plainTextToHtmlBr(
        buildAcknowledgmentDescriptionPreview(ticketData),
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
    });
  }

  const safeLabel = escapeHtml(ticketLabel);
  const safeNom = escapeHtml(nomUtilisateur);
  const safeSujet = escapeHtml(sujetTicketPlain);
  const messageHtml = plainTextToHtmlBr(messageBodyPlain);
  const safeInit = escapeHtml(initialesAgent);
  const safeAgent = escapeHtml(nomAgent);
  const pjBlock = buildStaffSupportAttachmentBlock(attachmentShownFileName);

  const csatPoor = supportCsatMailtoHref(ticketLabel, "Insuffisant", mailFromForCsat);
  const csatOk = supportCsatMailtoHref(ticketLabel, "Moyen", mailFromForCsat);
  const csatGood = supportCsatMailtoHref(ticketLabel, "Bien", mailFromForCsat);
  const csatGreat = supportCsatMailtoHref(ticketLabel, "Excellent", mailFromForCsat);

  const supportHrefEsc = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const journalHrefEsc = supportHrefEsc;
  const ticketStatusLabel = escapeHtml("En attente de votre retour");

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
}) {
  const safeLabel = escapeHtml(ticketLabel);
  const safeNom = escapeHtml(nomUtilisateur);
  const safeSujet = escapeHtml(sujetTicketPlain);
  const messageHtml = plainTextToHtmlBr(messageBodyPlain);
  const safeInit = escapeHtml(initialesAgent).trim();
  const safeAgent = escapeHtml(nomAgent);

  const pjBlock = buildStaffSupportAttachmentBlock(attachmentShownFileName);

  const supportHref = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const journalHref = supportHref;

  return `<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Réponse — PAYCHEK</title>
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
                <div class="reply-badge">Réponse</div>
                <h1>Mise à jour de votre dossier.</h1>
                <p style="color: #888888; font-size: 15px;">Bonjour ${safeNom}, un analyste a apporté une réponse à votre demande.</p>
                <p style="color: #666666; font-size: 13px; margin-top: 8px;">Sujet : <strong style="color:#aaaaaa;">«&nbsp;${safeSujet}&nbsp;»</strong></p>
            </div>

            <div class="agent-message">
                ${messageHtml}
                ${pjBlock}
                <div class="agent-signature">
                    <strong>${safeAgent}</strong>${safeInit ? ` <span style="color:#555555;">· ${safeInit}</span>` : ""}<br>
                    Support — PAYCHEK
                </div>
            </div>

            <div class="ticket-meta">
                <div class="meta-row">
                    <span class="meta-label">Référence Ticket</span>
                    <span class="meta-value">#${safeLabel}</span>
                </div>
            </div>

            <p style="text-align: center; color: #444444; font-size: 11px; margin-top: 40px; text-transform: uppercase; letter-spacing: 1px;">
                Si vous avez d'autres questions, répondez simplement à cet email.<br>
                Ce fil de discussion sera automatiquement clos dans 48h sans réponse de votre part.
            </p>
        </div>

        <div class="footer">
            <p>
                <strong>PAYCHEK SUPPORT LABS</strong> — PRECISION & RIGOR.<br><br>
                <a href="${supportHref}" style="color: #555555;">Centre d'aide</a> &nbsp;•&nbsp; <a href="${journalHref}" style="color: #555555;">Accéder à mon journal</a>
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
    const kindFr = kindLabelFr(kind);
    const label = humanTicketLabel(t, ticketId);
    const subject = `Paychek — Réponse à votre demande · ${kindFr} (#${label})`;

    const staffFromToken = `${request.auth.token.email ?? ""}`.trim();
    const ticketOwnerUid = `${t.userId ?? ""}`.trim();

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
      `\n\n— Pièce jointe : ${mailAttachments[0].filename}\n` :
      "";

    const textBody =
      `${messageBody}${pjLine}\n\n` +
      "---\n" +
      `Pour toute précision ou suite à donner à ta demande : merci de ne pas répondre à cet e-mail. ` +
      `Ouvre un nouveau ticket dans l’application Paychek (Réglages · Support) en indiquant la référence #${label}.\n\n` +
      `${footerClientTicketRef(t, ticketId)}\n` +
      (staffFromToken.includes("@") ?
        `Support Paychek : ${staffFromToken}\n` :
        "") +
      "Merci d'utiliser Paychek.\n";

    const htmlBody = await resolveStaffSupportReplyHtml(db, {
      ticketLabel: label,
      nomUtilisateur: ticketUserGreetingName(t),
      sujetTicketPlain: ackSubjectLine(kindFr, t.description),
      messageBodyPlain: messageBody,
      initialesAgent: initialesAgentAffiche,
      nomAgent: nomAgentAffiche,
      attachmentShownFileName: mailAttachments.length > 0 ?
        mailAttachments[0].filename :
        "",
      mailFromForCsat: id.mailFrom,
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
        const kindFr = kindLabelFr(kind);
        const opened = formatOpeningDateFrench(t.createdAt);
        const sujetLine = ackSubjectLine(kindFr, desc);
        const ackLabels = {
          label,
          opened,
          sujetLine,
          kindFr,
        };
        const ackBody = buildUserAcknowledgmentText(t, ackLabels);
        const ackHtml = await resolveUserAcknowledgmentHtml(db, t, ackLabels);
        const ackSubject =
          `[Ticket #${label}] Confirmation de réception de votre demande - ` +
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
function buildProAccessConfirmedHtml(v) {
  const supportHref = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const privacyHref = escapeHtml(PAYCHEK_PRIVACY_PAGE_URL_FR);
  return `<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accès Pro Confirmé - PAYCHEK</title>
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

        .receipt-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            font-size: 14px;
        }

        .receipt-label { color: #555555; text-transform: uppercase; letter-spacing: 1px; font-size: 11px; }
        .receipt-value { color: #ffffff; font-weight: 500; }

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
            .receipt-row { font-size: 13px; }
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
                <div class="success-badge">Activation Immédiate</div>
                <h1>Bienvenue dans l'accès <span class="gold-text">PRO</span>.</h1>
                <p style="color: #666666; font-size: 16px; margin-bottom: 0;">Votre abonnement <strong>Pro Access</strong> est désormais opérationnel sur Paychek.</p>
            </div>

            <div class="receipt-card">
                <div class="receipt-row">
                    <span class="receipt-label">Client</span>
                    <span class="receipt-value">${v.clientName}</span>
                </div>
                <div class="receipt-row">
                    <span class="receipt-label">Plan Actuel</span>
                    <span class="receipt-value"><span class="gold-text">PRO</span> ACCESS</span>
                </div>
                <div class="divider"></div>
                <div class="receipt-row">
                    <span class="receipt-label">Statut du Compte</span>
                    <span class="receipt-value" style="color: #c5a059;">ACTIF</span>
                </div>
                <div class="receipt-row">
                    <span class="receipt-label">Valide jusqu'au</span>
                    <span class="receipt-value">${v.periodEndFr}</span>
                </div>
            </div>

            <div style="margin-top: 50px;">
                <div class="feature-item">
                    <div class="feature-title">Analyses Avancées</div>
                    <div class="feature-desc">Accédez à votre Edge Ratio, vos statistiques de psychologie et vos graphiques de performance en temps réel.</div>
                </div>
            </div>

            <p style="text-align: center; font-size: 11px; color: #333333; margin-top: 40px; text-transform: uppercase; letter-spacing: 1px;">
                ID Transaction : #PC-${v.txnSuffix}<br>
                Une copie de votre facture est disponible dans vos paramètres.
            </p>
        </div>

        <div class="footer">
            <p>
                <strong>PAYCHEK LABS</strong> — L'EXCELLENCE DANS LA DISCIPLINE.<br><br>
                <a href="${supportHref}" style="color: #555555;">Support</a> &nbsp;•&nbsp; <a href="${privacyHref}" style="color: #555555;">Confidentialité</a>
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

  const periodEndFr = paychekFormatFrenchDateParis(periodEndTs);
  const txnSuffix = paychekProMailTxnSuffix(session);

  const safeClient = escapeHtml(clientLine);
  const safeEnd = escapeHtml(periodEndFr);
  const safeTxn = escapeHtml(txnSuffix);

  let customHtml = "";
  try {
    const tplData = await paychekLoadEmailTemplateOverrides(db);
    customHtml = `${tplData.proAccessConfirmedHtml ?? ""}`.trim();
  } catch (e) {
    console.warn("paychekProWelcomeEmail: lecture template Firestore", e);
  }

  const supportHrefEsc = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const privacyHrefEsc = escapeHtml(PAYCHEK_PRIVACY_PAGE_URL_FR);

  const html = customHtml ?
    paychekApplyEmailPlaceholders(customHtml, {
      clientName: safeClient,
      periodEndFr: safeEnd,
      txnSuffix: safeTxn,
      supportHref: supportHrefEsc,
      privacyHref: privacyHrefEsc,
    }) :
    buildProAccessConfirmedHtml({
      clientName: safeClient,
      periodEndFr: safeEnd,
      txnSuffix: safeTxn,
    });

  const text =
    `Bonjour ${clientLine},\n\n` +
    `Votre accès Pro Paychek est confirmé.\n\n` +
    `Plan : PRO ACCESS\n` +
    `Valide jusqu'au : ${periodEndFr}\n` +
    `ID transaction : #PC-${txnSuffix}\n\n` +
    `Merci d'utiliser Paychek.\n`;

  await sendPaychekMailOutbound(
      {
        from: `"Paychek" <${id.mailFrom}>`,
        to,
        bcc: id.mailBcc,
        replyTo: id.mailFrom,
        subject: "Paychek — Accès Pro confirmé",
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
function buildWelcomeSignupHtml(v) {
  const fn = v.firstName;
  const td = v.trialDays;
  const sh = v.supportHref;
  const ph = v.privacyHref;
  return `<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bienvenue sur PAYCHEK</title>
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
                <div class="welcome-badge">Compte Créé</div>
                <h1>Le trading est une science de la donnée.</h1>
                <p style="color: #888888; font-size: 16px;">Bonjour ${fn}, bienvenue sur l'outil qui va changer votre discipline.</p>
            </div>

            <div class="trial-box">
                <div class="trial-title">Offre de Bienvenue</div>
                <div class="trial-days">${td} JOURS PRO</div>
                <p style="color: #888888; font-size: 14px; margin: 0;">Découvrez l'intégralité des outils analytiques PAYCHEK sans aucune restriction.</p>
            </div>

            <div class="quote-box">
                "On ne peut pas améliorer ce que l'on ne mesure pas."
            </div>

            <div class="feature-grid">
                <div class="feature-item">
                    <div class="feature-dot">→</div>
                    <div>
                        <div class="feature-title">Analyses de Psychologie</div>
                        <div class="feature-desc">Identifiez vos biais cognitifs et vos erreurs récurrentes grâce à nos algorithmes.</div>
                    </div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot">→</div>
                    <div>
                        <div class="feature-title">Statistiques Avancées</div>
                        <div class="feature-desc">Win-rate, Profit Factor, et Edge Ratio calculés en temps réel sur tous vos trades.</div>
                    </div>
                </div>
            </div>

            <p style="text-align: center; color: #444444; font-size: 11px; text-transform: uppercase; letter-spacing: 1px; margin-top: 50px;">
                Aucune carte bancaire requise pour débuter l'essai.
            </p>
        </div>

        <div class="footer">
            <p>
                <strong>PAYCHEK LABS</strong> — DISCIPLINE IS FREEDOM.<br><br>
                <a href="${sh}" style="color: #555555;">Support</a> &nbsp;•&nbsp; <a href="${ph}" style="color: #555555;">Confidentialité</a>
            </p>
        </div>
    </div>
</body>
</html>`;
}

async function resolveWelcomeSignupHtml(db, varsRaw) {
  let customHtml = "";
  try {
    const tplData = await paychekLoadEmailTemplateOverrides(db);
    customHtml = `${tplData.welcomeSignupHtml ?? ""}`.trim();
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
    });
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

  const html = await resolveWelcomeSignupHtml(db, {
    firstName: firstNameRaw,
    trialDays,
  });

  const text =
    `Bonjour ${firstNameRaw},\n\n` +
    `Bienvenue sur Paychek.\n\n` +
    `Votre compte est créé : profitez de ${trialDays} jours d’accès Pro pour explorer les outils analytiques.\n\n` +
    `Rendez-vous dans l’application pour commencer.\n\n` +
    `— L’équipe Paychek\n`;

  await sendPaychekMailOutbound(
      {
        from: `"Paychek" <${id.mailFrom}>`,
        to,
        bcc: id.mailBcc,
        replyTo: id.mailFrom,
        subject: "Paychek — Bienvenue",
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
  const subId = session.subscription;
  if (subId && typeof subId === "string") {
    try {
      const sub = await stripe.subscriptions.retrieve(subId);
      if (sub.current_period_end) {
        currentPeriodEnd = admin.firestore.Timestamp.fromMillis(
            sub.current_period_end * 1000,
        );
      }
      if (sub.current_period_start) {
        proSinceUtc = admin.firestore.Timestamp.fromMillis(
            sub.current_period_start * 1000,
        );
      }
    } catch (e) {
      console.warn("paychekStripe: subscription period", e);
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
    const periodEnd = uSnap.data()?.subscriptionCurrentPeriodEnd;
    await paychekSendProAccessConfirmedEmail(db, passRaw, uid, session, periodEnd);
  } catch (e) {
    console.warn("paychekStripeWebhook: e-mail accès Pro", e);
  }
}

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
function buildRefundConfirmedHtml(v) {
  return `<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirmation de Remboursement - PAYCHEK</title>
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
                <div class="status-badge">Information</div>
                <h1>Remboursement — confirmation</h1>
                <p style="color: #888888; font-size: 15px;">Bonjour ${v.firstName}, suite à votre demande, nous vous confirmons un remboursement d’un montant de <strong style="color:#e8e8e8;">${v.amountDisplay}</strong>.</p>
            </div>

            <div class="refund-box">
                <div class="refund-row">
                    <span class="refund-label">Montant du remboursement</span>
                    <span class="refund-value" style="color: #c5a059; font-weight: 700;">${v.amountDisplay}</span>
                </div>
                <div class="refund-row">
                    <span class="refund-label">Date d'approbation</span>
                    <span class="refund-value">${v.approvalDateFr}</span>
                </div>
                <div class="divider"></div>
                <div class="refund-row">
                    <span class="refund-label">Délai estimé</span>
                    <span class="refund-value" style="color: #c5a059;">48h à 72h</span>
                </div>
            </div>

            <div class="note-box">
                <p class="note-text">
                    <strong>Information importante :</strong> le crédit est effectué sur le moyen de paiement utilisé lors de l’achat. Un délai supplémentaire peut être appliqué par votre banque avant l’affichage sur votre compte.
                </p>
            </div>

            <p style="text-align: center; color: #444444; font-size: 11px; margin-top: 50px; line-height: 1.8;">
                Nous vous remercions de votre confiance.<br>
                Votre historique reste consultable dans votre espace personnel.
            </p>
        </div>

        <div class="footer">
            <p>
                <strong>PAYCHEK LABS</strong> — PRECISION & RIGOR.<br><br>
                <a href="${v.supportHref}" style="color: #555555;">Support</a> &nbsp;•&nbsp; <a href="${v.privacyHref}" style="color: #555555;">Confidentialité</a>
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

  const firstNameRaw = paychekRefundGreetingFirstNameFromUserDoc(u);
  const fn = escapeHtml(firstNameRaw);
  const amountDisplay = escapeHtml(amountLabelPlain);
  const approvalDatePlain = new Date().toLocaleDateString("fr-FR", {
    dateStyle: "long",
    timeZone: "Europe/Paris",
  });
  const approvalDateFr = escapeHtml(approvalDatePlain);
  const supportHref = escapeHtml(
      KNOWLEDGE_BASE_URL_FR.replace(/\/+$/, "") + "/",
  );
  const privacyHref = escapeHtml(PAYCHEK_PRIVACY_PAGE_URL_FR);

  const html = buildRefundConfirmedHtml({
    firstName: fn,
    amountDisplay,
    approvalDateFr,
    supportHref,
    privacyHref,
  });

  const text =
    `Bonjour ${firstNameRaw},\n\n` +
    `Nous vous confirmons un remboursement d’un montant de ${amountLabelPlain} suite à votre demande.\n\n` +
    `Date (information) : ${approvalDatePlain}\n` +
    "Délai bancaire habituellement observé : 48h à 72h après traitement par l’établissement payeur.\n\n" +
    "— Paychek\n";

  await sendPaychekMailOutbound(
      {
        from: `"Paychek" <${id.mailFrom}>`,
        to,
        bcc: id.mailBcc,
        replyTo: id.mailFrom,
        subject: "Paychek — Remboursement (information)",
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
