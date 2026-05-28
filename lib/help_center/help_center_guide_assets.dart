import 'package:flutter/services.dart';

import 'help_center_catalog.dart';
import 'help_center_guide_bodies.dart';

/// Langues supportées pour les corps d’articles (fichiers `{slug}/{code}.txt`).
const List<String> kHelpCenterGuideLanguageCodes = <String>[
  'fr',
  'en',
  'es',
  'de',
  'pt',
  'ko',
];

/// Repli si une langue n’a pas encore de fichier dédié.
const String kHelpCenterGuideFallbackLanguageCode = 'en';

/// Guides du centre d’aide : TXT sous [assets/help_center/guides/{slug}/].
class HelpCenterGuideAssets {
  HelpCenterGuideAssets._();

  static String _normalizeLanguageCode(String? languageCode) {
    final raw = (languageCode ?? kHelpCenterGuideFallbackLanguageCode)
        .split('_')
        .first
        .toLowerCase();
    if (kHelpCenterGuideLanguageCodes.contains(raw)) return raw;
    return kHelpCenterGuideFallbackLanguageCode;
  }

  static Future<String?> _tryLoadAsset(String slug, String languageCode) async {
    final path = 'assets/help_center/guides/$slug/$languageCode.txt';
    try {
      final body = await rootBundle.loadString(path);
      if (body.trim().isNotEmpty) return body.trim();
    } catch (_) {}
    return null;
  }

  /// [rootBundle.loadString] renvoie une [Future] : il faut `await`.
  static Future<String> loadArticleBody(
    String slug, {
    String? languageCode,
  }) async {
    final lang = _normalizeLanguageCode(languageCode);

    final primary = await _tryLoadAsset(slug, lang);
    if (primary != null) return primary;

    if (lang != kHelpCenterGuideFallbackLanguageCode) {
      final en = await _tryLoadAsset(slug, kHelpCenterGuideFallbackLanguageCode);
      if (en != null) return en;
    }

    if (lang != 'fr') {
      final fr = await _tryLoadAsset(slug, 'fr');
      if (fr != null) return fr;
    }

    final embedded = kHelpCenterEmbeddedGuideBodies[slug];
    if (embedded != null && embedded.trim().isNotEmpty) {
      return embedded.trim();
    }

    return '';
  }

  /// Charge tous les corps listés dans [helpCenterArticles] pour [languageCode].
  static Future<Map<String, String>> loadBundle({String? languageCode}) async {
    final out = <String, String>{};
    for (final article in helpCenterArticles) {
      out[article.slug] = await loadArticleBody(
        article.slug,
        languageCode: languageCode,
      );
    }
    return out;
  }
}
