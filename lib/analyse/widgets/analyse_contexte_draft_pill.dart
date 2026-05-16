import 'package:flutter/material.dart';

import '../analyse_tokens.dart';

/// Pilule de saisie **compacte** pour un libellé perso (mode édition contexte).
///
/// Tap **en dehors** de la pilule, perte de focus, ou *Terminé* clavier : **valide** si
/// texte non vide (après trim), sinon **annule**. Pas de boutons ✓ / ✗.
class AnalyseContexteDraftPill extends StatefulWidget {
  const AnalyseContexteDraftPill({
    super.key,
    required this.hint,
    required this.accent,
    required this.onCommit,
    required this.onCancel,
  });

  final String hint;
  final Color accent;
  final ValueChanged<String> onCommit;
  final VoidCallback onCancel;

  @override
  State<AnalyseContexteDraftPill> createState() => _AnalyseContexteDraftPillState();
}

class _AnalyseContexteDraftPillState extends State<AnalyseContexteDraftPill>
    with WidgetsBindingObserver {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  bool _resolved = false;
  double _lastViewInsetBottom = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ctrl = TextEditingController();
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _lastViewInsetBottom = MediaQuery.viewInsetsOf(context).bottom;
      _focus.requestFocus();
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _resolved) return;
      final bottom = MediaQuery.viewInsetsOf(context).bottom;
      // Clavier refermé sans perte de focus (souvent sur Android) : on valide comme un blur.
      if (_lastViewInsetBottom > 0 && bottom == 0) {
        _resolve();
      }
      _lastViewInsetBottom = bottom;
    });
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      _resolve();
    }
  }

  /// Une seule résolution : blur ou clavier *Terminé*.
  void _resolve() {
    if (_resolved || !mounted) return;
    _resolved = true;
    final t = _ctrl.text.trim();
    if (t.isEmpty) {
      widget.onCancel();
    } else {
      widget.onCommit(t);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const r = 6.0;
    return TapRegion(
      onTapOutside: (_) {
        if (_resolved) return;
        _resolve();
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 64, maxWidth: 96),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AnalyseTokens.chipBg,
            borderRadius: BorderRadius.circular(r),
          ),
          child: SizedBox(
            height: 30,
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              style: const TextStyle(
                color: Color(0xFFDFDFDF),
                fontWeight: FontWeight.w700,
                fontSize: 10,
                height: 1.2,
              ),
              cursorColor: widget.accent,
              strutStyle: const StrutStyle(fontSize: 10, height: 1.2, forceStrutHeight: true),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: AnalyseTokens.muted2,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                border: InputBorder.none,
                isDense: true,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _focus.unfocus(),
              onTapOutside: (_) {
                if (_resolved) return;
                _resolve();
              },
            ),
          ),
        ),
      ),
    );
  }
}
