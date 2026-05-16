// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

extension _AjouterTradePageStateCsv on _AjouterTradePageState {
  Future<void> _importFromSelectedCsvSource(BuildContext context) async {
    final source = _selectedCsvSoftware;
    if (source == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis un logiciel avant l\'import.')),
      );
      return;
    }
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['htm', 'html', 'xlsx', 'csv'],
        withData: true,
      );
      if (!context.mounted || picked == null || picked.files.isEmpty) return;

      final file = picked.files.first;
      setState(() => _lastImportedFileName = file.name);
      final fileNameLower = file.name.toLowerCase();
      final isXlsx = fileNameLower.endsWith('.xlsx');
      String? html;
      Uint8List? rawBytes;
      List<MtStatementTradeRow> parsedRows = const <MtStatementTradeRow>[];
      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes != null) {
          rawBytes = bytes;
          if (!isXlsx) {
            html = _decodeHtmlBytes(bytes);
          }
        }
      } else {
        final path = file.path;
        if (path != null && path.trim().isNotEmpty) {
          final xFile = XFile(path);
          if (isXlsx) {
            rawBytes = await xFile.readAsBytes();
          } else {
            final htmlBytes = await xFile.readAsBytes();
            html = _decodeHtmlBytes(htmlBytes);
          }
        } else if (file.bytes != null && file.bytes!.isNotEmpty) {
          // Certains chemins file_picker : pas de path mais octets présents.
          rawBytes = file.bytes;
          if (!isXlsx) {
            html = _decodeHtmlBytes(file.bytes!);
          }
        }
      }

      if (!context.mounted) return;
      if (!isXlsx && (html == null || html.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier vide ou illisible.')),
        );
        return;
      }

      switch (source) {
        case 'MT4':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('MT4: utilise un export HTML/HTM.')),
            );
            return;
          }
          parsedRows = parseMt4StatementHtml(html!);
          break;
        case 'MT5':
          if (isXlsx) {
            final bytes = rawBytes ?? Uint8List(0);
            parsedRows = _parseMt5SpreadsheetBytes(bytes);
          } else if (fileNameLower.endsWith('.csv')) {
            parsedRows = parseMt5PositionsCsv(html!);
          } else {
            parsedRows = parseMt5StatementHtml(html!);
          }
          break;
        case 'TradingView':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('TradingView: utilise un export CSV.'),
              ),
            );
            return;
          }
          parsedRows = parseTradingViewOrdersCsv(html!);
          break;
        case 'cTrader':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('cTrader: utilise un relevé HTML/HTM (compte).'),
              ),
            );
            return;
          }
          parsedRows = parseCtraderAccountStatementHtml(html!);
          break;
        case 'Tradovate':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tradovate: exporte Orders.csv (remplissages).'),
              ),
            );
            return;
          }
          if (!fileNameLower.endsWith('.csv')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tradovate: choisis un fichier Orders.csv.'),
              ),
            );
            return;
          }
          parsedRows = parseTradovateOrdersCsv(html!);
          break;
        case 'NinjaTrader':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'NinjaTrader: exporte une grille CSV (Ordres ou exécutions).',
                ),
              ),
            );
            return;
          }
          if (!fileNameLower.endsWith('.csv')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('NinjaTrader: choisis un fichier CSV (grille).'),
              ),
            );
            return;
          }
          parsedRows = parseNinjaTraderGridCsv(html!);
          break;
        case 'Rithmic':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rithmic: utilise un export CSV (Recent Orders).'),
              ),
            );
            return;
          }
          if (!fileNameLower.endsWith('.csv')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rithmic: choisis un fichier CSV.'),
              ),
            );
            return;
          }
          parsedRows = parseRithmicRecentOrdersCsv(html!);
          break;
        case 'Quantower':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quantower : utilise un export CSV (Orders history).'),
              ),
            );
            return;
          }
          if (!fileNameLower.endsWith('.csv')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quantower : choisis un fichier CSV (Orders history).'),
              ),
            );
            return;
          }
          parsedRows = parseQuantowerOrdersHistoryCsv(html!);
          break;
        case 'ATAS':
          if (isXlsx) {
            var bytes = rawBytes;
            if (bytes == null || bytes.isEmpty) {
              final p = file.path;
              if (p != null && p.trim().isNotEmpty) {
                bytes = await XFile(p).readAsBytes();
              }
            }
            if (!context.mounted) return;
            if (bytes == null || bytes.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Impossible de lire le .xlsx (fichier vide ou trop gros pour le navigateur). Réessaie ou rouvre le fichier.',
                  ),
                ),
              );
              return;
            }
            final atasOutcome = parseAtasTradesXlsxOutcome(bytes);
            parsedRows = atasOutcome.rows;
            if (!context.mounted) return;
            if (parsedRows.isEmpty && atasOutcome.emptyReason != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(atasOutcome.emptyReason!)),
              );
              return;
            }
            break;
          }
          if (!fileNameLower.endsWith('.csv')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ATAS: choisis un fichier CSV ou .xlsx (Statistiques).'),
              ),
            );
            return;
          }
          parsedRows = parseAtasTradesCsv(html!);
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import $source pas encore branché.')),
          );
          return;
      }

      if (parsedRows.isEmpty) {
        final extensionLabel = isXlsx ? 'XLSX' : 'HTML';
        final emptyDetail = source == 'MT5'
            ? 'MT5 $extensionLabel: aucune ligne Position détectée.'
            : source == 'TradingView'
                ? 'TradingView CSV: aucune position fermee detectee.'
                : source == 'cTrader'
                    ? 'cTrader HTM/HTML: aucune ligne Historique detectee.'
                    : source == 'Tradovate'
                        ? 'Tradovate CSV: aucun round-trip (entrée/sortie) detecte.'
                        : source == 'NinjaTrader'
                            ? 'NinjaTrader CSV: aucun round-trip (entrée/sortie) detecte.'
                            : source == 'ATAS'
                                ? 'ATAS: aucune ligne reconnue (feuille Journal uniquement).'
                                : 'Aucune position reconnue pour ce logiciel/fichier.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(emptyDetail)),
        );
        await logPaychekUserCsvImportEvent(
          software: source,
          status: PaychekCsvImportLogStatus.empty,
          parsedRowCount: 0,
          message: emptyDetail,
          fileName: file.name,
        );
        return;
      }

      parsedRows.sort((a, b) => a.closeTime.compareTo(b.closeTime));

      final store = TradeJournalScope.of(context);
      final portfolioId = UserPortfolioScope.of(context).activePortfolioId;
      final existingIds = store.items.map((e) => e.id).toSet();
      final ent = widget.accountEntitlement;
      final isPro = ent?.isPro == true;
      final inFullTrial = ent?.trialActive == true;
      final capImports = !isPro && !inFullTrial;
      var importedCount = 0;
      var skippedCount = 0;
      var skippedLiteMonthlyCap = 0;
      final dealPrefix = switch (source) {
        'cTrader' => 'ct',
        'Tradovate' => 'td',
        'NinjaTrader' => 'nt',
        'ATAS' => 'as',
        _ => 'mt',
      };
      for (final row in parsedRows) {
        final baseId =
            '${dealPrefix}_${row.ticket}_${row.closeTime.millisecondsSinceEpoch}';
        if (existingIds.contains(baseId)) {
          skippedCount++;
          continue;
        }
        if (capImports &&
            !TradeLiteMonthlyLimit.canAddNonPro(store.items, delta: 1)) {
          skippedLiteMonthlyCap++;
          continue;
        }
        final net = row.profit;
        final amountLabel =
            '${net >= 0 ? '+' : ''}${net.toStringAsFixed(2).replaceAll('.', ',')}\$';
        final item = TradeListItem(
          id: baseId,
          syncRev: DateTime.now().millisecondsSinceEpoch,
          pair: _normalizeImportedPair(row.symbol),
          side: row.side,
          amountLabel: amountLabel,
          gainAmount: net,
          dateLine: _formatTradeDateLine(row.openTime),
          entreeAt: row.openTime,
          sortieAt: row.closeTime,
          breakeven: net == 0,
          avantNews: false,
          apresNews: false,
          quantiteLabel: row.size.toStringAsFixed(2),
          prixEntreeLabel: row.openPrice.toStringAsFixed(5),
          prixSortieLabel: row.closePrice.toStringAsFixed(5),
          checklistPct: 50,
          planPct: 50,
          strategiePct: 50,
          etatPct: 50,
          mindset: TradeMindset.principe,
          // Strategy execution must reflect user-defined strategy, not import source.
          strategieTitle: _strategieChoisie,
          isProfit: net >= 0,
          assetClass: _assetClassForImportedRow(source, row),
          performanceLite: true,
          portfolioId: portfolioId,
        );
        store.add(item);
        existingIds.add(baseId);
        importedCount++;
      }
      if (!context.mounted) return;
      final l = AppLocalizations.of(context)!;
      var summary = importedCount == 0
          ? 'Aucun nouveau trade importé depuis $source'
                '${skippedCount > 0 ? ' · $skippedCount doublon(s)' : ''}.'
          : '$importedCount trade(s) importé(s) depuis $source'
                '${skippedCount > 0 ? ' · $skippedCount doublon(s) ignoré(s)' : ''}.';
      if (skippedLiteMonthlyCap > 0) {
        summary +=
            ' ${l.ajouterTradeLiteMonthlyLimitImportSkipped(skippedLiteMonthlyCap, TradeLiteMonthlyLimit.maxTradesPerCalendarMonthNonPro)}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(summary)),
      );
      if (importedCount > 0) {
        await bumpPaychekUserImportedTradesCount(importedCount);
      }
      await logPaychekUserCsvImportEvent(
        software: source,
        status: PaychekCsvImportLogStatus.success,
        tradeCount: importedCount,
        skippedDuplicates: skippedCount,
        parsedRowCount: parsedRows.length,
        fileName: file.name,
        message: importedCount == 0 ? summary : null,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import échoué: $e')));
      await logPaychekUserCsvImportEvent(
        software: _selectedCsvSoftware ?? 'inconnu',
        status: PaychekCsvImportLogStatus.error,
        message: e.toString(),
        fileName: _lastImportedFileName,
      );
    }
  }

  String _decodeHtmlBytes(Uint8List bytes) {
    if (bytes.length >= 2) {
      // UTF-16 LE BOM
      if (bytes[0] == 0xFF && bytes[1] == 0xFE) {
        return _decodeUtf16(bytes, littleEndian: true, offset: 2);
      }
      // UTF-16 BE BOM
      if (bytes[0] == 0xFE && bytes[1] == 0xFF) {
        return _decodeUtf16(bytes, littleEndian: false, offset: 2);
      }
    }
    try {
      return utf8.decode(bytes);
    } catch (_) {
      // MT reports can be exported in ANSI/Windows-1252.
      return latin1.decode(bytes, allowInvalid: true);
    }
  }

  String _decodeUtf16(
    Uint8List bytes, {
    required bool littleEndian,
    int offset = 0,
  }) {
    final units = <int>[];
    for (var i = offset; i + 1 < bytes.length; i += 2) {
      final lo = bytes[i];
      final hi = bytes[i + 1];
      units.add(littleEndian ? (hi << 8) | lo : (lo << 8) | hi);
    }
    return String.fromCharCodes(units);
  }

  List<MtStatementTradeRow> _parseMt5SpreadsheetBytes(Uint8List bytes) {
    try {
      return parseMt5StatementXlsx(bytes);
    } on FormatException {
      final text = _decodeHtmlBytes(bytes);
      return parseMt5StatementHtml(text);
    }
  }

  String _normalizeImportedPair(String rawSymbol) {
    final symbol = rawSymbol.trim().toUpperCase();
    if (symbol.isEmpty) return symbol;

    // Futures contracts often include expiry digits/suffixes (e.g. ESU26, MNQ1!).
    final hasFutureSuffix =
        RegExp(r'\d').hasMatch(symbol) || symbol.contains('!');
    if (!hasFutureSuffix) return symbol;

    final lettersOnly =
        RegExp(r'^[A-Z]+').firstMatch(symbol)?.group(0) ?? symbol;
    if (lettersOnly.startsWith('M') && lettersOnly.length >= 3) {
      // Micro futures -> keep first 3 letters (MNQ, MES, ...).
      return lettersOnly.substring(0, 3);
    }
    if (lettersOnly.length >= 2) {
      // Mini futures -> keep first 2 letters (ES, NQ, ...).
      return lettersOnly.substring(0, 2);
    }
    return lettersOnly;
  }

  AjouterTradeAssetClass _assetClassForImportedRow(
    String source,
    MtStatementTradeRow row,
  ) {
    if (source == 'TradingView' ||
        source == 'Tradovate' ||
        source == 'NinjaTrader' ||
        source == 'ATAS') {
      return AjouterTradeAssetClass.future;
    }
    if (source == 'cTrader') {
      final u = row.symbol.trim().toUpperCase();
      if (u.contains('XAU') ||
          u.contains('XAG') ||
          u.contains('OIL') ||
          u.endsWith('GAS') ||
          u.contains('GAS.') ||
          u.contains('.GAS')) {
        return AjouterTradeAssetClass.matieresPremieres;
      }
      if (u.contains('BTC') || u.contains('ETH')) {
        return AjouterTradeAssetClass.crypto;
      }
      return AjouterTradeAssetClass.forex;
    }
    return inferAjouterTradeAssetClassFromImportSymbol(
      normalizedRoot: row.symbol,
      csvSymbolOriginal: row.csvSymbolOriginal,
    );
  }
}