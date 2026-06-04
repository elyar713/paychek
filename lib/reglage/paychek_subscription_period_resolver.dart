/// Résolution de la fin d’abonnement affichée (Play / Firestore).
library;

DateTime? paychekInferPlayBillingPeriodEndUtc({
  required String? productId,
  required DateTime proSinceUtc,
}) {
  final id = productId?.trim().toLowerCase() ?? '';
  if (id.isEmpty) return null;
  final s = proSinceUtc.toUtc();
  if (id.contains('annual')) {
    return DateTime.utc(s.year + 1, s.month, s.day, s.hour, s.minute, s.second,
        s.millisecond, s.microsecond);
  }
  if (id.contains('quarterly')) {
    return DateTime.utc(s.year, s.month + 3, s.day, s.hour, s.minute, s.second,
        s.millisecond, s.microsecond);
  }
  return DateTime.utc(s.year, s.month + 1, s.day, s.hour, s.minute, s.second,
      s.millisecond, s.microsecond);
}

/// Évite d’afficher la fin d’essai (7 j) à la place de la vraie échéance Play.
///
/// Ne prolonge jamais une échéance **déjà passée** (sandbox expiré, sync inactive).
DateTime? paychekResolveStoredSubscriptionPeriodEndUtc({
  DateTime? periodEndUtc,
  DateTime? proSinceUtc,
  String? storeProductId,
  DateTime? trialEndUtc,
  bool storeEntitlementActive = true,
}) {
  final nowUtc = DateTime.now().toUtc();

  if (!storeEntitlementActive) {
    if (periodEndUtc != null && !periodEndUtc.isAfter(nowUtc)) {
      return periodEndUtc;
    }
    return periodEndUtc;
  }

  DateTime? resolved = periodEndUtc;

  // Échéance passée sur paychek_users (fin d’essai) alors qu’un IAP Apple/Play est actif.
  if (resolved != null &&
      !resolved.isAfter(nowUtc) &&
      proSinceUtc != null &&
      !resolved.isAfter(proSinceUtc.subtract(const Duration(hours: 2)))) {
    resolved = null;
  } else if (resolved != null && !resolved.isAfter(nowUtc)) {
    return resolved;
  }

  // Ancienne échéance d’essai (7 j) encore sur paychek_users — ignorer si achat IAP plus récent.
  if (resolved != null &&
      proSinceUtc != null &&
      !resolved.isAfter(proSinceUtc.subtract(const Duration(hours: 2)))) {
    resolved = null;
  }

  if (resolved != null && trialEndUtc != null) {
    final margin = const Duration(hours: 36);
    if (!resolved.isAfter(trialEndUtc.add(margin))) {
      resolved = null;
    }
  }

  if (resolved != null && !resolved.isAfter(nowUtc)) {
    return resolved;
  }

  if (proSinceUtc != null) {
    final inferred = paychekInferPlayBillingPeriodEndUtc(
      productId: storeProductId,
      proSinceUtc: proSinceUtc,
    );
    if (inferred != null && inferred.isAfter(nowUtc)) {
      final suspicious = resolved == null ||
          resolved.isBefore(proSinceUtc.add(const Duration(days: 20)));
      if (suspicious) {
        resolved = resolved == null
            ? inferred
            : (inferred.isAfter(resolved) ? inferred : resolved);
      }
    }
  }

  return resolved;
}
