'use strict';

const fs = require('fs');
const path = require('path');

const dir = __dirname;
const MEDIA = require('./landing-media.cjs');

const LOCALE_KEYS = ['fr', 'en', 'de', 'es', 'pt', 'ko'];

function readOptionalJson(rel) {
  const p = path.join(dir, rel);
  if (!fs.existsSync(p)) return null;
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

/** Surface + preview fallback: locale → en → fr (preview copy should stay aligned with UX language). */
function loadLocaleMerged(code) {
  const fallback = code === 'fr' ? ['fr'] : code === 'en' ? ['en', 'fr'] : [code, 'en', 'fr'];
  let surface = null;
  for (const c of fallback) {
    surface = readOptionalJson('surface-' + c + '.json');
    if (surface) break;
  }
  if (!surface) {
    throw new Error('surface JSON missing even after fr/en fallback — add surface-fr.json');
  }
  let previewModules = null;
  for (const c of fallback) {
    previewModules = readOptionalJson('landing-preview-modules-' + c + '.clean.json');
    if (previewModules) break;
  }
  if (!previewModules) {
    throw new Error('landing-preview-modules-fr.clean.json (or fallback) missing');
  }
  return Object.assign({}, surface, { previewModules });
}

const PAYCHEK_LANDING_I18N = {};
for (const k of LOCALE_KEYS) {
  PAYCHEK_LANDING_I18N[k] = loadLocaleMerged(k);
}

const runtime = fs.readFileSync(path.join(dir, 'landing-i18n-runtime-embed.js'), 'utf8');

const outParts = [];
outParts.push('/* PAYCHEK landing i18n (bundled compose-paychek-landing-i18n.cjs output) */');
outParts.push("'use strict';");
outParts.push('(function () {');
outParts.push('  window.PAYCHEK_LANDING_MEDIA = ' + JSON.stringify(MEDIA) + ';');
outParts.push('  window.PAYCHEK_LANDING_I18N = ' + JSON.stringify(PAYCHEK_LANDING_I18N, null, 0) + ';');
outParts.push(runtime);
outParts.push('})();');
outParts.push('');

const outPath = path.join(dir, 'landing-i18n.js');
fs.writeFileSync(outPath, outParts.join('\n'), 'utf8');

console.log(
  'Wrote',
  outPath,
  'bytes=',
  Buffer.byteLength(outParts.join('\n'), 'utf8'),
  '(locales:',
  LOCALE_KEYS.join(', '),
  ')'
);
