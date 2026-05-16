import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'paywall_compare_rows.dart';

/// Style visuel du split Lite / Pro (essai = émeraude, Gold = or).
enum PaywallCompareTheme { trialEmerald, gold }

/// Tableau comparatif Lite / Pro partagé ([TrialPaywallOverlay], [GoldUpgradeFlutterPaywall]).
class PaywallCompareSplitTable extends StatelessWidget {
  const PaywallCompareSplitTable({
    super.key,
    required this.rows,
    required this.theme,
    required this.liteFooter,
    required this.proFooter,
    this.outerBorderRadius = 24,
    this.rowHeight = 38,
  });

  final List<PaywallCompareRow> rows;
  final PaywallCompareTheme theme;
  final Widget liteFooter;
  final Widget proFooter;
  final double outerBorderRadius;
  final double rowHeight;

  static const Color _splitBorder = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final isGold = theme == PaywallCompareTheme.gold;
    final liteBg = isGold ? const Color(0xFF0D0D0D) : const Color(0xFF0A0A0A);
    final outerBg = isGold ? const Color(0xFF0A0A0A) : const Color(0xFF050505);
    final liteText = isGold ? const Color(0xFF4B5563) : const Color(0xFF64748B);
    final proText = isGold ? const Color(0xFFFCF6BA) : const Color(0xFF10B981);
    final proGradient = isGold
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x14BF953F), Color(0x00000000)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x0D10B981), Color(0x00000000)],
          );
    final borderColor = isGold
        ? const Color(0xFFBF953F).withValues(alpha: 0.22)
        : _splitBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(outerBorderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: outerBg,
          borderRadius: BorderRadius.circular(outerBorderRadius),
          border: Border.all(color: borderColor),
          boxShadow: isGold
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
                ]
              : null,
        ),
        child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ColoredBox(
                color: liteBg,
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++)
                      _liteCell(
                        rows[i],
                        liteText,
                        italic: theme == PaywallCompareTheme.trialEmerald && i == 0,
                        bottomBorder: i < rows.length - 1,
                      ),
                    liteFooter,
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              color: Colors.white.withValues(alpha: 0.05),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: proGradient),
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++)
                      _proCell(
                        rows[i],
                        proText,
                        isGold: isGold,
                        bottomBorder: i < rows.length - 1,
                      ),
                    proFooter,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _liteCell(
    PaywallCompareRow row,
    Color textColor, {
    required bool italic,
    required bool bottomBorder,
  }) {
    final crossSize = theme == PaywallCompareTheme.gold ? 16.0 : 14.0;
    return Container(
      height: rowHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: bottomBorder
            ? const Border(bottom: BorderSide(color: _splitBorder, width: 1))
            : null,
      ),
      child: row.liteIsCross
          ? Icon(
              Icons.close_rounded,
              size: crossSize,
              color: textColor.withValues(
                alpha: theme == PaywallCompareTheme.gold ? 0.18 : 0.2,
              ),
            )
          : Text(
              row.liteLabel!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.15,
                color: textColor,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              ),
            ),
    );
  }

  Widget _proCell(
    PaywallCompareRow row,
    Color textColor, {
    required bool isGold,
    required bool bottomBorder,
  }) {
    final border = bottomBorder
        ? const Border(bottom: BorderSide(color: _splitBorder, width: 1))
        : null;

    if (row.proIsChip && isGold) {
      return Container(
        height: rowHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(border: border),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEAB308).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFEAB308).withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            row.proLabel.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.35,
              height: 1.1,
              color: isGold ? const Color(0xFFEAB308) : textColor,
            ),
          ),
        ),
      );
    }

    return Container(
      height: rowHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(border: border),
      child: Text(
        row.proLabel,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1.15,
          color: textColor,
        ),
      ),
    );
  }
}
