/**
 * Tarifs paywall web (Stripe) par pays / devise.
 * Mobile iOS/Android : prix lus directement depuis App Store / Play dans l’app.
 */

/** @type {Record<string, string>} ISO 3166-1 alpha-2 → ISO 4217 */
const COUNTRY_TO_CURRENCY = {
  AD: "EUR", AE: "AED", AF: "AFN", AG: "XCD", AI: "XCD", AL: "ALL", AM: "AMD",
  AO: "AOA", AR: "ARS", AS: "USD", AT: "EUR", AU: "AUD", AW: "AWG", AX: "EUR",
  AZ: "AZN", BA: "BAM", BB: "BBD", BD: "BDT", BE: "EUR", BF: "XOF", BG: "BGN",
  BH: "BHD", BI: "BIF", BJ: "XOF", BL: "EUR", BM: "BMD", BN: "BND", BO: "BOB",
  BQ: "USD", BR: "BRL", BS: "BSD", BT: "BTN", BV: "NOK", BW: "BWP", BY: "BYN",
  BZ: "BZD", CA: "CAD", CC: "AUD", CD: "CDF", CF: "XAF", CG: "XAF", CH: "CHF",
  CI: "XOF", CK: "NZD", CL: "CLP", CM: "XAF", CN: "CNY", CO: "COP", CR: "CRC",
  CU: "CUP", CV: "CVE", CW: "ANG", CX: "AUD", CY: "EUR", CZ: "CZK", DE: "EUR",
  DJ: "DJF", DK: "DKK", DM: "XCD", DO: "DOP", DZ: "DZD", EC: "USD", EE: "EUR",
  EG: "EGP", EH: "MAD", ER: "ERN", ES: "EUR", ET: "ETB", FI: "EUR", FJ: "FJD",
  FK: "FKP", FM: "USD", FO: "DKK", FR: "EUR", GA: "XAF", GB: "GBP", GD: "XCD",
  GE: "GEL", GF: "EUR", GG: "GBP", GH: "GHS", GI: "GIP", GL: "DKK", GM: "GMD",
  GN: "GNF", GP: "EUR", GQ: "XAF", GR: "EUR", GS: "GBP", GT: "GTQ", GU: "USD",
  GW: "XOF", GY: "GYD", HK: "HKD", HM: "AUD", HN: "HNL", HR: "EUR", HT: "HTG",
  HU: "HUF", ID: "IDR", IE: "EUR", IL: "ILS", IM: "GBP", IN: "INR", IO: "USD",
  IQ: "IQD", IR: "IRR", IS: "ISK", IT: "EUR", JE: "GBP", JM: "JMD", JO: "JOD",
  JP: "JPY", KE: "KES", KG: "KGS", KH: "KHR", KI: "AUD", KM: "KMF", KN: "XCD",
  KP: "KPW", KR: "KRW", KW: "KWD", KY: "KYD", KZ: "KZT", LA: "LAK", LB: "LBP",
  LC: "XCD", LI: "CHF", LK: "LKR", LR: "LRD", LS: "LSL", LT: "EUR", LU: "EUR",
  LV: "EUR", LY: "LYD", MA: "MAD", MC: "EUR", MD: "MDL", ME: "EUR", MF: "EUR",
  MG: "MGA", MH: "USD", MK: "MKD", ML: "XOF", MM: "MMK", MN: "MNT", MO: "MOP",
  MP: "USD", MQ: "EUR", MR: "MRU", MS: "XCD", MT: "EUR", MU: "MUR", MV: "MVR",
  MW: "MWK", MX: "MXN", MY: "MYR", MZ: "MZN", NA: "NAD", NC: "XPF", NE: "XOF",
  NF: "AUD", NG: "NGN", NI: "NIO", NL: "EUR", NO: "NOK", NP: "NPR", NR: "AUD",
  NU: "NZD", NZ: "NZD", OM: "OMR", PA: "PAB", PE: "PEN", PF: "XPF", PG: "PGK",
  PH: "PHP", PK: "PKR", PL: "PLN", PM: "EUR", PN: "NZD", PR: "USD", PS: "ILS",
  PT: "EUR", PW: "USD", PY: "PYG", QA: "QAR", RE: "EUR", RO: "RON", RS: "RSD",
  RU: "RUB", RW: "RWF", SA: "SAR", SB: "SBD", SC: "SCR", SD: "SDG", SE: "SEK",
  SG: "SGD", SH: "SHP", SI: "EUR", SJ: "NOK", SK: "EUR", SL: "SLE", SM: "EUR",
  SN: "XOF", SO: "SOS", SR: "SRD", SS: "SSP", ST: "STN", SV: "USD", SX: "ANG",
  SY: "SYP", SZ: "SZL", TC: "USD", TD: "XAF", TF: "EUR", TG: "XOF", TH: "THB",
  TJ: "TJS", TK: "NZD", TL: "USD", TM: "TMT", TN: "TND", TO: "TOP", TR: "TRY",
  TT: "TTD", TV: "AUD", TW: "TWD", TZ: "TZS", UA: "UAH", UG: "UGX", UM: "USD",
  US: "USD", UY: "UYU", UZ: "UZS", VA: "EUR", VC: "XCD", VE: "VES", VG: "USD",
  VI: "USD", VN: "VND", VU: "VUV", WF: "XPF", WS: "WST", XK: "EUR", YE: "YER",
  YT: "EUR", ZA: "ZAR", ZM: "ZMW", ZW: "USD",
};

/**
 * Montants TTC mensuel / trimestriel / annuel par devise (palier store indicatif).
 * Compléter via Firestore `paychek_app_config/billing.paywallPricesByCurrency`.
 * @type {Record<string, {monthly: number, quarterly: number, annual: number}>}
 */
const DEFAULT_PRICES_BY_CURRENCY = {
  USD: {monthly: 8.99, quarterly: 20.97, annual: 59.99},
  EUR: {monthly: 9.99, quarterly: 23.49, annual: 59.99},
  GBP: {monthly: 8.99, quarterly: 20.97, annual: 59.99},
  CAD: {monthly: 11.99, quarterly: 27.99, annual: 79.99},
  AUD: {monthly: 14.99, quarterly: 34.99, annual: 99.99},
  CHF: {monthly: 10.00, quarterly: 24.00, annual: 60.00},
  JPY: {monthly: 1300, quarterly: 3000, annual: 9000},
  BRL: {monthly: 49.90, quarterly: 119.90, annual: 349.90},
  MXN: {monthly: 179, quarterly: 419, annual: 1199},
  INR: {monthly: 899, quarterly: 2099, annual: 5900},
  PLN: {monthly: 39.99, quarterly: 94.99, annual: 269.99},
  SEK: {monthly: 99, quarterly: 229, annual: 649},
  NOK: {monthly: 99, quarterly: 229, annual: 649},
  DKK: {monthly: 69, quarterly: 159, annual: 449},
  CZK: {monthly: 229, quarterly: 529, annual: 1490},
  HUF: {monthly: 3990, quarterly: 9290, annual: 25990},
  RON: {monthly: 49.99, quarterly: 114.99, annual: 329.99},
  TRY: {monthly: 349.99, quarterly: 799.99, annual: 2299.99},
  ZAR: {monthly: 169.99, quarterly: 399.99, annual: 1099.99},
  KRW: {monthly: 11000, quarterly: 25000, annual: 75000},
  SGD: {monthly: 12.98, quarterly: 29.98, annual: 89.98},
  HKD: {monthly: 68, quarterly: 158, annual: 468},
  TWD: {monthly: 290, quarterly: 670, annual: 1990},
  NZD: {monthly: 14.99, quarterly: 34.99, annual: 99.99},
  ILS: {monthly: 34.90, quarterly: 79.90, annual: 229.90},
  AED: {monthly: 32.99, quarterly: 76.99, annual: 219.99},
  SAR: {monthly: 34.99, quarterly: 79.99, annual: 229.99},
  THB: {monthly: 349, quarterly: 799, annual: 2290},
  PHP: {monthly: 499, quarterly: 1190, annual: 3490},
  IDR: {monthly: 149000, quarterly: 349000, annual: 990000},
  MYR: {monthly: 39.90, quarterly: 94.90, annual: 279.90},
  CLP: {monthly: 8990, quarterly: 20990, annual: 59990},
  COP: {monthly: 39900, quarterly: 92900, annual: 269900},
  ARS: {monthly: 8999, quarterly: 20999, annual: 59999},
  NGN: {monthly: 12900, quarterly: 29900, annual: 84900},
  EGP: {monthly: 449.99, quarterly: 999.99, annual: 2999.99},
  UAH: {monthly: 399, quarterly: 929, annual: 2699},
  RUB: {monthly: 799, quarterly: 1890, annual: 5290},
  CNY: {monthly: 58, quarterly: 138, annual: 398},
};

/**
 * @param {string} countryCode
 * @return {string}
 */
function paychekCountryToCurrency(countryCode) {
  const cc = `${countryCode || ""}`.trim().toUpperCase();
  if (cc.length === 2 && COUNTRY_TO_CURRENCY[cc]) {
    return COUNTRY_TO_CURRENCY[cc];
  }
  return "USD";
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} currency
 * @return {Promise<{monthly: number, quarterly: number, annual: number, source: string}|null>}
 */
async function paychekLoadFirestorePaywallPrices(db, currency) {
  const cur = `${currency || ""}`.trim().toUpperCase();
  if (!cur) return null;
  const snap = await db.collection("paychek_app_config").doc("billing").get();
  if (!snap.exists) return null;
  const d = snap.data() || {};
  const byCur = d.paywallPricesByCurrency;
  if (!byCur || typeof byCur !== "object") return null;
  const row = byCur[cur] || byCur[cur.toLowerCase()];
  if (!row || typeof row !== "object") return null;
  const monthly = Number(row.monthly);
  const quarterly = Number(row.quarterly);
  const annual = Number(row.annual);
  if (!monthly || !quarterly || !annual) return null;
  return {monthly, quarterly, annual, source: "firestore"};
}

/**
 * @param {import("stripe").Stripe|null} stripe
 * @param {object} priceIds
 * @param {string} currency
 * @return {Promise<{monthly: number, quarterly: number, annual: number, source: string}|null>}
 */
async function paychekLoadStripePaywallPrices(stripe, priceIds, currency) {
  if (!stripe) return null;
  const cur = `${currency || ""}`.trim().toLowerCase();
  if (!cur) return null;

  /**
   * @param {string} priceId
   * @return {Promise<number|null>}
   */
  async function unitAmount(priceId) {
    const id = `${priceId || ""}`.trim();
    if (!id) return null;
    try {
      const price = await stripe.prices.retrieve(id);
      if (`${price.currency || ""}`.toLowerCase() === cur && price.unit_amount) {
        return price.unit_amount / 100;
      }
      const opts = price.currency_options;
      if (opts && opts[cur] && opts[cur].unit_amount) {
        return opts[cur].unit_amount / 100;
      }
    } catch (e) {
      console.warn("[Paychek] stripe price retrieve", id, e.message);
    }
    return null;
  }

  const monthly = await unitAmount(priceIds.monthly);
  const quarterly = await unitAmount(priceIds.quarterly);
  const annual = await unitAmount(priceIds.annual);
  if (monthly == null || quarterly == null || annual == null) return null;
  return {monthly, quarterly, annual, source: "stripe"};
}

/**
 * @param {object} deps
 * @return {object}
 */
function createPaywallPricingExports(deps) {
  const {onCall, HttpsError, admin, paychekStripeSecretKey, defineSecret} = deps;

  const getPaychekPaywallPrices = onCall(
      {
        region: "europe-west1",
        timeoutSeconds: 30,
        memory: "256MiB",
        secrets: paychekStripeSecretKey ? [paychekStripeSecretKey] : [],
      },
      async (request) => {
        try {
          const country =
            `${request.data?.countryCode ?? ""}`.trim().toUpperCase() || "US";
          const currency = paychekCountryToCurrency(country);
          const db = admin.firestore();

          let amounts = await paychekLoadFirestorePaywallPrices(db, currency);
          let source = amounts?.source || "default";

          if (!amounts && paychekStripeSecretKey) {
            const key = paychekStripeSecretKey.value().trim();
            if (key) {
              const Stripe = require("stripe");
              const stripe = new Stripe(key);
              const billingSnap =
                await db.collection("paychek_app_config").doc("billing").get();
              const bd = billingSnap.exists ? billingSnap.data() || {} : {};
              const fromStripe = await paychekLoadStripePaywallPrices(
                  stripe,
                  {
                    monthly: bd.stripePriceIdMonthly,
                    quarterly: bd.stripePriceIdQuarterly,
                    annual: bd.stripePriceIdAnnual,
                  },
                  currency,
              );
              if (fromStripe) {
                amounts = fromStripe;
                source = fromStripe.source;
              }
            }
          }

          if (!amounts) {
            const def =
              DEFAULT_PRICES_BY_CURRENCY[currency] ||
              DEFAULT_PRICES_BY_CURRENCY.USD;
            amounts = {...def, source: "default"};
            source = currency in DEFAULT_PRICES_BY_CURRENCY ?
              "default_currency" :
              "default_usd";
          }

          return {
            countryCode: country,
            currencyCode: currency,
            source,
            monthly: amounts.monthly,
            quarterly: amounts.quarterly,
            annual: amounts.annual,
          };
        } catch (e) {
          console.error("[Paychek] getPaychekPaywallPrices", e);
          throw new HttpsError(
              "internal",
              e && e.message ? String(e.message) : "paywall_prices_failed",
          );
        }
      },
  );

  return {getPaychekPaywallPrices};
}

module.exports = {
  createPaywallPricingExports,
  paychekCountryToCurrency,
  COUNTRY_TO_CURRENCY,
  DEFAULT_PRICES_BY_CURRENCY,
};
