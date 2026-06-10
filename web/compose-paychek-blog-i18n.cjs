'use strict';

const fs = require('fs');
const path = require('path');

const dir = __dirname;
const LOCALE_KEYS = ['fr', 'en', 'de', 'es', 'pt', 'ko'];
const i18nDir = path.join(dir, 'blog-i18n');

const PAYCHEK_BLOG_I18N = {};
for (const code of LOCALE_KEYS) {
  const p = path.join(i18nDir, code + '.json');
  if (!fs.existsSync(p)) {
    throw new Error('Missing blog translation: ' + p);
  }
  PAYCHEK_BLOG_I18N[code] = JSON.parse(fs.readFileSync(p, 'utf8'));
}

const runtime = fs.readFileSync(path.join(dir, 'blog-i18n-runtime.js'), 'utf8');
const outParts = [
  '/* PAYCHEK blog i18n (compose-paychek-blog-i18n.cjs output) */',
  "'use strict';",
  '(function () {',
  '  window.PAYCHEK_BLOG_I18N = ' + JSON.stringify(PAYCHEK_BLOG_I18N) + ';',
  runtime,
  '})();',
  '',
];

const outPath = path.join(dir, 'blog-i18n.js');
fs.writeFileSync(outPath, outParts.join('\n'), 'utf8');
console.log('Wrote', outPath, 'bytes=', Buffer.byteLength(outParts.join('\n'), 'utf8'));
