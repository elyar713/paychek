# Déploie uniquement l'app Paychek (build/web) sur Firebase Hosting paychek-trading.
# Prérequis : firebase login (session valide).
#
# Usage :
#   .\scripts\deploy_web_hosting_only.ps1

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error 'flutter absent du PATH.'
}
if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
  Write-Error 'firebase CLI absent du PATH.'
}

flutter build web --release --no-wasm-dry-run
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$seoFiles = @(
  'sitemap.xml', 'robots.txt', 'landing.html', 'landing-i18n.js',
  'privacy.html', 'privacy-en.html', 'terms.html',
  'blog.html', 'contact.html'
)
foreach ($name in $seoFiles) {
  $src = Join-Path (Get-Location) "web\$name"
  $dst = Join-Path (Get-Location) "build\web\$name"
  if (Test-Path $src) { Copy-Item -Force $src $dst }
}
foreach ($dir in @('images', 'js', 'css', 'blog-i18n', 'contact-i18n')) {
  $srcDir = Join-Path (Get-Location) "web\$dir"
  $dstDir = Join-Path (Get-Location) "build\web\$dir"
  if (-not (Test-Path $srcDir)) { continue }
  New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
  Copy-Item -Path (Join-Path $srcDir '*') -Destination $dstDir -Recurse -Force
}

$landingJs = Join-Path (Get-Location) 'build\web\js\landing-page.js'
if (-not (Test-Path $landingJs)) {
  Write-Error 'build/web/js/landing-page.js manquant.'
}
if (Select-String -Path $landingJs -Pattern 'overlay=1' -Quiet) {
  Write-Error 'landing-page.js contient encore overlay=1 — corrige web/js/landing-page.js avant deploy.'
}
Write-Host 'OK: landing-page.js utilise la redirection top-level (pas overlay iframe).' -ForegroundColor Green

firebase deploy --only hosting:paychek-trading
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Deploye. Verifiez : https://paychek.pro/js/landing-page.js" -ForegroundColor Cyan
Write-Host "  -> doit contenir window.location.href (pas overlay=1)" -ForegroundColor Cyan
