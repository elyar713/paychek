#!/usr/bin/env bash
# Re-archive Runner avec signature automatique (MacinCloud / certificat manquant).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=ios_signing_env.sh
source "$(dirname "$0")/ios_signing_env.sh"
# shellcheck source=_paychek_flutter_env.sh
source "$(dirname "$0")/_paychek_flutter_env.sh"

paychek_require_flutter

ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"

if [[ ! -f ios/Flutter/Signing.xcconfig ]]; then
  echo "ERROR: ios/Flutter/Signing.xcconfig absent." >&2
  echo "  cp ios/Flutter/Signing.xcconfig.example ios/Flutter/Signing.xcconfig" >&2
  echo "  Remplace XXXXXXXXXX par ton Team ID (Xcode → Settings → Accounts)." >&2
  exit 1
fi

paychek_ios_unlock_login_keychain

echo ">> flutter pub get + pod install"
flutter pub get
(cd ios && pod install)

echo ">> xcodebuild archive (-allowProvisioningUpdates)"
rm -rf "$ARCHIVE_PATH"
mkdir -p build/ios/archive

xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  archive

echo ""
echo "Archive OK : $ARCHIVE_PATH"
echo ">> Export IPA : ./tool/export_ios_ipa_from_archive.sh"
