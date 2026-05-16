/// Pendant l’auth web : iframe en `pointer-events: none` pour que la modale Flutter reçoive les clics.
class WebLandingIframeSuppress {
  WebLandingIframeSuppress._();

  static void Function()? _blockPointerOnIframe;
  static void Function()? _unblockPointerOnIframe;

  /// À appeler depuis `web_landing_unauthenticated_web.dart` (où l’[IFrameElement] est créé).
  static void attachIframeDomHooks({
    required void Function() blockPointerOnIframe,
    required void Function() unblockPointerOnIframe,
  }) {
    _blockPointerOnIframe = blockPointerOnIframe;
    _unblockPointerOnIframe = unblockPointerOnIframe;
  }

  /// Bloque l’iframe **immédiatement** (pas d’attente frames / délai — évite la lag à l’ouverture).
  static void prepareForAuthOverlay() {
    _blockPointerOnIframe?.call();
  }

  static void release() {
    _unblockPointerOnIframe?.call();
  }
}
