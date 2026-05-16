import '../paychek_brand_links.dart';

/// **Unique** boîte e-mail applicative : tickets, mailto, BCC admin, accusés.
///
/// Aligner avec :
/// - `firestore.rules` (`staffNotifyEmail`) ;
/// - les paramètres `PAYCHEK_MAIL_FROM` / `PAYCHEK_MAIL_BCC` (Cloud Functions / Resend).
const String kPaychekSupportPublicInboxEmail = kPaychekContactEmail;
