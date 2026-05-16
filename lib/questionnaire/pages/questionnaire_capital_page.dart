import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';
import '../questionnaire_tokens.dart';
import '../trading_currency.dart';
import '../../reglage/user_portfolio_scope.dart';
import '../user_capital_scope.dart';

/// Saisie du capital initial : grille de devises + montant (symbole Ã  gauche).
class QuestionnaireCapitalPage extends StatefulWidget {
  const QuestionnaireCapitalPage({super.key});

  @override
  QuestionnaireCapitalPageState createState() => QuestionnaireCapitalPageState();
}

class QuestionnaireCapitalPageState extends State<QuestionnaireCapitalPage> {
  final _controller = TextEditingController();
  String? _error;
  bool _seededFromStore = false;
  bool _useCustom = false;
  String _customName = '';
  String _customSymbol = '';
  TradingCurrency _currency = kTradingCurrencies.first;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seededFromStore) return;
    final store = UserCapitalScope.of(context);
    final existing = store.capitalAmount;
    if (store.isCustomCurrency) {
      _useCustom = true;
      _customName = store.customCurrencyName ?? '';
      _customSymbol = store.currencySymbol;
    } else {
      _useCustom = false;
      final fromStore = tradingCurrencyByCode(store.currencyCode);
      _currency = fromStore ?? kTradingCurrencies.first;
    }
    if (existing != null) {
      _controller.text = _formatAmount(existing);
    }
    _seededFromStore = true;
  }

  String _formatAmount(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(2);
  }

  String get _amountPrefix =>
      _useCustom ? (_customSymbol.isNotEmpty ? _customSymbol : r'$') : _currency.symbol;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openAddCurrencyDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: _customName);
    final symbolCtrl = TextEditingController(text: _customSymbol);
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return Theme(
            data: _capitalDialogTheme(Theme.of(ctx)),
            child: AlertDialog(
              title: Text(l10n.customCurrencyTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: l10n.currencyNameLabel,
                        hintText: l10n.currencyNameHint,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: symbolCtrl,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: l10n.symbolLabel,
                        hintText: l10n.symbolHint,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  style: _capitalDialogFilledButtonStyle(),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(l10n.validate),
                ),
              ],
            ),
          );
        },
      );
      if (ok != true || !mounted) return;
      final n = nameCtrl.text.trim();
      final s = symbolCtrl.text.trim();
      if (n.isEmpty && s.isEmpty) {
        setState(() => _error = l10n.errorNameOrSymbol);
        return;
      }
      final resolvedName = n.isEmpty ? s : n;
      final resolvedSymbol = s.isEmpty ? n : s;
      setState(() {
        _useCustom = true;
        _customName = resolvedName;
        _customSymbol = resolvedSymbol;
        _error = null;
      });
    } finally {
      nameCtrl.dispose();
      symbolCtrl.dispose();
    }
  }

  Future<bool> tryAdvance() async {
    final l10n = AppLocalizations.of(context)!;
    final raw = _controller.text.trim().replaceAll(',', '.').replaceAll(' ', '');
    final value = double.tryParse(raw);
    if (value == null || value < 0) {
      setState(() => _error = l10n.errorAmount);
      return false;
    }
    setState(() => _error = null);
    try {
      final store = UserCapitalScope.of(context);
      if (_useCustom) {
        await store.setCapitalCustom(
          amount: value,
          name: _customName,
          symbol: _customSymbol,
        );
      } else {
        await store.setCapital(
          amount: value,
          currencyCode: _currency.code,
        );
      }
      if (!mounted) return false;
      await UserPortfolioScope.of(context).syncDefaultFromCapital(store);
      return true;
    } on ArgumentError {
      setState(() => _error = l10n.errorInvalidAmount);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final w = MediaQuery.sizeOf(context).width;
    final isWideWeb = kIsWeb && w >= 900;

    final tileSize = isWideWeb ? 46.0 : 54.0;
    final gap = isWideWeb ? 5.0 : 6.0;
    final contentMaxWidth = isWideWeb ? 720.0 : double.infinity;

    final abbrev = _abbrevLabel(_customName);
    final addTop = _useCustom && abbrev.isNotEmpty ? abbrev : '+';
    final addBottom = _useCustom && _customSymbol.isNotEmpty
        ? _customSymbol
        : (_useCustom ? l10n.capitalEllipsis : l10n.capitalOther);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isWideWeb ? 20 : 24, 8, isWideWeb ? 20 : 24, isWideWeb ? 20 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.capitalInitialTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      fontSize: isWideWeb ? 22 : null,
                      color: Colors.white,
                    ),
              ),
              SizedBox(height: isWideWeb ? 14 : 20),
              Text(
                l10n.capitalCurrencyTitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white54,
                      fontWeight: FontWeight.w500,
                      fontSize: isWideWeb ? 11 : null,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final c in kTradingCurrencies)
                    _CompactCurrencyTile(
                      selected: !_useCustom && _currency.code == c.code,
                      size: tileSize,
                      onTap: () => setState(() {
                        _useCustom = false;
                        _currency = c;
                      }),
                      topText: c.shortLabel,
                      bottomText: c.symbol,
                    ),
                  _CompactCurrencyTile(
                    selected: _useCustom,
                    size: tileSize,
                    onTap: _openAddCurrencyDialog,
                    topText: addTop,
                    bottomText: addBottom,
                    bottomFontSize: isWideWeb ? 10 : 11,
                    largeTop: addTop == '+',
                  ),
                ],
              ),
              SizedBox(height: isWideWeb ? 20 : 28),
              TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
                ],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w300,
                      fontSize: isWideWeb ? 26 : null,
                      color: Colors.white,
                    ),
                decoration: InputDecoration(
                  hintText: l10n.capitalHintAmount,
                  errorText: _error,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _amountPrefix,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: isWideWeb ? 16 : null,
                            ),
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => tryAdvance(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _abbrevLabel(String name) {
  if (name.isEmpty) return '';
  final u = name.toUpperCase();
  return u.length <= 5 ? u : '${u.substring(0, 4)}â€¦';
}

ThemeData _capitalDialogTheme(ThemeData base) {
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: Colors.white,
      onPrimary: Colors.black,
    ),
    splashColor: Colors.white24,
    highlightColor: Colors.white24,
    dialogTheme: const DialogThemeData(
      surfaceTintColor: Colors.transparent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: _capitalDialogTextButtonStyle(),
    ),
  );
}

ButtonStyle _capitalDialogTextButtonStyle() {
  return TextButton.styleFrom(
    foregroundColor: Colors.white,
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) return Colors.white24;
      if (states.contains(WidgetState.hovered)) return Colors.white12;
      return Colors.transparent;
    }),
  );
}

ButtonStyle _capitalDialogFilledButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) return Colors.black26;
      return null;
    }),
  );
}

class _CompactCurrencyTile extends StatelessWidget {
  const _CompactCurrencyTile({
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
    final bg = selected
        ? QuestionnaireTokens.tileBgSelected
        : QuestionnaireTokens.tileBgUnselected;
    final border = selected ? Colors.white70 : const Color(0xFF333333);
    final effectiveTopSize = largeTop ? 18.0 : 9.5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
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
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: effectiveTopSize,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                bottomText,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white54,
                  fontSize: bottomFontSize,
                  fontWeight: FontWeight.w400,
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



