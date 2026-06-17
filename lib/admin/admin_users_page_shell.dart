part of 'admin_users_page.dart';

class _AdminUsersIntegratedShellHeader extends StatelessWidget {
  const _AdminUsersIntegratedShellHeader({required this.statsBody});

  final Widget statsBody;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final mobile = c.maxWidth < AdminLayout.mobileBreakpoint;
        final padding = AdminLayout.shellHeaderPadding(context);
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AdminTheme.border.withValues(alpha: 0.65),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: mobile
              ? statsBody
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Utilisateurs',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                                letterSpacing: -0.4,
                              ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: statsBody,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

enum _UsersStatsLayout {
  /// Grille responsive (Wrap), pour du contenu pleine largeur sous le titre.
  wrap,

  /// Rangée à droite du titre : 4 colonnes égales (largeur suivant l’espace).
  headerInline,
}

class _UsersStatsRow extends StatelessWidget {
  const _UsersStatsRow({
    required this.total,
    required this.pro,
    required this.signup30,
    required this.stripePro,
    required this.applePro,
    required this.googlePlayPro,
    this.layout = _UsersStatsLayout.wrap,
  });

  final int total;
  final int pro;
  final int signup30;
  final int stripePro;
  final int applePro;
  final int googlePlayPro;
  final _UsersStatsLayout layout;

  static bool _isApplePayment(String pm) {
    final t = pm.trim().toLowerCase();
    return t == 'apple' || t == 'apple_iap';
  }

  static bool _isGooglePlayPayment(String pm) {
    final t = pm.trim().toLowerCase();
    return t == 'google' || t == 'google_play';
  }

  String _fmt(int n) {
    final s = n.toString();
    return s.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = <({
      String label,
      String value,
      IconData icon,
      Color iconColor,
      Color bg
    })>[
      (
        label: 'Utilisateurs totaux',
        value: _fmt(total),
        icon: Icons.groups_rounded,
        iconColor: const Color(0xFF60A5FA),
        bg: const Color(0x331E3A5F),
      ),
      (
        label: 'Comptes Pro',
        value: _fmt(pro),
        icon: Icons.bolt_rounded,
        iconColor: _UsersUi.amber,
        bg: const Color(0x33451A03),
      ),
      (
        label: 'Inscriptions (30 j)',
        value: '+${_fmt(signup30)}',
        icon: Icons.person_search_rounded,
        iconColor: _UsersUi.emerald,
        bg: const Color(0x33064E3B),
      ),
      (
        label: 'Pro · Stripe',
        value: _fmt(stripePro),
        icon: Icons.credit_card_rounded,
        iconColor: const Color(0xFFA78BFA),
        bg: const Color(0x332E1065),
      ),
      (
        label: 'Pro · App Store',
        value: _fmt(applePro),
        icon: Icons.phone_iphone_rounded,
        iconColor: const Color(0xFFE2E8F0),
        bg: const Color(0x33334155),
      ),
      (
        label: 'Pro · Google Play',
        value: _fmt(googlePlayPro),
        icon: Icons.android_rounded,
        iconColor: const Color(0xFF93C5FD),
        bg: const Color(0x331E3A8A),
      ),
    ];

    Widget statTile(
      ({
        String label,
        String value,
        IconData icon,
        Color iconColor,
        Color bg,
      }) e, {
      required bool inline,
      double? headerSlotWidth,
    }) {
      final scaledInline = inline && headerSlotWidth != null;
      final slotScale = scaledInline
          ? ((headerSlotWidth - 88) / 76).clamp(0.0, 1.0)
          : 0.0;

      double hp;
      double vp;
      double iconPadding;
      double iconSize;
      double gapIconText;
      double valueSize;
      double labelSize;

      if (scaledInline) {
        hp = 8 + 6 * slotScale;
        vp = 8 + 4 * slotScale;
        iconPadding = 5 + 2 * slotScale;
        iconSize = 15 + 3 * slotScale;
        gapIconText = 8 + 3 * slotScale;
        valueSize = 14 + 4 * slotScale;
        labelSize = 10 + 2 * slotScale;
      } else if (inline) {
        hp = 8;
        vp = 8;
        iconPadding = 5;
        iconSize = 15;
        gapIconText = 8;
        valueSize = 14;
        labelSize = 10;
      } else {
        hp = 12;
        vp = 10;
        iconPadding = 6;
        iconSize = 17;
        gapIconText = 10;
        valueSize = 17;
        labelSize = 11;
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
        decoration: BoxDecoration(
          color: _UsersUi.panel,
          borderRadius: BorderRadius.circular(scaledInline ? 10 + 2 * slotScale : (inline ? 10 : 12)),
          border: Border.all(
            color: _UsersUi.border.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: e.bg,
                borderRadius: BorderRadius.circular(scaledInline ? 7 + slotScale : (inline ? 7 : 8)),
              ),
              child: Icon(e.icon, size: iconSize, color: e.iconColor),
            ),
            SizedBox(width: gapIconText),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: valueSize,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.35,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: scaledInline ? 1 + slotScale : (inline ? 1 : 2)),
                  Text(
                    e.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: labelSize,
                      fontWeight: FontWeight.w600,
                      color: _UsersUi.dim,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (layout == _UsersStatsLayout.headerInline) {
      const gap = 8.0;
      const count = 4;
      return LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          if (w < AdminLayout.mobileBreakpoint) {
            final cols = w >= 360 ? 2 : 1;
            final gapWrap = 8.0;
            final cardW = cols <= 1 ? w : (w - (cols - 1) * gapWrap) / cols;
            return Wrap(
              spacing: gapWrap,
              runSpacing: gapWrap,
              children: [
                for (final e in entries)
                  SizedBox(
                    width: cardW,
                    child: statTile(e, inline: false),
                  ),
              ],
            );
          }
          final slot =
              ((w - (count - 1) * gap) / count).clamp(72.0, double.infinity);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0) SizedBox(width: gap),
                Expanded(
                  child: statTile(
                    entries[i],
                    inline: true,
                    headerSlotWidth: slot,
                  ),
                ),
              ],
            ],
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 1100
            ? 4
            : w >= 640
                ? 2
                : 1;
        final gap = 10.0;
        final cardW = cols <= 1 ? w : (w - (cols - 1) * gap) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final e in entries)
              SizedBox(
                width: cardW,
                child: statTile(e, inline: false),
              ),
          ],
        );
      },
    );
  }
}

class _UsersTableToolbar extends StatelessWidget {
  const _UsersTableToolbar({
    required this.searchCtrl,
    required this.sort,
    required this.tierQuick,
    required this.onSort,
    required this.onTier,
  });

  final TextEditingController searchCtrl;
  final _UsersSort sort;
  final _TierQuick tierQuick;
  final ValueChanged<_UsersSort> onSort;
  final ValueChanged<_TierQuick> onTier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _UsersUi.border.withValues(alpha: 0.65)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 720;
          final search = TextField(
            controller: searchCtrl,
            scrollPadding: EdgeInsets.zero,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Rechercher par nom, email…',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: _UsersUi.dim,
                fontSize: 13,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: _UsersUi.dim, size: 20),
              filled: true,
              fillColor: _UsersUi.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _UsersUi.border.withValues(alpha: 0.8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _UsersUi.border.withValues(alpha: 0.8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _UsersUi.blue, width: 1.2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
          );
          final filterBtn = PopupMenuButton<_TierQuick>(
            tooltip: 'Filtres',
            color: _UsersUi.inputBg,
            onSelected: onTier,
            itemBuilder: (ctx) => [
              CheckedPopupMenuItem(
                value: _TierQuick.all,
                checked: tierQuick == _TierQuick.all,
                child: Text('Tous les comptes', style: GoogleFonts.plusJakartaSans()),
              ),
              CheckedPopupMenuItem(
                value: _TierQuick.proOnly,
                checked: tierQuick == _TierQuick.proOnly,
                child: Text('Pro uniquement', style: GoogleFonts.plusJakartaSans()),
              ),
              CheckedPopupMenuItem(
                value: _TierQuick.liteOnly,
                checked: tierQuick == _TierQuick.liteOnly,
                child: Text('Lite uniquement', style: GoogleFonts.plusJakartaSans()),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _UsersUi.inputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _UsersUi.border.withValues(alpha: 0.8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_list_rounded, size: 18, color: _UsersUi.muted),
                  const SizedBox(width: 8),
                  Text(
                    'Filtres',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _UsersUi.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
          final sortBtn = PopupMenuButton<_UsersSort>(
            tooltip: 'Tri',
            color: _UsersUi.inputBg,
            onSelected: onSort,
            itemBuilder: (ctx) => [
              for (final s in _UsersSort.values)
                PopupMenuItem(
                  value: s,
                  child: Text(s.menuLabel, style: GoogleFonts.plusJakartaSans()),
                ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _UsersUi.inputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _UsersUi.border.withValues(alpha: 0.8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Trier : ${sort.menuLabel}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _UsersUi.muted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down_rounded, color: _UsersUi.muted, size: 20),
                ],
              ),
            ),
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: filterBtn),
                    const SizedBox(width: 10),
                    Expanded(child: sortBtn),
                  ],
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: search),
              const SizedBox(width: 12),
              filterBtn,
              const SizedBox(width: 10),
              sortBtn,
            ],
          );
        },
      ),
    );
  }
}

class _UsersPaginationFooter extends StatelessWidget {
  const _UsersPaginationFooter({
    required this.fromItem,
    required this.toItem,
    required this.totalFiltered,
    required this.pageIndex,
    required this.pageCount,
    required this.onPrev,
    required this.onNext,
    required this.onExportCsv,
  });

  final int fromItem;
  final int toItem;
  final int totalFiltered;
  final int pageIndex;
  final int pageCount;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onExportCsv;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _UsersUi.inputBg,
        border: Border(
          top: BorderSide(color: _UsersUi.border.withValues(alpha: 0.65)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 520;
          final textStyle = GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: _UsersUi.dim,
          );
          final csvBtn = TextButton.icon(
            onPressed: onExportCsv,
            icon: Icon(
              Icons.download_rounded,
              size: 15,
              color: _UsersUi.muted,
            ),
            label: Text(
              'CSV',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _UsersUi.muted,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: _UsersUi.muted,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
          final summary = Text.rich(
            TextSpan(
              style: textStyle,
              children: [
                const TextSpan(text: 'Affichage '),
                TextSpan(
                  text: '$fromItem',
                  style: textStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' à '),
                TextSpan(
                  text: '$toItem',
                  style: textStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' sur '),
                TextSpan(
                  text: '$totalFiltered',
                  style: textStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
          Widget btn(String label, VoidCallback? onTap, {bool primary = false}) {
            return OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    primary ? Colors.white : _UsersUi.muted,
                backgroundColor: primary ? _UsersUi.blue : _UsersUi.panel,
                side: BorderSide(
                  color: primary ? _UsersUi.blue : _UsersUi.border,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12)),
            );
          }

          final pager = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              btn('Précédent', onPrev),
              const SizedBox(width: 8),
              btn('${pageIndex + 1} / $pageCount', null, primary: true),
              const SizedBox(width: 8),
              btn('Suivant', onNext),
            ],
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                Align(
                  alignment: Alignment.centerLeft,
                  child: csvBtn,
                ),
                const SizedBox(height: 12),
                pager,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    summary,
                    csvBtn,
                  ],
                ),
              ),
              pager,
            ],
          );
        },
      ),
    );
  }
}
