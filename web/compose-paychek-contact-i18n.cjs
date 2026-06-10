'use strict';

const fs = require('fs');
const path = require('path');

const dir = __dirname;
const LOCALE_KEYS = ['fr', 'en', 'de', 'es', 'pt', 'ko'];
const i18nDir = path.join(dir, 'contact-i18n');

const PAYCHEK_CONTACT_I18N = {};
for (const code of LOCALE_KEYS) {
  const p = path.join(i18nDir, code + '.json');
  if (!fs.existsSync(p)) {
    throw new Error('Missing contact translation: ' + p);
  }
  PAYCHEK_CONTACT_I18N[code] = JSON.parse(fs.readFileSync(p, 'utf8'));
}

const runtime = fs.readFileSync(path.join(dir, 'contact-i18n-runtime.js'), 'utf8');
const out = [
  '/* PAYCHEK contact i18n (compose-paychek-contact-i18n.cjs output) */',
  "'use strict';",
  '(function () {',
  '  window.PAYCHEK_CONTACT_I18N = ' + JSON.stringify(PAYCHEK_CONTACT_I18N) + ';',
  runtime,
  '})();',
  '',
].join('\n');

fs.writeFileSync(path.join(dir, 'contact-i18n.js'), out, 'utf8');
console.log('Wrote contact-i18n.js');
