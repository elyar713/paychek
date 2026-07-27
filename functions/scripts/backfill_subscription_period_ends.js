/**
 * Backfill missing Journal Pro end dates on paychek_users / subscriber_entitlements.
 *
 * - Mirror ent.currentPeriodEnd → user.subscriptionCurrentPeriodEnd when missing
 * - For Stripe Pro with no period end: set +1y from proSince (web default)
 * - For inactive ents with past period and no subscriptionEndedAt: set endedAt = periodEnd
 *
 * Usage:
 *   node functions/scripts/backfill_subscription_period_ends.js
 *   node functions/scripts/backfill_subscription_period_ends.js --apply
 */
const path = require("path");
const admin = require("firebase-admin");
const sa = require(path.join(
    __dirname,
    "..",
    "..",
    "paychek-trading-firebase-adminsdk-fbsvc-2a79fdd25f.json",
));

if (!admin.apps.length) {
  admin.initializeApp({credential: admin.credential.cert(sa)});
}
const db = admin.firestore();
const APPLY = process.argv.includes("--apply");

function tsIso(v) {
  if (!v || typeof v.toDate !== "function") return null;
  return v.toDate().toISOString();
}

function plusOneYear(ts) {
  const d = ts.toDate();
  return admin.firestore.Timestamp.fromMillis(
      Date.UTC(
          d.getUTCFullYear() + 1,
          d.getUTCMonth(),
          d.getUTCDate(),
          d.getUTCHours(),
          d.getUTCMinutes(),
          d.getUTCSeconds(),
          d.getUTCMilliseconds(),
      ),
  );
}

function redactEmail(e) {
  e = String(e || "");
  const at = e.indexOf("@");
  if (at < 0) return "(none)";
  const local = e.slice(0, at);
  const domain = e.slice(at + 1);
  const m =
    local.length <= 2 ? "***" : local[0] + "***" + local.slice(-1);
  return m + "@" + domain;
}

(async () => {
  const ents = await db.collection("subscriber_entitlements").get();
  const actions = [];

  for (const doc of ents.docs) {
    const e = doc.data() || {};
    const userRef = db.collection("paychek_users").doc(doc.id);
    const userSnap = await userRef.get();
    const u = userSnap.exists ? userSnap.data() || {} : {};
    const email = redactEmail(u.email);
    const entEnd =
      e.currentPeriodEnd && typeof e.currentPeriodEnd.toMillis === "function" ?
        e.currentPeriodEnd :
        null;
    const userEnd =
      u.subscriptionCurrentPeriodEnd &&
      typeof u.subscriptionCurrentPeriodEnd.toMillis === "function" ?
        u.subscriptionCurrentPeriodEnd :
        null;
    const proSince =
      (e.proSinceUtc && typeof e.proSinceUtc.toMillis === "function" &&
        e.proSinceUtc) ||
      (u.subscriptionProSinceUtc &&
        typeof u.subscriptionProSinceUtc.toMillis === "function" &&
        u.subscriptionProSinceUtc) ||
      null;
    const provider = `${e.provider || ""}`.trim();
    const isPro =
      `${u.subscriptionTier || ""}`.toLowerCase() === "pro" ||
      u.isPremium === true ||
      e.active === true;

    const patchEnt = {};
    const patchUser = {};

    // Stripe / any Pro missing period end → +1y from proSince.
    if (!entEnd && !userEnd && proSince && (isPro || provider === "stripe")) {
      const inferred = plusOneYear(proSince);
      patchEnt.currentPeriodEnd = inferred;
      patchUser.subscriptionCurrentPeriodEnd = inferred;
      actions.push({
        uid: doc.id.slice(0, 10) + "…",
        email,
        action: "infer_period_end_plus_1y",
        from: tsIso(proSince),
        to: tsIso(inferred),
      });
    }

    const effectiveEnd =
      patchEnt.currentPeriodEnd || entEnd || userEnd || null;

    // Mirror ent → user
    if (effectiveEnd && !userEnd && !patchUser.subscriptionCurrentPeriodEnd) {
      patchUser.subscriptionCurrentPeriodEnd = effectiveEnd;
      actions.push({
        uid: doc.id.slice(0, 10) + "…",
        email,
        action: "mirror_period_end_to_user",
        to: tsIso(effectiveEnd),
      });
    }

    // Mirror user → ent
    if (userEnd && !entEnd && !patchEnt.currentPeriodEnd) {
      patchEnt.currentPeriodEnd = userEnd;
      actions.push({
        uid: doc.id.slice(0, 10) + "…",
        email,
        action: "mirror_period_end_to_ent",
        to: tsIso(userEnd),
      });
    }

    const finalEnd = patchEnt.currentPeriodEnd || entEnd || userEnd;
    if (
      e.active === false &&
      finalEnd &&
      typeof finalEnd.toMillis === "function" &&
      finalEnd.toMillis() <= Date.now() &&
      !e.subscriptionEndedAt
    ) {
      patchEnt.subscriptionEndedAt = finalEnd;
      if (!u.subscriptionEndedAt) {
        patchUser.subscriptionEndedAt = finalEnd;
      }
      if (!e.subscriptionEndReason) {
        patchEnt.subscriptionEndReason = "backfill_expired";
      }
      actions.push({
        uid: doc.id.slice(0, 10) + "…",
        email,
        action: "set_subscriptionEndedAt",
        to: tsIso(finalEnd),
      });
    }

    if (Object.keys(patchEnt).length || Object.keys(patchUser).length) {
      if (APPLY) {
        const batch = db.batch();
        if (Object.keys(patchEnt).length) {
          patchEnt.updatedAt = admin.firestore.FieldValue.serverTimestamp();
          batch.set(doc.ref, patchEnt, {merge: true});
        }
        if (Object.keys(patchUser).length) {
          patchUser.updatedAt = admin.firestore.FieldValue.serverTimestamp();
          batch.set(userRef, patchUser, {merge: true});
        }
        await batch.commit();
      }
    }
  }

  console.log(
      JSON.stringify(
          {
            mode: APPLY ? "APPLY" : "DRY_RUN",
            actionCount: actions.length,
            actions,
          },
          null,
          2,
      ),
  );
  process.exit(0);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
