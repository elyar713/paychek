import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

import '../reglage/paychek_support_ticket_submit.dart';
import 'admin_firebase_storage_download_url.dart';
import 'admin_support_staff_reply.dart';
import 'admin_theme.dart';

/// Fil + réponse sans ouvrir la page dédiée (liste Support).
class AdminSupportInboxQuickReplyPanel extends StatefulWidget {
  const AdminSupportInboxQuickReplyPanel({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<AdminSupportInboxQuickReplyPanel> createState() =>
      _AdminSupportInboxQuickReplyPanelState();
}

class _AdminSupportInboxQuickReplyPanelState
    extends State<AdminSupportInboxQuickReplyPanel> {
  final _replyCtrl = TextEditingController();
  bool _sending = false;
  String? _pendingName;
  Uint8List? _pendingBytes;
  String? _pendingExt;

  String? _replyStatusText;
  bool _showReplyStatus = false;
  Color _replyStatusColor = AdminTheme.accent;
  Timer? _replyStatusTimer;

  DocumentReference<Map<String, dynamic>> get _ticketRef =>
      FirebaseFirestore.instance
          .collection(kPaychekSupportTicketsCollection)
          .doc(widget.ticketId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      paychekStaffMarkTicketSeen(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _replyStatusTimer?.cancel();
    _replyCtrl.dispose();
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
            content: Text(
              'Impossible de lire l’image (réessaie avec un autre fichier).',
            ),
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
          const SnackBar(content: Text('Impossible de lire le PDF — réessaie.')),
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
            content: Text(
              'Impossible d’ouvrir le lien. Utilise une autre méthode depuis la fiche.',
            ),
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

  Future<void> _send() async {
    final textRaw = _replyCtrl.text.trim();
    final hasFile =
        _pendingBytes != null && _pendingBytes!.isNotEmpty && _pendingExt != null;
    if (textRaw.isEmpty && !hasFile) return;

    final text = textRaw.isEmpty && hasFile ? '(Pièce jointe)' : textRaw;

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

  Widget _sectionDividerRow(BuildContext context, String label) {
    final lineColor = const Color(0xFF1E293B).withValues(alpha: 0.55);
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: lineColor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.8,
                ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: lineColor),
        ),
      ],
    );
  }

  Widget _bubble(
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
    final hasAttach = attachPath != null &&
        attachPath.isNotEmpty &&
        attachName != null &&
        attachName.isNotEmpty;

    return Align(
      alignment: staff ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color:
                staff ? AdminTheme.accent.withValues(alpha: 0.14) : AdminTheme.bg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(staff ? 12 : 3),
              bottomRight: Radius.circular(staff ? 3 : 12),
            ),
            border: Border.all(
              color: staff
                  ? AdminTheme.accent.withValues(alpha: 0.28)
                  : AdminTheme.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
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
                        fontSize: 10,
                      ),
                ),
                if (tStr.isNotEmpty)
                  Text(
                    tStr,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AdminTheme.textDim,
                          fontSize: 10,
                        ),
                  ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.3),
                  ),
                ],
                if (hasAttach) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    decoration: AdminTheme.attachmentPanelDecoration(),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _openAttachment(attachPath),
                        icon: Icon(
                          attachName.toLowerCase().endsWith('.pdf')
                              ? Icons.picture_as_pdf_outlined
                              : Icons.image_outlined,
                          size: 16,
                          color: AdminTheme.attachmentHighlight,
                        ),
                        label: Text(
                          attachName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AdminTheme.attachmentHighlight,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
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
    final msgDf = DateFormat('dd/MM/y HH:mm', 'fr_FR');
    final footerBorder = const Color(0xFF1E293B).withValues(alpha: 0.55);
    final slateFill = const Color(0xFF0F172A).withValues(alpha: 0.72);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _ticketRef.snapshots(),
      builder: (context, tdSnap) {
        if (!tdSnap.hasData || !tdSnap.data!.exists) {
          return const SizedBox.shrink();
        }
        final d = tdSnap.data!.data()!;
        final desc = '${d['description']}'.trim();
        final replyEmail = '${d['replyEmail']}'.trim();
        final ipath = (d['attachmentStoragePath'] as String?)?.trim();
        final iname = (d['attachmentFileName'] as String?)?.trim();
        final ich = ipath != null &&
            ipath.isNotEmpty &&
            iname != null &&
            iname.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AdminTheme.supportPanel.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionDividerRow(context, 'Message original'),
                          const SizedBox(height: 18),
                          if (desc.isNotEmpty) ...[
                            SelectableText(
                              desc,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: const Color(0xFFCBD5E1),
                                    height: 1.55,
                                    fontSize: 15,
                                  ),
                            ),
                          ],
                          if (ich) ...[
                            const SizedBox(height: 22),
                            Material(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () => _openAttachment(ipath),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E293B),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.attach_file_rounded,
                                          size: 20,
                                          color: AdminTheme.accent,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              iname,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Pièce jointe · ouvrir / télécharger',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: const Color(0xFF64748B),
                                                    fontSize: 10,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => _openAttachment(ipath),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AdminTheme.accent,
                                          side: BorderSide(
                                            color: AdminTheme.accent
                                                .withValues(alpha: 0.25),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                        ),
                                        child: const Text(
                                          'Télécharger',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _ticketRef
                                .collection(
                                  kPaychekSupportTicketMessagesSubcollection,
                                )
                                .orderBy('createdAt', descending: false)
                                .snapshots(),
                            builder: (context, q) {
                              if (q.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    '${q.error}',
                                    style: TextStyle(
                                      color: AdminTheme.warning,
                                    ),
                                  ),
                                );
                              }
                              final docs = q.data?.docs ?? [];
                              final staffDocs = docs.where((doc) {
                                final m = doc.data();
                                return '${m['sender']}'.trim() == 'staff';
                              }).toList();
                              if (staffDocs.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final children = <Widget>[
                                const SizedBox(height: 20),
                              ];
                              for (final doc in staffDocs) {
                                final m = doc.data();
                                final ct = m['createdAt'];
                                children.add(
                                  _bubble(
                                    context,
                                    m,
                                    ct is Timestamp ? ct : null,
                                    msgDf,
                                  ),
                                );
                                children.add(const SizedBox(height: 8));
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: children,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: BoxDecoration(
                color: AdminTheme.supportPanel.withValues(alpha: 0.82),
                border: Border(top: BorderSide(color: footerBorder)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.subdirectory_arrow_left_rounded,
                            size: 14,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              replyEmail.isEmpty
                                  ? 'Répondre au client'
                                  : 'Répondre à $replyEmail',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    letterSpacing: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          TextField(
                            controller: _replyCtrl,
                            minLines: 5,
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: 'Rédigez votre réponse ici…',
                              hintStyle: TextStyle(
                                color: AdminTheme.textDim,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: slateFill,
                              contentPadding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                54,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: footerBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: footerBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AdminTheme.accent.withValues(alpha: 0.45),
                                  width: 1.2,
                                ),
                              ),
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(height: 1.4, fontSize: 13),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Photo',
                                  onPressed: _sending ? null : _pickImage,
                                  icon: Icon(
                                    Icons.photo_library_outlined,
                                    size: 20,
                                    color: AdminTheme.textMuted,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'PDF',
                                  onPressed: _sending ? null : _pickPdf,
                                  icon: Icon(
                                    Icons.picture_as_pdf_outlined,
                                    size: 20,
                                    color: AdminTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                FilledButton.icon(
                                  onPressed: _sending ? null : _send,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF059669),
                                    foregroundColor: const Color(0xFF020617),
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: _sending
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black
                                                .withValues(alpha: 0.75),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send_rounded,
                                          size: 16,
                                        ),
                                  label: const Text(
                                    'ENVOYER',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_showReplyStatus &&
                          (_replyStatusText ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
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
                      ],
                      if (_pendingName != null) ...[
                        const SizedBox(height: 8),
                        ListTile(
                          dense: true,
                          tileColor: slateFill,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: footerBorder),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          leading: Icon(
                            _pendingExt == 'pdf'
                                ? Icons.picture_as_pdf_outlined
                                : Icons.image_outlined,
                            color: AdminTheme.accent,
                            size: 22,
                          ),
                          title: Text(
                            _pendingName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: _clearPending,
                            tooltip: 'Retirer',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
