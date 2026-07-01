import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app_finder/ajouter_trade/ajouter_trade_mt_statement_import.dart';
import 'package:mon_app_finder/trade/trade_models.dart';

void main() {
  test('French paper TradingView export (Quantité column) yields closed trades', () {
    final csv = File('test/fixtures/tradingview_paper_fr_sample.csv')
        .readAsStringSync();
    final rows = parseTradingViewOrdersCsv(csv);
    expect(rows.length, greaterThanOrEqualTo(2));
    expect(rows.first.symbol, 'MNQ1!');
    expect(rows.first.side, TradeSide.achat);
    expect(rows.first.size, greaterThan(0));
  });
}
