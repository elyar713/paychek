import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'trade_models.dart';
import 'trade_screenshot_file_bytes.dart'
    if (dart.library.html) 'trade_screenshot_file_bytes_stub.dart';

const _kLocalBase = 'trade_ss_v1';

String _localPrefsKey(String tradeId, {String? firebaseUidOverride}) {
  final base = '${_kLocalBase}_$tradeId';
  if (firebaseUidOverride != null && firebaseUidOverride.trim().isNotEmpty) {
    return paychekScopedPrefsKeyForUid(base, firebaseUidOverride);
  }
  return paychekScopedPrefsKey(base);
}

/// Persistance locale des captures (clé séparée du journal JSON — quota web).
abstract final class TradeScreenshotLocalPrefs {
  TradeScreenshotLocalPrefs._();

  static Future<void> save(
    String tradeId,
    Uint8List bytes, {
    String? firebaseUidOverride,
  }) async {
    if (bytes.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _localPrefsKey(tradeId, firebaseUidOverride: firebaseUidOverride),
      base64Encode(bytes),
    );
  }

  static Future<Uint8List?> load(
    String tradeId, {
    String? firebaseUidOverride,
  }) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(
      _localPrefsKey(tradeId, firebaseUidOverride: firebaseUidOverride),
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      return Uint8List.fromList(base64Decode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> delete(
    String tradeId, {
    String? firebaseUidOverride,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_localPrefsKey(tradeId, firebaseUidOverride: firebaseUidOverride));
  }
}

String _firebaseStorageRestEncodeObjectPath(String path) {
  final cleaned = path.replaceAll(RegExp(r'^/+|/+$'), '');
  return cleaned.split('/').map(Uri.encodeComponent).join('%2F');
}

/// Upload / URL Firebase Storage pour captures trade (web + multi-appareils).
abstract final class TradeScreenshotCloud {
  TradeScreenshotCloud._();

  static String objectPath(String uid, String tradeId) =>
      'trade_screenshots/$uid/$tradeId.jpg';

  /// Bytes en mémoire, prefs locales, ou fichier natif (`screenshotPath`).
  static Future<Uint8List?> resolveBytes(TradeListItem item) async {
    final mem = item.screenshotBytes;
    if (mem != null && mem.isNotEmpty) return mem;

    final local = await TradeScreenshotLocalPrefs.load(item.id);
    if (local != null && local.isNotEmpty) return local;

    if (!kIsWeb) {
      final path = item.screenshotPath?.trim();
      if (path != null && path.isNotEmpty) {
        return readTradeScreenshotFileBytes(path);
      }
    }
    return null;
  }

  static Future<TradeListItem> ensureUploaded(TradeListItem item) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return item;
    final existing = item.screenshotStoragePath?.trim();
    if (existing != null && existing.isNotEmpty) {
      final bytes = await resolveBytes(item);
      if (bytes != null &&
          bytes.isNotEmpty &&
          (item.screenshotBytes == null || item.screenshotBytes!.isEmpty)) {
        return item.copyWith(screenshotBytes: bytes);
      }
      return item;
    }

    final bytes = await resolveBytes(item);
    if (bytes == null || bytes.isEmpty) return item;

    final path = objectPath(u.uid, item.id);
    try {
      await FirebaseStorage.instance.ref(path).putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
      return item.copyWith(screenshotStoragePath: path, screenshotBytes: bytes);
    } catch (e, st) {
      debugPrint('[Paychek] trade screenshot upload: $e\n$st');
      if (item.screenshotBytes == null || item.screenshotBytes!.isEmpty) {
        return item.copyWith(screenshotBytes: bytes);
      }
      return item;
    }
  }

  static Future<String> downloadUrl(String storagePath) async {
    try {
      return await FirebaseStorage.instance.ref(storagePath).getDownloadURL();
    } catch (e) {
      final s = e.toString().toLowerCase();
      final channelLike = s.contains('channel-error') ||
          s.contains('unable to establish connection');
      if (channelLike) {
        return _downloadUrlViaStorageRest(storagePath);
      }
      rethrow;
    }
  }

  static Future<String> _downloadUrlViaStorageRest(String storagePath) async {
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
        'Metadata Storage (${resp.statusCode})',
      );
    }

    final dynamic decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Réponse metadata Storage inattendue.');
    }
    final tokensRaw = decoded['downloadTokens'];
    final tokens = tokensRaw is String ? tokensRaw.trim() : '';
    if (tokens.isEmpty) {
      throw StateError('Aucun downloadToken sur la capture trade.');
    }
    final firstToken = tokens.split(',').first.trim();
    return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$enc?alt=media&token=$firstToken';
  }
}
