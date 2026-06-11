// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use



import 'dart:convert';



import 'dart:html' as html;



const _kStandaloneLandingUrl = 'landing.html?stay=1';

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



/// Ferme l’overlay auth sur la landing standalone (parent HTML).

void paychekCloseAuthOverlay() {

  paychekReturnToLandingIfAuthCancelled();

}



/// Connexion réussie depuis l’overlay iframe → ferme l’overlay et ouvre l’app.

void paychekCompleteAuthOverlaySuccess() {

  paychekStripAuthQueryFromUrl();

  _postAuthOverlayMessage(_kAuthOverlayCloseType);

  try {

    final origin = html.window.location.origin;

    final top = html.window.top;

    if (top != null && top != html.window) {

      top.location.href = '$origin/';

      return;

    }

    html.window.location.href = '/';

  } catch (_) {

    try {

      html.window.location.href = '/';

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


