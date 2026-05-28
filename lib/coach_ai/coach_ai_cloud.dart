import 'dart:ui' show Locale;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../reglage/stripe_entitlement_sync.dart';

typedef PaychekAiCoachResult = ({
  bool ok,
  String? answer,
  String? code,
  String? message,
  int? quotaUsed,
  int? quotaLimit,
});

class PaychekAiCoachCloud {
  PaychekAiCoachCloud._();

  static Map<String, dynamic>? _coerceMap(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      try {
        return Map<String, dynamic>.from(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<PaychekAiCoachResult> ask({
    required String question,
    required Locale locale,
    Map<String, dynamic>? context,
  }) async {
    final q = question.trim();
    if (q.isEmpty) {
      return (
        ok: false,
        answer: null,
        code: 'invalid-argument',
        message: 'Question vide.',
        quotaUsed: null,
        quotaLimit: null,
      );
    }

    try {
      final fn = FirebaseFunctions.instanceFor(region: kPaychekFunctionsRegion);
      final callable = fn.httpsCallable(
        'paychekAiCoach',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );
      final payload = <String, dynamic>{
        'question': q,
        'locale': locale.languageCode,
      };
      if (context != null) {
        payload['context'] = context;
      }
      final result = await callable.call<Map<String, dynamic>>(payload);
      final map = _coerceMap(result.data);
      final answer = '${map?['answer'] ?? ''}'.trim();
      if (map != null && map['ok'] == true && answer.isNotEmpty) {
        final quotaMap = _coerceMap(map['quota']);
        final used = quotaMap?['used'];
        final limit = quotaMap?['quota'];
        return (
          ok: true,
          answer: answer,
          code: null,
          message: null,
          quotaUsed: used is int ? used : int.tryParse('$used'),
          quotaLimit: limit is int ? limit : int.tryParse('$limit'),
        );
      }
      return (
        ok: false,
        answer: null,
        code: 'invalid-response',
        message: 'Réponse IA invalide.',
        quotaUsed: null,
        quotaLimit: null,
      );
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint('[Paychek] paychekAiCoach ${e.code}: ${e.message}\n$st');
      return (
        ok: false,
        answer: null,
        code: e.code,
        message: e.message,
        quotaUsed: null,
        quotaLimit: null,
      );
    } catch (e, st) {
      debugPrint('[Paychek] paychekAiCoach $e\n$st');
      return (
        ok: false,
        answer: null,
        code: 'client',
        message: '$e',
        quotaUsed: null,
        quotaLimit: null,
      );
    }
  }
}
