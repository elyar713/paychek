#!/bin/sh

# Xcode Cloud — après clone : installer Flutter, dépendances, CocoaPods.
# https://docs.flutter.dev/deployment/cd#xcode-cloud

set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

echo ">> Flutter SDK"
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

flutter --version
flutter precache --ios

echo ">> flutter pub get"
flutter pub get

echo ">> flutter gen-l10n"
flutter gen-l10n

echo ">> CocoaPods"
export HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods

cd ios
pod install

exit 0
