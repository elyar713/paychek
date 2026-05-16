import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../questionnaire/trading_currency.dart';
import '../questionnaire/user_capital_scope.dart';
import 'reglage_portfolio_editor_widgets.dart';
import 'user_portfolio_models.dart';
import 'user_portfolio_store.dart';

class ReglageSinglePortfolioEditorSheet extends StatefulWidget {
  const ReglageSinglePortfolioEditorSheet({
    super.key,
    required this.store,
    this.existing,
  });

  final UserPortfolioStore store;
  final UserPortfolio? existing;

  @override
  State<ReglageSinglePortfolioEditorSheet> createState() =>
      _ReglageSinglePortfolioEditorSheetState();
}

class _ReglageSinglePortfolioEditorSheetState
    extends State<ReglageSinglePortfolioEditorSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late bool _useCustom;
  late String _customName;
  late String _customSymbol;
  late TradingCurrency _currency;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl = TextEditingController();
    if (e?.capitalAmount != null) {
      final v = e!.capitalAmount!;
      _amountCtrl.text =
          v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);
    }
    if (e != null && e.isCustomCurrency) {
      _useCustom = true;
      _customName = e.customCurrencyName;
      _customSymbol = e.customCurrencySymbol;
    } else {
      _useCustom = false;
      _customName = '';
      _customSymbol = '';
      _currency = e != null
          ? (tradingCurrencyByCode(e.currencyCode) ?? kTradingCurrencies.first)
          : kTradingCurrencies.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  String get _amountPrefix => _useCustom
      ? (_customSymbol.isNotEmpty ? _customSymbol : r'$')
      : _currency.symbol;

  Future<void> _openCustomCurrencyDialog() async {
    final nameCtrl = TextEditingController(text: _customName);
    final symbolCtrl = TextEditingController(text: _customSymbol);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            l.customCurrencyTitle,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
                decoration: reglagePortfolioDialogField(l.currencyNameLabel, l.currencyNameHint),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: symbolCtrl,
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
                decoration: reglagePortfolioDialogField(l.symbolLabel, l.symbolHint),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel, style: GoogleFonts.plusJakartaSans(color: DashboardTokens.muted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kReglagePortfolioBrandTeal,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.ok, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
    final n = nameCtrl.text.trim();
    final s = symbolCtrl.text.trim();
    nameCtrl.dispose();
    symbolCtrl.dispose();
    if (ok != true || !mounted) return;
    if (n.isEmpty && s.isEmpty) {
      setState(() => _error = AppLocalizations.of(context)!.errorNameOrSymbol);
      return;
    }
    setState(() {
      _useCustom = true;
      _customName = n.isEmpty ? s : n;
      _customSymbol = s.isEmpty ? n : s;
      _error = null;
    });
  }

  String _abbrevLabel(String name) {
    if (name.isEmpty) return '';
    final u = name.toUpperCase();
    return u.length <= 5 ? u : '${u.substring(0, 4)}…';
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l.portfolioNameMissing);
      return;
    }
    final raw = _amountCtrl.text.trim().replaceAll(',', '.').replaceAll(' ', '');
    final value = raw.isEmpty ? 0.0 : double.tryParse(raw);
    if (value == null || value < 0) {
      setState(() => _error = l.errorAmount);
      return;
    }
    setState(() => _error = null);

    final id = widget.existing?.id ?? '${DateTime.now().microsecondsSinceEpoch}';
    final isDefault = id == kDefaultPortfolioId;

    if (isDefault) {
      final capital = UserCapitalScope.of(context);
      try {
        if (_useCustom) {
          await capital.setCapitalCustom(
            amount: value,
            name: _customName,
            symbol: _customSymbol,
          );
        } else {
          await capital.setCapital(
            amount: value,
            currencyCode: _currency.code,
          );
        }
        await widget.store.syncDefaultFromCapital(capital, displayName: name);
      } on ArgumentError {
        setState(() => _error = l.errorInvalidAmount);
        return;
      }
    } else {
      final p = UserPortfolio(
        id: id,
        name: name,
        capitalAmount: value,
        currencyCode: _useCustom ? kCustomCurrencyCode : _currency.code,
        customCurrencyName: _useCustom ? _customName : '',
        customCurrencySymbol: _useCustom ? _customSymbol : '',
      );
      await widget.store.upsert(p);
    }
    if (mounted) Navigator.of(context).pop();
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
        : (_useCustom ? '…' : 'autre');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DashboardTokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.existing == null ? 'Nouveau portefeuille' : 'Modifier le portefeuille',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nom',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: DashboardTokens.labelGrey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'ex. IC Markets, compte principal…',
                hintStyle: GoogleFonts.plusJakartaSans(color: DashboardTokens.muted),
                filled: true,
                fillColor: const Color(0xFF121214),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: DashboardTokens.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kReglagePortfolioBrandTeal, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Devise',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: DashboardTokens.labelGrey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final c in kTradingCurrencies)
                  ReglagePortfolioCurrencyChip(
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
                ReglagePortfolioCurrencyChip(
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
            const SizedBox(height: 18),
            Text(
              'Montant du capital',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: DashboardTokens.labelGrey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
              ],
              style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
              decoration: InputDecoration(
                errorText: _error,
                filled: true,
                fillColor: const Color(0xFF121214),
                hintText: 'ex. 10 000',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
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
                prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: DashboardTokens.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kReglagePortfolioBrandTeal, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DashboardTokens.onMatteEmphasis,
                      side: BorderSide(color: DashboardTokens.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l.cancel, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: kReglagePortfolioBrandTeal,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l.save, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
