#!/bin/sh

# Xcode Cloud — avant xcodebuild : ios/Flutter/Generated.xcconfig (versions).

set -e
set -x

ROOT="${CI_PRIMARY_REPOSITORY_PATH:-${CI_WORKSPACE:-.}}"
cd "$ROOT" || exit 1

export PATH="$HOME/flutter/bin:$PATH"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter introuvable. ci_post_clone a-t-il réussi ?"
  exit 1
fi

flutter --version

flutter pub get
flutter gen-l10n

echo ">> flutter build ios --config-only"
set +e
flutter build ios --config-only --no-codesign
status=$?
set -e
if [ "$status" -ne 0 ]; then
  echo "WARN: config-only + --no-codesign a échoué ($status), retry sans --no-codesign"
  flutter build ios --config-only
fi

test -f ios/Flutter/Generated.xcconfig || {
  echo "ERROR: ios/Flutter/Generated.xcconfig manquant"
  exit 1
}

grep -E 'FLUTTER_BUILD_' ios/Flutter/Generated.xcconfig || true

echo ">> ci_pre_xcodebuild terminé"
exit 0
