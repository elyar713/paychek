// This file intentionally contains legacy/duplicated code as a raw string.
// It exists only to keep `calculatrice_page.dart` small and readable.
//
// If you no longer need to keep this around, you can delete this file safely.
//
// ignore_for_file: unused_element

const String legacyCalculatricePageDump = r'''

  String _fmtMoney(double v) =>
      v.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

  String _fmtRatio(double v) {
    var s = v.toStringAsFixed(2);
    s = s.replaceAll(RegExp(r'\.?0+$'), ''); // drop trailing .00 / zeros
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final assets = ajouterTradeActifsPour(market);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MarketPillDropdown(
                  value: market,
                  onChanged: onChangedMarket,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AjouterTradeLabeledActifDropdown(
                  label: 'Actif',
                  labelStyle: t.labelMedium?.copyWith(
                    color: DashboardTokens.muted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  value: assets.contains(asset) ? asset : assets.first,
                  items: assets,
                  valueFontSize: 12,
                  onChanged: onChangedAsset,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: lot,
                  label: 'Lot',
                  onSubmitted: (_) => onCalculate(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NumberField(
                  controller: entry,
                  label: 'Prix d’entrée',
                  onSubmitted: (_) => onCalculate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: sl,
                  label: 'Stop loss',
                  onSubmitted: (_) => onCalculate(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NumberField(
                  controller: tp,
                  label: 'Take profit',
                  onSubmitted: (_) => onCalculate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCalculate,
              child: const Text('Calculer le ratio'),
            ),
          ),
          const SizedBox(height: 12),
          if (error != null)
            Text(error!, style: t.bodyMedium?.copyWith(color: Colors.redAccent))
          else if (result == null)
            Text('—', style: t.bodyMedium?.copyWith(color: DashboardTokens.muted))
          else ...[
            Text(
              'Résultat',
              style: t.labelLarge?.copyWith(
                color: DashboardTokens.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '1:${_fmtRatio(result!.ratio)}',
                textAlign: TextAlign.center,
                style: t.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // (rest of legacy file omitted)

''';
