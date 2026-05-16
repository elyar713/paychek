import '../questionnaire/trading_currency.dart';

/// Identifiant fixe du portefeuille principal (lié au capital global / questionnaire).
const String kDefaultPortfolioId = 'portfolio_1';

/// Libellé par défaut affiché tant que l’utilisateur n’ajoute pas d’autres portefeuilles.
const String kDefaultPortfolioName = 'Portefeuille 1';

/// Portefeuille utilisateur (ex. par broker) : nom + capital + devise.
class UserPortfolio {
  UserPortfolio({
    required this.id,
    required this.name,
    this.capitalAmount,
    this.currencyCode = kDefaultCurrencyCode,
    this.customCurrencyName = '',
    this.customCurrencySymbol = '',
  });

  final String id;
  String name;
  double? capitalAmount;
  String currencyCode;
  String customCurrencyName;
  String customCurrencySymbol;

  bool get isCustomCurrency => currencyCode == kCustomCurrencyCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'capitalAmount': capitalAmount,
        'currencyCode': currencyCode,
        'customCurrencyName': customCurrencyName,
        'customCurrencySymbol': customCurrencySymbol,
      };

  factory UserPortfolio.fromJson(Map<String, dynamic> j) => UserPortfolio(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        capitalAmount: (j['capitalAmount'] as num?)?.toDouble(),
        currencyCode: j['currencyCode'] as String? ?? kDefaultCurrencyCode,
        customCurrencyName: j['customCurrencyName'] as String? ?? '',
        customCurrencySymbol: j['customCurrencySymbol'] as String? ?? '',
      );

  UserPortfolio copyWith({
    String? name,
    double? capitalAmount,
    String? currencyCode,
    String? customCurrencyName,
    String? customCurrencySymbol,
  }) {
    return UserPortfolio(
      id: id,
      name: name ?? this.name,
      capitalAmount: capitalAmount ?? this.capitalAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      customCurrencyName: customCurrencyName ?? this.customCurrencyName,
      customCurrencySymbol: customCurrencySymbol ?? this.customCurrencySymbol,
    );
  }
}
