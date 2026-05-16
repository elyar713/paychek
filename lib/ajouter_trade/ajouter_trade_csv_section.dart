import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';

class CsvSoftwareOption {
  const CsvSoftwareOption({
    required this.label,
    required this.assetPath,
  });

  final String label;
  final String assetPath;
}

/// Texte d’aide (gris) sous le sélecteur quand un logiciel est choisi — clef = [CsvSoftwareOption.label].
const kCsvSoftwareImportGuidance = <String, String>{
  'MT4': 'Terminal -> Account History -> Save as Detailed report',
  'MT5': 'Toolbox -> History -> Report -> Open XML or HTML',
  'TradingView': 'Trading panel (bottom) -> Export date -> Order history',
  'Tradovate': 'Icone (+) -> Report -> Date -> Go -> Download',
  'cTrader': 'Trading panel -> History -> Create a statement',
  'NinjaTrader': 'Control Center -> New -> Account Date -> Export',
  'Quantower':
      'Panel Activity -> Portfolio -> Trade -> ☰ top-left -> Export date -> Export file',
  'Rithmic': 'Order history -> Export as CSV',
};

/// Les **9 logiciels** proposés pour l’import CSV (alignés sur [AjouterTradeCsvSection]
/// / sélecteur « Ajouter un trade » — à garder identiques aux libellés [CsvSoftwareOption.label]).
const kPaychekCsvSoftwareLabelsOrdered = <String>[
  'MT4',
  'MT5',
  'TradingView',
  'Tradovate',
  'cTrader',
  'NinjaTrader',
  'Quantower',
  'ATAS',
  'Rithmic',
];

class AjouterTradeCsvSection extends StatelessWidget {
  const AjouterTradeCsvSection({
    super.key,
    required this.labelStyle,
    required this.mutedStyle,
    required this.selectedSource,
    required this.options,
    required this.onSourceChanged,
    required this.onImportTap,
    this.importedFileName,
    this.cardDecoration,
    this.sectionTitleColor,
  });

  final TextStyle? labelStyle;
  final TextStyle? mutedStyle;
  final String? selectedSource;
  final List<CsvSoftwareOption> options;
  final ValueChanged<String?> onSourceChanged;
  final VoidCallback onImportTap;
  final String? importedFileName;
  final BoxDecoration? cardDecoration;
  final Color? sectionTitleColor;

  @override
  Widget build(BuildContext context) {
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
          Text('CSV', style: headerStyle),
          const SizedBox(height: 10),
          _CsvSoftwarePickerField(
            selectedSource: selectedSource,
            options: options,
            mutedStyle: mutedStyle,
            onSourceChanged: onSourceChanged,
          ),
          if (selectedSource != null &&
              (selectedSource == 'ATAS' ||
                  (kCsvSoftwareImportGuidance[selectedSource]?.trim().isNotEmpty ??
                      false))) ...[
            const SizedBox(height: 8),
            if (selectedSource == 'ATAS')
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: DashboardTokens.labelGrey,
                    fontSize: 11,
                    height: 1.35,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'Table → Trading Journal → Journal → ',
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.settings_outlined,
                        size: 14,
                        color: DashboardTokens.labelGrey,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' top-right corner → Export Statistics · Journal sheet (.xlsx or CSV)',
                    ),
                  ],
                ),
              )
            else
              Text(
                kCsvSoftwareImportGuidance[selectedSource]!.trim(),
                style: const TextStyle(
                  color: DashboardTokens.labelGrey,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onImportTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: DashboardTokens.onMatteEmphasis,
              side: const BorderSide(color: DashboardTokens.cardBoxBorder),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.file_upload_outlined, size: 18),
            label: const Text(
              'IMPORT CSV',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          if (importedFileName != null && importedFileName!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              importedFileName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: mutedStyle?.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _CsvSoftwarePickerField extends StatelessWidget {
  const _CsvSoftwarePickerField({
    required this.selectedSource,
    required this.options,
    required this.mutedStyle,
    required this.onSourceChanged,
  });

  final String? selectedSource;
  final List<CsvSoftwareOption> options;
  final TextStyle? mutedStyle;
  final ValueChanged<String?> onSourceChanged;

  @override
  Widget build(BuildContext context) {
    final fieldKey = GlobalKey();
    CsvSoftwareOption? selectedOption;
    for (final option in options) {
      if (option.label == selectedSource) {
        selectedOption = option;
        break;
      }
    }

    Future<void> openMenu() async {
      final fieldContext = fieldKey.currentContext;
      final renderObject = fieldContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        return;
      }
      final overlayState = Overlay.of(context);
      final overlay = overlayState.context.findRenderObject();
      if (overlay is! RenderBox) {
        return;
      }
      final topLeft =
          renderObject.localToGlobal(Offset.zero, ancestor: overlay);
      final bottomRight = renderObject.localToGlobal(
        renderObject.size.bottomRight(Offset.zero),
        ancestor: overlay,
      );

      final fieldWidth = renderObject.size.width;
      final spaceBelow = overlay.size.height - bottomRight.dy - 8;
      final maxMenuHeight = math.min(280.0, math.max(120.0, spaceBelow));

      final selected = await showMenu<String>(
        context: context,
        color: DashboardTokens.cardBoxBg,
        position: RelativeRect.fromLTRB(
          topLeft.dx,
          bottomRight.dy + 4,
          overlay.size.width - bottomRight.dx,
          0,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        elevation: 12,
        shadowColor: Colors.black54,
        constraints: BoxConstraints(
          minWidth: fieldWidth,
          maxWidth: fieldWidth,
          maxHeight: maxMenuHeight,
        ),
        menuPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        items: [
          for (final option in options)
            PopupMenuItem<String>(
              value: option.label,
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Row(
                children: [
                  _CsvSoftwareLogo(
                    key: ValueKey(option.assetPath),
                    label: option.label,
                    assetPath: option.assetPath,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      option.label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DashboardTokens.onMatteEmphasis,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
      if (selected != null) {
        onSourceChanged(selected);
      }
    }

    return InkWell(
      key: fieldKey,
      onTap: openMenu,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: DashboardTokens.scaffoldMatte,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DashboardTokens.cardBoxBorder),
        ),
        child: Row(
          children: [
            if (selectedOption != null) ...[
              _CsvSoftwareLogo(
                key: ValueKey(selectedOption.assetPath),
                label: selectedOption.label,
                assetPath: selectedOption.assetPath,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedOption.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardTokens.onMatteEmphasis,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.ajouterTradeCsvChooseSoftware,
                  overflow: TextOverflow.ellipsis,
                  style: mutedStyle?.copyWith(fontSize: 12),
                ),
              ),
            ],
            const SizedBox(width: 8),
            const Icon(
              Icons.expand_more,
              size: 18,
              color: DashboardTokens.labelGrey,
            ),
          ],
        ),
      ),
    );
  }
}

const double _csvLogoBox = 26;

/// URLs à essayer sur le web (même origine) : PNG servis par le build (`build/web/assets/assets/...`),
/// puis copies statiques `web/csv_logos/`.
List<String> _csvSoftwareLogoWebUrls(String assetPath) {
  final basename = assetPath.split(RegExp(r'[/\\]')).last;
  final b = Uri.base.replace(fragment: '', queryParameters: {});
  final out = <String>[];

  if (assetPath.startsWith('assets/')) {
    final rest = assetPath.substring('assets/'.length);
    out.add(b.resolve('assets/assets/$rest').toString());
  }

  out.add(b.resolve('csv_logos/$basename').toString());

  if (b.hasScheme && (b.scheme == 'http' || b.scheme == 'https')) {
    if (assetPath.startsWith('assets/')) {
      final rest = assetPath.substring('assets/'.length);
      out.add(
        Uri(
          scheme: b.scheme,
          userInfo: b.userInfo.isEmpty ? null : b.userInfo,
          host: b.host.isEmpty ? null : b.host,
          port: b.hasPort ? b.port : null,
          path: '/assets/assets/$rest',
        ).toString(),
      );
    }
    out.add(
      Uri(
        scheme: b.scheme,
        userInfo: b.userInfo.isEmpty ? null : b.userInfo,
        host: b.host.isEmpty ? null : b.host,
        port: b.hasPort ? b.port : null,
        path: '/csv_logos/$basename',
      ).toString(),
    );
  }

  final seen = <String>{};
  return out.where(seen.add).toList();
}

Widget _csvLogoInitials(String label, {double fontSize = 10}) {
  final initials = label.trim().isEmpty
      ? '?'
      : (label.length >= 2 ? label.substring(0, 2) : label);
  return Center(
    child: Text(
      initials.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: TextStyle(
        color: Colors.black87,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    ),
  );
}

Widget _csvLogoNetworkChain(String label, List<String> urls, int index) {
  if (index >= urls.length) {
    return _csvLogoInitials(label, fontSize: 11);
  }
  return Image.network(
    urls[index],
    fit: BoxFit.contain,
    width: _csvLogoBox,
    height: _csvLogoBox,
    gaplessPlayback: true,
    excludeFromSemantics: true,
    filterQuality: FilterQuality.medium,
    // Même origine : CanvasKit peut quand même échouer à afficher le PNG ; `<img>` natif fonctionne
    // (l’URL s’ouvre bien dans Chrome, cf. vos tests).
    webHtmlElementStrategy: kIsWeb
        ? WebHtmlElementStrategy.prefer
        : WebHtmlElementStrategy.never,
    errorBuilder: (context, error, stackTrace) =>
        _csvLogoNetworkChain(label, urls, index + 1),
  );
}

Widget _csvLogoSlot(Widget inner) {
  return SizedBox(
    width: 30,
    height: 30,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardTokens.cardBoxBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: inner,
      ),
    ),
  );
}

/// Web : `Image.network` vers les PNG servis par le site (`/assets/assets/...` puis `/csv_logos/...`).
/// Autres plateformes : [Image.asset].
class _CsvSoftwareLogo extends StatelessWidget {
  const _CsvSoftwareLogo({
    super.key,
    required this.label,
    required this.assetPath,
  });

  final String label;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return _csvLogoSlot(
        Image.asset(
          assetPath,
          bundle: rootBundle,
          fit: BoxFit.contain,
          width: _csvLogoBox,
          height: _csvLogoBox,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stackTrace) =>
              _csvLogoInitials(label, fontSize: 11),
        ),
      );
    }
    return _csvLogoSlot(
      _csvLogoNetworkChain(label, _csvSoftwareLogoWebUrls(assetPath), 0),
    );
  }
}
