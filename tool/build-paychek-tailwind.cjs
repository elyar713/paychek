'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');
const https = require('https');

const webDir = path.join(__dirname, '..', 'web');
const toolsDir = path.join(webDir, 'tools');
const exeName = process.platform === 'win32' ? 'tailwindcss.exe' : 'tailwindcss';
const exePath = path.join(toolsDir, exeName);
const cssOut = path.join(webDir, 'css', 'paychek-tailwind.css');
const releaseUrl =
  'https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.17/tailwindcss-windows-x64.exe';

function download(url, dest) {
  return new Promise((resolve, reject) => {
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    const file = fs.createWriteStream(dest);
    https
      .get(url, (res) => {
        if (res.statusCode === 302 || res.statusCode === 301) {
          file.close();
          fs.unlinkSync(dest);
          download(res.headers.location, dest).then(resolve).catch(reject);
          return;
        }
        if (res.statusCode !== 200) {
          reject(new Error('Download failed: HTTP ' + res.statusCode));
          return;
        }
        res.pipe(file);
        file.on('finish', () => file.close(resolve));
      })
      .on('error', reject);
  });
}

async function ensureCli() {
  if (fs.existsSync(exePath)) return exePath;
  if (process.platform !== 'win32') {
    throw new Error(
      'Tailwind standalone binary missing. On macOS/Linux, download from ' +
        'https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.17 ' +
        'into web/tools/tailwindcss'
    );
  }
  console.log('Downloading Tailwind standalone CLI…');
  await download(releaseUrl, exePath);
  return exePath;
}

async function main() {
  const cli = await ensureCli();
  fs.mkdirSync(path.dirname(cssOut), { recursive: true });
  const args = [
    '-c',
    path.join(webDir, 'tailwind.config.js'),
    '-i',
    path.join(webDir, 'input.css'),
    '-o',
    cssOut,
    '--minify',
  ];
  const result = spawnSync(cli, args, { stdio: 'inherit', cwd: webDir });
  if (result.status !== 0) process.exit(result.status || 1);
  console.log('Wrote', cssOut);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
