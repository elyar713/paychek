/**
 * Traductions des e-mails transactionnels Paychek (alignées sur l’app :
 * fr, en, de, es, pt, ko).
 */

const PAYCHEK_EMAIL_LOCALES = ["fr", "en", "de", "es", "pt", "ko"];
const DEFAULT_EMAIL_LOCALE = "en";

const BCP47 = {
  fr: "fr-FR",
  en: "en-US",
  de: "de-DE",
  es: "es-ES",
  pt: "pt-PT",
  ko: "ko-KR",
};

const PACKS = {
  fr: {
    responseDelay: "48 heures",
    refundDelay: "48h à 72h",
    kind: {
      account: "Compte",
      billing: "Facturation",
      feature: "Idée / fonctionnalité",
      other: "Autre demande",
    },
    noMessagePreview: "(aucun texte saisi)",
    footerTicketRef: (ref) => `Référence dossier : ${ref}`,
    ackSubjectPrefix: (label) =>
      `[Ticket #${label}] Confirmation de réception de votre demande - `,
    staffReplySubject: (kind, label) =>
      `Paychek — Réponse à votre demande · ${kind} (#${label})`,
    welcomeSubject: "Paychek — Bienvenue",
    proSubject: "Paychek — Accès Pro confirmé",
    refundSubject: "Paychek — Remboursement (information)",
    csat: {
      poor: "Insuffisant",
      ok: "Moyen",
      good: "Bien",
      great: "Excellent",
    },
    attachmentBlock: (name) =>
      `<strong style="color:#ffffff;">Pièce jointe</strong>&nbsp;: ` +
      `${name} — ce fichier est joint à cet e-mail.`,
    ticketStatusPending: "En attente de votre retour",
    ack: {
      greetingNamed: (n) => `Bonjour ${n},`,
      greeting: "Bonjour,",
      body: (sujet, delay, kbUrl, company) =>
        `Nous vous informons que nous avons bien reçu votre demande ` +
        `concernant « ${sujet} ». ` +
        "Un membre de notre équipe technique a été assigné à votre dossier.\n\n" +
        "Récapitulatif de votre ticket :\n\n" +
        "Statut actuel : En cours de traitement\n\n" +
        `Nous nous efforçons de répondre à toutes les demandes sous un délai de ${delay}. ` +
        "En attendant, vous pouvez consulter notre base de connaissances :\n" +
        `${kbUrl}\n\n` +
        "Vous recevrez une notification dès qu'une mise à jour sera disponible. " +
        "Si vous avez des informations complémentaires à ajouter, " +
        `répondez simplement à cet e-mail (ou écrivez-nous depuis l’application ${company}).\n\n` +
        "Cordialement,\n\n" +
        `L'équipe Support ${company}`,
      refLine: (label) => `Numéro de référence : #${label}`,
      openedLine: (d) => `Date d’ouverture : ${d}`,
      htmlTitle: "Ticket de Support PAYCHEK",
      badge: "Requête Reçue",
      h1: "Nous analysons votre demande.",
      htmlGreeting: (n) =>
        `Bonjour ${n}, votre ticket de support a été ouvert.`,
      refLabel: "Référence",
      delayLabel: "Délai estimé",
      previewTitle: "Rappel de votre message",
      footerNote:
        "Vous recevrez une notification dès qu'un analyste aura traité votre dossier. " +
        "Inutile de renvoyer une demande pour la même requête.",
      helpCenter: "Centre d'aide",
      followTicket: "Suivre mon ticket",
    },
    staffReply: {
      htmlTitle: "Réponse — PAYCHEK",
      badge: "Réponse",
      h1: "Mise à jour de votre dossier.",
      intro: (n) =>
        `Bonjour ${n}, un analyste a apporté une réponse à votre demande.`,
      subjectLine: (s) => `Sujet : <strong style="color:#aaaaaa;">«&nbsp;${s}&nbsp;»</strong>`,
      supportLine: "Support — PAYCHEK",
      refLabel: "Référence Ticket",
      footerNote:
        "Si vous avez d'autres questions, répondez simplement à cet e-mail.<br>" +
        "Ce fil de discussion sera automatiquement clos dans 48h sans réponse de votre part.",
      helpCenter: "Centre d'aide",
      myJournal: "Accéder à mon journal",
      textFooter: (label) =>
        `Pour toute précision ou suite à donner à ta demande : merci de ne pas répondre à cet e-mail. ` +
        `Ouvre un nouveau ticket dans l’application Paychek (Réglages · Support) en indiquant la référence #${label}.`,
      thanks: "Merci d'utiliser Paychek.",
      attachmentLine: (fn) => `\n\n— Pièce jointe : ${fn}\n`,
    },
    welcome: {
      htmlTitle: "Bienvenue sur PAYCHEK",
      badge: "Compte Créé",
      h1: "Le trading est une science de la donnée.",
      intro: (n) =>
        `Bonjour ${n}, bienvenue sur l'outil qui va changer votre discipline.`,
      trialTitle: "Offre de Bienvenue",
      trialDays: (d) => `${d} JOURS PRO`,
      trialDesc:
        "Découvrez l'intégralité des outils analytiques PAYCHEK sans aucune restriction.",
      quote: "On ne peut pas améliorer ce que l'on ne mesure pas.",
      feat1Title: "Analyses de Psychologie",
      feat1Desc:
        "Identifiez vos biais cognitifs et vos erreurs récurrentes grâce à nos algorithmes.",
      feat2Title: "Statistiques Avancées",
      feat2Desc:
        "Win-rate, Profit Factor, et Edge Ratio calculés en temps réel sur tous vos trades.",
      noCard: "Aucune carte bancaire requise pour débuter l'essai.",
      support: "Support",
      privacy: "Confidentialité",
      text: (name, days) =>
        `Bonjour ${name},\n\n` +
        `Bienvenue sur Paychek.\n\n` +
        `Votre compte est créé : profitez de ${days} jours d’accès Pro pour explorer les outils analytiques.\n\n` +
        `Rendez-vous dans l’application pour commencer.\n\n` +
        `— L’équipe Paychek\n`,
    },
    pro: {
      htmlTitle: "Accès Pro — PAYCHEK",
      badge: "Activation Immédiate",
      h1: "Bienvenue dans l'accès PRO.",
      intro:
        "Votre abonnement <strong>Pro Access</strong> est désormais opérationnel sur Paychek.",
      clientLabel: "Client",
      planLabel: "Plan Actuel",
      statusLabel: "Statut du Compte",
      statusActive: "ACTIF",
      validUntilLabel: "Valide jusqu'au",
      periodEndUnavailable: "—",
      featTitle: "Analyses Avancées",
      featDesc:
        "Accédez à votre Edge Ratio, vos statistiques de psychologie et vos graphiques de performance en temps réel.",
      txnLine: (s) =>
        `ID Transaction : #PC-${s}<br>` +
        "Une copie de votre facture est disponible dans vos paramètres.",
      text: (client, end, txn) =>
        `Bonjour ${client},\n\n` +
        `Votre accès Pro Paychek est confirmé.\n\n` +
        `Plan : PRO ACCESS\n` +
        `Valide jusqu'au : ${end}\n` +
        `ID transaction : #PC-${txn}\n\n` +
        `Merci d'utiliser Paychek.\n`,
    },
    refund: {
      htmlTitle: "Confirmation de Remboursement - PAYCHEK",
      badge: "Information",
      h1: "Remboursement — confirmation",
      intro: (name, amount) =>
        `Bonjour ${name}, suite à votre demande, nous vous confirmons un remboursement d’un montant de <strong style="color:#e8e8e8;">${amount}</strong>.`,
      amountLabel: "Montant du remboursement",
      approvalLabel: "Date d'approbation",
      delayLabel: "Délai estimé",
      note:
        "<strong>Information importante :</strong> le crédit est effectué sur le moyen de paiement utilisé lors de l’achat. Un délai supplémentaire peut être appliqué par votre banque avant l’affichage sur votre compte.",
      thanks:
        "Nous vous remercions de votre confiance.<br>" +
        "Votre historique reste consultable dans votre espace personnel.",
      text: (name, amount, date, delay) =>
        `Bonjour ${name},\n\n` +
        `Nous vous confirmons un remboursement d’un montant de ${amount} suite à votre demande.\n\n` +
        `Date (information) : ${date}\n` +
        `Délai bancaire habituellement observé : ${delay} après traitement par l’établissement payeur.\n\n` +
        "— Paychek\n",
    },
  },
  en: {
    responseDelay: "48 hours",
    refundDelay: "48–72 hours",
    kind: {
      account: "Account",
      billing: "Billing",
      feature: "Feature idea",
      other: "Other request",
    },
    noMessagePreview: "(no message entered)",
    footerTicketRef: (ref) => `Case reference: ${ref}`,
    ackSubjectPrefix: (label) =>
      `[Ticket #${label}] We received your request - `,
    staffReplySubject: (kind, label) =>
      `Paychek — Reply to your request · ${kind} (#${label})`,
    welcomeSubject: "Paychek — Welcome",
    proSubject: "Paychek — Pro access confirmed",
    refundSubject: "Paychek — Refund (information)",
    csat: {poor: "Poor", ok: "Fair", good: "Good", great: "Excellent"},
    attachmentBlock: (name) =>
      `<strong style="color:#ffffff;">Attachment</strong>&nbsp;: ` +
      `${name} — this file is attached to this email.`,
    ticketStatusPending: "Awaiting your reply",
    ack: {
      greetingNamed: (n) => `Hello ${n},`,
      greeting: "Hello,",
      body: (sujet, delay, kbUrl, company) =>
        `We confirm that we have received your request regarding « ${sujet} ». ` +
        "A member of our technical team has been assigned to your case.\n\n" +
        "Ticket summary:\n\n" +
        "Current status: In progress\n\n" +
        `We aim to respond to all requests within ${delay}. ` +
        "In the meantime, you can visit our knowledge base:\n" +
        `${kbUrl}\n\n` +
        "You will be notified as soon as an update is available. " +
        "If you have additional information, " +
        `simply reply to this email (or contact us from the ${company} app).\n\n` +
        "Best regards,\n\n" +
        `${company} Support Team`,
      refLine: (label) => `Reference number: #${label}`,
      openedLine: (d) => `Opened on: ${d}`,
      htmlTitle: "PAYCHEK Support Ticket",
      badge: "Request Received",
      h1: "We are reviewing your request.",
      htmlGreeting: (n) => `Hello ${n}, your support ticket has been opened.`,
      refLabel: "Reference",
      delayLabel: "Estimated response time",
      previewTitle: "Your message",
      footerNote:
        "You will be notified when an analyst has handled your case. " +
        "Please do not submit a duplicate request for the same issue.",
      helpCenter: "Help center",
      followTicket: "Track my ticket",
    },
    staffReply: {
      htmlTitle: "Reply — PAYCHEK",
      badge: "Reply",
      h1: "Update on your case.",
      intro: (n) => `Hello ${n}, an analyst has replied to your request.`,
      subjectLine: (s) => `Subject: <strong style="color:#aaaaaa;">«&nbsp;${s}&nbsp;»</strong>`,
      supportLine: "Support — PAYCHEK",
      refLabel: "Ticket reference",
      footerNote:
        "If you have further questions, simply reply to this email.<br>" +
        "This thread will close automatically after 48 hours without a reply from you.",
      helpCenter: "Help center",
      myJournal: "Open my journal",
      textFooter: (label) =>
        `For any follow-up, please do not reply to this email. ` +
        `Open a new ticket in the Paychek app (Settings · Support) and include reference #${label}.`,
      thanks: "Thank you for using Paychek.",
      attachmentLine: (fn) => `\n\n— Attachment: ${fn}\n`,
    },
    welcome: {
      htmlTitle: "Welcome to PAYCHEK",
      badge: "Account Created",
      h1: "Trading is a data science.",
      intro: (n) => `Hello ${n}, welcome to the tool that will sharpen your discipline.`,
      trialTitle: "Welcome offer",
      trialDays: (d) => `${d} DAYS PRO`,
      trialDesc: "Explore all PAYCHEK analytics tools with no restrictions.",
      quote: "You cannot improve what you do not measure.",
      feat1Title: "Psychology insights",
      feat1Desc: "Spot cognitive biases and recurring mistakes with our algorithms.",
      feat2Title: "Advanced statistics",
      feat2Desc: "Win rate, profit factor, and edge ratio computed in real time.",
      noCard: "No credit card required to start your trial.",
      support: "Support",
      privacy: "Privacy",
      text: (name, days) =>
        `Hello ${name},\n\n` +
        `Welcome to Paychek.\n\n` +
        `Your account is ready: enjoy ${days} days of Pro access to explore our analytics tools.\n\n` +
        `Open the app to get started.\n\n` +
        `— The Paychek team\n`,
    },
    pro: {
      htmlTitle: "Pro access — PAYCHEK",
      badge: "Instant activation",
      h1: "Welcome to PRO access.",
      intro:
        "Your <strong>Pro Access</strong> subscription is now active on Paychek.",
      clientLabel: "Client",
      planLabel: "Current plan",
      statusLabel: "Account status",
      statusActive: "ACTIVE",
      validUntilLabel: "Valid until",
      periodEndUnavailable: "—",
      featTitle: "Advanced analytics",
      featDesc:
        "Access your edge ratio, psychology stats, and performance charts in real time.",
      txnLine: (s) =>
        `Transaction ID: #PC-${s}<br>` +
        "A copy of your invoice is available in your settings.",
      text: (client, end, txn) =>
        `Hello ${client},\n\n` +
        `Your Paychek Pro access is confirmed.\n\n` +
        `Plan: PRO ACCESS\n` +
        `Valid until: ${end}\n` +
        `Transaction ID: #PC-${txn}\n\n` +
        `Thank you for using Paychek.\n`,
    },
    refund: {
      htmlTitle: "Refund confirmation - PAYCHEK",
      badge: "Information",
      h1: "Refund — confirmation",
      intro: (name, amount) =>
        `Hello ${name}, following your request, we confirm a refund of <strong style="color:#e8e8e8;">${amount}</strong>.`,
      amountLabel: "Refund amount",
      approvalLabel: "Approval date",
      delayLabel: "Estimated delay",
      note:
        "<strong>Important:</strong> the credit is issued to the payment method used for purchase. Your bank may take additional time before it appears on your account.",
      thanks:
        "Thank you for your trust.<br>" +
        "Your history remains available in your personal space.",
      text: (name, amount, date, delay) =>
        `Hello ${name},\n\n` +
        `We confirm a refund of ${amount} following your request.\n\n` +
        `Date (information): ${date}\n` +
        `Typical bank processing time: ${delay} after the payer institution processes it.\n\n` +
        "— Paychek\n",
    },
  },
  de: {
    responseDelay: "48 Stunden",
    refundDelay: "48–72 Stunden",
    kind: {
      account: "Konto",
      billing: "Abrechnung",
      feature: "Funktionsidee",
      other: "Sonstige Anfrage",
    },
    noMessagePreview: "(kein Text eingegeben)",
    footerTicketRef: (ref) => `Vorgangsreferenz: ${ref}`,
    ackSubjectPrefix: (label) =>
      `[Ticket #${label}] Wir haben Ihre Anfrage erhalten - `,
    staffReplySubject: (kind, label) =>
      `Paychek — Antwort auf Ihre Anfrage · ${kind} (#${label})`,
    welcomeSubject: "Paychek — Willkommen",
    proSubject: "Paychek — Pro-Zugang bestätigt",
    refundSubject: "Paychek — Erstattung (Information)",
    csat: {poor: "Unzureichend", ok: "Mittel", good: "Gut", great: "Ausgezeichnet"},
    attachmentBlock: (name) =>
      `<strong style="color:#ffffff;">Anhang</strong>&nbsp;: ` +
      `${name} — diese Datei ist dieser E-Mail beigefügt.`,
    ticketStatusPending: "Warten auf Ihre Rückmeldung",
    ack: {
      greetingNamed: (n) => `Hallo ${n},`,
      greeting: "Hallo,",
      body: (sujet, delay, kbUrl, company) =>
        `Wir bestätigen den Eingang Ihrer Anfrage zu « ${sujet} ». ` +
        "Ein Techniker wurde Ihrem Vorgang zugewiesen.\n\n" +
        "Ticket-Zusammenfassung:\n\n" +
        "Aktueller Status: In Bearbeitung\n\n" +
        `Wir bemühen uns, alle Anfragen innerhalb von ${delay} zu beantworten. ` +
        "In der Zwischenzeit können Sie unsere Wissensdatenbank besuchen:\n" +
        `${kbUrl}\n\n` +
        "Sie werden benachrichtigt, sobald ein Update verfügbar ist. " +
        "Bei Zusatzinformationen antworten Sie auf diese E-Mail " +
        `(oder schreiben Sie uns in der ${company}-App).\n\n` +
        "Mit freundlichen Grüßen\n\n" +
        `${company} Support`,
      refLine: (label) => `Referenznummer: #${label}`,
      openedLine: (d) => `Eröffnet am: ${d}`,
      htmlTitle: "PAYCHEK Support-Ticket",
      badge: "Anfrage erhalten",
      h1: "Wir prüfen Ihre Anfrage.",
      htmlGreeting: (n) => `Hallo ${n}, Ihr Support-Ticket wurde eröffnet.`,
      refLabel: "Referenz",
      delayLabel: "Geschätzte Antwortzeit",
      previewTitle: "Ihre Nachricht",
      footerNote:
        "Sie werden benachrichtigt, sobald ein Analyst Ihren Vorgang bearbeitet hat. " +
        "Bitte senden Sie keine doppelte Anfrage zum gleichen Thema.",
      helpCenter: "Hilfe-Center",
      followTicket: "Ticket verfolgen",
    },
    staffReply: {
      htmlTitle: "Antwort — PAYCHEK",
      badge: "Antwort",
      h1: "Aktualisierung Ihres Vorgangs.",
      intro: (n) => `Hallo ${n}, ein Analyst hat auf Ihre Anfrage geantwortet.`,
      subjectLine: (s) => `Betreff: <strong style="color:#aaaaaa;">«&nbsp;${s}&nbsp;»</strong>`,
      supportLine: "Support — PAYCHEK",
      refLabel: "Ticket-Referenz",
      footerNote:
        "Bei weiteren Fragen antworten Sie einfach auf diese E-Mail.<br>" +
        "Dieser Thread wird nach 48 Stunden ohne Ihre Antwort automatisch geschlossen.",
      helpCenter: "Hilfe-Center",
      myJournal: "Mein Journal öffnen",
      textFooter: (label) =>
        `Für Rückfragen antworten Sie bitte nicht auf diese E-Mail. ` +
        `Öffnen Sie ein neues Ticket in der Paychek-App (Einstellungen · Support) mit Referenz #${label}.`,
      thanks: "Danke, dass Sie Paychek nutzen.",
      attachmentLine: (fn) => `\n\n— Anhang: ${fn}\n`,
    },
    welcome: {
      htmlTitle: "Willkommen bei PAYCHEK",
      badge: "Konto erstellt",
      h1: "Trading ist Datenwissenschaft.",
      intro: (n) => `Hallo ${n}, willkommen beim Tool für mehr Disziplin.`,
      trialTitle: "Willkommensangebot",
      trialDays: (d) => `${d} TAGE PRO`,
      trialDesc: "Entdecken Sie alle PAYCHEK-Analysetools ohne Einschränkung.",
      quote: "Man kann nur verbessern, was man misst.",
      feat1Title: "Psychologie-Analysen",
      feat1Desc: "Erkennen Sie kognitive Verzerrungen und wiederkehrende Fehler.",
      feat2Title: "Erweiterte Statistiken",
      feat2Desc: "Win-Rate, Profit Factor und Edge Ratio in Echtzeit.",
      noCard: "Keine Kreditkarte für den Teststart erforderlich.",
      support: "Support",
      privacy: "Datenschutz",
      text: (name, days) =>
        `Hallo ${name},\n\n` +
        `Willkommen bei Paychek.\n\n` +
        `Ihr Konto ist bereit: ${days} Tage Pro-Zugang für unsere Analysetools.\n\n` +
        `Öffnen Sie die App, um zu starten.\n\n` +
        `— Das Paychek-Team\n`,
    },
    pro: {
      htmlTitle: "Pro-Zugang — PAYCHEK",
      badge: "Sofortige Aktivierung",
      h1: "Willkommen beim PRO-Zugang.",
      intro: "Ihr <strong>Pro Access</strong>-Abo ist auf Paychek aktiv.",
      clientLabel: "Kunde",
      planLabel: "Aktueller Plan",
      statusLabel: "Kontostatus",
      statusActive: "AKTIV",
      validUntilLabel: "Gültig bis",
      periodEndUnavailable: "—",
      featTitle: "Erweiterte Analysen",
      featDesc: "Edge Ratio, Psychologie-Statistiken und Performance-Charts in Echtzeit.",
      txnLine: (s) =>
        `Transaktions-ID: #PC-${s}<br>` +
        "Eine Rechnungskopie finden Sie in den Einstellungen.",
      text: (client, end, txn) =>
        `Hallo ${client},\n\n` +
        `Ihr Paychek Pro-Zugang ist bestätigt.\n\n` +
        `Plan: PRO ACCESS\n` +
        `Gültig bis: ${end}\n` +
        `Transaktions-ID: #PC-${txn}\n\n` +
        `Danke, dass Sie Paychek nutzen.\n`,
    },
    refund: {
      htmlTitle: "Erstattungsbestätigung - PAYCHEK",
      badge: "Information",
      h1: "Erstattung — Bestätigung",
      intro: (name, amount) =>
        `Hallo ${name}, wir bestätigen eine Erstattung von <strong style="color:#e8e8e8;">${amount}</strong>.`,
      amountLabel: "Erstattungsbetrag",
      approvalLabel: "Genehmigungsdatum",
      delayLabel: "Geschätzte Dauer",
      note:
        "<strong>Wichtig:</strong> Die Gutschrift erfolgt auf das beim Kauf verwendete Zahlungsmittel. Ihre Bank kann zusätzliche Zeit benötigen.",
      thanks:
        "Vielen Dank für Ihr Vertrauen.<br>" +
        "Ihr Verlauf bleibt in Ihrem persönlichen Bereich einsehbar.",
      text: (name, amount, date, delay) =>
        `Hallo ${name},\n\n` +
        `Wir bestätigen eine Erstattung von ${amount}.\n\n` +
        `Datum (Information): ${date}\n` +
        `Übliche Bankbearbeitung: ${delay} nach Verarbeitung.\n\n` +
        "— Paychek\n",
    },
  },
  es: {
    responseDelay: "48 horas",
    refundDelay: "48–72 horas",
    kind: {
      account: "Cuenta",
      billing: "Facturación",
      feature: "Idea de función",
      other: "Otra solicitud",
    },
    noMessagePreview: "(sin texto)",
    footerTicketRef: (ref) => `Referencia del caso: ${ref}`,
    ackSubjectPrefix: (label) =>
      `[Ticket #${label}] Hemos recibido su solicitud - `,
    staffReplySubject: (kind, label) =>
      `Paychek — Respuesta a su solicitud · ${kind} (#${label})`,
    welcomeSubject: "Paychek — Bienvenido",
    proSubject: "Paychek — Acceso Pro confirmado",
    refundSubject: "Paychek — Reembolso (información)",
    csat: {poor: "Insuficiente", ok: "Regular", good: "Bien", great: "Excelente"},
    attachmentBlock: (name) =>
      `<strong style="color:#ffffff;">Adjunto</strong>&nbsp;: ` +
      `${name} — este archivo está adjunto a este correo.`,
    ticketStatusPending: "En espera de su respuesta",
    ack: {
      greetingNamed: (n) => `Hola ${n},`,
      greeting: "Hola,",
      body: (sujet, delay, kbUrl, company) =>
        `Confirmamos la recepción de su solicitud sobre « ${sujet} ». ` +
        "Un miembro de nuestro equipo técnico ha sido asignado a su caso.\n\n" +
        "Resumen del ticket:\n\n" +
        "Estado actual: En curso\n\n" +
        `Intentamos responder en un plazo de ${delay}. ` +
        "Mientras tanto, puede consultar nuestra base de conocimientos:\n" +
        `${kbUrl}\n\n` +
        "Le notificaremos cuando haya una actualización. " +
        `Responda a este correo o escríbanos desde la app ${company}.\n\n` +
        "Atentamente,\n\n" +
        `Equipo de soporte ${company}`,
      refLine: (label) => `Número de referencia: #${label}`,
      openedLine: (d) => `Abierto el: ${d}`,
      htmlTitle: "Ticket de soporte PAYCHEK",
      badge: "Solicitud recibida",
      h1: "Estamos analizando su solicitud.",
      htmlGreeting: (n) => `Hola ${n}, su ticket de soporte ha sido abierto.`,
      refLabel: "Referencia",
      delayLabel: "Plazo estimado",
      previewTitle: "Su mensaje",
      footerNote:
        "Le avisaremos cuando un analista haya tratado su caso. " +
        "No envíe una solicitud duplicada para el mismo asunto.",
      helpCenter: "Centro de ayuda",
      followTicket: "Seguir mi ticket",
    },
    staffReply: {
      htmlTitle: "Respuesta — PAYCHEK",
      badge: "Respuesta",
      h1: "Actualización de su caso.",
      intro: (n) => `Hola ${n}, un analista ha respondido a su solicitud.`,
      subjectLine: (s) => `Asunto: <strong style="color:#aaaaaa;">«&nbsp;${s}&nbsp;»</strong>`,
      supportLine: "Soporte — PAYCHEK",
      refLabel: "Referencia del ticket",
      footerNote:
        "Si tiene más preguntas, responda a este correo.<br>" +
        "Este hilo se cerrará automáticamente a las 48 h sin respuesta suya.",
      helpCenter: "Centro de ayuda",
      myJournal: "Abrir mi diario",
      textFooter: (label) =>
        `Para cualquier seguimiento, no responda a este correo. ` +
        `Abra un nuevo ticket en la app Paychek (Ajustes · Soporte) con la referencia #${label}.`,
      thanks: "Gracias por usar Paychek.",
      attachmentLine: (fn) => `\n\n— Adjunto: ${fn}\n`,
    },
    welcome: {
      htmlTitle: "Bienvenido a PAYCHEK",
      badge: "Cuenta creada",
      h1: "El trading es ciencia de datos.",
      intro: (n) => `Hola ${n}, bienvenido a la herramienta para su disciplina.`,
      trialTitle: "Oferta de bienvenida",
      trialDays: (d) => `${d} DÍAS PRO`,
      trialDesc: "Explore todas las herramientas analíticas PAYCHEK sin restricciones.",
      quote: "No se puede mejorar lo que no se mide.",
      feat1Title: "Análisis de psicología",
      feat1Desc: "Identifique sesgos cognitivos y errores recurrentes.",
      feat2Title: "Estadísticas avanzadas",
      feat2Desc: "Win rate, profit factor y edge ratio en tiempo real.",
      noCard: "No se requiere tarjeta para iniciar la prueba.",
      support: "Soporte",
      privacy: "Privacidad",
      text: (name, days) =>
        `Hola ${name},\n\n` +
        `Bienvenido a Paychek.\n\n` +
        `Su cuenta está lista: ${days} días de acceso Pro para explorar las herramientas.\n\n` +
        `Abra la aplicación para empezar.\n\n` +
        `— El equipo Paychek\n`,
    },
    pro: {
      htmlTitle: "Acceso Pro — PAYCHEK",
      badge: "Activación inmediata",
      h1: "Bienvenido al acceso PRO.",
      intro: "Su suscripción <strong>Pro Access</strong> está activa en Paychek.",
      clientLabel: "Cliente",
      planLabel: "Plan actual",
      statusLabel: "Estado de la cuenta",
      statusActive: "ACTIVO",
      validUntilLabel: "Válido hasta",
      periodEndUnavailable: "—",
      featTitle: "Análisis avanzados",
      featDesc: "Edge ratio, estadísticas de psicología y gráficos en tiempo real.",
      txnLine: (s) =>
        `ID de transacción: #PC-${s}<br>` +
        "Una copia de su factura está en los ajustes.",
      text: (client, end, txn) =>
        `Hola ${client},\n\n` +
        `Su acceso Pro Paychek está confirmado.\n\n` +
        `Plan: PRO ACCESS\n` +
        `Válido hasta: ${end}\n` +
        `ID de transacción: #PC-${txn}\n\n` +
        `Gracias por usar Paychek.\n`,
    },
    refund: {
      htmlTitle: "Confirmación de reembolso - PAYCHEK",
      badge: "Información",
      h1: "Reembolso — confirmación",
      intro: (name, amount) =>
        `Hola ${name}, confirmamos un reembolso de <strong style="color:#e8e8e8;">${amount}</strong>.`,
      amountLabel: "Importe del reembolso",
      approvalLabel: "Fecha de aprobación",
      delayLabel: "Plazo estimado",
      note:
        "<strong>Importante:</strong> el abono se realiza al medio de pago usado en la compra. Su banco puede tardar más.",
      thanks:
        "Gracias por su confianza.<br>" +
        "Su historial sigue disponible en su espacio personal.",
      text: (name, amount, date, delay) =>
        `Hola ${name},\n\n` +
        `Confirmamos un reembolso de ${amount}.\n\n` +
        `Fecha (información): ${date}\n` +
        `Plazo bancario habitual: ${delay} tras el procesamiento.\n\n` +
        "— Paychek\n",
    },
  },
  pt: {
    responseDelay: "48 horas",
    refundDelay: "48–72 horas",
    kind: {
      account: "Conta",
      billing: "Faturação",
      feature: "Ideia de funcionalidade",
      other: "Outro pedido",
    },
    noMessagePreview: "(sem texto)",
    footerTicketRef: (ref) => `Referência do caso: ${ref}`,
    ackSubjectPrefix: (label) =>
      `[Ticket #${label}] Recebemos o seu pedido - `,
    staffReplySubject: (kind, label) =>
      `Paychek — Resposta ao seu pedido · ${kind} (#${label})`,
    welcomeSubject: "Paychek — Bem-vindo",
    proSubject: "Paychek — Acesso Pro confirmado",
    refundSubject: "Paychek — Reembolso (informação)",
    csat: {poor: "Insuficiente", ok: "Médio", good: "Bom", great: "Excelente"},
    attachmentBlock: (name) =>
      `<strong style="color:#ffffff;">Anexo</strong>&nbsp;: ` +
      `${name} — este ficheiro está anexado a este e-mail.`,
    ticketStatusPending: "À espera da sua resposta",
    ack: {
      greetingNamed: (n) => `Olá ${n},`,
      greeting: "Olá,",
      body: (sujet, delay, kbUrl, company) =>
        `Confirmamos a receção do seu pedido sobre « ${sujet} ». ` +
        "Um membro da nossa equipa técnica foi atribuído ao seu caso.\n\n" +
        "Resumo do ticket:\n\n" +
        "Estado atual: Em curso\n\n" +
        `Procuramos responder no prazo de ${delay}. ` +
        "Entretanto, pode consultar a nossa base de conhecimento:\n" +
        `${kbUrl}\n\n` +
        "Será notificado quando houver uma atualização. " +
        `Responda a este e-mail ou contacte-nos na app ${company}.\n\n` +
        "Com os melhores cumprimentos,\n\n" +
        `Equipa de suporte ${company}`,
      refLine: (label) => `Número de referência: #${label}`,
      openedLine: (d) => `Aberto em: ${d}`,
      htmlTitle: "Ticket de suporte PAYCHEK",
      badge: "Pedido recebido",
      h1: "Estamos a analisar o seu pedido.",
      htmlGreeting: (n) => `Olá ${n}, o seu ticket de suporte foi aberto.`,
      refLabel: "Referência",
      delayLabel: "Prazo estimado",
      previewTitle: "A sua mensagem",
      footerNote:
        "Será notificado quando um analista tratar o seu caso. " +
        "Não envie um pedido duplicado para o mesmo assunto.",
      helpCenter: "Centro de ajuda",
      followTicket: "Acompanhar o meu ticket",
    },
    staffReply: {
      htmlTitle: "Resposta — PAYCHEK",
      badge: "Resposta",
      h1: "Atualização do seu caso.",
      intro: (n) => `Olá ${n}, um analista respondeu ao seu pedido.`,
      subjectLine: (s) => `Assunto: <strong style="color:#aaaaaa;">«&nbsp;${s}&nbsp;»</strong>`,
      supportLine: "Suporte — PAYCHEK",
      refLabel: "Referência do ticket",
      footerNote:
        "Se tiver mais perguntas, responda a este e-mail.<br>" +
        "Este tópico fecha automaticamente após 48 h sem resposta sua.",
      helpCenter: "Centro de ajuda",
      myJournal: "Abrir o meu diário",
      textFooter: (label) =>
        `Para seguimento, não responda a este e-mail. ` +
        `Abra um novo ticket na app Paychek (Definições · Suporte) com a referência #${label}.`,
      thanks: "Obrigado por usar o Paychek.",
      attachmentLine: (fn) => `\n\n— Anexo: ${fn}\n`,
    },
    welcome: {
      htmlTitle: "Bem-vindo ao PAYCHEK",
      badge: "Conta criada",
      h1: "O trading é ciência de dados.",
      intro: (n) => `Olá ${n}, bem-vindo à ferramenta para a sua disciplina.`,
      trialTitle: "Oferta de boas-vindas",
      trialDays: (d) => `${d} DIAS PRO`,
      trialDesc: "Explore todas as ferramentas analíticas PAYCHEK sem restrições.",
      quote: "Não se melhora o que não se mede.",
      feat1Title: "Análises de psicologia",
      feat1Desc: "Identifique vieses cognitivos e erros recorrentes.",
      feat2Title: "Estatísticas avançadas",
      feat2Desc: "Win rate, profit factor e edge ratio em tempo real.",
      noCard: "Sem cartão de crédito para iniciar o teste.",
      support: "Suporte",
      privacy: "Privacidade",
      text: (name, days) =>
        `Olá ${name},\n\n` +
        `Bem-vindo ao Paychek.\n\n` +
        `A sua conta está pronta: ${days} dias de acesso Pro para explorar as ferramentas.\n\n` +
        `Abra a aplicação para começar.\n\n` +
        `— A equipa Paychek\n`,
    },
    pro: {
      htmlTitle: "Acesso Pro — PAYCHEK",
      badge: "Ativação imediata",
      h1: "Bem-vindo ao acesso PRO.",
      intro: "A sua subscrição <strong>Pro Access</strong> está ativa no Paychek.",
      clientLabel: "Cliente",
      planLabel: "Plano atual",
      statusLabel: "Estado da conta",
      statusActive: "ATIVO",
      validUntilLabel: "Válido até",
      periodEndUnavailable: "—",
      featTitle: "Análises avançadas",
      featDesc: "Edge ratio, estatísticas de psicologia e gráficos em tempo real.",
      txnLine: (s) =>
        `ID da transação: #PC-${s}<br>` +
        "Uma cópia da fatura está nas definições.",
      text: (client, end, txn) =>
        `Olá ${client},\n\n` +
        `O seu acesso Pro Paychek está confirmado.\n\n` +
        `Plano: PRO ACCESS\n` +
        `Válido até: ${end}\n` +
        `ID da transação: #PC-${txn}\n\n` +
        `Obrigado por usar o Paychek.\n`,
    },
    refund: {
      htmlTitle: "Confirmação de reembolso - PAYCHEK",
      badge: "Informação",
      h1: "Reembolso — confirmação",
      intro: (name, amount) =>
        `Olá ${name}, confirmamos um reembolso de <strong style="color:#e8e8e8;">${amount}</strong>.`,
      amountLabel: "Montante do reembolso",
      approvalLabel: "Data de aprovação",
      delayLabel: "Prazo estimado",
      note:
        "<strong>Importante:</strong> o crédito é feito no meio de pagamento usado na compra. O seu banco pode demorar mais.",
      thanks:
        "Obrigado pela sua confiança.<br>" +
        "O seu histórico permanece no seu espaço pessoal.",
      text: (name, amount, date, delay) =>
        `Olá ${name},\n\n` +
        `Confirmamos um reembolso de ${amount}.\n\n` +
        `Data (informação): ${date}\n` +
        `Prazo bancário habitual: ${delay} após processamento.\n\n` +
        "— Paychek\n",
    },
  },
  ko: {
    responseDelay: "48시간",
    refundDelay: "48~72시간",
    kind: {
      account: "계정",
      billing: "결제",
      feature: "기능 아이디어",
      other: "기타 문의",
    },
    noMessagePreview: "(입력된 내용 없음)",
    footerTicketRef: (ref) => `케이스 참조: ${ref}`,
    ackSubjectPrefix: (label) =>
      `[티켓 #${label}] 요청이 접수되었습니다 - `,
    staffReplySubject: (kind, label) =>
      `Paychek — 문의 답변 · ${kind} (#${label})`,
    welcomeSubject: "Paychek — 환영합니다",
    proSubject: "Paychek — Pro 액세스 확인",
    refundSubject: "Paychek — 환불 (안내)",
    csat: {poor: "부족", ok: "보통", good: "좋음", great: "우수"},
    attachmentBlock: (name) =>
      `<strong style="color:#ffffff;">첨부 파일</strong>&nbsp;: ` +
      `${name} — 이 파일이 이 이메일에 첨부되어 있습니다.`,
    ticketStatusPending: "회신 대기 중",
    ack: {
      greetingNamed: (n) => `안녕하세요 ${n}님,`,
      greeting: "안녕하세요,",
      body: (sujet, delay, kbUrl, company) =>
        `「${sujet}」에 대한 요청이 접수되었음을 알려 드립니다. ` +
        "기술 팀 담당자가 배정되었습니다.\n\n" +
        "티켓 요약:\n\n" +
        "현재 상태: 처리 중\n\n" +
        `모든 문의에 ${delay} 이내 답변을 드리도록 노력합니다. ` +
        "그동안 지식 베이스를 참고하실 수 있습니다:\n" +
        `${kbUrl}\n\n` +
        "업데이트가 있으면 알려 드립니다. " +
        `이 이메일에 답장하거나 ${company} 앱에서 문의해 주세요.\n\n` +
        "감사합니다.\n\n" +
        `${company} 지원팀`,
      refLine: (label) => `참조 번호: #${label}`,
      openedLine: (d) => `접수일: ${d}`,
      htmlTitle: "PAYCHEK 지원 티켓",
      badge: "요청 접수",
      h1: "요청을 검토 중입니다.",
      htmlGreeting: (n) => `안녕하세요 ${n}님, 지원 티켓이 열렸습니다.`,
      refLabel: "참조",
      delayLabel: "예상 응답 시간",
      previewTitle: "메시지 내용",
      footerNote:
        "분석가가 처리하면 알려 드립니다. " +
        "동일한 문의를 중복 제출하지 마세요.",
      helpCenter: "도움말 센터",
      followTicket: "티켓 추적",
    },
    staffReply: {
      htmlTitle: "답변 — PAYCHEK",
      badge: "답변",
      h1: "케이스 업데이트.",
      intro: (n) => `안녕하세요 ${n}님, 분석가가 문의에 답변했습니다.`,
      subjectLine: (s) => `제목: <strong style="color:#aaaaaa;">«&nbsp;${s}&nbsp;»</strong>`,
      supportLine: "지원 — PAYCHEK",
      refLabel: "티켓 참조",
      footerNote:
        "추가 질문이 있으면 이 이메일에 답장하세요.<br>" +
        "48시간 내 회신이 없으면 이 스레드는 자동으로 종료됩니다.",
      helpCenter: "도움말 센터",
      myJournal: "저널 열기",
      textFooter: (label) =>
        `후속 문의는 이 이메일에 답장하지 마세요. ` +
        `Paychek 앱(설정 · 지원)에서 참조 #${label}를 포함해 새 티켓을 열어 주세요.`,
      thanks: "Paychek를 이용해 주셔서 감사합니다.",
      attachmentLine: (fn) => `\n\n— 첨부: ${fn}\n`,
    },
    welcome: {
      htmlTitle: "PAYCHEK에 오신 것을 환영합니다",
      badge: "계정 생성됨",
      h1: "트레이딩은 데이터 과학입니다.",
      intro: (n) => `안녕하세요 ${n}님, 규율을 위한 도구에 오신 것을 환영합니다.`,
      trialTitle: "환영 혜택",
      trialDays: (d) => `${d}일 PRO`,
      trialDesc: "제한 없이 PAYCHEK 분석 도구를 이용해 보세요.",
      quote: "측정하지 않으면 개선할 수 없습니다.",
      feat1Title: "심리 분석",
      feat1Desc: "인지 편향과 반복 오류를 알고리즘으로 파악합니다.",
      feat2Title: "고급 통계",
      feat2Desc: "승률, profit factor, edge ratio를 실시간으로 계산합니다.",
      noCard: "체험 시작에 신용카드가 필요하지 않습니다.",
      support: "지원",
      privacy: "개인정보",
      text: (name, days) =>
        `안녕하세요 ${name}님,\n\n` +
        `Paychek에 오신 것을 환영합니다.\n\n` +
        `계정이 준비되었습니다: ${days}일간 Pro 액세스로 분석 도구를 탐색하세요.\n\n` +
        `앱에서 시작하세요.\n\n` +
        `— Paychek 팀\n`,
    },
    pro: {
      htmlTitle: "Pro 액세스 — PAYCHEK",
      badge: "즉시 활성화",
      h1: "PRO 액세스에 오신 것을 환영합니다.",
      intro: "Paychek에서 <strong>Pro Access</strong> 구독이 활성화되었습니다.",
      clientLabel: "고객",
      planLabel: "현재 플랜",
      statusLabel: "계정 상태",
      statusActive: "활성",
      validUntilLabel: "유효 기간",
      periodEndUnavailable: "—",
      featTitle: "고급 분석",
      featDesc: "edge ratio, 심리 통계, 실시간 성과 차트를 이용하세요.",
      txnLine: (s) =>
        `거래 ID: #PC-${s}<br>` +
        "설정에서 청구서 사본을 확인할 수 있습니다.",
      text: (client, end, txn) =>
        `안녕하세요 ${client}님,\n\n` +
        `Paychek Pro 액세스가 확인되었습니다.\n\n` +
        `플랜: PRO ACCESS\n` +
        `유효 기간: ${end}\n` +
        `거래 ID: #PC-${txn}\n\n` +
        `Paychek를 이용해 주셔서 감사합니다.\n`,
    },
    refund: {
      htmlTitle: "환불 확인 - PAYCHEK",
      badge: "안내",
      h1: "환불 — 확인",
      intro: (name, amount) =>
        `안녕하세요 ${name}님, 요청에 따라 <strong style="color:#e8e8e8;">${amount}</strong> 환불을 확인합니다.`,
      amountLabel: "환불 금액",
      approvalLabel: "승인일",
      delayLabel: "예상 소요",
      note:
        "<strong>안내:</strong> 구매 시 사용한 결제 수단으로 환급됩니다. 은행 처리에 추가 시간이 걸릴 수 있습니다.",
      thanks:
        "신뢰해 주셔서 감사합니다.<br>" +
        "기록은 개인 공간에서 계속 확인할 수 있습니다.",
      text: (name, amount, date, delay) =>
        `안녕하세요 ${name}님,\n\n` +
        `${amount} 환불을 확인합니다.\n\n` +
        `날짜(안내): ${date}\n` +
        `일반적인 은행 처리: 결제 기관 처리 후 ${delay}\n\n` +
        "— Paychek\n",
    },
  },
};

function normalizePaychekEmailLocale(code) {
  const c = `${code ?? ""}`.trim().toLowerCase();
  return PAYCHEK_EMAIL_LOCALES.includes(c) ? c : DEFAULT_EMAIL_LOCALE;
}

function pack(locale) {
  const loc = normalizePaychekEmailLocale(locale);
  return PACKS[loc] || PACKS[DEFAULT_EMAIL_LOCALE];
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {Record<string, unknown>|undefined|null} ticketData
 */
async function paychekResolveEmailLocale(db, uid, ticketData) {
  const fromTicket = `${ticketData?.appLanguageCode ?? ""}`.trim().toLowerCase();
  if (PAYCHEK_EMAIL_LOCALES.includes(fromTicket)) return fromTicket;

  const id = `${uid ?? ticketData?.userId ?? ""}`.trim();
  if (!id || !db) return DEFAULT_EMAIL_LOCALE;

  try {
    const snap = await db.collection("paychek_users").doc(id).get();
    if (snap.exists) {
      const code = `${snap.data()?.appLanguageCode ?? ""}`.trim().toLowerCase();
      if (PAYCHEK_EMAIL_LOCALES.includes(code)) return code;
    }
  } catch (e) {
    console.warn("paychekResolveEmailLocale:", e);
  }
  return DEFAULT_EMAIL_LOCALE;
}

function kindLabel(locale, kindRaw) {
  const k = `${kindRaw ?? ""}`.trim();
  const p = pack(locale).kind;
  switch (k) {
  case "account":
    return p.account;
  case "billing":
    return p.billing;
  case "feature":
    return p.feature;
  case "other":
  default:
    return k === "" ? p.other : k;
  }
}

function formatOpeningDate(locale, createdAt) {
  let d;
  if (createdAt && typeof createdAt.toDate === "function") {
    d = createdAt.toDate();
  } else {
    d = new Date();
  }
  const loc = normalizePaychekEmailLocale(locale);
  const bcp = BCP47[loc] || BCP47.en;
  return d.toLocaleString(bcp, {
    dateStyle: "long",
    timeStyle: "short",
    timeZone: "Europe/Paris",
  });
}

function formatApprovalDate(locale, date) {
  const d = date instanceof Date ? date : new Date();
  const loc = normalizePaychekEmailLocale(locale);
  const bcp = BCP47[loc] || BCP47.en;
  return d.toLocaleDateString(bcp, {
    dateStyle: "long",
    timeZone: "Europe/Paris",
  });
}

function paychekFormatPeriodEndDate(locale, periodEndTs) {
  const loc = normalizePaychekEmailLocale(locale);
  const fallback = pack(loc).pro.periodEndUnavailable;
  if (periodEndTs == null) return fallback;

  let d = null;
  if (periodEndTs instanceof Date) {
    d = periodEndTs;
  } else if (typeof periodEndTs.toDate === "function") {
    try {
      d = periodEndTs.toDate();
    } catch (_) {
      d = null;
    }
  } else if (typeof periodEndTs === "object" && typeof periodEndTs.seconds === "number") {
    d = new Date(
        periodEndTs.seconds * 1000 +
        Math.floor((periodEndTs.nanoseconds || 0) / 1e6),
    );
  }

  if (!d || Number.isNaN(d.getTime())) return fallback;
  return formatApprovalDate(loc, d);
}

module.exports = {
  PAYCHEK_EMAIL_LOCALES,
  DEFAULT_EMAIL_LOCALE,
  normalizePaychekEmailLocale,
  paychekResolveEmailLocale,
  pack,
  kindLabel,
  formatOpeningDate,
  formatApprovalDate,
  paychekFormatPeriodEndDate,
};
