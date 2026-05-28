# Déploie l'app Paychek + Trading Admin sous UN SEUL site Hosting (paychek-trading).
# Déploiement Hosting : site Firebase `paychek-trading` (voir firebase.json).
# Après déploiement : app à la racine du domaine connecté (ex. https://paychek.pro/) ;
# console admin : suffixe /admin-hub/ (ex. https://paychek.pro/admin-hub/).
#
# IMPORTANT — Ne pas lancer avant ce script :
#   flutter build web -t lib/admin/main_admin.dart
# sans --output, car ça ÉCRASE build/web et la RACINE DU SITE DEVIENT LA CONSOLE ADMIN.
#
# Ordre volontaire : (1) build admin hors build/web → (2) build app principale dans
# build/web en DERNIER, puis copie admin dans build/web/admin-hub.
#
# Usage (PowerShell, à la racine du projet) :
#   .\scripts\deploy_web_with_admin_hub.ps1
#
# Optionnel — lien Stripe (Payment Link / Checkout) pour le paywall web :
#   $env:PAYCHEK_STRIPE_CHECKOUT_URL = 'https://buy.stripe.com/...'
#   .\scripts\deploy_web_with_admin_hub.ps1

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error 'flutter absent du PATH.'
}

flutter build web `
  -t lib/admin/main_admin.dart `
  --base-href /admin-hub/ `
  --output build/admin_web `
  --no-tree-shake-icons
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$mainFlutterArgs = @('build', 'web', '-t', 'lib/main.dart', '--no-tree-shake-icons')
$stripeUrl = [string]$env:PAYCHEK_STRIPE_CHECKOUT_URL
if ($stripeUrl.Trim().Length -gt 0) {
  $mainFlutterArgs += "--dart-define=PAYCHEK_STRIPE_CHECKOUT_URL=$($stripeUrl.Trim())"
}
& flutter @mainFlutterArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Pages marketing / SEO (sinon absentes si le build web ne les recopie pas).
$seoFiles = @('sitemap.xml', 'robots.txt', 'landing.html', 'landing-i18n.js', 'privacy.html', 'terms.html', 'admin-hub.html')
foreach ($name in $seoFiles) {
  $src = Join-Path (Get-Location) "web\$name"
  $dst = Join-Path (Get-Location) "build\web\$name"
  if (Test-Path $src) {
    Copy-Item -Force $src $dst
  }
}
$webImages = Join-Path (Get-Location) 'web\images'
$buildImages = Join-Path (Get-Location) 'build\web\images'
if (Test-Path $webImages) {
  New-Item -ItemType Directory -Force -Path $buildImages | Out-Null
  Copy-Item -Path (Join-Path $webImages '*') -Destination $buildImages -Recurse -Force
}

$adminDest = Join-Path (Get-Location) 'build\web\admin-hub'
if (Test-Path $adminDest) {
  Remove-Item -Recurse -Force $adminDest
}
New-Item -ItemType Directory -Path $adminDest | Out-Null

Copy-Item -Path 'build\admin_web\*' -Destination $adminDest -Recurse -Force

$rootIndex = Join-Path (Get-Location) 'build\web\index.html'
$adminIndex = Join-Path (Get-Location) 'build\web\admin-hub\index.html'
if (-not (Test-Path -LiteralPath $rootIndex)) {
  Write-Error "Fichier manquant : build/web/index.html — le build app principal a échoué ou build/web est vide. Pas de deploiement."
}
if (-not (Test-Path -LiteralPath $adminIndex)) {
  Write-Error "Fichier manquant : build/web/admin-hub/index.html — la copie admin a échoué. Pas de deploiement."
}

firebase deploy --only hosting:paychek-trading

Write-Host ''
Write-Host 'Paychek (racine) : build/web'
Write-Host 'Admin            : build/web/admin-hub/'
Write-Host 'URL admin        : https://paychek-trading.web.app/admin-hub/  (pas admin-hub.html)'
