part of 'admin_users_page.dart';

extension _AdminProfileStripeTier on _PaychekProfileTierStripeSectionState {
  Future<void> _setTier(PaychekSubscriptionTier tier) async {
    if (_saving || tier == _tier) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    _profileStripeMutate(() => _saving = true);
    try {
      DateTime? preservedPeriodEnd;
      if (tier == PaychekSubscriptionTier.lite) {
        try {
          final entSnap = await FirebaseFirestore.instance
              .collection(kPaychekSubscriberEntitlementsCollection)
              .doc(widget.userId)
              .get();
          preservedPeriodEnd = paychekParseFirestoreInstantUtc(
            entSnap.data()?['currentPeriodEnd'],
          );
        } catch (_) {}
        preservedPeriodEnd ??= widget.subscriptionCurrentPeriodEnd;
      }

      await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.userId)
          .set(
        <String, dynamic>{
          'subscriptionTier': tier.firestoreValue,
          'isPremium': tier == PaychekSubscriptionTier.pro,
          'updatedAt': FieldValue.serverTimestamp(),
          kPaychekUserFieldSubscriptionTierUpdatedAt:
              FieldValue.serverTimestamp(),
          if (tier == PaychekSubscriptionTier.pro) ...<String, dynamic>{
            // Ne pas forcer paymentMethod=admin (garder Google/Apple/Stripe).
            kPaychekUserFieldSubscriptionProSinceUtc:
                FieldValue.serverTimestamp(),
          } else ...<String, dynamic>{
            // Keep billing trail + last period end so licence.html can show Expiré + date.
            'subscriptionEndedAt': FieldValue.serverTimestamp(),
            'subscriptionEndReason': 'admin_set_lite',
            if (preservedPeriodEnd != null)
              'subscriptionCurrentPeriodEnd':
                  Timestamp.fromDate(preservedPeriodEnd.toUtc()),
          },
        },
        SetOptions(merge: true),
      );
      try {
        final entRef = FirebaseFirestore.instance
            .collection(kPaychekSubscriberEntitlementsCollection)
            .doc(widget.userId);
        if (tier == PaychekSubscriptionTier.pro) {
          await entRef.set(
            <String, dynamic>{
              'active': true,
              'updatedAt': FieldValue.serverTimestamp(),
              'proSinceUtc': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } else {
          await entRef.set(
            <String, dynamic>{
              'active': false,
              'updatedAt': FieldValue.serverTimestamp(),
              'subscriptionEndedAt': FieldValue.serverTimestamp(),
              'subscriptionEndReason': 'admin_set_lite',
              if (preservedPeriodEnd != null)
                'currentPeriodEnd':
                    Timestamp.fromDate(preservedPeriodEnd.toUtc()),
            },
            SetOptions(merge: true),
          );
        }
      } catch (_) {}
      if (!snackCtx.mounted) return;
      _profileStripeMutate(() => _tier = tier);
      messenger?.showSnackBar(
        SnackBar(content: Text('Plan : ${tier.adminShortLabel}')),
      );
    } catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Échec : $e'),
        ),
      );
    } finally {
      if (mounted) _profileStripeMutate(() => _saving = false);
    }
  }
}
