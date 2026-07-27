'use strict';

(function () {
  var FLAG = {
    en: 'https://flagcdn.com/w40/us.png',
    fr: 'https://flagcdn.com/w40/fr.png',
    de: 'https://flagcdn.com/w40/de.png',
    es: 'https://flagcdn.com/w40/es.png',
    pt: 'https://flagcdn.com/w40/pt.png',
    ko: 'https://flagcdn.com/w40/kr.png'
  };
  var CODE = { en: 'EN', fr: 'FR', de: 'DE', es: 'ES', pt: 'PT', ko: 'KO' };
  var LANG_ATTR = { en: 'en', fr: 'fr', de: 'de', es: 'es', pt: 'pt', ko: 'ko' };
  // Cache-bust query: bump when zip contents change (Uninstall scripts, etc.).
  var DOWNLOAD_URL = 'https://paychek.pro/downloads/PaychekSafeguard-Windows.zip?v=20260727-rebuild';
  var LICENCE_SG = 'licence.html#safeguard';
  var LOCALE_KEY = 'paychek_landing_lang';

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

  function normalize(code) {
    var c = String(code || 'en').toLowerCase().slice(0, 2);
    if ((window.PAYCHEK_SAFEGUARD_I18N || {})[c]) return c;
    return 'en';
  }

  function readStoredLocale() {
    try {
      if (typeof sessionStorage !== 'undefined') {
        var s = sessionStorage.getItem(LOCALE_KEY);
        if (s) return s;
      }
    } catch (e0) {}
    try {
      if (typeof localStorage !== 'undefined') {
        return localStorage.getItem(LOCALE_KEY);
      }
    } catch (e1) {}
    return null;
  }

  function writeStoredLocale(lc) {
    try {
      if (typeof sessionStorage !== 'undefined') sessionStorage.setItem(LOCALE_KEY, lc);
    } catch (e0) {}
    try {
      if (typeof localStorage !== 'undefined') localStorage.setItem(LOCALE_KEY, lc);
    } catch (e1) {}
  }

  function closeLangMenu() {
    var wrap = document.getElementById('lang-picker-wrap');
    var menu = document.getElementById('lang-dropdown-menu');
    var btn = document.getElementById('lang-trigger-btn');
    if (wrap) wrap.classList.remove('is-open');
    if (menu) menu.classList.remove('is-open');
    if (btn) btn.setAttribute('aria-expanded', 'false');
  }

  function apply(code) {
    var lc = normalize(code);
    var s = (window.PAYCHEK_SAFEGUARD_I18N || {})[lc];
    if (!s) return lc;
    document.documentElement.setAttribute('lang', LANG_ATTR[lc] || lc);
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
    if (flag && FLAG[lc]) {
      flag.src = FLAG[lc];
      flag.alt = CODE[lc] || lc;
    }
    if (codeEl && CODE[lc]) codeEl.textContent = CODE[lc];

    Array.prototype.slice.call(document.querySelectorAll('[data-landing-lang]')).forEach(function (el) {
      var c = el.getAttribute('data-landing-lang');
      if (c === lc) {
        el.classList.remove('text-gray-400');
        el.classList.add('text-white');
      } else {
        el.classList.add('text-gray-400');
        el.classList.remove('text-white');
      }
    });

    writeStoredLocale(lc);
    if (typeof paychekRefreshAccountNavLabels === 'function') {
      paychekRefreshAccountNavLabels();
    }
    return lc;
  }

  window.sgSelectLang = function (code, ev) {
    if (ev) {
      ev.preventDefault();
      ev.stopPropagation();
    }
    apply(code);
    closeLangMenu();
  };

  window.sgToggleLang = function (ev) {
    if (ev) {
      ev.preventDefault();
      ev.stopPropagation();
    }
    var wrap = document.getElementById('lang-picker-wrap');
    var menu = document.getElementById('lang-dropdown-menu');
    var btn = document.getElementById('lang-trigger-btn');
    if (!wrap || !menu) return;
    var open = !wrap.classList.contains('is-open');
    if (open) {
      wrap.classList.add('is-open');
      menu.classList.add('is-open');
      if (btn) btn.setAttribute('aria-expanded', 'true');
    } else {
      closeLangMenu();
    }
  };

  function wireBuyLink(url) {
    var buy = document.getElementById('sg-buy-link');
    if (!buy) return;
    if (url && /^https:\/\//i.test(url)) {
      buy.href = url;
      buy.removeAttribute('hidden');
      buy.setAttribute('target', '_blank');
      buy.setAttribute('rel', 'noopener noreferrer');
    } else {
      buy.href = LICENCE_SG;
      buy.setAttribute('target', '_top');
      buy.removeAttribute('rel');
    }
  }

  function loadSafeguardPaymentUrl() {
    var api = window.paychekAccountEntitlement;
    if (!api || typeof api.loadBillingConfig !== 'function') {
      wireBuyLink(null);
      return;
    }
    api
      .loadBillingConfig()
      .then(function (billing) {
        var base =
          billing && billing.safeguardPaymentUrl
            ? String(billing.safeguardPaymentUrl).trim()
            : '';
        if (!base) {
          wireBuyLink(null);
          return;
        }
        if (typeof api.ensureFirebase !== 'function') {
          wireBuyLink(base);
          return;
        }
        return api.ensureFirebase().then(function (fb) {
          var user = fb && fb.auth && fb.auth.currentUser;
          if (user && typeof api.buildCheckoutUri === 'function') {
            wireBuyLink(
              api.buildCheckoutUri(base, user.email || '', user.uid || '')
            );
          } else {
            wireBuyLink(base);
          }
        });
      })
      .catch(function () {
        wireBuyLink(null);
      });
  }

  function initLangPicker() {
    var wrap = document.getElementById('lang-picker-wrap');
    if (!wrap) return;
    document.addEventListener('pointerdown', function (ev) {
      if (wrap.contains(ev.target)) return;
      closeLangMenu();
    });
    document.addEventListener('keydown', function (ev) {
      if (ev.key === 'Escape') closeLangMenu();
    });
  }

  function boot() {
    var stored = readStoredLocale();
    var browser = (navigator.language || 'en').slice(0, 2).toLowerCase();
    apply(stored || browser || 'en');
    initLangPicker();

    Array.prototype.slice
      .call(document.querySelectorAll('a[href*="PaychekSafeguard-Windows.zip"]'))
      .forEach(function (a) {
        a.href = DOWNLOAD_URL;
      });

    wireBuyLink(null);
    loadSafeguardPaymentUrl();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
