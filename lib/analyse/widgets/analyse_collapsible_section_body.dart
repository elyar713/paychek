import 'package:flutter/material.dart';

/// Corps d’une section sous [AnalyseSectionTitleRow] : animation de hauteur
/// (effet rideau) quand [expanded] passe à false.
class AnalyseCollapsibleSectionBody extends StatefulWidget {
  const AnalyseCollapsibleSectionBody({
    super.key,
    required this.expanded,
    required this.child,
  });

  final bool expanded;
  final Widget child;

  static const Duration _duration = Duration(milliseconds: 280);

  @override
  State<AnalyseCollapsibleSectionBody> createState() =>
      _AnalyseCollapsibleSectionBodyState();
}

class _AnalyseCollapsibleSectionBodyState extends State<AnalyseCollapsibleSectionBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnalyseCollapsibleSectionBody._duration,
    );
    _sizeFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    if (widget.expanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnalyseCollapsibleSectionBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded == oldWidget.expanded) return;
    if (widget.expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizeTransition(
        sizeFactor: _sizeFactor,
        axisAlignment: -1.0,
        child: widget.child,
      ),
    );
  }
}
