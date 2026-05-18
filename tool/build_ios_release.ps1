# Préparation release iOS — le build IPA doit se faire sur macOS (Xcode).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$version = 'unknown'
$pubspec = Get-Content -Raw (Join-Path $root 'pubspec.yaml')
if ($pubspec -match 'version:\s*(\S+)') {
  $version = $Matches[1]
}

Write-Host "Paychek iOS release" -ForegroundColor Cyan
Write-Host "  Version pubspec : $version" -ForegroundColor White
$notes = Join-Path $root "tool\ios_release_notes_$($version.Split('+')[0]).txt"
if (Test-Path $notes) {
  Write-Host "  Notes App Store : $notes" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Le build iOS ne peut pas être lancé depuis Windows (il faut un Mac)." -ForegroundColor Yellow
Write-Host ""
Write-Host "A) Tester sur TON iPhone (compte Apple pas encore validé possible) :" -ForegroundColor Cyan
Write-Host "  ./tool/build_ios_on_device.sh" -ForegroundColor Green
Write-Host "  → Xcode → Run sur l’iPhone branché (install local, pas l’App Store)." -ForegroundColor Gray
Write-Host ""
Write-Host "B) Mise à jour App Store pour tout le monde (compte Developer ACTIVE) :" -ForegroundColor Cyan
Write-Host "  ./tool/build_ios_release.sh" -ForegroundColor Green
Write-Host "  → App Store Connect → version $version → Transporter / Xcode Archive." -ForegroundColor Gray

Write-Host ""
Write-Host ">> flutter pub get" -ForegroundColor Cyan
flutter pub get

Write-Host ">> flutter gen-l10n" -ForegroundColor Cyan
flutter gen-l10n

Write-Host ">> flutter analyze" -ForegroundColor Cyan
flutter analyze
exit $LASTEXITCODE
