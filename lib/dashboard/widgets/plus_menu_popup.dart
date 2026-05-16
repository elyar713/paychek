import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard_tokens.dart';
import '../../web/plus_menu_actions.dart';

/// Menu **Plus** : une case par entrÃ©e, apparition en cascade depuis la droite.
class PlusMenuPopup extends StatefulWidget {
  const PlusMenuPopup({
    super.key,
    required this.onOpenMainTab,
    required this.onOpenMental,
    required this.onOpenStrategie,
    required this.onOpenAnalyse,
    required this.onOpenPerformance,
    required this.onOpenChecklist,
    required this.onOpenCalculatrice,
    required this.onOpenReglage,
    this.liteGate,
  });

  final ValueChanged<int> onOpenMainTab;
  final VoidCallback onOpenMental;
  final VoidCallback onOpenStrategie;
  final VoidCallback onOpenAnalyse;
  final VoidCallback onOpenPerformance;
  final VoidCallback onOpenChecklist;
  final VoidCallback onOpenCalculatrice;
  final VoidCallback onOpenReglage;
  final PlusMenuLiteGate? liteGate;

  @override
  State<PlusMenuPopup> createState() => _PlusMenuPopupState();
}

class _PlusMenuPopupState extends State<PlusMenuPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// DurÃ©e totale un peu longue pour laisser chaque ligne Â« respirer Â».
  static const Duration _totalDuration = Duration(milliseconds: 1180);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Cascade fluide : lÃ©ger dÃ©calage entre les lignes mais forte fenÃªtre commune
  /// (chevauchement) pour Ã©viter lâ€™effet Â« mÃ©tronome Â».
  Animation<double> _slideIntervalForIndex(int index) {
    const stagger = 0.034;
    const window = 0.48;
    final start = (index * stagger).clamp(0.0, 1.0);
    final end = (start + window).clamp(0.0, 1.0);
    if (end <= start) {
      return const AlwaysStoppedAnimation<double>(1);
    }
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutQuart),
    );
  }

  /// Le fondu se termine un peu avant la fin du slide : entrÃ©e plus naturelle.
  Animation<double> _fadeIntervalForIndex(int index) {
    const stagger = 0.034;
    const slideWindow = 0.48;
    const fadePortion = 0.62;
    final start = (index * stagger).clamp(0.0, 1.0);
    final slideEnd = (start + slideWindow).clamp(0.0, 1.0);
    final span = slideEnd - start;
    final end = (start + span * fadePortion).clamp(0.0, 1.0);
    if (end <= start) {
      return const AlwaysStoppedAnimation<double>(1);
    }
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxH = MediaQuery.sizeOf(context).height * 0.42;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final entries = PlusMenuActions.buildEntries(
      l10n,
      onOpenMainTab: widget.onOpenMainTab,
      onOpenMental: widget.onOpenMental,
      onOpenStrategie: widget.onOpenStrategie,
      onOpenAnalyse: widget.onOpenAnalyse,
      onOpenPerformance: widget.onOpenPerformance,
      onOpenChecklist: widget.onOpenChecklist,
      onOpenCalculatrice: widget.onOpenCalculatrice,
      onOpenReglage: widget.onOpenReglage,
      includeHelpCenter: false,
      liteGate: widget.liteGate,
    );

    final n = entries.length;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < n; i++) ...[
                reduceMotion
                    ? _case(
                        context,
                        entries[i].icon,
                        entries[i].label,
                        entries[i].onTap,
                      )
                    : _animatedCase(
                        context,
                        i,
                        entries[i].icon,
                        entries[i].label,
                        entries[i].onTap,
                      ),
                if (i < n - 1) const SizedBox(height: 6),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedCase(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final slideAnim = _slideIntervalForIndex(index);
    final fadeAnim = _fadeIntervalForIndex(index);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.075, 0),
        end: Offset.zero,
      ).animate(slideAnim),
      child: FadeTransition(
        opacity: fadeAnim,
        child: _case(context, icon, label, onTap),
      ),
    );
  }

  Widget _case(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Material(
      color: DashboardTokens.cardBoxBg,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: DashboardTokens.accent.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 6, 7),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: DashboardTokens.accent),
                const SizedBox(width: 8),
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DashboardTokens.onMatteEmphasis,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



