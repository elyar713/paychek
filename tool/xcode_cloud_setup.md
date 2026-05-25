# Xcode Cloud — Paychek

## Pourquoi les builds échouaient

Sans `ios/ci_scripts/`, Xcode Cloud ne lance pas `flutter pub get`, `pod install` ni `gen-l10n` → erreurs de build (souvent ~5).

## Scripts ajoutés

- `ios/ci_scripts/ci_post_clone.sh` — Flutter + pub get + gen-l10n + pod install
- `ios/ci_scripts/ci_pre_xcodebuild.sh` — `flutter build ios --config-only --no-codesign` (réexporte `$HOME/flutter/bin`)

## Après `git pull` sur le Mac

```bash
git add --chmod=+x ios/ci_scripts/ci_post_clone.sh ios/ci_scripts/ci_pre_xcodebuild.sh
git commit -m "Ajoute scripts Xcode Cloud pour builds Flutter iOS."
git push origin main
```

Puis App Store Connect → Xcode Cloud → **Lancer le build**.

## Voir les erreurs d’un build raté

1. Cliquer sur le build (ex. Build 10)
2. Onglet **Logs** / étapes (Archive, etc.)
3. Lire la première erreur rouge

## TestFlight

Quand le build est **Réussi** (coche verte) :

1. Onglet **TestFlight** (pas Xcode Cloud)
2. Build **Ready to Test**
3. Testeurs internes → installer via l’app **TestFlight** sur iPhone
