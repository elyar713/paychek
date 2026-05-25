#!/bin/sh

# Xcode Cloud — avant xcodebuild : génère Generated.xcconfig (versions, etc.).

set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

export PATH="$PATH:$HOME/flutter/bin"

echo ">> flutter build ios --config-only"
flutter build ios --config-only --release

exit 0
