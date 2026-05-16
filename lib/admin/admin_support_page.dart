import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../reglage/paychek_support_ticket_submit.dart';
import 'admin_support_inbox_quick_reply.dart';
import 'admin_support_ticket_detail_page.dart';
import 'admin_theme.dart';
import 'admin_user_account_page.dart';

String _kindLabelFr(String raw) {
  switch (raw) {
    case 'account':
      return 'Compte';
    case 'billing':
      return 'Facturation';
    case 'feature':
      return 'Idée / fonctionnalité';
    case 'other':
      return 'Autre';
    default:
      return raw.isEmpty ? '—' : raw;
  }
}

/// Ligne d’identité dans la liste admin : **nom** puis **prénom** si stockés sur le ticket.
String _supportInboxDisplayName(Map<String, dynamic> data, String replyEmail) {
  final fn = '${data['replyFirstName'] ?? ''}'.trim();
  final ln = '${data['replyLastName'] ?? ''}'.trim();
  if (fn.isNotEmpty && ln.isNotEmpty) return '$ln $fn';
  if (ln.isNotEmpty) return ln;
  if (fn.isNotEmpty) return fn;
  final dn = '${data['replyDisplayName'] ?? ''}'.trim();
  if (dn.isNotEmpty) return dn;
  final e = replyEmail.trim();
  if (e.isNotEmpty && e != '—') {
    final at = e.indexOf('@');
    if (at > 0) return e.substring(0, at);
    return e;
  }
  return '—';
}

/// Nom affiché dans **( )** à côté de l’e-mail : uniquement données ticket (pas de fallback local-part).
String _supportInboxTicketNameOnly(Map<String, dynamic> data) {
  final fn = '${data['replyFirstName'] ?? ''}'.trim();
  final ln = '${data['replyLastName'] ?? ''}'.trim();
  if (fn.isNotEmpty && ln.isNotEmpty) return '$ln $fn';
  if (ln.isNotEmpty) return ln;
  if (fn.isNotEmpty) return fn;
  final dn = '${data['replyDisplayName'] ?? ''}'.trim();
  if (dn.isNotEmpty) return dn;
  return '';
}

/// Sujet en liste : uniquement le **type** de demande (Compte, Facturation, etc.), pas le corps du message.
String _supportInboxSubjectLine(Map<String, dynamic> data) {
  return _kindLabelFr('${data['kind']}');
}

class _SupportKpiSnapshot {
  const _SupportKpiSnapshot({
    required this.openTickets,
    required this.openCreatedToday,
    required this.answeredTickets,
    required this.touched24h,
    required this.staffUnread,
    required this.total,
  });

  final int openTickets;
  final int openCreatedToday;
  final int answeredTickets;
  final int touched24h;
  final int staffUnread;
  final int total;

  factory _SupportKpiSnapshot.fromDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final now = DateTime.now();
    final sod = DateTime(now.year, now.month, now.day);
    var openTickets = 0,
        openCreatedToday = 0,
        answeredTickets = 0,
        touched24h = 0,
        staffUnread = 0;
    for (final d in docs) {
      final m = d.data();
      final st = '${m['status']}'.trim().toLowerCase();
      final isOpen = st.isEmpty || st == 'open';
      if (isOpen) {
        openTickets++;
        final ct = m['createdAt'];
        if (ct is Timestamp) {
          final c = ct.toDate().toLocal();
          if (!c.isBefore(sod)) openCreatedToday++;
        }
      }
      if (st == 'answered') answeredTickets++;
      final ut = m['updatedAt'];
      if (ut is Timestamp) {
        final local = ut.toDate().toLocal();
        final diff = now.difference(local);
        if (!diff.isNegative && diff <= const Duration(hours: 24)) {
          touched24h++;
        }
      }
      if (m['staffUnread'] == true) staffUnread++;
    }
    return _SupportKpiSnapshot(
      openTickets: openTickets,
      openCreatedToday: openCreatedToday,
      answeredTickets: answeredTickets,
      touched24h: touched24h,
      staffUnread: staffUnread,
      total: docs.length,
    );
  }
}

List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterTicketDocs(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs);
  }
  return docs.where((d) {
    final m = d.data();
    final email = '${m['replyEmail']}'.toLowerCase();
    final desc = '${m['description']}'.toLowerCase();
    final ref = paychekSupportHumanRefLine(d.id, m).toLowerCase();
    final displayName = _supportInboxDisplayName(
      m,
      '${m['replyEmail'] ?? ''}'.trim(),
    ).toLowerCase();
    final subject = _supportInboxSubjectLine(m).toLowerCase();
    return email.contains(q) ||
        desc.contains(q) ||
        ref.contains(q) ||
        displayName.contains(q) ||
        subject.contains(q) ||
        d.id.toLowerCase().contains(q);
  }).toList();
}

void _sortTicketDocs(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> list,
  bool newestFirst,
) {
  int millis(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final t = d.data()['createdAt'];
    if (t is! Timestamp) return 0;
    return t.millisecondsSinceEpoch;
  }

  list.sort((a, b) {
    final ca = millis(a);
    final cb = millis(b);
    return newestFirst ? cb.compareTo(ca) : ca.compareTo(cb);
  });
}

/// Statut pour une ligne de liste (point + libellé type maquette).
({Color dot, Color fg, String label}) _inboxListStatusLook(String statusRaw) {
  final raw = statusRaw.trim().toLowerCase();
  return switch (raw) {
    '' ||
    'open' => (dot: AdminTheme.accent, fg: AdminTheme.accent, label: 'OUVERT'),
    'answered' => (
      dot: AdminTheme.warning,
      fg: AdminTheme.warning,
      label: 'EN ATTENTE',
    ),
    'closed' => (
      dot: AdminTheme.liveBlue,
      fg: AdminTheme.textMuted,
      label: 'FERMÉ',
    ),
    _ => (
      dot: AdminTheme.textDim,
      fg: AdminTheme.textMuted,
      label: statusRaw.isEmpty ? '—' : statusRaw.toUpperCase(),
    ),
  };
}

/// Support — deux volets : liste à gauche, fil et réponse à droite.
class AdminSupportPage extends StatefulWidget {
  const AdminSupportPage({super.key});

  @override
  State<AdminSupportPage> createState() => _AdminSupportPageState();
}

class _AdminSupportPageState extends State<AdminSupportPage> {
  String? _selectedTicketId;
  String _searchQuery = '';
  bool _newestFirst = true;

  String? _effectiveSelectedTicketId(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered,
  ) {
    if (filtered.isEmpty) return null;
    if (_selectedTicketId != null) {
      for (final d in filtered) {
        if (d.id == _selectedTicketId) return _selectedTicketId;
      }
    }
    return filtered.first.id;
  }

  QueryDocumentSnapshot<Map<String, dynamic>>? _docForId(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered,
    String? id,
  ) {
    if (id == null) return null;
    for (final d in filtered) {
      if (d.id == id) return d;
    }
    return null;
  }

  Future<void> _deleteSupportTicket(BuildContext context, String ticketId) async {
    final go = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Supprimer le ticket ?'),
            content: const Text(
              'La conversation et les pièces jointes enregistrées en base seront supprimées. '
              'Les fichiers Storage restent orphelins sauf nettoyage manuel.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminTheme.warning,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;
    if (!go || !mounted) return;

    try {
      final ref = FirebaseFirestore.instance
          .collection(kPaychekSupportTicketsCollection)
          .doc(ticketId);
      final msgs = await ref
          .collection(kPaychekSupportTicketMessagesSubcollection)
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (final d in msgs.docs) {
        batch.delete(d.reference);
      }
      batch.delete(ref);
      await batch.commit();
      if (!mounted || !context.mounted) return;
      setState(() => _selectedTicketId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket supprimé')),
      );
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Suppression impossible : $e')),
        );
      }
    }
  }

  Future<void> _closeSupportTicket(BuildContext context, String ticketId) async {
    try {
      await FirebaseFirestore.instance
          .collection(kPaychekSupportTicketsCollection)
          .doc(ticketId)
          .update({
        'status': 'closed',
        'updatedAt': FieldValue.serverTimestamp(),
        'staffUnread': false,
      });
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket clôturé')),
        );
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Clôture impossible : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd('fr_FR').add_Hm();
    final dfHm = DateFormat.Hm('fr_FR');
    final headerBorder =
        const Color(0xFF1E293B).withValues(alpha: 0.55);

    return ColoredBox(
      color: AdminTheme.supportCanvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(kPaychekSupportTicketsCollection)
                .orderBy('createdAt', descending: true)
                .limit(80)
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                final kpisErr =
                    _SupportKpiSnapshot.fromDocs(snap.data?.docs ?? []);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _supportInboxTopBar(context, kpisErr, headerBorder),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SelectableText(
                          '${snap.error}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AdminTheme.warning),
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData) {
                final kpisWait = _SupportKpiSnapshot.fromDocs(const []);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _supportInboxTopBar(context, kpisWait, headerBorder),
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AdminTheme.accent,
                        ),
                      ),
                    ),
                  ],
                );
              }
              final docs = snap.data?.docs ?? [];
              final kpis = _SupportKpiSnapshot.fromDocs(docs);
              final filtered = _filterTicketDocs(docs, _searchQuery);
              _sortTicketDocs(filtered, _newestFirst);
              final effectiveId = _effectiveSelectedTicketId(filtered);
              final selectedDoc = effectiveId == null
                  ? null
                  : _docForId(filtered, effectiveId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _supportInboxTopBar(context, kpis, headerBorder),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final innerW = constraints.maxWidth;
                        final stacked = innerW < 840;
                        const leftFixed = 380.0;
                        final leftW = stacked
                            ? innerW
                            : leftFixed.clamp(260.0, innerW * 0.42);

                        final left = _buildLeftInboxPane(
                          context,
                          filtered: filtered,
                          docsEmpty: docs.isEmpty,
                          filteredEmpty: filtered.isEmpty,
                          effectiveId: effectiveId,
                          dfHm: dfHm,
                        );

                        final right = _buildRightDetailPane(
                          context,
                          docsEmpty: docs.isEmpty,
                          filteredEmpty: filtered.isEmpty,
                          effectiveId: effectiveId,
                          selectedDoc: selectedDoc,
                          df: df,
                          borderColor: headerBorder,
                        );

                        final body = stacked
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 11, child: left),
                                  const SizedBox(height: 12),
                                  Expanded(flex: 14, child: right),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(width: leftW, child: left),
                                  VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    color: headerBorder,
                                  ),
                                  Expanded(child: right),
                                ],
                              );

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: body,
                        );
                      },
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

  Widget _supportInboxTopBar(
    BuildContext context,
    _SupportKpiSnapshot kpis,
    Color borderColor,
  ) {
    final searchFill = const Color(0xFF0F172A).withValues(alpha: 0.68);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
      decoration: BoxDecoration(
        color: AdminTheme.supportPanel.withValues(alpha: 0.85),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Boîte de réception',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: Colors.white,
                  letterSpacing: -0.35,
                ),
          ),
          const SizedBox(width: 12),
          if (kpis.staffUnread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: searchFill,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AdminTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    kpis.staffUnread > 99
                        ? '99+ NOUVEAUX'
                        : '${kpis.staffUnread} NOUVEAUX',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          SizedBox(
            width: 200,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                  ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Rechercher…',
                hintStyle: TextStyle(
                  color: AdminTheme.textDim,
                  fontSize: 12,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 17,
                  color: AdminTheme.textDim,
                ),
                filled: true,
                fillColor: searchFill,
                contentPadding: const EdgeInsets.fromLTRB(8, 10, 10, 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AdminTheme.accent.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Tri',
            color: AdminTheme.supportPanel,
            offset: const Offset(0, 40),
            onSelected: (v) => setState(() => _newestFirst = v == 'recent'),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'recent', child: Text('Plus récents')),
              PopupMenuItem(value: 'old', child: Text('Plus anciens')),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                size: 19,
                color: AdminTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftInboxPane(
    BuildContext context, {
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered,
    required bool docsEmpty,
    required bool filteredEmpty,
    required String? effectiveId,
    required DateFormat dfHm,
  }) {
    return ColoredBox(
      color: AdminTheme.supportPanel.withValues(alpha: 0.32),
      child: docsEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Aucun ticket pour le moment.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AdminTheme.textMuted,
                      ),
                ),
              ),
            )
          : filteredEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Aucun ticket ne correspond à la recherche.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AdminTheme.textMuted,
                          ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = filtered[i];
                    return _inboxListRow(
                      context,
                      d,
                      effectiveId: effectiveId,
                      dfHm: dfHm,
                      onTap: () => setState(() => _selectedTicketId = d.id),
                    );
                  },
                ),
    );
  }

  Widget _buildRightDetailPane(
    BuildContext context, {
    required bool docsEmpty,
    required bool filteredEmpty,
    required String? effectiveId,
    required QueryDocumentSnapshot<Map<String, dynamic>>? selectedDoc,
    required DateFormat df,
    required Color borderColor,
  }) {
    Widget emptySimple(String msg) {
      return ColoredBox(
        color: AdminTheme.supportCanvas,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              msg,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AdminTheme.textMuted,
                    height: 1.45,
                  ),
            ),
          ),
        ),
      );
    }

    Widget emptySelectTicket() {
      return ColoredBox(
        color: AdminTheme.supportCanvas,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 2),
                          ),
                        ),
                        Icon(
                          Icons.mail_outlined,
                          size: 32,
                          color: AdminTheme.textDim.withValues(alpha: 0.85),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Aucun ticket sélectionné',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Choisissez une conversation dans la liste de gauche pour afficher les détails et répondre.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AdminTheme.textMuted,
                          height: 1.45,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (docsEmpty) {
      return emptySimple('Aucun ticket pour le moment.');
    }
    if (filteredEmpty) {
      return emptySimple('Aucun ticket ne correspond à la recherche.');
    }
    if (effectiveId == null || selectedDoc == null) {
      return emptySelectTicket();
    }

    return ColoredBox(
      color: AdminTheme.supportCanvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AdminTheme.supportPanel.withValues(alpha: 0.22),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: _selectedTicketHeader(context, selectedDoc, df),
          ),
          Expanded(
            child: AdminSupportInboxQuickReplyPanel(
              key: ValueKey<String>(effectiveId),
              ticketId: effectiveId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedTicketHeader(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    DateFormat df,
  ) {
    final data = doc.data();
    final replyEmail = '${data['replyEmail']}'.trim().isEmpty
        ? '—'
        : '${data['replyEmail']}'.trim();
    final nameInParens = _supportInboxTicketNameOnly(data);
    final humanRef = paychekSupportHumanRefLine(doc.id, data);
    final subjectLine = _supportInboxSubjectLine(data);
    final ticketUserId = '${data['userId'] ?? ''}'.trim();
    final statusRaw = '${data['status']}'.trim();
    final stLook = _inboxListStatusLook(statusRaw);
    final ts = data['createdAt'];
    final created = ts is Timestamp ? df.format(ts.toDate().toLocal()) : '—';
    final isClosed = statusRaw.trim().toLowerCase() == 'closed';
    final urgent = data['staffUnread'] == true;
    final chipBorder = const Color(0xFF1E293B).withValues(alpha: 0.55);
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AdminTheme.textDim,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          fontSize: 10,
        );
    final emailTitleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: Colors.white,
          letterSpacing: -0.35,
        );
    final parenNameStyle = emailTitleStyle?.copyWith(
          color: AdminTheme.textMuted,
          fontWeight: FontWeight.w700,
        );

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E293B),
                        Color(0xFF0F172A),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF334155).withValues(alpha: 0.9),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Icon(
                      Icons.mail_outline_rounded,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SelectableText.rich(
                              TextSpan(
                                style: emailTitleStyle,
                                children: [
                                  TextSpan(text: replyEmail),
                                  if (nameInParens.isNotEmpty)
                                    TextSpan(
                                      text: ' ($nameInParens)',
                                      style: parenNameStyle ??
                                          TextStyle(
                                            color: AdminTheme.textMuted,
                                            fontWeight: FontWeight.w700,
                                            fontSize:
                                                emailTitleStyle?.fontSize ?? 20,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (urgent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AdminTheme.attachmentHighlight
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AdminTheme.attachmentHighlight
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                'URGENT',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AdminTheme.attachmentHighlight,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Envoyé le $created',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subjectLine,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AdminTheme.accent.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
                _headerIconButton(
                  context,
                  icon: Icons.open_in_full_rounded,
                  tooltip: 'Agrandir',
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            AdminSupportTicketDetailPage(ticketId: doc.id),
                      ),
                    );
                  },
                ),
                _headerIconButton(
                  context,
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'Supprimer',
                  onPressed: () => _deleteSupportTicket(context, doc.id),
                  danger: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 2),
                  child: FilledButton(
                    onPressed: isClosed
                        ? null
                        : () => _closeSupportTicket(context, doc.id),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: const Color(0xFF020617),
                      disabledBackgroundColor:
                          AdminTheme.border.withValues(alpha: 0.55),
                      disabledForegroundColor: AdminTheme.textDim,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Clôturer le ticket',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('ID Ticket:', style: labelStyle),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF020617).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: chipBorder),
                  ),
                  child: Text(
                    humanRef,
                    style: TextStyle(
                      color: AdminTheme.accent.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                Text('Statut:', style: labelStyle),
                const SizedBox(width: 8),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: stLook.dot,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  stLook.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFCBD5E1),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.35,
                      ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: ticketUserId.isNotEmpty
                      ? 'Profil utilisateur'
                      : 'Aucun compte lié',
                  onPressed: ticketUserId.isNotEmpty
                      ? () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => AdminUserAccountPage(
                                userId: ticketUserId,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: Icon(
                    Icons.person_rounded,
                    size: 22,
                    color: ticketUserId.isNotEmpty
                        ? AdminTheme.liveBlue
                        : AdminTheme.textDim.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIconButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool danger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                icon,
                size: 19,
                color: danger
                    ? const Color(0xFFF87171)
                    : AdminTheme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inboxListRow(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> d, {
    required String? effectiveId,
    required DateFormat dfHm,
    required VoidCallback onTap,
  }) {
    final data = d.data();
    final humanRef = paychekSupportHumanRefLine(d.id, data);
    final replyEmail = '${data['replyEmail']}'.trim().isEmpty
        ? '—'
        : '${data['replyEmail']}'.trim();
    final subjectLine = _supportInboxSubjectLine(data);
    final desc = '${data['description']}'.trim();
    final statusRaw = '${data['status']}'.trim();
    final stLook = _inboxListStatusLook(statusRaw);
    final ts = data['createdAt'];
    final timeShort = ts is Timestamp
        ? dfHm.format(ts.toDate().toLocal())
        : '—';
    final path = (data['attachmentStoragePath'] as String?)?.trim();
    final fname = (data['attachmentFileName'] as String?)?.trim();
    final hasAttachment =
        path != null && path.isNotEmpty && fname != null && fname.isNotEmpty;
    final pending = data['attachmentPending'] == true;
    final needsAttachMark = hasAttachment || pending;
    final unread = data['staffUnread'] == true;
    final selected = effectiveId == d.id;

    final idBadgeDec = unread
        ? BoxDecoration(
            color: AdminTheme.attachmentHighlight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AdminTheme.attachmentHighlight.withValues(alpha: 0.22),
            ),
          )
        : BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(4),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AdminTheme.accent.withValues(alpha: 0.32)
                  : Colors.transparent,
            ),
            color: selected
                ? const Color(0xFF1E293B).withValues(alpha: 0.38)
                : Colors.transparent,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (selected)
                  Container(
                    width: 3,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AdminTheme.accent,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: AdminTheme.accent.withValues(alpha: 0.45),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: idBadgeDec,
                          child: Text(
                            humanRef,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: unread
                                  ? AdminTheme.attachmentHighlight
                                  : const Color(0xFF94A3B8),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeShort,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      replyEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? Colors.white
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subjectLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.accent.withValues(alpha: 0.9),
                      ),
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF64748B),
                              height: 1.45,
                              fontSize: 12,
                            ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (needsAttachMark)
                          const Icon(
                            Icons.attach_file_rounded,
                            size: 13,
                            color: Color(0xFF475569),
                          ),
                        if (needsAttachMark) const SizedBox(width: 8),
                        if (pending) ...[
                          Icon(
                            Icons.hourglass_bottom_rounded,
                            size: 14,
                            color: AdminTheme.warning,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: stLook.dot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          stLook.label,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 17,
                          color: selected
                              ? AdminTheme.accent
                              : const Color(0xFF0F172A),
                        ),
                      ],
                    ),
                  ],
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
