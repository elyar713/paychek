part of 'admin_users_page.dart';

extension _AdminProfileStripeApple on _PaychekProfileTierStripeSectionState {
  Future<void> _showAppleTransferDialog({
    List<PaychekAppleTransferCandidate>? initialCandidates,
  }) async {
    if (_transferringApple || _syncingApple) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    final targetEmail = widget.userEmail.trim().isEmpty
        ? widget.userId
        : widget.userEmail.trim();

    List<PaychekAppleTransferCandidate> candidates =
        initialCandidates ?? const [];
    if (candidates.isEmpty) {
      _profileStripeMutate(() => _transferringApple = true);
      try {
        candidates = await paychekAdminListAppleTransferCandidates(
          excludeUserId: widget.userId,
        );
      } catch (e) {
        if (snackCtx.mounted) {
          messenger?.showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade900,
              content: Text('Impossible de lister les comptes Apple : $e'),
            ),
          );
        }
        return;
      } finally {
        if (mounted) _profileStripeMutate(() => _transferringApple = false);
      }
    }

    if (!snackCtx.mounted) return;
    if (candidates.isEmpty) {
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'Aucun autre compte Paychek avec abonnement Apple actif.',
          ),
        ),
      );
      return;
    }

    final selected = await showDialog<PaychekAppleTransferCandidate>(
      context: snackCtx,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121212),
          title: Text(
            'Transférer abonnement Apple',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vers $targetEmail — choisis le compte source :',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 12),
                ...candidates.map((c) {
                  final end = c.currentPeriodEndUtc;
                  final endLabel = end != null
                      ? DateFormat.yMMMd('fr_FR').format(end.toLocal())
                      : null;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      c.maskedEmail,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      [
                        if (c.appleProductId?.isNotEmpty == true)
                          c.appleProductId!,
                        if (endLabel != null) 'Fin Pro : $endLabel',
                      ].join(' · '),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    onTap: () => Navigator.of(ctx).pop(c),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );

    if (selected == null) return;
    await _runAppleTransfer(fromUid: selected.uid);
  }

  Future<void> _runAppleTransfer({required String fromUid}) async {
    if (_transferringApple || _syncingApple) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    _profileStripeMutate(() => _transferringApple = true);
    try {
      final sync = await paychekAdminSyncAppleEntitlement(
        targetUserId: widget.userId,
        transferFromUid: fromUid,
      );
      if (!snackCtx.mounted) return;
      if (sync.active) {
        _profileStripeMutate(() => _tier = PaychekSubscriptionTier.pro);
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              sync.message?.trim().isNotEmpty == true
                  ? sync.message!.trim()
                  : 'Abonnement Apple transféré — ${widget.userEmail.trim().isEmpty ? widget.userId : widget.userEmail.trim()}',
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      } else {
        messenger?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange.shade900,
            content: Text(
              sync.message?.trim().isNotEmpty == true
                  ? sync.message!.trim()
                  : 'Transfert Apple incomplet.',
            ),
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Transfert Apple : ${e.message ?? e.code}'),
        ),
      );
    } catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Transfert Apple : $e'),
        ),
      );
    } finally {
      if (mounted) _profileStripeMutate(() => _transferringApple = false);
    }
  }

  Future<void> _syncApple() async {
    if (_syncingApple) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    _profileStripeMutate(() => _syncingApple = true);
    try {
      final sync = await paychekAdminSyncAppleEntitlement(
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
                  ? 'Apple : abonnement expiré ou inactif.'
                  : (sync.reason?.trim().isNotEmpty == true
                      ? sync.reason!.trim()
                      : 'Apple : aucun achat enregistré.')))
          : null;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            sync.active
                ? 'Apple OK — $emailLabel$endLabel'
                : '$inactiveDetail — $emailLabel$endLabel',
          ),
          backgroundColor: sync.active ? null : Colors.orange.shade900,
          duration: Duration(seconds: sync.active ? 6 : 12),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!snackCtx.mounted) return;
      if (e.code == 'failed-precondition') {
        var candidates = paychekAppleTransferCandidatesFromDetails(e.details);
        if (candidates.isEmpty) {
          try {
            candidates = await paychekAdminListAppleTransferCandidates(
              excludeUserId: widget.userId,
            );
          } catch (_) {
            // Liste via API en secours si e.details absent (web).
          }
        }
        if (candidates.isNotEmpty) {
          unawaited(
            _showAppleTransferDialog(initialCandidates: candidates),
          );
        } else {
          messenger?.showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange.shade900,
              duration: const Duration(seconds: 14),
              content: Text('Apple : ${e.message ?? e.code}'),
            ),
          );
        }
        return;
      }
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text(
            e.code == 'not-found' || e.code == 'unavailable'
                ? 'Function syncPaychekAppleEntitlement non déployée.'
                : 'Apple : ${e.message ?? e.code}',
          ),
        ),
      );
    } catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Apple : $e'),
        ),
      );
    } finally {
      if (mounted) _profileStripeMutate(() => _syncingApple = false);
    }
  }
}
