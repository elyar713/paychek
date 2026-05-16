import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../questionnaire/trading_currency.dart';
import '../questionnaire/user_capital_scope.dart';
import '../questionnaire/user_capital_store.dart';
import 'user_portfolio_scope.dart';

const Color _kBrandTeal = Color(0xFF1EB48A);

/// Feuille modale : saisie du capital et choix de la devise (Portfolios).
Future<void> showReglagePortfolioSheet(BuildContext context) {
  final store = UserCapitalScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: _PortfolioSheetBody(store: store),
      );
    },
  );
}

class _PortfolioSheetBody extends StatefulWidget {
  const _PortfolioSheetBody({required this.store});

  final UserCapitalStore store;

  @override
  State<_PortfolioSheetBody> createState() => _PortfolioSheetBodyState();
}

class _PortfolioSheetBodyState extends State<_PortfolioSheetBody> {
  late final TextEditingController _amountCtrl;
  late bool _useCustom;
  late String _customName;
  late String _customSymbol;
  late TradingCurrency _currency;
  String? _error;

  @override
  void initState() {
    super.initState();
    final store = widget.store;
    _amountCtrl = TextEditingController();
    if (store.capitalAmount != null) {
      final v = store.capitalAmount!;
      _amountCtrl.text =
          v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);
    }
    if (store.isCustomCurrency) {
      _useCustom = true;
      _customName = store.customCurrencyName ?? '';
      _customSymbol = store.currencySymbol;
    } else {
      _useCustom = false;
      _customName = '';
      _customSymbol = '';
      _currency = tradingCurrencyByCode(store.currencyCode) ?? kTradingCurrencies.first;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  String get _amountPrefix => _useCustom
      ? (_customSymbol.isNotEmpty ? _customSymbol : r'$')
      : _currency.symbol;

  Future<void> _openCustomCurrencyDialog() async {
    final nameCtrl = TextEditingController(text: _customName);
    final symbolCtrl = TextEditingController(text: _customSymbol);
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final d = AppLocalizations.of(ctx)!;
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _kBrandTeal,
              surface: Color(0xFF141414),
              onSurface: Colors.white,
            ),
          ),
          child: AlertDialog(
            backgroundColor: const Color(0xFF141414),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              d.customCurrencyTitle,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: _dialogFieldDecoration(d.currencyNameLabel, d.currencyNameHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: symbolCtrl,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: _dialogFieldDecoration(d.symbolLabel, d.symbolHint),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  d.cancel,
                  style: GoogleFonts.plusJakartaSans(color: DashboardTokens.muted),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _kBrandTeal,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(d.validate, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        );
      },
    );
    final n = nameCtrl.text.trim();
    final s = symbolCtrl.text.trim();
    nameCtrl.dispose();
    symbolCtrl.dispose();
    if (ok != true || !mounted) return;
    if (n.isEmpty && s.isEmpty) {
      setState(() => _error = l.errorNameOrSymbol);
      return;
    }
    setState(() {
      _useCustom = true;
      _customName = n.isEmpty ? s : n;
      _customSymbol = s.isEmpty ? n : s;
      _error = null;
    });
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final raw = _amountCtrl.text.trim().replaceAll(',', '.').replaceAll(' ', '');
    final value = double.tryParse(raw);
    if (value == null || value < 0) {
      setState(() => _error = l.errorAmount);
      return;
    }
    setState(() => _error = null);
    try {
      if (_useCustom) {
        await widget.store.setCapitalCustom(
          amount: value,
          name: _customName,
          symbol: _customSymbol,
        );
      } else {
        await widget.store.setCapital(
          amount: value,
          currencyCode: _currency.code,
        );
      }
      if (!mounted) return;
      await UserPortfolioScope.of(context)
          .syncDefaultFromCapital(widget.store);
      if (mounted) Navigator.of(context).pop();
    } on ArgumentError {
      setState(() => _error = l.errorInvalidAmount);
    }
  }

  String _abbrevLabel(String name) {
    if (name.isEmpty) return '';
    final u = name.toUpperCase();
    return u.length <= 5 ? u : '${u.substring(0, 4)}\u2026';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    const tileSize = 52.0;
    const gap = 6.0;
    final abbrev = _abbrevLabel(_customName);
    final addTop = _useCustom && abbrev.isNotEmpty ? abbrev : '+';
    final addBottom = _useCustom && _customSymbol.isNotEmpty
        ? _customSymbol
        : (_useCustom ? l.capitalEllipsis : l.capitalOther);

    return Material(
      color: Colors.transparent,
      child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: const Color(0xFF1A1A1A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DashboardTokens.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  Text(
                    l.reglagePortfolioSheetTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.reglagePortfolioSheetSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: DashboardTokens.muted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    l.capitalCurrencyTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: DashboardTokens.labelGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final c in kTradingCurrencies)
                        _CurrencyChip(
                          selected: !_useCustom && _currency.code == c.code,
                          size: tileSize,
                          onTap: () => setState(() {
                            _useCustom = false;
                            _currency = c;
                            _error = null;
                          }),
                          topText: c.shortLabel,
                          bottomText: c.symbol,
                        ),
                      _CurrencyChip(
                        selected: _useCustom,
                        size: tileSize,
                        onTap: _openCustomCurrencyDialog,
                        topText: addTop,
                        bottomText: addBottom,
                        bottomFontSize: 11,
                        largeTop: addTop == '+',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    l.capitalAmountLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: DashboardTokens.labelGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
                    ],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      errorText: _error,
                      filled: true,
                      fillColor: const Color(0xFF121214),
                      hintText: l.capitalHintAmount,
                      hintStyle: GoogleFonts.plusJakartaSans(color: DashboardTokens.muted),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Align(
                          widthFactor: 1,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _amountPrefix,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              color: DashboardTokens.onMatteEmphasis,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 48, minHeight: 48),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: DashboardTokens.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: DashboardTokens.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _kBrandTeal, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DashboardTokens.onMatteEmphasis,
                            side: BorderSide(color: DashboardTokens.border),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l.cancel,
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: _kBrandTeal,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l.save,
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    );
  }
}

InputDecoration _dialogFieldDecoration(String label, String hint) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: GoogleFonts.plusJakartaSans(color: DashboardTokens.muted),
    hintStyle: GoogleFonts.plusJakartaSans(color: DashboardTokens.muted.withValues(alpha: 0.6)),
    filled: true,
    fillColor: const Color(0xFF1A1A1C),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({
    required this.selected,
    required this.size,
    required this.onTap,
    required this.topText,
    required this.bottomText,
    this.bottomFontSize = 13,
    this.largeTop = false,
  });

  final bool selected;
  final double size;
  final VoidCallback onTap;
  final String topText;
  final String bottomText;
  final double bottomFontSize;
  final bool largeTop;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? _kBrandTeal.withValues(alpha: 0.22) : const Color(0xFF121214);
    final border = selected ? _kBrandTeal : const Color(0xFF333333);
    final topSize = largeTop ? 17.0 : 9.5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: selected ? 1.5 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                topText,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: topSize,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                bottomText,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : Colors.white54,
                  fontSize: bottomFontSize,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



