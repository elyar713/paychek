import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../l10n/app_localizations.dart';

import 'analyse_controller.dart';
import 'analyse_firestore_sync.dart';
import 'analyse_feuille_contexte_template_dialogs.dart';
import 'analyse_tokens.dart';

/// Panneau sous le chevron, positionnÃ© une fois en coordonnÃ©es globales (Ã©vite
/// [CompositedTransformFollower] dans la liste dÃ©filante â†’ sync Ã  chaque frame, gels).
OverlayEntry buildFeuilleContexteTemplateModelsOverlayEntry({
  required BuildContext hostContext,
  required Offset panelTopLeft,
  required AnalyseController controller,
  required VoidCallback onDismiss,
  required bool Function() isMounted,
}) {
  return OverlayEntry(
    builder: (ctx) => _FeuilleContexteTemplateMenuOverlay(
      panelTopLeft: panelTopLeft,
      controller: controller,
      hostContext: hostContext,
      onDismiss: onDismiss,
      isMounted: isMounted,
    ),
  );
}

class _FeuilleContexteTemplateMenuOverlay extends StatefulWidget {
  const _FeuilleContexteTemplateMenuOverlay({
    required this.panelTopLeft,
    required this.controller,
    required this.hostContext,
    required this.onDismiss,
    required this.isMounted,
  });

  final Offset panelTopLeft;
  final AnalyseController controller;
  final BuildContext hostContext;
  final VoidCallback onDismiss;
  final bool Function() isMounted;

  @override
  State<_FeuilleContexteTemplateMenuOverlay> createState() =>
      _FeuilleContexteTemplateMenuOverlayState();
}

class _FeuilleContexteTemplateMenuOverlayState
    extends State<_FeuilleContexteTemplateMenuOverlay> {
  bool _barrierDismissEnabled = false;
  List<String>? _names;

  static const double _panelW = 136;
  static const double _emptyH = 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _barrierDismissEnabled = true);
    });
    _loadNames();
  }

  Future<void> _loadNames() async {
    final list = await widget.controller.listFeuilleContextePillsTemplateNames();
    if (!mounted) return;
    setState(() => _names = list);
  }

  void _onBarrierTap() {
    if (!_barrierDismissEnabled) return;
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final screenH = MediaQuery.sizeOf(context).height;
    final maxPanelH = (screenH * 0.28).clamp(100.0, 200.0);
    final names = _names;
    final top = widget.panelTopLeft.dy;
    final left = widget.panelTopLeft.dx;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onBarrierTap,
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          width: _panelW,
          child: RepaintBoundary(
            child: Material(
              elevation: 14,
              color: const Color(0xFF141414),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFF2A2A2A)),
              ),
              clipBehavior: Clip.antiAlias,
              child: names == null
                  ? SizedBox(
                      width: _panelW,
                      height: 56,
                      child: ColoredBox(
                        color: const Color(0xFF141414),
                        child: Center(
                          child: Text(
                            'â€¦',
                            style: TextStyle(
                              color: AnalyseTokens.muted2,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    )
                  : names.isEmpty
                      ? SizedBox(
                          width: _panelW,
                          height: _emptyH,
                          child: ColoredBox(
                            color: const Color(0xFF141414),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Center(
                                child: Text(
                                  l.analyseNoTemplatesSaved,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AnalyseTokens.muted2,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : ColoredBox(
                          color: const Color(0xFF141414),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: maxPanelH),
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: names.length,
                              separatorBuilder: (_, _) => Divider(
                                height: 1,
                                thickness: 1,
                                color: AnalyseTokens.cardBorder
                                    .withValues(alpha: 0.55),
                              ),
                              itemBuilder: (context, i) {
                                return _FeuilleContexteTemplateModelRow(
                                  name: names[i],
                                  controller: widget.controller,
                                  hostContext: widget.hostContext,
                                  onDismiss: widget.onDismiss,
                                  isMounted: widget.isMounted,
                                  l: l,
                                );
                              },
                            ),
                          ),
                        ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeuilleContexteTemplateModelRow extends StatelessWidget {
  const _FeuilleContexteTemplateModelRow({
    required this.name,
    required this.controller,
    required this.hostContext,
    required this.onDismiss,
    required this.isMounted,
    required this.l,
  });

  final String name;
  final AnalyseController controller;
  final BuildContext hostContext;
  final VoidCallback onDismiss;
  final bool Function() isMounted;
  final AppLocalizations l;

  Future<void> _onApply() async {
    await controller.applyFeuilleContextePillsTemplateNamed(name);
    AnalyseFirestoreSync.pushIfSignedIn();
    onDismiss();
    if (!isMounted()) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) return;
      ScaffoldMessenger.of(hostContext).showSnackBar(
        SnackBar(content: Text(l.analyseTemplateApplied(name))),
      );
    });
  }

  Future<void> _onRename() async {
    onDismiss();
    final old = name;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!isMounted()) return;
      final newName = await showDialog<String>(
        context: hostContext,
        barrierColor: Colors.black54,
        builder: (dctx) =>
            RenameFeuilleContexteTemplateDialog(initialName: old),
      );
      if (newName == null || newName.trim().isEmpty || !isMounted()) {
        return;
      }
      await controller.renameFeuilleContextePillsTemplateNamed(
        old,
        newName.trim(),
      );
      AnalyseFirestoreSync.pushIfSignedIn();
    });
  }

  Future<void> _onDelete() async {
    onDismiss();
    final toDelete = name;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!isMounted()) return;
      final ok = await showDialog<bool>(
        context: hostContext,
        barrierColor: Colors.black54,
        builder: (dctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          title: Text(
            l.analyseDeleteTemplateTitle,
            style: AnalyseTokens.labelStyle.copyWith(
              color: AnalyseTokens.matteText,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dctx, false),
              child: Text(
                l.cancel,
                style: TextStyle(color: AnalyseTokens.muted2),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AnalyseTokens.accentRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dctx, true),
              child: Text(l.delete),
            ),
          ],
        ),
      );
      if (ok == true && isMounted()) {
        await controller.deleteFeuilleContextePillsTemplateNamed(toDelete);
        AnalyseFirestoreSync.pushIfSignedIn();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _onApply,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 6,
                ),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFDFDFDF),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
            icon: Icon(
              LucideIcons.pencil,
              size: 15,
              color: const Color(0xFF9A9A9A),
            ),
            onPressed: _onRename,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
            icon: Icon(
              LucideIcons.trash2,
              size: 15,
              color: AnalyseTokens.accentRed,
            ),
            onPressed: _onDelete,
          ),
        ],
      ),
    );
  }
}



