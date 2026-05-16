import 'package:flutter/services.dart';

/// Guides longs du centre d’aide (TXT sous [assets/help_center/guides/]),
/// selon la langue de l’app : en · fr · de · es · pt · ko → repli **en**.
class HelpCenterGuideAssets {
  HelpCenterGuideAssets._();

  /// Si tout échoue, évite un centre d’aide vide : les cartes utilisent encore l’ARB court / titres.
  static const Map<String, String> emptyGuideBundle = {
    'addTrade': '',
    'myStrategy': '',
    'performance': '',
  };

  static String languageCode(String localeName) {
    final t = localeName.toLowerCase().split(RegExp(r'[_-]')).first;
    switch (t) {
      case 'fr':
      case 'de':
      case 'es':
      case 'pt':
      case 'ko':
        return t;
      default:
        return 'en';
    }
  }

  /// [rootBundle.loadString] renvoie une [Future] : il faut `await`, sinon aucun [catch] synchrone ne gère une asset manquante.
  static Future<String> _loadOrEn(String slug, String code) async {
    final primary = 'assets/help_center/guides/$slug/$code.txt';
    final fallback = 'assets/help_center/guides/$slug/en.txt';
    try {
      return await rootBundle.loadString(primary);
    } catch (_) {
      try {
        return await rootBundle.loadString(fallback);
      } catch (_) {
        return '';
      }
    }
  }

  /// Charge les trois corps longs utilisés hors ARB pour Add trade, Ma stratégie, Performance.
  static Future<Map<String, String>> loadBundle(String localeName) async {
    final code = languageCode(localeName);
    final addTrade = await _loadOrEn('add_trade', code);
    final myStrategy = await _loadOrEn('my_strategy', code);
    final performance = await _loadOrEn('performance', code);
    return {
      'addTrade': addTrade,
      'myStrategy': myStrategy,
      'performance': performance,
    };
  }
}
