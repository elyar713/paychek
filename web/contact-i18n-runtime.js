'use strict';

function contactNormalizeLocale(raw) {
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

function contactHtmlLang(code) {
  var m = { fr: 'fr', en: 'en', de: 'de', es: 'es', pt: 'pt', ko: 'ko' };
  return m[contactNormalizeLocale(code)] || 'en';
}

function contactDetectLocale() {
  try {
    var s = typeof sessionStorage !== 'undefined' ? sessionStorage.getItem('paychek_landing_lang') : null;
    if (s) return contactNormalizeLocale(s);
  } catch (_e) {}
  return contactNormalizeLocale(typeof navigator !== 'undefined' && navigator.language ? navigator.language : 'en');
}

function contactGetAtPath(obj, path) {
  if (!obj || !path) return null;
  return path.split('.').reduce(function (acc, key) {
    return acc && acc[key] != null ? acc[key] : null;
  }, obj);
}

function contactBindStrings(s) {
  if (!s) return;
  document.querySelectorAll('[data-i18n]').forEach(function (el) {
    var p = el.getAttribute('data-i18n');
    if (!p) return;
    var v = contactGetAtPath(s, p);
    if (typeof v === 'string') el.textContent = v;
  });
  document.querySelectorAll('[data-i18n-html]').forEach(function (el) {
    var p = el.getAttribute('data-i18n-html');
    if (!p) return;
    var v = contactGetAtPath(s, p);
    if (typeof v === 'string') el.innerHTML = v;
  });
  document.querySelectorAll('[data-i18n-placeholder]').forEach(function (el) {
    var p = el.getAttribute('data-i18n-placeholder');
    if (!p) return;
    var v = contactGetAtPath(s, p);
    if (typeof v === 'string') el.setAttribute('placeholder', v);
  });
}

function contactUpdateMeta(s) {
  if (!s || !s.meta) return;
  if (s.meta.title) document.title = s.meta.title;
  var desc = document.querySelector('meta[name="description"]');
  if (desc && s.meta.description) desc.setAttribute('content', s.meta.description);
}

function contactApplySubjectOptions(s) {
  if (!s || !s.form || !s.form.subjects) return;
  var sel = document.getElementById('cf-subject');
  if (!sel) return;
  var map = [
    ['support', 'Support'],
    ['bug', 'Bug'],
    ['suggestion', 'Suggestion'],
    ['affiliate', 'Affiliation'],
    ['other', 'Autre'],
  ];
  map.forEach(function (row) {
    var opt = sel.querySelector('option[data-subject-key="' + row[0] + '"]');
    if (opt && s.form.subjects[row[0]]) opt.textContent = s.form.subjects[row[0]];
  });
}

window.applyContactTranslations = function applyContactTranslations(code) {
  var lc = contactNormalizeLocale(code);
  var s = (window.PAYCHEK_CONTACT_I18N || {})[lc] || (window.PAYCHEK_CONTACT_I18N || {}).en;
  if (!s) return lc;
  document.documentElement.setAttribute('lang', contactHtmlLang(lc));
  contactUpdateMeta(s);
  contactBindStrings(s);
  contactApplySubjectOptions(s);
  window._paychekContactStrings = s;
  window._paychekContactActiveLocale = lc;
  return lc;
};

window.contactDetectInitialLocale = contactDetectLocale;
