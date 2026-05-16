import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../paywall_compare_rows.dart';
import '../paywall_compare_split_table.dart';

/// Paywall marketing **Gold** entièrement Flutter (aucun HTML / WebView).
///
/// Même intention que l’ancienne maquette HTML : Lite vs Pro, prix, CTA or.
class GoldUpgradeFlutterPaywall extends StatelessWidget {
  const GoldUpgradeFlutterPaywall({super.key, required this.onSubscribe});

  final Future<void> Function() onSubscribe;

  static const Color _bg = Color(0xFF050505);
  static const Color _gold1 = Color(0xFFBF953F);
  static const Color _gold2 = Color(0xFFAA771C);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate400 = Color(0xFF94A3B8);
  static const Color _slate600 = Color(0xFF4B5563);

  static const LinearGradient _goldBtnGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_gold1, _gold2],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ColoredBox(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF422006).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFD97706).withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  l10n.paywallGoldPremiumPill.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.2,
                    color: const Color(0xFFEAB308),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _gold1,
                  Color(0xFFFCF6BA),
                  Color(0xFFB38728),
                  Color(0xFFFBF5B7),
                  _gold2,
                ],
                stops: [0.0, 0.25, 0.5, 0.72, 1.0],
              ).createShader(bounds),
              child: Text(
                l10n.paywallGoldMarketingHeadline,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.paywallGoldTagline,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _slate500,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        l10n.paywallGoldLiteColumnCaption.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.4,
                          color: _slate600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.paywallPlanLiteName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: _slate400,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        l10n.paywallGoldProColumnCaption.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.paywallPlanProName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: _gold1.withValues(alpha: 0.45),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            PaywallCompareSplitTable(
              rows: buildPaywallCompareRows(l10n),
              theme: PaywallCompareTheme.gold,
              outerBorderRadius: 28,
              liteFooter: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          l10n.paywallGoldYourPlanLabel.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: GoldUpgradeFlutterPaywall._slate600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              proFooter: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: _GoldSubscribeButton(
                  label: l10n.paywallSubscribeButton,
                  onSubscribe: onSubscribe,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.paywallPriceAnnualHighlight,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.paywallPriceApproxPerMonth,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: const Color(0xFFD97706).withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.paywallLegalFooter,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.8,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldSubscribeButton extends StatelessWidget {
  const _GoldSubscribeButton({
    required this.label,
    required this.onSubscribe,
  });

  final String label;
  final Future<void> Function() onSubscribe;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: GoldUpgradeFlutterPaywall._goldBtnGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: GoldUpgradeFlutterPaywall._gold2.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => unawaited(onSubscribe()),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
