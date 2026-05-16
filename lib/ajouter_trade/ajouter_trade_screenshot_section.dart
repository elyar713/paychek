import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';

/// Bloc **capture dâ€™Ã©cran** : ajout dâ€™une image (galerie / appareil) avant enregistrement.
class AjouterTradeScreenshotSection extends StatelessWidget {
  const AjouterTradeScreenshotSection({
    super.key,
    required this.file,
    required this.bytes,
    required this.labelStyle,
    required this.mutedStyle,
    required this.onPick,
    required this.onRemove,
    this.cardDecoration,
    this.sectionTitleColor,
  });

  final BoxDecoration? cardDecoration;
  final Color? sectionTitleColor;

  final XFile? file;
  final Uint8List? bytes;
  final TextStyle? labelStyle;
  final TextStyle? mutedStyle;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final headerStyle = (labelStyle ??
            const TextStyle(
              color: DashboardTokens.onMatteEmphasis,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.35,
            ))
        .copyWith(
          color: sectionTitleColor ?? DashboardTokens.titleGold,
          fontSize: 9,
          letterSpacing: 0.35,
        );

    return Container(
      padding: DashboardTokens.cardPadding,
      decoration: cardDecoration ?? DashboardTokens.cardBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.screenshot, style: headerStyle),
          const SizedBox(height: 8),
          Text(
            l.ajouterTradeScreenshotHelp,
            style: mutedStyle?.copyWith(fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 12),
          if (file == null && (bytes == null || bytes!.isEmpty))
            Material(
              color: DashboardTokens.scaffoldMatte,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 140,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DashboardTokens.cardBoxBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36,
                        color: DashboardTokens.muted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.ajouterTradeScreenshotTapToAdd,
                        textAlign: TextAlign.center,
                        style: mutedStyle?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: (bytes != null && bytes!.isNotEmpty)
                        ? Image.memory(
                            bytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : FutureBuilder<Uint8List>(
                            future: file!.readAsBytes(),
                            builder: (context, snap) {
                              if (snap.hasError) {
                                return ColoredBox(
                                  color: DashboardTokens.scaffoldMatte,
                                  child: Center(
                                    child: Text(
                                      l.ajouterTradeScreenshotLoadError,
                                      style: mutedStyle,
                                    ),
                                  ),
                                );
                              }
                              if (!snap.hasData) {
                                return ColoredBox(
                                  color: DashboardTokens.scaffoldMatte,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Image.memory(
                                snap.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, size: 18, color: Colors.white),
                      onPressed: onRemove,
                      tooltip: l.ajouterTradeScreenshotRemove,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  child: Material(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: onPick,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              size: 16,
                              color: DashboardTokens.onMatteEmphasis
                                  .withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l.ajouterTradeScreenshotChangeImage,
                              style: mutedStyle?.copyWith(
                                color: DashboardTokens.onMatteEmphasis
                                    .withValues(alpha: 0.95),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}



