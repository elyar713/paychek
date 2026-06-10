part of 'admin_users_page.dart';

extension _AdminProfileStripeGoogle on _PaychekProfileTierStripeSectionState {
  Future<void> _syncGooglePlay() async {
    if (_syncingGooglePlay) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    _profileStripeMutate(() => _syncingGooglePlay = true);
    try {
      final sync = await paychekAdminSyncGooglePlayEntitlement(
        targetUserId: widget.userId,
      );
      if (!snackCtx.mounted) return;
      final emailLabel = widget.userEmail.trim().isEmpty
          ? widget.userId
          : widget.userEmail.trim();
      var endLabel = sync.currentPeriodEndUtc != null
          ? ' Fin Pro (réponse) : ${DateFormat.yMMMd('fr_FR').format(sync.currentPeriodEndUtc!.toLocal())}.'
          : '';
      final fresh = await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.userId)
          .get(const GetOptions(source: Source.server));
      final ent = await FirebaseFirestore.instance
          .collection(kPaychekSubscriberEntitlementsCollection)
          .doc(widget.userId)
          .get(const GetOptions(source: Source.server));
      final d = fresh.data();
      final ed = ent.data();
      if (d != null) {
        final tier = '${d['subscriptionTier'] ?? ''}'.trim();
        final premium = d['isPremium'] == true;
        final pe = paychekParseFirestoreInstantUtc(
          d[kPaychekUserFieldSubscriptionCurrentPeriodEnd],
        );
        final peLabel = pe != null
            ? DateFormat.yMMMd('fr_FR').format(pe.toLocal())
            : '—';
        final entActive = ed?['active'] == true;
        endLabel =
            ' tier=$tier premium=$premium entitlements.active=$entActive'
            ' · Fin Pro : $peLabel.';
      }
      final inactiveDetail = !sync.active
          ? (sync.message?.trim().isNotEmpty == true
              ? sync.message!.trim()
              : (sync.reason == 'expired_or_inactive'
                  ? 'Google Play : abonnement expiré ou inactif.'
                  : (sync.reason?.trim().isNotEmpty == true
                      ? sync.reason!.trim()
                      : 'Google Play : aucun achat enregistré.')))
          : null;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            sync.active
                ? 'Google Play OK — $emailLabel$endLabel'
                : '$inactiveDetail — $emailLabel$endLabel',
          ),
          backgroundColor: sync.active ? null : Colors.orange.shade900,
          duration: Duration(seconds: sync.active ? 6 : 12),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text(
            e.code == 'not-found' || e.code == 'unavailable'
                ? 'Function syncPaychekGooglePlayEntitlement non déployée.'
                : 'Google Play : ${e.message ?? e.code}',
          ),
        ),
      );
    } catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Google Play : $e'),
        ),
      );
    } finally {
      if (mounted) _profileStripeMutate(() => _syncingGooglePlay = false);
    }
  }

}
