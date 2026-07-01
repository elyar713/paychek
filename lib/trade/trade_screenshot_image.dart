import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'trade_models.dart';
import 'trade_screenshot_storage.dart';
import 'trade_tokens.dart';
import 'trade_screenshot_native_file.dart'
    if (dart.library.html) 'trade_screenshot_native_file_stub.dart';

/// Affiche la capture d’un trade (mémoire, Firebase Storage, fichier natif).
class TradeScreenshotImage extends StatefulWidget {
  const TradeScreenshotImage({
    super.key,
    required this.item,
    this.borderRadius = 12,
    this.aspectRatio = 16 / 9,
  });

  final TradeListItem item;
  final double borderRadius;
  final double aspectRatio;

  @override
  State<TradeScreenshotImage> createState() => _TradeScreenshotImageState();
}

class _TradeScreenshotImageState extends State<TradeScreenshotImage> {
  Uint8List? _prefsBytes;
  bool _fileFailed = false;

  TradeListItem get item => widget.item;

  bool get _hasBytes =>
      item.screenshotBytes != null && item.screenshotBytes!.isNotEmpty;

  bool get _hasPath =>
      item.screenshotPath != null && item.screenshotPath!.trim().isNotEmpty;

  bool get _hasStoragePath =>
      item.screenshotStoragePath != null &&
      item.screenshotStoragePath!.trim().isNotEmpty;

  Uint8List? get _effectiveBytes =>
      _hasBytes ? item.screenshotBytes : _prefsBytes;

  @override
  void initState() {
    super.initState();
    _loadPrefsBytes();
  }

  @override
  void didUpdateWidget(covariant TradeScreenshotImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != item.id ||
        oldWidget.item.screenshotBytes != item.screenshotBytes ||
        oldWidget.item.screenshotStoragePath != item.screenshotStoragePath) {
      _fileFailed = false;
      _prefsBytes = null;
      _loadPrefsBytes();
    }
  }

  Future<void> _loadPrefsBytes() async {
    if (_hasBytes) return;
    final bytes = await TradeScreenshotLocalPrefs.load(item.id);
    if (!mounted) return;
    if (bytes != null && bytes.isNotEmpty) {
      setState(() => _prefsBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVisibleSource = (_effectiveBytes != null &&
            _effectiveBytes!.isNotEmpty) ||
        _hasStoragePath ||
        (!kIsWeb && _hasPath && !_fileFailed);
    if (!hasVisibleSource) return const SizedBox.shrink();

    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;

    final Widget child;
    final bytes = _effectiveBytes;
    if (bytes != null && bytes.isNotEmpty) {
      child = Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (_hasStoragePath) {
      child = _storageImage(l, t);
    } else if (!kIsWeb && _hasPath && !_fileFailed) {
      child = tradeScreenshotNativeFileImage(
        path: item.screenshotPath!,
        onError: () {
          if (!mounted) return;
          setState(() => _fileFailed = true);
        },
        errorWidget: _errorBox(l.tradeScreenshotLoadError, t),
      );
    } else {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AspectRatio(aspectRatio: widget.aspectRatio, child: child),
    );
  }

  Widget _storageImage(AppLocalizations l, TextTheme? t) {
    return FutureBuilder<String>(
      key: ValueKey<String>(item.screenshotStoragePath!),
      future: TradeScreenshotCloud.downloadUrl(item.screenshotStoragePath!),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snap.hasError || !snap.hasData) {
          return _errorBox(l.tradeScreenshotUnavailableWeb, t);
        }
        return Image.network(
          snap.data!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stack) =>
              _errorBox(l.tradeScreenshotUnavailableWeb, t),
        );
      },
    );
  }

  Widget _errorBox(String message, TextTheme? t) {
    return ColoredBox(
      color: TradeTokens.pillInactiveBg,
      child: Center(
        child: Text(
          message,
          style: t?.bodySmall?.copyWith(
            color: TradeTokens.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
