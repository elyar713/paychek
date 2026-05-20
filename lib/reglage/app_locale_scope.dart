import 'package:flutter/material.dart';
import 'paychek_user_firestore.dart';
import 'reglage_language_prefs.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController() : _locale = const Locale('en');

  Locale _locale;

  Locale get locale => _locale;

  Future<void> load() async {
    final code = await ReglageLanguagePrefs.loadCode();
    _locale = ReglageLanguagePrefs.localeFromCode(code);
    notifyListeners();
  }

  Future<void> selectCode(String code) async {
    await ReglageLanguagePrefs.save(code);
    _locale = ReglageLanguagePrefs.localeFromCode(code);
    notifyListeners();
    await paychekPushUserAppLanguageToFirestore(code);
  }
}

/// Fournit [AppLocaleController] sous [MaterialApp] et notifie les descendants au changement de langue.
class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  const AppLocaleScope({
    super.key,
    required AppLocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppLocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope introuvable');
    return scope!.notifier!;
  }
}
