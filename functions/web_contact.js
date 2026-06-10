/**
 * Formulaire contact web (landing) → même collection que Support & Feedback app.
 */

function paychekWebContactTicketRef() {
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let out = "PC-";
  for (let i = 0; i < 8; i++) {
    out += alphabet[Math.floor(Math.random() * alphabet.length)];
  }
  return out;
}

function paychekWebContactKindFromSubject(subject) {
  const s = `${subject ?? ""}`.trim().toLowerCase();
  if (s.includes("support") || s.includes("aide")) return "account";
  if (s.includes("bug")) return "other";
  if (s.includes("suggestion") || s.includes("feedback")) return "feature";
  if (s.includes("affiliation") || s.includes("affiliate")) return "other";
  if (s.includes("billing") || s.includes("facturation")) return "billing";
  return "other";
}

function createWebContactExports(deps) {
  const {onCall, HttpsError, admin} = deps;
  const STAFF_INBOX = "contact@paychek.pro";

  const submitPaychekWebContact = onCall(
      {
        region: "europe-west1",
        timeoutSeconds: 30,
        memory: "256MiB",
        invoker: "public",
      },
      async (request) => {
        const name = `${request.data?.name ?? ""}`.trim().slice(0, 120);
        const email = `${request.data?.email ?? ""}`.trim().toLowerCase();
        const subject = `${request.data?.subject ?? ""}`.trim().slice(0, 80);
        const message = `${request.data?.message ?? ""}`.trim();
        const localeRaw = `${request.data?.locale ?? "en"}`.trim().slice(0, 8);
        const locale = ["fr", "en", "de", "es", "pt", "ko"].includes(localeRaw.toLowerCase())
          ? localeRaw.toLowerCase()
          : "en";

        if (!email.includes("@") || email.length > 320) {
          throw new HttpsError("invalid-argument", "E-mail invalide.");
        }
        if (message.length < 8) {
          throw new HttpsError(
              "invalid-argument",
              "Message trop court (8 caractères minimum).",
          );
        }
        if (message.length > 20000) {
          throw new HttpsError("invalid-argument", "Message trop long.");
        }

        const kind = paychekWebContactKindFromSubject(subject);
        const ticketRef = paychekWebContactTicketRef();
        const description =
          `[Contact web${subject ? " — " + subject : ""}]\n` +
          (name ? `Nom: ${name}\n` : "") +
          `E-mail: ${email}\n` +
          `Langue: ${locale || "—"}\n\n` +
          message;

        const db = admin.firestore();
        const docRef = db.collection("paychek_support_tickets").doc();

        const ticketPayload = {
          userId: "web",
          source: "web_contact",
          ticketRef,
          replyEmail: email,
          staffNotifyEmail: STAFF_INBOX,
          kind,
          description,
          webSubject: subject || "Contact",
          appLanguageCode: locale || "fr",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          status: "open",
          staffUnread: true,
        };
        if (name) ticketPayload.replyDisplayName = name;

        const batch = db.batch();
        batch.set(docRef, ticketPayload);
        batch.set(
            docRef.collection("messages").doc(),
            {
              sender: "user",
              body: description,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            },
        );
        await batch.commit();

        return {ok: true, ticketRef};
      },
  );

  return {submitPaychekWebContact};
}

module.exports = {createWebContactExports};
