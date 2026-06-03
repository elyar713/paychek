/**
 * App Store (StoreKit 2) — validation JWS + activation Pro Firestore.
 *
 * Secrets Firebase (console ou CLI) :
 *   PAYCHEK_APPLE_IAP_PRIVATE_KEY  — contenu du fichier .p8 (App Store Connect API)
 * Bundle validé : pro.paychek.app (voir PAYCHEK_IOS_BUNDLE_ID).
 */

const fs = require("fs");
const path = require("path");
const {
  Environment,
  SignedDataVerifier,
} = require("@apple/app-store-server-library");

const PAYCHEK_IOS_BUNDLE_ID = "pro.paychek.app";

const DEFAULT_PRODUCT_IDS = new Set([
  "Paychek.monthly",
  "Paychek_quarterly",
  "Paychek_annual",
]);

let _rootCasCache = null;

function loadAppleRootCAs() {
  if (_rootCasCache) return _rootCasCache;
  const certsDir = path.join(
      path.dirname(require.resolve("@apple/app-store-server-library")),
      "certs",
  );
  const files = fs.readdirSync(certsDir).filter((f) => f.endsWith(".cer"));
  _rootCasCache = files.map((f) => fs.readFileSync(path.join(certsDir, f)));
  return _rootCasCache;
}

function buildVerifier(environment, bundleId) {
  return new SignedDataVerifier(
      loadAppleRootCAs(),
      true,
      environment,
      bundleId,
      undefined,
  );
}

/**
 * @param {string} signedTransaction JWS StoreKit 2
 * @param {string} bundleId
 * @return {Promise<object>}
 */
async function decodeAppleTransaction(signedTransaction, bundleId) {
  const jws = `${signedTransaction || ""}`.trim();
  if (!jws) {
    throw new Error("signedTransaction_missing");
  }
  let lastErr = null;
  for (const env of [Environment.PRODUCTION, Environment.SANDBOX]) {
    try {
      const verifier = buildVerifier(env, bundleId);
      return await verifier.verifyAndDecodeTransaction(jws);
    } catch (e) {
      lastErr = e;
    }
  }
  throw lastErr || new Error("apple_jws_invalid");
}

/**
 * @param {object} tx decoded transaction
 * @return {boolean}
 */
function appleTransactionGrantsPro(tx) {
  const revoked = tx.revocationDate != null;
  if (revoked) return false;
  const expires = tx.expiresDate;
  if (expires != null && typeof expires === "number") {
    return expires > Date.now();
  }
  return true;
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {object} tx
 * @param {string} productId
 * @param {function} paychekGrantProEntitlement
 * @param {function} paychekApplyTrialRemainderToPeriodEnd
 * @param {import("firebase-admin")} admin
 */
async function grantProFromAppleTransaction(
    db,
    uid,
    tx,
    productId,
    paychekGrantProEntitlement,
    paychekApplyTrialRemainderToPeriodEnd,
    admin,
) {
  const transactionId = `${tx.transactionId || ""}`;
  const originalId = `${tx.originalTransactionId || transactionId}`;
  if (!transactionId) {
    throw new Error("apple_transaction_id_missing");
  }

  let currentPeriodEnd = null;
  if (tx.expiresDate != null && typeof tx.expiresDate === "number") {
    currentPeriodEnd = admin.firestore.Timestamp.fromMillis(tx.expiresDate);
  }
  const purchaseMs =
    typeof tx.purchaseDate === "number" ? tx.purchaseDate : Date.now();
  const proSinceUtc = admin.firestore.Timestamp.fromMillis(purchaseMs);

  currentPeriodEnd = await paychekApplyTrialRemainderToPeriodEnd(
      db,
      uid,
      currentPeriodEnd,
      proSinceUtc,
  );

  return paychekGrantProEntitlement(db, uid, {
    provider: "apple_iap",
    appleTransactionId: transactionId,
    appleOriginalTransactionId: originalId,
    appleProductId: productId,
    proSinceUtc,
    currentPeriodEnd,
  });
}

/**
 * @param {object} deps
 * @return {object} named Cloud Function exports
 */
function createAppleIapExports(deps) {
  const {
    onCall,
    HttpsError,
    admin,
    paychekGrantProEntitlement,
    paychekApplyTrialRemainderToPeriodEnd,
  } = deps;

  async function verifyAndGrant(request) {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Connexion requise.");
    }
    const signedTransaction =
      `${request.data?.signedTransaction ?? ""}`.trim();
    const productId = `${request.data?.productId ?? ""}`.trim();
    if (!signedTransaction || !productId) {
      throw new HttpsError("invalid-argument", "Transaction Apple invalide.");
    }
    if (!DEFAULT_PRODUCT_IDS.has(productId)) {
      const remoteIds = request.data?.allowedProductIds;
      if (!Array.isArray(remoteIds) || !remoteIds.includes(productId)) {
        throw new HttpsError("invalid-argument", "Produit inconnu.");
      }
    }

    const bundleId = PAYCHEK_IOS_BUNDLE_ID;
    const tx = await decodeAppleTransaction(signedTransaction, bundleId);
    if (!appleTransactionGrantsPro(tx)) {
      return {active: false, reason: "expired_or_revoked"};
    }

    const db = admin.firestore();
    const uid = request.auth.uid;
    const granted = await grantProFromAppleTransaction(
        db,
        uid,
        tx,
        productId,
        paychekGrantProEntitlement,
        paychekApplyTrialRemainderToPeriodEnd,
        admin,
    );
    return {active: true, granted};
  }

  const verifyPaychekApplePurchase = onCall(
      {
        region: "europe-west1",
        timeoutSeconds: 60,
        memory: "256MiB",
      },
      verifyAndGrant,
  );

  const restorePaychekAppleEntitlement = onCall(
      {
        region: "europe-west1",
        timeoutSeconds: 60,
        memory: "256MiB",
      },
      verifyAndGrant,
  );

  return {
    verifyPaychekApplePurchase,
    restorePaychekAppleEntitlement,
  };
}

module.exports = {
  createAppleIapExports,
  decodeAppleTransaction,
  appleTransactionGrantsPro,
  PAYCHEK_IOS_BUNDLE_ID,
  DEFAULT_PRODUCT_IDS,
};
