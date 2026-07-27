// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

const _kStandaloneLandingUrl = 'landing.html';
const _kAuthOverlayCloseType = 'paychek-auth-overlay-close';

void _goToStandaloneLanding() {
  try {
    html.window.location.replace(_kStandaloneLandingUrl);
  } catch (_) {}
}

void _postAuthOverlayMessage(String type) {
  try {
    final payload = jsonEncode(<String, String>{'type': type});
    if (html.window.parent != html.window) {
      html.window.parent!.postMessage(payload, '*');
    }
  } catch (_) {}
}

bool _isAuthOverlayFrame() {
  try {
    return Uri.base.queryParameters['overlay'] == '1';
  } catch (_) {
    return false;
  }
}

bool _tryCloseAuthOverlayInParent() {
  if (!_isAuthOverlayFrame()) return false;
  _postAuthOverlayMessage(_kAuthOverlayCloseType);
  return true;
}

/// Fermeture volontaire de la page auth (`/?auth=…`) → landing marketing.
void paychekReturnToLandingIfAuthCancelled() {
  if (_tryCloseAuthOverlayInParent()) return;
  _goToStandaloneLanding();
}

/// Après déconnexion : landing marketing (pas `/?auth=login`).
void paychekReturnToLandingAfterLogout() {
  _goToStandaloneLanding();
}

/// Après connexion : rester sur le site (menu Mon compte), pas le journal.
void paychekReturnToLandingAfterLogin() {
  _goToStandaloneLanding();
}

/// Ferme l’overlay auth sur la landing standalone (parent HTML).
void paychekCloseAuthOverlay() {
  paychekReturnToLandingIfAuthCancelled();
}

/// Connexion réussie depuis l’overlay iframe → ferme l’overlay, reste sur le site.
void paychekCompleteAuthOverlaySuccess() {
  paychekStripAuthQueryFromUrl();
  _postAuthOverlayMessage(_kAuthOverlayCloseType);
  try {
    final origin = html.window.location.origin;
    final top = html.window.top;
    if (top != null && top != html.window) {
      top.location.href = '$origin/$_kStandaloneLandingUrl';
      return;
    }
    html.window.location.href = '/$_kStandaloneLandingUrl';
  } catch (_) {
    try {
      html.window.location.href = '/$_kStandaloneLandingUrl';
    } catch (_) {}
  }
}

/// Retire `?auth=` (et `overlay`) de l’URL après connexion réussie.
void paychekStripAuthQueryFromUrl() {
  try {
    final uri = Uri.parse(html.window.location.href);
    if (!uri.queryParameters.containsKey('auth') &&
        !uri.queryParameters.containsKey('overlay')) {
      return;
    }
    final params = Map<String, String>.from(uri.queryParameters)
      ..remove('auth')
      ..remove('overlay');
    final cleaned = uri.replace(
      queryParameters: params.isEmpty ? null : params,
    );
    var path = cleaned.path;
    if (cleaned.hasQuery) path = '$path?${cleaned.query}';
    if (cleaned.fragment.isNotEmpty) path = '$path#${cleaned.fragment}';
    html.window.history.replaceState(null, '', path);
  } catch (_) {}
}

/// `/?app=1` ou `open=billing|account|license` → entrer dans le journal Flutter.
bool paychekWebAppEntryRequested() {
  try {
    final q = Uri.base.queryParameters;
    final app = q['app']?.trim().toLowerCase();
    if (app == '1' || app == 'true' || app == 'journal') return true;
    final open = q['open']?.trim().toLowerCase();
    if (open == 'billing' ||
        open == 'account' ||
        open == 'license' ||
        open == 'licence') {
      return true;
    }
  } catch (_) {}
  return false;
}

String? paychekWebAppOpenTarget() {
  try {
    final open = Uri.base.queryParameters['open']?.trim().toLowerCase();
    if (open == null || open.isEmpty) return null;
    if (open == 'licence') return 'license';
    return open;
  } catch (_) {
    return null;
  }
}

void paychekStripWebAppEntryQueryFromUrl() {
  try {
    final uri = Uri.parse(html.window.location.href);
    if (!uri.queryParameters.containsKey('app') &&
        !uri.queryParameters.containsKey('open')) {
      return;
    }
    final params = Map<String, String>.from(uri.queryParameters)
      ..remove('app')
      ..remove('open');
    final cleaned = uri.replace(
      queryParameters: params.isEmpty ? null : params,
    );
    var path = cleaned.path;
    if (cleaned.hasQuery) path = '$path?${cleaned.query}';
    if (cleaned.fragment.isNotEmpty) path = '$path#${cleaned.fragment}';
    html.window.history.replaceState(null, '', path);
  } catch (_) {}
}
