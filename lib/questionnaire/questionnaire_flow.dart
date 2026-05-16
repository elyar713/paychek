import 'package:flutter/material.dart';

import '../dashboard_page.dart';
import '../l10n/app_localizations.dart';
import 'pages/questionnaire_capital_page.dart';
import 'pages/questionnaire_result_page.dart';
import 'questionnaire_question_content.dart';
import 'questionnaire_scoring.dart';
import 'questionnaire_steps_l10n.dart';
import 'widgets/questionnaire_step_page.dart';

/// EnchaÃ®ne les 6 Ã©crans : 4 questions â†’ rÃ©sultat â†’ capital â†’ dashboard.
class QuestionnaireFlow extends StatefulWidget {
  const QuestionnaireFlow({super.key, this.onFinished});

  /// Si non null : fin du flux (ex. écriture Firestore) sans [Navigator.pushReplacement] ici — le parent décide.
  final Future<void> Function()? onFinished;

  @override
  State<QuestionnaireFlow> createState() => _QuestionnaireFlowState();
}

class _QuestionnaireFlowState extends State<QuestionnaireFlow> {
  final PageController _controller = PageController();
  final GlobalKey<QuestionnaireCapitalPageState> _capitalKey = GlobalKey<QuestionnaireCapitalPageState>();

  int _pageIndex = 0;
  final List<int?> _singleSelections = [null, null, null];
  final Set<int> _challengeSelections = {};

  Locale? _stepsLocale;
  List<QuestionnaireQuestionContent>? _cachedSteps;

  List<QuestionnaireQuestionContent> _steps(BuildContext context) {
    final loc = Localizations.localeOf(context);
    if (_cachedSteps != null && _stepsLocale == loc) {
      return _cachedSteps!;
    }
    final l10n = AppLocalizations.of(context)!;
    _stepsLocale = loc;
    _cachedSteps = questionnaireStepsFromL10n(l10n);
    return _cachedSteps!;
  }

  static const _pageAnim = Duration(milliseconds: 280);
  static const _pageCurve = Curves.easeOutCubic;

  bool get _canGoNextQuestion {
    if (_pageIndex < 0 || _pageIndex > 3) return true;
    if (_pageIndex == 3) return _challengeSelections.isNotEmpty;
    return _singleSelections[_pageIndex] != null;
  }

  Future<void> _goToDashboard() async {
    final finish = widget.onFinished;
    if (finish != null) {
      await finish();
      if (!mounted) return;
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DashboardPage()),
    );
  }

  Future<void> _onArrowRight() async {
    if (_pageIndex <= 3) {
      if (!_canGoNextQuestion) return;
      await _controller.nextPage(duration: _pageAnim, curve: _pageCurve);
      return;
    }
    if (_pageIndex == 4) {
      await _controller.nextPage(duration: _pageAnim, curve: _pageCurve);
      return;
    }
    if (_pageIndex == 5) {
      final ok = await _capitalKey.currentState?.tryAdvance() ?? false;
      if (ok && mounted) {
        await _goToDashboard();
      }
      return;
    }
  }

  void _onArrowLeft() {
    if (_pageIndex <= 0) return;
    _controller.previousPage(duration: _pageAnim, curve: _pageCurve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  QuestionnaireScoreResult get _scores => QuestionnaireScoring.compute(
        q1: _singleSelections[0],
        q2: _singleSelections[1],
        q3: _singleSelections[2],
        q4: _challengeSelections,
      );

  /// Q1â€“Q3 : passage auto Ã  la page suivante dÃ¨s quâ€™un choix change.
  /// Q4 : sÃ©lection multiple, passage manuel (flÃ¨che).
  void _onQuestionSelect(int q, int i) {
    if (q == 3) {
      setState(() {
        if (_challengeSelections.contains(i)) {
          _challengeSelections.remove(i);
        } else {
          _challengeSelections.add(i);
        }
      });
      return;
    }

    final previous = _singleSelections[q];
    setState(() {
      _singleSelections[q] = i;
    });

    if (previous != i) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_pageIndex != q) return;
        if (_singleSelections[q] != i) return;
        _controller.nextPage(duration: _pageAnim, curve: _pageCurve);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps(context);
    final progress = (_pageIndex + 1) / 6;
    final nextEnabled = !(_pageIndex <= 3 && !_canGoNextQuestion);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemCount: 6,
                itemBuilder: (context, index) {
                  if (index < 4) {
                    final q = index;
                    return QuestionnaireStepPage(
                      title: steps[q].title,
                      slogan: steps[q].slogan,
                      useMPlus2ForSlogan: steps[q].useMPlus2ForSlogan,
                      options: steps[q].options,
                      multiSelect: steps[q].multiSelect,
                      selectedIndex: q < 3 ? _singleSelections[q] : null,
                      selectedIndices: q == 3 ? _challengeSelections : const {},
                      onSelect: (i) => _onQuestionSelect(q, i),
                    );
                  }
                  if (index == 4) {
                    return QuestionnaireResultPage(scores: _scores);
                  }
                  return QuestionnaireCapitalPage(key: _capitalKey);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  if (_pageIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                      onPressed: _onArrowLeft,
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: nextEnabled ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: nextEnabled ? Colors.white : Colors.white24,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      icon: Icon(
                        Icons.chevron_right,
                        color: nextEnabled ? const Color(0xFF1A1A1A) : Colors.white24,
                        size: 28,
                      ),
                      onPressed: nextEnabled
                          ? () {
                              _onArrowRight();
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



