#!/usr/bin/env bash
# Build IPA Paychek pour App Store (à lancer sur macOS avec Xcode + CocoaPods).
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION_LINE="$(grep -E '^version:' pubspec.yaml | head -1 | awk '{print $2}')"
BUILD_NAME="${VERSION_LINE%%+*}"
BUILD_NUMBER="${VERSION_LINE#*+}"
if [[ "$BUILD_NAME" == "$VERSION_LINE" ]]; then
  BUILD_NUMBER="1"
fi

echo ">> Paychek iOS release"
echo "   Version : $BUILD_NAME (build $BUILD_NUMBER)"
echo "   Notes   : tool/ios_release_notes_${BUILD_NAME}.txt"
echo ""

echo ">> flutter pub get"
flutter pub get

echo ">> flutter gen-l10n"
flutter gen-l10n

echo ">> pod install (ios)"
cd ios
pod install
cd ..

echo ">> flutter build ipa --release"
if [[ -f ios/ExportOptions.plist ]]; then
  flutter build ipa --release \
    --build-name="$BUILD_NAME" \
    --build-number="$BUILD_NUMBER" \
    --export-options-plist=ios/ExportOptions.plist
else
  flutter build ipa --release \
    --build-name="$BUILD_NAME" \
    --build-number="$BUILD_NUMBER"
fi

echo ""
echo "IPA prêt : build/ios/ipa/"
echo "  open build/ios/ipa"
echo ""
echo "App Store Connect :"
echo "  1. Créer la version $BUILD_NAME (build $BUILD_NUMBER)"
echo "  2. Coller les notes depuis tool/ios_release_notes_${BUILD_NAME}.txt"
echo "  3. Envoyer l’IPA (Transporter ou Xcode → Distribute App)"
echo ""
echo "Ou Xcode : open ios/Runner.xcworkspace → Product → Archive"
