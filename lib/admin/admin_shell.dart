import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../reglage/paychek_support_ticket_submit.dart';
import 'admin_billing_page.dart';
import 'admin_branding.dart';
import 'admin_config_page.dart';
import 'admin_overview_page.dart';
import 'admin_profile_page.dart';
import 'admin_superadmin_gate.dart';
import 'admin_support_page.dart';
import 'admin_team_page.dart';
import 'admin_theme.dart';
import 'admin_users_page.dart';

class _PaychekShellTab {
  const _PaychekShellTab({
    required this.title,
    required this.icon,
    required this.page,
  });

  final String title;
  final IconData icon;
  final Widget page;
}

List<_PaychekShellTab> _shellTabs(bool superadmin) => [
      _PaychekShellTab(
        title: 'Vue d’ensemble',
        icon: Icons.dashboard_outlined,
        page: const AdminOverviewPage(),
      ),
      _PaychekShellTab(
        title: 'Utilisateurs',
        icon: Icons.people_outline,
        page: const AdminUsersPage(),
      ),
      _PaychekShellTab(
        title: 'Facturation',
        icon: Icons.credit_card_outlined,
        page: const AdminBillingPage(),
      ),
      _PaychekShellTab(
        title: 'Configuration',
        icon: Icons.tune_outlined,
        page: const AdminConfigPage(),
      ),
      _PaychekShellTab(
        title: 'Support & feedback',
        icon: Icons.support_agent_outlined,
        page: const AdminSupportPage(),
      ),
      if (superadmin)
        _PaychekShellTab(
          title: 'Équipe admin',
          icon: Icons.shield_outlined,
          page: const AdminTeamPage(),
        ),
    ];

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        final sup = paychekIsSuperadminFirebaseUser(authSnap.data);
        final tabs = _shellTabs(sup);
        final n = tabs.length;

        if (n == 0) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_index >= n) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _index < n) return;
            setState(() => _index = 0);
          });
        }

        final safeIdx = _index.clamp(0, n - 1).toInt();
        final current = tabs[safeIdx];
        final embedPageTitleBar = current.page is AdminUsersPage;

        return Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Sidebar(
                tabs: tabs,
                selectedIndex: safeIdx,
                onSelect: (i) => setState(() => _index = i),
                onLogout: _onLogout,
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AdminTheme.cardElevated.withValues(alpha: 0.35),
                        AdminTheme.bg,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!embedPageTitleBar)
                        Container(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 26,
                                      letterSpacing: -0.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(child: current.page),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onLogout() async {
    await FirebaseAuth.instance.signOut();
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  final List<_PaychekShellTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    const w = 260.0;
    return Material(
      color: AdminTheme.sidebarBg,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: AdminTheme.border.withValues(alpha: 0.45),
            ),
          ),
        ),
        child: SizedBox(
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: const PaychekAdminLogoRow(compact: true),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(kPaychekSupportTicketsCollection)
                  .where('staffUnread', isEqualTo: true)
                  .snapshots(),
              builder: (context, unreadSnap) {
                final unread = unreadSnap.hasData ? unreadSnap.data!.docs.length : 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SidebarSectionLabel(text: 'MENU PRINCIPAL'),
                    for (var i = 0; i < 4 && i < tabs.length; i++)
                      _NavTile(
                        label: tabs[i].title,
                        icon: tabs[i].icon,
                        selected: selectedIndex == i,
                        onTap: () => onSelect(i),
                        notifyCount: 0,
                      ),
                    if (tabs.length > 4) ...[
                      const SizedBox(height: 12),
                      _SidebarSectionLabel(text: 'ASSISTANCE'),
                      for (var i = 4; i < tabs.length; i++)
                        _NavTile(
                          label: tabs[i].title,
                          icon: tabs[i].icon,
                          selected: selectedIndex == i,
                          onTap: () => onSelect(i),
                          notifyCount:
                              tabs[i].title == 'Support & feedback' ? unread : 0,
                        ),
                    ],
                  ],
                );
              },
            ),
            const Spacer(),
            const Divider(height: 1, color: AdminTheme.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const AdminProfilePage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AdminTheme.border,
                              child: const Icon(Icons.person, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: StreamBuilder(
                                stream: FirebaseAuth.instance.authStateChanges(),
                                builder: (context, snap) {
                                  final u = snap.data;
                                  final label =
                                      (u?.email ?? u?.displayName ?? '').trim();
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label.isEmpty ? 'Compte admin' : label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Profil administrateur',
                                        style:
                                            Theme.of(context)
                                                .textTheme.labelSmall?.copyWith(
                                                  color: AdminTheme.accent,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AdminTheme.textDim,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onLogout,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        foregroundColor: AdminTheme.textMuted,
                      ),
                      child: const Text('Déconnexion'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _SidebarSectionLabel extends StatelessWidget {
  const _SidebarSectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AdminTheme.textDim,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.15,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.notifyCount = 0,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int notifyCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: selected
                  ? AdminTheme.accent.withValues(alpha: 0.14)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? AdminTheme.accent.withValues(alpha: 0.55)
                    : Colors.transparent,
                width: 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AdminTheme.accent.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? AdminTheme.accent : AdminTheme.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: selected ? Colors.white : AdminTheme.textMuted,
                    ),
                  ),
                ),
                if (notifyCount > 0)
                  Tooltip(
                    message: notifyCount == 1
                        ? '1 ticket non lu'
                        : '$notifyCount tickets non lus',
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 22, minHeight: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        color: AdminTheme.accent,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AdminTheme.accent.withValues(alpha: 0.45),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        notifyCount > 99 ? '99+' : '$notifyCount',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
