# Aide test Sign in with Apple iPad - Windows (pas de simulateur iOS local).
# Le test reel necessite un Mac avec Xcode OU un iPad physique.
#
# Usage (PowerShell, racine du repo) :
#   .\scripts\ios\test_apple_signin_ipad.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location $Root

Write-Host "==> Paychek - test Sign in with Apple (iPad)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ce PC est sous Windows : le simulateur iPad n'est pas disponible ici." -ForegroundColor Yellow
Write-Host ""
Write-Host "Options pour tester avant resoumission :" -ForegroundColor White
Write-Host "  1. Mac + Xcode : ./scripts/ios/test_apple_signin_ipad.sh"
Write-Host "  2. iPad physique : installer un build TestFlight ou ad-hoc"
Write-Host "  3. CI Mac (Codemagic, GitHub Actions macos-latest) : flutter build ipa + test manuel"
Write-Host ""
Write-Host "Checklist rapide :" -ForegroundColor Green
Write-Host "  [ ] Supprimer l app sur l iPad"
Write-Host "  [ ] Installer le nouveau build (build 45+)"
Write-Host "  [ ] Sign in with Apple - doit quitter l ecran login"
Write-Host "  [ ] Paywall - liens Privacy + Terms cliquables en bas"
Write-Host ""
Write-Host "Documentation complete :" -ForegroundColor Green
Write-Host "  docs/app_store_resubmission_checklist.md"
Write-Host ""

if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "Verification dependances Flutter (Windows)..." -ForegroundColor DarkGray
    flutter pub get | Out-Null
    Write-Host "  crypto + sign_in_with_apple : OK (pub get reussi)" -ForegroundColor DarkGray
} else {
    Write-Host "Flutter non installe sur ce PATH." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Bundle ID attendu : pro.paychek.app" -ForegroundColor DarkGray
Write-Host "Privacy URL       : https://paychek.pro/privacy-en.html" -ForegroundColor DarkGray
Write-Host "Terms URL         : https://paychek.pro/terms.html" -ForegroundColor DarkGray
