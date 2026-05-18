import 'package:flutter/material.dart';

/// Ligne web Capital (solde) + Évolution : la carte évolution prend **exactement**
/// la hauteur mesurée de la carte capital.
class WebDashboardCapitalEvolutionPair extends StatefulWidget {
  const WebDashboardCapitalEvolutionPair({
    super.key,
    required this.gap,
    required this.capitalWidth,
    required this.evolutionWidth,
    required this.capitalChild,
    required this.evolutionChild,
  });

  final double gap;
  final double capitalWidth;
  final double evolutionWidth;
  final Widget capitalChild;
  final Widget evolutionChild;

  @override
  State<WebDashboardCapitalEvolutionPair> createState() =>
      _WebDashboardCapitalEvolutionPairState();
}

class _WebDashboardCapitalEvolutionPairState
    extends State<WebDashboardCapitalEvolutionPair> {
  final GlobalKey _capitalKey = GlobalKey();

  double? _capitalHeight;
  bool _measureQueued = false;

  void _scheduleMeasureCapitalHeight() {
    if (_measureQueued) return;
    _measureQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureQueued = false;
      _measureCapitalHeight();
    });
  }

  void _measureCapitalHeight() {
    if (!mounted) return;
    final ctx = _capitalKey.currentContext;
    if (ctx == null) return;
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.hasSize) return;
    final h = ro.size.height;
    if (_capitalHeight == null || (_capitalHeight! - h).abs() > 0.5) {
      setState(() => _capitalHeight = h);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_capitalHeight == null) {
      _scheduleMeasureCapitalHeight();
    }

    final evo = widget.evolutionChild;
    final evolutionBox = _capitalHeight == null
        ? evo
        : SizedBox(
            height: _capitalHeight,
            width: double.infinity,
            child: evo,
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: widget.capitalWidth,
          child: KeyedSubtree(
            key: _capitalKey,
            child: widget.capitalChild,
          ),
        ),
        SizedBox(width: widget.gap),
        SizedBox(
          width: widget.evolutionWidth,
          child: evolutionBox,
        ),
      ],
    );
  }
}
