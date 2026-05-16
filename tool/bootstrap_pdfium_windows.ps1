# Pré-télécharge PDFium pour pdfrx lorsque CMake file(DOWNLOAD) échoue (fichier .tgz vide).
# Usage (depuis la racine du projet) :
#   powershell -ExecutionPolicy Bypass -File tool/bootstrap_pdfium_windows.ps1

$ErrorActionPreference = 'Stop'

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$releaseDirName = 'chromium%2F7202'
$destDir = Join-Path $projectRoot "build/windows/x64/pdfium/$releaseDirName"
$url = "https://github.com/bblanchon/pdfium-binaries/releases/download/chromium%2F7202/pdfium-win-x64.tgz"
$tgz = Join-Path $destDir 'pdfium-win-x64.tgz'
$dll = Join-Path $destDir 'bin/pdfium.dll'

New-Item -ItemType Directory -Force $destDir | Out-Null

if ((Test-Path $dll) -and (Get-Item $dll).Length -gt 0) {
  Write-Host "PDFium déjà présent : $dll"
  exit 0
}

Write-Host "Téléchargement PDFium (pdfrx / Windows x64)..."
Invoke-WebRequest -Uri $url -OutFile $tgz -UseBasicParsing

$len = (Get-Item $tgz).Length
if ($len -lt 100000) {
  Remove-Item -Force $tgz -ErrorAction SilentlyContinue
  throw "Téléchargement invalide ou vide ($len octets). Vérifiez proxy / antivirus / TLS."
}

Write-Host "Extraction vers $destDir ..."
tar -xzf $tgz -C $destDir

if (-not (Test-Path $dll)) {
  throw "Extraction terminée mais introuvable : $dll"
}

Write-Host "OK : $dll ($((Get-Item $dll).Length) octets)"
