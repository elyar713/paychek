// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

extension _AjouterTradePageStatePsych on _AjouterTradePageState {
  Future<void> _pickTradeScreenshot() async {
    if (kIsWeb) {
      try {
        final picked = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );
        if (!mounted || picked == null || picked.files.isEmpty) return;
        final f = picked.files.first;
        final bytes = f.bytes;
        if (bytes == null || bytes.isEmpty) return;
        setState(() {
          _tradeScreenshotBytes = bytes;
          _tradeScreenshot = null;
        });
      } catch (_) {}
      return;
    }
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: DashboardTokens.cardBoxBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: DashboardTokens.onMatteEmphasis,
                    ),
                    tooltip: AppLocalizations.of(
                      ctx,
                    )!.ajouterTradeImagePickerClose,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(ctx)!.ajouterTradeImagePickerTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: DashboardTokens.onMatteEmphasis,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: DashboardTokens.cardBoxBorder,
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: DashboardTokens.onMatteEmphasis,
              ),
              title: Text(
                AppLocalizations.of(ctx)!.ajouterTradeGallery,
                style: const TextStyle(color: DashboardTokens.onMatteEmphasis),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: DashboardTokens.onMatteEmphasis,
              ),
              title: Text(
                AppLocalizations.of(ctx)!.ajouterTradeCamera,
                style: const TextStyle(color: DashboardTokens.onMatteEmphasis),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || source == null) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (!mounted || image == null) return;
    setState(() => _tradeScreenshot = image);
  }

  void _commitNewPsychTag() {
    final t = _psychTagNewController.text.trim();
    if (t.isEmpty) {
      setState(() => _psychTagInputVisible = false);
      return;
    }
    setState(() {
      if (!_psychTagLabels.contains(t)) {
        _psychTagLabels = List<String>.from(_psychTagLabels)..add(t);
      }
      _psychTagNewController.clear();
      _psychTagInputVisible = false;
    });
  }
}