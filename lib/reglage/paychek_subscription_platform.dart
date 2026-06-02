import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

import '../l10n/app_localizations.dart';
import 'paychek_apple_iap_service.dart';

/// App iOS native (StoreKit) — pas le site web dans Safari.
bool get paychekUsesNativeAppleIap => PaychekAppleIapService.isSupported;

/// Paychek ouvert dans Safari / Chrome sur iPhone (build web).
bool get paychekIsIosWeb =>
    kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Pied de page paywall selon la plateforme.
String paychekPaywallLegalFooterLabel(AppLocalizations l) {
  if (paychekUsesNativeAppleIap) {
    return l.paywallLegalFooterApple;
  }
  if (paychekIsIosWeb) {
    return l.paywallIosWebRequiresNativeApp;
  }
  return l.paywallLegalFooter;
}
