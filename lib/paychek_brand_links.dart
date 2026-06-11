/// Liens et identité publique Paychek (UI, centre d’aide, e-mails).
///
/// À garder aligné avec `firestore.rules` (`staffNotifyEmail`) et les variables
/// `PAYCHEK_MAIL_*` côté Cloud Functions.
library;

/// Site officiel (ex. lien « Version web » dans le centre d’aide).
const String kPaychekPublicWebsiteUrl = 'https://paychek.pro/';

/// Politique de confidentialité (App Store metadata + paywall IAP).
const String kPaychekPrivacyPolicyUrl = 'https://paychek.pro/privacy-en.html';

/// Conditions d’utilisation / CGV (EULA App Store + paywall IAP).
const String kPaychekTermsOfUseUrl = 'https://paychek.pro/terms.html';

/// Boîte contact unique (support, tickets, BCC staff).
const String kPaychekContactEmail = 'contact@paychek.pro';
