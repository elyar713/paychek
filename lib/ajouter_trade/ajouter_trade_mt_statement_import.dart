/// Import de relevés MT / brokers (HTML, CSV, XLSX) vers [MtStatementTradeRow].
///
/// Découpage en `part` : fichiers d’environ ≤ 300 lignes.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../trade/trade_models.dart';
import 'ajouter_trade_atas_xlsx_zip.dart';

part 'ajouter_trade_mt_statement_part01_models_mt45.dart';
part 'ajouter_trade_mt_statement_part02_ctrader.dart';
part 'ajouter_trade_mt_statement_part03_mt5xlsx_fifo.dart';
part 'ajouter_trade_mt_statement_part04_tradingview_csv.dart';
part 'ajouter_trade_mt_statement_part05_tradovate.dart';
part 'ajouter_trade_mt_statement_part06_quantower.dart';
part 'ajouter_trade_mt_statement_part07_rithmic_ninja.dart';
part 'ajouter_trade_mt_statement_part08_atas_columns.dart';
part 'ajouter_trade_mt_statement_part09_atas_parse_csv.dart';
part 'ajouter_trade_mt_statement_part10_futures_mt5rows.dart';
part 'ajouter_trade_mt_statement_part11_parse_helpers.dart';
