part of 'admin_users_page.dart';

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
