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
import 'admin_apple_entitlement_sync.dart';
import 'admin_google_play_entitlement_sync.dart';
import 'admin_models.dart';
import 'admin_stripe_entitlement_sync.dart';
import 'admin_stripe_refund.dart';
import 'admin_subscription_trace.dart';
import 'admin_user_billing_summary.dart';
import 'admin_support_ticket_detail_page.dart';
import 'admin_layout.dart';
import 'admin_theme.dart';
import 'admin_user_engagement.dart';

part 'admin_users_page_shell.dart';
part 'admin_users_page_table.dart';
part 'admin_users_page_profile_stripe.dart';
part 'admin_users_page_profile_stripe_tier.dart';
part 'admin_users_page_profile_stripe_google.dart';
part 'admin_users_page_profile_stripe_apple.dart';
part 'admin_users_page_profile_stripe_stripe.dart';
part 'admin_users_page_profile_dates.dart';
part 'admin_users_page_expanded.dart';
part 'admin_users_page_panels.dart';
part 'admin_users_page_controls.dart';
part 'admin_users_page_support.dart';

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
          paychekAdminDisplayDueDateUtc(u).toLocal(),
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
                          padding: AdminLayout.pagePadding(context),
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
                final statsApplePro = users
                    .where(
                      (u) =>
                          u.subscriptionTier ==
                              PaychekSubscriptionTier.pro &&
                          _UsersStatsRow._isApplePayment(u.paymentMethod),
                    )
                    .length;
                final statsGooglePlayPro = users
                    .where(
                      (u) =>
                          u.subscriptionTier ==
                              PaychekSubscriptionTier.pro &&
                          _UsersStatsRow._isGooglePlayPayment(u.paymentMethod),
                    )
                    .length;

                final statsStrip = _UsersStatsRow(
                  total: statsTotal,
                  pro: statsPro,
                  signup30: stats30,
                  stripePro: statsStripePro,
                  applePro: statsApplePro,
                  googlePlayPro: statsGooglePlayPro,
                  layout: _UsersStatsLayout.headerInline,
                );

                if (users.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AdminUsersIntegratedShellHeader(statsBody: statsStrip),
                      Expanded(
                        child: Padding(
                          padding: AdminLayout.pagePadding(context),
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

                return FutureBuilder<List<AdminUserRow>>(
                  key: ValueKey(
                    users
                        .map(
                          (u) =>
                              '${u.id}:${u.subscriptionCurrentPeriodEnd?.millisecondsSinceEpoch ?? 0}:${u.subscriptionTier.name}',
                        )
                        .join('|'),
                  ),
                  future: adminEnrichUsersWithEntitlements(users),
                  builder: (context, enrichedSnap) {
                    final displayUsers = enrichedSnap.data ?? users;
                    return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AdminUsersIntegratedShellHeader(statsBody: statsStrip),
                    Expanded(
                      child: Padding(
                        padding: AdminLayout.pagePadding(context),
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
                                    final processed =
                                        _filteredSorted(displayUsers);
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
