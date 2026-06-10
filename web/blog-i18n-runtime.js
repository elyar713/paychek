'use strict';

function blogNormalizeLocale(raw) {
  if (!raw || typeof raw !== 'string') return 'en';
  var c = raw.trim().toLowerCase();
  if (c.startsWith('en')) return 'en';
  if (c.startsWith('de')) return 'de';
  if (c.startsWith('es')) return 'es';
  if (c.startsWith('pt')) return 'pt';
  if (c.startsWith('ko')) return 'ko';
  if (c.startsWith('fr')) return 'fr';
  return 'en';
}

function blogHtmlLang(code) {
  var m = { fr: 'fr', en: 'en', de: 'de', es: 'es', pt: 'pt', ko: 'ko' };
  return m[blogNormalizeLocale(code)] || 'en';
}

function blogDetectLocale() {
  try {
    var s = typeof sessionStorage !== 'undefined' ? sessionStorage.getItem('paychek_landing_lang') : null;
    if (s) return blogNormalizeLocale(s);
  } catch (_e) {}
  return blogNormalizeLocale(typeof navigator !== 'undefined' && navigator.language ? navigator.language : 'en');
}

function blogGetAtPath(obj, path) {
  if (!obj || !path) return null;
  return path.split('.').reduce(function (acc, key) {
    return acc && acc[key] != null ? acc[key] : null;
  }, obj);
}

function blogBindStrings(s) {
  if (!s) return;
  document.querySelectorAll('[data-i18n]').forEach(function (el) {
    var p = el.getAttribute('data-i18n');
    if (!p) return;
    var v = blogGetAtPath(s, p);
    if (typeof v === 'string') el.textContent = v;
  });
  document.querySelectorAll('[data-i18n-html]').forEach(function (el) {
    var p = el.getAttribute('data-i18n-html');
    if (!p) return;
    var v = blogGetAtPath(s, p);
    if (typeof v === 'string') el.innerHTML = v;
  });
  document.querySelectorAll('[data-i18n-aria]').forEach(function (el) {
    var p = el.getAttribute('data-i18n-aria');
    if (!p) return;
    var v = blogGetAtPath(s, p);
    if (typeof v === 'string') el.setAttribute('aria-label', v);
  });
}

function blogUpdateMeta(s) {
  if (!s || !s.meta) return;
  if (s.meta.title) document.title = s.meta.title;
  var desc = document.querySelector('meta[name="description"]');
  if (desc && s.meta.description) desc.setAttribute('content', s.meta.description);
  var kw = document.querySelector('meta[name="keywords"]');
  if (kw && s.meta.keywords) kw.setAttribute('content', s.meta.keywords);
  var ogTitle = document.querySelector('meta[property="og:title"]');
  if (ogTitle && s.meta.title) ogTitle.setAttribute('content', s.meta.title);
  var ogDesc = document.querySelector('meta[property="og:description"]');
  if (ogDesc && s.meta.ogDescription) ogDesc.setAttribute('content', s.meta.ogDescription);
  var ogLocale = document.querySelector('meta[property="og:locale"]');
  if (ogLocale && s.meta.ogLocale) ogLocale.setAttribute('content', s.meta.ogLocale);
  var twTitle = document.querySelector('meta[name="twitter:title"]');
  if (twTitle && s.meta.title) twTitle.setAttribute('content', s.meta.title);
  var twDesc = document.querySelector('meta[name="twitter:description"]');
  if (twDesc && s.meta.ogDescription) twDesc.setAttribute('content', s.meta.ogDescription);
}

window.applyBlogTranslations = function applyBlogTranslations(code) {
  var lc = blogNormalizeLocale(code);
  var s = (window.PAYCHEK_BLOG_I18N || {})[lc];
  if (!s) return lc;
  document.documentElement.setAttribute('lang', blogHtmlLang(lc));
  blogUpdateMeta(s);
  blogBindStrings(s);
  return lc;
};

function blogInitI18n() {
  applyBlogTranslations(blogDetectLocale());
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', blogInitI18n);
} else {
  blogInitI18n();
}
