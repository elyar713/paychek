part of 'admin_users_page.dart';

class _PaychekUsersTableScrollBody extends StatefulWidget {
  const _PaychekUsersTableScrollBody({
    required this.users,
    required this.df,
    required this.scaffoldContext,
    required this.headerStyle,
    required this.paginationFooter,
  });

  final List<AdminUserRow> users;
  final DateFormat df;
  final BuildContext scaffoldContext;
  final TextStyle? headerStyle;
  final Widget paginationFooter;

  @override
  State<_PaychekUsersTableScrollBody> createState() =>
      _PaychekUsersTableScrollBodyState();
}

class _PaychekUsersTableScrollBodyState
    extends State<_PaychekUsersTableScrollBody> {
  late final ScrollController _hScrollController;
  late final ScrollController _vScrollController;

  static const double _rowMinWidth = 782;

  @override
  void initState() {
    super.initState();
    _hScrollController = ScrollController();
    _vScrollController = ScrollController();
  }

  @override
  void dispose() {
    _hScrollController.dispose();
    _vScrollController.dispose();
    super.dispose();
  }

  static String _namePart(String value) =>
      value.trim().isEmpty ? '—' : value.trim();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < AdminLayout.compactBreakpoint;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                  itemCount: widget.users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, index) {
                    final u = widget.users[index];
                    return _ExpandableUserRow(
                      key: ValueKey<String>(u.id),
                      u: u,
                      df: widget.df,
                      scaffoldContext: widget.scaffoldContext,
                      lnLabel: _namePart(u.lastName),
                      fnLabel: _namePart(u.firstName),
                      compact: true,
                    );
                  },
                ),
              ),
              widget.paginationFooter,
            ],
          );
        }

        final needHScroll = constraints.maxWidth < _rowMinWidth;
        final tableW =
            needHScroll ? _rowMinWidth : constraints.maxWidth;
        return Scrollbar(
          controller: _hScrollController,
          thumbVisibility: needHScroll,
          child: SingleChildScrollView(
            controller: _hScrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableW,
              height: constraints.maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModernUsersTableHeader(style: widget.headerStyle),
                  Expanded(
                    child: Scrollbar(
                      controller: _vScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: ListView.separated(
                        controller: _vScrollController,
                        padding: EdgeInsets.zero,
                        itemCount: widget.users.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          thickness: 1,
                          color: _UsersUi.border.withValues(alpha: 0.55),
                        ),
                        itemBuilder: (ctx, index) {
                          final u = widget.users[index];
                          return _ExpandableUserRow(
                            key: ValueKey<String>(u.id),
                            u: u,
                            df: widget.df,
                            scaffoldContext: widget.scaffoldContext,
                            lnLabel: _namePart(u.lastName),
                            fnLabel: _namePart(u.firstName),
                          );
                        },
                      ),
                    ),
                  ),
                  widget.paginationFooter,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

abstract final class _UmCol {
  static const double padH = 22;
  static const double user = 278;
  static const double details = 152;
  static const double due = 136;
  static const double pay = 124;
  static const double trail = 48;
}

class _ModernUsersTableHeader extends StatelessWidget {
  const _ModernUsersTableHeader({this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final s = style ??
        GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _UsersUi.dim,
          letterSpacing: 1.05,
        );
    Widget cell(String t, double w, [TextAlign align = TextAlign.left]) {
      return SizedBox(
        width: w,
        child: Text(
          t.toUpperCase(),
          textAlign: align,
          style: s,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _UmCol.padH,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: _UsersUi.inputBg,
        border: Border(
          bottom: BorderSide(color: _UsersUi.border.withValues(alpha: 0.65)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          cell('Utilisateur', _UmCol.user),
          cell('Détails', _UmCol.details),
          cell('Échéance', _UmCol.due),
          cell('Paiement', _UmCol.pay),
          SizedBox(width: _UmCol.trail, child: const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _ModernPaymentCell extends StatelessWidget {
  const _ModernPaymentCell({required this.raw});

  final String raw;

  @override
  Widget build(BuildContext context) {
    final t = raw.trim().toLowerCase();
    if (t.isEmpty) {
      return Text(
        '—',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: _UsersUi.dim.withValues(alpha: 0.65),
        ),
      );
    }
    final label = adminPaymentMethodDisplayLabel(raw);
    Color accent = adminPaymentMethodAccentColor(raw);
    Widget? lead;
    if (t == 'stripe') {
      lead = Container(
        width: 22,
        height: 14,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: accent.withValues(alpha: 0.28),
            ),
          ],
        ),
      );
    } else if (t == 'apple' || t == 'apple_iap') {
      lead = Icon(Icons.phone_iphone_rounded, size: 16, color: accent);
    } else if (t == 'google' || t == 'google_play') {
      lead = Icon(Icons.android_rounded, size: 16, color: accent);
    } else if (t == 'admin') {
      lead =
          Icon(Icons.admin_panel_settings_rounded, size: 16, color: accent);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lead != null) ...[
          lead,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModernUserCollapsedCells extends StatelessWidget {
  const _ModernUserCollapsedCells({
    required this.u,
    required this.fnLabel,
    required this.lnLabel,
    required this.trailing,
  });

  final AdminUserRow u;
  final String fnLabel;
  final String lnLabel;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final bodyName = GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.95),
    );
    final bodySmall = GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: _UsersUi.dim,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _UmCol.padH,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _UmCol.user,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _UsersUi.inputBg,
                    border: Border.all(
                      color: _UsersUi.border.withValues(alpha: 0.9),
                    ),
                  ),
                  child: Text(
                    u.subscriptionTier.adminChipLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: u.subscriptionTier == PaychekSubscriptionTier.pro
                          ? const Color(0xFF34D399)
                          : const Color(0xFF60A5FA),
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _UserEngagementDot(u: u),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$fnLabel $lnLabel'.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: bodyName,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.mail_outline_rounded,
                              size: 13, color: _UsersUi.dim),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              u.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: _UmCol.details,
            child: Text(
              _adminPreferredLanguageDisplay(u.appLanguageCode),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          SizedBox(
            width: _UmCol.due,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: _UsersUi.dim),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        DateFormat('dd/MM/yyyy', 'fr_FR').format(
                          paychekAdminDisplayDueDateUtc(u).toLocal(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  paychekAdminTrialDaysRemainingShort(u),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: u.hasPaidPlan
                        ? const Color(0xFF34D399)
                        : _UsersUi.dim,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: _UmCol.pay,
            child: _ModernPaymentCell(raw: u.paymentMethod),
          ),
          SizedBox(width: _UmCol.trail, child: trailing),
        ],
      ),
    );
  }
}

class _MobileUserCollapsedCells extends StatelessWidget {
  const _MobileUserCollapsedCells({
    required this.u,
    required this.fnLabel,
    required this.lnLabel,
    required this.trailing,
  });

  final AdminUserRow u;
  final String fnLabel;
  final String lnLabel;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final bodyName = GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.95),
    );
    final bodySmall = GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: _UsersUi.dim,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _UsersUi.inputBg,
                  border: Border.all(
                    color: _UsersUi.border.withValues(alpha: 0.9),
                  ),
                ),
                child: Text(
                  u.subscriptionTier.adminChipLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: u.subscriptionTier == PaychekSubscriptionTier.pro
                        ? const Color(0xFF34D399)
                        : const Color(0xFF60A5FA),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _UserEngagementDot(u: u),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$fnLabel $lnLabel'.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: bodyName,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      u.email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: bodySmall,
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _metaChip(
                Icons.translate_rounded,
                _adminPreferredLanguageDisplay(u.appLanguageCode),
              ),
              _metaChip(
                Icons.calendar_today_outlined,
                DateFormat('dd/MM/yyyy', 'fr_FR').format(
                  paychekAdminDisplayDueDateUtc(u).toLocal(),
                ),
              ),
              Text(
                paychekAdminTrialDaysRemainingShort(u),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color:
                      u.hasPaidPlan ? const Color(0xFF34D399) : _UsersUi.dim,
                ),
              ),
              _ModernPaymentCell(raw: u.paymentMethod),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _UsersUi.dim),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _ExpandableUserRow extends StatefulWidget {
  const _ExpandableUserRow({
    super.key,
    required this.u,
    required this.df,
    required this.scaffoldContext,
    required this.fnLabel,
    required this.lnLabel,
    this.compact = false,
  });

  final AdminUserRow u;
  final DateFormat df;
  final BuildContext scaffoldContext;
  final String fnLabel;
  final String lnLabel;
  final bool compact;

  @override
  State<_ExpandableUserRow> createState() => _ExpandableUserRowState();
}

class _ExpandableUserRowState extends State<_ExpandableUserRow>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _chevronCtrl;

  @override
  void initState() {
    super.initState();
    _chevronCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      lowerBound: 0,
      upperBound: 0.5,
    );
  }

  @override
  void dispose() {
    _chevronCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _chevronCtrl.forward();
      } else {
        _chevronCtrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final collapsed = widget.compact
        ? _MobileUserCollapsedCells(
            u: widget.u,
            fnLabel: widget.fnLabel,
            lnLabel: widget.lnLabel,
            trailing: RotationTransition(
              turns: _chevronCtrl,
              child: Icon(Icons.expand_more, color: _UsersUi.dim),
            ),
          )
        : _ModernUserCollapsedCells(
            u: widget.u,
            fnLabel: widget.fnLabel,
            lnLabel: widget.lnLabel,
            trailing: RotationTransition(
              turns: _chevronCtrl,
              child: Icon(Icons.expand_more, color: _UsersUi.dim),
            ),
          );

    final shell = Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggle,
            hoverColor: Colors.white.withValues(alpha: 0.035),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _expanded
                    ? _UsersUi.inputBg.withValues(alpha: 0.55)
                    : (widget.compact
                        ? _UsersUi.inputBg.withValues(alpha: 0.35)
                        : Colors.transparent),
                borderRadius:
                    widget.compact ? BorderRadius.circular(12) : null,
                border: widget.compact
                    ? Border.all(
                        color: _UsersUi.border.withValues(alpha: 0.55),
                      )
                    : null,
              ),
              child: collapsed,
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: _expanded
                ? _UserExpandedDashboard(
                    u: widget.u,
                    df: widget.df,
                    scaffoldContext: widget.scaffoldContext,
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );

    return shell;
  }
}

/// Section Abonnement (segment Lite/Pro + sync Stripe) — alignée sur la maquette React.
