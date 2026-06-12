/**
 * Google Play Billing — validation token + activation Pro Firestore.
 *
 * Secret Firebase :
 *   PAYCHEK_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON — JSON compte de service (Play Console)
 * Package : pro.paychek.app
 */

const {google} = require("googleapis");

const PAYCHEK_ANDROID_PACKAGE = "pro.paychek.app";

const DEFAULT_PRODUCT_IDS = new Set([
  "paychek_monthly",
  "paychek_quarterly",
  "paychek_quarterly2",
  "paychek_annual",
]);

const ACTIVE_SUBSCRIPTION_STATES = new Set([
  "SUBSCRIPTION_STATE_ACTIVE",
  "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
  "SUBSCRIPTION_STATE_PENDING",
]);

let _androidPublisher = null;

/**
 * @param {import("firebase-functions/params").SecretParam} secretParam
 */
function loadServiceAccountCredentials(secretParam) {
  let raw = `${secretParam.value() || ""}`.trim();
  if (!raw) {
    throw new Error("google_play_credentials_missing");
  }
  if (
    (raw.startsWith("'") && raw.endsWith("'")) ||
    (raw.startsWith("\"") && raw.endsWith("\""))
  ) {
    raw = raw.slice(1, -1);
  }
  try {
    return JSON.parse(raw);
  } catch (e) {
    throw new Error("google_play_credentials_invalid_json");
  }
}

/**
 * @param {import("firebase-functions/params").SecretParam} secretParam
 */
async function getAndroidPublisher(secretParam) {
  if (_androidPublisher) return _androidPublisher;
  const auth = new google.auth.GoogleAuth({
    credentials: loadServiceAccountCredentials(secretParam),
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });
  const client = await auth.getClient();
  _androidPublisher = google.androidpublisher({
    version: "v3",
    auth: client,
  });
  return _androidPublisher;
}

/**
 * @param {string} packageName
 * @param {string} purchaseToken
 * @param {import("firebase-functions/params").SecretParam} secretParam
 * @return {Promise<object>}
 */
async function fetchGoogleSubscription(
    packageName,
    purchaseToken,
    secretParam,
) {
  const token = `${purchaseToken || ""}`.trim();
  if (!token) {
    throw new Error("purchaseToken_missing");
  }
  const androidpublisher = await getAndroidPublisher(secretParam);
  const res = await androidpublisher.purchases.subscriptionsv2.get({
    packageName,
    token,
  });
  return res.data || {};
}

/**
 * API v1 (secours si v2 ambiguë).
 * @param {string} packageName
 * @param {string} subscriptionId
 * @param {string} purchaseToken
 * @param {import("firebase-functions/params").SecretParam} secretParam
 * @return {Promise<object>}
 */
async function fetchGoogleSubscriptionLegacy(
    packageName,
    subscriptionId,
    purchaseToken,
    secretParam,
) {
  const token = `${purchaseToken || ""}`.trim();
  const androidpublisher = await getAndroidPublisher(secretParam);
  const res = await androidpublisher.purchases.subscriptions.get({
    packageName,
    subscriptionId,
    token,
  });
  return res.data || {};
}

/**
 * @param {object} sub SubscriptionPurchaseV2
 * @param {string} expectedProductId
 * @return {boolean}
 */
function googleSubscriptionGrantsPro(sub, expectedProductId) {
  const state = `${sub.subscriptionState || ""}`;
  // Expiré = plus d’accès. Annulé (CANCELED) = accès jusqu’à expiryTime (règle Play / UE).
  if (state === "SUBSCRIPTION_STATE_EXPIRED") {
    return false;
  }
  if (ACTIVE_SUBSCRIPTION_STATES.has(state)) {
    return true;
  }
  const lineItems = Array.isArray(sub.lineItems) ? sub.lineItems : [];
  if (lineItems.length === 0) {
    if (
      state === "SUBSCRIPTION_STATE_EXPIRED" ||
      state === "SUBSCRIPTION_STATE_CANCELED"
    ) {
      return false;
    }
    return ACTIVE_SUBSCRIPTION_STATES.has(state);
  }
  const now = Date.now();
  for (const item of lineItems) {
    const productId = `${item.productId || ""}`;
    const expiry = item.expiryTime ? Date.parse(item.expiryTime) : NaN;
    const future = !Number.isNaN(expiry) && expiry > now;
    if (!future && state !== "SUBSCRIPTION_STATE_PENDING") continue;
    if (
      !expectedProductId ||
      !productId ||
      productId === expectedProductId ||
      DEFAULT_PRODUCT_IDS.has(productId)
    ) {
      return true;
    }
  }
  return false;
}

/**
 * paymentState: 0 pending, 1 received, 2 free trial, 3 deferred.
 * @param {object} data
 * @return {boolean}
 */
function legacySubscriptionGrantsPro(data) {
  const paymentState = data.paymentState;
  const okPayment =
    paymentState === 0 ||
    paymentState === 1 ||
    paymentState === 2 ||
    paymentState === 3;
  if (!okPayment) return false;
  const exp = Number.parseInt(`${data.expiryTimeMillis || ""}`, 10);
  if (!Number.isNaN(exp) && exp > Date.now()) return true;
  return paymentState === 1 || paymentState === 2;
}

/**
 * @param {string} packageName
 * @param {string} subscriptionId
 * @param {string} purchaseToken
 * @param {import("firebase-functions/params").SecretParam} secretParam
 */
async function acknowledgeGoogleSubscription(
    packageName,
    subscriptionId,
    purchaseToken,
    secretParam,
) {
  const androidpublisher = await getAndroidPublisher(secretParam);
  try {
    await androidpublisher.purchases.subscriptions.acknowledge({
      packageName,
      subscriptionId,
      token: purchaseToken,
    });
  } catch (e) {
    const msg = `${e.message || e}`;
    if (!msg.includes("already") && !msg.includes("400")) {
      console.warn("[Paychek] acknowledge subscription", msg);
    }
  }
}

/**
 * @param {object} sub
 * @return {number|null} millis
 */
/**
 * @param {string|undefined} raw
 * @return {number|null}
 */
function parsePlayExpiryMillis(raw) {
  if (raw == null) return null;
  if (typeof raw === "number" && raw > 0) return raw;
  const parsed = Date.parse(`${raw}`);
  return Number.isNaN(parsed) ? null : parsed;
}

/**
 * @param {object} sub SubscriptionPurchaseV2
 * @return {number|null}
 */
/**
 * Début d’abonnement Play (pour prolonger la fin au-delà d’un essai offre court).
 * @param {object} sub SubscriptionPurchaseV2
 * @return {number|null}
 */
function googleSubscriptionStartMillis(sub) {
  const candidates = [];
  const top = parsePlayExpiryMillis(sub.startTime);
  if (top != null) candidates.push(top);
  const lineItems = Array.isArray(sub.lineItems) ? sub.lineItems : [];
  for (const item of lineItems) {
    const ms = parsePlayExpiryMillis(item.startTime);
    if (ms != null) candidates.push(ms);
  }
  if (candidates.length === 0) return null;
  return Math.min(...candidates);
}

function googleSubscriptionExpiryMillis(sub) {
  const lineItems = Array.isArray(sub.lineItems) ? sub.lineItems : [];
  let maxMs = null;
  for (const item of lineItems) {
    const candidates = [
      item.expiryTime,
      item.autoRenewingPlan && item.autoRenewingPlan.expiryTime,
    ];
    for (const raw of candidates) {
      const ms = parsePlayExpiryMillis(raw);
      if (ms != null) {
        maxMs = maxMs == null ? ms : Math.max(maxMs, ms);
      }
    }
  }
  const top = parsePlayExpiryMillis(sub.expiryTime);
  if (top != null) {
    maxMs = maxMs == null ? top : Math.max(maxMs, top);
  }
  return maxMs;
}

/**
 * Secours si l’API Play ne renvoie pas d’échéance (lineItems vides).
 * @param {string} productId
 * @param {number} startMs
 * @return {number}
 */
/**
 * Play peut renvoyer une échéance courte (essai offre abo) : pour l’affichage admin / Pro,
 * on préfère la durée du forfait (mensuel / trimestriel / annuel) si l’échéance est trop courte.
 * @param {string} productId
 * @param {number|null} expiryMs
 * @param {number} startMs
 * @return {number}
 */
/**
 * @param {string} productId
 * @param {number|null} expiryMs
 * @param {number} startMs
 * @param {string} [subscriptionState] SubscriptionPurchaseV2.subscriptionState
 * @return {number}
 */
function resolveGooglePlayPeriodEndMillis(
    productId,
    expiryMs,
    startMs = Date.now(),
    subscriptionState = "",
) {
  const state = `${subscriptionState || ""}`.trim();
  const now = Date.now();

  if (expiryMs != null && Number.isFinite(expiryMs)) {
    if (state === "SUBSCRIPTION_STATE_EXPIRED" || expiryMs <= now) {
      return expiryMs;
    }
    if (
      state === "SUBSCRIPTION_STATE_CANCELED" ||
      state === "SUBSCRIPTION_STATE_ON_HOLD" ||
      state === "SUBSCRIPTION_STATE_PAUSED"
    ) {
      return expiryMs;
    }
  }

  const inferred = inferGooglePlayPeriodEndMillis(productId, startMs);
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
  if (span < minSpanMs && expiryMs > now) {
    console.log(
        "[Paychek] Play expiry shorter than product period, using max(play,inferred)",
        {
          productId,
          spanDays: Math.round(span / 86400000),
          minDays: Math.round(minSpanMs / 86400000),
          subscriptionState: state,
        },
    );
    return Math.max(expiryMs, inferred);
  }
  return expiryMs;
}

function inferGooglePlayPeriodEndMillis(productId, startMs = Date.now()) {
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
 * @param {object} legacy
 * @return {number|null}
 */
function legacySubscriptionExpiryMillis(legacy) {
  const exp = Number.parseInt(`${legacy.expiryTimeMillis || ""}`, 10);
  return Number.isNaN(exp) ? null : exp;
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {string} productId
 * @param {string} purchaseToken
 * @param {string} orderId
 * @param {number|null} expiryMs
 * @param {function} paychekGrantProEntitlement
 * @param {import("firebase-admin")} admin
 * @param {number} [startMs] début abonnement Play (sinon maintenant)
 */
async function grantProFromGooglePurchase(
    db,
    uid,
    productId,
    purchaseToken,
    orderId,
    expiryMs,
    paychekGrantProEntitlement,
    admin,
    startMs = Date.now(),
    subscriptionState = "",
    paychekApplyTrialRemainderToPeriodEnd = null,
    paychekAssertStoreSubscriptionOwner = null,
) {
  const token = `${purchaseToken || ""}`.trim();
  if (typeof paychekAssertStoreSubscriptionOwner === "function" && token) {
    await paychekAssertStoreSubscriptionOwner(db, uid, {
      googlePlayPurchaseToken: token,
    });
  }

  const anchorMs = Number.isFinite(startMs) ? startMs : Date.now();
  let resolvedExpiryMs = resolveGooglePlayPeriodEndMillis(
      productId,
      expiryMs,
      anchorMs,
      subscriptionState,
  );
  if (expiryMs == null && productId) {
    console.log(
        "[Paychek] Google Play period end inferred from product",
        productId,
        resolvedExpiryMs,
    );
  }
  let currentPeriodEnd = null;
  if (resolvedExpiryMs != null) {
    currentPeriodEnd = admin.firestore.Timestamp.fromMillis(resolvedExpiryMs);
  }
  const proSinceUtc = admin.firestore.Timestamp.fromMillis(
      anchorMs > 0 && anchorMs <= Date.now() ? anchorMs : Date.now(),
  );

  if (typeof paychekApplyTrialRemainderToPeriodEnd === "function") {
    currentPeriodEnd = await paychekApplyTrialRemainderToPeriodEnd(
        db,
        uid,
        currentPeriodEnd,
        proSinceUtc,
    );
  }

  const granted = await paychekGrantProEntitlement(db, uid, {
    provider: "google_play",
    googlePlayPurchaseToken: purchaseToken,
    googlePlayProductId: productId,
    googlePlayOrderId: orderId,
    proSinceUtc,
    currentPeriodEnd,
  });
  return {granted, currentPeriodEnd, proSinceUtc};
}

/**
 * Garantit tier Pro + miroir Firestore après sync Play (même si grant idempotent).
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {object} opts
 * @param {import("firebase-admin")} admin
 */
async function paychekForceGooglePlayProMirror(db, uid, opts, admin) {
  const {
    currentPeriodEnd = null,
    proSinceUtc = null,
    productId = "",
    purchaseToken = "",
    orderId = "",
  } = opts;
  const entRef = db.collection("subscriber_entitlements").doc(uid);
  const userRef = db.collection("paychek_users").doc(uid);
  const entPatch = {
    active: true,
    provider: "google_play",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    googlePlayPurchaseToken: purchaseToken,
    googlePlayProductId: productId,
  };
  if (orderId) entPatch.googlePlayOrderId = orderId;
  if (proSinceUtc) entPatch.proSinceUtc = proSinceUtc;
  if (currentPeriodEnd) entPatch.currentPeriodEnd = currentPeriodEnd;

  const userPatch = {
    subscriptionTier: "pro",
    isPremium: true,
    paymentProvider: "google_play",
    paymentMethod: "google_play",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (proSinceUtc) userPatch.subscriptionProSinceUtc = proSinceUtc;
  if (currentPeriodEnd) {
    userPatch.subscriptionCurrentPeriodEnd = currentPeriodEnd;
  }

  const batch = db.batch();
  batch.set(entRef, entPatch, {merge: true});
  batch.set(userRef, userPatch, {merge: true});
  await batch.commit();
  console.log(
      "[Paychek] forceGooglePlayProMirror",
      uid,
      productId,
      currentPeriodEnd && currentPeriodEnd.toMillis ?
        new Date(currentPeriodEnd.toMillis()).toISOString() :
        null,
  );
}

/**
 * @param {Error} e
 * @return {string}
 */
function googlePlayApiErrorMessage(e) {
  const msg = `${e.message || e}`;
  const status = e.status || e.code || e.response?.status;
  const reasons = Array.isArray(e.errors) ?
    e.errors.map((err) => `${err.reason || ""}`).join(" ") :
    "";
  if (
    status === 401 ||
    status === 403 ||
    msg.includes("401") ||
    msg.includes("403") ||
    msg.includes("insufficient permissions") ||
    msg.includes("permissionDenied") ||
    reasons.includes("permissionDenied") ||
    msg.includes("permission") ||
    msg.includes("Forbidden")
  ) {
    return "play_api_forbidden_link_service_account";
  }
  if (msg.includes("google_play_credentials")) {
    return msg;
  }
  return "play_api_error";
}

/**
 * @param {string} productId
 * @return {string}
 */
function paychekGooglePlayCycleHint(productId) {
  const id = `${productId || ""}`.toLowerCase();
  if (id.includes("annual")) return "1 an";
  if (id.includes("quarterly")) return "3 mois";
  if (id.includes("monthly")) return "1 mois";
  return "";
}

/**
 * @param {object|null} money { units, nanos, currencyCode }
 * @return {{major: number, currency: string}}
 */
function playMoneyToMajor(money) {
  if (!money || typeof money !== "object") {
    return {major: 0, currency: "usd"};
  }
  const units = Number(money.units) || 0;
  const nanos = Number(money.nanos) || 0;
  const cur = `${money.currencyCode || "usd"}`.trim().toLowerCase();
  return {major: units + nanos / 1e9, currency: cur || "usd"};
}

/**
 * @param {object} sub SubscriptionPurchaseV2
 * @param {object|null} legacy legacy subscriptions.get
 * @return {string}
 */
function paychekGoogleSubscriptionDisplayStatus(sub, legacy = null) {
  const state = `${sub?.subscriptionState || ""}`;
  if (state === "SUBSCRIPTION_STATE_EXPIRED") return "Expiré";
  if (state === "SUBSCRIPTION_STATE_CANCELED") return "Annulé";
  if (state === "SUBSCRIPTION_STATE_ON_HOLD") return "En attente";
  if (state === "SUBSCRIPTION_STATE_IN_GRACE_PERIOD") return "Période de grâce";
  if (state === "SUBSCRIPTION_STATE_PENDING") return "En attente";
  if (ACTIVE_SUBSCRIPTION_STATES.has(state)) return "Actif";
  if (legacy?.paymentState === 0) return "Paiement en attente";
  const cancelReason = legacy?.cancelReason;
  if (cancelReason === 1) return "Annulé (système)";
  if (cancelReason === 2) return "Remplacé";
  if (cancelReason === 3) return "Annulé (développeur)";
  return "Réussi";
}

/**
 * @param {object} opts
 * @return {object}
 */
function paychekGooglePaymentRowFromSubscription(opts) {
  const {
    sub,
    legacy = null,
    productId,
    purchaseToken,
    orderId = "",
    chainIndex = 0,
  } = opts;
  const lineItems = Array.isArray(sub?.lineItems) ? sub.lineItems : [];
  const primary =
    lineItems.find((i) => `${i.productId || ""}` === productId) ||
    lineItems[0] ||
    {};
  const pid = `${primary.productId || productId || ""}`.trim();
  const startMs =
    parsePlayExpiryMillis(primary.startTime) ||
    parsePlayExpiryMillis(sub?.startTime) ||
    (legacy?.startTimeMillis ?
      Number.parseInt(`${legacy.startTimeMillis}`, 10) :
      null) ||
    Date.now();
  const expiryMs =
    parsePlayExpiryMillis(primary.expiryTime) ||
    googleSubscriptionExpiryMillis(sub || {}) ||
  legacySubscriptionExpiryMillis(legacy || {});

  let major = 0;
  let currency = "usd";
  const recurring = primary.autoRenewingPlan?.recurringPrice;
  if (recurring) {
    const m = playMoneyToMajor(recurring);
    major = m.major;
    currency = m.currency;
  } else if (legacy?.priceAmountMicros) {
    const micros = Number.parseInt(`${legacy.priceAmountMicros}`, 10);
    if (!Number.isNaN(micros) && micros > 0) {
      major = micros / 1_000_000;
      currency = `${legacy.priceCurrencyCode || "usd"}`.toLowerCase();
    }
  }

  const oid =
    `${orderId || primary.latestSuccessfulOrderId || legacy?.orderId || ""}`.trim();
  const txId = oid || `${purchaseToken}`.slice(0, 24);
  const isLinked = chainIndex > 0;
  let displayStatus = paychekGoogleSubscriptionDisplayStatus(sub, legacy);
  if (isLinked && displayStatus === "Actif") {
    displayStatus = "Ancien achat (lié)";
  }

  return {
    provider: "google_play",
    transactionId: txId,
    originalTransactionId: `${purchaseToken}`.trim(),
    productId: pid,
    amountTotal: Math.round(major * 100),
    amountMajor: major,
    amountRefunded: 0,
    currency,
    paymentStatus: `${sub?.subscriptionState || legacy?.paymentState || ""}`,
    sessionStatus: sub?.testPurchase ? "Test Play" : "Production",
    displayStatus,
    cycleHint: paychekGooglePlayCycleHint(pid),
    failureMessage: "",
    email: "",
    created: Math.floor(startMs / 1000),
    expiresDate: expiryMs ? Math.floor(expiryMs / 1000) : 0,
    environment: sub?.testPurchase ? "Test" : "",
  };
}

/**
 * @param {object} ent
 * @return {object|null}
 */
function paychekGooglePaymentFromStoredEntitlement(ent) {
  const purchaseToken = `${ent.googlePlayPurchaseToken || ""}`.trim();
  const productId = `${ent.googlePlayProductId || ""}`.trim();
  if (!purchaseToken || !productId) return null;
  const proSince =
    ent.proSinceUtc && typeof ent.proSinceUtc.toMillis === "function" ?
      ent.proSinceUtc.toMillis() :
      Date.now();
  const periodEnd =
    ent.currentPeriodEnd && typeof ent.currentPeriodEnd.toMillis === "function" ?
      ent.currentPeriodEnd.toMillis() :
      null;
  return {
    provider: "google_play",
    transactionId:
      `${ent.googlePlayOrderId || purchaseToken}`.trim().slice(0, 64),
    originalTransactionId: purchaseToken,
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
    cycleHint: paychekGooglePlayCycleHint(productId),
    failureMessage:
      "Historique Play indisponible — dernière transaction Firestore.",
    email: "",
    created: Math.floor(proSince / 1000),
    expiresDate: periodEnd ? Math.floor(periodEnd / 1000) : 0,
    environment: "",
  };
}

/**
 * Chaîne linkedPurchaseToken (réabonnement / changement de formule).
 * @param {string} packageName
 * @param {string} startToken
 * @param {import("firebase-functions/params").SecretParam} secretParam
 * @param {string} productId
 * @return {Promise<string[]>}
 */
async function collectGooglePurchaseTokenChain(
    packageName,
    startToken,
    secretParam,
    productId,
) {
  const ordered = [];
  const seen = new Set();
  let token = `${startToken || ""}`.trim();
  let depth = 0;
  while (token && !seen.has(token) && depth < 10) {
    seen.add(token);
    ordered.push(token);
    let linked = "";
    try {
      const sub = await fetchGoogleSubscription(packageName, token, secretParam);
      linked = `${sub.linkedPurchaseToken || ""}`.trim();
    } catch (e) {
      try {
        const legacy = await fetchGoogleSubscriptionLegacy(
            packageName,
            productId,
            token,
            secretParam,
        );
        linked = `${legacy.linkedPurchaseToken || ""}`.trim();
      } catch (_) {
        break;
      }
    }
    if (!linked || seen.has(linked)) break;
    token = linked;
    depth++;
  }
  return ordered;
}

/**
 * Historique Google Play pour la console admin.
 *
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {import("firebase-functions/params").SecretParam} secretParam
 * @return {Promise<{configured: boolean, payments: object[], error: string|null}>}
 */
async function paychekAdminFetchGoogleBillingHistory(db, uid, secretParam) {
  const id = `${uid ?? ""}`.trim();
  if (!id) {
    return {configured: false, payments: [], error: null};
  }

  const entSnap = await db.collection("subscriber_entitlements").doc(id).get();
  const ent = entSnap.exists ? entSnap.data() || {} : {};
  const purchaseToken = `${ent.googlePlayPurchaseToken || ""}`.trim();
  const productId = `${ent.googlePlayProductId || ""}`.trim();
  const storedOrderId = `${ent.googlePlayOrderId || ""}`.trim();

  let configured = false;
  try {
    const raw = `${secretParam.value() || ""}`.trim();
    configured = raw.length > 0;
  } catch (_) {
    configured = false;
  }

  if (!configured) {
    const fallback = paychekGooglePaymentFromStoredEntitlement(ent);
    return {
      configured: false,
      payments: fallback ? [fallback] : [],
      error: purchaseToken ?
        "API Google Play non configurée (PAYCHEK_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON)." :
        null,
    };
  }

  if (!purchaseToken || !productId) {
    return {configured: true, payments: [], error: null};
  }

  try {
    const tokens = await collectGooglePurchaseTokenChain(
        PAYCHEK_ANDROID_PACKAGE,
        purchaseToken,
        secretParam,
        productId,
    );
    const payments = [];
    for (let i = 0; i < tokens.length; i++) {
      const token = tokens[i];
      let sub = null;
      let legacy = null;
      try {
        sub = await fetchGoogleSubscription(
            PAYCHEK_ANDROID_PACKAGE,
            token,
            secretParam,
        );
      } catch (e) {
        console.warn("paychekAdminGoogle subv2", token.slice(0, 12), e);
      }
      try {
        legacy = await fetchGoogleSubscriptionLegacy(
            PAYCHEK_ANDROID_PACKAGE,
            productId,
            token,
            secretParam,
        );
      } catch (e) {
        console.warn("paychekAdminGoogle legacy", token.slice(0, 12), e);
      }
      if (!sub && !legacy) continue;
      const row = paychekGooglePaymentRowFromSubscription({
        sub,
        legacy,
        productId,
        purchaseToken: token,
        orderId: i === 0 ? storedOrderId : "",
        chainIndex: i,
      });
      if (row) payments.push(row);
    }

    payments.sort((a, b) => b.created - a.created);
    if (payments.length === 0) {
      const fallback = paychekGooglePaymentFromStoredEntitlement(ent);
      return {
        configured: true,
        payments: fallback ? [fallback] : [],
        error: "Aucune transaction Play — affichage Firestore.",
      };
    }
    return {configured: true, payments, error: null};
  } catch (e) {
    console.error("paychekAdminFetchGoogleBillingHistory", e);
    const fallback = paychekGooglePaymentFromStoredEntitlement(ent);
    const msg = googlePlayApiErrorMessage(e);
    return {
      configured: true,
      payments: fallback ? [fallback] : [],
      error: msg,
    };
  }
}

/**
 * @param {object} deps
 * @return {object} named Cloud Function exports
 */
function createGooglePlayIapExports(deps) {
  const {
    onCall,
    HttpsError,
    admin,
    paychekGrantProEntitlement,
    paychekRevokeProEntitlement,
    paychekPatchSubscriberPeriodEnd,
    paychekApplyTrialRemainderToPeriodEnd,
    paychekAssertStoreSubscriptionOwner,
    googlePlayServiceAccountJson,
  } = deps;

  if (typeof paychekPatchSubscriberPeriodEnd !== "function") {
    throw new Error("paychekPatchSubscriberPeriodEnd_required");
  }

  /**
   * @param {FirebaseFirestore.Firestore} db
   * @param {string} uid
   * @param {string} productId
   * @param {string} purchaseToken
   * @param {string[]|null} allowedProductIds
   */
  async function verifyGooglePlayPurchaseCore(
      db,
      uid,
      productId,
      purchaseToken,
      allowedProductIds,
  ) {
    if (!DEFAULT_PRODUCT_IDS.has(productId)) {
      if (!Array.isArray(allowedProductIds) || !allowedProductIds.includes(productId)) {
        throw new HttpsError("invalid-argument", "Produit inconnu.");
      }
    }

    await acknowledgeGoogleSubscription(
        PAYCHEK_ANDROID_PACKAGE,
        productId,
        purchaseToken,
        googlePlayServiceAccountJson,
    );

    let sub = null;
    let apiError = null;
    try {
      sub = await fetchGoogleSubscription(
          PAYCHEK_ANDROID_PACKAGE,
          purchaseToken,
          googlePlayServiceAccountJson,
      );
    } catch (e) {
      apiError = googlePlayApiErrorMessage(e);
      console.error("[Paychek] Google Play subscriptionsv2.get failed", e);
    }

    if (sub && googleSubscriptionGrantsPro(sub, productId)) {
      const playStartMs =
        googleSubscriptionStartMillis(sub) || Date.now();
      const {granted, currentPeriodEnd, proSinceUtc} =
        await grantProFromGooglePurchase(
            db,
            uid,
            productId,
            purchaseToken,
            `${sub.latestOrderId || purchaseToken}`,
            googleSubscriptionExpiryMillis(sub),
            paychekGrantProEntitlement,
            admin,
            playStartMs,
            `${sub.subscriptionState || ""}`,
            paychekApplyTrialRemainderToPeriodEnd,
            paychekAssertStoreSubscriptionOwner,
        );
      if (currentPeriodEnd) {
        await paychekPatchSubscriberPeriodEnd(db, uid, currentPeriodEnd);
      }
      await paychekForceGooglePlayProMirror(db, uid, {
        currentPeriodEnd,
        proSinceUtc,
        productId,
        purchaseToken,
        orderId: `${sub.latestOrderId || purchaseToken}`,
      }, admin);
      return {
        active: true,
        granted,
        source: "subscriptionsv2",
        currentPeriodEndMillis: currentPeriodEnd ?
          currentPeriodEnd.toMillis() :
          null,
      };
    }

    let legacy = null;
    try {
      legacy = await fetchGoogleSubscriptionLegacy(
          PAYCHEK_ANDROID_PACKAGE,
          productId,
          purchaseToken,
          googlePlayServiceAccountJson,
      );
    } catch (e) {
      const legacyErr = googlePlayApiErrorMessage(e);
      console.error("[Paychek] Google Play subscriptions.get failed", e);
      if (apiError) {
        throw new HttpsError(
            "failed-precondition",
            apiError === "play_api_forbidden_link_service_account" ?
              "Compte de service non autorisé dans Play Console pour pro.paychek.app." :
              "Validation Google Play impossible (API).",
            {reason: apiError, legacyReason: legacyErr},
        );
      }
    }

    if (legacy && legacySubscriptionGrantsPro(legacy)) {
      const legacyStart = Number.parseInt(
          `${legacy.startTimeMillis || ""}`,
          10,
      );
      const legacyStartMs = Number.isNaN(legacyStart) ?
        Date.now() :
        legacyStart;
      const {granted, currentPeriodEnd, proSinceUtc} =
        await grantProFromGooglePurchase(
            db,
            uid,
            productId,
            purchaseToken,
            `${legacy.orderId || purchaseToken}`,
            legacySubscriptionExpiryMillis(legacy),
            paychekGrantProEntitlement,
            admin,
            legacyStartMs,
            "",
            paychekApplyTrialRemainderToPeriodEnd,
            paychekAssertStoreSubscriptionOwner,
        );
      if (currentPeriodEnd) {
        await paychekPatchSubscriberPeriodEnd(db, uid, currentPeriodEnd);
      }
      await paychekForceGooglePlayProMirror(db, uid, {
        currentPeriodEnd,
        proSinceUtc,
        productId,
        purchaseToken,
        orderId: `${legacy.orderId || purchaseToken}`,
      }, admin);
      return {
        active: true,
        granted,
        source: "subscriptions_v1",
        currentPeriodEndMillis: currentPeriodEnd ?
          currentPeriodEnd.toMillis() :
          null,
      };
    }

    if (apiError) {
      throw new HttpsError(
          "failed-precondition",
          apiError === "play_api_forbidden_link_service_account" ?
            "Compte de service non autorisé dans Play Console pour pro.paychek.app." :
            "Validation Google Play impossible (API).",
          {reason: apiError},
      );
    }

    console.warn(
        "[Paychek] Google Play sub not granting pro",
        productId,
        sub && sub.subscriptionState,
        sub && JSON.stringify(sub.lineItems || []),
        legacy && legacy.paymentState,
        legacy && legacy.expiryTimeMillis,
    );
    let playExpiryMs = null;
    if (sub) {
      playExpiryMs = googleSubscriptionExpiryMillis(sub);
    } else if (legacy) {
      playExpiryMs = legacySubscriptionExpiryMillis(legacy);
    }
    if (
      playExpiryMs != null &&
      Number.isFinite(playExpiryMs) &&
      paychekPatchSubscriberPeriodEnd
    ) {
      await paychekPatchSubscriberPeriodEnd(
          db,
          uid,
          admin.firestore.Timestamp.fromMillis(playExpiryMs),
          {forceReplace: true},
      );
    }
    await paychekRevokeProEntitlement(db, uid, {
      provider: "google_play",
      reason: "google_play_expired_or_inactive",
    });
    const stateLabel = sub && sub.subscriptionState ?
      `${sub.subscriptionState}` :
      "";
    return {
      active: false,
      reason: "expired_or_inactive",
      subscriptionState: sub && sub.subscriptionState,
      legacyPaymentState: legacy && legacy.paymentState,
      currentPeriodEndMillis: playExpiryMs,
      message: stateLabel === "SUBSCRIPTION_STATE_EXPIRED" ?
        "Abonnement Google Play expiré (sandbox ou fin de période). " +
        "Réabonnez-vous depuis l’app ; la date affichée = échéance Play réelle." :
        "Abonnement Google Play inactif côté Google.",
    };
  }

  async function verifyAndGrant(request) {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Connexion requise.");
    }
    const purchaseToken = `${request.data?.purchaseToken ?? ""}`.trim();
    const productId = `${request.data?.productId ?? ""}`.trim();
    if (!purchaseToken || !productId) {
      throw new HttpsError(
          "invalid-argument",
          "Achat Google Play invalide.",
      );
    }
    const db = admin.firestore();
    const allowed = Array.isArray(request.data?.allowedProductIds) ?
      request.data.allowedProductIds :
      null;
    try {
      return await verifyGooglePlayPurchaseCore(
          db,
          request.auth.uid,
          productId,
          purchaseToken,
          allowed,
      );
    } catch (e) {
      console.error("[Paychek] verifyPaychekGooglePurchase", e);
      if (e instanceof HttpsError) throw e;
      if (
        `${e.message || ""}`.includes(
            "google_play_subscription_linked_to_other_account",
        )
      ) {
        const hint = e.otherAccountHint ?
          ` (${e.otherAccountHint})` :
          "";
        throw new HttpsError(
            "failed-precondition",
            "Cet abonnement Google Play est déjà lié à un autre compte Paychek." +
            hint +
            " Connecte-toi avec le compte d’origine ou contacte le support.",
        );
      }
      throw new HttpsError(
          "internal",
          e && e.message ? String(e.message) : "google_verify_failed",
      );
    }
  }

  async function syncStoredGooglePlayEntitlement(request) {
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
    const entSnap =
      await db.collection("subscriber_entitlements").doc(targetUid).get();
    const ent = entSnap.exists ? entSnap.data() || {} : {};
    const purchaseToken = `${ent.googlePlayPurchaseToken || ""}`.trim();
    const productId = `${ent.googlePlayProductId || ""}`.trim();
    if (!purchaseToken || !productId) {
      throw new HttpsError(
          "failed-precondition",
          "Aucun achat Google Play enregistré pour ce compte.",
      );
    }
    console.log("[Paychek] syncStoredGooglePlayEntitlement", targetUid, productId);
    return await verifyGooglePlayPurchaseCore(
        db,
        targetUid,
        productId,
        purchaseToken,
        [...DEFAULT_PRODUCT_IDS],
    );
    } catch (e) {
      console.error("[Paychek] syncStoredGooglePlayEntitlement", e);
      if (e instanceof HttpsError) throw e;
      throw new HttpsError(
          "internal",
          e && e.message ? String(e.message) : "sync_google_play_failed",
      );
    }
  }

  const callOpts = {
    region: "europe-west1",
    timeoutSeconds: 60,
    memory: "256MiB",
    secrets: [googlePlayServiceAccountJson],
  };

  const verifyPaychekGooglePurchase = onCall(callOpts, verifyAndGrant);

  const restorePaychekGoogleEntitlement = onCall(callOpts, verifyAndGrant);

  const syncPaychekGooglePlayEntitlement = onCall(callOpts, syncStoredGooglePlayEntitlement);

  return {
    verifyPaychekGooglePurchase,
    restorePaychekGoogleEntitlement,
    syncPaychekGooglePlayEntitlement,
  };
}

module.exports = {
  createGooglePlayIapExports,
  fetchGoogleSubscription,
  fetchGoogleSubscriptionLegacy,
  googleSubscriptionGrantsPro,
  googleSubscriptionExpiryMillis,
  googleSubscriptionStartMillis,
  inferGooglePlayPeriodEndMillis,
  resolveGooglePlayPeriodEndMillis,
  legacySubscriptionGrantsPro,
  paychekAdminFetchGoogleBillingHistory,
  paychekGooglePlayCycleHint,
  PAYCHEK_ANDROID_PACKAGE,
  DEFAULT_PRODUCT_IDS,
};
