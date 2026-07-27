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
  var _authUser = null;
  var _billing = null;
  var _activateOpen = false;
  var _activateSending = false;

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
    return (window.PAYCHEK_LICENCE_I18N || {})[_locale] || (window.PAYCHEK_LICENCE_I18N || {}).en;
  }

  function normalize(code) {
    var c = String(code || 'en').toLowerCase().slice(0, 2);
    if ((window.PAYCHEK_LICENCE_I18N || {})[c]) return c;
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
    Array.prototype.slice.call(document.querySelectorAll('[data-i18n-placeholder]')).forEach(function (el) {
      var v = getAtPath(s, el.getAttribute('data-i18n-placeholder'));
      if (typeof v === 'string') el.setAttribute('placeholder', v);
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

  window.licenceSelectLang = function (code, ev) {
    if (ev) ev.preventDefault();
    applyI18n(code);
  };

  window.licenceToggleLang = function (ev) {
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
    if (channel === 'stripe') return s.journal.methodStripe;
    if (channel === 'apple_iap') return s.journal.methodApple;
    if (channel === 'google_play') return s.journal.methodGoogle;
    if (channel === 'admin') return s.journal.methodAdmin;
    return s.journal.methodUnknown;
  }

  function formatDate(d) {
    if (!d) return null;
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
    var btn = document.getElementById('licence-invoice-btn');
    var s = strings();
    if (!btn || !s || !s.journal) return;
    var opts = invoiceOpts(snap || _snap);
    var inv = window.paychekInvoice;
    var paid =
      inv && typeof inv.canDownloadDocument === 'function'
        ? inv.canDownloadDocument(opts)
        : inv && typeof inv.isInvoiceStyle === 'function'
          ? inv.isInvoiceStyle(opts)
          : !!(opts && (opts.isPro || opts.paymentMethod));
    btn.textContent = paid
      ? s.journal.downloadInvoice
      : s.journal.downloadReceipt;
    btn.disabled = !paid;
    btn.setAttribute('aria-disabled', paid ? 'false' : 'true');
    if (paid) {
      btn.removeAttribute('title');
    } else {
      btn.setAttribute(
        'title',
        s.journal.noInvoiceAvailable || 'No invoice available',
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

  function setActivateStatus(kind, message) {
    var el = document.getElementById('licence-sg-activate-status');
    if (!el) return;
    el.classList.remove('is-visible', 'is-success', 'is-error');
    if (!message) {
      el.textContent = '';
      return;
    }
    el.textContent = message;
    el.classList.add('is-visible');
    if (kind === 'success') el.classList.add('is-success');
    else if (kind === 'error') el.classList.add('is-error');
  }

  function prefillActivateEmail() {
    var input = document.getElementById('licence-sg-email');
    if (!input) return;
    if (input.value && String(input.value).trim()) return;
    var em =
      (_authUser && _authUser.email) ||
      (_snap && _snap.email) ||
      '';
    if (em) input.value = em;
  }

  function parseExpiryDate(raw) {
    if (!raw) return null;
    if (raw instanceof Date && !isNaN(raw.getTime())) return raw;
    if (typeof raw.toDate === 'function') {
      try {
        var d = raw.toDate();
        return d instanceof Date && !isNaN(d.getTime()) ? d : null;
      } catch (_e) {
        return null;
      }
    }
    if (typeof raw === 'string' || typeof raw === 'number') {
      var parsed = new Date(raw);
      return isNaN(parsed.getTime()) ? null : parsed;
    }
    return null;
  }

  function showLicenseCodePanel(key, expiresRaw) {
    var panel = document.getElementById('licence-sg-code-panel');
    var valueEl = document.getElementById('licence-sg-code-value');
    var expiryEl = document.getElementById('licence-sg-code-expiry');
    var s = strings();
    var code = String(key || '').trim();
    if (!panel || !valueEl) return;
    if (!code) {
      panel.setAttribute('hidden', '');
      valueEl.textContent = '';
      if (expiryEl) expiryEl.textContent = '';
      return;
    }
    valueEl.textContent = code;
    panel.removeAttribute('hidden');
    if (expiryEl) {
      var exp = parseExpiryDate(expiresRaw);
      var formatted = formatDate(exp);
      if (formatted && s.safeguard && s.safeguard.expiresLabel) {
        expiryEl.innerHTML =
          s.safeguard.expiresLabel + ' <strong>' + formatted + '</strong>';
      } else if (formatted) {
        expiryEl.textContent = formatted;
      } else if (s.safeguard && s.safeguard.noExpiry) {
        expiryEl.textContent = s.safeguard.noExpiry;
      } else {
        expiryEl.textContent = '';
      }
    }
  }

  function hideLicenseCodePanel() {
    showLicenseCodePanel('', null);
  }

  function copyLicenseCode() {
    var valueEl = document.getElementById('licence-sg-code-value');
    var s = strings();
    var code = valueEl ? String(valueEl.textContent || '').trim() : '';
    if (!code) return;
    var done = function () {
      setActivateStatus(
        'success',
        (s.safeguard && s.safeguard.copied) || 'Copied.',
      );
    };
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(code).then(done).catch(function () {
        fallbackCopy(code, done);
      });
    } else {
      fallbackCopy(code, done);
    }
  }

  function fallbackCopy(text, done) {
    try {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.setAttribute('readonly', '');
      ta.style.position = 'fixed';
      ta.style.left = '-9999px';
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
      if (done) done();
    } catch (_e) {}
  }

  function updateCodePanelFromSnap(snap) {
    var lic = snap && snap.safeguardLicense;
    if (!lic || lic.revoked === true) {
      hideLicenseCodePanel();
      return;
    }
    var key = String(lic.key || lic.id || '').trim();
    var exp =
      (snap && snap.safeguardExpiresAt) ||
      (lic && (lic.expiresAt || lic.trialExpiresAt)) ||
      null;
    showLicenseCodePanel(key, exp);
  }

  function setActivateFormOpen(open) {
    var api = window.paychekAccountEntitlement;
    var can =
      api && typeof api.canActivateSafeguard === 'function'
        ? api.canActivateSafeguard(_snap)
        : true;
    if (open && !can) {
      open = false;
    }
    _activateOpen = !!open;
    var form = document.getElementById('licence-sg-activate-form');
    var btn = document.getElementById('licence-sg-activate-btn');
    if (form) {
      if (_activateOpen) form.removeAttribute('hidden');
      else form.setAttribute('hidden', '');
    }
    if (btn) btn.setAttribute('aria-expanded', _activateOpen ? 'true' : 'false');
    if (_activateOpen) {
      prefillActivateEmail();
      setActivateStatus(null, '');
      var input = document.getElementById('licence-sg-email');
      if (input) {
        try {
          input.focus();
        } catch (_e) {}
      }
    }
  }

  function updateActivateVisibility(snap) {
    var btn = document.getElementById('licence-sg-activate-btn');
    var form = document.getElementById('licence-sg-activate-form');
    var input = document.getElementById('licence-sg-email');
    var sendBtn = document.getElementById('licence-sg-send-btn');
    var s = strings();
    var api = window.paychekAccountEntitlement;
    var can =
      api && typeof api.canActivateSafeguard === 'function'
        ? api.canActivateSafeguard(snap)
        : true;
    if (btn) {
      // Always visible once account content is shown; grayed out after claim.
      btn.removeAttribute('hidden');
      btn.disabled = !can;
      btn.setAttribute('aria-disabled', can ? 'false' : 'true');
      if (can) {
        btn.textContent =
          (s.safeguard && s.safeguard.activate) || 'Activate';
        btn.removeAttribute('title');
      } else {
        btn.textContent =
          (s.safeguard && s.safeguard.activateDone) ||
          (s.safeguard && s.safeguard.activate) ||
          'Activated';
        btn.setAttribute(
          'title',
          (s.safeguard && s.safeguard.activateDoneHint) ||
            'Trial already claimed for this account',
        );
      }
    }
    if (!can) {
      _activateOpen = false;
      if (form) form.setAttribute('hidden', '');
      if (input) {
        input.disabled = true;
        input.setAttribute('aria-disabled', 'true');
      }
      if (sendBtn) {
        sendBtn.disabled = true;
        sendBtn.setAttribute('aria-disabled', 'true');
      }
    } else {
      if (input) {
        input.disabled = false;
        input.removeAttribute('aria-disabled');
      }
      if (sendBtn && !_activateSending) {
        sendBtn.disabled = false;
        sendBtn.removeAttribute('aria-disabled');
      }
      if (_activateOpen && form) {
        form.removeAttribute('hidden');
        prefillActivateEmail();
      }
    }
    updateCodePanelFromSnap(snap);
  }

  function submitActivateForm(ev) {
    if (ev) ev.preventDefault();
    if (_activateSending) return;
    var api = window.paychekAccountEntitlement;
    if (
      api &&
      typeof api.canActivateSafeguard === 'function' &&
      !api.canActivateSafeguard(_snap)
    ) {
      return;
    }
    var s = strings();
    var input = document.getElementById('licence-sg-email');
    var sendBtn = document.getElementById('licence-sg-send-btn');
    var email = input ? String(input.value || '').trim() : '';
    if (!email || email.indexOf('@') < 0) {
      setActivateStatus('error', (s.safeguard && s.safeguard.emailInvalid) || 'Invalid email');
      return;
    }
    if (!api || typeof api.requestSafeguardLicenseCode !== 'function') {
      setActivateStatus('error', (s.safeguard && s.safeguard.sendError) || 'Request failed');
      return;
    }
    _activateSending = true;
    if (sendBtn) {
      sendBtn.disabled = true;
      sendBtn.textContent = (s.safeguard && s.safeguard.sending) || 'Sending…';
    }
    setActivateStatus(null, '');
    api
      .requestSafeguardLicenseCode({ email: email, locale: _locale })
      .then(function (result) {
        var key = result && result.licenseKey ? String(result.licenseKey).trim() : '';
        var exp = result && result.expiresAt ? result.expiresAt : null;
        if (key) showLicenseCodePanel(key, exp);
        var msg;
        if (s.safeguard && s.safeguard.sendSuccessTrial) {
          msg = s.safeguard.sendSuccessTrial;
          if (result && result.deliveryEmail && s.safeguard.sendSuccessTrialTo) {
            msg = s.safeguard.sendSuccessTrialTo.replace(
              '{email}',
              result.deliveryEmail,
            );
          }
        } else {
          msg = (s.safeguard && s.safeguard.sendSuccessSent) || 'Code ready.';
        }
        setActivateStatus('success', msg);
        setActivateFormOpen(false);
        if (_snap) {
          _snap.safeguardTrialClaimed = true;
          // Web Activer = account activated → pastille Lite (no desktop install needed).
          _snap.safeguardBadge = 'lite';
          if (key) {
            _snap.safeguardLicense = Object.assign({}, _snap.safeguardLicense || {}, {
              key: key,
              id: key,
              plan: 'trial',
              revoked: false,
              expiresAt: exp,
              maxActivations: 1,
              activations: [],
            });
            _snap.safeguardExpiresAt = parseExpiryDate(exp);
          }
        }
        renderSnap(_snap);
        // Soft refresh so badge/claim match Firestore after mint.
        if (_authUser && typeof api.loadAccountSnapshot === 'function') {
          api
            .loadAccountSnapshot(_authUser.uid)
            .then(function (fresh) {
              if (!_authUser || !fresh) return;
              _snap = fresh;
              renderSnap(fresh);
              setActivateStatus('success', msg);
            })
            .catch(function () {});
        }
      })
      .catch(function (err) {
        console.warn('[paychek] safeguard activate failed', err);
        var msg =
          (err && err.message) ||
          (s.safeguard && s.safeguard.sendError) ||
          'Request failed';
        setActivateStatus('error', msg);
      })
      .then(function () {
        _activateSending = false;
        if (sendBtn) {
          sendBtn.disabled = false;
          sendBtn.textContent =
            (s.safeguard && s.safeguard.sendCode) || 'Start free trial';
        }
      });
  }

  function renderSnap(snap) {
    var s = strings();
    var badge = document.getElementById('licence-plan-badge');
    var status = document.getElementById('licence-plan-status');
    var expiry = document.getElementById('licence-plan-expiry');
    var method = document.getElementById('licence-plan-method');
    var upgrade = document.getElementById('licence-upgrade-link');
    var sgBadge = document.getElementById('licence-safeguard-badge');

    if (badge) {
      badge.textContent = snap.isPro
        ? s.journal.pro
        : snap.proExpired
          ? s.journal.expired || s.journal.lite
          : s.journal.lite;
      badge.classList.toggle('acct-badge--pro', !!snap.isPro);
      badge.classList.toggle(
        'acct-badge--lite',
        !snap.isPro && !snap.proExpired,
      );
      badge.classList.toggle('acct-badge--expired', !!snap.proExpired);
    }
    if (status) {
      status.textContent = snap.isPro
        ? s.journal.pro
        : snap.proExpired
          ? s.journal.expired || 'Expired'
          : s.journal.lite;
    }
    var dateLabel = document.getElementById('licence-plan-date-label');
    if (expiry) {
      if (dateLabel) {
        dateLabel.setAttribute('data-i18n', 'journal.expirationDate');
        dateLabel.textContent =
          (s.journal && s.journal.expirationDate) || 'Expiration date';
      }
      // Active / former Pro / any paid signal: never "Sans expiration".
      // Never-paid Lite only: "No expiration".
      var everPro = !!(
        snap.isPro ||
        snap.proExpired ||
        snap.everPro ||
        snap.hasExpiration ||
        snap.paymentMethod
      );
      if (snap.periodEnd && (everPro || snap.isPro || snap.proExpired)) {
        expiry.textContent = formatDate(snap.periodEnd) || '—';
      } else if (everPro) {
        // Had / has Pro but end date missing from Firestore.
        expiry.textContent = '—';
      } else {
        expiry.textContent =
          (s.journal && s.journal.noExpiration) || 'No expiration';
      }
    }
    if (method) method.textContent = methodLabel(s, snap.paymentMethod);
    if (upgrade) {
      if (snap.isPro) upgrade.setAttribute('hidden', '');
      else upgrade.removeAttribute('hidden');
    }
    if (sgBadge && s.safeguard) {
      var sg = String(snap.safeguardBadge || 'inactive').toLowerCase();
      if (sg === 'active') sg = 'inactive';
      // Safeguard: Inactive (red) / Lite (green trial) / Pro (gold paid).
      if (sg !== 'inactive' && sg !== 'lite' && sg !== 'pro') sg = 'inactive';
      var sgLabel =
        sg === 'pro'
          ? s.safeguard.pro || 'Pro'
          : sg === 'lite'
            ? s.safeguard.lite
            : s.safeguard.inactive;
      sgBadge.textContent = sgLabel || sg;
      sgBadge.classList.toggle('acct-badge--inactive', sg === 'inactive');
      sgBadge.classList.toggle('acct-badge--pro', sg === 'pro');
      sgBadge.classList.toggle('acct-badge--lite', sg === 'lite');
      sgBadge.classList.toggle('acct-badge--sg-lite', sg === 'lite');
    }
    updateInvoiceButtonLabel(snap);
    updateActivateVisibility(snap);
    updateSafeguardBuyLink(snap);
  }

  function updateSafeguardBuyLink(snap) {
    var buy = document.getElementById('licence-sg-buy-link');
    if (!buy) return;
    var api = window.paychekAccountEntitlement;
    var base =
      _billing && _billing.safeguardPaymentUrl
        ? String(_billing.safeguardPaymentUrl).trim()
        : '';
    var url = null;
    if (base && api && typeof api.buildCheckoutUri === 'function' && _authUser) {
      url = api.buildCheckoutUri(
        base,
        (_authUser.email || (snap && snap.email) || ''),
        _authUser.uid,
      );
    } else if (base && /^https:\/\//i.test(base)) {
      url = base;
    }
    if (!url) {
      buy.setAttribute('hidden', '');
      buy.removeAttribute('href');
      return;
    }
    buy.href = url;
    buy.removeAttribute('hidden');
  }

  function readSafeguardPaidQuery() {
    try {
      var u = new URL(window.location.href);
      var sid = String(
        u.searchParams.get('session_id') ||
          u.searchParams.get('checkout_session_id') ||
          '',
      ).trim();
      var paidFlag = String(u.searchParams.get('safeguard') || '')
        .trim()
        .toLowerCase();
      var paid = paidFlag === 'paid' || paidFlag === '1' || !!sid;
      return { paid: paid, sessionId: sid };
    } catch (_e) {
      return { paid: false, sessionId: '' };
    }
  }

  function clearSafeguardPaidQuery() {
    try {
      var u = new URL(window.location.href);
      if (
        !u.searchParams.has('safeguard') &&
        !u.searchParams.has('session_id') &&
        !u.searchParams.has('checkout_session_id')
      ) {
        return;
      }
      u.searchParams.delete('safeguard');
      u.searchParams.delete('session_id');
      u.searchParams.delete('checkout_session_id');
      var next = u.pathname + (u.search || '') + (u.hash || '');
      window.history.replaceState({}, '', next);
    } catch (_e) {}
  }

  /**
   * After Stripe redirect (?safeguard=paid&session_id=cs_…) or manual re-claim,
   * mint/link the 1-year Pro key then refresh the snapshot.
   */
  function maybeClaimSafeguardPurchase(api) {
    var q = readSafeguardPaidQuery();
    if (!q.paid) return Promise.resolve(null);
    if (!api || typeof api.claimSafeguardPurchase !== 'function') {
      return Promise.resolve(null);
    }
    var s = strings();
    setActivateStatus(
      'success',
      (s.safeguard && s.safeguard.claimingPaid) ||
        'Confirming your Safeguard purchase…',
    );
    return api
      .claimSafeguardPurchase({
        sessionId: q.sessionId || undefined,
        locale: _locale,
      })
      .then(function (result) {
        clearSafeguardPaidQuery();
        var msg =
          (s.safeguard && s.safeguard.claimPaidSuccess) ||
          'Your Safeguard Pro key is ready.';
        if (result && result.deliveryEmail && s.safeguard && s.safeguard.claimPaidSuccessTo) {
          msg = s.safeguard.claimPaidSuccessTo.replace(
            '{email}',
            result.deliveryEmail,
          );
        }
        setActivateStatus('success', msg);
        if (result && result.licenseKey) {
          showLicenseCodePanel(result.licenseKey, result.expiresAt);
        }
        return result;
      })
      .catch(function (err) {
        console.warn('[paychek] claimSafeguardPurchase failed', err);
        clearSafeguardPaidQuery();
        setActivateStatus(
          'error',
          (err && err.message) ||
            (s.safeguard && s.safeguard.claimPaidError) ||
            'Could not confirm the Safeguard purchase.',
        );
        return null;
      });
  }

  function wireGateButtons() {
    document.querySelectorAll('[data-paychek-auth-open]').forEach(function (btn) {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        var mode = btn.getAttribute('data-paychek-auth-open') || 'login';
        if (typeof window.paychekOpenSiteAuth === 'function') {
          window.paychekOpenSiteAuth(mode);
        }
      });
    });
    var invoiceBtn = document.getElementById('licence-invoice-btn');
    if (invoiceBtn) {
      invoiceBtn.addEventListener('click', function (e) {
        e.preventDefault();
        openInvoice();
      });
    }
    var activateBtn = document.getElementById('licence-sg-activate-btn');
    if (activateBtn) {
      activateBtn.setAttribute('aria-controls', 'licence-sg-activate-form');
      activateBtn.setAttribute('aria-expanded', 'false');
      activateBtn.addEventListener('click', function (e) {
        e.preventDefault();
        if (activateBtn.disabled) return;
        setActivateFormOpen(!_activateOpen);
      });
    }
    var activateForm = document.getElementById('licence-sg-activate-form');
    if (activateForm) {
      activateForm.addEventListener('submit', submitActivateForm);
    }
    var copyBtn = document.getElementById('licence-sg-code-copy');
    if (copyBtn) {
      copyBtn.addEventListener('click', function (e) {
        e.preventDefault();
        copyLicenseCode();
      });
    }
  }

  function showGuest() {
    setVisible('licence-loading', false);
    setVisible('licence-error', false);
    setVisible('licence-content', false);
    setVisible('licence-gate', true);
  }

  function showLoading() {
    setVisible('licence-gate', false);
    setVisible('licence-error', false);
    setVisible('licence-content', false);
    setVisible('licence-loading', true);
  }

  function showError() {
    setVisible('licence-gate', false);
    setVisible('licence-loading', false);
    setVisible('licence-content', false);
    setVisible('licence-error', true);
  }

  function showContent(snap) {
    _snap = snap;
    renderSnap(snap);
    setVisible('licence-gate', false);
    setVisible('licence-loading', false);
    setVisible('licence-error', false);
    setVisible('licence-content', true);
  }

  function boot() {
    var stored = null;
    try {
      stored = localStorage.getItem('paychek_landing_lang');
    } catch (_e) {}
    var browser = (navigator.language || 'en').slice(0, 2).toLowerCase();
    applyI18n(stored || browser || 'en');
    wireGateButtons();

    var api = window.paychekAccountEntitlement;
    if (!api) {
      showError();
      return;
    }

    showLoading();
    api.ensureFirebase().then(function (fb) {
      fb.auth.onAuthStateChanged(function (user) {
          if (!user) {
            _snap = null;
            _authUser = null;
            _billing = null;
            showGuest();
            return;
          }
        _authUser = user;
        showLoading();
        Promise.all([
          api.loadAccountSnapshot(user.uid),
          api.loadBillingConfig
            ? api.loadBillingConfig().catch(function () {
                return null;
              })
            : Promise.resolve(null),
        ])
          .then(function (pair) {
            _billing = pair[1];
            showContent(pair[0]);
            return maybeClaimSafeguardPurchase(api).then(function (claimed) {
              if (!claimed || !claimed.ok) return null;
              return api.loadAccountSnapshot(user.uid).then(function (snap) {
                showContent(snap);
              });
            });
          })
          .catch(function (err) {
            console.warn('[paychek] licence load failed', err);
            showError();
          });
      });
    }).catch(function (err) {
      console.warn('[paychek] licence firebase failed', err);
      showError();
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
