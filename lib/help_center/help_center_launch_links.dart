import 'package:flutter/foundation.dart' show debugPrint;
import 'package:url_launcher/url_launcher.dart';

import '../paychek_brand_links.dart';

/// Liens téléchargement & app web Paychek (à adapter quand les fiches Store sont publiées).
abstract final class HelpCenterLaunchLinks {
  HelpCenterLaunchLinks._();

  static const String playStoreListing =
      'https://play.google.com/store/apps/details?id=pro.paychek.app';

  static const String appStoreListing =
      'https://apps.apple.com/app/paychek/id0000000000';

  /// PWA / site web (affiché sous « Version web » dans le centre d’aide).
  static const String webAppCanonical = kPaychekPublicWebsiteUrl;

  static Future<void> open(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e, st) {
      debugPrint('[HelpCenter] open $uri: $e\n$st');
    }
  }
}
