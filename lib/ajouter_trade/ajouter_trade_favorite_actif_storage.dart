import 'package:shared_preferences/shared_preferences.dart';

import 'ajouter_trade_asset_class.dart';
import '../reglage/paychek_prefs_scope.dart';

/// Un actif « étoile » par marché : proposé par défaut au prochain enregistrement.
abstract final class AjouterTradeFavoriteActifStorage {
  AjouterTradeFavoriteActifStorage._();

  static String _key(AjouterTradeAssetClass c) =>
      paychekScopedPrefsKey('ajouter_trade_fav_actif_${c.name}');

  static Future<Map<AjouterTradeAssetClass, String>> loadAll() async {
    final p = await SharedPreferences.getInstance();
    final out = <AjouterTradeAssetClass, String>{};
    for (final e in AjouterTradeAssetClass.values) {
      final v = p.getString(_key(e));
      if (v != null && v.trim().isNotEmpty) {
        out[e] = v.trim();
      }
    }
    return out;
  }

  static Future<void> save(AjouterTradeAssetClass marche, String symbol) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key(marche), symbol.trim());
  }

  static Future<void> clear(AjouterTradeAssetClass marche) async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key(marche));
  }
}
