import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';

/// Politique de confidentialité (texte type standard ; FR / EN selon la langue de l’app).
class ReglagePrivacyPolicyPage extends StatelessWidget {
  const ReglagePrivacyPolicyPage({super.key});

  static bool _useFrench(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'fr';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fr = _useFrench(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.settingsPrivacyPageTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settingsPrivacyDocHeading,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: DashboardTokens.onMatteEmphasis,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              ..._blocks(fr).map(
                (b) => _block(b.$1, b.$2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<(String, String)> _blocks(bool fr) {
    if (fr) {
      return _kFr;
    }
    return _kEn;
  }

  static const List<(String, String)> _kFr = [
    (
      '1. Responsable du traitement',
      'L’application Paychek (« le Service ») est éditée par son responsable de traitement des données personnelles. Pour toute question relative à la présente politique ou à vos données, vous pouvez nous contacter via les canaux indiqués dans l’application (aide / support).',
    ),
    (
      '2. Données collectées',
      'Nous pouvons collecter et traiter notamment : les données de compte et d’authentification (adresse e-mail, identifiant fournisseur de connexion) ; les données que vous saisissez dans l’application (journaux de trading, analyses, préférences d’affichage) ; des données techniques et d’usage (type d’appareil, système, journaux d’erreurs limités) dans la mesure nécessaire au fonctionnement et à la sécurité du Service.',
    ),
    (
      '3. Finalités',
      'Vos données sont utilisées pour : fournir et améliorer le Service ; assurer la synchronisation et la sauvegarde de vos contenus ; gérer l’abonnement ou l’accès aux fonctionnalités ; assurer la sécurité, prévenir la fraude et respecter nos obligations légales ; communiquer des informations relatives au Service lorsque cela est pertinent.',
    ),
    (
      '4. Base légale',
      'Le traitement repose notamment sur : l’exécution du contrat (fourniture du Service) ; votre consentement lorsque la loi l’exige (par ex. certaines communications) ; l’intérêt légitime (sécurité, amélioration du produit, mesures techniques proportionnées) ; le respect d’obligations légales le cas échéant.',
    ),
    (
      '5. Durée de conservation',
      'Les données sont conservées pendant la durée nécessaire aux finalités décrites, puis archivées ou supprimées selon des délais compatibles avec la loi et nos obligations comptables ou probatoires. Certaines données peuvent être conservées plus longtemps en cas de litige ou de réclamation, dans la limite autorisée.',
    ),
    (
      '6. Sous-traitants et transferts',
      'Nous pouvons faire appel à des prestataires techniques dûment qualifiés (hébergement, authentification, bases de données, analytique limitée) situés dans l’Union européenne et/ou hors UE. Le cas échéant, des garanties appropriées (clauses types, mesures complémentaires) sont mises en œuvre conformément au RGPD.',
    ),
    (
      '7. Vos droits',
      'Conformément au RGPD, vous disposez d’un droit d’accès, de rectification, d’effacement, de limitation du traitement, d’opposition, de portabilité lorsque applicable, ainsi que du droit de retirer votre consentement à tout moment lorsque le traitement est fondé sur celui-ci. Vous pouvez introduire une réclamation auprès de l’autorité de contrôle compétente (en France : la CNIL).',
    ),
    (
      '8. Sécurité',
      'Nous mettons en œuvre des mesures techniques et organisationnelles raisonnables pour protéger vos données contre la perte, l’accès non autorisé ou la divulgation. Aucun système n’étant infaillible, nous vous invitons à sécuriser votre compte (mot de passe fort, déconnexion sur appareils partagés).',
    ),
    (
      '9. Mineurs',
      'Le Service ne s’adresse pas aux mineurs de moins de 16 ans (ou l’âge requis par la loi applicable). Nous ne collectons pas sciemment de données les concernant.',
    ),
    (
      '10. Modifications',
      'Nous pouvons mettre à jour la présente politique pour refléter l’évolution du Service ou des obligations légales. La date de mise à jour peut être précisée dans l’application ou sur notre site. L’usage continu du Service vaut acceptation des changements substantiels lorsque la loi le permet.',
    ),
  ];

  static const List<(String, String)> _kEn = [
    (
      '1. Data controller',
      'The Paychek application (“the Service”) is operated by its data controller. For questions about this policy or your data, contact us through the in‑app channels (help / support).',
    ),
    (
      '2. Data we collect',
      'We may collect and process: account and authentication data (email address, sign‑in provider identifier); data you enter in the app (trading logs, analyses, display preferences); limited technical and usage data (device type, OS, error logs) as needed to run and secure the Service.',
    ),
    (
      '3. Purposes',
      'We use your data to: provide and improve the Service; sync and back up your content; manage subscription or access to features; maintain security, prevent fraud, and meet legal obligations; send Service‑related communications when appropriate.',
    ),
    (
      '4. Legal bases',
      'Processing relies on: performance of a contract (providing the Service); consent where required by law; legitimate interests (security, product improvement, proportionate technical measures); legal obligations where applicable.',
    ),
    (
      '5. Retention',
      'We keep data for as long as needed for the purposes described, then archive or delete it in line with law and any accounting or evidence requirements. Some data may be kept longer in case of disputes or claims, within legal limits.',
    ),
    (
      '6. Processors and transfers',
      'We may use qualified technical subprocessors (hosting, authentication, databases, limited analytics) in the EU and/or outside the EU. Where required, appropriate safeguards (e.g. standard contractual clauses) are applied in line with the GDPR.',
    ),
    (
      '7. Your rights',
      'Under the GDPR you may have rights of access, rectification, erasure, restriction, objection, portability where applicable, and to withdraw consent at any time when processing is consent‑based. You may lodge a complaint with your local supervisory authority.',
    ),
    (
      '8. Security',
      'We apply reasonable technical and organisational measures to protect your data against loss, unauthorised access, or disclosure. No system is perfect; please protect your account (strong password, sign out on shared devices).',
    ),
    (
      '9. Children',
      'The Service is not directed at children under 16 (or the age required by applicable law). We do not knowingly collect data from them.',
    ),
    (
      '10. Changes',
      'We may update this policy to reflect changes to the Service or legal requirements. An updated date may be shown in the app or on our site. Continued use may constitute acceptance of material changes where permitted by law.',
    ),
  ];

  static Widget _block(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DashboardTokens.onMatteEmphasis,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DashboardTokens.labelGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
