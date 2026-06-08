// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

extension _AjouterTradePageStateCsv on _AjouterTradePageState {
  void _showCsvImportSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (!kIsWeb) {
      final bottomInset = MediaQuery.paddingOf(context).bottom;
      final navClearance =
          DashboardMainBottomNav.totalHeight(bottomInset) + 12;
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, navClearance),
          duration: const Duration(seconds: 6),
          backgroundColor: isError ? const Color(0xFF2A1810) : null,
        ),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 5),
        backgroundColor: isError ? const Color(0xFF2A1810) : null,
      ),
    );
  }

  void _revealCsvImportFeedback() {
    if (kIsWeb) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _csvImportFeedbackKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.15,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _setCsvImportFeedback(
    String message, {
    required bool isError,
  }) {
    setState(() {
      _lastCsvImportFeedback = message;
      _lastCsvImportFeedbackIsError = isError;
    });
    _revealCsvImportFeedback();
  }

  Future<bool> _confirmCsvJournalImport(
    BuildContext context, {
    required int count,
    required String source,
    required int skippedDuplicates,
    required int skippedLiteMonthlyCap,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final dupSuffix = skippedDuplicates > 0
        ? l10n.tradeImportDuplicatesSuffix(skippedDuplicates)
        : '';
    var liteCapNote = '';
    if (skippedLiteMonthlyCap > 0) {
      liteCapNote =
          ' ${l10n.ajouterTradeLiteMonthlyLimitImportSkipped(skippedLiteMonthlyCap, TradeLiteMonthlyLimit.maxTradesPerCalendarMonthNonPro)}';
    }
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          backgroundColor: DashboardTokens.cardBoxBg,
          title: Text(
            l.tradeImportConfirmTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            '${l.tradeImportConfirmBody(count, source, dupSuffix)}$liteCapNote',
            style: TextStyle(color: DashboardTokens.muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l.tradeImportConfirmAction,
                style: TextStyle(color: DashboardTokens.accent),
              ),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  String _atasXlsxEmptyMessage(
    AppLocalizations l,
    AtasXlsxEmptyReason reason,
  ) {
    return switch (reason) {
      AtasXlsxEmptyReason.emptyFile => l.tradeImportAtasXlsxEmptyFile,
      AtasXlsxEmptyReason.invalidFormat => l.tradeImportAtasXlsxInvalidFormat,
      AtasXlsxEmptyReason.journalSheetMissing =>
        l.tradeImportAtasXlsxJournalMissing,
      AtasXlsxEmptyReason.noTradeRows => l.tradeImportAtasXlsxNoRows,
    };
  }

  String _tradeImportEmptyDetail(
    AppLocalizations l,
    String source,
    bool isXlsx,
  ) {
    final extensionLabel = isXlsx ? 'XLSX' : 'HTML';
    return switch (source) {
      'MT5' => l.tradeImportEmptyMt5(extensionLabel),
      'TradingView' => l.tradeImportEmptyTradingView,
      'cTrader' => l.tradeImportEmptyCtrader,
      'Tradovate' => l.tradeImportEmptyTradovate,
      'NinjaTrader' => l.tradeImportEmptyNinjaTrader,
      'ATAS' => l.tradeImportEmptyAtas,
      _ => l.tradeImportEmptyGeneric,
    };
  }

  Future<void> _importFromSelectedCsvSource(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.liteFreemiumRestricted) {
      widget.onLiteFreemiumRestrictedTap?.call();
      return;
    }
    final source = _selectedCsvSoftware;
    if (source == null) {
      _showCsvImportSnackBar(context, l10n.tradeImportPickSoftwareFirst);
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
      setState(() {
        _lastImportedFileName = file.name;
        _lastCsvImportFeedback = null;
        _lastCsvImportFeedbackIsError = false;
      });
      final fileNameLower = file.name.toLowerCase();
      final isXlsx = fileNameLower.endsWith('.xlsx');
      final rawBytes = await paychekSupportReadPlatformFileBytes(file);
      if (!context.mounted) return;
      if (rawBytes == null || rawBytes.isEmpty) {
        final msg = l10n.tradeImportEmptyFile;
        _setCsvImportFeedback(msg, isError: true);
        _showCsvImportSnackBar(context, msg, isError: true);
        return;
      }
      final html = isXlsx ? null : _decodeHtmlBytes(rawBytes);
      List<MtStatementTradeRow> parsedRows = const <MtStatementTradeRow>[];

      if (!context.mounted) return;
      if (!isXlsx && (html == null || html.trim().isEmpty)) {
        final msg = l10n.tradeImportEmptyFile;
        _setCsvImportFeedback(msg, isError: true);
        _showCsvImportSnackBar(context, msg, isError: true);
        return;
      }

      switch (source) {
        case 'MT4':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportMt4HtmlOnly)),
            );
            return;
          }
          parsedRows = parseMt4StatementHtml(html!);
          break;
        case 'MT5':
          if (isXlsx) {
            parsedRows = _parseMt5SpreadsheetBytes(rawBytes);
          } else if (fileNameLower.endsWith('.csv')) {
            parsedRows = parseMt5PositionsCsv(html!);
          } else {
            parsedRows = parseMt5StatementHtml(html!);
          }
          break;
        case 'TradingView':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportTradingViewCsvOnly)),
            );
            return;
          }
          parsedRows = parseTradingViewOrdersCsv(html!);
          break;
        case 'cTrader':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportCtraderHtmlOnly)),
            );
            return;
          }
          parsedRows = parseCtraderAccountStatementHtml(html!);
          break;
        case 'Tradovate':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportTradovateOrdersCsv)),
            );
            return;
          }
          if (!fileNameLower.endsWith('.csv')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportTradovatePickOrdersCsv)),
            );
            return;
          }
          parsedRows = parseTradovateImportCsv(html!);
          break;
        case 'NinjaTrader':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportNinjaGridCsv)),
            );
            return;
          }
          if (!fileNameLower.endsWith('.csv')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportNinjaPickCsv)),
            );
            return;
          }
          parsedRows = parseNinjaTraderGridCsv(html!);
          break;
        case 'Rithmic':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportRithmicCsv)),
            );
            return;
          }
          if (!fileNameLower.endsWith('.csv')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportRithmicPickCsv)),
            );
            return;
          }
          parsedRows = parseRithmicRecentOrdersCsv(html!);
          break;
        case 'Quantower':
          if (isXlsx) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportQuantowerCsv)),
            );
            return;
          }
          if (!fileNameLower.endsWith('.csv')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportQuantowerPickCsv)),
            );
            return;
          }
          parsedRows = parseQuantowerOrdersHistoryCsv(html!);
          break;
        case 'ATAS':
          if (isXlsx) {
            final atasOutcome = parseAtasTradesXlsxOutcome(rawBytes);
            parsedRows = atasOutcome.rows;
            if (!context.mounted) return;
            if (parsedRows.isEmpty && atasOutcome.emptyReason != null) {
              final msg = _atasXlsxEmptyMessage(l10n, atasOutcome.emptyReason!);
              _setCsvImportFeedback(msg, isError: true);
              _showCsvImportSnackBar(context, msg, isError: true);
              return;
            }
            break;
          }
          if (!fileNameLower.endsWith('.csv')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tradeImportAtasPickCsvXlsx)),
            );
            return;
          }
          parsedRows = parseAtasTradesCsv(html!);
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.tradeImportNotImplemented(source))),
          );
          return;
      }

      if (parsedRows.isEmpty) {
        final emptyDetail = _tradeImportEmptyDetail(l10n, source, isXlsx);
        _setCsvImportFeedback(emptyDetail, isError: true);
        _showCsvImportSnackBar(context, emptyDetail, isError: true);
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

      final storedAnalyseReports = await AnalyseReportsStorage.loadAll();
      if (!context.mounted) return;

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
      final pendingImports = <TradeListItem>[];
      for (final row in parsedRows) {
        final baseId =
            '${dealPrefix}_${row.ticket}_${row.closeTime.millisecondsSinceEpoch}';
        if (existingIds.contains(baseId)) {
          skippedCount++;
          continue;
        }
        if (capImports &&
            !TradeLiteMonthlyLimit.canAddNonPro(
              store.items,
              delta: pendingImports.length + 1,
            )) {
          skippedLiteMonthlyCap++;
          continue;
        }
        final net = row.profit;
        final amountLabel =
            '${net >= 0 ? '+' : ''}${net.toStringAsFixed(2).replaceAll('.', ',')}\$';
        final pair = _normalizeImportedPair(row.symbol);
        final planReport =
            planReportForImportedSymbol(pair, storedAnalyseReports);
        final discipline = resolveTradeDisciplineForEntryDay(
          entryAt: row.openTime,
          checklist: widget.checklistController,
          storedReports: storedAnalyseReports,
          planReport: planReport,
        );
        final newsFlags = resolveTradeNewsTimingFlagsFromController(
          entreeAt: row.openTime,
          checklist: widget.checklistController,
        );
        pendingImports.add(
          TradeListItem(
            id: baseId,
            syncRev: DateTime.now().millisecondsSinceEpoch,
            pair: pair,
            side: row.side,
            amountLabel: amountLabel,
            gainAmount: net,
            dateLine: _formatTradeDateLine(row.openTime),
            entreeAt: row.openTime,
            sortieAt: row.closeTime,
            breakeven: net == 0,
            avantNews: newsFlags.avantNews,
            apresNews: newsFlags.apresNews,
            quantiteLabel: row.size.toStringAsFixed(2),
            prixEntreeLabel: row.openPrice.toStringAsFixed(5),
            prixSortieLabel: row.closePrice.toStringAsFixed(5),
            checklistPct: discipline.checklistPct,
            planPct: discipline.planPct ?? 0,
            strategiePct: 0,
            etatPct: discipline.etatPct,
            mindset: TradeMindset.none,
            planReport: discipline.planReport,
            strategieTitle: '',
            isProfit: net >= 0,
            assetClass: _assetClassForImportedRow(source, row),
            performanceLite: false,
            portfolioId: portfolioId,
          ),
        );
        existingIds.add(baseId);
      }

      if (pendingImports.isEmpty) {
        if (!context.mounted) return;
        final dupSuffix = skippedCount > 0
            ? l10n.tradeImportDuplicatesOnlySuffix(skippedCount)
            : '';
        final summary = l10n.tradeImportNoneNew(source, dupSuffix);
        _setCsvImportFeedback(summary, isError: true);
        _showCsvImportSnackBar(context, summary, isError: true);
        await logPaychekUserCsvImportEvent(
          software: source,
          status: PaychekCsvImportLogStatus.empty,
          tradeCount: 0,
          skippedDuplicates: skippedCount,
          parsedRowCount: parsedRows.length,
          fileName: file.name,
          message: summary,
        );
        return;
      }

      if (!context.mounted) return;
      final confirmed = await _confirmCsvJournalImport(
        context,
        count: pendingImports.length,
        source: source,
        skippedDuplicates: skippedCount,
        skippedLiteMonthlyCap: skippedLiteMonthlyCap,
      );
      if (!confirmed) {
        if (!context.mounted) return;
        final cancelled = l10n.tradeImportCancelled;
        _setCsvImportFeedback(cancelled, isError: false);
        _showCsvImportSnackBar(context, cancelled);
        return;
      }

      final taggedImports = applySessionMindsetToIncomingTrades(
        existing: store.items,
        incoming: pendingImports,
        rules: _sessionMindsetRules,
        portfolioId: portfolioId,
      );
      for (final item in taggedImports) {
        store.add(item);
        importedCount++;
      }
      if (!context.mounted) return;
      final dupSuffix = skippedCount > 0
          ? (importedCount == 0
              ? l10n.tradeImportDuplicatesOnlySuffix(skippedCount)
              : l10n.tradeImportDuplicatesSuffix(skippedCount))
          : '';
      var summary = importedCount == 0
          ? l10n.tradeImportNoneNew(source, dupSuffix)
          : l10n.tradeImportSummary(importedCount, source, dupSuffix);
      if (skippedLiteMonthlyCap > 0) {
        summary +=
            ' ${l10n.ajouterTradeLiteMonthlyLimitImportSkipped(skippedLiteMonthlyCap, TradeLiteMonthlyLimit.maxTradesPerCalendarMonthNonPro)}';
      }
      _setCsvImportFeedback(summary, isError: importedCount == 0);
      _showCsvImportSnackBar(
        context,
        summary,
        isError: importedCount == 0,
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
      final msg = l10n.tradeImportFailed('$e');
      _setCsvImportFeedback(msg, isError: true);
      _showCsvImportSnackBar(context, msg, isError: true);
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