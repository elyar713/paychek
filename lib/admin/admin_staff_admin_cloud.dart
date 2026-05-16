import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'admin_support_send_email.dart';

/// Données optionnelles écrites dans `paychek_admin_profiles` par le super-admin (callable).
class PaychekStaffAdminSeedProfile {
  const PaychekStaffAdminSeedProfile({
    this.firstName,
    this.lastName,
    this.roleTitle,
    this.phone,
  });

  final String? firstName;
  final String? lastName;
  final String? roleTitle;
  final String? phone;

  Map<String, dynamic> toCallableMap() {
    final out = <String, dynamic>{
      if (firstName != null && firstName!.trim().isNotEmpty)
        'firstName': firstName!.trim(),
      if (lastName != null && lastName!.trim().isNotEmpty)
        'lastName': lastName!.trim(),
      if (roleTitle != null && roleTitle!.trim().isNotEmpty)
        'roleTitle': roleTitle!.trim(),
      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
    };
    return out;
  }

  bool get isEmpty => toCallableMap().isEmpty;
}

/// Mutation du claim Firebase `admin` via [managePaychekStaffAdmin].
Future<PaychekStaffAdminMutationResult> paychekCallableManageStaffAdmin({
  required String targetEmailTrimmed,
  required bool grant,
  PaychekStaffAdminSeedProfile? seedProfile,
}) async {
  final fn =
      FirebaseFunctions.instanceFor(region: kPaychekSupportFunctionsRegion);
  final callable = fn.httpsCallable('managePaychekStaffAdmin');
  try {
    final payload = <String, dynamic>{
      'action': grant ? 'grant' : 'revoke',
      'targetEmail': targetEmailTrimmed.trim().toLowerCase(),
    };
    if (grant &&
        seedProfile != null &&
        !seedProfile.isEmpty) {
      payload['initialProfile'] = seedProfile.toCallableMap();
    }

    final result = await callable.call<Map<String, dynamic>?>(payload);
    final map = result.data;
    final ok = map != null && map['ok'] == true;
    return PaychekStaffAdminMutationResult(
      ok: ok,
      targetUid: map == null ? null : '${map['targetUid'] ?? ''}'.trim(),
      claimsAdmin: map != null && map['claimsAdmin'] == true,
    );
  } on FirebaseFunctionsException catch (e, st) {
    debugPrint('[Paychek] managePaychekStaffAdmin ${e.code}: ${e.message}\n$st');
    return PaychekStaffAdminMutationResult(
      ok: false,
      errorCode: e.code,
      errorMessage: e.message,
    );
  } catch (e, st) {
    debugPrint('[Paychek] managePaychekStaffAdmin $e\n$st');
    return PaychekStaffAdminMutationResult(
      ok: false,
      errorMessage: '$e',
    );
  }
}

class PaychekStaffAdminMutationResult {
  PaychekStaffAdminMutationResult({
    required this.ok,
    this.targetUid,
    this.claimsAdmin,
    this.errorCode,
    this.errorMessage,
  });

  final bool ok;
  final String? targetUid;
  final bool? claimsAdmin;
  final String? errorCode;
  final String? errorMessage;

  String? get userFacingError {
    if (ok) return null;
    if (errorMessage != null && errorMessage!.trim().isNotEmpty) {
      return errorMessage;
    }
    if (errorCode != null) return errorCode;
    return 'Échec de la mise à jour';
  }
}
