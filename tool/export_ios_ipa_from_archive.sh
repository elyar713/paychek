#!/usr/bin/env bash
# Exporte un .ipa depuis une archive déjà créée (secours si flutter build ipa → code 127).
set -euo pipefail
cd "$(dirname "$0")/.."

ARCHIVE_PATH="${1:-build/ios/archive/Runner.xcarchive}"
EXPORT_DIR="build/ios/ipa"
EXPORT_PLIST="ios/ExportOptions.plist"

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

echo ">> xcodebuild -exportArchive"
echo "   Archive : $ARCHIVE_PATH"
echo "   Export  : $EXPORT_DIR"
rm -rf "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR"

if [[ -f "$EXPORT_PLIST" ]]; then
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$EXPORT_PLIST"
else
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportMethod app-store-connect
fi

IPA_FILE="$(find "$EXPORT_DIR" -maxdepth 1 -name '*.ipa' 2>/dev/null | head -1 || true)"
if [[ -z "$IPA_FILE" ]]; then
  echo "ERROR: aucun .ipa dans $EXPORT_DIR" >&2
  exit 1
fi

echo ""
echo "IPA prêt : $IPA_FILE"
echo "  open $EXPORT_DIR"
