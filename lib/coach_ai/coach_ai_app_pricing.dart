import '../l10n/app_localizations.dart';
import 'coach_ai_response_format.dart';

/// Tarifs / abonnements PAYCHEK — intention coach + faits JSON (réponse cloud structurée).
abstract final class CoachAiAppPricing {
  static bool isPricingQuestion(String question) {
    final q = question.toLowerCase().trim();
    if (q.isEmpty) return false;

    if (RegExp(
      r'prix d.?entr|prix de sortie|entry price|exit price|take profit|stop loss|'
      r'\btp\b|\bsl\b|lot\b|paire\b|eur/usd|position\b',
    ).hasMatch(q)) {
      return false;
    }

    final pricingIntent = RegExp(
      r'prix|tarif|tarifs|co[uû]te|combien|pricing|subscription|abonnement|'
      r'upgrade|formule|paywall|essai|trial|lite|pro\b|premium|gratuit|free plan',
    ).hasMatch(q);
    if (!pricingIntent) return false;

    return RegExp(
      r'app|appli|application|paychek|abonnement|upgrade|formule|essai|trial|'
      r'lite|pro\b|premium|gratuit|cette appli|this app|the app|l.app|l.appli|'
      r'souscrire|subscribe|site web|website',
    ).hasMatch(q);
  }

  static String cardTitle(String languageCode) {
    return switch (languageCode) {
      'en' => 'PAYCHEK pricing',
      'de' => 'PAYCHEK Preise',
      'es' => 'Precios PAYCHEK',
      _ => 'Tarifs PAYCHEK',
    };
  }

  static String cardSubtitle(String languageCode) {
    return switch (languageCode) {
      'en' => ' · subscriptions',
      'de' => ' · Abonnements',
      'es' => ' · suscripciones',
      _ => ' · abonnements',
    };
  }

  /// Faits officiels pour le coach (ne pas recopier mot pour mot — adapter à la question).
  static Map<String, dynamic> contextToJson(
    AppLocalizations l10n,
    String languageCode,
  ) {
    return <String, dynamic>{
      'coachInstructions': CoachAiResponseFormat.pricingInstructions(languageCode),
      'currency': 'USD',
      'billingProvider': 'Stripe',
      'autoRenewUntilCancelled': true,
      'trialDaysNewAccount': 7,
      'plans': <String, dynamic>{
        'lite': <String, dynamic>{
          'name': l10n.paywallPlanLiteName,
          'afterTrial': true,
          'highlights': <String>[
            l10n.paywallLiteFeature1,
            l10n.paywallLiteFeature2,
            l10n.paywallLiteFeature3,
          ],
          'limitedHint': l10n.paywallLiteLimitedHint,
        },
        'pro': <String, dynamic>{
          'name': l10n.paywallPlanProName,
          'monthlyUsd': 8.99,
          'quarterlyUsd': 20.97,
          'annualUsd': 59.99,
          'annualLabel': l10n.paywallPriceAnnualHighlight,
          'annualApproxPerMonth': l10n.paywallPriceApproxPerMonth,
          'highlights': <String>[
            l10n.paywallProFeature1,
            l10n.paywallProFeature2,
            l10n.paywallProFeature3,
            l10n.paywallProFeature4,
            l10n.paywallProFeature5,
            l10n.paywallProFeature6,
            l10n.paywallProFeature7,
            l10n.paywallProFeature8,
            l10n.paywallProFeature9,
          ],
        },
      },
      'partnerOfferNote': languageCode == 'fr'
          ? 'Accès Pro possible via partenaire (Prop Firm / Broker) si conditions de parrainage remplies.'
          : 'Pro access may be granted via partner referral (Prop Firm / Broker) when conditions are met.',
      'subscribeInApp': <String>[
        if (languageCode == 'fr') ...<String>[
          'Bouton Upgrade (accueil / hero)',
          'Plus → Réglages → Compte → ${l10n.profileManageSubscriptionButton}',
        ] else ...<String>[
          'Upgrade button (home hero)',
          'Plus → Settings → Account → ${l10n.profileManageSubscriptionButton}',
        ],
      ],
      'legalReference': l10n.settingsCgvRowTitle,
      'cgvPricingExcerpt': l10n.settingsCgv3Body,
    };
  }
}
