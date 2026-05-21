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
    required this.hostContext,
    required this.onLocaleSelected,
  });

  /// Contexte sous [MaterialApp] (fourni par [WebAuthGate]) pour [showDialog].
  final BuildContext hostContext;

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

  /// Invalide les [addPostFrameCallback] / microtasks après [dispose] ou hot reload.
  int _uiGeneration = 0;

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
    _iframeVisible = true;
    final bootGen = _uiGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isUiAlive(bootGen)) return;
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
  }

  bool _isUiAlive(int generation) {
    return mounted && !_tearDown && generation == _uiGeneration;
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

  /// Clics dans l’iframe HTML : réveille le pipeline Flutter sans [scheduleFrame]
  /// (évite « Trying to render a disposed EngineFlutterView » au hot reload).
  void _runLandingUiAction(void Function() action) {
    if (!mounted || _tearDown) return;
    final host = widget.hostContext;
    if (!host.mounted) return;
    final gen = _uiGeneration;
    scheduleMicrotask(() {
      if (!_isUiAlive(gen) || !host.mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isUiAlive(gen) || !host.mounted) return;
        action();
      });
      if (_isUiAlive(gen)) {
        setState(() {});
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
        final host = widget.hostContext;
        if (mode == 'login' || mode == 'signin' || mode == 'connexion') {
          unawaited(showWebLandingLoginDialog(host));
        } else if (mode == 'signup' ||
            mode == 'register' ||
            mode == 'inscription') {
          unawaited(showWebLandingSignupDialog(host));
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
    final host = widget.hostContext;
    if (!host.mounted) return;
    final code = ReglageLanguagePrefs.codeFromLocale(
      AppLocaleScope.of(host).locale,
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
    _uiGeneration++;
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
    hostContext: context,
    onLocaleSelected: onLocaleSelected,
  );
}
