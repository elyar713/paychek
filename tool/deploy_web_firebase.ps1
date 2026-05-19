# Build Flutter Web puis deploiement Firebase Hosting (projet [default] dans .firebaserc).
# Prerequis : `npm i -g firebase-tools` (ou npx), `firebase login`, et droits sur le projet Firebase.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host ">> flutter build web --release --no-wasm-dry-run" -ForegroundColor Cyan
flutter build web --release --no-wasm-dry-run
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Fichiers SEO statiques (sinon le rewrite SPA renvoie index.html et Google voit une erreur sitemap).
$seoFiles = @('sitemap.xml', 'robots.txt', 'landing.html', 'privacy.html', 'terms.html')
foreach ($name in $seoFiles) {
  $src = Join-Path $root "web\$name"
  $dst = Join-Path $root "build\web\$name"
  if (-not (Test-Path $src)) {
    Write-Host "WARN: web\$name manquant" -ForegroundColor Yellow
    continue
  }
  if (-not (Test-Path $dst)) {
    Copy-Item $src $dst -Force
    Write-Host ">> copie web\$name -> build\web\" -ForegroundColor Yellow
  }
}

Write-Host ">> firebase deploy --only hosting" -ForegroundColor Cyan
firebase deploy --only hosting
exit $LASTEXITCODE
