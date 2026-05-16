import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../reglage/paychek_support_routing.dart';
import '../reglage/paychek_support_ticket_submit.dart';
import 'admin_support_send_email.dart';

String paychekStaffSupportKindLabelFr(String raw) {
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

Future<void> paychekStaffMarkTicketSeen(String ticketId) async {
  try {
    await FirebaseFirestore.instance
        .collection(kPaychekSupportTicketsCollection)
        .doc(ticketId)
        .set(<String, dynamic>{
      'staffUnread': false,
    }, SetOptions(merge: true));
  } catch (_) {}
}

Future<void> staffSupportLaunchMailtoFallback({
  required String clientEmail,
  required String ticketHumanLabel,
  required String kindLabel,
  required String messageBody,
  bool hasAttachment = false,
}) async {
  final staff = FirebaseAuth.instance.currentUser?.email?.trim() ?? '';

  final subject =
      'Paychek — Réponse à votre demande · $kindLabel (#$ticketHumanLabel)';
  final body = StringBuffer()
    ..writeln(messageBody)
    ..writeln();
  if (hasAttachment) {
    body.writeln(
      '(Une pièce jointe est disponible dans votre ticket dans l’application Paychek.)',
    );
    body.writeln();
  }
  body
    ..writeln('---')
    ..writeln('Référence dossier : $ticketHumanLabel');

  if (staff.isNotEmpty) {
    body.writeln('Support Paychek : $staff');
  }
  body.writeln('Merci d’utiliser Paychek.');

  var bodyStr = body.toString();
  const maxLen = 1900;
  if (bodyStr.length > maxLen) {
    bodyStr =
        '${bodyStr.substring(0, maxLen)}\n\n[Suite du message dans le back-office.]';
  }

  final uri = Uri(
    scheme: 'mailto',
    path: clientEmail,
    queryParameters: <String, String>{
      'subject': subject,
      'body': bodyStr,
      'bcc': kPaychekSupportStaffInboxEmail,
    },
  );

  final launched = await launchUrl(
    uri,
    mode:
        kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
  );
  if (launched) return;

  await Clipboard.setData(
    ClipboardData(
      text:
          'À : $clientEmail\nBcc : $kPaychekSupportStaffInboxEmail\nSujet : $subject\n\n$bodyStr',
    ),
  );
}

/// Persiste message + mise à jour ticket, envoi SMTP si dispo sinon mailto.
/// Jeté sur erreur (Storage, réseau, données invalides).
Future<({bool emailedViaCloudFunction, String snackMessage})>
    paychekStaffSendTicketReply({
  required String ticketId,
  required String trimmedMessageTextOrPlaceholder,
  Uint8List? attachmentBytes,
  String? attachmentOrigName,
  String? attachmentExtBare,
}) async {
  final ticketRef =
      FirebaseFirestore.instance.collection(kPaychekSupportTicketsCollection).doc(ticketId);

  final ticketSnap = await ticketRef.get();
  if (!ticketSnap.exists) {
    throw StateError('Ticket introuvable.');
  }
  final authUser = FirebaseAuth.instance.currentUser;
  if (authUser == null) {
    throw StateError('Connexion administrateur requise.');
  }

  final td = ticketSnap.data() ?? {};
  final replyEmail = '${td['replyEmail']}'.trim();
  if (replyEmail.isEmpty || !replyEmail.contains('@')) {
    throw StateError('E-mail client invalide sur le ticket (replyEmail).');
  }
  final ticketOwnerUid = '${td['userId']}'.trim();

  final kindLabel = paychekStaffSupportKindLabelFr('${td['kind']}');
  final ticketHumanLabel = paychekSupportHumanRefLine(ticketId, td);
  final text = trimmedMessageTextOrPlaceholder;

  String? storagePath;
  String? fileName;
  String? contentType;

  bool hasFile = false;
  final ab = attachmentBytes;
  final ae = attachmentExtBare;
  if (ab != null && ab.isNotEmpty && ae != null && ae.trim().isNotEmpty) {
    hasFile = true;
    if (ticketOwnerUid.isEmpty) {
      throw StateError(
        'UID client manquant sur le ticket — impossible d’ajouter une pièce jointe '
        '(chemin Storage). Réponse texte seule autorisée.',
      );
    }
    final bytes = ab;
    final orig = (attachmentOrigName ?? 'fichier').trim();
    final extClean = ae.trim();
    fileName = paychekSupportSanitizeAttachmentFileName(orig, extClean);
    storagePath =
        'support_staff_attachments/$ticketOwnerUid/$ticketId/$fileName';
    contentType = paychekSupportContentTypeForFileName(fileName);
    final ct = contentType.trim().isNotEmpty
        ? contentType.trim()
        : 'application/octet-stream';

    await authUser.getIdToken(true);

    await FirebaseStorage.instance.ref(storagePath).putData(
          bytes,
          SettableMetadata(
            contentType: ct,
            customMetadata: <String, String>{
              if (orig.isNotEmpty) 'originalName': orig,
            },
          ),
        ).timeout(kPaychekSupportUploadTimeout);
  }

  final staffEmail = authUser.email;

  final msgMap = <String, dynamic>{
    'sender': 'staff',
    'body': text,
    'createdAt': FieldValue.serverTimestamp(),
  };
  final se = staffEmail?.trim();
  if (se != null && se.isNotEmpty) {
    msgMap['staffEmail'] = se;
  }
  if (storagePath != null) {
    msgMap['attachmentStoragePath'] = storagePath;
  }
  if (fileName != null) {
    msgMap['attachmentFileName'] = fileName;
  }
  if (contentType != null) {
    msgMap['attachmentContentType'] = contentType;
  }

  await ticketRef.collection(kPaychekSupportTicketMessagesSubcollection).add(msgMap);

  await ticketRef.update(<String, dynamic>{
    'status': 'answered',
    'updatedAt': FieldValue.serverTimestamp(),
  });

  final emailOutcome = await paychekTrySendStaffSupportEmail(
    ticketId: ticketId,
    messageBody: text,
    attachmentStoragePath: storagePath,
    attachmentFileName: fileName,
    attachmentContentType: contentType,
  );
  final emailed = emailOutcome.ok;
  if (!emailed) {
    await staffSupportLaunchMailtoFallback(
      clientEmail: replyEmail,
      ticketHumanLabel: ticketHumanLabel,
      kindLabel: kindLabel,
      messageBody: text,
      hasAttachment: hasFile,
    );
  }

  String snackMessage;
  if (emailed) {
    snackMessage = 'Réponse envoyée (e-mail automatique).';
  } else {
    final code = (emailOutcome.code ?? '').trim();
    final msg = (emailOutcome.message ?? '').trim();
    final detail = [code, msg].where((s) => s.isNotEmpty).join(' — ');
      if (detail.isNotEmpty) {
      final short = detail.length > 220 ? '${detail.substring(0, 220)}…' : detail;
      snackMessage =
          'Réponse enregistrée. E-mail auto impossible : $short '
          '(Resend : PAYCHEK_RESEND_API_KEY + domaine verifie ; secours SMTP : PAYCHEK_SMTP_* + secret, '
          'région europe-west1, logs). Sinon brouillon mailto / presse-papiers.';
    } else {
      snackMessage =
          'Réponse enregistrée. E-mail auto indisponible — brouillon mailto ou presse-papiers.';
    }
  }

  return (emailedViaCloudFunction: emailed, snackMessage: snackMessage);
}
