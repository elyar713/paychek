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

/** App Store Connect → App Information → Apple ID (numérique). */
function parseAppleAppId(raw) {
  const n = Number.parseInt(`${raw ?? ""}`.trim(), 10);
  return Number.isFinite(n) && n > 0 ? n : null;
}

const PAYCHEK_APPLE_APP_ID = parseAppleAppId(process.env.PAYCHEK_APPLE_APP_ID);

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
  const appAppleId =
    environment === Environment.PRODUCTION ? PAYCHEK_APPLE_APP_ID : undefined;
  if (environment === Environment.PRODUCTION && !appAppleId) {
    return null;
  }
  return new SignedDataVerifier(
      loadAppleRootCAs(),
      false,
      environment,
      bundleId,
      appAppleId,
  );
}

/**
 * @param {*} value
 * @return {number|null}
 */
function parseAppleMillis(value) {
  if (value == null) return null;
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  const parsed = Date.parse(`${value}`);
  return Number.isNaN(parsed) ? null : parsed;
}

/**
 * @param {object} obj StoreKit 2 jsonRepresentation
 * @return {boolean}
 */
function isSandboxStoreKitJson(obj) {
  const env = `${obj.environment || obj.storefront || ""}`.toLowerCase();
  if (env.includes("sandbox")) return true;
  if (env.includes("xcode")) return true;
  return false;
}

/**
 * @param {string} raw jsonRepresentation StoreKit 2
 * @param {string} fallbackProductId
 * @return {object|null}
 */
function transactionFromStoreKitJson(raw, fallbackProductId) {
  const trimmed = `${raw || ""}`.trim();
  if (!trimmed.startsWith("{")) return null;
  let obj;
  try {
    obj = JSON.parse(trimmed);
  } catch (_) {
    return null;
  }
  if (!obj || typeof obj !== "object") return null;
  const productId =
    `${obj.productId || obj.productID || fallbackProductId || ""}`.trim();
  const transactionId =
    `${obj.transactionId || obj.id || obj.transactionID || ""}`.trim();
  if (!productId || !transactionId) return null;
  const purchaseDate =
    parseAppleMillis(obj.purchaseDate) ||
    parseAppleMillis(obj.signedDate) ||
    parseAppleMillis(obj.originalPurchaseDate) ||
    Date.now();
  const expiresDate =
    parseAppleMillis(obj.expiresDate) ||
    parseAppleMillis(obj.expirationDate) ||
    null;
  return {
    transactionId,
    originalTransactionId:
      `${obj.originalTransactionId || obj.originalId || transactionId}`.trim(),
    productId,
    purchaseDate,
    expiresDate,
    environment: obj.environment,
  };
}

/**
 * @param {Error} err
 * @return {string}
 */
function formatAppleVerifyError(err) {
  if (!err) return "apple_jws_invalid";
  const status = err.status;
  if (status != null) return `apple_verify_status_${status}`;
  return err.message ? String(err.message) : "apple_jws_invalid";
}

/**
 * @param {string} signedTransaction JWS StoreKit 2
 * @param {string} bundleId
 * @param {string} appleStoreKit2Json jsonRepresentation (secours sandbox)
 * @param {string} fallbackProductId
 * @return {Promise<{tx: object, source: string}>}
 */
async function resolveAppleTransaction(
    signedTransaction,
    bundleId,
    appleStoreKit2Json,
    fallbackProductId,
) {
  const jws = `${signedTransaction || ""}`.trim();
  if (isLikelyAppleTransactionJws(jws)) {
    let lastErr = null;
    for (const env of [Environment.SANDBOX, Environment.PRODUCTION]) {
      try {
        const verifier = buildVerifier(env, bundleId);
        if (!verifier) continue;
        const tx = await verifier.verifyAndDecodeTransaction(jws);
        return {tx, source: env === Environment.SANDBOX ? "jws_sandbox" : "jws_production"};
      } catch (e) {
        lastErr = e;
        console.warn("[Paychek] decodeAppleTransaction", env, formatAppleVerifyError(e));
      }
    }
    const jsonTx = transactionFromStoreKitJson(
        appleStoreKit2Json,
        fallbackProductId,
    );
    if (jsonTx && isSandboxStoreKitJson(jsonTx)) {
      console.warn("[Paychek] resolveAppleTransaction sandbox JSON fallback", {
        productId: jsonTx.productId,
        transactionId: jsonTx.transactionId,
        jwsError: formatAppleVerifyError(lastErr),
      });
      return {tx: jsonTx, source: "json_sandbox_fallback"};
    }
    throw lastErr || new Error("apple_jws_invalid");
  }

  const jsonTx = transactionFromStoreKitJson(
      appleStoreKit2Json || jws,
      fallbackProductId,
  );
  if (jsonTx && isSandboxStoreKitJson(jsonTx)) {
    return {tx: jsonTx, source: "json_sandbox_only"};
  }

  throw new Error("signedTransaction_missing");
}

/**
 * @param {object} tx decoded transaction
 * @return {boolean}
 */
function isLikelyAppleTransactionJws(signedTransaction) {
  const t = `${signedTransaction || ""}`.trim();
  const parts = t.split(".");
  return parts.length === 3 && parts[0].startsWith("eyJ");
}

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
 * @param {string} productId
 * @param {number} startMs
 * @return {number}
 */
function inferApplePeriodEndMillis(productId, startMs = Date.now()) {
  const id = `${productId || ""}`.toLowerCase();
  const d = new Date(startMs);
  const y = d.getUTCFullYear();
  const m = d.getUTCMonth();
  const day = d.getUTCDate();
  const h = d.getUTCHours();
  const min = d.getUTCMinutes();
  const sec = d.getUTCSeconds();
  const ms = d.getUTCMilliseconds();
  if (id.includes("annual")) {
    return Date.UTC(y + 1, m, day, h, min, sec, ms);
  }
  if (id.includes("quarterly")) {
    return Date.UTC(y, m + 3, day, h, min, sec, ms);
  }
  return Date.UTC(y, m + 1, day, h, min, sec, ms);
}

/**
 * @param {object} tx
 * @param {string} productId
 * @return {number|null}
 */
function resolveApplePeriodEndMillis(tx, productId) {
  const startMs =
    typeof tx.purchaseDate === "number" ? tx.purchaseDate : Date.now();
  let expiryMs = null;
  if (tx.expiresDate != null && typeof tx.expiresDate === "number") {
    expiryMs = tx.expiresDate;
  }
  const inferred = inferApplePeriodEndMillis(productId, startMs);
  if (expiryMs == null || !Number.isFinite(expiryMs)) {
    return inferred;
  }
  const span = expiryMs - startMs;
  const id = `${productId || ""}`.toLowerCase();
  let minSpanMs = 25 * 24 * 60 * 60 * 1000;
  if (id.includes("annual")) {
    minSpanMs = 300 * 24 * 60 * 60 * 1000;
  } else if (id.includes("quarterly")) {
    minSpanMs = 60 * 24 * 60 * 60 * 1000;
  }
  if (span < minSpanMs && expiryMs > Date.now()) {
    return Math.max(expiryMs, inferred);
  }
  return expiryMs;
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
    paychekAssertStoreSubscriptionOwner,
    allowTransfer = false,
) {
  const transactionId = `${tx.transactionId || ""}`;
  const originalId = `${tx.originalTransactionId || transactionId}`;
  if (!transactionId) {
    throw new Error("apple_transaction_id_missing");
  }

  if (typeof paychekAssertStoreSubscriptionOwner === "function") {
    await paychekAssertStoreSubscriptionOwner(
        db,
        uid,
        {
          appleOriginalTransactionId: originalId,
          appleTransactionId: transactionId,
        },
        {allowTransfer},
    );
  }

  const periodEndMs = resolveApplePeriodEndMillis(tx, productId);
  let currentPeriodEnd = admin.firestore.Timestamp.fromMillis(periodEndMs);
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
 * Re-synchronise Pro depuis les champs Apple déjà stockés (admin / réparation).
 *
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {object} ent
 * @param {function} paychekGrantProEntitlement
 * @param {import("firebase-admin")} admin
 */
async function resyncProFromStoredAppleEntitlement(
    db,
    uid,
    ent,
    paychekGrantProEntitlement,
    admin,
) {
  const productId = `${ent.appleProductId || ""}`.trim();
  const transactionId = `${ent.appleTransactionId || ""}`.trim();
  const originalId =
    `${ent.appleOriginalTransactionId || transactionId}`.trim();
  if (!productId || !transactionId) {
    throw new Error("apple_stored_purchase_missing");
  }

  let currentPeriodEnd = ent.currentPeriodEnd || null;
  if (
    !currentPeriodEnd ||
    typeof currentPeriodEnd.toMillis !== "function"
  ) {
    const proSince =
      ent.proSinceUtc && typeof ent.proSinceUtc.toMillis === "function" ?
        ent.proSinceUtc.toMillis() :
        Date.now();
    currentPeriodEnd = admin.firestore.Timestamp.fromMillis(
        inferApplePeriodEndMillis(productId, proSince),
    );
  }

  const proSinceUtc =
    ent.proSinceUtc && typeof ent.proSinceUtc.toMillis === "function" ?
      ent.proSinceUtc :
      admin.firestore.Timestamp.fromMillis(Date.now());

  const granted = await paychekGrantProEntitlement(db, uid, {
    provider: "apple_iap",
    appleTransactionId: transactionId,
    appleOriginalTransactionId: originalId,
    appleProductId: productId,
    proSinceUtc,
    currentPeriodEnd,
  });

  const periodMs =
    currentPeriodEnd && typeof currentPeriodEnd.toMillis === "function" ?
      currentPeriodEnd.toMillis() :
      null;

  return {
    active: true,
    granted,
    reason: granted ? "stored_apple_resync" : "stored_apple_already_synced",
    currentPeriodEndMillis: periodMs,
    message: "Abonnement Apple resynchronisé depuis Firestore.",
  };
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
    paychekAssertStoreSubscriptionOwner,
    paychekRevokeProEntitlement,
    paychekHintOtherActiveAppleAccounts,
  } = deps;

  /**
   * Transfère l’abonnement Apple stocké d’un uid vers un autre (admin).
   */
  async function adminTransferAppleEntitlement(db, fromUid, toUid) {
    const fromSnap =
      await db.collection("subscriber_entitlements").doc(fromUid).get();
    if (!fromSnap.exists) {
      throw new HttpsError(
          "not-found",
          "Compte source sans entitlements Apple.",
      );
    }
    const ent = fromSnap.data() || {};
    const productId = `${ent.appleProductId || ""}`.trim();
    const transactionId = `${ent.appleTransactionId || ""}`.trim();
    if (!productId || !transactionId) {
      throw new HttpsError(
          "failed-precondition",
          "Le compte source n’a pas d’achat Apple enregistré.",
      );
    }
    if (typeof paychekRevokeProEntitlement === "function") {
      await paychekRevokeProEntitlement(db, fromUid, {
        provider: "apple_iap",
        reason: "admin_apple_transfer",
      });
    }
    return resyncProFromStoredAppleEntitlement(
        db,
        toUid,
        ent,
        paychekGrantProEntitlement,
        admin,
    );
  }

  async function verifyAndGrant(request) {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Connexion requise.");
    }
    try {
      const signedTransaction =
        `${request.data?.signedTransaction ?? ""}`.trim();
      const appleStoreKit2Json =
        `${request.data?.appleStoreKit2Json ?? ""}`.trim();
      const allowTransfer = request.data?.allowTransfer === true;
      let productId = `${request.data?.productId ?? ""}`.trim();
      if ((!signedTransaction && !appleStoreKit2Json) || !productId) {
        throw new HttpsError(
            "invalid-argument",
            "Transaction Apple invalide (données manquantes).",
        );
      }
      if (!DEFAULT_PRODUCT_IDS.has(productId)) {
        const remoteIds = request.data?.allowedProductIds;
        if (!Array.isArray(remoteIds) || !remoteIds.includes(productId)) {
          throw new HttpsError("invalid-argument", "Produit inconnu.");
        }
      }

      const bundleId = PAYCHEK_IOS_BUNDLE_ID;
      const resolved = await resolveAppleTransaction(
          signedTransaction,
          bundleId,
          appleStoreKit2Json,
          productId,
      );
      const tx = resolved.tx;
      const txProductId = `${tx.productId || ""}`.trim();
      if (txProductId && DEFAULT_PRODUCT_IDS.has(txProductId)) {
        productId = txProductId;
      }
      if (!appleTransactionGrantsPro(tx)) {
        const expiresMs =
          tx.expiresDate != null && typeof tx.expiresDate === "number" ?
            tx.expiresDate :
            null;
        console.warn("[Paychek] verifyPaychekApplePurchase inactive tx", {
          uid: request.auth.uid,
          productId,
          source: resolved.source,
          expiresMs,
          now: Date.now(),
        });
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
          paychekAssertStoreSubscriptionOwner,
          allowTransfer,
      );
      const periodEndMs = resolveApplePeriodEndMillis(tx, productId);
      console.log("[Paychek] verifyPaychekApplePurchase ok", {
        uid,
        productId,
        source: resolved.source,
        granted,
      });
      return {
        active: true,
        granted,
        source: resolved.source,
        currentPeriodEndMillis: periodEndMs,
      };
    } catch (e) {
      console.error("[Paychek] verifyPaychekApplePurchase", e);
      if (e instanceof HttpsError) throw e;
      const msg = formatAppleVerifyError(e);
      if (
        msg.includes("apple_subscription_linked_to_other_account") ||
        `${e.message || ""}`.includes("apple_subscription_linked_to_other_account")
      ) {
        const hint = e.otherAccountHint ?
          ` (${e.otherAccountHint})` :
          "";
        throw new HttpsError(
            "failed-precondition",
            "Cet abonnement Apple est déjà lié à un autre compte Paychek." +
            hint +
            " Connecte-toi avec le compte d’origine ou contacte le support.",
        );
      }
      if (
        msg.includes("signedTransaction_missing") ||
        msg.includes("apple_jws") ||
        msg.includes("apple_verify")
      ) {
        const hint = PAYCHEK_APPLE_APP_ID ?
          "" :
          " (Production : configure PAYCHEK_APPLE_APP_ID sur Firebase.)";
        throw new HttpsError(
            "invalid-argument",
            "Validation Apple échouée. Réessaie « Restaurer les achats »." + hint,
        );
      }
      throw new HttpsError("internal", msg);
    }
  }

  async function syncStoredAppleEntitlement(request) {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Connexion requise.");
    }
    try {
      const db = admin.firestore();
      let targetUid = `${request.auth.uid || ""}`.trim();
      const requested = `${request.data?.targetUserId ?? ""}`.trim();
      if (requested && requested !== targetUid) {
        if (request.auth.token.admin !== true) {
          throw new HttpsError(
              "permission-denied",
              "Réservé aux administrateurs.",
          );
        }
        targetUid = requested;
      }

      const transferFrom = `${request.data?.transferFromUid ?? ""}`.trim();
      if (
        transferFrom &&
        transferFrom !== targetUid &&
        request.auth.token.admin === true
      ) {
        const transferred = await adminTransferAppleEntitlement(
            db,
            transferFrom,
            targetUid,
        );
        return {
          active: true,
          granted: true,
          reason: "admin_transfer",
          message: "Abonnement Apple transféré depuis l’autre compte.",
          currentPeriodEndMillis: transferred.currentPeriodEndMillis,
        };
      }

      const entSnap =
        await db.collection("subscriber_entitlements").doc(targetUid).get();
      const ent = entSnap.exists ? entSnap.data() || {} : {};
      const signedTransaction =
        `${request.data?.signedTransaction ?? ""}`.trim();

      if (signedTransaction) {
        const productId =
          `${ent.appleProductId || request.data?.productId || ""}`.trim();
        if (!productId) {
          throw new HttpsError(
              "failed-precondition",
              "Produit Apple manquant pour ce compte.",
          );
        }
        const resolved = await resolveAppleTransaction(
            signedTransaction,
            PAYCHEK_IOS_BUNDLE_ID,
            `${request.data?.appleStoreKit2Json ?? ""}`.trim(),
            productId,
        );
        const tx = resolved.tx;
        if (!appleTransactionGrantsPro(tx)) {
          return {
            active: false,
            reason: "expired_or_revoked",
            message: "Transaction Apple expirée ou révoquée.",
          };
        }
        const granted = await grantProFromAppleTransaction(
            db,
            targetUid,
            tx,
            productId,
            paychekGrantProEntitlement,
            paychekApplyTrialRemainderToPeriodEnd,
            admin,
            paychekAssertStoreSubscriptionOwner,
            request.data?.allowTransfer === true ||
            request.auth.token.admin === true,
        );
        return {
          active: true,
          granted,
          reason: "jws_verified",
          currentPeriodEndMillis: resolveApplePeriodEndMillis(tx, productId),
        };
      }

      const hasApple =
        `${ent.appleProductId || ""}`.trim().length > 0 &&
        (`${ent.appleTransactionId || ""}`.trim().length > 0 ||
          `${ent.appleOriginalTransactionId || ""}`.trim().length > 0);
      if (!hasApple) {
        let message =
          "Aucun achat Apple enregistré pour ce compte Firebase.";
        if (typeof paychekHintOtherActiveAppleAccounts === "function") {
          const hints =
            await paychekHintOtherActiveAppleAccounts(db, targetUid);
          if (hints.length > 0) {
            message +=
              " Un abonnement Apple actif existe sur : " +
              hints.join(", ") +
              ". Sur iPhone : « Restaurer les achats » avec CE compte Paychek " +
              "(transfert automatique), ou en admin paramètre transferFromUid.";
          } else {
            message +=
              " Sur iPhone (connecté avec CE email) : paywall → " +
              "« Restaurer les achats ».";
          }
        }
        throw new HttpsError("failed-precondition", message);
      }

      const periodEnd =
        ent.currentPeriodEnd &&
        typeof ent.currentPeriodEnd.toMillis === "function" ?
          ent.currentPeriodEnd.toMillis() :
          null;
      if (ent.active !== true && periodEnd != null && periodEnd <= Date.now()) {
        return {
          active: false,
          reason: "expired_or_inactive",
          currentPeriodEndMillis: periodEnd,
          message: "Abonnement Apple inactif ou échéance passée.",
        };
      }

      console.log("[Paychek] syncStoredAppleEntitlement", targetUid);
      return await resyncProFromStoredAppleEntitlement(
          db,
          targetUid,
          ent,
          paychekGrantProEntitlement,
          admin,
      );
    } catch (e) {
      console.error("[Paychek] syncStoredAppleEntitlement", e);
      if (e instanceof HttpsError) throw e;
      throw new HttpsError(
          "internal",
          e && e.message ? String(e.message) : "sync_apple_failed",
      );
    }
  }

  const callOpts = {
    region: "europe-west1",
    timeoutSeconds: 60,
    memory: "256MiB",
  };

  const verifyPaychekApplePurchase = onCall(callOpts, verifyAndGrant);

  const restorePaychekAppleEntitlement = onCall(callOpts, async (request) => {
    return verifyAndGrant({
      ...request,
      data: {
        ...(request.data || {}),
        allowTransfer: true,
      },
    });
  });

  const syncPaychekAppleEntitlement = onCall(callOpts, syncStoredAppleEntitlement);

  return {
    verifyPaychekApplePurchase,
    restorePaychekAppleEntitlement,
    syncPaychekAppleEntitlement,
  };
}

module.exports = {
  createAppleIapExports,
  resolveAppleTransaction,
  appleTransactionGrantsPro,
  inferApplePeriodEndMillis,
  resolveApplePeriodEndMillis,
  PAYCHEK_IOS_BUNDLE_ID,
  PAYCHEK_APPLE_APP_ID,
  DEFAULT_PRODUCT_IDS,
};
