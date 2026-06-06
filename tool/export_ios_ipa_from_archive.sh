#!/usr/bin/env bash
# Exporte un .ipa depuis une archive déjà créée (secours si flutter build ipa → code 127).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=ios_signing_env.sh
source "$(dirname "$0")/ios_signing_env.sh"

ARCHIVE_PATH="${1:-build/ios/archive/Runner.xcarchive}"
EXPORT_DIR="build/ios/ipa"
EXPORT_PLIST_BASE="ios/ExportOptions.plist"

if [[ ! -d "$ARCHIVE_PATH" ]]; then
  echo "ERROR: archive introuvable : $ARCHIVE_PATH" >&2
  echo "  Lance d’abord : ./tool/build_ios_release.sh" >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "ERROR: xcodebuild introuvable (Xcode CLI)." >&2
  echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer" >&2
  exit 127
fi

paychek_ios_unlock_login_keychain

EXPORT_PLIST="$EXPORT_PLIST_BASE"
TEMP_PLIST=""
if [[ -f "$EXPORT_PLIST_BASE" ]]; then
  TEMP_PLIST="$(paychek_ios_export_plist_with_team "$EXPORT_PLIST_BASE")"
  if [[ "$TEMP_PLIST" != "$EXPORT_PLIST_BASE" ]]; then
    EXPORT_PLIST="$TEMP_PLIST"
    echo ">> teamID depuis ios/Flutter/Signing.xcconfig"
  fi
fi

echo ">> xcodebuild -exportArchive -allowProvisioningUpdates"
echo "   Archive : $ARCHIVE_PATH"
echo "   Export  : $EXPORT_DIR"
rm -rf "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR"

set +e
if [[ -f "$EXPORT_PLIST" ]]; then
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$EXPORT_PLIST" \
    -allowProvisioningUpdates
else
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportMethod app-store-connect \
    -allowProvisioningUpdates
fi
EXPORT_STATUS=$?
set -e

if [[ -n "$TEMP_PLIST" && -f "$TEMP_PLIST" ]]; then
  rm -f "$TEMP_PLIST"
fi

IPA_FILE="$(find "$EXPORT_DIR" -maxdepth 1 -name '*.ipa' 2>/dev/null | head -1 || true)"
if [[ -z "$IPA_FILE" ]]; then
  echo ""
  echo "ERROR: exportArchive a échoué (code $EXPORT_STATUS), aucun .ipa." >&2
  echo ""
  echo "MacinCloud — compte Xcode connecté ≠ certificat Distribution dans le trousseau." >&2
  echo "  1. Ouvre Xcode (interface graphique, pas seulement le terminal)" >&2
  echo "  2. Settings → Accounts → Manage Certificates → + → Apple Distribution" >&2
  echo "  3. Runner.xcworkspace → Runner → Signing → Team + Automatically manage signing" >&2
  echo "  4. cp ios/Flutter/Signing.xcconfig.example ios/Flutter/Signing.xcconfig" >&2
  echo "     puis mets ton Team ID (10 caractères)" >&2
  echo "  5. Plan sûr : open $ARCHIVE_PATH → Distribute App → App Store Connect" >&2
  exit 1
fi

echo ""
echo "IPA prêt : $IPA_FILE"
echo "  open $EXPORT_DIR"
