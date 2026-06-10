part of 'admin_users_page.dart';

extension _AdminProfileStripeStripe on _PaychekProfileTierStripeSectionState {
  Future<void> _syncStripe() async {
    if (_syncingStripe) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    _profileStripeMutate(() => _syncingStripe = true);
    try {
      final sync = await paychekAdminSyncStripeEntitlement(
        targetUserId: widget.userId,
      );
      if (!snackCtx.mounted) return;
      final emailLabel = widget.userEmail.trim().isEmpty
          ? widget.userId
          : widget.userEmail.trim();
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            sync.active
                ? 'Stripe : paiement trouvé — $emailLabel passé en Pro.'
                : (sync.reason?.trim().isNotEmpty == true
                    ? sync.reason!.trim()
                    : 'Stripe : aucun paiement trouvé pour $emailLabel.'),
          ),
          backgroundColor: sync.active ? null : Colors.orange.shade900,
          duration: Duration(seconds: sync.active ? 4 : 8),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text(
            e.code == 'not-found' || e.code == 'unavailable'
                ? 'Function non déployée ou indisponible.'
                : 'Stripe : ${e.message ?? e.code}',
          ),
        ),
      );
    } catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Stripe : $e'),
        ),
      );
    } finally {
      if (mounted) _profileStripeMutate(() => _syncingStripe = false);
    }
  }

  Widget _syncLinkButton({
    required VoidCallback? onPressed,
    required bool syncing,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: syncing
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
