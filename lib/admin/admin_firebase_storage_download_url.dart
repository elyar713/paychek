import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Encode le chemin objet pour l’API REST Firebase Storage (`%2F` entre segments).
String _firebaseStorageRestEncodeObjectPath(String path) {
  final cleaned = path.replaceAll(RegExp(r'^/+|/+$'), '');
  return cleaned
      .split('/')
      .map(Uri.encodeComponent)
      .join('%2F');
}

/// Obtient une URL avec `downloadToken` via l’API metadata (sans plugin channel).
///
/// Évite `[firebase_storage/channel-error]` observé sur Flutter Web après hot reload / certains shells.
Future<String> _downloadUrlViaStorageRest(String storagePath) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Authentification requise pour télécharger depuis Storage.');
  }
  final token = await user.getIdToken();
  if (token == null || token.isEmpty) {
    throw StateError('Jeton Firebase Auth indisponible.');
  }

  final bucket =
      FirebaseStorage.instance.app.options.storageBucket?.trim() ?? '';
  if (bucket.isEmpty) {
    throw StateError('storageBucket manquant dans firebase_options.');
  }

  final enc = _firebaseStorageRestEncodeObjectPath(storagePath);
  final metaUri = Uri.parse(
    'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$enc',
  );

  final resp = await http.get(
    metaUri,
    headers: <String, String>{'Authorization': 'Bearer $token'},
  );

  if (resp.statusCode != 200) {
    throw Exception(
      'Metadata Storage (${resp.statusCode}) : ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}…' : resp.body}',
    );
  }

  final dynamic decoded = jsonDecode(resp.body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Réponse metadata Storage inattendue.');
  }
  final tokensRaw = decoded['downloadTokens'];
  final tokens = tokensRaw is String ? tokensRaw.trim() : '';
  if (tokens.isEmpty) {
    throw StateError(
      'Aucun downloadToken sur le fichier (règles ou objet récent).',
    );
  }
  final firstToken = tokens.split(',').first.trim();
  return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$enc?alt=media&token=$firstToken';
}

/// URL signée pour ouvrir / copier une pièce jointe support.
Future<String> paychekAdminStorageDownloadUrl(String storagePath) async {
  try {
    return await FirebaseStorage.instance.ref(storagePath).getDownloadURL();
  } catch (e) {
    final s = e.toString().toLowerCase();
    final channelLike = s.contains('channel-error') ||
        s.contains('unable to establish connection');
    if (kIsWeb && channelLike) {
      return _downloadUrlViaStorageRest(storagePath);
    }
    rethrow;
  }
}
