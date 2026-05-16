import 'package:firebase_auth/firebase_auth.dart';

/// E-mails autorisés à gérer les admins (liste blanche locale + à synchroniser avec
/// `PAYCHEK_SUPERADMIN_EMAILS` dans `functions/index.js`).
const Set<String> kPaychekSuperadminEmailsLowercase = {
  'elyar713@gmail.com',
};

bool paychekIsSuperadminFirebaseUser(User? u) {
  final e = u?.email?.trim().toLowerCase() ?? '';
  return e.isNotEmpty && kPaychekSuperadminEmailsLowercase.contains(e);
}
