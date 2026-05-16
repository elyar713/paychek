/**
 * One-shot: builds lib/l10n/app_pt.arb from app_en.arb via MyMemory API (en|pt).
 * Run: node tool/translate_arb_to_pt.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const srcPath = path.join(root, 'lib', 'l10n', 'app_en.arb');
const outPath = path.join(root, 'lib', 'l10n', 'app_pt.arb');

const PLACEHOLDER = (i) => `⟦${i}⟧`;

function protectPlaceholders(s) {
  const found = [];
  let out = s.replace(/\{[^{}]+\}/g, (m) => {
    const i = found.length;
    found.push(m);
    return PLACEHOLDER(i);
  });
  return { text: out, found };
}

function restorePlaceholders(s, found) {
  let out = s;
  for (let i = 0; i < found.length; i++) {
    out = out.split(PLACEHOLDER(i)).join(found[i]);
  }
  return out;
}

async function translateLine(text) {
  const t = text.trim();
  if (!t) return text;
  const { text: protectedText, found } = protectPlaceholders(t);
  const url =
    'https://api.mymemory.translated.net/get?' +
    new URLSearchParams({ q: protectedText, langpair: 'en|pt-BR' });
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const j = await res.json();
  const tr = j.responseData?.translatedText;
  if (!tr) throw new Error(JSON.stringify(j));
  return restorePlaceholders(tr, found);
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

const raw = fs.readFileSync(srcPath, 'utf8');
const data = JSON.parse(raw);
const out = { '@@locale': 'pt' };

let n = 0;
const keys = Object.keys(data).filter((k) => k !== '@@locale');
for (const k of keys) {
  const v = data[k];
  if (typeof v === 'string') {
    process.stdout.write(`\r${++n}/${keys.length} ${k.slice(0, 40)}…`);
    try {
      out[k] = await translateLine(v);
    } catch (e) {
      console.error(`\nFAIL ${k}:`, e.message);
      out[k] = v;
    }
    await sleep(120);
  } else {
    out[k] = v;
  }
}

fs.writeFileSync(outPath, JSON.stringify(out, null, 2) + '\n', 'utf8');
console.log(`\nWrote ${outPath}`);
