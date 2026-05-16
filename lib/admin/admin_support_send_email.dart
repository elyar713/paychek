import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

/// Même région que [functions/index.js] (`sendStaffSupportEmail`).
const String kPaychekSupportFunctionsRegion = 'europe-west1';

/// Résultat callable Gen2 (`{ ok: true }`) parfois mal typé côté Web — normalise en [Map].
Map<String, dynamic>? _paychekCoerceCallableDataMap(Object? raw) {
  if (raw == null) return null;
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    try {
      return Map<String, dynamic>.from(
        raw.map((k, v) => MapEntry('$k', v)),
      );
    } catch (_) {
      return null;
    }
  }
  return null;
}

bool _paychekMapHasOkTrue(Map<String, dynamic> m) {
  if (m['ok'] == true) return true;
  final nested = m['result'];
  if (nested is Map && nested['ok'] == true) return true;
  final data = m['data'];
  if (data is Map && data['ok'] == true) return true;
  return false;
}

/// Résultat de l’appel [sendStaffSupportEmail] (diagnostic si échec).
typedef PaychekStaffEmailOutcome = ({
  bool ok,
  String? code,
  String? message,
});

/// Tente l’envoi SMTP via Cloud Function (secret Firebase `PAYCHEK_SMTP_PASSWORD`).
Future<PaychekStaffEmailOutcome> paychekTrySendStaffSupportEmail({
  required String ticketId,
  required String messageBody,
  String? attachmentStoragePath,
  String? attachmentFileName,
  String? attachmentContentType,
}) async {
  try {
    await FirebaseAuth.instance.currentUser?.getIdToken(true);

    final fn =
        FirebaseFunctions.instanceFor(region: kPaychekSupportFunctionsRegion);
    final callable = fn.httpsCallable(
      'sendStaffSupportEmail',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 120),
      ),
    );
    final payload = <String, dynamic>{
      'ticketId': ticketId,
      'messageBody': messageBody,
    };
    final p = attachmentStoragePath?.trim();
    final fnm = attachmentFileName?.trim();
    if ((p ?? '').isNotEmpty && (fnm ?? '').isNotEmpty) {
      payload['attachmentStoragePath'] = p;
      payload['attachmentFileName'] = fnm;
      final ct = attachmentContentType?.trim();
      if ((ct ?? '').isNotEmpty) payload['attachmentContentType'] = ct;
    }

    final result = await callable.call<dynamic>(payload);

    final data = _paychekCoerceCallableDataMap(result.data);
    final ok = data != null && _paychekMapHasOkTrue(data);
    if (ok) {
      return (ok: true, code: null, message: null);
    }
    if (kIsWeb) {
      debugPrint(
        '[Paychek] sendStaffSupportEmail: réponse sans ok=true '
        '(type=${result.data.runtimeType}) data=$data',
      );
    } else {
      debugPrint('[Paychek] sendStaffSupportEmail: réponse sans ok=true: $data');
    }
    return (
      ok: false,
      code: 'invalid-response',
      message: 'La Function a répondu sans confirmation (ok).',
    );
  } on FirebaseFunctionsException catch (e, st) {
    debugPrint(
      '[Paychek] sendStaffSupportEmail '
      '${e.code}: ${e.message}'
      '${e.details != null ? '\ndetails: ${e.details}' : ''}'
      '\n$st',
    );
    return (ok: false, code: e.code, message: e.message);
  } catch (e, st) {
    debugPrint('[Paychek] sendStaffSupportEmail: $e\n$st');
    return (ok: false, code: 'client', message: '$e');
  }
}
