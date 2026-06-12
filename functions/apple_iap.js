/**
 * App Store (StoreKit 2) — validation JWS + activation Pro Firestore.
 *
 * Secrets Firebase (console ou CLI) :
 *   PAYCHEK_APPLE_IAP_PRIVATE_KEY  — contenu du fichier .p8 (App Store Connect API)
 *   PAYCHEK_APPLE_IAP_KEY_ID        — Key ID de la clé API (Users and Access → Keys)
 *   PAYCHEK_APPLE_IAP_ISSUER_ID     — Issuer ID (Users and Access, en haut de page)
 * Bundle validé : pro.paychek.app (voir PAYCHEK_IOS_BUNDLE_ID).
 */

const fs = require("fs");
const path = require("path");
const {
  AppStoreServerAPIClient,
  Environment,
  GetTransactionHistoryVersion,
  Order,
  ProductType,
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
 * @param {string} raw
 * @return {string}
 */
function normalizeApplePrivateKey(raw) {
  let key = `${raw ?? ""}`.trim();
  if (!key) return "";
  if (!key.includes("\n") && key.includes("\\n")) {
    key = key.replace(/\\n/g, "\n");
  }
  return key;
}

/**
 * @param {{privateKey?: () => string, keyId?: () => string, issuerId?: () => string}|null} getters
 * @return {{privateKey: string, keyId: string, issuerId: string}|null}
 */
function readAppleApiCredentials(getters) {
  const privateKey = normalizeApplePrivateKey(
      typeof getters?.privateKey === "function" ?
        getters.privateKey() :
        process.env.PAYCHEK_APPLE_IAP_PRIVATE_KEY,
  );
  const keyId = `${typeof getters?.keyId === "function" ?
    getters.keyId() :
    process.env.PAYCHEK_APPLE_IAP_KEY_ID ?? ""}`.trim();
  const issuerId = `${typeof getters?.issuerId === "function" ?
    getters.issuerId() :
    process.env.PAYCHEK_APPLE_IAP_ISSUER_ID ?? ""}`.trim();
  if (!privateKey || !keyId || !issuerId) return null;
  return {privateKey, keyId, issuerId};
}

/**
 * @param {string} productId
 * @return {string}
 */
function paychekAppleCycleHintFromProductId(productId) {
  const id = `${productId || ""}`.toLowerCase();
  if (id.includes("annual")) return "1 an";
  if (id.includes("quarterly")) return "3 mois";
  if (id.includes("monthly") || id.includes(".month")) return "1 mois";
  return "";
}

/**
 * @param {object} tx decoded JWS transaction
 * @return {string}
 */
function paychekAppleTransactionDisplayStatus(tx) {
  if (tx.revocationDate != null) return "Remboursé";
  const reason = `${tx.transactionReason || ""}`.toUpperCase();
  if (reason === "RENEWAL") return "Renouvellement";
  if (reason === "PURCHASE") return "Réussi";
  const expires = tx.expiresDate;
  if (expires != null && typeof expires === "number" && expires <= Date.now()) {
    return "Expiré";
  }
  return "Réussi";
}

/**
 * @param {{tx: object, environment: string}} entry
 * @return {object|null}
 */
function paychekApplePaymentRowFromTx(entry) {
  const tx = entry?.tx;
  if (!tx || typeof tx !== "object") return null;
  const transactionId = `${tx.transactionId || ""}`.trim();
  if (!transactionId) return null;
  const productId = `${tx.productId || ""}`.trim();
  const purchaseMs =
    typeof tx.purchaseDate === "number" ? tx.purchaseDate : Date.now();
  const priceMilli = typeof tx.price === "number" ? tx.price : 0;
  const cur = `${tx.currency || "usd"}`.trim().toLowerCase();
  const amountMajor = priceMilli > 0 ? priceMilli / 1000 : 0;
  const envLabel =
    entry.environment === Environment.SANDBOX ? "Sandbox" : "Production";

  return {
    provider: "apple_iap",
    transactionId,
    originalTransactionId:
      `${tx.originalTransactionId || transactionId}`.trim(),
    productId,
    amountTotal: Math.round(amountMajor * 100),
    amountMajor,
    amountRefunded: 0,
    currency: cur,
    paymentStatus: `${tx.transactionReason || ""}`.trim(),
    sessionStatus: envLabel,
    displayStatus: paychekAppleTransactionDisplayStatus(tx),
    cycleHint: paychekAppleCycleHintFromProductId(productId),
    failureMessage: "",
    email: "",
    created: Math.floor(purchaseMs / 1000),
    expiresDate:
      typeof tx.expiresDate === "number" ?
        Math.floor(tx.expiresDate / 1000) :
        0,
    environment: envLabel,
  };
}

/**
 * @param {object} ent subscriber_entitlements document
 * @return {object|null}
 */
function paychekApplePaymentFromStoredEntitlement(ent) {
  const transactionId = `${ent.appleTransactionId || ""}`.trim();
  const productId = `${ent.appleProductId || ""}`.trim();
  if (!transactionId || !productId) return null;
  const proSince =
    ent.proSinceUtc && typeof ent.proSinceUtc.toMillis === "function" ?
      ent.proSinceUtc.toMillis() :
      Date.now();
  const periodEnd =
    ent.currentPeriodEnd && typeof ent.currentPeriodEnd.toMillis === "function" ?
      ent.currentPeriodEnd.toMillis() :
      null;
  return {
    provider: "apple_iap",
    transactionId,
    originalTransactionId:
      `${ent.appleOriginalTransactionId || transactionId}`.trim(),
    productId,
    amountTotal: 0,
    amountMajor: 0,
    amountRefunded: 0,
    currency: "usd",
    paymentStatus: "",
    sessionStatus: "Firestore",
    displayStatus:
      ent.active === true ?
        "Enregistré (serveur)" :
        "Inactif (serveur)",
    cycleHint: paychekAppleCycleHintFromProductId(productId),
    failureMessage:
      "Historique App Store indisponible — dernière transaction Firestore.",
    email: "",
    created: Math.floor(proSince / 1000),
    expiresDate: periodEnd ? Math.floor(periodEnd / 1000) : 0,
    environment: "",
  };
}

/**
 * @param {string} anyTransactionId original or latest transaction id
 * @param {{privateKey: string, keyId: string, issuerId: string}} apiCreds
 * @return {Promise<Array<{tx: object, environment: string}>>}
 */
async function paychekFetchAppleTransactionHistoryDecoded(
    anyTransactionId,
    apiCreds,
) {
  const id = `${anyTransactionId || ""}`.trim();
  if (!id) return [];

  /** @type {Map<string, {tx: object, environment: string}>} */
  const byTxId = new Map();
  let lastError = null;

  for (const environment of [Environment.SANDBOX, Environment.PRODUCTION]) {
    try {
      const client = new AppStoreServerAPIClient(
          apiCreds.privateKey,
          apiCreds.keyId,
          apiCreds.issuerId,
          PAYCHEK_IOS_BUNDLE_ID,
          environment,
      );
      const request = {
        sort: Order.DESCENDING,
        productTypes: [ProductType.AUTO_RENEWABLE],
      };
      let response = null;
      do {
        const revision = response?.revision ?? null;
        response = await client.getTransactionHistory(
            id,
            revision,
            request,
            GetTransactionHistoryVersion.V2,
        );
        const verifier = buildVerifier(environment, PAYCHEK_IOS_BUNDLE_ID);
        if (!verifier) continue;
        for (const signed of response.signedTransactions || []) {
          try {
            const tx = await verifier.verifyAndDecodeTransaction(signed);
            const tid = `${tx.transactionId || ""}`.trim();
            if (tid) {
              byTxId.set(tid, {tx, environment});
            }
          } catch (decodeErr) {
            console.warn("paychekAppleHistory decode", decodeErr);
          }
        }
      } while (response?.hasMore);
      if (byTxId.size > 0) break;
    } catch (e) {
      lastError = e;
      console.warn("paychekAppleHistory env", environment, e);
    }
  }

  if (byTxId.size === 0 && lastError) throw lastError;
  return [...byTxId.values()];
}

/**
 * Historique App Store pour la console admin (Get Transaction History).
 *
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {{privateKey?: () => string, keyId?: () => string, issuerId?: () => string}|null} credGetters
 * @return {Promise<{configured: boolean, payments: object[], error: string|null}>}
 */
async function paychekAdminFetchAppleBillingHistory(db, uid, credGetters) {
  const id = `${uid ?? ""}`.trim();
  if (!id) {
    return {configured: false, payments: [], error: null};
  }

  const entSnap = await db.collection("subscriber_entitlements").doc(id).get();
  const ent = entSnap.exists ? entSnap.data() || {} : {};
  const transactionId =
    `${ent.appleOriginalTransactionId || ent.appleTransactionId || ""}`.trim();
  const apiCreds = readAppleApiCredentials(credGetters);

  if (!apiCreds) {
    const fallback = paychekApplePaymentFromStoredEntitlement(ent);
    return {
      configured: false,
      payments: fallback ? [fallback] : [],
      error: transactionId ?
        "API App Store non configurée (PAYCHEK_APPLE_IAP_PRIVATE_KEY, KEY_ID, ISSUER_ID)." :
        null,
    };
  }

  if (!transactionId) {
    return {configured: true, payments: [], error: null};
  }

  try {
    const decoded = await paychekFetchAppleTransactionHistoryDecoded(
        transactionId,
        apiCreds,
    );
    const payments = decoded
        .map(paychekApplePaymentRowFromTx)
        .filter(Boolean);
    payments.sort((a, b) => b.created - a.created);
    if (payments.length === 0) {
      const fallback = paychekApplePaymentFromStoredEntitlement(ent);
      if (fallback) {
        return {
          configured: true,
          payments: [fallback],
          error: "Aucune transaction App Store — affichage Firestore.",
        };
      }
    }
    return {configured: true, payments, error: null};
  } catch (e) {
    console.error("paychekAdminFetchAppleBillingHistory", e);
    const fallback = paychekApplePaymentFromStoredEntitlement(ent);
    return {
      configured: true,
      payments: fallback ? [fallback] : [],
      error: e && e.message ? String(e.message) : "apple_history_failed",
    };
  }
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
    paychekListActiveAppleEntitlementCandidates,
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
        let candidates = [];
        if (typeof paychekListActiveAppleEntitlementCandidates === "function") {
          candidates =
            await paychekListActiveAppleEntitlementCandidates(db, targetUid);
        } else if (typeof paychekHintOtherActiveAppleAccounts === "function") {
          const hints =
            await paychekHintOtherActiveAppleAccounts(db, targetUid);
          candidates = hints.map((maskedEmail) => ({maskedEmail}));
        }
        if (candidates.length > 0) {
          const hints = candidates
              .map((c) => c.maskedEmail || c.uid || "")
              .filter(Boolean);
          message +=
            " Un abonnement Apple actif existe sur : " +
            hints.join(", ") +
            ". Utilise « Transférer abonnement Apple ici » ci-dessous, " +
            "ou sur iPhone « Restaurer les achats » avec CE compte Paychek.";
        } else {
          message +=
            " Sur iPhone (connecté avec CE email) : paywall → " +
            "« Restaurer les achats ».";
        }
        throw new HttpsError("failed-precondition", message, {candidates});
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

  const listPaychekAppleTransferCandidates = onCall(
      callOpts,
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
        const db = admin.firestore();
        const excludeUid =
          `${request.data?.excludeUserId ?? request.auth.uid}`.trim();
        if (typeof paychekListActiveAppleEntitlementCandidates !== "function") {
          return {candidates: []};
        }
        const candidates =
          await paychekListActiveAppleEntitlementCandidates(db, excludeUid);
        return {candidates};
      },
  );

  return {
    verifyPaychekApplePurchase,
    restorePaychekAppleEntitlement,
    syncPaychekAppleEntitlement,
    listPaychekAppleTransferCandidates,
  };
}

module.exports = {
  createAppleIapExports,
  resolveAppleTransaction,
  appleTransactionGrantsPro,
  inferApplePeriodEndMillis,
  resolveApplePeriodEndMillis,
  paychekAdminFetchAppleBillingHistory,
  paychekAppleCycleHintFromProductId,
  PAYCHEK_IOS_BUNDLE_ID,
  PAYCHEK_APPLE_APP_ID,
  DEFAULT_PRODUCT_IDS,
};
