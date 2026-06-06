#!/usr/bin/env bash
# Diagnostic signature iOS (Mac) — lancer avant export IPA.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "=== Paychek iOS signing check ==="
echo ""

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "FAIL: xcodebuild introuvable"
  exit 127
fi

echo ">> Xcode"
xcodebuild -version | head -2
echo "   xcode-select: $(xcode-select -p)"
echo ""

echo ">> Comptes Xcode (CLI)"
if xcodebuild -checkFirstLaunchStatus 2>/dev/null; then
  :
fi
# Liste les équipes vues par xcodebuild (nécessite au moins une archive ou -list)
xcodebuild -showBuildSettings -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release 2>/dev/null | grep -E 'DEVELOPMENT_TEAM|PRODUCT_BUNDLE_IDENTIFIER|CODE_SIGN' | head -20 || true
echo ""

echo ">> Certificats dans le trousseau (codesigning)"
IDENTITIES="$(security find-identity -v -p codesigning 2>/dev/null || true)"
echo "$IDENTITIES"
echo ""

HAS_DIST=0
if echo "$IDENTITIES" | grep -q 'Apple Distribution'; then
  HAS_DIST=1
  echo "OK: certificat « Apple Distribution » trouvé"
else
  echo "FAIL: pas de certificat « Apple Distribution »"
  echo "     Compte Apple dans Xcode ≠ certificat dans le Trousseau."
  echo "     Xcode (GUI) → Settings → Accounts → Manage Certificates → + → Apple Distribution"
  echo "     Puis relance : ./tool/export_ios_ipa_from_archive.sh (avec -allowProvisioningUpdates)"
fi

HAS_DEV=0
if echo "$IDENTITIES" | grep -q 'Apple Development'; then
  HAS_DEV=1
  echo "OK: certificat « Apple Development » trouvé"
else
  echo "WARN: pas de certificat « Apple Development »"
fi

echo ""
echo ">> Signing.xcconfig"
if [[ -f ios/Flutter/Signing.xcconfig ]]; then
  echo "OK: ios/Flutter/Signing.xcconfig présent"
  grep DEVELOPMENT_TEAM ios/Flutter/Signing.xcconfig || true
else
  echo "WARN: ios/Flutter/Signing.xcconfig absent (copier depuis Signing.xcconfig.example)"
fi

echo ""
echo ">> ExportOptions.plist"
if [[ -f ios/ExportOptions.plist ]]; then
  plutil -p ios/ExportOptions.plist 2>/dev/null || cat ios/ExportOptions.plist
else
  echo "WARN: ios/ExportOptions.plist absent"
fi

echo ""
echo ">> Archive"
ARCH="build/ios/archive/Runner.xcarchive"
if [[ -d "$ARCH" ]]; then
  echo "OK: $ARCH"
else
  echo "INFO: pas d’archive locale (normal avant build)"
fi

echo ""
if [[ "$HAS_DIST" -eq 0 ]]; then
  echo "=== Résultat: pas de Apple Distribution dans le trousseau (export CLI échouera) ==="
  echo ""
  echo "MacinCloud : fais ces étapes dans l’interface Xcode (VNC), pas en SSH seul :"
  echo "  1. open ios/Runner.xcworkspace"
  echo "  2. Runner → Signing & Capabilities → Team + Automatically manage signing"
  echo "  3. Xcode → Settings → Accounts → Manage Certificates → + → Apple Distribution"
  echo "  4. cp ios/Flutter/Signing.xcconfig.example ios/Flutter/Signing.xcconfig"
  echo "     nano ios/Flutter/Signing.xcconfig   # DEVELOPMENT_TEAM=TON_TEAM_ID"
  echo "  5. ./tool/rearchive_ios_signed.sh && ./tool/export_ios_ipa_from_archive.sh"
  echo ""
  echo "Plan B (le plus fiable) :"
  echo "  open build/ios/archive/Runner.xcarchive"
  echo "  Distribute App → App Store Connect → Upload"
  echo ""
  echo "Plan C : exporter le certificat .p12 depuis ton Mac perso et l’importer sur MacinCloud"
  exit 1
fi

echo "=== Résultat: certificat Distribution OK — si export échoue encore, vérifie Team + profil App Store pour pro.paychek.app ==="
