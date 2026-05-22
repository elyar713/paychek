import 'performance_tokens.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'performance_widget_model.dart';
import 'performance_widget_storage.dart';

const Color _kGreen = PerformanceTokens.green;
const Color _kBorder = PerformanceTokens.borderSubtle;
const Color _kGrey = PerformanceTokens.labelFaint;

/// Personnalisation Performance — enregistre métrique + type de graphique (persistance locale).
class PerformanceWidgetCustomizationPage extends StatefulWidget {
  const PerformanceWidgetCustomizationPage({super.key});

  @override
  State<PerformanceWidgetCustomizationPage> createState() =>
      _PerformanceWidgetCustomizationPageState();
}

class _PerformanceWidgetCustomizationPageState
    extends State<PerformanceWidgetCustomizationPage> {
  static const _chartIcons = <IconData>[
    LucideIcons.barChart2,
    LucideIcons.pieChart,
    LucideIcons.trendingUp,
    LucideIcons.alignLeft,
  ];

  final _searchCtrl = TextEditingController();
  int _metricIndex = 0;
  int _chartIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final w = await PerformanceWidgetStorage.load();
    if (!mounted || w == null) return;
    setState(() {
      _metricIndex = w.metricIndex;
      _chartIndex = w.chartTypeIndex;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<int> _filteredIndices(List<PerformanceWidgetMetric> all) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      return List.generate(all.length, (i) => i);
    }
    final out = <int>[];
    for (var i = 0; i < all.length; i++) {
      final m = all[i];
      if (m.title.toLowerCase().contains(q) ||
          m.subtitle.toLowerCase().contains(q)) {
        out.add(i);
      }
    }
    return out;
  }

  Future<void> _saveAndPop() async {
    await PerformanceWidgetStorage.save(
      SavedPerformanceWidget(
        metricIndex: _metricIndex,
        chartTypeIndex: _chartIndex,
        savedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final all = PerformanceWidgetMetric.list(l);
    final filtered = _filteredIndices(all);

    return Scaffold(
      backgroundColor: DashboardTokens.scaffoldMatte,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _header(context),
                      const SizedBox(height: 4),
                      Text(
                        l.perfCustomizeIntro,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: DashboardTokens.muted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _sectionTitle(l.perfStep1Title),
                      _analysisBox(filtered, all, l),
                      const SizedBox(height: 24),
                      _sectionTitle(l.perfStep2Title),
                      _chartTypeBlock(l),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _bottomCta(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20, color: _kGrey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.perfNewWidgetTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 24, bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _kGrey,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _analysisBox(
    List<int> filtered,
    List<PerformanceWidgetMetric> all,
    AppLocalizations l,
  ) {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF050505),
              border: Border(
                bottom: BorderSide(color: PerformanceTokens.innerBg),
              ),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.white,
              ),
              cursorColor: _kGreen,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(40, 12, 12, 12),
                filled: true,
                fillColor: Colors.black,
                hintText: l.perfSearchHint,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: _kGrey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kGreen),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(LucideIcons.search, size: 16, color: _kGrey),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      l.perfNoResults,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: _kGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final idx = filtered[i];
                      final m = all[idx];
                      final selected = _metricIndex == idx;
                      final showBorder = i < filtered.length - 1;
                      return Material(
                        color: selected
                            ? const Color(0x0D1EB48A)
                            : Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _metricIndex = idx),
                          borderRadius: BorderRadius.circular(8),
                          hoverColor: Colors.white.withValues(alpha: 0.03),
                          splashColor: Colors.white.withValues(alpha: 0.05),
                          child: Container(
                            decoration: showBorder
                                ? const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: PerformanceTokens.innerBg,
                                      ),
                                    ),
                                  )
                                : null,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.title,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: selected
                                              ? _kGreen
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        m.subtitle,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          color: PerformanceTokens.labelDim,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _customRadio(selected),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _customRadio(bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? _kGreen : PerformanceTokens.labelFaint,
          width: 1.5,
        ),
      ),
      child: Center(
        child: AnimatedScale(
          scale: selected ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _kGreen,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chartTypeBlock(AppLocalizations l) {
    final n = PerformanceWidgetChartType.count;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(n, (i) {
          final selected = _chartIndex == i;
          return Material(
            color: selected ? const Color(0x0D1EB48A) : Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _chartIndex = i),
              child: Container(
                decoration: BoxDecoration(
                  border: i < n - 1
                      ? const Border(bottom: BorderSide(color: _kBorder))
                      : null,
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: selected
                                  ? _kGreen
                                  : PerformanceTokens.innerBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _chartIcons[i],
                              size: 16,
                              color: selected
                                  ? Colors.black
                                  : PerformanceTokens.labelMuted,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  PerformanceWidgetChartType.title(i, l),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  PerformanceWidgetChartType.hint(i, l),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: PerformanceTokens.labelDim,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _customRadio(selected),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _bottomCta(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black,
            Colors.black.withValues(alpha: 0.95),
            Colors.black.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.35, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saveAndPop,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.perfAddWidgetButton,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
