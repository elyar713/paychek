import 'package:flutter/material.dart';

/// Après l’essai : la page Pro reste **visible** (grisée) ; le contenu sous l’en-tête
/// est **inerte** (pas de saisie, scroll ni tap vers les widgets en dessous).
///
/// La zone haute ([headerUnlockHeight]) reste active pour le bouton retour.
class LiteFreemiumPageLock extends StatelessWidget {
  const LiteFreemiumPageLock({
    super.key,
    required this.child,
    required this.onLockedInteraction,
    this.headerUnlockHeight = 112,
  });

  final Widget child;
  final VoidCallback onLockedInteraction;

  /// Hauteur réservée à l’en-tête (retour + titre) sans voile ni blocage.
  final double headerUnlockHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          top: headerUnlockHeight,
          bottom: 0,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => onLockedInteraction(),
            child: AbsorbPointer(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.62),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bloque pointer / saisie sur [child] (ex. aperçu accueil) ; un tap → paywall.
class LiteFreemiumInteractionBarrier extends StatelessWidget {
  const LiteFreemiumInteractionBarrier({
    super.key,
    required this.locked,
    required this.onLockedInteraction,
    required this.child,
  });

  final bool locked;
  final VoidCallback onLockedInteraction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => onLockedInteraction(),
            child: const AbsorbPointer(
              child: SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}
