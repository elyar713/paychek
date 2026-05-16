import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../widgets/paychek_page_header.dart';
import 'mental_state_controller.dart';
import 'mental_state_tokens.dart';
import 'mental_state_weight_modal.dart';
import 'widgets/mental_state_inline_editable_name.dart';
import 'widgets/mental_state_moment_section.dart';
import 'widgets/mental_state_emotion_section.dart';
import 'widgets/mental_state_global_score_calendar_section.dart';
import 'widgets/mental_state_overall_gauge.dart';
import 'widgets/mental_state_routines_section.dart';
import 'widgets/mental_state_sentiment_card.dart';
import 'widgets/mental_state_sleep_section.dart';

/// Page « État mental » — singleton [MentalStateController], sections découpées en widgets.
///
/// [onNavigateToDashboard] : après fermeture de la route (flèche ou retour système), bascule
/// vers l’**accueil Dashboard** (ex. `onOpenMainTab(0)`).
///
/// [onReturnToDashboard] : rappel additionnel post-frame (optionnel).
///
/// [onCloseAsTab] : page dans un [IndexedStack] — flèche / retour sans [Navigator.pop].
class MentalStatePage extends StatefulWidget {
  const MentalStatePage({
    super.key,
    this.onNavigateToDashboard,
    this.onReturnToDashboard,
    this.onCloseAsTab,
  });

  final VoidCallback? onNavigateToDashboard;
  final VoidCallback? onReturnToDashboard;
  final VoidCallback? onCloseAsTab;

  @override
  State<MentalStatePage> createState() => _MentalStatePageState();
}

class _MentalStatePageState extends State<MentalStatePage> {
  MentalStateController get _c => MentalStateController.instance;

  bool _editFactors = false;
  bool _editMoment = false;
  bool _editEmotions = false;

  final Map<String, GlobalKey<MentalStateInlineEditableNameState>> _emotionLabelKeys = {};
  final Map<String, GlobalKey<MentalStateInlineEditableNameState>> _metricRowLabelKeys = {};

  GlobalKey<MentalStateInlineEditableNameState> _keyForEmotionLabel(String id) {
    return _emotionLabelKeys.putIfAbsent(id, () => GlobalKey<MentalStateInlineEditableNameState>());
  }

  GlobalKey<MentalStateInlineEditableNameState> _keyForMetricRow(String id) {
    return _metricRowLabelKeys.putIfAbsent(id, () => GlobalKey<MentalStateInlineEditableNameState>());
  }

  TextStyle get _titleStyle => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF9CA3AF),
        letterSpacing: 1.2,
      );

  String _statusLineForScore(AppLocalizations l, double score) {
    if (score >= 70) return l.mentalPeakForm;
    if (score >= 45) return l.mentalGaugeStatusStable;
    return l.mentalGaugeStatusFragile;
  }

  Color _statusColorForScore(double score) {
    if (score >= 70) return MentalStateTokens.matteGreen;
    if (score >= 45) return const Color(0xFFE5E5E5);
    return MentalStateTokens.matteRed;
  }

  Widget _buildScrollableBody({
    required BuildContext context,
    required AppLocalizations l,
    required double score,
    required Color stroke,
    required Color centerCol,
    required double maxContent,
  }) {
    // Grille 2 colonnes dès que la largeur utile dépasse le seuil (mobile, web, desktop).
    final wide = maxContent >= MentalStateTokens.pageWideBreakpoint;
    final n = _c.indicatorCount;

    final gaugeCard = MentalStateSentimentCard(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Center(
        child: MentalStateOverallGauge(
          score: score,
          strokeColor: stroke,
          centerTextColor: centerCol,
          gaugeBottomLabel: l.mentalGaugeStateLabel,
          statusLine: _statusLineForScore(l, score),
          basedOnLine: l.mentalGaugeBasedOnIndicators(n),
          statusColor: _statusColorForScore(score),
          gaugeDiameter: wide ? MentalStateTokens.gaugeSizeWide : null,
        ),
      ),
    );

    final sleepCard = MentalStateSentimentCard(
      padding: const EdgeInsets.all(20),
      child: MentalStateSleepSection(
        controller: _c,
        titleStyle: _titleStyle,
        onSleepImpactTap: _showSleepImpactModal,
      ),
    );

    final globalScoreCalendarCard = MentalStateSentimentCard(
      padding: const EdgeInsets.all(20),
      child: MentalStateGlobalScoreCalendarSection(
        controller: _c,
        titleStyle: _titleStyle,
      ),
    );

    final routinesCard = MentalStateSentimentCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: MentalStateTokens.factorSectionBg,
      child: MentalStateRoutinesSection(
        controller: _c,
        titleStyle: _titleStyle,
        editFactors: _editFactors,
        onToggleEditFactors: () => setState(() => _editFactors = !_editFactors),
        keyForMetricRow: _keyForMetricRow,
        onGlobalRoutinesModal: _showGlobalRoutinesShareModal,
      ),
    );

    final momentCard = MentalStateSentimentCard(
      padding: const EdgeInsets.all(20),
      child: MentalStateMomentSection(
        controller: _c,
        titleStyle: _titleStyle,
        editMoment: _editMoment,
        onToggleEditMoment: () => setState(() => _editMoment = !_editMoment),
        keyForMetricRow: _keyForMetricRow,
        onGlobalMomentModal: _showGlobalMomentShareModal,
        thinMetricBars: wide,
        wrapGap: wide ? 16 : 24,
      ),
    );

    final emotionCard = MentalStateSentimentCard(
      padding: const EdgeInsets.all(20),
      child: MentalStateEmotionSection(
        controller: _c,
        titleStyle: _titleStyle,
        editEmotions: _editEmotions,
        onToggleEditEmotions: () => setState(() => _editEmotions = !_editEmotions),
        keyForEmotionLabel: _keyForEmotionLabel,
        onGlobalEmotionModal: _showGlobalEmotionShareModal,
        onDeleteEmotionAt: _deleteEmotionAt,
      ),
    );

    if (wide) {
      const gap = 20.0;
      final leftW = (maxContent * 0.38).clamp(260.0, 400.0);
      final rightW = maxContent - leftW - gap;
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: SizedBox(
            width: maxContent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: leftW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      gaugeCard,
                      const SizedBox(height: 16),
                      sleepCard,
                      const SizedBox(height: 16),
                      globalScoreCalendarCard,
                    ],
                  ),
                ),
                const SizedBox(width: gap),
                SizedBox(
                  width: rightW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      routinesCard,
                      const SizedBox(height: 16),
                      momentCard,
                      const SizedBox(height: 16),
                      emotionCard,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          gaugeCard,
          const SizedBox(height: 16),
          sleepCard,
          const SizedBox(height: 16),
          routinesCard,
          const SizedBox(height: 16),
          momentCard,
          const SizedBox(height: 16),
          emotionCard,
          const SizedBox(height: 16),
          globalScoreCalendarCard,
        ],
      ),
    );
  }

  Color _gaugeStroke(double score) {
    if (score >= 70) return MentalStateTokens.matteGreen;
    if (score >= 45) return Colors.white;
    return MentalStateTokens.matteRed;
  }

  Color _gaugeCenterText(double score) {
    if (score >= 70) return Colors.white;
    if (score >= 45) return Colors.white;
    return MentalStateTokens.matteRed;
  }

  Future<void> _showGlobalEmotionShareModal() async {
    final snapS = _c.sleepWeight;
    final snapR = _c.routinesGlobalWeight;
    final snapM = _c.momentBlockWeight;
    final snapE = _c.emotionBlockWeight;
    await showMentalWeightModal(
      context,
      showPolarity: false,
      initialWeight: _c.emotionBlockWeight,
      initialInverse: false,
      onCancelRestore: () {
        _c.sleepWeight = snapS;
        _c.routinesGlobalWeight = snapR;
        _c.momentBlockWeight = snapM;
        _c.emotionBlockWeight = snapE;
        _c.touch();
      },
      onApply: (nw, inv) {
        _c.setGlobalEmotionShare(nw);
        _c.touch();
      },
    );
  }

  Future<void> _showGlobalRoutinesShareModal() async {
    final snapS = _c.sleepWeight;
    final snapR = _c.routinesGlobalWeight;
    final snapM = _c.momentBlockWeight;
    final snapE = _c.emotionBlockWeight;
    await showMentalWeightModal(
      context,
      showPolarity: false,
      initialWeight: _c.routinesGlobalWeight,
      initialInverse: false,
      onCancelRestore: () {
        _c.sleepWeight = snapS;
        _c.routinesGlobalWeight = snapR;
        _c.momentBlockWeight = snapM;
        _c.emotionBlockWeight = snapE;
        _c.touch();
      },
      onApply: (nw, inv) {
        _c.setGlobalRoutinesShare(nw);
        _c.touch();
      },
    );
  }

  Future<void> _showGlobalMomentShareModal() async {
    final snapS = _c.sleepWeight;
    final snapR = _c.routinesGlobalWeight;
    final snapM = _c.momentBlockWeight;
    final snapE = _c.emotionBlockWeight;
    await showMentalWeightModal(
      context,
      showPolarity: false,
      initialWeight: _c.momentBlockWeight,
      initialInverse: false,
      onCancelRestore: () {
        _c.sleepWeight = snapS;
        _c.routinesGlobalWeight = snapR;
        _c.momentBlockWeight = snapM;
        _c.emotionBlockWeight = snapE;
        _c.touch();
      },
      onApply: (nw, inv) {
        _c.setGlobalMomentShare(nw);
        _c.touch();
      },
    );
  }

  Future<void> _showSleepImpactModal() async {
    final snapS = _c.sleepWeight;
    final snapR = _c.routinesGlobalWeight;
    final snapM = _c.momentBlockWeight;
    final snapE = _c.emotionBlockWeight;
    final snapInv = _c.sleepInverse;
    await showMentalWeightModal(
      context,
      showPolarity: true,
      showImpactSlider: true,
      initialWeight: _c.sleepWeight,
      initialInverse: _c.sleepInverse,
      onCancelRestore: () {
        _c.sleepWeight = snapS;
        _c.routinesGlobalWeight = snapR;
        _c.momentBlockWeight = snapM;
        _c.emotionBlockWeight = snapE;
        _c.sleepInverse = snapInv;
        _c.touch();
      },
      onApply: (nw, inv) {
        _c.setGlobalSleepShare(nw);
        _c.sleepInverse = inv;
        _c.touch();
      },
    );
  }

  void _deleteEmotionAt(int index) {
    final removedId = _c.emotions[index].id;
    _c.emotions.removeAt(index);
    if (_c.emotions.isNotEmpty && _c.emotionsShare100) {
      _c.equalizeEmotionWeights();
    }
    _c.selectedEmotionIds.remove(removedId);
    if (_c.selectedEmotionIds.isEmpty && _c.emotions.isNotEmpty) {
      _c.selectedEmotionIds.add(_c.emotions.first.id);
    }
    _c.touch();
  }

  void _afterPopGoDashboard() {
    final cb = widget.onReturnToDashboard;
    if (cb == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => cb());
  }

  bool get _embeddedInTabShell => widget.onCloseAsTab != null;

  void _handleLeadingBack() {
    if (_embeddedInTabShell) {
      widget.onCloseAsTab!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        _c.ensureLocalizedLabels(Localizations.localeOf(context), l);
        final score = _c.overallScore;
        final stroke = _gaugeStroke(score);
        final centerCol = _gaugeCenterText(score);

        return PopScope(
          canPop: !_embeddedInTabShell,
          onPopInvokedWithResult: (didPop, result) {
            if (_embeddedInTabShell) {
              if (!didPop) widget.onCloseAsTab!();
              return;
            }
            if (didPop) {
              widget.onNavigateToDashboard?.call();
              _afterPopGoDashboard();
            }
          },
          child: Scaffold(
          backgroundColor: MentalStateTokens.scaffoldBg,
          body: Stack(
            children: [
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final hPad = PaychekPageHeader.horizontalPad(constraints.maxWidth);
                    final maxContent = math.min(
                      MentalStateTokens.pageMaxWide,
                      math.max(0.0, constraints.maxWidth - 2 * hPad),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PaychekPageHeader(
                          onBack: _handleLeadingBack,
                          title: l.mentalPageTitle,
                          subtitle: l.mentalPageIntro,
                          subtitleMaxLines: 2,
                          maxContentWidth: MentalStateTokens.pageMaxWide,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxContent),
                                child: _buildScrollableBody(
                                  context: context,
                                  l: l,
                                  score: score,
                                  stroke: stroke,
                                  centerCol: centerCol,
                                  maxContent: maxContent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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
