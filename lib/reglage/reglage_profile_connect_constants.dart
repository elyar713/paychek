/// Onglet ouvert au premier affichage de la page Compte : [connexion] par défaut.
enum ReglageAuthInitialTab { connexion, inscription }

/// Passé à [Navigator.pop] après connexion / inscription réussie → [ReglagePage] affiche les Réglages + snack.
const String kReglageAuthSuccessPopResult = 'paychek_auth_ok';

/// Passé à [Navigator.pop] après déconnexion depuis [ReglageProfileViewPage] → snack côté [ReglagePage].
const String kReglageProfileLogoutPopResult = 'paychek_profile_logout';
