// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// Retire le spinner HTML affiché pendant le chargement de `/?auth=…`.
void paychekHideAuthBootLoader() {
  try {
    html.document.getElementById('paychek-auth-boot')?.remove();
  } catch (_) {}
}
