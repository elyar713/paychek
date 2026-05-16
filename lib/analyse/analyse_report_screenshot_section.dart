import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import 'analyse_tokens.dart';

/// Zone sous le rapport pour attacher une capture (fichier image ou appareil photo sur mobile).
class AnalyseReportScreenshotSection extends StatefulWidget {
  const AnalyseReportScreenshotSection({
    super.key,
    required this.bytes,
    required this.onBytesChanged,
  });

  final Uint8List? bytes;
  final ValueChanged<Uint8List?> onBytesChanged;

  @override
  State<AnalyseReportScreenshotSection> createState() =>
      _AnalyseReportScreenshotSectionState();
}

class _AnalyseReportScreenshotSectionState
    extends State<AnalyseReportScreenshotSection> {
  static final ImagePicker _imagePicker = ImagePicker();

  bool get _cameraSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void _showError(Object e) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l = AppLocalizations.of(context)!;
    final msg = e is MissingPluginException
        ? l.analyseReportScreenshotErrorPlugin
        : l.analyseReportScreenshotErrorGeneric;
    messenger?.showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Galerie / explorateur : [file_picker] (Windows, macOS, Linux, Android, iOS, etc.).
  Future<void> _pickImageFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) return;
      final data = result.files.single.bytes;
      if (data == null || data.isEmpty) {
        _showError(StateError('empty_bytes'));
        return;
      }
      widget.onBytesChanged(data);
    } catch (e, st) {
      debugPrint('AnalyseReportScreenshotSection _pickImageFile: $e\n$st');
      _showError(e);
    }
  }

  /// Appareil photo : [image_picker] (surtout Android / iOS).
  Future<void> _pickFromCamera() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        imageQuality: 88,
      );
      if (!mounted || file == null) return;
      final data = await file.readAsBytes();
      if (!mounted) return;
      widget.onBytesChanged(data);
    } catch (e, st) {
      debugPrint('AnalyseReportScreenshotSection _pickFromCamera: $e\n$st');
      _showError(e);
    }
  }

  void _scheduleAfterSheet(Future<void> Function() pick) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      pick();
    });
  }

  void _openSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        final l = AppLocalizations.of(sheetCtx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  l.analyseReportScreenshotAddCapture,
                  style: AnalyseTokens.labelStyle.copyWith(fontSize: 13),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFFDFDFDF),
                ),
                title: Text(
                  l.analyseReportScreenshotChooseImage,
                  style: const TextStyle(
                    color: Color(0xFFDFDFDF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  kIsWeb ? l.analyseReportScreenshotSubtitleWeb : l.analyseReportScreenshotSubtitleFilePicker,
                  style: TextStyle(
                    color: AnalyseTokens.muted2,
                    fontSize: 11,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _scheduleAfterSheet(_pickImageFile);
                },
              ),
              if (_cameraSupported)
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera_outlined,
                    color: Color(0xFFDFDFDF),
                  ),
                  title: Text(
                    l.analyseReportScreenshotCamera,
                    style: const TextStyle(
                      color: Color(0xFFDFDFDF),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _scheduleAfterSheet(_pickFromCamera);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hint = _cameraSupported
        ? l.analyseReportScreenshotHintWithCamera
        : l.analyseReportScreenshotHintNoCamera;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyseTokens.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.analyseReportScreenshotSectionTitle,
            style: AnalyseTokens.sectionTitleStyle.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 12),
          if (widget.bytes != null)
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 280),
                    color: AnalyseTokens.fieldBg,
                    child: Image.memory(
                      widget.bytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => widget.onBytesChanged(null),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openSourcePicker,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AnalyseTokens.fieldBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: AnalyseTokens.muted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l.analyseReportScreenshotAddCapture,
                        style: TextStyle(
                          color: AnalyseTokens.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hint,
                        style: TextStyle(
                          color: AnalyseTokens.muted2,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
