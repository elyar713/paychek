# After: flutter build web --base-href /app/
# Root (/) = marketing landing; /app/ = Flutter app
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'build\web'
$appDir = Join-Path $out 'app'

if (-not (Test-Path $out)) {
  throw 'build/web missing. Run: flutter build web --base-href /app/'
}

New-Item -ItemType Directory -Force -Path $appDir | Out-Null

$moveNames = @(
  'index.html',
  'main.dart.js',
  'flutter.js',
  'flutter_bootstrap.js',
  'flutter_service_worker.js',
  'version.json',
  'manifest.json'
)
foreach ($name in $moveNames) {
  $src = Join-Path $out $name
  if (Test-Path $src) {
    Move-Item -Force $src (Join-Path $appDir $name)
  }
}
foreach ($dir in @('assets', 'canvaskit')) {
  $src = Join-Path $out $dir
  if (Test-Path $src) {
    $dest = Join-Path $appDir $dir
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    Move-Item -Force $src $dest
  }
}

$landing = Join-Path $out 'landing.html'
if (-not (Test-Path $landing)) {
  throw 'build/web/landing.html missing'
}
Copy-Item -Force $landing (Join-Path $out 'index.html')
Write-Host 'OK: / = landing, /app/ = Flutter' -ForegroundColor Green
