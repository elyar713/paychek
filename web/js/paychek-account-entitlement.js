'use strict';

/**
 * Helpers marketing : Firebase Auth/Firestore + statut Pro / URLs Stripe.
 * Réutilisé par licence.html et facturation.html (sans boot Flutter).
 */
(function (global) {
  var FIREBASE_CONFIG = {
    apiKey: 'AIzaSyB_hs_XTxovKaTPz4SQ8cYGSlGmjue3JqY',
    authDomain: 'paychek-trading.firebaseapp.com',
    projectId: 'paychek-trading',
    storageBucket: 'paychek-trading.firebasestorage.app',
    messagingSenderId: '738203717325',
    appId: '1:738203717325:web:28a7a4da987d1caa36e384',
  };

  var REGION = 'europe-west1';
  var _ready = null;

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement('script');
      s.src = src;
      s.async = true;
      s.onload = resolve;
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }

  function ensureFirebase() {
    if (_ready) return _ready;
    _ready = Promise.resolve()
      .then(function () {
        if (global.firebase && global.firebase.initializeApp) return;
        return loadScript(
          'https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js',
        );
      })
      .then(function () {
        if (global.firebase.auth) return;
        return loadScript(
          'https://www.gstatic.com/firebasejs/10.14.1/firebase-auth-compat.js',
        );
      })
      .then(function () {
        if (global.firebase.firestore) return;
        return loadScript(
          'https://www.gstatic.com/firebasejs/10.14.1/firebase-firestore-compat.js',
        );
      })
      .then(function () {
        try {
          global.firebase.app();
        } catch (_e) {
          global.firebase.initializeApp(FIREBASE_CONFIG);
        }
        return {
          auth: global.firebase.auth(),
          db: global.firebase.firestore(),
        };
      });
    return _ready;
  }

  function parseInstant(raw) {
    if (raw == null) return null;
    if (typeof raw.toDate === 'function') {
      try {
        return raw.toDate();
      } catch (_e) {
        return null;
      }
    }
    if (typeof raw.toMillis === 'function') {
      try {
        var fromMs = new Date(raw.toMillis());
        return isNaN(fromMs.getTime()) ? null : fromMs;
      } catch (_e2) {
        return null;
      }
    }
    if (typeof raw === 'number' && isFinite(raw)) {
      var ms = raw < 1e12 ? raw * 1000 : raw;
      var d = new Date(ms);
      return isNaN(d.getTime()) ? null : d;
    }
    if (typeof raw === 'string' && raw.trim()) {
      var trimmed = raw.trim();
      if (/^\d+$/.test(trimmed)) {
        var asNum = Number(trimmed);
        if (isFinite(asNum)) {
          var msNum = asNum < 1e12 ? asNum * 1000 : asNum;
          var dNum = new Date(msNum);
          if (!isNaN(dNum.getTime())) return dNum;
        }
      }
      var d2 = new Date(trimmed);
      return isNaN(d2.getTime()) ? null : d2;
    }
    if (raw && typeof raw === 'object') {
      var sec =
        raw.seconds != null
          ? Number(raw.seconds)
          : raw._seconds != null
            ? Number(raw._seconds)
            : NaN;
      if (isFinite(sec)) {
        var ns =
          raw.nanoseconds != null
            ? Number(raw.nanoseconds)
            : raw._nanoseconds != null
              ? Number(raw._nanoseconds)
              : 0;
        var d3 = new Date(sec * 1000 + Math.floor((ns || 0) / 1e6));
        return isNaN(d3.getTime()) ? null : d3;
      }
    }
    return null;
  }

  function firstInstant(data, keys) {
    if (!data) return null;
    for (var i = 0; i < keys.length; i++) {
      var d = parseInstant(data[keys[i]]);
      if (d) return d;
    }
    return null;
  }

  /** Subscription period / expiry fields (not revoke timestamps). */
  var PERIOD_END_KEYS = [
    'currentPeriodEnd',
    'subscriptionCurrentPeriodEnd',
    'adminCompPeriodEnd',
    'expiresAt',
    'periodEnd',
    'proExpiresAt',
    'expiryDate',
    'subscriptionEnd',
    'validUntil',
    'currentPeriodEndMillis',
    'expiryTimeMillis',
    'expiresDate',
  ];

  /**
   * Pick the best display end date: prefer a live (future) end if any,
   * otherwise the most recent past end (expired Pro).
   */
  function resolvePeriodEndInstant(user, ent) {
    user = user || {};
    ent = ent || {};
    var now = Date.now();
    var bestLive = null;
    var bestPast = null;
    function consider(raw) {
      var d = parseInstant(raw);
      if (!d) return;
      var t = d.getTime();
      if (t > now) {
        if (!bestLive || t < bestLive.getTime()) bestLive = d;
      } else if (!bestPast || t > bestPast.getTime()) {
        bestPast = d;
      }
    }
    for (var i = 0; i < PERIOD_END_KEYS.length; i++) {
      var key = PERIOD_END_KEYS[i];
      consider(ent[key]);
      consider(user[key]);
    }
    return bestLive || bestPast || null;
  }

  function inferPeriodEndFromProSince(proSince, productHint, paymentMethod) {
    if (!proSince) return null;
    var id = String(productHint || '')
      .trim()
      .toLowerCase();
    var start = proSince.getTime();
    if (!isFinite(start)) return null;
    var days = 30;
    var channel = String(paymentMethod || '')
      .trim()
      .toLowerCase();
    // Web Stripe Journal Pro is annual when no product id is stored.
    if (channel === 'stripe' && !id) days = 365;
    if (id.indexOf('annual') >= 0 || id.indexOf('year') >= 0) days = 365;
    else if (id.indexOf('quarter') >= 0) days = 90;
    else if (id.indexOf('month') >= 0) days = 30;
    return new Date(start + days * 24 * 60 * 60 * 1000);
  }

  function sanitizeClientRef(uid) {
    var t = String(uid || '').trim().replace(/[^a-zA-Z0-9_-]/g, '');
    if (!t) return null;
    return t.length > 200 ? t.slice(0, 200) : t;
  }

  /**
   * Canonique : stripe | apple_iap | google_play | admin | '' .
   * Accepte les alias historiques (app_store, ios, play_store, android, …).
   */
  function normalizeBillingChannel(raw) {
    var t = String(raw || '')
      .trim()
      .toLowerCase()
      .replace(/[\s-]+/g, '_');
    if (!t) return '';
    if (
      t === 'stripe' ||
      t === 'stripe_web' ||
      t === 'web' ||
      t === 'card'
    ) {
      return 'stripe';
    }
    if (
      t === 'apple_iap' ||
      t === 'apple' ||
      t === 'app_store' ||
      t === 'appstore' ||
      t === 'ios' ||
      t === 'iphone' ||
      t === 'ipad' ||
      t === 'storekit'
    ) {
      return 'apple_iap';
    }
    if (
      t === 'google_play' ||
      t === 'google' ||
      t === 'play_store' ||
      t === 'playstore' ||
      t === 'android' ||
      t === 'play' ||
      t === 'gp'
    ) {
      return 'google_play';
    }
    if (t === 'admin' || t === 'comp' || t === 'gift' || t === 'courtesy') {
      return 'admin';
    }
    return '';
  }

  function firstNonEmptyString() {
    for (var i = 0; i < arguments.length; i++) {
      var s = String(arguments[i] == null ? '' : arguments[i]).trim();
      if (s) return s;
    }
    return '';
  }

  /**
   * Résout le canal de facturation depuis paychek_users + subscriber_entitlements.
   * Même logique que l’admin (`_adminInferStorePaymentChannel`) : ne pas se
   * limiter à paymentMethod — IAP écrit aussi paymentProvider / provider /
   * product ids / tokens.
   */
  function resolveBillingChannel(user, ent) {
    user = user || {};
    ent = ent || {};
    var fields = [
      user.paymentMethod,
      user.paymentProvider,
      user.billingProvider,
      user.billingChannel,
      user.store,
      ent.provider,
      ent.paymentMethod,
      ent.paymentProvider,
      ent.billingProvider,
      ent.billingChannel,
      ent.source,
    ];
    for (var i = 0; i < fields.length; i++) {
      var channel = normalizeBillingChannel(fields[i]);
      if (channel) return channel;
    }

    var googleHint = firstNonEmptyString(
      ent.googlePlayPurchaseToken,
      ent.googlePlayProductId,
      ent.googlePlayOrderId,
      user.googlePlayProductId,
      user.googlePlayPurchaseToken,
    );
    if (googleHint) return 'google_play';

    var appleHint = firstNonEmptyString(
      ent.appleTransactionId,
      ent.appleOriginalTransactionId,
      ent.appleProductId,
      user.appleProductId,
      user.appleTransactionId,
    );
    if (appleHint) return 'apple_iap';

    var stripeHint = firstNonEmptyString(
      user.stripeCustomerId,
      ent.stripeCustomerId,
      ent.stripeSubscriptionId,
      ent.stripeCheckoutSessionId,
      user.stripeSubscriptionId,
    );
    if (stripeHint) return 'stripe';

    return '';
  }

  function buildCheckoutUri(baseUrl, email, uid) {
    var trimmed = String(baseUrl || '').trim();
    if (!trimmed) return null;
    var base;
    try {
      base = new URL(trimmed);
    } catch (_e) {
      return null;
    }
    if (base.protocol !== 'https:' && base.protocol !== 'http:') return null;
    if (base.hostname.indexOf('stripe.com') < 0) return null;
    var em = String(email || '').trim();
    if (em && !base.searchParams.has('prefilled_email')) {
      base.searchParams.set('prefilled_email', em);
    }
    var ref = sanitizeClientRef(uid);
    if (ref && !base.searchParams.has('client_reference_id')) {
      base.searchParams.set('client_reference_id', ref);
    }
    return base.toString();
  }

  /**
   * Pastille Safeguard (licence.html / admin) :
   * - inactive : aucun essai réclamé et aucune licence liée (ou licence révoquée seule)
   * - lite     : essai réclamé via Activer (uid) OU licence trial non révoquée
   * - pro      : licence payante / Pro annuelle non révoquée (prioritaire sur l’essai)
   *
   * @param {object|null} license
   * @param {{ trialClaimed?: boolean }} [opts]
   */
  function resolveSafeguardBadge(license, opts) {
    opts = opts || {};
    var trialClaimed = opts.trialClaimed === true;
    // Revoked-only → Inactive (even if a claim doc still exists).
    if (license && license.revoked === true) return 'inactive';
    if (license && !isTrialSafeguardLicense(license)) return 'pro';
    if (trialClaimed) return 'lite';
    if (license) return 'lite';
    return 'inactive';
  }

  function isSafeguardExpired(license) {
    if (!license) return false;
    var exp = firstInstant(license, ['expiresAt', 'trialExpiresAt']);
    return !!(exp && exp.getTime() < Date.now());
  }

  function isTrialSafeguardLicense(d) {
    if (!d || typeof d !== 'object') return false;
    if (d.isTrial === true) return true;
    if (String(d.source || '').toLowerCase() === 'trial_claim') return true;
    var plan = String(d.plan || '')
      .trim()
      .toLowerCase();
    var type = String(d.type || '')
      .trim()
      .toLowerCase();
    return plan === 'trial' || type === 'trial';
  }

  /**
   * Prefer paid/Pro over trial (even if trial is activated / still valid).
   * Among equals: non-expired, later expiry, more recently issued.
   */
  function pickBestSafeguardLicense(docs) {
    var best = null;
    var bestMeta = null;
    var revokedOnly = null;
    var now = Date.now();

    function meta(d) {
      var trial = isTrialSafeguardLicense(d);
      var exp = firstInstant(d, ['expiresAt', 'trialExpiresAt']);
      var created = firstInstant(d, ['createdAt', 'issuedAt']);
      var acts = Array.isArray(d.activations) ? d.activations.length : 0;
      var expired = !!(exp && exp.getTime() < now);
      return {
        trial: trial,
        expired: expired,
        // Paid without expiry = long-lived (sort after dated paid, before trial).
        expMs: exp
          ? exp.getTime()
          : trial
            ? 0
            : Number.MAX_SAFE_INTEGER,
        createdMs: created ? created.getTime() : 0,
        acts: acts,
      };
    }

    function better(am, bm) {
      if (am.trial !== bm.trial) return !am.trial;
      if (am.expired !== bm.expired) return !am.expired;
      if (am.expMs !== bm.expMs) return am.expMs > bm.expMs;
      if (am.createdMs !== bm.createdMs) return am.createdMs > bm.createdMs;
      if (am.acts !== bm.acts) return am.acts > bm.acts;
      return false;
    }

    for (var i = 0; i < docs.length; i++) {
      var d = docs[i];
      if (!d) continue;
      if (d.revoked === true) {
        if (!revokedOnly) revokedOnly = d;
        continue;
      }
      var m = meta(d);
      if (!best || better(m, bestMeta)) {
        best = d;
        bestMeta = m;
      }
    }
    if (best) return best;
    return revokedOnly;
  }

  function mergeSafeguardLicenseDocs(lists) {
    var byId = {};
    for (var i = 0; i < lists.length; i++) {
      var list = lists[i] || [];
      for (var j = 0; j < list.length; j++) {
        var d = list[j];
        if (!d) continue;
        var id = String(d.id || d.key || '').trim();
        if (!id) continue;
        if (!byId[id]) byId[id] = d;
      }
    }
    var out = [];
    for (var k in byId) {
      if (Object.prototype.hasOwnProperty.call(byId, k)) out.push(byId[k]);
    }
    return out;
  }

  function querySafeguardLicenses(fb, field, value) {
    if (!value) return Promise.resolve([]);
    return fb.db
      .collection('safeguard_licenses')
      .where(field, '==', value)
      .limit(20)
      .get()
      .then(function (snap) {
        var out = [];
        snap.forEach(function (doc) {
          var data = doc.data() || {};
          data.id = doc.id;
          out.push(data);
        });
        return out;
      })
      .catch(function (err) {
        console.warn('[paychek] safeguard query failed', field, err);
        return [];
      });
  }

  function loadSafeguardStatus(uid, emailHint) {
    return ensureFirebase().then(function (fb) {
      var authUser = fb.auth.currentUser;
      var id = String(uid || (authUser && authUser.uid) || '').trim();
      if (!id) {
        return {
          badge: 'inactive',
          license: null,
          trialClaimed: false,
          trialClaim: null,
        };
      }
      // Rules allow owner read by userId OR userEmail == auth.token.email.
      // Admin Pro mints often set userEmail only — also query by auth email.
      // Prefer auth email (required by rules); fall back to account email hint.
      var emailForQuery = String((authUser && authUser.email) || emailHint || '')
        .trim()
        .toLowerCase();
      return Promise.all([
        querySafeguardLicenses(fb, 'userId', id),
        emailForQuery
          ? querySafeguardLicenses(fb, 'userEmail', emailForQuery)
          : Promise.resolve([]),
        fb.db
          .collection('safeguard_trial_claims')
          .doc(id)
          .get()
          .then(function (snap) {
            return snap.exists ? snap.data() || {} : null;
          })
          .catch(function (err) {
            console.warn('[paychek] trial claim read failed', err);
            return null;
          }),
      ]).then(function (triple) {
        var licenses = mergeSafeguardLicenseDocs([triple[0], triple[1]]);
        var claim = triple[2];
        var license = pickBestSafeguardLicense(licenses);
        if (
          (!license || license.revoked === true) &&
          claim &&
          (claim.licenseKey || claim.licenseId)
        ) {
          // Fall back to claim record so the code stays visible for this uid.
          license = {
            id: String(claim.licenseId || claim.licenseKey || ''),
            key: String(claim.licenseKey || claim.licenseId || ''),
            plan: 'trial',
            revoked: false,
            expiresAt: claim.expiresAt || null,
            maxActivations: 1,
            activations: [],
            source: 'trial_claim',
          };
        }
        var trialClaimed = !!(claim && (claim.licenseKey || claim.claimedAt));
        var revokedOnly = !!(license && license.revoked === true);
        var usable = revokedOnly ? null : license;
        return {
          badge: resolveSafeguardBadge(license, {
            trialClaimed: trialClaimed,
          }),
          license: usable,
          revokedOnly: revokedOnly,
          trialClaimed: trialClaimed,
          trialClaim: claim,
        };
      });
    });
  }

  function loadAccountSnapshot(uid) {
    return ensureFirebase().then(function (fb) {
      var userRef = fb.db.collection('paychek_users').doc(uid);
      var entRef = fb.db.collection('subscriber_entitlements').doc(uid);
      return Promise.all([userRef.get(), entRef.get()]).then(function (pair) {
        var userSnap = pair[0];
        var entSnap = pair[1];
        var user = userSnap.exists ? userSnap.data() || {} : {};
        var ent = entSnap.exists ? entSnap.data() || {} : {};

        var now = Date.now();
        var adminComp =
          firstInstant(ent, ['adminCompPeriodEnd']) ||
          firstInstant(user, ['adminCompPeriodEnd']);
        var adminGiftLive = !!(adminComp && adminComp.getTime() > now);
        var endedAt =
          firstInstant(ent, ['subscriptionEndedAt', 'endedAt']) ||
          firstInstant(user, ['subscriptionEndedAt', 'proEndedAt']);
        var periodEnd = resolvePeriodEndInstant(user, ent);
        if (adminComp && (!periodEnd || adminComp.getTime() > periodEnd.getTime())) {
          periodEnd = adminComp;
        }

        var tier = String(user.subscriptionTier || '').toLowerCase();
        var docPro = tier === 'pro' || user.isPremium === true;
        var entStatus = String(
          ent.status || ent.subscriptionStatus || user.subscriptionStatus || '',
        )
          .trim()
          .toLowerCase();
        var endReason = String(ent.subscriptionEndReason || '')
          .trim()
          .toLowerCase();
        var statusSaysExpired =
          entStatus === 'expired' ||
          entStatus === 'canceled' ||
          entStatus === 'cancelled';
        var reasonSaysFormerPro =
          endReason.length > 0 &&
          (endReason.indexOf('expired') >= 0 ||
            endReason.indexOf('inactive') >= 0 ||
            endReason.indexOf('revok') >= 0 ||
            endReason.indexOf('cancel') >= 0 ||
            endReason.indexOf('transfer') >= 0 ||
            endReason.indexOf('admin_set_lite') >= 0);
        var periodPast = !!(periodEnd && periodEnd.getTime() <= now);
        var periodLive = !!(periodEnd && periodEnd.getTime() > now);

        var paymentMethod = resolveBillingChannel(user, ent);
        var stripeCustomerId = String(
          user.stripeCustomerId || ent.stripeCustomerId || '',
        ).trim();
        var email = String(user.email || '').trim();
        var storeProductHint = firstNonEmptyString(
          ent.googlePlayProductId,
          ent.appleProductId,
          user.googlePlayProductId,
          user.appleProductId,
          ent.stripeSubscriptionId,
          user.stripeSubscriptionId,
          ent.stripeCheckoutSessionId,
        );
        var proSince =
          firstInstant(ent, ['proSinceUtc', 'proSince', 'currentPeriodStart']) ||
          firstInstant(user, [
            'subscriptionProSinceUtc',
            'proSinceUtc',
            'proSince',
          ]);
        var hadPaidProSignals =
          !!paymentMethod ||
          stripeCustomerId.length > 0 ||
          !!storeProductHint ||
          !!endedAt ||
          !!endReason ||
          reasonSaysFormerPro ||
          statusSaysExpired ||
          ent.active === true ||
          docPro ||
          !!proSince;

        // Infer a display date when Stripe/admin grants left currentPeriodEnd empty.
        if (!periodEnd && proSince && (docPro || ent.active === true || hadPaidProSignals)) {
          periodEnd = inferPeriodEndFromProSince(
            proSince,
            storeProductHint,
            paymentMethod,
          );
          periodPast = !!(periodEnd && periodEnd.getTime() <= now);
          periodLive = !!(periodEnd && periodEnd.getTime() > now);
        }

        // Last resort for former Pro: use subscriptionEndedAt as display date.
        if (!periodEnd && endedAt && (hadPaidProSignals || reasonSaysFormerPro)) {
          periodEnd = endedAt;
          periodPast = !!(periodEnd && periodEnd.getTime() <= now);
          periodLive = !!(periodEnd && periodEnd.getTime() > now);
        }

        // Past periodEnd / expired status wins over stale isPremium / active flags.
        // Do NOT let a stale subscriptionEndReason demote a live re-subscribe.
        var active = false;
        if (adminGiftLive) {
          active = true;
        } else if (periodPast) {
          active = false;
        } else if (statusSaysExpired && ent.active !== true) {
          active = false;
        } else if (ent.active === true) {
          active = true;
        } else if (docPro && (!periodEnd || periodLive)) {
          active = true;
        }

        // Former Pro: past end date / expired status / billing history after downgrade.
        var proExpired =
          !active &&
          (periodPast ||
            statusSaysExpired ||
            reasonSaysFormerPro ||
            !!endedAt ||
            !!endReason ||
            (!!periodEnd && hadPaidProSignals) ||
            (!!paymentMethod && hadPaidProSignals) ||
            (!!proSince && !periodLive));

        // Account creation: Firestore first, then Auth metadata (always present for signed-in users).
        var accountCreatedAt =
          firstInstant(user, ['createdAt', 'created_at']) || null;
        if (!accountCreatedAt) {
          var authUser = fb.auth.currentUser;
          if (
            authUser &&
            authUser.uid === uid &&
            authUser.metadata &&
            authUser.metadata.creationTime
          ) {
            accountCreatedAt = parseInstant(authUser.metadata.creationTime);
          }
        }

        return loadSafeguardStatus(uid, email).then(function (sg) {
          var trialClaimed =
            !!user.safeguardTrialClaimedAt ||
            !!(sg && sg.trialClaimed) ||
            !!(sg && sg.license && String(sg.license.plan || '').toLowerCase() === 'trial');
          var lic = (sg && sg.license) || null;
          var paidLicense = !!(lic && !isTrialSafeguardLicense(lic));
          // Paid Pro must show its own expiry — never fall back to trial dates.
          var sgExpires =
            (lic && firstInstant(lic, ['expiresAt', 'trialExpiresAt'])) || null;
          if (!sgExpires && !paidLicense) {
            sgExpires =
              (sg &&
                sg.trialClaim &&
                firstInstant(sg.trialClaim, ['expiresAt'])) ||
              firstInstant(user, ['safeguardTrialExpiresAt']) ||
              null;
          }
          // Re-resolve with account-level claim flags. Revoked-only stays Inactive.
          var badge =
            sg && sg.revokedOnly
              ? 'inactive'
              : resolveSafeguardBadge(lic, { trialClaimed: trialClaimed });
          return {
            isPro: !!active,
            proExpired: !!proExpired,
            // Any paid/former Pro signal — never show "Sans expiration" for these.
            everPro: !!(active || proExpired || hadPaidProSignals),
            // Show a date whenever we have periodEnd for active or former Pro.
            hasExpiration: !!(
              periodEnd &&
              (active || proExpired || periodPast || hadPaidProSignals)
            ),
            periodEnd: periodEnd,
            journalFirstOpenedAt: firstInstant(user, ['journalFirstOpenedAt']),
            accountCreatedAt: accountCreatedAt,
            paymentMethod: paymentMethod,
            stripeCustomerId: stripeCustomerId,
            hasStripeCustomer:
              stripeCustomerId.length > 0 || paymentMethod === 'stripe',
            email: email,
            googlePlayProductId: String(
              ent.googlePlayProductId || user.googlePlayProductId || '',
            ).trim(),
            appleProductId: String(
              ent.appleProductId || user.appleProductId || '',
            ).trim(),
            safeguardBadge: badge,
            safeguardLicense: lic,
            safeguardTrialClaimed: trialClaimed,
            safeguardExpiresAt: sgExpires,
          };
        });
      });
    });
  }

  function loadBillingConfig() {
    return ensureFirebase().then(function (fb) {
      return fb.db
        .collection('paychek_app_config')
        .doc('billing')
        .get()
        .then(function (snap) {
          var d = snap.exists ? snap.data() || {} : {};
          var enabled = d.stripeBillingEnabled !== false;
          var monthly = String(d.stripeCheckoutUrlMonthly || '').trim();
          var quarterly = String(d.stripeCheckoutUrlQuarterly || '').trim();
          var annual = String(
            d.stripeCheckoutUrlAnnual || d.stripeCheckoutUrl || '',
          ).trim();
          return {
            enabled: enabled,
            monthly: monthly || null,
            quarterly: quarterly || null,
            annual: annual || null,
            safeguardPaymentUrl:
              String(d.safeguardPaymentUrl || '').trim() || null,
          };
        });
    });
  }

  function openBillingPortal(returnUrl) {
    return ensureFirebase().then(function (fb) {
      var user = fb.auth.currentUser;
      if (!user) return Promise.reject(new Error('unauthenticated'));
      return user.getIdToken().then(function (token) {
        var url =
          'https://' +
          REGION +
          '-' +
          FIREBASE_CONFIG.projectId +
          '.cloudfunctions.net/createPaychekStripeBillingPortal';
        return fetch(url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: 'Bearer ' + token,
          },
          body: JSON.stringify({
            data: {
              returnUrl:
                returnUrl ||
                global.location.origin + '/facturation.html',
            },
          }),
        }).then(function (res) {
          return res.json().then(function (body) {
            if (!res.ok) {
              var msg =
                (body && body.error && body.error.message) ||
                'HTTP ' + res.status;
              var err = new Error(msg);
              err.code = body && body.error && body.error.status;
              throw err;
            }
            var result = body && (body.result || body);
            var portalUrl = result && result.url ? String(result.url).trim() : '';
            if (!portalUrl) throw new Error('empty_portal_url');
            return portalUrl;
          });
        });
      });
    });
  }

  /**
   * Self-serve Safeguard 7-day trial: mints a key (server-side) and emails it.
   * @param {{ email?: string, locale?: string }} opts
   * @returns {Promise<{ ok: boolean, status: string, deliveryEmail?: string, licenseKey?: string, expiresAt?: string, trialDays?: number }>}
   */
  function requestSafeguardLicenseCode(opts) {
    opts = opts || {};
    return ensureFirebase().then(function (fb) {
      var user = fb.auth.currentUser;
      if (!user) return Promise.reject(new Error('unauthenticated'));
      return user.getIdToken().then(function (token) {
        var url =
          'https://' +
          REGION +
          '-' +
          FIREBASE_CONFIG.projectId +
          '.cloudfunctions.net/requestSafeguardLicenseCode';
        return fetch(url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: 'Bearer ' + token,
          },
          body: JSON.stringify({
            data: {
              email: String(opts.email || user.email || '').trim(),
              locale: String(opts.locale || 'en').trim().slice(0, 8),
            },
          }),
        }).then(function (res) {
          return res.json().then(function (body) {
            if (!res.ok) {
              var msg =
                (body && body.error && body.error.message) ||
                'HTTP ' + res.status;
              var err = new Error(msg);
              err.code = body && body.error && body.error.status;
              throw err;
            }
            return (body && (body.result || body)) || {};
          });
        });
      });
    });
  }

  /**
   * After Stripe Safeguard payment: verify checkout session and mint Pro 1-year key.
   * @param {{ sessionId?: string, locale?: string }} opts
   */
  function claimSafeguardPurchase(opts) {
    opts = opts || {};
    return ensureFirebase().then(function (fb) {
      var user = fb.auth.currentUser;
      if (!user) return Promise.reject(new Error('unauthenticated'));
      return user.getIdToken().then(function (token) {
        var url =
          'https://' +
          REGION +
          '-' +
          FIREBASE_CONFIG.projectId +
          '.cloudfunctions.net/claimSafeguardPurchase';
        var data = {
          locale: String(opts.locale || 'en').trim().slice(0, 8),
        };
        var sid = String(opts.sessionId || opts.session_id || '').trim();
        if (sid) data.sessionId = sid;
        return fetch(url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: 'Bearer ' + token,
          },
          body: JSON.stringify({ data: data }),
        }).then(function (res) {
          return res.json().then(function (body) {
            if (!res.ok) {
              var msg =
                (body && body.error && body.error.message) ||
                'HTTP ' + res.status;
              var err = new Error(msg);
              err.code = body && body.error && body.error.status;
              throw err;
            }
            return (body && (body.result || body)) || {};
          });
        });
      });
    });
  }

  /**
   * Activer is available only when this uid has not claimed a trial and has no
   * non-revoked Safeguard license yet. Email is never used as the uniqueness key.
   */
  function canActivateSafeguard(snap) {
    if (!snap) return false;
    if (snap.safeguardTrialClaimed === true) return false;
    var badge = String(snap.safeguardBadge || 'inactive').toLowerCase();
    if (badge === 'active') badge = 'inactive';
    if (badge === 'lite' || badge === 'pro') return false;
    var lic = snap.safeguardLicense;
    if (lic && lic.revoked !== true) return false;
    return true;
  }

  global.paychekAccountEntitlement = {
    ensureFirebase: ensureFirebase,
    loadAccountSnapshot: loadAccountSnapshot,
    loadSafeguardStatus: loadSafeguardStatus,
    resolveSafeguardBadge: resolveSafeguardBadge,
    isSafeguardExpired: isSafeguardExpired,
    loadBillingConfig: loadBillingConfig,
    buildCheckoutUri: buildCheckoutUri,
    openBillingPortal: openBillingPortal,
    requestSafeguardLicenseCode: requestSafeguardLicenseCode,
    claimSafeguardPurchase: claimSafeguardPurchase,
    canActivateSafeguard: canActivateSafeguard,
    normalizeBillingChannel: normalizeBillingChannel,
    resolveBillingChannel: resolveBillingChannel,
  };
})(window);
