import 'dart:async' show unawaited;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../ajouter_trade/ajouter_trade_csv_section.dart';
import '../reglage/paychek_csv_import_log.dart';
import '../reglage/paychek_support_ticket_submit.dart';
import '../reglage/paychek_user_firestore.dart';
import '../reglage/trial_access_prefs.dart';
import 'admin_firestore_users.dart';
import 'admin_models.dart';
import 'admin_stripe_entitlement_sync.dart';
import 'admin_stripe_refund.dart';
import 'admin_user_billing_summary.dart';
import 'admin_support_ticket_detail_page.dart';
import 'admin_theme.dart';
import 'admin_user_engagement.dart';

/// Palette maquette « Utilisateurs » (React/Tailwind sombre).
abstract final class _UsersUi {
  _UsersUi._();

  static const Color canvas = Color(0xFF0A0A0A);
  static const Color panel = Color(0xFF121212);
  static const Color inputBg = Color(0xFF1A1A1A);
  static const Color border = Color(0xFF1E293B);
  static const Color muted = Color(0xFF94A3B8);
  static const Color dim = Color(0xFF64748B);
  static const Color blue = Color(0xFF2563EB);
  static const Color emerald = Color(0xFF34D399);
  static const Color amber = Color(0xFFF59E0B);
}

enum _UsersSort {
  activityRecent,
  joinedRecent,
  emailAz,
}

enum _TierQuick { all, proOnly, liteOnly }

extension _UsersSortLabel on _UsersSort {
  String get menuLabel => switch (this) {
        _UsersSort.activityRecent => 'Activité récente',
        _UsersSort.joinedRecent => 'Inscription récente',
        _UsersSort.emailAz => 'Email (A→Z)',
      };
}

String _adminCsvEscape(String s) {
  final t = s.replaceAll('"', '""');
  if (t.contains(';') || t.contains('\n') || t.contains('\r')) {
    return '"$t"';
  }
  return t;
}

Future<void> _adminExportUsersCsv(
    BuildContext context, List<AdminUserRow> users) async {
  final dfIso = DateFormat('yyyy-MM-dd');
  final sb = StringBuffer();
  sb.writeln(
    'nom;prenom;email;langue;naissance;compte;fin_essai;jours_essai;'
    'actif_7j;inscription;paiement',
  );
  for (final u in users) {
    final led = paychekAdminEngagementLed(u);
    final actLabel = switch (led) {
      AdminEngagementLed.green => 'Actif',
      AdminEngagementLed.orange => 'Peu actif',
      AdminEngagementLed.red => 'Inactif',
    };
    sb.writeln([
      _adminCsvEscape(u.lastName.trim()),
      _adminCsvEscape(u.firstName.trim()),
      _adminCsvEscape(u.email),
      _adminCsvEscape(_adminPreferredLanguageDisplay(u.appLanguageCode)),
      _adminCsvEscape(_adminBirthDateLabel(u.birthDate)),
      _adminCsvEscape(_adminAccountTierTableLabel(u.subscriptionTier)),
      _adminCsvEscape(
        DateFormat('dd/MM/yyyy').format(
          paychekAdminEffectiveTrialEndUtc(u).toLocal(),
        ),
      ),
      _adminCsvEscape(paychekAdminTrialDaysRemainingShort(u)),
      _adminCsvEscape(actLabel),
      _adminCsvEscape(dfIso.format(u.joinedAt.toLocal())),
      _adminCsvEscape(_adminPaymentMethodDisplay(u.paymentMethod)),
    ].join(';'));
  }
  await Clipboard.setData(ClipboardData(text: sb.toString()));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'CSV (${users.length} lignes) copié dans le presse-papiers.',
          style: GoogleFonts.plusJakartaSans(),
        ),
      ),
    );
  }
}

String _adminUserTableCellDash(String value) =>
    value.trim().isEmpty ? '—' : value.trim();

/// Affiche `birthDate` Firestore comme jour civil (composantes UTC du timestamp).
String _adminBirthDateLabel(DateTime? bd) {
  if (bd == null) return '—';
  final d = bd.isUtc ? bd : bd.toUtc();
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day/$month/${d.year}';
}

/// Libellé console admin pour [AdminUserRow.appLanguageCode].
String _adminPreferredLanguageDisplay(String rawCode) {
  final code = rawCode.trim().toLowerCase();
  if (code.isEmpty) return '—';
  switch (code) {
    case 'fr':
      return 'FR · Français';
    case 'en':
      return 'EN · English';
    case 'es':
      return 'ES · Español';
    case 'de':
      return 'DE · Deutsch';
    case 'ko':
      return 'KO · 한국어';
    case 'pt':
      return 'PT · Português';
    default:
      return code.toUpperCase();
  }
}

String _adminAccountTierTableLabel(PaychekSubscriptionTier tier) =>
    switch (tier) {
      PaychekSubscriptionTier.lite => 'Lite',
      PaychekSubscriptionTier.pro => 'Pro',
    };

String _adminPaymentMethodDisplay(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '—';
  switch (t.toLowerCase()) {
    case 'stripe':
      return 'Stripe';
    case 'apple':
    case 'apple_iap':
      return 'Apple';
    case 'google':
    case 'google_play':
      return 'Google Play';
    case 'admin':
      return 'Admin';
    default:
      return t;
  }
}

String _adminPlatformLabel(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'web':
      return 'Web';
    case 'android':
      return 'Android';
    case 'ios':
      return 'iOS';
    case 'desktop':
      return 'Bureau';
    default:
      return raw.trim().isEmpty ? '—' : raw.trim();
  }
}

/// Bandeau titre + stats (remplace la barre du shell pour l’onglet Utilisateurs).
class _AdminUsersIntegratedShellHeader extends StatelessWidget {
  const _AdminUsersIntegratedShellHeader({required this.statsBody});

  final Widget statsBody;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 18),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Utilisateurs',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    this.layout = _UsersStatsLayout.wrap,
  });

  final int total;
  final int pro;
  final int signup30;
  final int stripePro;
  final _UsersStatsLayout layout;

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

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  /// Texte de filtre déjà appliqué au dernier rebuild ([trim] + lowercase).
  /// Les listeners du controller se déclenchent aussi au focus (changement de
  /// sélection) sans modifier le texte : on évite un setState inutile qui faisait « sauter » l’UI.
  String _appliedSearchQuery = '';

  static const int _pageSize = 12;
  int _pageIndex = 0;
  _UsersSort _sort = _UsersSort.activityRecent;
  _TierQuick _tierQuick = _TierQuick.all;

  @override
  void initState() {
    super.initState();
    _appliedSearchQuery = _searchCtrl.text.trim().toLowerCase();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q == _appliedSearchQuery) return;
    _appliedSearchQuery = q;
    _pageIndex = 0;
    // Pas de setState : le filtre est rendu via [ListenableBuilder] sur [_searchCtrl].
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  int _compareUsers(AdminUserRow a, AdminUserRow b) {
    switch (_sort) {
      case _UsersSort.activityRecent:
        final ta = a.lastSeenAt?.millisecondsSinceEpoch ?? 0;
        final tb = b.lastSeenAt?.millisecondsSinceEpoch ?? 0;
        return tb.compareTo(ta);
      case _UsersSort.joinedRecent:
        return b.joinedAt.compareTo(a.joinedAt);
      case _UsersSort.emailAz:
        return a.email.toLowerCase().compareTo(b.email.toLowerCase());
    }
  }

  List<AdminUserRow> _filteredSorted(List<AdminUserRow> all) {
    Iterable<AdminUserRow> it = all;
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      it = it.where(
        (u) =>
            u.email.toLowerCase().contains(q) ||
            u.firstName.toLowerCase().contains(q) ||
            u.lastName.toLowerCase().contains(q),
      );
    }
    switch (_tierQuick) {
      case _TierQuick.proOnly:
        it =
            it.where((u) => u.subscriptionTier == PaychekSubscriptionTier.pro);
        break;
      case _TierQuick.liteOnly:
        it =
            it.where((u) => u.subscriptionTier == PaychekSubscriptionTier.lite);
        break;
      case _TierQuick.all:
        break;
    }
    final list = it.toList();
    list.sort(_compareUsers);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd('fr_FR');
    final hdrStyle = GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: _UsersUi.dim,
      letterSpacing: 1.05,
    );

    return ColoredBox(
      color: _UsersUi.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: paychekUsersOrderedQuery().snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AdminUsersIntegratedShellHeader(
                        statsBody: Text(
                          'Données indisponibles',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: _UsersUi.dim,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: _FirestoreError(message: '${snap.error}'),
                        ),
                      ),
                    ],
                  );
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AdminUsersIntegratedShellHeader(
                        statsBody: const Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AdminTheme.accent,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child:
                              CircularProgressIndicator(color: AdminTheme.accent),
                        ),
                      ),
                    ],
                  );
                }

                final docs = snap.data?.docs ?? [];
                final users = docs
                    .map(adminUserRowFromFirestore)
                    .toList(growable: false);

                final statsTotal = users.length;
                final statsPro = users
                    .where(
                      (u) => u.subscriptionTier == PaychekSubscriptionTier.pro,
                    )
                    .length;
                final cutoff30 =
                    DateTime.now().toUtc().subtract(const Duration(days: 30));
                final stats30 = users
                    .where((u) => u.joinedAt.toUtc().isAfter(cutoff30))
                    .length;
                final statsStripePro = users
                    .where(
                      (u) =>
                          u.subscriptionTier ==
                              PaychekSubscriptionTier.pro &&
                          u.paymentMethod.trim().toLowerCase() == 'stripe',
                    )
                    .length;

                final statsStrip = _UsersStatsRow(
                  total: statsTotal,
                  pro: statsPro,
                  signup30: stats30,
                  stripePro: statsStripePro,
                  layout: _UsersStatsLayout.headerInline,
                );

                if (users.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AdminUsersIntegratedShellHeader(statsBody: statsStrip),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Aucun document. Les comptes Auth existants '
                                'apparaîtront après une connexion depuis l’app Paychek.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  color: _UsersUi.dim,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AdminUsersIntegratedShellHeader(statsBody: statsStrip),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _UsersUi.panel,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _UsersUi.border.withValues(alpha: 0.65),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _UsersTableToolbar(
                                searchCtrl: _searchCtrl,
                                sort: _sort,
                                tierQuick: _tierQuick,
                                onSort: (s) => setState(() {
                                  _sort = s;
                                  _pageIndex = 0;
                                }),
                                onTier: (t) => setState(() {
                                  _tierQuick = t;
                                  _pageIndex = 0;
                                }),
                              ),
                              Expanded(
                                child: ListenableBuilder(
                                  listenable: _searchCtrl,
                                  builder: (context, _) {
                                    final processed = _filteredSorted(users);
                                    final totalPages = processed.isEmpty
                                        ? 1
                                        : ((processed.length + _pageSize - 1) ~/
                                            _pageSize);
                                    final page = _pageIndex.clamp(
                                      0,
                                      totalPages > 0 ? totalPages - 1 : 0,
                                    );
                                    if (page != _pageIndex) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (!mounted) return;
                                        setState(() => _pageIndex = page);
                                      });
                                    }
                                    final start = page * _pageSize;
                                    final pageSlice = processed
                                        .skip(start)
                                        .take(_pageSize)
                                        .toList(growable: false);

                                    return _PaychekUsersTableScrollBody(
                                      users: pageSlice,
                                      df: df,
                                      scaffoldContext: context,
                                      headerStyle: hdrStyle,
                                      paginationFooter:
                                          _UsersPaginationFooter(
                                        fromItem: processed.isEmpty
                                            ? 0
                                            : start + 1,
                                        toItem:
                                            start + pageSlice.length,
                                        totalFiltered: processed.length,
                                        pageIndex: page,
                                        pageCount: totalPages,
                                        onPrev: page > 0
                                            ? () => setState(
                                                () => _pageIndex--,
                                              )
                                            : null,
                                        onNext: page < totalPages - 1
                                            ? () => setState(
                                                () => _pageIndex++,
                                              )
                                            : null,
                                        onExportCsv: () =>
                                            _adminExportUsersCsv(
                                              context,
                                              processed,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Scrollbar + ListView : la barre d’outils est **au-dessus** dans la page pour ne pas
/// reconstruire le champ recherche à chaque frappe ([ListenableBuilder] sur le corps seul).
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
    final label = _adminPaymentMethodDisplay(raw);
    Color accent = _UsersUi.muted;
    Widget? lead;
    if (t == 'stripe') {
      accent = const Color(0xFF818CF8);
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
      accent = const Color(0xFFE2E8F0);
      lead = Icon(Icons.phone_iphone_rounded, size: 16, color: accent);
    } else if (t == 'google' || t == 'google_play') {
      accent = const Color(0xFF93C5FD);
      lead = Icon(Icons.android_rounded, size: 16, color: accent);
    } else if (t == 'admin') {
      accent = _UsersUi.amber;
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
                          paychekAdminEffectiveTrialEndUtc(u).toLocal(),
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

class _ExpandableUserRow extends StatefulWidget {
  const _ExpandableUserRow({
    super.key,
    required this.u,
    required this.df,
    required this.scaffoldContext,
    required this.fnLabel,
    required this.lnLabel,
  });

  final AdminUserRow u;
  final DateFormat df;
  final BuildContext scaffoldContext;
  final String fnLabel;
  final String lnLabel;

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
    return Material(
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
              color: _expanded
                  ? _UsersUi.inputBg.withValues(alpha: 0.55)
                  : Colors.transparent,
              child: _ModernUserCollapsedCells(
                u: widget.u,
                fnLabel: widget.fnLabel,
                lnLabel: widget.lnLabel,
                trailing: RotationTransition(
                  turns: _chevronCtrl,
                  child: Icon(Icons.expand_more, color: _UsersUi.dim),
                ),
              ),
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
  }
}

/// Section Abonnement (segment Lite/Pro + sync Stripe) — alignée sur la maquette React.
class _PaychekProfileTierStripeSection extends StatefulWidget {
  const _PaychekProfileTierStripeSection({
    required this.userId,
    required this.userEmail,
    required this.initialTier,
    required this.scaffoldContext,
  });

  final String userId;
  final String userEmail;
  final PaychekSubscriptionTier initialTier;
  final BuildContext scaffoldContext;

  @override
  State<_PaychekProfileTierStripeSection> createState() =>
      _PaychekProfileTierStripeSectionState();
}

class _PaychekProfileTierStripeSectionState
    extends State<_PaychekProfileTierStripeSection> {
  late PaychekSubscriptionTier _tier;
  bool _saving = false;
  bool _syncing = false;

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

  Future<void> _setTier(PaychekSubscriptionTier tier) async {
    if (_saving || tier == _tier) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    setState(() => _saving = true);
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
      setState(() => _tier = tier);
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
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _syncStripe() async {
    if (_syncing) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    setState(() => _syncing = true);
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
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const mpInner = Color(0xFF1A1A1A);
    const mpBorder = Color(0xFF1E293B);
    final pro = _tier == PaychekSubscriptionTier.pro;
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
        TextButton.icon(
          onPressed: _syncing ? null : _syncStripe,
          icon: _syncing
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.sync_rounded,
                  size: 16, color: Colors.tealAccent.shade400),
          label: Text(
            'Synchroniser paiement Stripe → Pro',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF34D399),
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF34D399),
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
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

/// Inscription, essai, achat Pro et fin Pro — valeurs lisibles (sans sous-texte gris).
class _MaquetteAccountDatesBlock extends StatelessWidget {
  const _MaquetteAccountDatesBlock({
    required this.u,
    required this.df,
  });

  final AdminUserRow u;
  final DateFormat df;

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
    final inscription = df.format(u.joinedAt.toLocal());

    final trialEndUtc = u.trialFreemiumOverrideUntil ??
        u.joinedAt.toUtc().add(kPaychekTrialDuration);
    final trialEndLabel = df.format(trialEndUtc.toLocal());

    final nowUtc = DateTime.now().toUtc();
    final trialNotExpired = nowUtc.isBefore(trialEndUtc);
    final tierPro = u.subscriptionTier == PaychekSubscriptionTier.pro;

    final periodEndUtc = u.subscriptionCurrentPeriodEnd;
    final proSinceUtc = u.subscriptionProSinceUtc;
    final showProDates = tierPro ||
        periodEndUtc != null ||
        proSinceUtc != null;
    final anchor = proSinceUtc ?? u.subscriptionTierUpdatedAt;
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
              const SizedBox(width: 16),
              Expanded(
                child: _pair(
                  'Fin d’essai (accès plein)',
                  trialEndLabel,
                  trailing: trialChip(),
                ),
              ),
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
                    'Fin Pro',
                    finLabel,
                    valueColor:
                        finProUtc != null ? _finPro : _value,
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
            _adminPaymentMethodDisplay(u.paymentMethod),
            valueColor: const Color(0xFF818CF8),
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

    final billingCard = _MaquetteCollapsibleCard(
      title: 'FACTURATION',
      leading: const Icon(Icons.credit_card_rounded,
          size: 18, color: Color(0xFF818CF8)),
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
class _MaquetteCollapsibleCard extends StatefulWidget {
  const _MaquetteCollapsibleCard({
    required this.title,
    required this.child,
    this.leading,
    this.headerTrailing,
    this.bodyPadding = const EdgeInsets.all(22),
    this.initiallyExpanded = true,
  });

  final String title;
  final Widget child;
  final Widget? leading;
  final Widget? headerTrailing;
  final EdgeInsetsGeometry bodyPadding;
  final bool initiallyExpanded;

  @override
  State<_MaquetteCollapsibleCard> createState() =>
      _MaquetteCollapsibleCardState();
}

class _MaquetteCollapsibleCardState extends State<_MaquetteCollapsibleCard> {
  late bool _expanded = widget.initiallyExpanded;

  static const Color _card = Color(0xFF121212);
  static const Color _panel = Color(0xFF1A1A1A);
  static const Color _border = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
      color: const Color(0xFFCBD5E1),
    );

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: _panel.withValues(alpha: 0.5),
              border: const Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          setState(() => _expanded = !_expanded),
                      hoverColor: Colors.white.withValues(alpha: 0.04),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            if (widget.leading != null) ...[
                              widget.leading!,
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: Text(
                                widget.title,
                                style: titleStyle,
                              ),
                            ),
                            Tooltip(
                              message:
                                  _expanded ? 'Replier' : 'Déplier',
                              waitDuration:
                                  const Duration(milliseconds: 400),
                              child: AnimatedRotation(
                                turns: _expanded ? 0.5 : 0,
                                duration:
                                    const Duration(milliseconds: 180),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.headerTrailing != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: widget.headerTrailing!,
                  ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: _expanded
                ? Padding(
                    padding: widget.bodyPadding,
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

/// Libellé chiffré pour la grille USAGE APP (Firestore `csv_imports` count).
class _CsvImportsCountLabel extends StatefulWidget {
  const _CsvImportsCountLabel({super.key, required this.userId});

  final String userId;

  @override
  State<_CsvImportsCountLabel> createState() => _CsvImportsCountLabelState();
}

class _CsvImportsCountLabelState extends State<_CsvImportsCountLabel> {
  late final Future<int?> _countFuture =
      paychekCsvImportsRecordedCount(widget.userId);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        );
    return FutureBuilder<int?>(
      future: _countFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AdminTheme.accent,
            ),
          );
        }
        if (snap.hasError) {
          return Tooltip(
            message: '${snap.error}',
            child: Text(
              '?',
              style: style?.copyWith(color: AdminTheme.warning),
            ),
          );
        }
        final n = snap.data;
        if (n == null) {
          return Tooltip(
            message:
                'Lecture impossible (droits Firebase, hors-ligne ou index). '
                'Déploie `firestore.indexes.json` puis `firebase deploy --only firestore:indexes`.',
            child: Text('—', style: style),
          );
        }
        return Text('$n', style: style);
      },
    );
  }
}

class _CsvImportsHistoryFirestore extends StatefulWidget {
  const _CsvImportsHistoryFirestore({
    required this.userId,
    required this.df,
  });

  final String userId;
  final DateFormat df;

  @override
  State<_CsvImportsHistoryFirestore> createState() =>
      _CsvImportsHistoryFirestoreState();
}

class _CsvImportsHistoryFirestoreState extends State<_CsvImportsHistoryFirestore> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _snapshots;

  @override
  void initState() {
    super.initState();
    _snapshots = paychekCsvImportsQuery(widget.userId).snapshots();
  }

  @override
  void didUpdateWidget(covariant _CsvImportsHistoryFirestore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      setState(() {
        _snapshots = paychekCsvImportsQuery(widget.userId).snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle th() => Theme.of(context).textTheme.labelSmall!.copyWith(
          color: AdminTheme.textMuted,
          fontWeight: FontWeight.w700,
        );

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _snapshots,
      builder: (context, snap) {
        if (snap.hasError) {
          final err = '${snap.error}';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectableText(
                err,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.warning,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Si le message parle d’index : déploie les index Firestore '
                '(`firebase deploy --only firestore:indexes`) puis réessaie.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.textMuted,
                      height: 1.35,
                    ),
              ),
            ],
          );
        }
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: AdminTheme.accent),
            ),
          );
        }

        final docsRaw = snap.data?.docs ?? [];
        final docs = csvImportDocsNewestFirst(docsRaw);
        final referenceLine =
            'Logiciels disponibles dans l’app : ${kPaychekCsvSoftwareLabelsOrdered.join(' · ')}.';

        if (docs.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Aucun import CSV enregistré pour cet utilisateur '
                '(Firestore `paychek_users/${widget.userId}/$kPaychekCsvImportsSubcollection`).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.textMuted,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                referenceLine,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.textDim,
                      height: 1.35,
                    ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2.2),
                1: FlexColumnWidth(1.4),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2.2),
              },
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('DATE', style: th()),
                    ),
                    Text('LOGICIEL', style: th()),
                    Text('TRADES', style: th()),
                    Text('STATUT', style: th()),
                  ],
                ),
                ...docs.map((doc) {
                  final d = doc.data();
                  final ts = d['createdAt'];
                  final dateStr = ts is Timestamp
                      ? widget.df.format(ts.toDate().toLocal())
                      : '—';
                  final software = (d['software'] as String?)?.trim() ?? '—';
                  final trades = (d['tradeCount'] as num?)?.toInt() ?? 0;
                  final skipped =
                      (d['skippedDuplicates'] as num?)?.toInt() ?? 0;
                  final badge = _csvImportBadge(d);
                  final detail = _csvImportDetail(d, skipped);

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(dateStr),
                      ),
                      Text(software),
                      Text(
                        trades > 0
                            ? '$trades'
                            : (skipped > 0 ? '0 ($skipped ignorés)' : '0'),
                      ),
                      Tooltip(
                        message: detail ?? '',
                        child: Row(
                          children: [
                            Icon(
                              badge.icon,
                              size: 18,
                              color: badge.color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${badge.shortLabel}'
                                '${detail != null && detail.isNotEmpty && detail.length < 60 ? ' — $detail' : ''}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: badge.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              referenceLine,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AdminTheme.textMuted,
                    height: 1.35,
                  ),
            ),
          ],
        );
      },
    );
  }
}

({Color color, IconData icon, String shortLabel}) _csvImportBadge(
  Map<String, dynamic> d,
) {
  final s = (d['status'] as String?) ?? '';
  final tradeCount = (d['tradeCount'] as num?)?.toInt() ?? 0;
  final skipped = (d['skippedDuplicates'] as num?)?.toInt() ?? 0;
  if (s == PaychekCsvImportLogStatus.success && tradeCount == 0 && skipped > 0) {
    return (
      color: AdminTheme.warning,
      icon: Icons.copy_all_rounded,
      shortLabel: 'Doublons',
    );
  }
  switch (s) {
    case PaychekCsvImportLogStatus.success:
      return (
        color: AdminTheme.accent,
        icon: Icons.check_circle_outline,
        shortLabel: 'Succès',
      );
    case PaychekCsvImportLogStatus.empty:
      return (
        color: AdminTheme.warning,
        icon: Icons.info_outline,
        shortLabel: 'Aucun trade',
      );
    case PaychekCsvImportLogStatus.error:
      return (
        color: Colors.redAccent,
        icon: Icons.error_outline,
        shortLabel: 'Erreur',
      );
    default:
      return (
        color: AdminTheme.textMuted,
        icon: Icons.help_outline,
        shortLabel: s.isEmpty ? '—' : s,
      );
  }
}

/// Détail lisible dans le tooltip (message court + fichier si présent).
String? _csvImportDetail(Map<String, dynamic> d, int skipped) {
  final parts = <String>[];
  final fn = (d['fileName'] as String?)?.trim();
  if (fn != null && fn.isNotEmpty) parts.add(fn);
  final parsed = (d['parsedRowCount'] as num?)?.toInt();
  if (parsed != null && parsed > 0) {
    parts.add('$parsed lignes parsées depuis le fichier');
  }
  final msg = (d['message'] as String?)?.trim();
  if (msg != null && msg.isNotEmpty) parts.add(msg);
  final trades = (d['tradeCount'] as num?)?.toInt() ?? 0;
  if (skipped > 0 && (parts.isEmpty || trades == 0)) {
    parts.add('$skipped doublon(s)');
  }
  return parts.isEmpty ? null : parts.join(' · ');
}

class _BillingStripePanel extends StatefulWidget {
  const _BillingStripePanel({
    required this.df,
    required this.user,
  });

  final DateFormat df;
  final AdminUserRow user;

  @override
  State<_BillingStripePanel> createState() => _BillingStripePanelState();
}

class _BillingStripePanelState extends State<_BillingStripePanel> {
  bool _refundBusy = false;
  bool _summaryLoading = true;
  AdminUserBillingSummary _summary = AdminUserBillingSummary.empty;
  final _amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(_loadSummary());
  }

  @override
  void didUpdateWidget(covariant _BillingStripePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id ||
        oldWidget.user.subscriptionTier != widget.user.subscriptionTier ||
        oldWidget.user.subscriptionProSinceUtc !=
            widget.user.subscriptionProSinceUtc ||
        oldWidget.user.subscriptionCurrentPeriodEnd !=
            widget.user.subscriptionCurrentPeriodEnd) {
      unawaited(_loadSummary());
    }
  }

  Future<void> _loadSummary() async {
    setState(() => _summaryLoading = true);
    try {
      final s = await resolveAdminUserBillingSummary(
        user: widget.user,
        dateFormat: widget.df,
      );
      if (!mounted) return;
      setState(() {
        _summary = s;
        _summaryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _summaryLoading = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRembourse(BuildContext context) async {
    if (_refundBusy) return;
    final amount = _amountCtrl.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Indiquez le montant affiché dans l’e-mail (ex. 35 \$).'),
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTheme.cardElevated,
        title: Text(
          'Envoyer l’e-mail de remboursement ?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        content: Text(
          "Aucun remboursement Stripe n'est effectué depuis cette action. "
          "Le client recevra un e-mail indiquant le montant : « $amount ». "
          "Effectuez le virement réel depuis le Dashboard Stripe comme d'habitude.",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.45,
            color: AdminTheme.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFCA8A04),
              foregroundColor: Colors.black,
            ),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    setState(() => _refundBusy = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final r = await paychekAdminNotifyUserRefundEmail(
        targetUserId: widget.user.id,
        amountLabel: amount,
      );
      if (!context.mounted) return;
      if (r.ok) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              r.amountLabel != null && r.amountLabel!.isNotEmpty
                  ? 'E-mail envoyé (montant : ${r.amountLabel}).'
                  : 'E-mail de remboursement envoyé au client.',
            ),
          ),
        );
      } else {
        messenger?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade900,
            content: Text(r.message ?? 'Envoi impossible.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _refundBusy = false);
    }
  }

  Widget _billingPair(
    String label,
    String value, {
    bool monospace = false,
    double valueSize = 15,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(
          value,
          maxLines: 2,
          style: GoogleFonts.plusJakartaSans(
            fontSize: valueSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
            fontFeatures: monospace
                ? const [FontFeature.tabularFigures()]
                : null,
          ).copyWith(
            fontFamily: monospace ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_summaryLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _billingPair('Montant payé', _summary.amountLabel),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child:
                          _billingPair('Date de paiement', _summary.paidAtLabel),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _billingPair(
                        'Type d\'abonnement',
                        _summary.cycleLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _billingPair(
                  'N° de transaction',
                  _summary.transactionIdLabel,
                  monospace: true,
                  valueSize: 12,
                ),
              ],
            ),
          ),
        if (!widget.user.hasPaidPlan && !_summaryLoading) ...[
          const SizedBox(height: 10),
          Text(
            'Aucun abonnement payant actif pour ce compte.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AdminTheme.textMuted,
                ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Montant (e-mail client uniquement — Stripe manuel)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AdminTheme.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _amountCtrl,
                enabled: !_refundBusy,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: r'ex: 35 $',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: AdminTheme.textDim,
                    fontSize: 13,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _refundBusy ? null : () => unawaited(_onRembourse(context)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE2E8F0),
                side: const BorderSide(color: Color(0xFFC5A059)),
              ),
              child: _refundBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Remboursement'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminPlatformAccessControl extends StatefulWidget {
  const _AdminPlatformAccessControl({
    required this.userId,
    required this.webEnabled,
    required this.mobileEnabled,
    required this.scaffoldContext,
  });

  final String userId;
  final bool webEnabled;
  final bool mobileEnabled;
  final BuildContext scaffoldContext;

  @override
  State<_AdminPlatformAccessControl> createState() =>
      _AdminPlatformAccessControlState();
}

class _AdminPlatformAccessControlState extends State<_AdminPlatformAccessControl> {
  bool _saving = false;

  Future<void> _pushAccess({required bool web, required bool value}) async {
    if (_saving) return;
    final current = web ? widget.webEnabled : widget.mobileEnabled;
    if (value == current) return;

    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.userId)
          .update(<String, dynamic>{
        if (web) 'accessWebEnabled': value else 'accessMobileEnabled': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            web
                ? 'Web : ${value ? 'activé' : 'désactivé'}'
                : 'Mobile (Android/iOS) : ${value ? 'activé' : 'désactivé'}',
          ),
        ),
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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _saving,
      child: Opacity(
        opacity: _saving ? 0.5 : 1,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Accès Web',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch.adaptive(
                  value: widget.webEnabled,
                  activeThumbColor: AdminTheme.accent,
                  activeTrackColor: AdminTheme.accent.withValues(alpha: 0.35),
                  onChanged: (v) => _pushAccess(web: true, value: v),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Accès mobile (Android / iOS)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch.adaptive(
                  value: widget.mobileEnabled,
                  activeThumbColor: AdminTheme.accent,
                  activeTrackColor: AdminTheme.accent.withValues(alpha: 0.35),
                  onChanged: (v) => _pushAccess(web: false, value: v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pastille d’engagement (7 j) : seul un rond coloré, la colonne « Statut » est retirée du tableau.
class _UserEngagementDot extends StatelessWidget {
  const _UserEngagementDot({required this.u});

  final AdminUserRow u;

  @override
  Widget build(BuildContext context) {
    final led = paychekAdminEngagementLed(u);
    final c = paychekAdminEngagementLedColor(led);
    final short = switch (led) {
      AdminEngagementLed.green => 'Actif',
      AdminEngagementLed.orange => 'Peu actif',
      AdminEngagementLed.red => 'Inactif',
    };
    return Tooltip(
      message: '$short\n${paychekAdminEngagementLedTooltip(led)}',
      waitDuration: const Duration(milliseconds: 400),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: c.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTrialFreemiumOverrideControl extends StatefulWidget {
  const _AdminTrialFreemiumOverrideControl({
    required this.userId,
    required this.joinedAt,
    required this.overrideUntil,
    required this.df,
    required this.scaffoldContext,
  });

  final String userId;
  final DateTime joinedAt;
  final DateTime? overrideUntil;
  final DateFormat df;
  final BuildContext scaffoldContext;

  @override
  State<_AdminTrialFreemiumOverrideControl> createState() =>
      _AdminTrialFreemiumOverrideControlState();
}

class _AdminTrialFreemiumOverrideControlState
    extends State<_AdminTrialFreemiumOverrideControl> {
  static const Duration _kTrial = Duration(days: 7);
  bool _saving = false;

  DateTime get _defaultEndUtc => widget.joinedAt.toUtc().add(_kTrial);

  DateTime get _effectiveEndUtc =>
      widget.overrideUntil ?? _defaultEndUtc;

  Future<void> _persistEndUtc(DateTime endUtc) async {
    if (_saving) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.userId)
          .set(
            <String, dynamic>{
              kPaychekUserFieldTrialFreemiumOverrideUntil:
                  Timestamp.fromDate(endUtc),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'Date freemium enregistrée — l’app utilisera cette fin d’accès plein.',
          ),
        ),
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
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clearOverride() async {
    if (_saving) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.userId)
          .update(<String, dynamic>{
        kPaychekUserFieldTrialFreemiumOverrideUntil: FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Override supprimé — retour au calcul inscription + 7 j.'),
        ),
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
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _effectiveEndUtc.toLocal(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null || !mounted) return;
    final endLocal = DateTime(
      picked.year,
      picked.month,
      picked.day,
      23,
      59,
      59,
      999,
    );
    await _persistEndUtc(endLocal.toUtc());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AbsorbPointer(
      absorbing: _saving,
      child: Opacity(
        opacity: _saving ? 0.55 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RÉGLAGE FREEMIUM',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.55,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.df.format(_effectiveEndUtc.toLocal()),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.overrideUntil != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x1A34D399),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0x4434D399)),
                    ),
                    child: Text(
                      'OVERRIDE ADMIN ACTIF',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x152563EB),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0x332563EB)),
                    ),
                    child: Text(
                      'FIN PAR DÉFAUT : INSCRIPTION + 7 J',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: _saving ? null : _pickEndDate,
                  child: const Text('Choisir la date de fin…'),
                ),
                if (widget.overrideUntil != null)
                  OutlinedButton(
                    onPressed: _saving ? null : _clearOverride,
                    child: const Text('Supprimer l’override'),
                  ),
              ],
            ),
            if (_saving) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _adminSupportKindLabelFr(String raw) {
  switch (raw.trim()) {
    case 'account':
      return 'Compte';
    case 'billing':
      return 'Facturation';
    case 'feature':
      return 'Fonctionnalité';
    case 'other':
      return 'Autre';
    default:
      return raw.trim().isEmpty ? '—' : raw.trim();
  }
}

/// Affichage : prénom ou partie locale de l’e-mail support (pas l’adresse complète si évitable).
String _adminSupportDisplayNameFromStaffEmail(String? email) {
  final e = email?.trim() ?? '';
  if (e.isEmpty) return 'Support';
  final at = e.indexOf('@');
  final local = (at >= 0 ? e.substring(0, at) : e).trim();
  if (local.isEmpty) return 'Support';
  final parts = local
      .split(RegExp(r'[._+\-]+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return local;
  final buf = StringBuffer();
  for (final p in parts) {
    if (buf.isNotEmpty) buf.write(' ');
    buf.write(p[0].toUpperCase());
    if (p.length > 1) buf.write(p.substring(1).toLowerCase());
  }
  final s = buf.toString().trim();
  return s.isEmpty ? local : s;
}

enum _OutboundEmailKind { welcome, payment, refund, reply }

/// Lignes de la carte « e-mails envoyés » (tickets + indications profil).
class _OutboundSupportEmailEvent {
  const _OutboundSupportEmailEvent({
    required this.kind,
    required this.atUtc,
    this.ticketId,
    this.ticketLabel,
    this.staffEmail,
  });

  final _OutboundEmailKind kind;
  final DateTime atUtc;

  /// Présent pour bienvenue / réponse (navigation vers le ticket).
  final String? ticketId;
  final String? ticketLabel;
  final String? staffEmail;
}

_OutboundSupportEmailEvent? _paymentOutboundEmailEvent(AdminUserRow user) {
  if (user.subscriptionTier != PaychekSubscriptionTier.pro) return null;
  final pm = user.paymentMethod.trim().toLowerCase();
  if (pm == 'admin') return null;
  final ts = user.subscriptionProSinceUtc ?? user.subscriptionTierUpdatedAt;
  if (ts == null) return null;
  return _OutboundSupportEmailEvent(
    kind: _OutboundEmailKind.payment,
    atUtc: ts,
  );
}

Future<List<_OutboundSupportEmailEvent>> _loadOutboundSupportEmailsFromTickets(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> ticketDocs,
) async {
  if (ticketDocs.isEmpty) return const [];

  final perTicket = await Future.wait(ticketDocs.map((doc) async {
    final tid = doc.id;
    final td = doc.data();
    final label = paychekSupportHumanRefLine(tid, td);
    final local = <_OutboundSupportEmailEvent>[];

    final created = td['createdAt'];
    if (created is Timestamp) {
      local.add(
        _OutboundSupportEmailEvent(
          kind: _OutboundEmailKind.welcome,
          ticketId: tid,
          ticketLabel: label,
          atUtc: created.toDate().toUtc(),
        ),
      );
    }

    final mq = await doc.reference
        .collection(kPaychekSupportTicketMessagesSubcollection)
        .where('sender', isEqualTo: 'staff')
        .get();

    for (final msgDoc in mq.docs) {
      final md = msgDoc.data();
      final ts = md['createdAt'];
      if (ts is! Timestamp) continue;
      final agent = '${md['staffEmail'] ?? ''}'.trim();
      local.add(
        _OutboundSupportEmailEvent(
          kind: _OutboundEmailKind.reply,
          ticketId: tid,
          ticketLabel: label,
          atUtc: ts.toDate().toUtc(),
          staffEmail: agent.isEmpty ? null : agent,
        ),
      );
    }

    return local;
  }));

  return perTicket.expand((e) => e).toList(growable: false);
}

Future<List<_OutboundSupportEmailEvent>> _loadAllOutboundEmailEvents({
  required AdminUserRow user,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> ticketDocs,
}) async {
  final fromTickets = await _loadOutboundSupportEmailsFromTickets(ticketDocs);
  final payment = _paymentOutboundEmailEvent(user);
  final merged = <_OutboundSupportEmailEvent>[
    ...fromTickets,
    ?payment,
  ];
  merged.sort((a, b) => b.atUtc.compareTo(a.atUtc));
  return merged;
}

/// Titres homogènes pour la carte e-mails.
String _outboundEmailPrimaryTitle(_OutboundSupportEmailEvent e) {
  switch (e.kind) {
    case _OutboundEmailKind.welcome:
      final lab = (e.ticketLabel ?? '').trim();
      return lab.isEmpty
          ? 'E-mail de bienvenue'
          : 'E-mail de bienvenue · ticket #$lab';
    case _OutboundEmailKind.payment:
      return 'E-mail de paiement';
    case _OutboundEmailKind.refund:
      return 'E-mail de remboursement';
    case _OutboundEmailKind.reply:
      final name = _adminSupportDisplayNameFromStaffEmail(e.staffEmail);
      final lab = (e.ticketLabel ?? '').trim();
      final ticketBit = lab.isEmpty ? '' : ' · ticket #$lab';
      return 'E-mail de réponse — $name$ticketBit';
  }
}

IconData _outboundEmailIcon(_OutboundEmailKind k) {
  return switch (k) {
    _OutboundEmailKind.welcome => Icons.mark_email_read_outlined,
    _OutboundEmailKind.payment => Icons.payment_outlined,
    _OutboundEmailKind.refund => Icons.currency_exchange,
    _OutboundEmailKind.reply => Icons.reply_outlined,
  };
}

class _AdminUserSupportOutboundEmailsPanel extends StatelessWidget {
  const _AdminUserSupportOutboundEmailsPanel({required this.user});

  final AdminUserRow user;

  @override
  Widget build(BuildContext context) {
    final msgDf = DateFormat('dd/MM/y HH:mm', 'fr_FR');
    return _MaquetteCollapsibleCard(
      title: 'E-MAILS ENVOYÉS',
      leading: Icon(
        Icons.forward_to_inbox_outlined,
        size: 18,
        color: AdminTheme.accent,
      ),
      initiallyExpanded: true,
      bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(kPaychekSupportTicketsCollection)
            .where('userId', isEqualTo: user.id)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Text(
              '${snap.error}',
              style: TextStyle(color: AdminTheme.warning, fontSize: 13),
            );
          }
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AdminTheme.accent,
                  ),
                ),
              ),
            );
          }

          final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            snap.data?.docs ?? const [],
          );

          final ticketSync = docs
              .map((d) {
                final m = d.data();
                final u = m['updatedAt'];
                final ums = u is Timestamp ? u.millisecondsSinceEpoch : 0;
                return '${d.id}:$ums';
              })
              .join('|');
          final userSync =
              '${user.id}|${user.subscriptionTier.name}|${user.paymentMethod}|'
              '${user.subscriptionProSinceUtc?.millisecondsSinceEpoch ?? 0}|'
              '${user.subscriptionTierUpdatedAt?.millisecondsSinceEpoch ?? 0}';
          final syncKey = '$userSync|$ticketSync';

          return FutureBuilder<List<_OutboundSupportEmailEvent>>(
            key: ValueKey(syncKey),
            future: _loadAllOutboundEmailEvents(user: user, ticketDocs: docs),
            builder: (context, futSnap) {
              if (futSnap.hasError) {
                return Text(
                  '${futSnap.error}',
                  style: TextStyle(color: AdminTheme.warning, fontSize: 13),
                );
              }
              if (futSnap.connectionState == ConnectionState.waiting &&
                  !futSnap.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AdminTheme.accent,
                      ),
                    ),
                  ),
                );
              }

              final rows = futSnap.data ?? const [];
              if (rows.isEmpty) {
                return Text(
                  'Aucun e-mail listé pour cet utilisateur.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AdminTheme.textMuted,
                      ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AdminTheme.border),
                    Builder(
                      builder: (context) {
                        final row = rows[i];
                        final tid = row.ticketId?.trim();
                        final padded = Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _outboundEmailIcon(row.kind),
                                size: 20,
                                color: AdminTheme.textMuted,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _outboundEmailPrimaryTitle(row),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AdminTheme.accent,
                                        fontWeight: FontWeight.w800,
                                        height: 1.28,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                msgDf.format(row.atUtc.toLocal()),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AdminTheme.textMuted,
                                    ),
                              ),
                            ],
                          ),
                        );
                        if (tid != null && tid.isNotEmpty) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => AdminSupportTicketDetailPage(
                                    ticketId: tid,
                                  ),
                                ),
                              );
                            },
                            child: padded,
                          );
                        }
                        return padded;
                      },
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Tickets `paychek_support_tickets` liés à l’UID (bas de fiche utilisateur).
class _AdminUserTicketsPanel extends StatelessWidget {
  const _AdminUserTicketsPanel({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final msgDf = DateFormat('dd/MM/y HH:mm', 'fr_FR');
    return _MaquetteCollapsibleCard(
      title: 'TICKETS SUPPORT (cet utilisateur)',
      leading: Icon(
        Icons.support_agent_outlined,
        size: 18,
        color: AdminTheme.accent,
      ),
      initiallyExpanded: true,
      bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(kPaychekSupportTicketsCollection)
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Text(
              '${snap.error}',
              style: TextStyle(color: AdminTheme.warning, fontSize: 13),
            );
          }
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AdminTheme.accent,
                  ),
                ),
              ),
            );
          }
          final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            snap.data?.docs ?? const [],
          );
          docs.sort((a, b) {
            final ta = a.data()['createdAt'];
            final tb = b.data()['createdAt'];
            if (ta is Timestamp && tb is Timestamp) {
              return tb.toDate().compareTo(ta.toDate());
            }
            return 0;
          });
          if (docs.isEmpty) {
            return Text(
              'Aucun ticket pour cet UID.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AdminTheme.textMuted,
                  ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < docs.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: AdminTheme.border),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => AdminSupportTicketDetailPage(
                          ticketId: docs[i].id,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.support_agent_outlined,
                          size: 20,
                          color: AdminTheme.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                paychekSupportHumanRefLine(
                                  docs[i].id,
                                  docs[i].data(),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AdminTheme.accent,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _adminSupportKindLabelFr(
                                  '${docs[i].data()['kind']}',
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${docs[i].data()['description']}'.trim(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AdminTheme.textDim),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (ctx) {
                            final ts = docs[i].data()['createdAt'];
                            final label = ts is Timestamp
                                ? msgDf.format(ts.toDate().toLocal())
                                : '—';
                            return Text(
                              label,
                              style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                                    color: AdminTheme.textMuted,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FirestoreError extends StatelessWidget {
  const _FirestoreError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AdminTheme.warning, size: 40),
            const SizedBox(height: 12),
            Text(
              'Firestore',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Vérifie le déploiement des règles (`firebase deploy --only firestore:rules`) '
              'et le claim `admin` sur ton compte.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AdminTheme.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Titre court profil (même logique que la ligne Utilisateurs dépliée).
String paychekAdminProfileDisplayName(AdminUserRow u) {
  final ordered = '${u.lastName} ${u.firstName}'.trim();
  if (ordered.isNotEmpty) return ordered;
  final email = u.email;
  if (email.contains('@')) {
    return email.split('@').first;
  }
  return u.id.length <= 12 ? u.id : '${u.id.substring(0, 8)}…';
}

/// Panneau détaillé identique à la fiche « Utilisateurs » dépliée.
Widget paychekAdminUserExpandedPanel({
  required AdminUserRow u,
  required DateFormat df,
  required BuildContext scaffoldContext,
}) {
  return _UserExpandedDashboard(
    u: u,
    df: df,
    scaffoldContext: scaffoldContext,
  );
}
