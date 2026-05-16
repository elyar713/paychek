import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

import '../reglage/paychek_support_ticket_submit.dart';
import 'admin_firebase_storage_download_url.dart';
import 'admin_support_staff_reply.dart';
import 'admin_theme.dart';

class AdminSupportTicketDetailPage extends StatefulWidget {
  const AdminSupportTicketDetailPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<AdminSupportTicketDetailPage> createState() =>
      _AdminSupportTicketDetailPageState();
}

class _AdminSupportTicketDetailPageState extends State<AdminSupportTicketDetailPage> {
  final TextEditingController _replyCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  String? _pendingName;
  Uint8List? _pendingBytes;
  String? _pendingExt;

  String? _replyStatusText;
  bool _showReplyStatus = false;
  Color _replyStatusColor = AdminTheme.accent;
  Timer? _replyStatusTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markStaffSeen());
  }

  @override
  void dispose() {
    _replyStatusTimer?.cancel();
    _replyCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _hideReplyStatus() {
    if (!mounted) return;
    setState(() => _showReplyStatus = false);
  }

  void _showReplyStatusLine(String text, Color color, Duration visibleFor) {
    _replyStatusTimer?.cancel();
    setState(() {
      _replyStatusText = text;
      _replyStatusColor = color;
      _showReplyStatus = true;
    });
    _replyStatusTimer = Timer(visibleFor, _hideReplyStatus);
  }

  Future<void> _markStaffSeen() async {
    await paychekStaffMarkTicketSeen(widget.ticketId);
  }

  static String _kindFr(String raw) {
    switch (raw) {
      case 'account':
        return 'Compte';
      case 'billing':
        return 'Facturation';
      case 'feature':
        return 'Idée / fonctionnalité';
      case 'other':
      default:
        return raw.isEmpty ? '—' : raw;
    }
  }

  DocumentReference<Map<String, dynamic>> get _ticketRef =>
      FirebaseFirestore.instance
          .collection(kPaychekSupportTicketsCollection)
          .doc(widget.ticketId);

  void _clearPending() {
    setState(() {
      _pendingName = null;
      _pendingBytes = null;
      _pendingExt = null;
    });
  }

  Future<void> _pickImage() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (r == null || r.files.isEmpty) return;
    final f = r.files.single;
    final bytes = f.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de lire l’image (réessaie avec un autre fichier).'),
          ),
        );
      }
      return;
    }
    if (bytes.length > kPaychekSupportAttachmentMaxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Fichier trop volumineux (max ${kPaychekSupportAttachmentMaxBytes ~/ (1024 * 1024)} Mo).',
            ),
          ),
        );
      }
      return;
    }
    final ext = path.extension(f.name).toLowerCase();
    final bare = ext.startsWith('.') ? ext.substring(1) : ext;
    if (!kPaychekSupportAttachmentExtensions.contains(bare)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format d’image non pris en charge.')),
        );
      }
      return;
    }
    setState(() {
      _pendingBytes = bytes;
      _pendingName = f.name;
      _pendingExt = bare;
    });
  }

  Future<void> _pickPdf() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
      withData: true,
    );
    if (r == null || r.files.isEmpty) return;
    final f = r.files.single;
    final bytes = f.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de lire le PDF — réessaie.'),
          ),
        );
      }
      return;
    }
    if (bytes.length > kPaychekSupportAttachmentMaxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Fichier trop volumineux (max ${kPaychekSupportAttachmentMaxBytes ~/ (1024 * 1024)} Mo).',
            ),
          ),
        );
      }
      return;
    }
    setState(() {
      _pendingBytes = bytes;
      _pendingName = f.name;
      _pendingExt = 'pdf';
    });
  }

  Future<void> _openAttachment(String storagePath) async {
    try {
      final url = await paychekAdminStorageDownloadUrl(storagePath);
      final uri = Uri.parse(url);
      final mode = kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication;
      final ok = await launchUrl(uri, mode: mode);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d’ouvrir le lien. Utilise « Copier le lien ».'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ouverture impossible : $e')),
      );
    }
  }

  Future<void> _copyAttachmentUrl(String storagePath) async {
    try {
      final url = await paychekAdminStorageDownloadUrl(storagePath);
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lien copié dans le presse-papiers')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copie impossible : $e')),
      );
    }
  }

  Future<void> _sendReply() async {
    final textRaw = _replyCtrl.text.trim();
    final hasFile = _pendingBytes != null &&
        _pendingBytes!.isNotEmpty &&
        _pendingExt != null;
    if (textRaw.isEmpty && !hasFile) return;

    final text = textRaw.isEmpty && hasFile
        ? '(Pièce jointe)'
        : textRaw;

    setState(() {
      _sending = true;
      _replyStatusTimer?.cancel();
      _showReplyStatus = false;
    });
    try {
      final r = await paychekStaffSendTicketReply(
        ticketId: widget.ticketId,
        trimmedMessageTextOrPlaceholder: text,
        attachmentBytes: hasFile ? _pendingBytes : null,
        attachmentOrigName: _pendingName,
        attachmentExtBare: _pendingExt,
      );
      _replyCtrl.clear();
      _clearPending();

      if (mounted) {
        _showReplyStatusLine(
          r.snackMessage,
          r.emailedViaCloudFunction ? AdminTheme.accent : AdminTheme.warning,
          Duration(seconds: r.emailedViaCloudFunction ? 8 : 14),
        );
      }
    } catch (e) {
      if (mounted) {
        _showReplyStatusLine(
          'Erreur : $e',
          AdminTheme.attachmentHighlight,
          const Duration(seconds: 14),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _confirmDeleteTicket() async {
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
                style: FilledButton.styleFrom(backgroundColor: AdminTheme.warning),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;
    if (!go || !mounted) return;

    try {
      final msgs =
          await _ticketRef.collection(kPaychekSupportTicketMessagesSubcollection).get();
      final batch = FirebaseFirestore.instance.batch();
      for (final d in msgs.docs) {
        batch.delete(d.reference);
      }
      batch.delete(_ticketRef);
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket supprimé')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Suppression impossible : $e')),
        );
      }
    }
  }

  Widget _metaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AdminTheme.border.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _messageBubble(
    BuildContext context,
    Map<String, dynamic> md,
    Timestamp? ts,
    DateFormat msgDf,
  ) {
    final body = '${md['body']}'.trim();
    final staff = '${md['sender']}' == 'staff';
    final tStr = ts != null ? msgDf.format(ts.toDate().toLocal()) : '';
    final attachPath = (md['attachmentStoragePath'] as String?)?.trim();
    final attachName = (md['attachmentFileName'] as String?)?.trim();
    final hasAttach =
        attachPath != null && attachPath.isNotEmpty && attachName != null && attachName.isNotEmpty;

    return Align(
      alignment: staff ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: staff
                ? AdminTheme.accent.withValues(alpha: 0.16)
                : AdminTheme.card,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(staff ? 16 : 4),
              bottomRight: Radius.circular(staff ? 4 : 16),
            ),
            border: Border.all(
              color: staff
                  ? AdminTheme.accent.withValues(alpha: 0.35)
                  : AdminTheme.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff
                      ? 'SUPPORT • ${'${md['staffEmail'] ?? '?'}'.toUpperCase()}'
                      : 'UTILISATEUR',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: staff ? AdminTheme.accent : AdminTheme.textMuted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                ),
                if (tStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tStr,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AdminTheme.textDim,
                        ),
                  ),
                ],
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (hasAttach) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    decoration: AdminTheme.attachmentPanelDecoration(),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openAttachment(attachPath),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminTheme.attachmentHighlight,
                            side: BorderSide(
                              color: AdminTheme.attachmentHighlight
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                          icon: Icon(
                            attachName.toLowerCase().endsWith('.pdf')
                                ? Icons.picture_as_pdf_outlined
                                : Icons.image_outlined,
                            size: 18,
                          ),
                          label: Text(
                            attachName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _copyAttachmentUrl(attachPath),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminTheme.attachmentHighlight,
                            side: BorderSide(
                              color: AdminTheme.attachmentHighlight
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                          icon: const Icon(Icons.link, size: 18),
                          label: const Text('Copier le lien'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd('fr_FR').add_Hm();
    final msgDf = DateFormat('dd/MM/y HH:mm', 'fr_FR');

    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _ticketRef.snapshots(),
          builder: (context, docSnap) {
            if (docSnap.hasError) {
              return Center(
                child: SelectableText(
                  '${docSnap.error}',
                  style: TextStyle(color: AdminTheme.warning),
                ),
              );
            }
            if (!docSnap.hasData || !docSnap.data!.exists) {
              return const Center(child: Text('Ticket introuvable'));
            }

            final d = docSnap.data!.data()!;
            final kindLabel = _kindFr('${d['kind']}');
            final refLine = paychekSupportHumanRefLine(widget.ticketId, d);
            final replyEmail = '${d['replyEmail']}'.trim();
            final desc = '${d['description']}'.trim();
            final path = (d['attachmentStoragePath'] as String?)?.trim();
            final fileName = (d['attachmentFileName'] as String?)?.trim();
            final pending = d['attachmentPending'] == true;
            final uploadStatus = '${d['attachmentUploadStatus'] ?? ''}'.trim();
            final uploadDetail =
                (d['attachmentUploadDetail'] as String?)?.trim() ?? '';
            final status = '${d['status']}'.trim().isEmpty
                ? 'open'
                : '${d['status']}'.trim();
            final created = d['createdAt'];
            final createdStr = created is Timestamp
                ? df.format(created.toDate().toLocal())
                : '—';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 12, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        tooltip: 'Retour',
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    kindLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 21,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AdminTheme.accent.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          AdminTheme.accent.withValues(alpha: 0.45),
                                    ),
                                  ),
                                  child: Text(
                                    refLine,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              replyEmail,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AdminTheme.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _metaChip(status.toUpperCase()),
                      IconButton(
                        tooltip: 'Supprimer le ticket',
                        icon: const Icon(Icons.delete_outline),
                        color: AdminTheme.textMuted,
                        onPressed: _confirmDeleteTicket,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'Ouvert le $createdStr',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AdminTheme.textMuted,
                        ),
                  ),
                ),
                if (pending)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: AdminTheme.attachmentPanelDecoration(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_file_rounded,
                            size: 18,
                            color: AdminTheme.attachmentHighlight,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pièce jointe utilisateur : envoi en cours…',
                              style: TextStyle(
                                color: AdminTheme.attachmentHighlight,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (uploadStatus.isNotEmpty &&
                    (path == null || path.isEmpty)) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      'Pièce jointe : échec ($uploadStatus)'
                      '${uploadDetail.isEmpty ? '' : '\n$uploadDetail'}',
                      style: TextStyle(color: AdminTheme.warning, fontSize: 13),
                    ),
                  ),
                ],
                if (path != null &&
                    path.isNotEmpty &&
                    fileName != null &&
                    fileName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: AdminTheme.attachmentPanelDecoration(),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _openAttachment(path),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AdminTheme.attachmentHighlight,
                              side: BorderSide(
                                color: AdminTheme.attachmentHighlight
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                            icon: Icon(
                              fileName.toLowerCase().endsWith('.pdf')
                                  ? Icons.picture_as_pdf_outlined
                                  : Icons.download_outlined,
                              size: 18,
                            ),
                            label: Text('Message initial · $fileName'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _copyAttachmentUrl(path),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AdminTheme.attachmentHighlight,
                              side: BorderSide(
                                color: AdminTheme.attachmentHighlight
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                            icon: const Icon(Icons.link, size: 18),
                            label: const Text('Copier le lien'),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _ticketRef
                        .collection(kPaychekSupportTicketMessagesSubcollection)
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, q) {
                      if (q.hasError) {
                        return Center(child: SelectableText('${q.error}'));
                      }

                      final docs = q.data?.docs ?? [];
                      final bubbles = <Widget>[];

                      void addSyntheticUserMessage() {
                        if (desc.isEmpty) return;
                        bubbles.add(
                          _messageBubble(
                            context,
                            <String, dynamic>{'sender': 'user', 'body': desc},
                            created is Timestamp ? created : null,
                            msgDf,
                          ),
                        );
                        bubbles.add(const SizedBox(height: 12));
                      }

                      if (docs.isEmpty) {
                        addSyntheticUserMessage();
                      } else {
                        for (final doc in docs) {
                          final m = doc.data();
                          final ct = m['createdAt'];
                          bubbles.add(
                            _messageBubble(
                              context,
                              m,
                              ct is Timestamp ? ct : null,
                              msgDf,
                            ),
                          );
                          bubbles.add(const SizedBox(height: 12));
                        }
                      }

                      return ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        children: bubbles,
                      );
                    },
                  ),
                ),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AdminTheme.card,
                    border: Border(
                      top: BorderSide(color: AdminTheme.border),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      14,
                      16,
                      14 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AdminTheme.bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AdminTheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _replyCtrl,
                                minLines: 3,
                                maxLines: 6,
                                decoration: InputDecoration(
                                  hintText: 'Réponse au client…',
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(14, 12, 14, 4),
                                  hintStyle: TextStyle(
                                    color: AdminTheme.textDim,
                                  ),
                                ),
                              ),
                              if (_pendingName != null) ...[
                                const Divider(height: 1),
                                ListTile(
                                  dense: true,
                                  leading: Icon(
                                    (_pendingExt == 'pdf')
                                        ? Icons.picture_as_pdf_outlined
                                        : Icons.image_outlined,
                                    color: AdminTheme.attachmentHighlight,
                                  ),
                                  title: Text(
                                    _pendingName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Retirer',
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: _clearPending,
                                  ),
                                ),
                              ],
                              Padding(
                                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                                child: Row(
                                  children: [
                                    IconButton.filledTonal(
                                      tooltip: 'Ajouter une photo',
                                      onPressed: _sending ? null : _pickImage,
                                      style: IconButton.styleFrom(
                                        backgroundColor: AdminTheme.accentDim
                                            .withValues(alpha: 0.25),
                                      ),
                                      icon: const Icon(
                                        Icons.photo_library_outlined,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filledTonal(
                                      tooltip: 'Ajouter un PDF',
                                      onPressed: _sending ? null : _pickPdf,
                                      style: IconButton.styleFrom(
                                        backgroundColor: AdminTheme.accentDim
                                            .withValues(alpha: 0.25),
                                      ),
                                      icon: const Icon(
                                        Icons.picture_as_pdf_outlined,
                                        size: 22,
                                      ),
                                    ),
                                    const Spacer(),
                                    FilledButton.icon(
                                      onPressed: _sending ? null : _sendReply,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AdminTheme.accent,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 14,
                                        ),
                                      ),
                                      icon: _sending
                                          ? SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.black
                                                    .withValues(alpha: 0.75),
                                              ),
                                            )
                                          : const Icon(Icons.send_rounded),
                                      label: const Text(
                                        'Envoyer',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_showReplyStatus &&
                                  (_replyStatusText ?? '').isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 6, 12, 0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 520,
                                      ),
                                      child: Text(
                                        _replyStatusText!,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: _replyStatusColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Réponse enregistrée dans le ticket. E-mail automatique '
                          'si la fonction Cloud est active ; sinon ouverture messagerie ou copie.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AdminTheme.textDim,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
