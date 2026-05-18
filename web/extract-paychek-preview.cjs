'use strict';
const fs = require('fs');
const path = require('path');
const landingPath = path.join(__dirname, 'landing.html');
const txt = fs.readFileSync(landingPath, 'utf8');
const anchor = txt.indexOf('const previewData = ');
if (anchor < 0) throw new Error('anchor');
const braceStart = txt.indexOf('{', anchor);
let depth = 0;
let end = -1;
for (let j = braceStart; j < txt.length; j++) {
  const c = txt.charAt(j);
  if (c === '{') depth++;
  else if (c === '}') {
    depth--;
    if (depth === 0) {
      end = j;
      break;
    }
  }
}
if (end < 0) throw new Error('end');
const literal = txt.slice(braceStart, end + 1);
const previewModules = new Function('return (' + literal + ')')();
const out = path.join(__dirname, 'landing-preview-modules-fr.json');
fs.writeFileSync(out, JSON.stringify(previewModules, null, 2), 'utf8');
console.log('Wrote', out, 'keys=', Object.keys(previewModules).join(','));
