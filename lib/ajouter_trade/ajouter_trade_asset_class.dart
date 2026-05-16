/// Classe d’instrument au-dessus de Actif / Quantité ([AjouterTradePage]).
enum AjouterTradeAssetClass {
  forex,
  indice,
  future,
  crypto,
  stock,
  matieresPremieres,
}

extension AjouterTradeAssetClassLabel on AjouterTradeAssetClass {
  String get label {
    switch (this) {
      case AjouterTradeAssetClass.forex:
        return 'Forex';
      case AjouterTradeAssetClass.indice:
        return 'Indice';
      case AjouterTradeAssetClass.future:
        return 'Future';
      case AjouterTradeAssetClass.crypto:
        return 'Crypto';
      case AjouterTradeAssetClass.stock:
        return 'Stock';
      case AjouterTradeAssetClass.matieresPremieres:
        return 'Como';
    }
  }
}
