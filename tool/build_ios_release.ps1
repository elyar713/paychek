# Préparation release iOS — le build IPA doit se faire sur macOS (Xcode).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$pubspec = Get-Content -Raw (Join-Path $root 'pubspec.yaml')
if ($pubspec -match 'version:\s*(\S+)') {
  $version = $Matches[1]
  Write-Host "Version Flutter (pubspec) : $version" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Le build iOS / App Store ne peut pas être lancé depuis Windows." -ForegroundColor Yellow
Write-Host "Sur un Mac, dans le dossier du projet :" -ForegroundColor White
Write-Host "  chmod +x tool/build_ios_release.sh" -ForegroundColor Gray
Write-Host "  ./tool/build_ios_release.sh" -ForegroundColor Green
Write-Host ""
Write-Host "Puis App Store Connect → app Paychek → + version → envoyer le build (Transporter ou Xcode)." -ForegroundColor White

Write-Host ""
Write-Host ">> flutter pub get (vérif dépendances)" -ForegroundColor Cyan
flutter pub get

Write-Host ">> flutter analyze" -ForegroundColor Cyan
flutter analyze
exit $LASTEXITCODE
