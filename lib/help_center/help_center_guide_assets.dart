import 'package:flutter/services.dart';

import 'help_center_catalog.dart';
import 'help_center_guide_bodies.dart';

/// Langue unique des corps d’articles pendant la refonte (traductions plus tard).
const String kHelpCenterContentLanguageCode = 'fr';

/// Repli si un article n’a pas encore de `fr.txt` (legacy).
const String kHelpCenterContentLegacyFallbackLanguageCode = 'en';

/// Guides du centre d’aide : TXT sous [assets/help_center/guides/{slug}/].
class HelpCenterGuideAssets {
  HelpCenterGuideAssets._();

  /// [rootBundle.loadString] renvoie une [Future] : il faut `await`.
  static Future<String> loadArticleBody(String slug) async {
    final embedded = kHelpCenterEmbeddedGuideBodies[slug];
    if (embedded != null && embedded.trim().isNotEmpty) {
      return embedded.trim();
    }

    final primary =
        'assets/help_center/guides/$slug/$kHelpCenterContentLanguageCode.txt';
    final fallback =
        'assets/help_center/guides/$slug/$kHelpCenterContentLegacyFallbackLanguageCode.txt';
    try {
      final body = await rootBundle.loadString(primary);
      if (body.trim().isNotEmpty) return body;
    } catch (_) {}
    try {
      final body = await rootBundle.loadString(fallback);
      if (body.trim().isNotEmpty) return body;
    } catch (_) {}
    return '';
  }

  /// Charge tous les corps listés dans [helpCenterArticles] (français).
  static Future<Map<String, String>> loadBundle() async {
    final out = <String, String>{};
    for (final article in helpCenterArticles) {
      out[article.slug] = await loadArticleBody(article.slug);
    }
    return out;
  }
}
