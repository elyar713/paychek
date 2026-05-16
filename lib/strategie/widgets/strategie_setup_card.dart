import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../strategie_tokens.dart';

/// Données d’une carte « Setup » (liste éditable).
class StrategieSetupCardData {
  const StrategieSetupCardData({
    required this.title,
    required this.dotColor,
    required this.timeframes,
    required this.indicateurs,
    required this.pattern,
    required this.signalText,
    required this.signalColor,
    required this.ruleBlocks,
  });

  final String title;
  final Color dotColor;
  final String timeframes;
  final String indicateurs;
  final String pattern;
  final String signalText;
  final Color signalColor;
  final List<StrategieSetupRuleBlock> ruleBlocks;
}

/// Carte « Setup » : point coloré, grille info, signal, bloc règles (icône + titre + texte).
class StrategieSetupCard extends StatelessWidget {
  const StrategieSetupCard({
    super.key,
    required this.title,
    required this.dotColor,
    required this.timeframes,
    required this.indicateurs,
    required this.pattern,
    required this.signalText,
    required this.signalColor,
    required this.ruleBlocks,
    this.onEditTap,
    this.onDeleteTap,
    this.isDashboardStarred = false,
    this.onToggleDashboardStar,
    this.webDashboardPreview = false,
    this.maquetteStyle = false,
  });

  /// Grille 2×2, titre accentué, règles en titres or — aperçu accueil web.
  final bool webDashboardPreview;

  /// Page « Ma Stratégie » (desktop) : grille 2×2 + titres de règles orange.
  final bool maquetteStyle;

  final String title;
  final Color dotColor;
  final String timeframes;
  final String indicateurs;
  final String pattern;
  final String signalText;
  final Color signalColor;
  final List<StrategieSetupRuleBlock> ruleBlocks;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final bool isDashboardStarred;
  final VoidCallback? onToggleDashboardStar;

  static const Color _starActive = Color(0xFFE6C35C);
  static const Color _webRuleHeadingGold = Color(0xFFE6C35C);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    const iconHit = BoxConstraints(minWidth: 32, minHeight: 32);
    final titleStyle = webDashboardPreview
        ? GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: Colors.white,
            height: 1.25,
          )
        : GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(webDashboardPreview ? 12 : 16),
      decoration: webDashboardPreview
          ? const BoxDecoration(color: Colors.transparent)
          : StrategieTokens.innerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.only(top: webDashboardPreview ? 6 : 5),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: webDashboardPreview ? 12 : 10),
              Expanded(
                child: Text(
                  title,
                  style: titleStyle,
                ),
              ),
              if (onToggleDashboardStar != null ||
                  onEditTap != null ||
                  onDeleteTap != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (onToggleDashboardStar != null)
                      IconButton(
                        onPressed: onToggleDashboardStar,
                        tooltip: isDashboardStarred
                            ? l.strategieSetupRemoveFromDashboard
                            : l.strategieSetupShowOnDashboard,
                        padding: EdgeInsets.zero,
                        constraints: iconHit,
                        icon: Icon(
                          isDashboardStarred
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 20,
                          color: isDashboardStarred
                              ? _starActive
                              : StrategieTokens.labelMuted,
                        ),
                      ),
                    if (onEditTap != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: iconHit,
                        tooltip: l.checklistMenuEdit,
                        icon: Icon(
                          LucideIcons.pencil,
                          size: 16,
                          color: StrategieTokens.labelMuted,
                        ),
                        onPressed: onEditTap,
                      ),
                    if (onDeleteTap != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: iconHit,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: StrategieTokens.riskRed,
                        ),
                        onPressed: onDeleteTap,
                      ),
                  ],
                ),
            ],
          ),
          SizedBox(height: webDashboardPreview ? 16 : 14),
          if (webDashboardPreview || maquetteStyle)
            _webInfoGrid(l, timeframes, indicateurs, pattern, signalText, signalColor)
          else ...[
            _kv('TIMEFRAMES', timeframes),
            const SizedBox(height: 10),
            _kv(l.strategieIndicators, indicateurs),
            const SizedBox(height: 10),
            _kv('PATTERN / FIGURE', pattern),
            const SizedBox(height: 10),
            _kv(l.strategieAlertSignal, signalText, valueColor: signalColor),
          ],
          const SizedBox(height: 14),
          Container(
            padding: EdgeInsets.all(webDashboardPreview ? 14 : 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(
                webDashboardPreview ? 10 : StrategieTokens.radiusMd,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < ruleBlocks.length; i++) ...[
                  if (i > 0) SizedBox(height: webDashboardPreview ? 16 : 14),
                  _RuleBlock(
                    r: ruleBlocks[i],
                    webDashboardPreview: webDashboardPreview,
                    maquetteStyle: maquetteStyle,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _webInfoGrid(
    AppLocalizations l,
    String timeframes,
    String indicateurs,
    String pattern,
    String signalText,
    Color signalColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _kvStacked(
                'TIMEFRAMES',
                timeframes,
                valueItalic: true,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _kvStacked(
                l.strategieIndicators.toUpperCase(),
                indicateurs,
                valueItalic: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _kvStacked(
                'PATTERN / FIGURE',
                pattern,
                valueItalic: true,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _kvStacked(
                l.strategieAlertSignal.toUpperCase(),
                signalText,
                valueColor: signalColor,
                valueItalic: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _kv(String k, String v, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            k,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: StrategieTokens.labelMuted,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            v,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.white,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _kvStacked(
    String k,
    String v, {
    Color? valueColor,
    bool valueItalic = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          k,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: StrategieTokens.labelMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          v,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontStyle: valueItalic ? FontStyle.italic : FontStyle.normal,
            color: valueColor ?? Colors.white,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class StrategieSetupRuleBlock {
  const StrategieSetupRuleBlock({
    required this.icon,
    required this.heading,
    required this.headingColor,
    required this.body,
  });

  final IconData icon;
  final String heading;
  final Color headingColor;
  final String body;
}

class _RuleBlock extends StatelessWidget {
  const _RuleBlock({
    required this.r,
    this.webDashboardPreview = false,
    this.maquetteStyle = false,
  });

  final StrategieSetupRuleBlock r;
  final bool webDashboardPreview;
  final bool maquetteStyle;

  @override
  Widget build(BuildContext context) {
    final headingColor = maquetteStyle
        ? StrategieTokens.maquetteHeadingOrange
        : (webDashboardPreview
            ? StrategieSetupCard._webRuleHeadingGold
            : r.headingColor);
    final headingText =
        (webDashboardPreview || maquetteStyle) ? r.heading.toUpperCase() : r.heading;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(r.icon, size: 18, color: StrategieTokens.labelMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headingText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight:
                      (webDashboardPreview || maquetteStyle) ? FontWeight.w800 : FontWeight.w700,
                  letterSpacing: 0.5,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                r.body,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
