import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import '../checklist/checklist_tokens.dart';
import '../strategie/strategie_tokens.dart';
import '../strategie/widgets/strategie_setup_card.dart';
import '../web/paychek_web_tokens.dart';
import '../web/web_dashboard_config.dart';
import 'dashboard_tokens.dart';

/// Aperçu accueil : setup épinglé → sinon 1ᵉʳ setup → sinon titre « Ma stratégie » seul.
///
/// En-tÃªte **au-dessus** de la carte, comme [DashboardEtatMomentSection] / [DashboardAnalyseShortcut] ;
/// chevron **>** ouvre la page Ma stratÃ©gie ([onOpenStrategie]).
class DashboardHomeStrategieTeaser extends StatelessWidget {
  const DashboardHomeStrategieTeaser({
    super.key,
    required this.previewSetup,
    required this.onOpenStrategie,
    this.contentPadding,
    this.cardBackgroundColor,
  });

  final StrategieSetupCardData? previewSetup;
  final VoidCallback onOpenStrategie;

  /// Même logique que [DashboardEtatMomentSection.contentPadding] (ex. web).
  final EdgeInsetsGeometry? contentPadding;

  /// Fond derrière le contenu (ex. transparent dans un cadre web).
  final Color? cardBackgroundColor;

  static final TextStyle _titleStyle = ChecklistTokens.sectionTitleOnCardStyle.copyWith(
    fontSize: 10,
    letterSpacing: 0.4,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = previewSetup;
    final webDash = WebDashboardConfig.useLeftRail;

    if (s == null) {
      if (webDash) {
        return ColoredBox(
          color: cardBackgroundColor ?? DashboardTokens.scaffoldMatte,
          child: Padding(
            padding: contentPadding ?? const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.target,
                  size: 16,
                  color: PaychekWebTokens.textGray500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.plusMyStrategy.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: PaychekWebTokens.textGray500,
                    ),
                  ),
                ),
                Tooltip(
                  message: l.dashboardOpenStrategyTooltip,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: onOpenStrategie,
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: PaychekWebTokens.textGray500
                          .withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return ColoredBox(
        color: cardBackgroundColor ?? DashboardTokens.scaffoldMatte,
        child: Padding(
          padding: contentPadding ?? const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.target,
                size: 16,
                color: ChecklistTokens.sectionTitleOnCardStyle.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.plusMyStrategy,
                  style: _titleStyle,
                ),
              ),
              Tooltip(
                message: l.dashboardOpenStrategyTooltip,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onOpenStrategie,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 24,
                        color: ChecklistTokens.sectionTitleOnCardStyle.color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (webDash) {
      return ColoredBox(
        color: cardBackgroundColor ?? DashboardTokens.scaffoldMatte,
        child: Padding(
          padding: contentPadding ?? const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.target,
                    size: 16,
                    color: PaychekWebTokens.textGray500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.plusMyStrategy.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: PaychekWebTokens.textGray500,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: l.dashboardOpenStrategyTooltip,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: onOpenStrategie,
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: PaychekWebTokens.textGray500
                            .withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: StrategieSetupCard(
                  title: s.title,
                  dotColor: s.dotColor,
                  timeframes: s.timeframes,
                  indicateurs: s.indicateurs,
                  pattern: s.pattern,
                  signalText: s.signalText,
                  signalColor: s.signalColor,
                  ruleBlocks: s.ruleBlocks,
                  webDashboardPreview: true,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ColoredBox(
      color: cardBackgroundColor ?? DashboardTokens.scaffoldMatte,
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.target,
                  size: 16,
                  color: ChecklistTokens.sectionTitleOnCardStyle.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.plusMyStrategy,
                    style: _titleStyle,
                  ),
                ),
                Tooltip(
                  message: l.dashboardOpenStrategyTooltip,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onOpenStrategie,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 24,
                          color: ChecklistTokens.sectionTitleOnCardStyle.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ChecklistTokens.sectionHeaderToItemsGap),
            Container(
              width: double.infinity,
              decoration: StrategieTokens.sectionDecoration(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: StrategieSetupCard(
                title: s.title,
                dotColor: s.dotColor,
                timeframes: s.timeframes,
                indicateurs: s.indicateurs,
                pattern: s.pattern,
                signalText: s.signalText,
                signalColor: s.signalColor,
                ruleBlocks: s.ruleBlocks,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



