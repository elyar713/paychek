import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../reglage/paychek_user_firestore.dart';
import 'admin_firestore_users.dart';
import 'admin_theme.dart';
import 'admin_users_page.dart';

/// Fiche utilisateur plein écran (navigation depuis Support & feedback, etc.).
class AdminUserAccountPage extends StatelessWidget {
  const AdminUserAccountPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd('fr_FR');
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      appBar: AppBar(
        backgroundColor: AdminTheme.bg,
        elevation: 0,
        title: const Text('Compte utilisateur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(kPaychekUsersCollection)
            .doc(userId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: SelectableText(
                '${snap.error}',
                style: const TextStyle(color: AdminTheme.warning),
              ),
            );
          }
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AdminTheme.accent),
            );
          }
          if (!snap.hasData || !snap.data!.exists) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Aucun document `$kPaychekUsersCollection` pour cet UID.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AdminTheme.textMuted,
                      ),
                ),
              ),
            );
          }
          final u = adminUserRowFromFirestore(snap.data!);
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: paychekAdminUserExpandedPanel(
              u: u,
              df: df,
              scaffoldContext: context,
            ),
          );
        },
      ),
    );
  }
}
