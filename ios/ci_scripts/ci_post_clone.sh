#!/bin/sh

# Xcode Cloud — après clone : Flutter + dépendances + CocoaPods.
# https://docs.flutter.dev/deployment/cd#xcode-cloud
# Ne pas lancer "flutter build ios" ici (réservé à ci_pre_xcodebuild.sh).

set -e
set -x

ROOT="${CI_PRIMARY_REPOSITORY_PATH:-${CI_WORKSPACE:-.}}"
cd "$ROOT" || exit 1

echo ">> Repo: $ROOT"

echo ">> Flutter SDK"
if [ ! -x "$HOME/flutter/bin/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter precache --ios

echo ">> flutter pub get"
flutter pub get

echo ">> flutter gen-l10n"
flutter gen-l10n

echo ">> CocoaPods"
export HOMEBREW_NO_AUTO_UPDATE=1
if ! command -v pod >/dev/null 2>&1; then
  brew install cocoapods
fi

cd ios
pod install
cd "$ROOT"

echo ">> ci_post_clone terminé"
exit 0
