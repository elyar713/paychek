import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app_finder/ajouter_trade/ajouter_trade_mt_statement_import.dart';
import 'package:mon_app_finder/trade/trade_models.dart';

void main() {
  group('parseTradovateOrdersCsv', () {
    test('TradeTally-style Orders.csv (Filled Qty, Avg Fill Price, Buy/Sell)', () {
      const csv = '''
orderId,Account,Contract,Product,Product Description,Status,B/S,Filled Qty,Avg Fill Price,Fill Time,Text
12345,DEMO,MESZ5,MES,Micro E-mini S&P 500,Filled,Buy,2,5025.50,11/25/2025 04:38:24,
12346,DEMO,MESZ5,MES,Micro E-mini S&P 500,Filled,Sell,2,5030.25,11/25/2025 05:12:10,Exit
''';
      final rows = parseTradovateOrdersCsv(csv);
      expect(rows, hasLength(1));
      expect(rows.first.side, TradeSide.achat);
      expect(rows.first.symbol, 'MESZ5');
      expect(rows.first.size, 2);
    });

    test('duplicate price columns: empty avgPrice, filled Avg Fill Price', () {
      const csv = '''
orderId,Account,Order ID,B/S,Contract,Product,avgPrice,filledQty,Fill Time,Status,Filled Qty,Avg Fill Price
1,ACC,1,Buy,MESZ5,MES,,,11/25/2025 04:38:24,Filled,1,5025.50
2,ACC,2,Sell,MESZ5,MES,,,11/25/2025 05:12:10,Filled,1,5030.25
''';
      final rows = parseTradovateOrdersCsv(csv);
      expect(rows, hasLength(1));
      expect(rows.first.openPrice, 5025.50);
      expect(rows.first.closePrice, 5030.25);
    });

    test('B/S single letter B and S', () {
      const csv = '''
orderId,Contract,Product,Status,B/S,Filled Qty,Avg Fill Price,Fill Time
1,MNQZ5,MNQ,Filled,B,1,21000,12/01/2025 09:00:00
2,MNQZ5,MNQ,Filled,S,1,21010,12/01/2025 10:00:00
''';
      final rows = parseTradovateOrdersCsv(csv);
      expect(rows, hasLength(1));
    });

    test('Performance.csv round-trips (user export)', () {
      const csv = '''
symbol,_priceFormat,_priceFormatType,_tickSize,buyFillId,sellFillId,qty,buyPrice,sellPrice,pnl,boughtTimestamp,soldTimestamp,duration
MNQM6,-2,0,0.25,518233460290,518233460341,1,30339.00,30302.25,\$(73.50),05/29/2026 08:22:58,05/29/2026 09:22:38,59min 40sec
MNQM6,-2,0,0.25,518233460353,518233460404,1,30303.50,30315.75,\$24.50,05/29/2026 10:10:28,05/29/2026 14:23:03,4h 12min 34sec
MNQM6,-2,0,0.25,518233460514,518233460471,1,30304.75,30282.50,\$(44.50),05/29/2026 16:48:20,05/29/2026 16:45:04,3min 15sec
''';
      final rows = parseTradovateImportCsv(csv);
      expect(rows, hasLength(3));
      expect(rows.first.profit, closeTo(-73.50, 0.01));
      expect(rows[1].profit, closeTo(24.50, 0.01));
      expect(rows.last.side, TradeSide.vente);
      expect(rows.last.openTime.isBefore(rows.last.closeTime), isTrue);
    });

    test('semicolon delimiter', () {
      const csv = '''
orderId;Contract;Status;B/S;Filled Qty;Avg Fill Price;Fill Time
1;MESZ5;Filled;Buy;1;5000;11/25/2025 04:38:24
2;MESZ5;Filled;Sell;1;5010;11/25/2025 05:12:10
''';
      final rows = parseTradovateOrdersCsv(csv);
      expect(rows, hasLength(1));
    });
  });
}
