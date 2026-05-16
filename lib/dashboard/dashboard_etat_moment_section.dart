import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import '../checklist/checklist_tokens.dart';
import '../etat_mental/mental_state_controller.dart';
import '../etat_mental/mental_state_tokens.dart';
import '../etat_mental/mental_state_weight_modal.dart';
import '../etat_mental/widgets/mental_state_inline_editable_name.dart';
import '../etat_mental/widgets/mental_state_moment_section.dart';
import '../etat_mental/widgets/mental_state_sentiment_card.dart';
import '../reglage/lite_freemium_page_lock.dart';
import '../web/paychek_web_tokens.dart';
import '../web/web_dashboard_config.dart';
import 'dashboard_tokens.dart';

/// Section sous **Mon Analyse** : grille des curseurs (mÃªme rendu que la page Ã‰tat mental).
/// En-tÃªte **au-dessus** de la carte, comme [DashboardAnalyseShortcut] ; pas de 100 % / + / Ã©dition : **>** vers la page complÃ¨te.
class DashboardEtatMomentSection extends StatefulWidget {
  const DashboardEtatMomentSection({
    super.key,
    required this.onOpenEtatMental,
    this.contentPadding,
    this.cardBackgroundColor,
    this.liteInteractionLocked = false,
    this.onLiteInteractionLockedTap,
  });

  final VoidCallback onOpenEtatMental;
  final bool liteInteractionLocked;
  final VoidCallback? onLiteInteractionLockedTap;

  /// Marge intérieure du bloc (ex. web : plus d’air autour de la carte « My state »).
  final EdgeInsetsGeometry? contentPadding;

  /// Fond de l’en-tête (ex. transparent quand un cadre web l’englobe).
  final Color? cardBackgroundColor;

  @override
  State<DashboardEtatMomentSection> createState() => _DashboardEtatMomentSectionState();
}

class _DashboardEtatMomentSectionState extends State<DashboardEtatMomentSection> {
  final Map<String, GlobalKey<MentalStateInlineEditableNameState>> _metricRowLabelKeys = {};
  String? _scheduledLocaleTag;

  GlobalKey<MentalStateInlineEditableNameState> _keyForMetricRow(String id) {
    return _metricRowLabelKeys.putIfAbsent(
      id,
      () => GlobalKey<MentalStateInlineEditableNameState>(),
    );
  }

  static final TextStyle _momentTitleStyle = ChecklistTokens.sectionTitleOnCardStyle.copyWith(
    fontSize: 10,
    letterSpacing: 0.4,
  );

  Future<void> _showSleepImpactModal() async {
    final c = MentalStateController.instance;
    final snapS = c.sleepWeight;
    final snapR = c.routinesGlobalWeight;
    final snapM = c.momentBlockWeight;
    final snapE = c.emotionBlockWeight;
    final snapInv = c.sleepInverse;
    await showMentalWeightModal(
      context,
      showPolarity: true,
      showImpactSlider: true,
      initialWeight: c.sleepWeight,
      initialInverse: c.sleepInverse,
      onCancelRestore: () {
        c.sleepWeight = snapS;
        c.routinesGlobalWeight = snapR;
        c.momentBlockWeight = snapM;
        c.emotionBlockWeight = snapE;
        c.sleepInverse = snapInv;
        c.touch();
      },
      onApply: (nw, inv) {
        c.setGlobalSleepShare(nw);
        c.sleepInverse = inv;
        c.touch();
      },
    );
  }

  void _scheduleLocalizedLabelsSync() {
    final l = AppLocalizations.of(context);
    if (l == null) return;
    final locale = Localizations.localeOf(context);
    final tag = locale.toString();
    if (_scheduledLocaleTag == tag) return;
    _scheduledLocaleTag = tag;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentLocale = Localizations.localeOf(context);
      final currentTag = currentLocale.toString();
      if (_scheduledLocaleTag != currentTag) return;
      MentalStateController.instance.ensureLocalizedLabels(
        currentLocale,
        AppLocalizations.of(context)!,
      );
      _scheduledLocaleTag = null;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleLocalizedLabelsSync();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = MentalStateController.instance;
    final webDash = WebDashboardConfig.useLeftRail;

    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        if (webDash) {
          return ColoredBox(
            color: widget.cardBackgroundColor ?? DashboardTokens.scaffoldMatte,
            child: Padding(
              padding: widget.contentPadding ??
                  const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tight = constraints.maxWidth < 180;
                      final title = Text(
                        l.mentalPageTitle.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: PaychekWebTokens.textGray500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );

                      final arrow = Tooltip(
                        message: l.mentalPageTitle,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: widget.onOpenEtatMental,
                          icon: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: PaychekWebTokens.textGray500
                                .withValues(alpha: 0.85),
                          ),
                        ),
                      );

                      if (tight) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.brain,
                                  size: 16,
                                  color: PaychekWebTokens.textGray500,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: title),
                                arrow,
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.brain,
                            size: 16,
                            color: PaychekWebTokens.textGray500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: title),
                          arrow,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  LiteFreemiumInteractionBarrier(
                    locked: widget.liteInteractionLocked,
                    onLockedInteraction: () =>
                        widget.onLiteInteractionLockedTap?.call(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DashboardWebSleepHighlight(
                            controller: c,
                            onSleepImpactTap: _showSleepImpactModal,
                          ),
                          const SizedBox(height: 18),
                          MentalStateMomentSection(
                            controller: c,
                            titleStyle: _momentTitleStyle,
                            editMoment: false,
                            onToggleEditMoment: () {},
                            keyForMetricRow: _keyForMetricRow,
                            compactForDashboard: true,
                            wrapGap: 20,
                            thinMetricBars: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ColoredBox(
          color: widget.cardBackgroundColor ?? DashboardTokens.scaffoldMatte,
          child: Padding(
            padding: widget.contentPadding ??
                const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.activity,
                      size: 18,
                      color: ChecklistTokens.sectionTitleOnCardStyle.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.dashboardMyStateSection,
                        style: _momentTitleStyle,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onOpenEtatMental,
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
                  ],
                ),
                const SizedBox(height: ChecklistTokens.sectionHeaderToItemsGap),
                LiteFreemiumInteractionBarrier(
                  locked: widget.liteInteractionLocked,
                  onLockedInteraction: () =>
                      widget.onLiteInteractionLockedTap?.call(),
                  child: RepaintBoundary(
                    child: MentalStateSentimentCard(
                      padding: const EdgeInsets.all(20),
                      child: MentalStateMomentSection(
                        controller: c,
                        titleStyle: _momentTitleStyle,
                        editMoment: false,
                        onToggleEditMoment: () {},
                        keyForMetricRow: _keyForMetricRow,
                        compactForDashboard: true,
                        wrapGap: null,
                        thinMetricBars: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bloc « repos » compact pour l’aperçu web : icône, libellé, impact, % et curseur.
class _DashboardWebSleepHighlight extends StatelessWidget {
  const _DashboardWebSleepHighlight({
    required this.controller,
    required this.onSleepImpactTap,
  });

  final MentalStateController controller;
  final Future<void> Function() onSleepImpactTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = controller;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: PaychekWebTokens.accentMint.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.zap,
                  size: 22,
                  color: PaychekWebTokens.accentMint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.mentalSleepEnough,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => onSleepImpactTap(),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1, bottom: 1),
                        child: Text(
                          l.mentalSleepImpact(c.weightPercent(c.sleepWeight)),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: PaychekWebTokens.textGray500,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${c.sleepValue.round()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: c.sleepInverse
                  ? MentalStateTokens.matteRed
                  : MentalStateTokens.matteGreen,
              inactiveTrackColor: MentalStateTokens.trackBg,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: c.sleepValue.clamp(0, 100),
              min: 0,
              max: 100,
              onChanged: c.updateSleepValue,
            ),
          ),
        ],
      ),
    );
  }
}



