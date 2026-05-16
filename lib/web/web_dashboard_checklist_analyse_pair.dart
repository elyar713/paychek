import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'paychek_web_tokens.dart';

/// Carte encadrée (web) pour un bloc seul sur l’accueil.
class WebDashboardPairedCard extends StatelessWidget {
  const WebDashboardPairedCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = kIsWeb ? PaychekWebTokens.radiusCard : 20.0;
    final fill =
        kIsWeb ? PaychekWebTokens.cardBg : DashboardTokens.cardBoxBg;
    final side = kIsWeb
        ? PaychekWebTokens.cardBorder.withValues(alpha: 0.85)
        : DashboardTokens.border.withValues(alpha: 0.55);
    return Material(
      color: fill,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: side),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: child,
      ),
    );
  }
}

/// Padding vertical du contenu dans [WebDashboardPairedCard] (`12 + 16`). À garder aligné avec la carte.
const double _kWebPairedCardContentVerticalPadding = 28.0;

/// Paire checklist + « Mon analyse » : la checklist **prend la même hauteur** que la carte « Mon analyse »
/// (hauteur mesurée après layout, sans imposer de min/max viewport à l’analyse).
class WebDashboardChecklistAnalysePair extends StatefulWidget {
  const WebDashboardChecklistAnalysePair({
    super.key,
    required this.wide,
    required this.gap,
    required this.checklistChild,
    required this.analyseChild,
    required this.onOpenChecklistFull,
  });

  final bool wide;
  final double gap;
  final Widget checklistChild;
  final Widget analyseChild;
  final VoidCallback onOpenChecklistFull;

  @override
  State<WebDashboardChecklistAnalysePair> createState() =>
      _WebDashboardChecklistAnalysePairState();
}

class _WebDashboardChecklistAnalysePairState
    extends State<WebDashboardChecklistAnalysePair> {
  final GlobalKey _analyseCardKey = GlobalKey();

  /// Hauteur **intérieure** (hors padding de [WebDashboardPairedCard]) de la colonne checklist + lien « Plus ».
  /// `null` : pas encore mesuré (première frame ou analyse pas encore layout).
  double? _checklistTargetInnerHeight;

  void _measureAnalyseCardOuterHeight() {
    if (!mounted) return;
    final ctx = _analyseCardKey.currentContext;
    if (ctx == null) return;
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.hasSize) return;
    final outerH = ro.size.height;
    final inner = (outerH - _kWebPairedCardContentVerticalPadding)
        .clamp(120.0, double.infinity);
    if (_checklistTargetInnerHeight == null ||
        (_checklistTargetInnerHeight! - inner).abs() > 0.5) {
      setState(() => _checklistTargetInnerHeight = inner);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WebDashboardPairedCard(child: widget.analyseChild),
          const SizedBox(height: 16),
          WebDashboardPairedCard(child: widget.checklistChild),
        ],
      );
    }

    /// Mon analyse / checklist : checklist ~20 % moins large qu’en 5:4 (≈ 36 % vs 44 % de la ligne).
    const flexAnalyse = 29;
    const flexChecklist = 16;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Même si le parent considère la ligne « large », un rail / split peut laisser très peu de place :
        // Row + gap + Expanded → contraintes impossibles / overflows en cascade.
        const minSideBySide = 340.0;
        if (constraints.maxWidth < minSideBySide + widget.gap) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WebDashboardPairedCard(child: widget.analyseChild),
              const SizedBox(height: 16),
              WebDashboardPairedCard(child: widget.checklistChild),
            ],
          );
        }

        WidgetsBinding.instance
            .addPostFrameCallback((_) => _measureAnalyseCardOuterHeight());

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: flexAnalyse,
              child: WebDashboardPairedCard(
                key: _analyseCardKey,
                child: widget.analyseChild,
              ),
            ),
            SizedBox(width: widget.gap),
            Expanded(
              flex: flexChecklist,
              child: WebDashboardPairedCard(
                child: _WebChecklistSizedToAnalyse(
                  innerHeight: _checklistTargetInnerHeight,
                  onOpenFull: widget.onOpenChecklistFull,
                  child: widget.checklistChild,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WebChecklistSizedToAnalyse extends StatelessWidget {
  const _WebChecklistSizedToAnalyse({
    required this.innerHeight,
    required this.onOpenFull,
    required this.child,
  });

  /// Hauteur intérieure cible ; `null` = layout naturel jusqu’à la mesure de la carte analyse.
  final double? innerHeight;
  final VoidCallback onOpenFull;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final footer = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenFull,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.dashboardChecklistSeeRest,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: PaychekWebTokens.accentMint,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final h = innerHeight;
    if (h == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          footer,
        ],
      );
    }

    final scroll = SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      primary: false,
      child: Align(
        alignment: Alignment.topCenter,
        widthFactor: 1,
        child: child,
      ),
    );

    return SizedBox(
      height: h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRect(child: scroll),
          ),
          footer,
        ],
      ),
    );
  }
}
