// ignore_for_file: avoid_print — petit CLI local

import 'dart:convert';
import 'dart:io';

void main() {
  final en = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
      as Map<String, dynamic>;
  final keys = en.keys
      .where((k) => !k.startsWith('@') && k != '@@locale' && en[k] is String)
      .toList()
    ..sort();
  for (final k in keys) {
    print(k);
  }
  print('__COUNT__ ${keys.length}');
}
