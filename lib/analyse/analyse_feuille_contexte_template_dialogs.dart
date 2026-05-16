import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_tokens.dart';

/// Dialogue Â« nom du modÃ¨le Â» : le [TextEditingController] est possÃ©dÃ© par ce [State].
class SaveFeuilleContexteTemplateNameDialog extends StatefulWidget {
  const SaveFeuilleContexteTemplateNameDialog({super.key});

  @override
  State<SaveFeuilleContexteTemplateNameDialog> createState() =>
      _SaveFeuilleContexteTemplateNameDialogState();
}

class _SaveFeuilleContexteTemplateNameDialogState
    extends State<SaveFeuilleContexteTemplateNameDialog> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _textCtrl.text.trim();
    if (t.isEmpty) return;
    Navigator.pop(context, t);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      title: Text(
        l.analyseTemplateSaveDialogTitle,
        style: AnalyseTokens.labelStyle.copyWith(
          color: AnalyseTokens.matteText,
          fontSize: 15,
        ),
      ),
      content: TextField(
        controller: _textCtrl,
        autofocus: true,
        style: const TextStyle(color: Color(0xFFDFDFDF)),
        decoration: InputDecoration(
          hintText: l.analyseTemplateStyleHint,
          hintStyle: TextStyle(color: AnalyseTokens.muted2),
          filled: true,
          fillColor: AnalyseTokens.fieldBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AnalyseTokens.accentGreen.withValues(alpha: 0.7),
            ),
          ),
        ),
        onSubmitted: (s) {
          final t = s.trim();
          if (t.isNotEmpty) Navigator.pop(context, t);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l.cancel,
            style: TextStyle(color: AnalyseTokens.muted2),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AnalyseTokens.accentGreen,
            foregroundColor: Colors.black,
          ),
          onPressed: _submit,
          child: Text(l.save),
        ),
      ],
    );
  }
}

class RenameFeuilleContexteTemplateDialog extends StatefulWidget {
  const RenameFeuilleContexteTemplateDialog({
    super.key,
    required this.initialName,
  });

  final String initialName;

  @override
  State<RenameFeuilleContexteTemplateDialog> createState() =>
      _RenameFeuilleContexteTemplateDialogState();
}

class _RenameFeuilleContexteTemplateDialogState
    extends State<RenameFeuilleContexteTemplateDialog> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _textCtrl.text.trim();
    if (t.isEmpty) return;
    Navigator.pop(context, t);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      title: Text(
        l.analyseTemplateRenameDialogTitle,
        style: AnalyseTokens.labelStyle.copyWith(
          color: AnalyseTokens.matteText,
          fontSize: 15,
        ),
      ),
      content: TextField(
        controller: _textCtrl,
        autofocus: true,
        style: const TextStyle(color: Color(0xFFDFDFDF)),
        decoration: InputDecoration(
          hintText: l.analyseTemplateNameHint,
          hintStyle: TextStyle(color: AnalyseTokens.muted2),
          filled: true,
          fillColor: AnalyseTokens.fieldBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AnalyseTokens.accentGreen.withValues(alpha: 0.7),
            ),
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l.cancel,
            style: TextStyle(color: AnalyseTokens.muted2),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AnalyseTokens.accentGreen,
            foregroundColor: Colors.black,
          ),
          onPressed: _submit,
          child: Text(l.save),
        ),
      ],
    );
  }
}



