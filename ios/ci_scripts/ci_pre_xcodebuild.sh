#!/bin/sh

# Xcode Cloud — avant Archive : config Flutter + compilation release (sans signature).
# Si cette étape échoue, le log est plus clair que dans "Archive - iOS".

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

echo ">> Génération config iOS"
set +e
flutter build ios --config-only --no-codesign
cfg_status=$?
set -e
if [ "$cfg_status" -ne 0 ]; then
  echo "WARN: config-only ($cfg_status), on continue"
fi

test -f ios/Flutter/Generated.xcconfig || {
  echo "ERROR: ios/Flutter/Generated.xcconfig manquant"
  exit 1
}
grep -E 'FLUTTER_(ROOT|BUILD_)' ios/Flutter/Generated.xcconfig || true

echo ">> Compilation release (no-codesign) — détecte erreurs Dart avant Archive"
flutter build ios --release --no-codesign

echo ">> ci_pre_xcodebuild terminé"
exit 0
