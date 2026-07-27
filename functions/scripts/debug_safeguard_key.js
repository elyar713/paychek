/**
 * Look up a Safeguard license key in Firestore (admin SDK).
 *
 * Usage:
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\serviceAccount.json"
 *   node scripts/debug_safeguard_key.js "PAYC-XXXX-XXXX-XXXX"
 *   node scripts/debug_safeguard_key.js --list
 *
 * Does not print full keys unless --reveal is passed.
 */
"use strict";

const path = require("path");
const admin = require("firebase-admin");

const {
  normalizeSafeguardLicenseKey,
  compactSafeguardLicenseKey,
  resolveLicenseByKey,
} = require("../safeguard_license");

const COL = "safeguard_licenses";
const COL_TRIAL = "safeguard_trial_machines";

function redactKey(key) {
  const k = `${key || ""}`;
  if (k.length < 12) return "****";
  return `${k.slice(0, 9)}••••-${k.slice(-4)}`;
}

function redactEmail(em) {
  const e = `${em || ""}`.trim().toLowerCase();
  if (!e.includes("@")) return null;
  const [u, d] = e.split("@");
  return `${u.slice(0, 2)}***@${d}`;
}

async function listRecent(db, limit = 30) {
  const snap = await db
      .collection(COL)
      .orderBy("createdAt", "desc")
      .limit(limit)
      .get();
  console.log(`recent_licenses=${snap.size}`);
  for (const doc of snap.docs) {
    const d = doc.data() || {};
    const key = d.key || doc.id;
    console.log(
        JSON.stringify({
          id: redactKey(doc.id),
          key: redactKey(key),
          idEqualsKey: doc.id === d.key,
          idLooksPayc: /^PAYC-/i.test(doc.id),
          keyNormalized: d.keyNormalized || null,
          plan: d.plan || d.type || null,
          source: d.source || d.createdByEmail || null,
          revoked: !!d.revoked,
          acts: Array.isArray(d.activations) ? d.activations.length : 0,
          max: d.maxActivations || null,
          userEmail: redactEmail(d.userEmail),
          expiresAt:
            d.expiresAt && d.expiresAt.toDate ?
              d.expiresAt.toDate().toISOString() :
              null,
          createdAt:
            d.createdAt && d.createdAt.toDate ?
              d.createdAt.toDate().toISOString() :
              null,
        }),
    );
  }
}

async function lookupKey(db, raw, reveal) {
  const normalized = normalizeSafeguardLicenseKey(raw);
  const compact = compactSafeguardLicenseKey(normalized);
  console.log(
      JSON.stringify({
        licenseKeyReceived: reveal ? raw : redactKey(raw),
        normalized: reveal ? normalized : redactKey(normalized),
        compactLen: compact.length,
      }),
  );

  const resolved = await resolveLicenseByKey(db, normalized);
  console.log(JSON.stringify({found: !!resolved}));
  if (!resolved) {
    // Extra diagnostics: scan recent docs for compact match (no composite index needed).
    const snap = await db.collection(COL).limit(200).get();
    let softHits = 0;
    for (const doc of snap.docs) {
      const d = doc.data() || {};
      const candidates = [doc.id, d.key, d.keyNormalized]
          .filter(Boolean)
          .map((x) => compactSafeguardLicenseKey(normalizeSafeguardLicenseKey(x)));
      if (candidates.includes(compact)) softHits++;
    }
    console.log(JSON.stringify({softScanHitsIn200: softHits, scanned: snap.size}));
    return;
  }

  const d = resolved.data || {};
  const out = {
    docId: reveal ? resolved.id : redactKey(resolved.id),
    keyField: reveal ? d.key : redactKey(d.key || resolved.id),
    keyNormalized: d.keyNormalized || null,
    plan: d.plan || d.type || null,
    source: d.source || null,
    revoked: !!d.revoked,
    acts: Array.isArray(d.activations) ? d.activations.length : 0,
    max: d.maxActivations || null,
    userEmail: redactEmail(d.userEmail),
    userId: d.userId ? `${String(d.userId).slice(0, 6)}…` : null,
    expiresAt:
      d.expiresAt && d.expiresAt.toDate ?
        d.expiresAt.toDate().toISOString() :
        null,
    activationMachinePrefixes: (Array.isArray(d.activations) ? d.activations : [])
        .map((a) => `${(a && a.machineId) || ""}`.slice(0, 8).toUpperCase())
        .filter(Boolean),
  };
  console.log(JSON.stringify(out));
}

async function findTrialMachinePrefix(db, prefix) {
  const p = `${prefix || ""}`.trim().toUpperCase();
  if (!p) return;
  const snap = await db.collection(COL_TRIAL).limit(100).get();
  let hits = 0;
  for (const doc of snap.docs) {
    const d = doc.data() || {};
    const pref = `${d.machineIdPrefix || ""}`.toUpperCase();
    if (pref === p || pref.startsWith(p)) {
      hits++;
      console.log(
          JSON.stringify({
            trialMachine: true,
            prefix: pref,
            licenseId: redactKey(d.licenseId),
            source: d.source || null,
          }),
      );
    }
  }
  console.log(JSON.stringify({trialMachinePrefix: p, hits}));
}

async function main() {
  const args = process.argv.slice(2);
  const reveal = args.includes("--reveal");
  const list = args.includes("--list");
  const trialPrefIdx = args.indexOf("--trial-prefix");
  const trialPrefix =
    trialPrefIdx >= 0 ? args[trialPrefIdx + 1] : null;
  const rawKey = args.find((a) => !a.startsWith("--") && a !== trialPrefix);

  if (
    !process.env.GOOGLE_APPLICATION_CREDENTIALS ||
    `${process.env.GOOGLE_APPLICATION_CREDENTIALS}`.trim() === ""
  ) {
    console.error(
        "Set GOOGLE_APPLICATION_CREDENTIALS to a Firebase service account JSON.",
    );
    process.exit(1);
  }

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: "paychek-trading",
    });
  }
  const db = admin.firestore();

  if (list || !rawKey) {
    await listRecent(db);
  }
  if (rawKey) {
    await lookupKey(db, rawKey, reveal);
  }
  if (trialPrefix) {
    await findTrialMachinePrefix(db, trialPrefix);
  }
  // Also useful: fingerprint short AC60C268 is NOT machineId prefix.
  if (!rawKey && !trialPrefix) {
    console.log(
        "Tip: pass a key to test resolveLicenseByKey, or --trial-prefix AC60C268 " +
        "(note: UI shows fingerprint short, trial lock uses machineId prefix).",
    );
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
