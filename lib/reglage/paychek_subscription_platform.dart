import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

import '../l10n/app_localizations.dart';
import 'paychek_apple_iap_service.dart';
import 'paychek_google_play_iap_service.dart';

/// App iOS native (StoreKit) — pas le site web dans Safari.
bool get paychekUsesNativeAppleIap => PaychekAppleIapService.isSupported;

/// App Android native (Google Play Billing).
bool get paychekUsesNativeGooglePlayIap =>
    PaychekGooglePlayIapService.isSupported;

/// App Store ou Play (pas Stripe in-app).
bool get paychekUsesNativeStoreIap =>
    paychekUsesNativeAppleIap || paychekUsesNativeGooglePlayIap;

/// Paychek ouvert dans Safari / Chrome sur iPhone (build web).
bool get paychekIsIosWeb =>
    kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Pied de page paywall selon la plateforme.
String paychekPaywallLegalFooterLabel(AppLocalizations l) {
  if (paychekUsesNativeAppleIap) {
    return l.paywallLegalFooterApple;
  }
  if (paychekUsesNativeGooglePlayIap) {
    return l.paywallLegalFooterGooglePlay;
  }
  if (paychekIsIosWeb) {
    return l.paywallIosWebRequiresNativeApp;
  }
  return l.paywallLegalFooter;
}
