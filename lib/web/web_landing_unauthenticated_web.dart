// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../reglage/app_locale_scope.dart';
import '../reglage/reglage_language_prefs.dart';
import 'web_landing_auth_dialogs.dart';
import 'web_landing_iframe_suppress.dart';

const _kPaychekAuthMessageType = 'paychek-auth';
const _kPaychekLocaleMessageType = 'paychek-locale';
const _kPaychekReadyMessageType = 'paychek-ready';
const _kPaychekLocaleSyncType = 'paychek-locale-sync';
const _kIframeViewType = 'paychek-landing-html-iframe';

bool _iframeViewFactoryRegistered = false;

/// Référence DOM de l’iframe (pour `pointer-events` pendant les modales Flutter).
html.IFrameElement? _landingIframeElement;

void _ensureIframeRegistered() {
  if (_iframeViewFactoryRegistered) return;
  _iframeViewFactoryRegistered = true;
  ui_web.platformViewRegistry.registerViewFactory(_kIframeViewType, (int _) {
    final iframe = html.IFrameElement()
      ..src = 'landing.html'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.display = 'block'
      // Calque GPU dédié : réduit les artefacts de texte (background-clip) à la frontière Flutter / iframe.
      ..style.transform = 'translateZ(0)'
      ..setAttribute('title', 'PAYCHEK — landing');
    _landingIframeElement = iframe;
    return iframe;
  });
}

/// Landing marketing HTML (`web/landing.html`) dans une iframe.
class WebLandingUnauthenticatedWeb extends StatefulWidget {
  const WebLandingUnauthenticatedWeb({
    super.key,
    required this.onLocaleSelected,
  });

  final Future<void> Function(String languageCode) onLocaleSelected;

  @override
  State<WebLandingUnauthenticatedWeb> createState() =>
      _WebLandingUnauthenticatedWebState();
}

class _WebLandingUnauthenticatedWebState
    extends State<WebLandingUnauthenticatedWeb> {
  StreamSubscription<html.MessageEvent>? _sub;

  @override
  void initState() {
    super.initState();
    WebLandingIframeSuppress.attachIframeDomHooks(
      blockPointerOnIframe: () {
        _landingIframeElement?.style.pointerEvents = 'none';
      },
      unblockPointerOnIframe: () {
        _landingIframeElement?.style.pointerEvents = 'auto';
      },
    );
    _sub = html.window.onMessage.listen(_onWindowMessage);
  }

  Map<String, dynamic>? _decodeMessageData(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is! String) return null;
    try {
      final decoded = jsonDecode(raw) as Object?;
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  /// N’utilise pas [html.MessageEvent.source] : le getter Dart peut lever
  /// `_DOMWindowCrossFrame` → `Window?` (DDC). On cible [IFrameElement.contentWindow].
  static void _replyLocaleToLandingIframe(String payload) {
    try {
      final cw = _landingIframeElement?.contentWindow;
      if (cw == null) return;
      // ignore: avoid_dynamic_calls
      (cw as dynamic).postMessage(payload, '*');
    } catch (_) {}
  }

  void _onWindowMessage(html.MessageEvent event) {
    if (!mounted) return;
    final map = _decodeMessageData(event.data);
    if (map == null) return;

    final type = map['type']?.toString();
    if (type == _kPaychekReadyMessageType) {
      if (event.origin != html.window.location.origin) return;
      final code = ReglageLanguagePrefs.codeFromLocale(
        AppLocaleScope.of(context).locale,
      );
      final payload = jsonEncode(<String, String>{
        'type': _kPaychekLocaleSyncType,
        'code': code,
      });
      _replyLocaleToLandingIframe(payload);
      return;
    }

    if (type == _kPaychekAuthMessageType) {
      final mode = map['mode']?.toString().toLowerCase();
      // Hors dispatch navigateur pur : [context] du [State] reste valide. [addPostFrameCallback]
      // peut ne pas tourner après certaines erreurs moteur / hot reload — [scheduleMicrotask] suffit.
      scheduleMicrotask(() {
        if (!mounted) return;
        if (mode == 'login' || mode == 'signin' || mode == 'connexion') {
          unawaited(showWebLandingLoginDialog(context));
        } else if (mode == 'signup' ||
            mode == 'register' ||
            mode == 'inscription') {
          unawaited(showWebLandingSignupDialog(context));
        }
      });
      return;
    }

    if (type == _kPaychekLocaleMessageType) {
      final code = map['code']?.toString().toLowerCase();
      if (code == null || !ReglageLanguagePrefs.availableCodes.contains(code)) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await widget.onLocaleSelected(code);
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(kIsWeb);
    _ensureIframeRegistered();
    return const Scaffold(
      backgroundColor: Colors.black,
      body: HtmlElementView(viewType: _kIframeViewType),
    );
  }
}

Widget buildWebLandingUnauthenticated(
  BuildContext context,
  Future<void> Function(String languageCode) onLocaleSelected,
) {
  return WebLandingUnauthenticatedWeb(
    onLocaleSelected: onLocaleSelected,
  );
}
