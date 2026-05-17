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
const _kIframeViewTypePrefix = 'paychek-landing-html-iframe';

int _nextLandingViewTypeId = 0;

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
  bool _tearDown = false;
  bool _acceptMessages = false;
  final List<({Map<String, dynamic> map, String? origin})> _pendingMessages =
      [];

  late final String _viewType;
  html.IFrameElement? _iframe;
  bool _iframeVisible = false;

  static void _purgeStaleLandingIframes() {
    for (final el in html.document.querySelectorAll(
      'iframe[title="PAYCHEK — landing"]',
    )) {
      el.remove();
    }
  }

  @override
  void initState() {
    super.initState();
    _purgeStaleLandingIframes();
    _viewType = '$_kIframeViewTypePrefix-${_nextLandingViewTypeId++}';
    _registerIframeViewFactory();
    WebLandingIframeSuppress.attachIframeDomHooks(
      blockPointerOnIframe: () {
        _iframe?.style.pointerEvents = 'none';
      },
      unblockPointerOnIframe: () {
        _iframe?.style.pointerEvents = 'auto';
      },
    );
    _sub = html.window.onMessage.listen(_onWindowMessage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _tearDown) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _tearDown) return;
        setState(() => _iframeVisible = true);
        _acceptMessages = true;
        final pending =
            List<({Map<String, dynamic> map, String? origin})>.from(
          _pendingMessages,
        );
        _pendingMessages.clear();
        for (final item in pending) {
          _handleMessageMap(item.map, eventOrigin: item.origin);
        }
      });
    });
  }

  void _registerIframeViewFactory() {
    final viewType = _viewType;
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final iframe = html.IFrameElement()
        ..src = 'landing.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block'
        ..style.transform = 'translateZ(0)'
        ..setAttribute('title', 'PAYCHEK — landing');
      _iframe = iframe;
      return iframe;
    });
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

  void _replyLocaleToLandingIframe(String payload) {
    try {
      final cw = _iframe?.contentWindow;
      if (cw == null) return;
      // ignore: avoid_dynamic_calls
      (cw as dynamic).postMessage(payload, '*');
    } catch (_) {}
  }

  /// Clics dans l’iframe HTML ne planifient pas de frame Flutter : sans
  /// [scheduleFrame], les modales auth ne s’ouvrent jamais.
  void _runLandingUiAction(void Function() action) {
    if (!mounted || _tearDown) return;
    scheduleMicrotask(() {
      if (!mounted || _tearDown) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _tearDown) return;
        action();
      });
      final binding = WidgetsBinding.instance;
      if (!binding.hasScheduledFrame) {
        try {
          binding.scheduleFrame();
        } catch (_) {
          try {
            binding.ensureVisualUpdate();
          } catch (_) {}
        }
      }
    });
  }

  void _onWindowMessage(html.MessageEvent event) {
    if (!mounted || _tearDown) return;
    final map = _decodeMessageData(event.data);
    if (map == null) return;

    if (!_acceptMessages) {
      _pendingMessages.add((map: map, origin: event.origin));
      return;
    }
    _handleMessageMap(map, eventOrigin: event.origin);
  }

  void _handleMessageMap(
    Map<String, dynamic> map, {
    String? eventOrigin,
  }) {
    if (!mounted || _tearDown) return;

    final type = map['type']?.toString();
    if (type == _kPaychekReadyMessageType) {
      if (eventOrigin != null && eventOrigin != html.window.location.origin) {
        return;
      }
      final codeFromLanding = map['code']?.toString().toLowerCase();
      unawaited(_syncLocaleWithLanding(codeFromLanding));
      return;
    }

    if (type == _kPaychekAuthMessageType) {
      final mode = map['mode']?.toString().toLowerCase();
      _runLandingUiAction(() {
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
      _runLandingUiAction(() {
        unawaited(widget.onLocaleSelected(code));
      });
    }
  }

  Future<void> _syncLocaleWithLanding(String? codeFromLanding) async {
    if (!mounted || _tearDown) return;
    if (codeFromLanding != null &&
        ReglageLanguagePrefs.availableCodes.contains(codeFromLanding)) {
      await widget.onLocaleSelected(codeFromLanding);
    }
    if (!mounted || _tearDown) return;
    final code = ReglageLanguagePrefs.codeFromLocale(
      AppLocaleScope.of(context).locale,
    );
    _replyLocaleToLandingIframe(
      jsonEncode(<String, String>{
        'type': _kPaychekLocaleSyncType,
        'code': code,
      }),
    );
  }

  @override
  void dispose() {
    _tearDown = true;
    _acceptMessages = false;
    _iframeVisible = false;
    _pendingMessages.clear();
    _sub?.cancel();
    WebLandingIframeSuppress.attachIframeDomHooks(
      blockPointerOnIframe: () {},
      unblockPointerOnIframe: () {},
    );
    try {
      _iframe?.remove();
    } catch (_) {}
    _iframe = null;
    _purgeStaleLandingIframes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(kIsWeb);
    return Scaffold(
      backgroundColor: Colors.black,
      body: _iframeVisible
          ? HtmlElementView(viewType: _viewType)
          : const ColoredBox(color: Colors.black),
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
