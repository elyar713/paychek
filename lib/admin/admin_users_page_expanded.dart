part of 'admin_users_page.dart';

class _UserExpandedDashboard extends StatelessWidget {
  const _UserExpandedDashboard({
    required this.u,
    required this.df,
    required this.scaffoldContext,
  });

  final AdminUserRow u;
  final DateFormat df;
  final BuildContext scaffoldContext;

  static String _shortId(String uid) {
    if (uid.length <= 8) return uid;
    return uid.substring(uid.length - 8);
  }

  @override
  Widget build(BuildContext context) {
    const mpBg = Color(0xFF0A0A0A);
    const mpCard = Color(0xFF121212);
    const mpPanel = Color(0xFF1A1A1A);
    const mpBorder = Color(0xFF1E293B);

    Widget miniLabel(String t) => Text(
          t.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        );

    Widget maquetteField(
      String label,
      String value, {
      Color? valueColor,
      Widget? trailing,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          miniLabel(label),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              ? trailing,
            ],
          ),
        ],
      );
    }

    Widget platformChip(String code, String label) {
      final last = u.lastSeenPlatform.trim().toLowerCase();
      final isLast = last == code;
      final has = u.platformsSeen
          .map((p) => p.trim().toLowerCase())
          .contains(code);
      final on = isLast && has;
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: on ? Colors.white : const Color(0xFF64748B),
          backgroundColor: on
              ? Colors.white.withValues(alpha: 0.05)
              : mpPanel,
          side: BorderSide(
            color: on ? Colors.white.withValues(alpha: 0.35) : mpBorder,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    Widget bigStat(String label, Widget valueWidget, IconData watermark) {
      return Container(
        decoration: BoxDecoration(
          color: mpCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: mpBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: 12,
              top: 12,
              child: Icon(
                watermark,
                size: 56,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DefaultTextStyle(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                    child: valueWidget,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final infoCard = _MaquetteCollapsibleCard(
      title: 'INFORMATIONS',
      leading: Icon(Icons.account_circle_outlined,
          size: 18, color: Colors.blue.shade400),
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: maquetteField(
                  'ID',
                  _shortId(u.id),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: maquetteField(
                  'Dernière synchro profil',
                  u.lastSeenAt != null
                      ? df.format(u.lastSeenAt!.toLocal())
                      : '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          maquetteField(
            'UID',
            u.id,
            trailing: IconButton(
              tooltip: 'Copier',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: u.id));
                if (context.mounted) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(
                      content: Text('UID copié dans le presse-papiers'),
                    ),
                  );
                }
              },
              icon: Icon(Icons.copy_rounded,
                  size: 16, color: const Color(0xFF475569)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: maquetteField(
                  'Nom',
                  _adminUserTableCellDash(u.lastName),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: maquetteField(
                  'Prénom',
                  _adminUserTableCellDash(u.firstName),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          maquetteField(
            'Email',
            u.email,
            trailing: IconButton(
              tooltip: 'Copier',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: u.email));
                if (context.mounted) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(
                      content: Text('Email copié dans le presse-papiers'),
                    ),
                  );
                }
              },
              icon: Icon(Icons.copy_rounded,
                  size: 16, color: const Color(0xFF475569)),
            ),
          ),
          const SizedBox(height: 18),
          _MaquetteAccountDatesBlock(u: u, df: df),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: maquetteField(
                  'Langue',
                  _adminPreferredLanguageDisplay(u.appLanguageCode),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: maquetteField(
                  'Pays',
                  _adminUserTableCellDash(u.country),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          maquetteField(
            'Mode de paiement',
            adminPaymentMethodDisplayLabel(u.paymentMethod),
            valueColor: adminPaymentMethodAccentColor(u.paymentMethod),
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, color: mpBorder),
          const SizedBox(height: 18),
          miniLabel('Plateformes'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              platformChip('android', 'Android'),
              platformChip('ios', 'iOS'),
              platformChip('web', 'Web'),
            ],
          ),
          if (u.lastSeenPlatform.isNotEmpty) ...[
            const SizedBox(height: 12),
            maquetteField(
              'Plateforme (dernière)',
              _adminPlatformLabel(u.lastSeenPlatform),
            ),
          ],
          const SizedBox(height: 18),
          const Divider(height: 1, color: mpBorder),
          const SizedBox(height: 16),
          _AdminPlatformAccessControl(
            userId: u.id,
            webEnabled: u.accessWebEnabled,
            mobileEnabled: u.accessMobileEnabled,
            scaffoldContext: scaffoldContext,
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: mpBorder),
          const SizedBox(height: 16),
          _PaychekProfileTierStripeSection(
            userId: u.id,
            userEmail: u.email,
            initialTier: u.subscriptionTier,
            paymentMethod: u.paymentMethod,
            lastSeenPlatform: u.lastSeenPlatform,
            scaffoldContext: scaffoldContext,
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: mpBorder),
          const SizedBox(height: 16),
          _AdminTrialFreemiumOverrideControl(
            userId: u.id,
            joinedAt: u.joinedAt,
            overrideUntil: u.trialFreemiumOverrideUntil,
            df: df,
            scaffoldContext: scaffoldContext,
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: mpBorder),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: miniLabel('Dernière IP')),
              Text(
                '—',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final importsCard = _MaquetteCollapsibleCard(
      title: 'IMPORTS RÉCENTS',
      leading: Icon(Icons.history_rounded,
          size: 18, color: Colors.amber.shade400),
      initiallyExpanded: true,
      bodyPadding: const EdgeInsets.all(16),
      child: _CsvImportsHistoryFirestore(
        userId: u.id,
        df: df,
      ),
    );

    final billingAccent = adminPaymentMethodAccentColor(u.paymentMethod);
    final billingCard = _MaquetteCollapsibleCard(
      title: adminBillingSectionTitle(u.paymentMethod),
      leading: Icon(Icons.credit_card_rounded,
          size: 18, color: billingAccent),
      initiallyExpanded: true,
      headerTrailing: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dashboard Stripe (stub).')),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF94A3B8),
          side: const BorderSide(color: mpBorder),
          backgroundColor: mpPanel,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Détails Stripe',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
      child: _BillingStripePanel(df: df, user: u),
    );

    final usageSection = _MaquetteCollapsibleCard(
      title: 'SYNTHÈSE',
      leading: const Icon(Icons.insights_rounded,
          size: 18, color: Color(0xFF34D399)),
      initiallyExpanded: true,
      bodyPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: bigStat(
              'Trades',
              Text('${u.importedTrades}'),
              Icons.insights_rounded,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: bigStat(
              'Imports CSV',
              _CsvImportsCountLabel(
                key: ValueKey('csv_import_count_${u.id}'),
                userId: u.id,
              ),
              Icons.download_rounded,
            ),
          ),
        ],
      ),
    );

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 920;
              final rightCol = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  usageSection,
                  const SizedBox(height: 22),
                  _AdminUserTicketsPanel(userId: u.id),
                  const SizedBox(height: 22),
                  _AdminUserSupportOutboundEmailsPanel(user: u),
                  const SizedBox(height: 22),
                  importsCard,
                  const SizedBox(height: 22),
                  billingCard,
                ],
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: infoCard),
                    const SizedBox(width: 22),
                    Expanded(flex: 7, child: rightCol),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  infoCard,
                  const SizedBox(height: 22),
                  rightCol,
                ],
              );
            },
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: mpBg,
        border: Border(
          top: BorderSide(color: mpBorder),
        ),
      ),
      child: body,
    );
  }
}

/// Carte admin « maquette » (#121212) avec en-tête cliquable (repli / dépli).
