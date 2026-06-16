# Vérifie qu'aucune permission READ_MEDIA_* n'est dans le manifest fusionné release.
# Usage (après flutter build appbundle --release) :
#   .\tool\verify_android_media_permissions.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$candidates = @(
    "$root\build\app\intermediates\merged_manifests\release\processReleaseManifest\AndroidManifest.xml",
    "$root\build\app\intermediates\merged_manifest\release\processReleaseMainManifest\AndroidManifest.xml"
)

$manifest = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $manifest) {
    Write-Host "Manifest fusionné introuvable. Lancez d'abord : flutter build appbundle --release" -ForegroundColor Red
    exit 1
}

$text = Get-Content $manifest -Raw
$forbidden = @(
    "READ_MEDIA_IMAGES",
    "READ_MEDIA_VIDEO",
    "READ_MEDIA_AUDIO",
    "READ_EXTERNAL_STORAGE",
    "WRITE_EXTERNAL_STORAGE"
)

$found = $forbidden | Where-Object { $text -match $_ }
$version = if ($text -match 'android:versionCode="(\d+)"') { $Matches[1] } else { "?" }

Write-Host "Manifest : $manifest"
Write-Host "versionCode : $version"

if ($found) {
    Write-Host "ECHEC - permissions interdites detectees :" -ForegroundColor Red
    $found | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "OK - aucune permission media persistante dans le build $version." -ForegroundColor Green
Write-Host ""
Write-Host "Si Play Console affiche encore l'erreur, ce n'est PAS le code :"
Write-Host "  1. App Bundle Explorer - reperer les versionCode Actifs avec READ_MEDIA"
Write-Host "  2. Mettre a jour TOUS les tracks (interne, ferme, ouvert, production)"
Write-Host "  3. Exclure les anciennes versions (section Non incluses)"
Write-Host "  4. Politique - Contenu - Photos et videos - declarer acces ponctuel uniquement"
