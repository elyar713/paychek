# Build Paychek for the browser (release).
# Sur Windows, le dry-run WASM peut échouer sur les liens symboliques — on le désactive.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
flutter build web --release --no-wasm-dry-run
