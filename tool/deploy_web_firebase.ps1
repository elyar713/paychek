# Build Flutter Web puis deploiement Firebase Hosting (projet [default] dans .firebaserc).
# Prerequis : `npm i -g firebase-tools` (ou npx), `firebase login`, et droits sur le projet Firebase.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host ">> flutter build web --release --no-wasm-dry-run" -ForegroundColor Cyan
flutter build web --release --no-wasm-dry-run
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Fichiers marketing / SEO : toujours recopier (évite build Flutter stale + cache navigateur).
$seoFiles = @('sitemap.xml', 'robots.txt', 'landing.html', 'privacy.html', 'terms.html', 'contact.html', 'blog.html', 'contact-i18n.js', 'landing-i18n.js')
foreach ($name in $seoFiles) {
  $src = Join-Path $root "web\$name"
  $dst = Join-Path $root "build\web\$name"
  if (-not (Test-Path $src)) {
    Write-Host "WARN: web\$name manquant" -ForegroundColor Yellow
    continue
  }
  Copy-Item $src $dst -Force
  Write-Host ">> copie web\$name -> build\web\" -ForegroundColor DarkGray
}

$marketingDirs = @('css', 'js', 'images')
foreach ($dir in $marketingDirs) {
  $srcDir = Join-Path $root "web\$dir"
  $dstDir = Join-Path $root "build\web\$dir"
  if (-not (Test-Path $srcDir)) { continue }
  if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
  Copy-Item (Join-Path $srcDir '*') $dstDir -Recurse -Force
  Write-Host ">> sync web\$dir -> build\web\$dir" -ForegroundColor DarkGray
}

Write-Host ">> firebase deploy --only hosting" -ForegroundColor Cyan
firebase deploy --only hosting
exit $LASTEXITCODE
