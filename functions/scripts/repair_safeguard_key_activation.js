/**
 * One-shot: clear activations on a Safeguard license (and related trial-machine locks)
 * so the user can activate again on their real PC.
 *
 * Usage:
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="..."
 *   node scripts/repair_safeguard_key_activation.js "PAYC-XXXX-XXXX-XXXX" [--clear-trial-locks]
 */
"use strict";

const admin = require("firebase-admin");
const {
  normalizeSafeguardLicenseKey,
  resolveLicenseByKey,
} = require("../safeguard_license");

const COL_TRIAL = "safeguard_trial_machines";

async function main() {
  const args = process.argv.slice(2);
  const clearTrial = args.includes("--clear-trial-locks");
  const rawKey = args.find((a) => !a.startsWith("--"));
  if (!rawKey) {
    console.error("Usage: node scripts/repair_safeguard_key_activation.js PAYC-… [--clear-trial-locks]");
    process.exit(1);
  }
  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.error("Set GOOGLE_APPLICATION_CREDENTIALS");
    process.exit(1);
  }
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: "paychek-trading",
    });
  }
  const db = admin.firestore();
  const key = normalizeSafeguardLicenseKey(rawKey);
  const resolved = await resolveLicenseByKey(db, key);
  if (!resolved) {
    console.error(JSON.stringify({found: false, key}));
    process.exit(2);
  }
  const before = resolved.data || {};
  const actsBefore = Array.isArray(before.activations) ? before.activations.length : 0;
  await resolved.ref.update({
    activations: [],
    lastActivatedAt: admin.firestore.FieldValue.delete(),
    lastActivatedMachineId: admin.firestore.FieldValue.delete(),
  });
  console.log(
      JSON.stringify({
        repaired: true,
        docId: resolved.id,
        clearedActivations: actsBefore,
      }),
  );

  if (clearTrial) {
    const snap = await db
        .collection(COL_TRIAL)
        .where("licenseId", "==", key)
        .limit(20)
        .get();
    let deleted = 0;
    for (const doc of snap.docs) {
      await doc.ref.delete();
      deleted++;
      console.log(JSON.stringify({deletedTrialLock: doc.id.slice(0, 12) + "…"}));
    }
    console.log(JSON.stringify({trialLocksDeleted: deleted}));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
