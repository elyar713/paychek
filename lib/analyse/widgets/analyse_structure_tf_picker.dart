import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../l10n/app_localizations.dart';
import '../analyse_controller.dart';
import '../analyse_models.dart';
import '../analyse_tokens.dart';

/// Menu ancrÃ© sous la pilule TF (comme un dropdown), pas en bas dâ€™Ã©cran.
///
/// - Structure : [structureSnapshotIndex] non nul â†’ copie dupliquÃ©e ; sinon TF principal.
/// - Indicateurs : [forIndicatorsSection] ; [indicatorsSnapshotIndex] non nul â†’ copie.
/// - SMC : [forSmcSection] ; [smcSnapshotIndex] non nul â†’ copie.
/// - Profil de volume : [forVolumeProfileSection].
Future<void> showAnalyseStructureTfPicker(
  BuildContext context,
  AnalyseController controller, {
  int? structureSnapshotIndex,
  bool forIndicatorsSection = false,
  int? indicatorsSnapshotIndex,
  bool forSmcSection = false,
  int? smcSnapshotIndex,
  bool forVolumeProfileSection = false,
}) async {
  final c = controller;
  final rootContext = context;

  final multiSection = (forIndicatorsSection ? 1 : 0) +
      (forSmcSection ? 1 : 0) +
      (forVolumeProfileSection ? 1 : 0);
  if (multiSection > 1) return;

  if (forVolumeProfileSection) {
    // Rien d’autre à valider.
  } else if (forSmcSection) {
    if (smcSnapshotIndex != null) {
      if (smcSnapshotIndex < 0 || smcSnapshotIndex >= c.smcSnapshots.length) {
        return;
      }
    }
  } else if (forIndicatorsSection) {
    if (indicatorsSnapshotIndex != null) {
      if (indicatorsSnapshotIndex < 0 ||
          indicatorsSnapshotIndex >= c.indicatorsSnapshots.length) {
        return;
      }
    }
  } else {
    if (structureSnapshotIndex != null) {
      if (structureSnapshotIndex < 0 ||
          structureSnapshotIndex >= c.structureSnapshots.length) {
        return;
      }
    }
  }

  final structSnap =
      (forIndicatorsSection || forSmcSection) ? null : structureSnapshotIndex;
  final indSnap = forIndicatorsSection ? indicatorsSnapshotIndex : null;
  final smcSnap = forSmcSection ? smcSnapshotIndex : null;

  String currentTf() {
    if (forVolumeProfileSection) {
      return c.volumeProfileTf;
    }
    if (forSmcSection) {
      return smcSnap != null ? c.smcSnapshots[smcSnap].smcTf : c.smcTf;
    }
    if (forIndicatorsSection) {
      return indSnap != null
          ? c.indicatorsSnapshots[indSnap].indicatorsTf
          : c.indicatorsTf;
    }
    return structSnap != null
        ? c.structureSnapshots[structSnap].structureTf
        : c.structureTf;
  }

  void applyTf(String label) {
    if (forVolumeProfileSection) {
      c.volumeProfileTf = label;
      return;
    }
    if (forSmcSection) {
      if (smcSnap != null) {
        c.setSmcSnapshotTf(smcSnap, label);
      } else {
        c.smcTf = label;
      }
      return;
    }
    if (forIndicatorsSection) {
      if (indSnap != null) {
        c.setIndicatorsSnapshotTf(indSnap, label);
      } else {
        c.indicatorsTf = label;
      }
    } else {
      if (structSnap != null) {
        c.setStructureSnapshotTf(structSnap, label);
      } else {
        c.structureTf = label;
      }
    }
  }

  final RenderBox? button = context.findRenderObject() as RenderBox?;
  final RenderBox? overlay = Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
  if (button == null || overlay == null) return;

  final overlaySize = overlay.size;
  final topLeft = overlay.localToGlobal(Offset.zero);
  final containerRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, overlaySize.width, overlaySize.height);
  final buttonRect = Rect.fromPoints(
    button.localToGlobal(Offset.zero),
    button.localToGlobal(Offset(button.size.width, button.size.height)),
  );
  final position = RelativeRect.fromRect(buttonRect, containerRect);

  Future<void> openAddDialog() async {
    final result = await showDialog<String?>(
      context: rootContext,
      useRootNavigator: true,
      builder: (ctx) => const _AddStructureTfDialog(),
    );

    // Ã‰vite notifyListeners() pendant le dÃ©montage de la route (assert _dependents.isEmpty).
    if (result == null) return;
    final v = result.trim();
    if (v.isEmpty) return;

    void apply() {
      if (!rootContext.mounted) return;
      if (forVolumeProfileSection) {
        c.addVolumeProfileTfCustom(v);
      } else if (forSmcSection) {
        if (smcSnap != null) {
          c.addSmcSnapshotTfCustom(smcSnap, v);
        } else {
          c.addSmcTfCustom(v);
        }
      } else if (forIndicatorsSection) {
        if (indSnap != null) {
          c.addIndicatorsSnapshotTfCustom(indSnap, v);
        } else {
          c.addIndicatorsTfCustom(v);
        }
      } else {
        if (structSnap != null) {
          c.addStructureSnapshotTfCustom(structSnap, v);
        } else {
          c.addStructureTfCustom(v);
        }
      }
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        apply();
      });
    });
  }

  /// AprÃ¨s fermeture du menu : Ã©vite dâ€™empiler [showDialog] sur la route du menu (crash / Ã©cran rouge).
  void scheduleOpenAddDialog() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (rootContext.mounted) {
          openAddDialog();
        }
      });
    });
  }

  final presetLabels = AnalyseStructureChartTf.values.map((e) => e.label).toList();
  final List<String> customSource = forVolumeProfileSection
      ? c.volumeProfileTfCustom
      : forSmcSection
          ? c.smcTfCustom
          : forIndicatorsSection
              ? c.indicatorsTfCustom
              : c.structureTfCustom;
  final custom = customSource.where((s) => !presetLabels.contains(s)).toList();

  final mq = MediaQuery.sizeOf(context);
  final maxH = mq.height * 0.45;
  final l = AppLocalizations.of(context)!;

  await showMenu<void>(
    context: context,
    position: position,
    color: const Color(0xFF121212).withValues(alpha: 0.88),
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AnalyseTokens.cardBorder),
    ),
    constraints: BoxConstraints(
      minWidth: button.size.width,
      maxWidth: 200,
      maxHeight: maxH,
    ),
    items: [
      for (final label in presetLabels)
        PopupMenuItem<void>(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          height: 40,
          onTap: () {
            Future<void>.delayed(Duration.zero, () {
              applyTf(label);
            });
          },
          child: _MenuRow(label: label, selected: currentTf() == label),
        ),
      for (final label in custom)
        PopupMenuItem<void>(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          height: 40,
          onTap: () {
            Future<void>.delayed(Duration.zero, () {
              applyTf(label);
            });
          },
          child: _MenuRow(label: label, selected: currentTf() == label),
        ),
      const PopupMenuDivider(height: 1),
      PopupMenuItem<void>(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        height: 44,
        onTap: scheduleOpenAddDialog,
        child: Row(
          children: [
            _AddCircleIcon(),
            const SizedBox(width: 10),
            Text(
              l.navAdd,
              style: const TextStyle(
                color: AnalyseTokens.matteText,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

/// Dialogue Â« Ajouter un TF Â» : le [TextEditingController] est possÃ©dÃ© par lâ€™Ã©tat et
/// disposÃ© dans [State.dispose] aprÃ¨s retrait du [TextField] (ordre sÃ»r pour Flutter).
class _AddStructureTfDialog extends StatefulWidget {
  const _AddStructureTfDialog();

  @override
  State<_AddStructureTfDialog> createState() => _AddStructureTfDialogState();
}

class _AddStructureTfDialogState extends State<_AddStructureTfDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: const Color(0xFF0a0a0a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF222222)),
      ),
      title: Text(
        l.analyseAddTimeframeTitle,
        style: TextStyle(
          color: AnalyseTokens.matteText,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        style: TextStyle(color: AnalyseTokens.matteText),
        cursorColor: AnalyseTokens.accentGreen,
        decoration: InputDecoration(
          hintText: l.analyseHintTfExamples,
          hintStyle: TextStyle(
            color: AnalyseTokens.muted2.withValues(alpha: 0.8),
          ),
          filled: true,
          fillColor: AnalyseTokens.fieldBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AnalyseTokens.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AnalyseTokens.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AnalyseTokens.accentGreen),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop<String?>(context),
          child: Text(l.cancel, style: TextStyle(color: AnalyseTokens.muted2)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          onPressed: () => Navigator.pop<String?>(context, _ctrl.text),
          child: Text(l.ok),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AnalyseTokens.matteText,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        if (selected)
          const Icon(Icons.check, color: AnalyseTokens.accentGreen, size: 18),
      ],
    );
  }
}

class _AddCircleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.add, size: 16, color: Color(0xFF8A8A8A)),
        ),
      ),
    );
  }
}



