#!/usr/bin/env bash
# Build IPA Paychek pour App Store (à lancer sur macOS avec Xcode + CocoaPods).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=_paychek_flutter_env.sh
source "$(dirname "$0")/_paychek_flutter_env.sh"
paychek_require_flutter
echo ">> Flutter: $(command -v flutter)"
flutter --version
echo ""

paychek_validate_ios_toolchain() {
  if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "ERROR: xcodebuild introuvable (code 127)." >&2
    echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer" >&2
    exit 127
  fi
  echo ">> Xcode: $(xcodebuild -version | head -1)"
  echo ">> xcode-select: $(xcode-select -p)"
}

paychek_regenerate_ios_flutter_config() {
  echo ">> flutter pub get + config iOS (Generated.xcconfig sur ce Mac)"
  flutter pub get
  set +e
  flutter build ios --config-only --release --no-codesign
  set -e
  local gen="ios/Flutter/Generated.xcconfig"
  if [[ ! -f "$gen" ]]; then
    echo "ERROR: $gen manquant après flutter pub get" >&2
    exit 1
  fi
  local root
  root="$(grep '^FLUTTER_ROOT=' "$gen" | cut -d= -f2- | tr -d '[:space:]')"
  if [[ -z "$root" || ! -d "$root" ]]; then
    echo "ERROR: FLUTTER_ROOT invalide dans $gen : « $root »" >&2
    echo "  Supprime $gen puis relance ce script sur le Mac." >&2
    exit 1
  fi
  if [[ "$root" == *'\'* ]] || [[ "$root" == *':'* ]]; then
    echo "ERROR: FLUTTER_ROOT Windows détecté ($root)." >&2
    echo "  rm ios/Flutter/Generated.xcconfig && flutter pub get" >&2
    exit 1
  fi
  echo ">> FLUTTER_ROOT OK : $root"
}

paychek_validate_ios_toolchain
echo ""

VERSION_LINE="$(grep -E '^version:' pubspec.yaml | head -1 | awk '{print $2}')"
BUILD_NAME="${VERSION_LINE%%+*}"
BUILD_NUMBER="${VERSION_LINE#*+}"
if [[ "$BUILD_NAME" == "$VERSION_LINE" ]]; then
  BUILD_NUMBER="1"
fi

ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"
EXPORT_DIR="build/ios/ipa"
EXPORT_PLIST="ios/ExportOptions.plist"

echo ">> Paychek iOS release"
echo "   Version : $BUILD_NAME (build $BUILD_NUMBER)"
echo "   Notes   : tool/ios_release_notes_${BUILD_NAME}.txt"
echo ""

echo ">> flutter clean (évite objective_c.framework slice simulateur en IPA)"
flutter clean
rm -rf build/native_assets .dart_tool/hooks_runner

paychek_regenerate_ios_flutter_config

echo ">> flutter gen-l10n"
flutter gen-l10n

echo ">> pod install (ios)"
cd ios
pod install
cd ..

export_ipa_with_xcodebuild() {
  echo ">> xcodebuild -exportArchive (secours — contourne flutter export / code 127)"
  if [[ -x "$(dirname "$0")/export_ios_ipa_from_archive.sh" ]]; then
    "$(dirname "$0")/export_ios_ipa_from_archive.sh" "$ARCHIVE_PATH"
    return
  fi
  rm -rf "$EXPORT_DIR"
  mkdir -p "$EXPORT_DIR"
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$EXPORT_PLIST" \
    -allowProvisioningUpdates
}

echo ">> flutter build ipa --release"
set +e
if [[ -f "$EXPORT_PLIST" ]]; then
  flutter build ipa --release \
    --build-name="$BUILD_NAME" \
    --build-number="$BUILD_NUMBER" \
    --export-options-plist="$EXPORT_PLIST"
else
  flutter build ipa --release \
    --build-name="$BUILD_NAME" \
    --build-number="$BUILD_NUMBER"
fi
FLUTTER_IPA_STATUS=$?
set -e

IPA_FILE="$(find "$EXPORT_DIR" -maxdepth 1 -name '*.ipa' 2>/dev/null | head -1 || true)"

if [[ -z "$IPA_FILE" && -d "$ARCHIVE_PATH" ]]; then
  echo ""
  echo "WARN: flutter build ipa a échoué ou IPA absent — export Xcode direct."
  export_ipa_with_xcodebuild
  IPA_FILE="$(find "$EXPORT_DIR" -maxdepth 1 -name '*.ipa' 2>/dev/null | head -1 || true)"
fi

if [[ -z "$IPA_FILE" ]]; then
  echo ""
  echo "ERROR: aucun fichier .ipa dans $EXPORT_DIR"
  echo "  Archive présente : $([ -d "$ARCHIVE_PATH" ] && echo oui || echo non)"
  echo ""
  echo "Plan B — export direct :"
  echo "  ./tool/export_ios_ipa_from_archive.sh"
  echo ""
  echo "Plan C — Xcode Organizer :"
  echo "  open ios/Runner.xcworkspace"
  echo "  Window → Organizer → Archives → Distribute App"
  if [[ "$FLUTTER_IPA_STATUS" -eq 127 ]]; then
    echo ""
    echo "Code 127 = commande introuvable (souvent flutter ou xcodebuild hors PATH)."
    echo "  export PATH=\"\$HOME/flutter/bin:\$PATH\""
    echo "  which flutter xcodebuild"
  fi
  exit 1
fi

echo ""
echo "IPA prêt : $IPA_FILE"
echo "  open $EXPORT_DIR"
echo ""
echo "App Store Connect :"
echo "  1. Créer la version $BUILD_NAME (build $BUILD_NUMBER)"
echo "  2. Coller les notes depuis tool/ios_release_notes_${BUILD_NAME}.txt"
echo "  3. Envoyer l’IPA avec Transporter (app macOS)"
echo ""
if [[ "$FLUTTER_IPA_STATUS" -ne 0 ]]; then
  echo "Note: flutter build ipa a terminé avec code $FLUTTER_IPA_STATUS mais l’IPA a été exportée via xcodebuild."
fi
