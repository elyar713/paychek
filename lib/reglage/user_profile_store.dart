import 'package:flutter/foundation.dart';

import 'reglage_profile_prefs.dart';

/// Profil utilisateur (réglages / futur compte) — notifie l’accueil pour le titre.
class UserProfileStore extends ChangeNotifier {
  ReglageProfileData _profile = const ReglageProfileData(
    inscrit: false,
    prenom: '',
    nom: '',
    email: '',
  );

  ReglageProfileData get profile => _profile;

  Future<void> load() async {
    _profile = await ReglageProfilePrefs.load();
    notifyListeners();
  }

  void setProfile(ReglageProfileData data) {
    _profile = data;
    notifyListeners();
  }
}
