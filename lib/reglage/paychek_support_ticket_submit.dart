import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:path/path.dart' as path;

import 'paychek_support_read_file_bytes.dart';
import 'paychek_support_routing.dart';
import 'paychek_user_firestore.dart';

/// Collection racine synchronisée avec [firestore.rules].
const String kPaychekSupportTicketsCollection = 'paychek_support_tickets';

/// Sous-collection pour le fil de discussion (Firestore rules).
const String kPaychekSupportTicketMessagesSubcollection = 'messages';

const int kPaychekSupportAttachmentMaxBytes = 10 * 1024 * 1024;

/// Délais uploads — évite un spinner infini si Storage / réseau ne répond pas.
const Duration kPaychekSupportUploadTimeout = Duration(seconds: 120);

/// Firestore / Auth : limites pour réseau mobile lent (sans cela [batch.commit] peut ne jamais finir).
const Duration kPaychekSupportFirestoreReadTimeout = Duration(seconds: 20);
const Duration kPaychekSupportFirestoreWriteTimeout = Duration(seconds: 50);
const Duration kPaychekSupportAuthTokenTimeout = Duration(seconds: 25);
const Duration kPaychekSupportAttachmentBytesReadTimeout = Duration(seconds: 45);

const Set<String> kPaychekSupportAttachmentExtensions = {
  'pdf',
  'jpg',
  'jpeg',
  'png',
  'webp',
};

/// Référence lisible dans les mails (ex. PC-K4M9Q2XB), distincte de l’ID Firestore.
const String _kTicketRefAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

String paychekSupportNewTicketRef() {
  final r = Random.secure();
  final buf = StringBuffer('PC-');
  for (var i = 0; i < 8; i++) {
    buf.write(_kTicketRefAlphabet[r.nextInt(_kTicketRefAlphabet.length)]);
  }
  return buf.toString();
}

/// Pour l’admin / sujets mail : `ticketRef` si disponible sinon l’ID Firestore.
String paychekSupportHumanRefLine(
  String firestoreDocId,
  Map<String, dynamic> doc,
) {
  final tr = '${doc['ticketRef'] ?? ''}'.trim();
  return tr.length >= 6 ? tr : firestoreDocId;
}

String paychekSupportSanitizeAttachmentFileName(
  String raw,
  String extensionWithoutDot,
) {
  var stem = path.basenameWithoutExtension(raw).trim().replaceAll(
        RegExp(r'[^a-zA-Z0-9._-]+'),
        '_',
      );
  if (stem.isEmpty || stem.replaceAll('.', '').isEmpty) stem = 'fichier';
  final ts = DateTime.now().millisecondsSinceEpoch;
  var out = '${stem}_$ts.$extensionWithoutDot';
  out = out.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
  if (out.length > 120) out = out.substring(out.length - 120);
  return out;
}

String paychekSupportContentTypeForFileName(String fileName) {
  switch (path.extension(fileName).toLowerCase()) {
    case '.pdf':
      return 'application/pdf';
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.png':
      return 'image/png';
    case '.webp':
      return 'image/webp';
    default:
      return 'application/octet-stream';
  }
}

/// Préfère [FilePicker] avec `withData: true` ; sur mobile, secours lecture [path].
Future<Uint8List?> paychekSupportReadPlatformFileBytes(PlatformFile f) async {
  if (f.bytes != null && f.bytes!.isNotEmpty) return f.bytes;
  if (!kIsWeb) {
    final fromPath = await paychekSupportReadLocalPathAsBytes(f.path);
    if (fromPath != null && fromPath.isNotEmpty) return fromPath;
  }
  debugPrint(
    '[Paychek] Fichier sans octets (bytes vides, path ${kIsWeb ? "n/a web" : f.path}).',
  );
  return null;
}

/// Soumet la demande. Retour :
/// – `true` si pas de fichier ou fichier bien envoyé.
/// – `false` si ticket enregistré mais upload Storage impossible (voir champs Doc).
Future<bool> submitPaychekSupportTicket({
  required String replyEmail,
  required String kind,
  required String description,
  PlatformFile? attachment,
  /// Octets lus au moment du choix du fichier (surtout Web : [PlatformFile.bytes]
  /// peut être vide plus tard).
  Uint8List? attachmentBytes,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw StateError('FirebaseAuth.instance.currentUser is null');

  final docRef = FirebaseFirestore.instance
      .collection(kPaychekSupportTicketsCollection)
      .doc();
  final uid = user.uid;

  Uint8List? uploadBytes;
  String? attachmentFileName;
  String? attachmentContentType;
  String? storagePath;

  if (attachment != null) {
    final ext = path.extension(attachment.name).toLowerCase();
    final extBare = ext.startsWith('.') ? ext.substring(1) : ext;
    if (!kPaychekSupportAttachmentExtensions.contains(extBare)) {
      throw FormatException('Extension non autorisée: $extBare');
    }
    uploadBytes = (attachmentBytes != null && attachmentBytes.isNotEmpty)
        ? attachmentBytes
        : await paychekSupportReadPlatformFileBytes(attachment)
            .timeout(kPaychekSupportAttachmentBytesReadTimeout);
    if (uploadBytes == null || uploadBytes.isEmpty) {
      throw StateError('Impossible de lire les octets du fichier.');
    }
    if (uploadBytes.length > kPaychekSupportAttachmentMaxBytes) {
      throw ArgumentError.value(
        uploadBytes.length,
        'size',
        'Attachment exceeds ${kPaychekSupportAttachmentMaxBytes ~/ (1024 * 1024)} MB',
      );
    }
    attachmentFileName =
        paychekSupportSanitizeAttachmentFileName(attachment.name, extBare);
    attachmentContentType =
        paychekSupportContentTypeForFileName(attachmentFileName);
    storagePath =
        'support_attachments/$uid/${docRef.id}/$attachmentFileName';
  }

  final dn = user.displayName?.trim();
  var replyFirstName = '';
  var replyLastName = '';
  try {
    final userSnap = await FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(uid)
        .get()
        .timeout(kPaychekSupportFirestoreReadTimeout);
    if (userSnap.exists) {
      final u = userSnap.data()!;
      replyFirstName = '${u['firstName'] ?? ''}'.trim();
      replyLastName = '${u['lastName'] ?? ''}'.trim();
    }
  } catch (e, st) {
    if (e is TimeoutException) {
      debugPrint('[Paychek] support ticket user profile read: timeout');
    } else {
      debugPrint('[Paychek] support ticket user profile read: $e\n$st');
    }
  }

  final ticketPayload = <String, dynamic>{
    'userId': uid,
    'ticketRef': paychekSupportNewTicketRef(),
    if (dn != null && dn.isNotEmpty) 'replyDisplayName': dn,
    if (replyFirstName.isNotEmpty) 'replyFirstName': replyFirstName,
    if (replyLastName.isNotEmpty) 'replyLastName': replyLastName,
    'replyEmail': replyEmail,
    'staffNotifyEmail': kPaychekSupportStaffInboxEmail,
    'kind': kind,
    'description': description,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'status': 'open',
    'staffUnread': true,
    if (attachment != null) 'attachmentPending': true,
  };

  final batch = FirebaseFirestore.instance.batch();
  batch.set(docRef, ticketPayload);
  batch.set(
    docRef.collection(kPaychekSupportTicketMessagesSubcollection).doc(),
    <String, dynamic>{
      'sender': 'user',
      'body': description,
      'createdAt': FieldValue.serverTimestamp(),
    },
  );
  await batch.commit().timeout(kPaychekSupportFirestoreWriteTimeout);

  if (attachment == null) return true;

  try {
    await user.getIdToken(true).timeout(kPaychekSupportAuthTokenTimeout);

    await FirebaseStorage.instance.ref(storagePath!).putData(
          uploadBytes!,
          SettableMetadata(
            contentType: attachmentContentType!,
            customMetadata: <String, String>{
              if (attachment.name.trim().isNotEmpty)
                'originalName': attachment.name,
            },
          ),
        ).timeout(kPaychekSupportUploadTimeout);

    await docRef
        .update(<String, dynamic>{
      'attachmentStoragePath': storagePath,
      'attachmentFileName': attachmentFileName,
      'attachmentContentType': attachmentContentType,
      'updatedAt': FieldValue.serverTimestamp(),
      'attachmentPending': FieldValue.delete(),
      'attachmentUploadStatus': FieldValue.delete(),
      'attachmentUploadDetail': FieldValue.delete(),
    })
        .timeout(kPaychekSupportFirestoreWriteTimeout);
    return true;
  } on TimeoutException catch (e, st) {
    debugPrint('[Paychek] attachment pipeline timeout: $e\n$st');
    await _patchAttachmentFailure(
      docRef,
      'timeout',
      'deadline exceeded (auth token, upload, or Firestore save)',
    );
    return false;
  } catch (e, st) {
    debugPrint('[Paychek] Storage upload failed: $e\n$st');
    var detail = e.toString();
    if (detail.length > 520) {
      detail = '${detail.substring(0, 520)}…';
    }
    await _patchAttachmentFailure(docRef, 'error', detail);
    return false;
  }
}

Future<void> _patchAttachmentFailure(
  DocumentReference<Map<String, dynamic>> docRef,
  String status,
  String detail,
) async {
  try {
    await docRef
        .update(<String, dynamic>{
      'attachmentPending': FieldValue.delete(),
      'attachmentUploadStatus': status,
      'attachmentUploadDetail': detail,
    })
        .timeout(const Duration(seconds: 20));
  } catch (e2, st) {
    debugPrint('[Paychek] ticket annotation after upload failure: $e2\n$st');
  }
}
