part of 'admin_users_page.dart';

extension _AdminProfileStripeTier on _PaychekProfileTierStripeSectionState {
  Future<void> _setTier(PaychekSubscriptionTier tier) async {
    if (_saving || tier == _tier) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    _profileStripeMutate(() => _saving = true);
    try {
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
            'paymentMethod': 'admin',
            kPaychekUserFieldSubscriptionProSinceUtc:
                FieldValue.serverTimestamp(),
          } else ...<String, dynamic>{
            'paymentMethod': FieldValue.delete(),
            kPaychekUserFieldSubscriptionCurrentPeriodEnd:
                FieldValue.delete(),
            kPaychekUserFieldSubscriptionProSinceUtc: FieldValue.delete(),
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
              'provider': 'admin',
              'updatedAt': FieldValue.serverTimestamp(),
              'proSinceUtc': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } else {
          await entRef.set(
            <String, dynamic>{
              'active': false,
              'provider': 'admin',
              'updatedAt': FieldValue.serverTimestamp(),
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
