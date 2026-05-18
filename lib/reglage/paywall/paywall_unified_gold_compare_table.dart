import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../paywall_compare_rows.dart';
import 'mobile/paywall_mobile_tokens.dart';

/// Tableau Lite / Pro unifié (2 colonnes, style or compact — landing web & paywall web).
class PaywallUnifiedGoldCompareTable extends StatelessWidget {
  const PaywallUnifiedGoldCompareTable({
    super.key,
    required this.rows,
    this.compact = false,
    this.liteFooter,
    this.proFooter,
  });

  final List<PaywallCompareRow> rows;
  final bool compact;
  final Widget? liteFooter;
  final Widget? proFooter;

  static const _rowSpecs = [
    ('trades', 'rowTrades', 'liteTrades', 'proTrades'),
    ('entry', 'rowEntry', 'liteEntry', 'proEntry'),
    ('calendar', 'rowCalendar', 'liteCalendar', 'proCalendar'),
    ('checklist', 'rowChecklist', 'liteAbsent', 'proChecklist'),
    ('analysis', 'rowAnalysis', 'liteAbsent', 'proAnalysis'),
    ('strategy', 'rowStrategy', 'liteAbsent', 'proStrategy'),
    ('performance', 'rowPerformance', 'liteAbsent', 'proPerformance'),
    ('psychology', 'rowPsychology', 'liteAbsent', 'proPsychology'),
    ('reports', 'rowReports', 'liteAbsent', 'proReports'),
  ];

  double get _cellPad => compact ? 10 : 14;
  double get _headerPad => compact ? 16 : 20;
  double get _labelSize => compact ? 9 : 10;
  double get _valueSize => compact ? 11 : 12;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final data = _rowSpecs.take(rows.length).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: PaywallMobileTokens.tableBg,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        border: Border.all(
          color: PaywallMobileTokens.neutral800.withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.12),
            blurRadius: compact ? 16 : 22,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        child: Column(
          children: [
            _planHeaders(l),
            for (var i = 0; i < data.length; i++) ...[
              Divider(
                height: 1,
                color: PaywallMobileTokens.neutral800.withValues(alpha: 0.45),
              ),
              _compareRow(l, data[i], rows[i]),
            ],
            if (liteFooter != null || proFooter != null) ...[
              Divider(
                height: 1,
                color: PaywallMobileTokens.neutral800.withValues(alpha: 0.6),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: liteFooter ?? const SizedBox.shrink()),
                    Container(
                      width: 1,
                      color: const Color(0xFFD97706).withValues(alpha: 0.22),
                    ),
                    Expanded(child: proFooter ?? const SizedBox.shrink()),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _planHeaders(AppLocalizations l) {
    TextStyle cap({required Color color}) => GoogleFonts.plusJakartaSans(
          fontSize: compact ? 8 : 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: color,
        );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: PaywallMobileTokens.neutral950.withValues(alpha: 0.55),
              padding: EdgeInsets.all(_headerPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.paywallGoldLiteColumnCaption.toUpperCase(),
                    style: cap(color: PaywallMobileTokens.neutral500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.paywallPlanLiteName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: compact ? 16 : 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 8),
                  Text(
                    _liteFreeLabel(l),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: compact ? 20 : 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF451A03).withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
                border: Border(
                  left: BorderSide(
                    color: const Color(0xFFD97706).withValues(alpha: 0.25),
                  ),
                ),
              ),
              padding: EdgeInsets.all(_headerPad),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: PaywallMobileTokens.amber500,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PRO',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.paywallGoldProColumnCaption.toUpperCase(),
                        style: cap(color: PaywallMobileTokens.amber400),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.paywallPlanProName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: compact ? 16 : 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compareRow(
    AppLocalizations l,
    (String, String, String, String) spec,
    PaywallCompareRow row,
  ) {
    final rowLabel = _localized(l, spec.$2);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _cell(rowLabel, _liteValue(l, spec.$3, row), isPro: false)),
          Expanded(
            child: _cell(
              rowLabel,
              _proValue(l, spec.$4, row),
              isPro: true,
            ),
          ),
        ],
      ),
    );
  }

  String _liteFreeLabel(AppLocalizations l) {
    final code = l.localeName.split('_').first;
    return switch (code) {
      'en' => 'Free',
      'de' => 'Kostenlos',
      'es' => 'Gratis',
      'pt' => 'Grátis',
      'ko' => '무료',
      _ => 'Gratuit',
    };
  }

  String _localized(AppLocalizations l, String key) {
    return switch (key) {
      'rowTrades' => l.paywallMobileRowTrades,
      'rowEntry' => l.paywallMobileRowEntry,
      'rowCalendar' => l.paywallMobileRowCalendar,
      'rowChecklist' => l.paywallMobileRowChecklist,
      'rowAnalysis' => l.paywallMobileRowAnalysis,
      'rowStrategy' => l.paywallMobileRowStrategy,
      'rowPerformance' => l.paywallMobileRowStats,
      'rowPsychology' => l.paywallMobileRowMental,
      'rowReports' => l.paywallMobileRowExport,
      _ => key,
    };
  }

  String _liteValue(AppLocalizations l, String key, PaywallCompareRow row) {
    if (key == 'liteAbsent' || row.liteIsCross) return '×';
    if (row.liteLabel != null) return row.liteLabel!;
    return '×';
  }

  String _proValue(AppLocalizations l, String key, PaywallCompareRow row) {
    if (key == 'proTrades' && !row.liteIsCross && row.proIsChip) {
      return row.proLabel;
    }
    return row.proLabel;
  }

  Widget _cell(String label, String value, {required bool isPro}) {
    final labelStyle = GoogleFonts.plusJakartaSans(
      fontSize: _labelSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: isPro ? PaywallMobileTokens.amber500 : PaywallMobileTokens.neutral500,
    );
    final valueStyle = GoogleFonts.plusJakartaSans(
      fontSize: _valueSize,
      fontWeight: isPro ? FontWeight.w700 : FontWeight.w500,
      height: 1.2,
      color: isPro
          ? (value == '×' ? PaywallMobileTokens.neutral600 : PaywallMobileTokens.amber300)
          : (value == '×'
              ? PaywallMobileTokens.neutral600
              : PaywallMobileTokens.neutral300),
    );

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: _cellPad, horizontal: 6),
      decoration: BoxDecoration(
        color: isPro
            ? PaywallMobileTokens.amber500.withValues(alpha: 0.04)
            : PaywallMobileTokens.neutral950.withValues(alpha: 0.12),
        border: isPro
            ? Border(
                left: BorderSide(
                  color: const Color(0xFFD97706).withValues(alpha: 0.22),
                ),
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), textAlign: TextAlign.center, style: labelStyle),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: value == '×' ? valueStyle.copyWith(fontSize: _valueSize + 2) : valueStyle,
          ),
        ],
      ),
    );
  }
}
