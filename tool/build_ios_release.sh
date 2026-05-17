#!/usr/bin/env bash
# Build IPA Paychek pour App Store (à lancer sur macOS avec Xcode + CocoaPods).
set -euo pipefail
cd "$(dirname "$0")/.."

echo ">> flutter pub get"
flutter pub get

echo ">> pod install (ios)"
cd ios
pod install
cd ..

echo ">> flutter build ipa --release"
flutter build ipa --release

echo ""
echo "IPA prêt. Ouvrir pour distribution :"
echo "  open build/ios/ipa"
echo ""
echo "Ou Xcode : Runner.xcworkspace → Product → Archive → Distribute App"
