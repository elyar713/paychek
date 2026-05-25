#!/bin/sh

# Xcode Cloud — avant xcodebuild : régénère ios/Flutter/Generated.xcconfig.
# Nouvelle session shell : réexporter PATH vers le SDK installé dans ci_post_clone.

set -e

ROOT="${CI_PRIMARY_REPOSITORY_PATH:-${CI_WORKSPACE:-.}}"
cd "$ROOT"

export PATH="$HOME/flutter/bin:$PATH"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter introuvable dans PATH ($PATH)"
  exit 1
fi

echo ">> $(flutter --version | head -1)"

echo ">> flutter pub get"
flutter pub get

echo ">> flutter gen-l10n"
flutter gen-l10n

echo ">> flutter build ios --config-only (sans signature)"
flutter build ios --config-only --no-codesign

echo ">> Generated.xcconfig"
grep -E 'FLUTTER_BUILD_' ios/Flutter/Generated.xcconfig || true

exit 0
