part of 'admin_users_page.dart';

/// Inscription, essai, achat Pro et fin Pro — valeurs lisibles (sans sous-texte gris).
class _MaquetteAccountDatesBlock extends StatefulWidget {
  const _MaquetteAccountDatesBlock({
    required this.u,
    required this.df,
  });

  final AdminUserRow u;
  final DateFormat df;

  @override
  State<_MaquetteAccountDatesBlock> createState() =>
      _MaquetteAccountDatesBlockState();
}

class _MaquetteAccountDatesBlockState extends State<_MaquetteAccountDatesBlock> {
  bool _syncingPlay = false;

  bool _isGooglePlayPayment(AdminUserRow u) {
    final m = u.paymentMethod.trim().toLowerCase();
    return m == 'google_play' || m == 'google';
  }

  Future<void> _resyncGooglePlayDates() async {
    setState(() => _syncingPlay = true);
    try {
      final r = await paychekAdminSyncGooglePlayEntitlement(
        targetUserId: widget.u.id,
      );
      if (!mounted) return;
      if (r.active && r.currentPeriodEndUtc != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dates Google Play mises à jour (${widget.df.format(r.currentPeriodEndUtc!.toLocal())})',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              r.reason ?? 'Sync Google Play : abonnement inactif ou introuvable.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync Google Play échouée : $e')),
      );
    } finally {
      if (mounted) setState(() => _syncingPlay = false);
    }
  }

  DateFormat get df => widget.df;

  static const Color _panel = Color(0xFF1A1A1A);
  static const Color _border = Color(0xFF1E293B);
  static const Color _value = Color(0xFFE2E8F0);
  static const Color _label = Color(0xFF64748B);
  static const Color _finPro = Color(0xFF34D399);

  Widget _mini(String t) => Text(
        t.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: _label,
          letterSpacing: 0.55,
        ),
      );

  Widget _pair(
    String label,
    String value, {
    Color valueColor = _value,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _mini(label),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ),
            ? trailing,
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: db.collection(kPaychekUsersCollection).doc(widget.u.id).snapshots(),
      builder: (context, userSnap) {
        var base = widget.u;
        if (userSnap.hasData && userSnap.data!.exists) {
          base = adminUserRowFromFirestore(userSnap.data!);
        }
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: db
              .collection(kPaychekSubscriberEntitlementsCollection)
              .doc(widget.u.id)
              .snapshots(),
          builder: (context, entSnap) {
            final u = adminUserRowMergeEntitlementData(
              base,
              entSnap.data?.data(),
            );
            return _buildChrono(context, u);
          },
        );
      },
    );
  }

  Widget _buildChrono(BuildContext context, AdminUserRow u) {
    final inscription = df.format(u.joinedAt.toLocal());

    final trialEndUtc = u.trialFreemiumOverrideUntil ??
        u.joinedAt.toUtc().add(kPaychekTrialDuration);
    final trialEndLabel = df.format(trialEndUtc.toLocal());

    final nowUtc = DateTime.now().toUtc();
    final trialNotExpired = nowUtc.isBefore(trialEndUtc);
    final tierPro = u.hasEffectiveProAccess;

    final proSinceUtc = u.subscriptionProSinceUtc;
    final anchor = proSinceUtc ?? u.subscriptionTierUpdatedAt;
    final periodEndUtc = paychekResolveStoredSubscriptionPeriodEndUtc(
      periodEndUtc: u.subscriptionCurrentPeriodEnd,
      proSinceUtc: anchor,
      storeProductId: u.googlePlayProductId,
      trialEndUtc: trialEndUtc,
    );
    final showProDates = tierPro ||
        periodEndUtc != null ||
        proSinceUtc != null;
    final finProUtc = TrialAccessPrefs.proSubscriptionAdminEndUtc(
      proSinceUtc: anchor,
      subscriptionPeriodEndUtc: periodEndUtc,
    );
    final achatUtc = proSinceUtc ?? u.subscriptionTierUpdatedAt;
    final achatLabel =
        achatUtc != null ? df.format(achatUtc.toLocal()) : '—';
    final finLabel =
        finProUtc != null ? df.format(finProUtc.toLocal()) : '—';

    Widget? trialChip() {
      if (tierPro) return null;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: trialNotExpired
              ? const Color(0x1A34D399)
              : const Color(0x26F59E0B),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: trialNotExpired
                ? const Color(0x4434D399)
                : const Color(0x44F59E0B),
          ),
        ),
        child: Text(
          trialNotExpired ? 'ESSAI ACTIF' : 'ESSAI TERMINÉ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: trialNotExpired
                ? const Color(0xFF34D399)
                : const Color(0xFFFBBF24),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  size: 18, color: Color(0xFF38BDF8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CHRONOLOGIE DU COMPTE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: _value,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _pair('Inscription', inscription)),
              if (!tierPro) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _pair(
                    'Fin d’essai (accès plein)',
                    trialEndLabel,
                    trailing: trialChip(),
                  ),
                ),
              ],
            ],
          ),
          if (showProDates) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _pair('Pro depuis', achatLabel)),
                const SizedBox(width: 16),
                Expanded(
                  child: _pair(
                    'Fin Pro (abonnement)',
                    finLabel,
                    valueColor:
                        finProUtc != null ? _finPro : _value,
                    trailing: tierPro && _isGooglePlayPayment(u)
                        ? IconButton(
                            tooltip: 'Resync dates Google Play',
                            onPressed: _syncingPlay ? null : _resyncGooglePlayDates,
                            icon: _syncingPlay
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.sync, size: 20),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
