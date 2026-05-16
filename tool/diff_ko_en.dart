// ignore_for_file: avoid_print — petit CLI local

import 'dart:convert';
import 'dart:io';

void main() {
  final en = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
      as Map<String, dynamic>;
  final ko = jsonDecode(File('lib/l10n/app_ko.arb').readAsStringSync())
      as Map<String, dynamic>;
  for (final k in en.keys) {
    if (k.startsWith('@') || k == '@@locale') continue;
    final ev = en[k];
    final kv = ko[k];
    if (ev is String && kv is String && ev == kv) {
      print(k);
    }
  }
}
