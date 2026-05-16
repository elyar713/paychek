# Build Flutter Web puis deploiement Firebase Hosting (projet [default] dans .firebaserc).
# Prerequis : `npm i -g firebase-tools` (ou npx), `firebase login`, et droits sur le projet Firebase.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host ">> flutter build web --release --no-wasm-dry-run" -ForegroundColor Cyan
flutter build web --release --no-wasm-dry-run
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ">> firebase deploy --only hosting" -ForegroundColor Cyan
firebase deploy --only hosting
exit $LASTEXITCODE
