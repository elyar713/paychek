import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../paywall_compare_rows.dart';
import 'paywall_mobile_tokens.dart';

/// Tableau Lite / Pro — style noir & or (maquette mobile).
class PaywallMobileCompareTable extends StatelessWidget {
  const PaywallMobileCompareTable({super.key, required this.rows});

  final List<PaywallCompareRow> rows;

  static List<(String feature, PaywallCompareRow row)> _mobileRows(
    AppLocalizations l,
    List<PaywallCompareRow> rows,
  ) {
    final titles = [
      l.paywallMobileRowTrades,
      l.paywallMobileRowEntry,
      l.paywallMobileRowCalendar,
      l.paywallMobileRowChecklist,
      l.paywallMobileRowAnalysis,
      l.paywallMobileRowStrategy,
      l.paywallMobileRowStats,
      l.paywallMobileRowMental,
      l.paywallMobileRowExport,
    ];
    return List.generate(
      rows.length.clamp(0, titles.length),
      (i) => (titles[i], rows[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final data = _mobileRows(l, rows);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: PaywallMobileTokens.tableBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PaywallMobileTokens.neutral800.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _headerRow(l),
            for (var i = 0; i < data.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, color: PaywallMobileTokens.neutral900),
              _dataRow(data[i].$1, data[i].$2),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerRow(AppLocalizations l) {
    TextStyle th({Color? color, FontWeight weight = FontWeight.w800}) =>
        GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: weight,
          letterSpacing: 1.1,
          color: color ?? PaywallMobileTokens.neutral400,
        );

    return Container(
      decoration: const BoxDecoration(
        color: PaywallMobileTokens.neutral950,
        border: Border(bottom: BorderSide(color: PaywallMobileTokens.neutral800)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 44,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                l.paywallMobileCompareFeatureCol.toUpperCase(),
                style: th(weight: FontWeight.w900),
              ),
            ),
          ),
          Expanded(
            flex: 28,
            child: Container(
              color: PaywallMobileTokens.neutral900.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                l.paywallPlanLiteName.toUpperCase(),
                textAlign: TextAlign.center,
                style: th(weight: FontWeight.w900),
              ),
            ),
          ),
          Expanded(
            flex: 28,
            child: Container(
              color: PaywallMobileTokens.amber500.withValues(alpha: 0.03),
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                l.paywallPlanProName.toUpperCase(),
                textAlign: TextAlign.center,
                style: th(
                  color: PaywallMobileTokens.amber400,
                  weight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataRow(String feature, PaywallCompareRow row) {
    return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 44,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 4),
                  child: Text(
                    feature,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                      color: PaywallMobileTokens.neutral200,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 28,
                child: Container(
                  color: PaywallMobileTokens.neutral900.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(child: _liteCell(row)),
                ),
              ),
              Expanded(
                flex: 28,
                child: Container(
                  color: PaywallMobileTokens.amber500.withValues(alpha: 0.03),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(child: _proCell(row)),
                ),
              ),
            ],
          ),
    );
  }

  Widget _liteCell(PaywallCompareRow row) {
    if (row.liteIsCross) {
      return Text(
        '✕',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: PaywallMobileTokens.neutral700,
        ),
      );
    }
    return Text(
      row.liteLabel!,
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: PaywallMobileTokens.neutral400,
      ),
    );
  }

  Widget _proCell(PaywallCompareRow row) {
    if (row.liteIsCross) {
      return Text(
        '✓',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: PaywallMobileTokens.amber500,
        ),
      );
    }
    return Text(
      row.proLabel,
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: PaywallMobileTokens.amber300,
      ),
    );
  }
}
