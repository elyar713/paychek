part of 'admin_users_page.dart';

class _PaychekProfileTierStripeSection extends StatefulWidget {
  const _PaychekProfileTierStripeSection({
    required this.userId,
    required this.userEmail,
    required this.initialTier,
    required this.paymentMethod,
    required this.lastSeenPlatform,
    this.subscriptionCurrentPeriodEnd,
    required this.scaffoldContext,
  });

  final String userId;
  final String userEmail;
  final PaychekSubscriptionTier initialTier;
  final String paymentMethod;
  final String lastSeenPlatform;
  final DateTime? subscriptionCurrentPeriodEnd;
  final BuildContext scaffoldContext;

  @override
  State<_PaychekProfileTierStripeSection> createState() =>
      _PaychekProfileTierStripeSectionState();
}

class _PaychekProfileTierStripeSectionState
    extends State<_PaychekProfileTierStripeSection> {
  late PaychekSubscriptionTier _tier;
  bool _saving = false;
  bool _syncingStripe = false;
  bool _syncingGooglePlay = false;
  bool _syncingApple = false;
  bool _transferringApple = false;

  void _profileStripeMutate(VoidCallback fn) => setState(fn);

  bool get _showGooglePlaySync {
    final pm = widget.paymentMethod.trim().toLowerCase();
    if (pm == 'google_play' || pm == 'google') return true;
    final plat = widget.lastSeenPlatform.trim().toLowerCase();
    if (plat == 'android') return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _tier = widget.initialTier;
  }

  @override
  void didUpdateWidget(covariant _PaychekProfileTierStripeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTier != widget.initialTier) {
      _tier = widget.initialTier;
    }
  }
  @override
  Widget build(BuildContext context) {
    const mpInner = Color(0xFF1A1A1A);
    const mpBorder = Color(0xFF1E293B);
    final pro = _tier == PaychekSubscriptionTier.pro;
    final busy =
        _syncingStripe || _syncingGooglePlay || _syncingApple || _transferringApple;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ABONNEMENT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: pro
                    ? const Color(0xFF34D399)
                    : const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                pro ? 'PRO' : 'LITE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: pro ? const Color(0xFF0A0A0A) : Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Opacity(
          opacity: _saving ? 0.55 : 1,
          child: AbsorbPointer(
            absorbing: _saving,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: mpInner,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: mpBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _seg(
                    context,
                    label: 'Lite',
                    selected: !pro,
                    onTap: () => _setTier(PaychekSubscriptionTier.lite),
                  ),
                  _seg(
                    context,
                    label: 'Pro',
                    selected: pro,
                    onTap: () => _setTier(PaychekSubscriptionTier.pro),
                    highlight: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _syncLinkButton(
          onPressed: busy ? null : _syncStripe,
          syncing: _syncingStripe,
          icon: Icons.sync_rounded,
          color: const Color(0xFF34D399),
          label: 'Synchroniser paiement Stripe → Pro',
        ),
        if (_showGooglePlaySync) ...[
          const SizedBox(height: 8),
          _syncLinkButton(
            onPressed: busy ? null : _syncGooglePlay,
            syncing: _syncingGooglePlay,
            icon: Icons.shop_rounded,
            color: const Color(0xFF38BDF8),
            label: 'Synchroniser Google Play → Pro',
          ),
        ],
        const SizedBox(height: 8),
        _syncLinkButton(
          onPressed: busy ? null : _syncApple,
          syncing: _syncingApple,
          icon: Icons.apple_rounded,
          color: const Color(0xFFA78BFA),
          label: 'Synchroniser Apple → Pro',
        ),
        const SizedBox(height: 8),
        _syncLinkButton(
          onPressed: busy ? null : () => _showAppleTransferDialog(),
          syncing: _transferringApple,
          icon: Icons.swap_horiz_rounded,
          color: const Color(0xFFF472B6),
          label: 'Transférer abonnement Apple ici',
        ),
      ],
    );
  }

  Widget _seg(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? (highlight
                    ? const Color(0x1A34D399)
                    : Colors.white.withValues(alpha: 0.06))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: selected && highlight
                ? Border.all(color: const Color(0x6634D399))
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected
                  ? (highlight
                      ? const Color(0xFF34D399)
                      : const Color(0xFF94A3B8))
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
