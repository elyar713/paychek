import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../web/paychek_web_tokens.dart';
import 'help_center_guide_assets.dart';
import 'help_center_launch_links.dart';
import 'help_center_store_badge_bytes.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  /// Recherche côté UI (texte brut) — le filtre utilise [_filterLowerDebounced].
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _filterLowerDebounced = '';

  _HelpCenterVersion _version = _HelpCenterVersion.mobile;

  /// Textes longs (add trade, ma stratégie, performance) chargés depuis les assets par langue.
  Map<String, String>? _guideBundle;
  String? _guidesLoadLocale;

  static const double _kWebHelpMaxWidth = 480;

  /// Au-delà, on ne recherche pas dans le corps — [toLowerCase] sur des dizaines de ko figeait l’UI.
  static const int _maxBodyCharsForSearch = 8000;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_scheduleSearchDebounced);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    final localeName = l10n.localeName;

    /// Même locale : ne pas redémarrer un chargement si une requête est déjà en cours ([_guideBundle] encore null).
    if (_guidesLoadLocale == localeName && _guideBundle != null) return;
    if (_guidesLoadLocale == localeName && _guideBundle == null) return;

    _guidesLoadLocale = localeName;
    setState(() => _guideBundle = null);

    HelpCenterGuideAssets.loadBundle(localeName).then(
      (m) {
        if (!mounted) return;
        if (AppLocalizations.of(context)?.localeName != localeName) return;
        setState(() => _guideBundle = m);
      },
      onError: (Object _, StackTrace stackTrace) {
        if (!mounted) return;
        if (AppLocalizations.of(context)?.localeName != localeName) return;
        setState(() => _guideBundle = Map<String, String>.from(
              HelpCenterGuideAssets.emptyGuideBundle,
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _guideBundle == null ? <_HelpCenterItem>[] : _buildItems(l10n, _guideBundle!);
    final q = _filterLowerDebounced;
    final filtered = q.isEmpty
        ? items
        : items
            .where((e) => e.matchesSearch(q, _version, _maxBodyCharsForSearch))
            .toList(growable: false);

    final web = kIsWeb;
    final bg = web ? PaychekWebTokens.scaffoldBg : Colors.black;
    final hPad = web ? 24.0 : 16.0;
    final vPadTop = web ? 12.0 : 8.0;
    final canPop = Navigator.of(context).canPop();

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (canPop)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.of(context).maybePop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: web ? 26 : 22,
                  ),
                ),
              ),
            if (canPop) const SizedBox(width: 2),
            Expanded(
              child: Text(
                l10n.helpCenterTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: web ? 22 : 20,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: web ? 10 : 8),
        Text(
          l10n.helpCenterSubtitle,
          style: GoogleFonts.plusJakartaSans(
            color: web
                ? PaychekWebTokens.textGray500
                : DashboardTokens.labelGrey,
            height: 1.4,
            fontSize: web ? 14 : 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: web ? 20 : 14),
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
          child: _guideBundle == null
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
        child: web
            ? Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _kWebHelpMaxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, vPadTop, hPad, 20),
                    child: column,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.fromLTRB(hPad, vPadTop, hPad, 16),
                child: column,
              ),
      ),
    );
  }

  List<_HelpCenterItem> _buildItems(
    AppLocalizations l10n,
    Map<String, String> guides,
  ) {
    const addTradeImagesMobile = <String>[
      'assets/help_center/add_trade_mobile.png',
    ];
    const addTradeImagesWeb = <String>[
      'assets/help_center/add_trade_web.png',
    ];
    final addTrade = guides['addTrade']!;
    final myStrategy = guides['myStrategy']!;
    final performance = guides['performance']!;
    return [
      _HelpCenterItem(
        title: l10n.helpCenterArticleAddTradeTitle,
        mobileBody: addTrade,
        webBody: addTrade,
        mobileImages: addTradeImagesMobile,
        webImages: addTradeImagesWeb,
      ),
      _HelpCenterItem(
        title: l10n.helpCenterArticleEditTradeTitle,
        mobileBody: l10n.helpCenterArticleEditTradeBody,
        webBody: l10n.helpCenterArticleEditTradeBody,
      ),
      _HelpCenterItem(
        title: l10n.helpCenterArticleChecklistTitle,
        mobileBody: l10n.helpCenterArticleChecklistBody,
        webBody: l10n.helpCenterArticleChecklistBody,
      ),
      _HelpCenterItem(
        title: l10n.helpCenterArticleCalendarTitle,
        mobileBody: l10n.helpCenterArticleCalendarBody,
        webBody: l10n.helpCenterArticleCalendarBody,
      ),
      _HelpCenterItem(
        title: l10n.helpCenterArticleMentalStateTitle,
        mobileBody: l10n.helpCenterArticleMentalStateBody,
        webBody: l10n.helpCenterArticleMentalStateBody,
      ),
      _HelpCenterItem(
        title: l10n.helpCenterArticleMyStrategyTitle,
        mobileBody: myStrategy,
        webBody: myStrategy,
      ),
      _HelpCenterItem(
        title: l10n.helpCenterArticleMyAnalysisTitle,
        mobileBody: l10n.helpCenterArticleMyAnalysisBody,
        webBody: l10n.helpCenterArticleMyAnalysisBody,
      ),
      _HelpCenterItem(
        title: l10n.helpCenterArticlePerformanceTitle,
        mobileBody: performance,
        webBody: performance,
      ),
      _HelpCenterItem(
        title: l10n.helpCenterArticleExportPdfTitle,
        mobileBody: l10n.helpCenterArticleExportPdfBody,
        webBody: l10n.helpCenterArticleExportPdfBody,
      ),
      _HelpCenterItem(
        title: l10n.helpCenterArticleResetDataTitle,
        mobileBody: l10n.helpCenterArticleResetDataBody,
        webBody: l10n.helpCenterArticleResetDataBody,
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
          fontSize: 15, // +2 vs normal
          fontWeight: FontWeight.w800,
        );

    TextStyle titleStyle() => GoogleFonts.plusJakartaSans(
          color: DashboardTokens.onMatteEmphasis,
          height: 1.25,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        );

    final sectionHeader = RegExp(r'^\s*\d+\.\s+');
    final guideTitle = RegExp(r'^Guide\s*:', unicode: true);

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

/// Web : chemins servis comme dans [AjouterTradeCsvSection] (`assets/assets/...`).
/// Autres plateformes : [Image.asset].
List<String> _helpCenterImageWebUrls(String assetPath) {
  final b = Uri.base.replace(fragment: '', queryParameters: {});
  final out = <String>[];

  if (assetPath.startsWith('assets/')) {
    final rest = assetPath.substring('assets/'.length);
    out.add(b.resolve('assets/assets/$rest').toString());
    out.add(b.resolve(assetPath).toString());

    if (b.hasScheme && (b.scheme == 'http' || b.scheme == 'https')) {
      out.add(
        Uri(
          scheme: b.scheme,
          userInfo: b.userInfo.isEmpty ? null : b.userInfo,
          host: b.host.isEmpty ? null : b.host,
          port: b.hasPort ? b.port : null,
          path: '/assets/assets/$rest',
        ).toString(),
      );
      out.add(
        Uri(
          scheme: b.scheme,
          userInfo: b.userInfo.isEmpty ? null : b.userInfo,
          host: b.host.isEmpty ? null : b.host,
          port: b.hasPort ? b.port : null,
          path: '/$assetPath',
        ).toString(),
      );
    }
  } else {
    out.add(b.resolve(assetPath).toString());
  }

  final seen = <String>{};
  return out.where(seen.add).toList();
}

class _HelpCenterBodyImage extends StatelessWidget {
  const _HelpCenterBodyImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: kIsWeb
          ? _HelpCenterBodyImageWeb(urls: _helpCenterImageWebUrls(path))
          : Image.asset(
              path,
              fit: BoxFit.cover,
            ),
    );
  }
}

class _HelpCenterBodyImageWeb extends StatelessWidget {
  const _HelpCenterBodyImageWeb({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) => _frame(0);

  Widget _frame(int index) {
    if (index >= urls.length) {
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
    return Image.network(
      urls[index],
      fit: BoxFit.cover,
      gaplessPlayback: true,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (context, error, stackTrace) => _frame(index + 1),
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

  /// Badges « Get it on Google Play » / App Store — hauteur lisible sur mobile et web.
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

