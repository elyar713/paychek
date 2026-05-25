import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../web/paychek_web_tokens.dart';
import '../widgets/paychek_page_header.dart';
import 'help_center_catalog.dart';
import 'help_center_embedded_images.dart';
import 'help_center_guide_assets.dart';
import 'help_center_launch_links.dart';
import 'help_center_store_badge_bytes.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key, this.onCloseInShell});

  /// Dashboard overlay : fermeture sans [Navigator.pop].
  final VoidCallback? onCloseInShell;

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _filterLowerDebounced = '';

  _HelpCenterVersion _version = _HelpCenterVersion.mobile;

  Map<String, String>? _guideBodies;
  bool _guidesLoading = false;

  static const double _kWebHelpMaxWidth = 480;

  /// Au-delà, on ne recherche pas dans le corps — [toLowerCase] sur des dizaines de ko figeait l’UI.
  static const int _maxBodyCharsForSearch = 8000;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_scheduleSearchDebounced);
    unawaited(_loadGuides());
  }

  Future<void> _loadGuides() async {
    if (_guidesLoading) return;
    _guidesLoading = true;
    if (_guideBodies == null && mounted) setState(() {});
    try {
      final bodies = await HelpCenterGuideAssets.loadBundle();
      if (!mounted) return;
      setState(() => _guideBodies = bodies);
    } finally {
      _guidesLoading = false;
    }
  }

  void _scheduleSearchDebounced() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() => _filterLowerDebounced =
          _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.removeListener(_scheduleSearchDebounced);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _guideBodies == null
        ? <_HelpCenterItem>[]
        : _buildItems(_guideBodies!);
    final q = _filterLowerDebounced;
    final filtered = q.isEmpty
        ? items
        : items
            .where((e) => e.matchesSearch(q, _version, _maxBodyCharsForSearch))
            .toList(growable: false);

    final web = kIsWeb;
    final bg = web ? PaychekWebTokens.scaffoldBg : Colors.black;
    final hPad = PaychekPageHeader.horizontalPad(
      MediaQuery.sizeOf(context).width,
    );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: web ? 4 : 0),
        _VersionToggle(
          mobileLabel: l10n.helpCenterVersionMobile,
          webLabel: l10n.helpCenterVersionWeb,
          value: _version,
          onChanged: (v) => setState(() => _version = v),
        ),
        SizedBox(height: web ? 14 : 10),
        TextField(
          controller: _searchCtrl,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: web ? 15 : 14,
          ),
          cursorColor: web ? PaychekWebTokens.accentEmerald : DashboardTokens.accent,
          decoration: InputDecoration(
            hintText: l10n.helpCenterSearchHint,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: web
                  ? PaychekWebTokens.textGray600
                  : DashboardTokens.labelGrey,
              fontSize: web ? 14 : 13,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: web
                  ? PaychekWebTokens.textGray500
                  : DashboardTokens.labelGrey,
            ),
            filled: true,
            fillColor:
                web ? PaychekWebTokens.cardBg : const Color(0xFF0E0E10),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                web ? PaychekWebTokens.radiusButton : 14,
              ),
              borderSide: BorderSide(
                color: web
                    ? PaychekWebTokens.borderGray800
                    : const Color(0xFF1A1A1A).withValues(alpha: 0.85),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                web ? PaychekWebTokens.radiusButton : 14,
              ),
              borderSide: BorderSide(
                color: web
                    ? PaychekWebTokens.borderGray800
                    : const Color(0xFF1A1A1A).withValues(alpha: 0.85),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                web ? PaychekWebTokens.radiusButton : 14,
              ),
              borderSide: BorderSide(
                color: web
                    ? PaychekWebTokens.accentEmerald.withValues(alpha: 0.85)
                    : DashboardTokens.accent.withValues(alpha: 0.75),
                width: 1.2,
              ),
            ),
          ),
        ),
        SizedBox(height: web ? 16 : 10),
        Expanded(
          child: _guideBodies == null
              ? Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: web
                          ? PaychekWebTokens.accentEmerald
                          : DashboardTokens.accent,
                    ),
                  ),
                )
              : filtered.isEmpty
                  ? Center(
                      child: Text(
                        l10n.helpCenterEmptyResults,
                        style: GoogleFonts.plusJakartaSans(
                          color: web
                              ? PaychekWebTokens.textGray500
                              : DashboardTokens.labelGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: web ? 10 : 8),
                      itemBuilder: (context, i) {
                        final item = filtered[i];
                        return _HelpCenterCard(
                          title: item.title,
                          body: item.bodyFor(_version),
                          images: item.imagesFor(_version),
                        );
                      },
                    ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaychekPageHeader(
              onBack: PaychekPageHeader.resolveBack(
                context,
                onCloseInShell: widget.onCloseInShell,
              ),
              title: l10n.helpCenterTitle,
              subtitle: l10n.helpCenterSubtitle,
              maxContentWidth: _kWebHelpMaxWidth,
            ),
            Expanded(
              child: web
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _kWebHelpMaxWidth,
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 20),
                          child: column,
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
                      child: column,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<_HelpCenterItem> _buildItems(Map<String, String> bodies) {
    return [
      for (final def in helpCenterArticles)
        _HelpCenterItem(
          title: def.frenchTitle,
          mobileBody: bodies[def.slug] ?? '',
          webBody: bodies[def.slug] ?? '',
          mobileImages: def.mobileHeroImages,
          webImages: def.webHeroImages,
        ),
    ];
  }
}

enum _HelpCenterVersion { mobile, web }

class _HelpCenterItem {
  const _HelpCenterItem({
    required this.title,
    required this.mobileBody,
    required this.webBody,
    this.mobileImages = const <String>[],
    this.webImages = const <String>[],
  });
  final String title;
  final String mobileBody;
  final String webBody;
  final List<String> mobileImages;
  final List<String> webImages;

  String bodyFor(_HelpCenterVersion v) =>
      v == _HelpCenterVersion.mobile ? mobileBody : webBody;

  List<String> imagesFor(_HelpCenterVersion v) {
    return v == _HelpCenterVersion.mobile ? mobileImages : webImages;
  }

  bool matchesSearch(
    String qLower,
    _HelpCenterVersion v,
    int maxBodyCharsForSearch,
  ) {
    if (title.toLowerCase().contains(qLower)) return true;
    final body = bodyFor(v);
    if (body.isEmpty) return false;
    if (body.length > maxBodyCharsForSearch) return false;
    return body.toLowerCase().contains(qLower);
  }
}

class _HelpCenterCard extends StatelessWidget {
  const _HelpCenterCard({
    required this.title,
    required this.body,
    this.images = const <String>[],
  });

  final String title;
  final String body;
  final List<String> images;

  List<Widget> _buildBodyWithInlineImages(BuildContext context) {
    final out = <Widget>[];
    final lines = body.split('\n');
    var isFirstNonEmptyLine = true;

    TextStyle normalStyle() => GoogleFonts.plusJakartaSans(
          color: DashboardTokens.labelGrey,
          height: 1.35,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        );

    TextStyle bulletStyle() => GoogleFonts.plusJakartaSans(
          color: DashboardTokens.onMatteEmphasis.withValues(alpha: 0.92),
          height: 1.38,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        );

    TextStyle sectionStyle() => GoogleFonts.plusJakartaSans(
          color: DashboardTokens.onMatteEmphasis,
          height: 1.35,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        );

    TextStyle titleStyle() => GoogleFonts.plusJakartaSans(
          color: DashboardTokens.onMatteEmphasis,
          height: 1.25,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        );

    TextStyle labeledHeadingStyle() => GoogleFonts.plusJakartaSans(
          color: Colors.white,
          height: 1.35,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        );

    final sectionHeader = RegExp(r'^\s*\d+\.\s+');
    final guideTitle = RegExp(r'^Guide\s*:', unicode: true);
    final labeledParagraph = RegExp(r'^([^:\[\]]+) : (.+)$');

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        out.add(const SizedBox(height: 10));
        continue;
      }

      final isImageLine = trimmed.startsWith('[img:') && trimmed.endsWith(']');
      if (isImageLine) {
        final path = trimmed.substring(5, trimmed.length - 1).trim();
        if (path.isNotEmpty) {
          out.add(const SizedBox(height: 6));
          out.add(_HelpCenterBodyImage(path: path));
          out.add(const SizedBox(height: 10));
        }
        continue;
      }

      final isTitle = isFirstNonEmptyLine || guideTitle.hasMatch(trimmed);
      final isSection = !isTitle && sectionHeader.hasMatch(trimmed);
      final isBullet = !isTitle && !isSection && trimmed.startsWith('- ');
      final labelMatch = !isTitle &&
              !isSection &&
              !isBullet &&
              !isImageLine
          ? labeledParagraph.firstMatch(trimmed)
          : null;

      if (labelMatch != null) {
        if (isFirstNonEmptyLine) isFirstNonEmptyLine = false;
        out.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: normalStyle(),
                  children: [
                    TextSpan(
                      text: '${labelMatch.group(1)!} : ',
                      style: labeledHeadingStyle(),
                    ),
                    TextSpan(text: labelMatch.group(2)!),
                  ],
                ),
              ),
            ),
          ),
        );
        continue;
      }

      final style = isTitle
          ? titleStyle()
          : (isSection
              ? sectionStyle()
              : (isBullet ? bulletStyle() : normalStyle()));
      if (isFirstNonEmptyLine) isFirstNonEmptyLine = false;

      if (isSection) {
        out.add(const SizedBox(height: 6));
      }

      out.add(
        Padding(
          padding: EdgeInsets.only(
            left: isTitle ? 8 : (isBullet ? 10 : 0),
            bottom: isTitle ? 12 : 4,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              trimmed,
              style: style,
              textAlign: TextAlign.left,
            ),
          ),
        ),
      );
    }

    while (out.isNotEmpty && out.last is SizedBox) {
      out.removeLast();
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final web = kIsWeb;
    final cardBg = web ? PaychekWebTokens.cardBg : const Color(0xFF0E0E10);
    final cardBorder =
        web ? PaychekWebTokens.borderGray800 : const Color(0xFF1A1A1A);
    final chevronOpen =
        web ? PaychekWebTokens.accentEmerald : DashboardTokens.accent;
    final chevronClosed =
        web ? PaychekWebTokens.textGray500 : DashboardTokens.labelGrey;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(
          web ? PaychekWebTokens.radiusCard : 16,
        ),
        border: Border.all(color: cardBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.white.withValues(alpha: 0.06),
          highlightColor: Colors.white.withValues(alpha: 0.04),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.fromLTRB(web ? 16 : 12, web ? 14 : 6,
              web ? 12 : 12, web ? 14 : 6),
          childrenPadding: EdgeInsets.fromLTRB(
              web ? 16 : 12, 0, web ? 16 : 12, web ? 16 : 12),
          collapsedShape: const RoundedRectangleBorder(),
          shape: const RoundedRectangleBorder(),
          iconColor: chevronOpen,
          collapsedIconColor: chevronClosed,
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: DashboardTokens.onMatteEmphasis,
              fontSize: web ? 15 : 15,
            ),
          ),
          children: [
            if (images.isNotEmpty) ...[
              const SizedBox(height: 6),
              for (final path in images) ...[
                _HelpCenterBodyImage(path: path),
                const SizedBox(height: 10),
              ],
            ],
            ..._buildBodyWithInlineImages(context),
          ],
        ),
      ),
    );
  }
}

class _HelpCenterBodyImage extends StatelessWidget {
  const _HelpCenterBodyImage({required this.path});

  final String path;

  static Future<ByteData?> _loadBytes(String path) async {
    final embedded = helpCenterEmbeddedImageBytes(path);
    if (embedded != null && embedded.isNotEmpty) {
      return ByteData.sublistView(embedded);
    }
    try {
      return await rootBundle.load(path);
    } catch (_) {}
    if (path.endsWith('.gif')) {
      try {
        return await rootBundle.load('${path.substring(0, path.length - 4)}.png');
      } catch (_) {}
    }
    return null;
  }

  static Widget _brokenPlaceholder() {
    return const AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: Color(0xFF1A1A1A),
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF666666),
            size: 40,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FutureBuilder<ByteData?>(
        future: _loadBytes(path),
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes != null) {
            return Image.memory(
              bytes.buffer.asUint8List(),
              fit: BoxFit.contain,
              width: double.infinity,
              gaplessPlayback: true,
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: Color(0xFF1A1A1A),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            );
          }
          return _brokenPlaceholder();
        },
      ),
    );
  }
}

class _VersionToggle extends StatelessWidget {
  const _VersionToggle({
    required this.mobileLabel,
    required this.webLabel,
    required this.value,
    required this.onChanged,
  });

  final String mobileLabel;
  final String webLabel;
  final _HelpCenterVersion value;
  final ValueChanged<_HelpCenterVersion> onChanged;

  @override
  Widget build(BuildContext context) {
    final isMobile = value == _HelpCenterVersion.mobile;
    final web = kIsWeb;
    final track = web ? PaychekWebTokens.pillTrackBg : const Color(0xFF0E0E10);
    final border =
        web ? PaychekWebTokens.borderGray800 : const Color(0xFF1A1A1A);
    final selectedBg =
        web ? PaychekWebTokens.accentEmerald : DashboardTokens.accent;
    final selectedFg = Colors.black87;
    final unselectedFg = web
        ? PaychekWebTokens.textGray500
        : DashboardTokens.onMatteEmphasis;
    const radius = BorderRadius.all(Radius.circular(999));
    final segHeight = web ? 44.0 : 40.0;
    final fontSize = web ? 13.0 : 12.0;

    Widget segment({
      required bool selected,
      required String label,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              height: segHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? selectedBg : Colors.transparent,
                borderRadius: radius,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: fontSize,
                  color: selected ? selectedFg : unselectedFg,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final linkColor =
        web ? PaychekWebTokens.accentEmerald : DashboardTokens.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: track,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              segment(
                selected: isMobile,
                label: mobileLabel,
                onTap: () => onChanged(_HelpCenterVersion.mobile),
              ),
              segment(
                selected: !isMobile,
                label: webLabel,
                onTap: () => onChanged(_HelpCenterVersion.web),
              ),
            ],
          ),
        ),
        if (isMobile) ...[
          SizedBox(height: web ? 10 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _StoreBadgeButton(
                  web: web,
                  imageBytes: HelpCenterStoreBadgeBytes.googlePlayPng,
                  semanticLabel: 'Google Play',
                  onTap: () => HelpCenterLaunchLinks.open(
                    Uri.parse(HelpCenterLaunchLinks.playStoreListing),
                  ),
                ),
              ),
              SizedBox(width: web ? 16 : 12),
              Flexible(
                child: _StoreBadgeButton(
                  web: web,
                  imageBytes: HelpCenterStoreBadgeBytes.appStorePng,
                  semanticLabel: 'App Store',
                  onTap: () => HelpCenterLaunchLinks.open(
                    Uri.parse(HelpCenterLaunchLinks.appStoreListing),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          SizedBox(height: web ? 10 : 8),
          Center(
            child: InkWell(
              onTap: () => HelpCenterLaunchLinks.open(
                Uri.parse(HelpCenterLaunchLinks.webAppCanonical),
              ),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Text(
                  HelpCenterLaunchLinks.webAppCanonical,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: web ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    color: linkColor,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StoreBadgeButton extends StatelessWidget {
  const _StoreBadgeButton({
    required this.web,
    required this.imageBytes,
    required this.semanticLabel,
    required this.onTap,
  });

  final bool web;
  final Uint8List imageBytes;
  final String semanticLabel;
  final VoidCallback onTap;

  static double badgeHeight(bool web) => web ? 62 : 54;

  @override
  Widget build(BuildContext context) {
    final splash = web
        ? PaychekWebTokens.accentEmerald.withAlpha(40)
        : DashboardTokens.accent.withAlpha(40);
    final h = badgeHeight(web);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: splash,
          hoverColor: splash,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: web ? 4 : 3, horizontal: 4),
            child: Image.memory(
              imageBytes,
              height: h,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
