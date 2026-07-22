import 'package:shared_preferences/shared_preferences.dart';

/// Marque une édition locale avant le push cloud (évite qu’un snapshot
/// encore « vieux » écrase la mémoire pendant le debounce).
Future<void> paychekBumpLocalSyncRev(String prefsKey) async {
  final p = await SharedPreferences.getInstance();
  final local = p.getInt(prefsKey) ?? 0;
  final now = DateTime.now().microsecondsSinceEpoch;
  final next = now > local ? now : local + 1;
  await p.setInt(prefsKey, next);
}
