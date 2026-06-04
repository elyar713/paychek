# Build AAB signé pour Google Play (pro.paychek.app).
# Prérequis : android/key.properties + keystore (voir android/app/build.gradle.kts).
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

if (-not (Test-Path "android\key.properties")) {
    Write-Error "android\key.properties introuvable. Configure la signature release avant le build."
}

flutter pub get
flutter build appbundle --release

$Out = Join-Path $Root "build\app\outputs\bundle\release\app-release.aab"
if (-not (Test-Path $Out)) {
    Write-Error "AAB non généré : $Out"
}

$version = (Select-String -Path "pubspec.yaml" -Pattern "^version:\s*(.+)$").Matches[0].Groups[1].Value.Trim()
Write-Host ""
Write-Host "OK — Paychek Android $version"
Write-Host "AAB : $Out"
Write-Host "Play Console → Production ou Test interne → Créer une version → Importer l'AAB"
