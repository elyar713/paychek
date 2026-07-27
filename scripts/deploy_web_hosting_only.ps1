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
  'safeguard.html', 'safeguard-i18n.js',
  'licence.html', 'licence-i18n.js',
  'facturation.html', 'facturation-i18n.js',
  'privacy.html', 'privacy-en.html', 'terms.html',
  'blog.html', 'blog-i18n.js', 'contact.html', 'contact-i18n.js'
)
foreach ($name in $seoFiles) {
  $src = Join-Path (Get-Location) "web\$name"
  $dst = Join-Path (Get-Location) "build\web\$name"
  if (Test-Path $src) { Copy-Item -Force $src $dst }
}
foreach ($dir in @('images', 'js', 'css', 'blog-i18n', 'contact-i18n', 'downloads')) {
  $srcDir = Join-Path (Get-Location) "web\$dir"
  $dstDir = Join-Path (Get-Location) "build\web\$dir"
  if (-not (Test-Path $srcDir)) { continue }
  New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
  Copy-Item -Path (Join-Path $srcDir '*') -Destination $dstDir -Recurse -Force
}

$siteAuthJs = Join-Path (Get-Location) 'build\web\js\paychek-site-auth.js'
if (-not (Test-Path $siteAuthJs)) {
  Write-Error 'build/web/js/paychek-site-auth.js manquant.'
}
if (-not (Select-String -Path $siteAuthJs -Pattern 'paychekOpenSiteAuth' -Quiet)) {
  Write-Error 'paychek-site-auth.js ne définit pas paychekOpenSiteAuth.'
}

$landingJs = Join-Path (Get-Location) 'build\web\js\landing-page.js'
if (-not (Test-Path $landingJs)) {
  Write-Error 'build/web/js/landing-page.js manquant.'
}
if (Select-String -Path $landingJs -Pattern 'location\.href\s*=\s*.*/\?auth=' -Quiet) {
  Write-Error 'landing-page.js redirige encore vers /?auth= — corrige web/js/landing-page.js avant deploy.'
}
if (Select-String -Path $landingJs -Pattern 'overlay=1' -Quiet) {
  Write-Error 'landing-page.js contient encore overlay=1 — corrige web/js/landing-page.js avant deploy.'
}

$accountNav = Join-Path (Get-Location) 'build\web\js\paychek-account-nav.js'
if (Select-String -Path $accountNav -Pattern 'href="/\?auth=' -Quiet) {
  Write-Error 'paychek-account-nav.js contient encore /?auth= — corrige avant deploy.'
}

Write-Host 'OK: auth marketing = HTML Firebase (pas Flutter /?auth=).' -ForegroundColor Green

firebase deploy --only hosting:paychek-trading
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Deploye. Verifiez : https://paychek.pro/landing.html" -ForegroundColor Cyan
Write-Host "  -> Connexion / Inscription = modale HTML (pas de boot Flutter)" -ForegroundColor Cyan
Write-Host "  -> Journal = /?app=1 (menu Mon compte)" -ForegroundColor Cyan
Write-Host "  -> Licence = /licence.html | Facturation = /facturation.html" -ForegroundColor Cyan
