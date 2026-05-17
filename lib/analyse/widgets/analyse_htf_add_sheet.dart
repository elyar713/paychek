import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../analyse_models.dart';
import '../analyse_tokens.dart';

/// Menu « + » timeframe (contexte My Analyse) — dialogue centré compact.
Future<AnalyseHtfAddChoice?> showAnalyseHtfAddSheet(
  BuildContext context, {
  required List<AnalyseTimeframe> hiddenEnums,
  required Set<String> visibleLabels,
}) {
  final extras = htfExtraPresetsNotVisible(visibleLabels);
  final intradayExtras = extras
      .where((l) => !const {'Weekly', 'Monthly'}.contains(l))
      .toList();
  final swingExtras = extras
      .where((l) => const {'Weekly', 'Monthly'}.contains(l))
      .toList();

  return showDialog<AnalyseHtfAddChoice>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogCtx) {
      final l = AppLocalizations.of(dialogCtx)!;
      final size = MediaQuery.sizeOf(dialogCtx);
      final maxW = size.width < 480 ? size.width * 0.92 : 400.0;
      final maxH = size.height * 0.72;

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF252525)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHeader(
                  title: l.analyseAddTimeframeTitle,
                  onClose: () => Navigator.pop(dialogCtx),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hiddenEnums.isNotEmpty) ...[
                          _SheetSectionLabel(
                            title: l.analyseAddTimeframeSectionRestore,
                          ),
                          const SizedBox(height: 6),
                          _TfChipWrap(
                            children: [
                              for (final tf in hiddenEnums)
                                _TfPickChip(
                                  label: ctxLabelHtf(tf),
                                  muted: true,
                                  onTap: () => Navigator.pop(
                                    dialogCtx,
                                    AnalyseHtfAddChoiceEnum(tf),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (intradayExtras.isNotEmpty) ...[
                          _SheetSectionLabel(
                            title: l.analyseAddTimeframeSectionIntraday,
                          ),
                          const SizedBox(height: 6),
                          _TfChipWrap(
                            children: [
                              for (final label in intradayExtras)
                                _TfPickChip(
                                  label: label,
                                  onTap: () => Navigator.pop(
                                    dialogCtx,
                                    AnalyseHtfAddChoiceLabel(label),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (swingExtras.isNotEmpty) ...[
                          _SheetSectionLabel(
                            title: l.analyseAddTimeframeSectionSwing,
                          ),
                          const SizedBox(height: 6),
                          _TfChipWrap(
                            children: [
                              for (final label in swingExtras)
                                _TfPickChip(
                                  label: label,
                                  onTap: () => Navigator.pop(
                                    dialogCtx,
                                    AnalyseHtfAddChoiceLabel(label),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],
                        _CustomTimeframeRow(
                          title: l.analyseAddTimeframeCustomEntry,
                          onTap: () => Navigator.pop(
                            dialogCtx,
                            const AnalyseHtfAddChoiceDraft(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AnalyseTokens.labelStyle.copyWith(
                color: AnalyseTokens.matteText,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF8A8A8A)),
          ),
        ],
      ),
    );
  }
}

class _SheetSectionLabel extends StatelessWidget {
  const _SheetSectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AnalyseTokens.labelStyle.copyWith(
        color: const Color(0xFF6E6E6E),
        fontSize: 9,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _TfChipWrap extends StatelessWidget {
  const _TfChipWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: children,
    );
  }
}

class _TfPickChip extends StatelessWidget {
  const _TfPickChip({
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: muted ? const Color(0xFF101010) : AnalyseTokens.chipBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusChip),
        side: BorderSide(
          color: muted ? const Color(0xFF2E2E2E) : const Color(0xFF333333),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusChip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (muted) ...[
                const Icon(
                  Icons.replay_rounded,
                  size: 13,
                  color: Color(0xFF6A6A6A),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: muted
                      ? const Color(0xFFB8B8B8)
                      : AnalyseTokens.matteText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomTimeframeRow extends StatelessWidget {
  const _CustomTimeframeRow({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111111),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 16,
                color: AnalyseTokens.chipHtfSelected,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AnalyseTokens.matteText,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF5A5A5A),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
