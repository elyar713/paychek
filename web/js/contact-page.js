(function () {
  'use strict';

  var PROJECT_ID = 'paychek-trading';
  var REGION = 'europe-west1';
  var FUNCTION_NAME = 'submitPaychekWebContact';

  function activeLocale() {
    if (window._paychekContactActiveLocale) {
      return window._paychekContactActiveLocale;
    }
    if (typeof contactDetectInitialLocale === 'function') {
      return contactDetectInitialLocale();
    }
    return 'en';
  }

  function callSubmit(payload) {
    var url = 'https://' + REGION + '-' + PROJECT_ID + '.cloudfunctions.net/' + FUNCTION_NAME;
    return fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ data: payload }),
    }).then(function (res) {
      return res.json().then(function (body) {
        if (!res.ok) {
          var msg = (body && body.error && body.error.message) ? body.error.message : 'HTTP ' + res.status;
          throw new Error(msg);
        }
        return body && body.result ? body.result : body;
      });
    });
  }

  function showStatus(el, text, isError) {
    if (!el) return;
    el.textContent = text || '';
    if (text) {
      el.classList.remove('hidden');
      el.style.display = 'block';
      el.setAttribute('aria-hidden', 'false');
      try {
        el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      } catch (_e) {}
    } else {
      el.classList.add('hidden');
      el.style.display = 'none';
      el.setAttribute('aria-hidden', 'true');
    }
    el.classList.toggle('contact-form-status--error', !!isError);
    el.classList.toggle('contact-form-status--success', !isError && !!text);
  }

  function initForm() {
    var form = document.getElementById('contact-form');
    if (!form) return;

    var statusEl = document.getElementById('contact-form-status');
    var submitBtn = form.querySelector('button[type="submit"]');

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var strings = window._paychekContactStrings || {};
      var name = document.getElementById('cf-name').value.trim();
      var email = document.getElementById('cf-email').value.trim();
      var subjectSel = document.getElementById('cf-subject');
      var subject = subjectSel ? subjectSel.value : 'Contact';
      var message = document.getElementById('cf-message').value.trim();
      var locale = activeLocale();

      if (!email.includes('@') || message.length < 8) {
        showStatus(
          statusEl,
          (strings.form && strings.form.errorValidation) ||
            'Please fill in a valid email and message.',
          true,
        );
        return;
      }

      if (submitBtn) submitBtn.disabled = true;
      showStatus(
        statusEl,
        (strings.form && strings.form.sending) || 'Sending…',
        false,
      );

      callSubmit({
        name: name,
        email: email,
        subject: subject,
        message: message,
        locale: locale,
      })
        .then(function (result) {
          var ref = (result && result.ticketRef) ? result.ticketRef : '—';
          var tpl = (strings.form && strings.form.success) ||
            'Thank you! Reference: {ref}';
          showStatus(statusEl, tpl.replace('{ref}', ref), false);
          form.reset();
        })
        .catch(function (err) {
          showStatus(
            statusEl,
            (strings.form && strings.form.errorGeneric) ||
              (err && err.message ? err.message : 'Error'),
            true,
          );
        })
        .finally(function () {
          if (submitBtn) submitBtn.disabled = false;
        });
    });

    var affBtn = document.getElementById('affiliate-mail-btn');
    if (affBtn) {
      affBtn.addEventListener('click', function (e) {
        e.preventDefault();
        var subj = (window._paychekContactStrings &&
          window._paychekContactStrings.affiliate &&
          window._paychekContactStrings.affiliate.mailtoSubject) ||
          'Paychek affiliate program';
        window.location.href = 'mailto:contact@paychek.pro?subject=' + encodeURIComponent(subj);
      });
    }
  }

  function init() {
    var locale = typeof contactDetectInitialLocale === 'function'
      ? contactDetectInitialLocale()
      : 'en';
    if (typeof applyContactTranslations === 'function') {
      applyContactTranslations(locale);
    }
    initForm();
    if (window.location.hash === '#affiliation') {
      var block = document.getElementById('affiliation');
      if (block) block.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
