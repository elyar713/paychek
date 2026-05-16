import 'package:shared_preferences/shared_preferences.dart';

import 'paychek_prefs_scope.dart';

/// Profil affiché dans Réglages (persistance locale).
abstract final class ReglageProfilePrefs {
  static const _kInscritBase = 'user_profile_inscrit';
  static const _kPrenomBase = 'user_profile_prenom';
  static const _kNomBase = 'user_profile_nom';
  static const _kEmailBase = 'user_profile_email';

  static String get _kInscrit => paychekScopedPrefsKey(_kInscritBase);
  static String get _kPrenom => paychekScopedPrefsKey(_kPrenomBase);
  static String get _kNom => paychekScopedPrefsKey(_kNomBase);
  static String get _kEmail => paychekScopedPrefsKey(_kEmailBase);

  static Future<ReglageProfileData> load() async {
    final p = await SharedPreferences.getInstance();
    // Migration: si on n'a pas encore de valeurs scopées, copier les anciennes clés globales.
    if (!p.containsKey(_kInscrit) &&
        (p.containsKey(_kInscritBase) ||
            p.containsKey(_kPrenomBase) ||
            p.containsKey(_kNomBase) ||
            p.containsKey(_kEmailBase))) {
      final oldInscrit = p.getBool(_kInscritBase);
      final oldPrenom = p.getString(_kPrenomBase);
      final oldNom = p.getString(_kNomBase);
      final oldEmail = p.getString(_kEmailBase);
      if (oldInscrit != null) await p.setBool(_kInscrit, oldInscrit);
      if (oldPrenom != null) await p.setString(_kPrenom, oldPrenom);
      if (oldNom != null) await p.setString(_kNom, oldNom);
      if (oldEmail != null) await p.setString(_kEmail, oldEmail);
    }
    return ReglageProfileData(
      inscrit: p.getBool(_kInscrit) ?? false,
      prenom: p.getString(_kPrenom) ?? '',
      nom: p.getString(_kNom) ?? '',
      email: p.getString(_kEmail) ?? '',
    );
  }

  /// Pour tests / futur écran d’inscription.
  static Future<void> save({
    required bool inscrit,
    required String prenom,
    required String nom,
    String email = '',
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kInscrit, inscrit);
    await p.setString(_kPrenom, prenom);
    await p.setString(_kNom, nom);
    await p.setString(_kEmail, email);
  }

  /// Réinitialise le profil persistant (prénom, nom, e-mail, drapeau inscrit).
  static Future<void> clearStoredAccountProfile() =>
      save(inscrit: false, prenom: '', nom: '', email: '');
}

class ReglageProfileData {
  const ReglageProfileData({
    required this.inscrit,
    required this.prenom,
    required this.nom,
    required this.email,
  });

  final bool inscrit;
  final String prenom;
  final String nom;
  final String email;

  /// Nom affiché : **Prénom Nom** si inscrit avec les deux renseignés, sinon **Trader**.
  String get displayName {
    final p = prenom.trim();
    final n = nom.trim();
    if (inscrit && p.isNotEmpty && n.isNotEmpty) {
      return '$p $n';
    }
    return 'Trader';
  }

  /// Initiales pour l’avatar (2 lettres).
  String get initials {
    final p = prenom.trim();
    final n = nom.trim();
    if (inscrit && p.isNotEmpty && n.isNotEmpty) {
      final a = p.isNotEmpty ? p[0].toUpperCase() : '';
      final b = n.isNotEmpty ? n[0].toUpperCase() : '';
      if (a.isNotEmpty && b.isNotEmpty) return '$a$b';
    }
    return 'TR';
  }

  /// Ligne sous le nom : e-mail réel si présent ; pas de placeholder tant que **non inscrit**
  /// (sinon après déconnexion le faux mail réapparaît).
  String get emailBelowName {
    final e = email.trim();
    if (e.isNotEmpty) return e;
    if (!inscrit) return '';
    if (displayName == 'Trader') {
      return 'trader@paychek.pro';
    }
    return '';
  }

  bool get hasEmailBelowName => emailBelowName.isNotEmpty;

  /// En-tête dashboard : prénom + nom inscrits, sinon partie locale de l’e-mail stocké ; null → marque app.
  String? get dashboardHeaderTitle {
    final p = prenom.trim();
    final n = nom.trim();
    if (inscrit && p.isNotEmpty && n.isNotEmpty) {
      return '$p $n';
    }
    final e = email.trim();
    if (e.isNotEmpty) {
      final at = e.indexOf('@');
      return at > 0 ? e.substring(0, at) : e;
    }
    return null;
  }
}
