import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

/// JWS StoreKit 2 (trois segments base64url, en-tête `eyJ`).
bool paychekLooksLikeAppleTransactionJws(String value) {
  final t = value.trim();
  if (t.length < 32) return false;
  final parts = t.split('.');
  if (parts.length != 3) return false;
  return parts.first.startsWith('eyJ');
}

/// Extrait le JWS transaction depuis [PurchaseDetails] (StoreKit 2 prioritaire).
String paychekExtractAppleTransactionJws(PurchaseDetails purchase) {
  final server = purchase.verificationData.serverVerificationData.trim();
  if (paychekLooksLikeAppleTransactionJws(server)) return server;

  if (purchase is SK2PurchaseDetails) {
    final local = purchase.verificationData.localVerificationData.trim();
    if (paychekLooksLikeAppleTransactionJws(local)) return local;
    return server.isNotEmpty ? server : local;
  }

  // StoreKit 1 : reçu App Store (base64), pas un JWS — ne pas l’envoyer au validateur SK2.
  return server;
}
