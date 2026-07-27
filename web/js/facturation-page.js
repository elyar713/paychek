'use strict';

(function () {
  var FLAG = {
    en: 'https://flagcdn.com/w40/us.png',
    fr: 'https://flagcdn.com/w40/fr.png',
    de: 'https://flagcdn.com/w40/de.png',
    es: 'https://flagcdn.com/w40/es.png',
    pt: 'https://flagcdn.com/w40/pt.png',
    ko: 'https://flagcdn.com/w40/kr.png',
  };
  var CODE = { en: 'EN', fr: 'FR', de: 'DE', es: 'ES', pt: 'PT', ko: 'KO' };
  var _locale = 'en';
  var _snap = null;
  var _billing = null;
  var _selectedCycle = 'annual';
  var _authUser = null;

  function getAtPath(obj, path) {
    if (!obj || !path) return undefined;
    var parts = path.split('.');
    var cur = obj;
    for (var i = 0; i < parts.length; i++) {
      if (cur == null) return undefined;
      cur = cur[parts[i]];
    }
    return cur;
  }

  function strings() {
    return (
      (window.PAYCHEK_FACTURATION_I18N || {})[_locale] ||
      (window.PAYCHEK_FACTURATION_I18N || {}).en
    );
  }

  function normalize(code) {
    var c = String(code || 'en').toLowerCase().slice(0, 2);
    if ((window.PAYCHEK_FACTURATION_I18N || {})[c]) return c;
    return 'en';
  }

  function applyI18n(code) {
    _locale = normalize(code);
    var s = strings();
    if (!s) return _locale;
    document.documentElement.setAttribute('lang', _locale);
    if (s.meta && s.meta.title) document.title = s.meta.title;
    var desc = document.querySelector('meta[name="description"]');
    if (desc && s.meta && s.meta.description) desc.setAttribute('content', s.meta.description);

    Array.prototype.slice.call(document.querySelectorAll('[data-i18n]')).forEach(function (el) {
      var v = getAtPath(s, el.getAttribute('data-i18n'));
      if (typeof v === 'string') el.textContent = v;
    });
    Array.prototype.slice.call(document.querySelectorAll('[data-i18n-html]')).forEach(function (el) {
      var v = getAtPath(s, el.getAttribute('data-i18n-html'));
      if (typeof v === 'string') el.innerHTML = v;
    });

    var flag = document.getElementById('lang-trigger-flag');
    var codeEl = document.getElementById('lang-trigger-code');
    if (flag && FLAG[_locale]) flag.src = FLAG[_locale];
    if (codeEl && CODE[_locale]) codeEl.textContent = CODE[_locale];

    Array.prototype.slice.call(document.querySelectorAll('[data-landing-lang]')).forEach(function (el) {
      var c = el.getAttribute('data-landing-lang');
      if (c === _locale) {
        el.classList.remove('text-gray-400');
        el.classList.add('text-white');
      } else {
        el.classList.add('text-gray-400');
        el.classList.remove('text-white');
      }
    });

    try {
      localStorage.setItem('paychek_landing_lang', _locale);
    } catch (_e) {}
    if (typeof paychekRefreshAccountNavLabels === 'function') {
      paychekRefreshAccountNavLabels();
    }
    if (_snap) renderSnap(_snap);
    else updateInvoiceButtonLabel(null);
    return _locale;
  }

  window.facturationSelectLang = function (code, ev) {
    if (ev) ev.preventDefault();
    applyI18n(code);
  };

  window.facturationToggleLang = function (ev) {
    if (ev) ev.stopPropagation();
    var btn = document.getElementById('lang-trigger-btn');
    if (btn) {
      btn.setAttribute(
        'aria-expanded',
        btn.getAttribute('aria-expanded') === 'true' ? 'false' : 'true',
      );
    }
  };

  function methodLabel(s, method) {
    var api = window.paychekAccountEntitlement;
    var channel =
      api && typeof api.normalizeBillingChannel === 'function'
        ? api.normalizeBillingChannel(method)
        : String(method || '')
            .trim()
            .toLowerCase();
    if (channel === 'stripe') return s.status.methodStripe;
    if (channel === 'apple_iap') return s.status.methodApple;
    if (channel === 'google_play') return s.status.methodGoogle;
    if (channel === 'admin') return s.status.methodAdmin;
    return s.status.methodUnknown;
  }

  function billingChannel(method) {
    var api = window.paychekAccountEntitlement;
    if (api && typeof api.normalizeBillingChannel === 'function') {
      return api.normalizeBillingChannel(method);
    }
    return String(method || '')
      .trim()
      .toLowerCase();
  }

  function formatDate(d) {
    if (!d) return '—';
    try {
      return new Intl.DateTimeFormat(_locale, {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
      }).format(d);
    } catch (_e) {
      return d.toISOString().slice(0, 10);
    }
  }

  function setVisible(id, show) {
    var el = document.getElementById(id);
    if (!el) return;
    if (show) el.removeAttribute('hidden');
    else el.setAttribute('hidden', '');
  }

  function showMsg(text, kind) {
    var el = document.getElementById('billing-status-msg');
    if (!el) return;
    el.textContent = text || '';
    el.classList.remove('is-error', 'is-info');
    if (!text) {
      el.style.display = 'none';
      return;
    }
    el.classList.add(kind === 'error' ? 'is-error' : 'is-info');
  }

  function invoiceOpts(snap) {
    var user = _authUser;
    return {
      locale: _locale,
      isPro: !!(snap && snap.isPro),
      paymentMethod: snap && snap.paymentMethod,
      periodEnd: snap && snap.periodEnd,
      email:
        (user && user.email) ||
        (snap && snap.email) ||
        '',
      displayName: (user && user.displayName) || '',
      uid: (user && user.uid) || '',
    };
  }

  function updateInvoiceButtonLabel(snap) {
    var btn = document.getElementById('billing-invoice-btn');
    var s = strings();
    if (!btn || !s || !s.status) return;
    var opts = invoiceOpts(snap || _snap);
    var inv = window.paychekInvoice;
    var paid =
      inv && typeof inv.canDownloadDocument === 'function'
        ? inv.canDownloadDocument(opts)
        : inv && typeof inv.isInvoiceStyle === 'function'
          ? inv.isInvoiceStyle(opts)
          : !!(opts && (opts.isPro || opts.paymentMethod));
    btn.textContent = paid
      ? s.status.downloadInvoice
      : s.status.downloadReceipt;
    btn.disabled = !paid;
    btn.setAttribute('aria-disabled', paid ? 'false' : 'true');
    if (paid) {
      btn.removeAttribute('title');
    } else {
      btn.setAttribute(
        'title',
        s.status.noInvoiceAvailable || 'No invoice available',
      );
    }
  }

  function openInvoice() {
    var inv = window.paychekInvoice;
    if (!inv || typeof inv.openDocument !== 'function' || !_snap) return;
    var opts = invoiceOpts(_snap);
    var can =
      typeof inv.canDownloadDocument === 'function'
        ? inv.canDownloadDocument(opts)
        : typeof inv.isInvoiceStyle === 'function'
          ? inv.isInvoiceStyle(opts)
          : !!(opts.isPro || opts.paymentMethod);
    if (!can) return;
    inv.openDocument(opts);
  }

  function renderSnap(snap) {
    var s = strings();
    var badge = document.getElementById('billing-plan-badge');
    var expiry = document.getElementById('billing-plan-expiry');
    var method = document.getElementById('billing-plan-method');
    var portalBtn = document.getElementById('billing-portal-btn');
    var noStripe = document.getElementById('billing-no-stripe');
    var apple = document.getElementById('billing-apple-link');
    var google = document.getElementById('billing-google-link');
    var plans = document.getElementById('billing-plans-section');

    if (badge) {
      badge.textContent = snap.isPro ? s.status.pro : s.status.lite;
      badge.classList.toggle('acct-badge--pro', snap.isPro);
      badge.classList.toggle('acct-badge--lite', !snap.isPro);
    }
    if (expiry) expiry.textContent = formatDate(snap.periodEnd);
    if (method) method.textContent = methodLabel(s, snap.paymentMethod);

    var channel = billingChannel(snap.paymentMethod);
    var isApple = channel === 'apple_iap';
    var isGoogle = channel === 'google_play';
    var canPortal = snap.hasStripeCustomer || channel === 'stripe';

    if (portalBtn) {
      if (canPortal) portalBtn.removeAttribute('hidden');
      else portalBtn.setAttribute('hidden', '');
    }
    if (noStripe) {
      if (!canPortal) noStripe.removeAttribute('hidden');
      else noStripe.setAttribute('hidden', '');
    }
    if (apple) {
      if (isApple) apple.removeAttribute('hidden');
      else apple.setAttribute('hidden', '');
    }
    if (google) {
      if (isGoogle) google.removeAttribute('hidden');
      else google.setAttribute('hidden', '');
    }
    if (plans) {
      // Toujours proposer l’upgrade / renouvellement web (sauf purement store-managed sans Stripe).
      if (isApple || isGoogle) {
        // Store users keep store manage links; checkout section still useful if they want web later.
        plans.removeAttribute('hidden');
      } else {
        plans.removeAttribute('hidden');
      }
    }
    updateInvoiceButtonLabel(snap);
  }

  function selectCycle(cycle) {
    _selectedCycle = cycle || 'annual';
    document.querySelectorAll('.plan-pick').forEach(function (btn) {
      var on = btn.getAttribute('data-cycle') === _selectedCycle;
      btn.classList.toggle('is-selected', on);
      btn.setAttribute('aria-checked', on ? 'true' : 'false');
    });
  }

  function wireUi() {
    document.querySelectorAll('[data-paychek-auth-open]').forEach(function (btn) {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        var mode = btn.getAttribute('data-paychek-auth-open') || 'login';
        if (typeof window.paychekOpenSiteAuth === 'function') {
          window.paychekOpenSiteAuth(mode);
        }
      });
    });

    document.querySelectorAll('.plan-pick').forEach(function (btn) {
      btn.addEventListener('click', function () {
        selectCycle(btn.getAttribute('data-cycle'));
      });
    });

    var subBtn = document.getElementById('billing-subscribe-btn');
    if (subBtn) {
      subBtn.addEventListener('click', function () {
        startCheckout(subBtn);
      });
    }

    var portalBtn = document.getElementById('billing-portal-btn');
    if (portalBtn) {
      portalBtn.addEventListener('click', function () {
        openPortal(portalBtn);
      });
    }

    var invoiceBtn = document.getElementById('billing-invoice-btn');
    if (invoiceBtn) {
      invoiceBtn.addEventListener('click', function (e) {
        e.preventDefault();
        openInvoice();
      });
    }
  }

  function startCheckout(btn) {
    var s = strings();
    var api = window.paychekAccountEntitlement;
    if (!api || !_authUser) return;
    showMsg('', null);
    var prev = btn.textContent;
    btn.disabled = true;
    btn.textContent = s.plans.ctaBusy;

    var run = _billing
      ? Promise.resolve(_billing)
      : api.loadBillingConfig().then(function (cfg) {
          _billing = cfg;
          return cfg;
        });

    run
      .then(function (cfg) {
        if (!cfg || cfg.enabled === false) {
          throw new Error('checkout_disabled');
        }
        var base =
          _selectedCycle === 'monthly'
            ? cfg.monthly
            : _selectedCycle === 'quarterly'
              ? cfg.quarterly
              : cfg.annual;
        var url = api.buildCheckoutUri(
          base,
          _authUser.email || (_snap && _snap.email),
          _authUser.uid,
        );
        if (!url) throw new Error('checkout_missing');
        window.location.href = url;
      })
      .catch(function (err) {
        console.warn('[paychek] checkout', err);
        showMsg(s.manage.checkoutMissing, 'error');
      })
      .finally(function () {
        btn.disabled = false;
        btn.textContent = prev;
        applyI18n(_locale);
      });
  }

  function openPortal(btn) {
    var s = strings();
    var api = window.paychekAccountEntitlement;
    if (!api) return;
    showMsg('', null);
    var prev = btn.textContent;
    btn.disabled = true;
    btn.textContent = s.manage.ctaBusy;

    api
      .openBillingPortal(window.location.origin + '/facturation.html')
      .then(function (url) {
        window.location.href = url;
      })
      .catch(function (err) {
        console.warn('[paychek] portal', err);
        var msg = s.manage.errorGeneric;
        var text = (err && err.message) || '';
        if (
          text.indexOf('Aucun abonnement Stripe') >= 0 ||
          text.indexOf('Stripe') >= 0
        ) {
          msg = s.manage.errorNoCustomer;
        }
        showMsg(msg, 'error');
      })
      .finally(function () {
        btn.disabled = false;
        btn.textContent = prev;
        applyI18n(_locale);
      });
  }

  function showGuest() {
    setVisible('billing-loading', false);
    setVisible('billing-error', false);
    setVisible('billing-content', false);
    setVisible('billing-gate', true);
  }

  function showLoading() {
    setVisible('billing-gate', false);
    setVisible('billing-error', false);
    setVisible('billing-content', false);
    setVisible('billing-loading', true);
  }

  function showError() {
    setVisible('billing-gate', false);
    setVisible('billing-loading', false);
    setVisible('billing-content', false);
    setVisible('billing-error', true);
  }

  function showContent(snap) {
    _snap = snap;
    renderSnap(snap);
    setVisible('billing-gate', false);
    setVisible('billing-loading', false);
    setVisible('billing-error', false);
    setVisible('billing-content', true);
  }

  function boot() {
    var stored = null;
    try {
      stored = localStorage.getItem('paychek_landing_lang');
    } catch (_e) {}
    var browser = (navigator.language || 'en').slice(0, 2).toLowerCase();
    applyI18n(stored || browser || 'en');
    wireUi();
    selectCycle('annual');

    var api = window.paychekAccountEntitlement;
    if (!api) {
      showError();
      return;
    }

    showLoading();
    api
      .ensureFirebase()
      .then(function (fb) {
        fb.auth.onAuthStateChanged(function (user) {
          _authUser = user;
          if (!user) {
            _snap = null;
            showGuest();
            return;
          }
          showLoading();
          Promise.all([
            api.loadAccountSnapshot(user.uid),
            api.loadBillingConfig().catch(function () {
              return null;
            }),
          ])
            .then(function (pair) {
              _billing = pair[1];
              showContent(pair[0]);
            })
            .catch(function (err) {
              console.warn('[paychek] billing load failed', err);
              showError();
            });
        });
      })
      .catch(function (err) {
        console.warn('[paychek] billing firebase failed', err);
        showError();
      });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
