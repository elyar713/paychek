import 'dart:async' show unawaited;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../reglage/paychek_billing_remote.dart';
import '../reglage/paychek_support_routing.dart';
import 'admin_stripe_checkout_history.dart';
import 'admin_support_send_email.dart';

/// Maquette « panel configuration » (#020203 / cartes #0a0a0b).
class AdminConfigPage extends StatefulWidget {
  const AdminConfigPage({super.key});

  @override
  State<AdminConfigPage> createState() => _AdminConfigPageState();
}

class _AdminConfigPageState extends State<AdminConfigPage>
    with SingleTickerProviderStateMixin {
  static const Color _canvas = Color(0xFF020203);
  static const Color _panel = Color(0xFF0A0A0B);
  static const Color _stripePurple = Color(0xFF635BFF);
  static const Color _emerald = Color(0xFF10B981);
  static const Color _rose = Color(0xFFF43F5E);

  static const String _stripeWebhookEndpoint =
      'https://europe-west1-paychek-trading.cloudfunctions.net/paychekStripeWebhook';

  bool _maintenance = false;
  final _stripePublishableKeyCtrl = TextEditingController();
  final _stripeSecretKeyCtrl = TextEditingController();
  bool _stripeSecretObscured = true;
  final _stripeCheckoutMonthlyCtrl = TextEditingController();
  final _stripeCheckoutQuarterlyCtrl = TextEditingController();
  final _stripeCheckoutAnnualCtrl = TextEditingController();
  bool _stripeBillingEnabled = true;
  bool _stripeBillingLoading = false;
  bool _stripeBillingSaving = false;

  bool _stripeHistoryLoading = false;
  String? _stripeHistoryError;
  List<StripeCheckoutSessionPreview> _stripeHistoryRows = const [];
  bool _stripeHistoryLoaded = false;

  late final AnimationController _syncSpinCtrl;

  @override
  void initState() {
    super.initState();
    _syncSpinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    unawaited(_loadStripeBilling());
    unawaited(_refreshStripeCheckoutHistory());
  }

  @override
  void dispose() {
    _syncSpinCtrl.dispose();
    _stripePublishableKeyCtrl.dispose();
    _stripeSecretKeyCtrl.dispose();
    _stripeCheckoutMonthlyCtrl.dispose();
    _stripeCheckoutQuarterlyCtrl.dispose();
    _stripeCheckoutAnnualCtrl.dispose();
    super.dispose();
  }

  static bool _isHttpsCheckoutUrl(String raw) {
    final t = raw.trim();
    return t.isEmpty || t.startsWith('https://');
  }

  static bool _isStripePublishableKey(String raw) {
    final t = raw.trim();
    return t.isEmpty || RegExp(r'^pk_(test|live)_').hasMatch(t);
  }

  static bool _isStripeSecretKey(String raw) {
    final t = raw.trim();
    return t.isEmpty || RegExp(r'^sk_(test|live)_').hasMatch(t);
  }

  Future<void> _openStripeDashboard() async {
    final uri = Uri.parse('https://dashboard.stripe.com/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openStripeWebhookDocs() async {
    final uri = Uri.parse('https://stripe.com/docs/webhooks');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String href) async {
    final uri = Uri.parse(href);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copyStaffInboxEmail() async {
    await Clipboard.setData(
      ClipboardData(text: kPaychekSupportStaffInboxEmail),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Adresse copiée.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _emailSupportKvRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.76),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailSupportBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Icon(
              Icons.circle,
              size: 6,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.86),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadStripeBilling() async {
    setState(() => _stripeBillingLoading = true);
    try {
      final col = FirebaseFirestore.instance.collection(
        kPaychekAppConfigCollection,
      );
      final results = await Future.wait([
        col.doc(kPaychekBillingDocId).get(),
        col.doc(kPaychekStripeKeysDocId).get(),
      ]);
      if (!mounted) return;
      final billingSnap = results[0];
      final keysSnap = results[1];
      if (billingSnap.exists) {
        final d = billingSnap.data() ?? {};
        _stripeCheckoutMonthlyCtrl.text =
            '${d[kFieldStripeCheckoutUrlMonthly] ?? ''}'.trim();
        _stripeCheckoutQuarterlyCtrl.text =
            '${d[kFieldStripeCheckoutUrlQuarterly] ?? ''}'.trim();
        var annual = '${d[kFieldStripeCheckoutUrlAnnual] ?? ''}'.trim();
        if (annual.isEmpty) {
          annual = '${d[kFieldStripeCheckoutUrl] ?? ''}'.trim();
        }
        _stripeCheckoutAnnualCtrl.text = annual;
        final en = d[kFieldStripeBillingEnabled];
        _stripeBillingEnabled = en is! bool || en == true;
      }
      if (keysSnap.exists) {
        final k = keysSnap.data() ?? {};
        _stripePublishableKeyCtrl.text =
            '${k[kFieldStripePublishableKey] ?? ''}'.trim();
        _stripeSecretKeyCtrl.text =
            '${k[kFieldStripeSecretKey] ?? ''}'.trim();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lecture facturation Firestore : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _stripeBillingLoading = false);
    }
  }

  Future<void> _saveStripeBilling() async {
    final monthly = _stripeCheckoutMonthlyCtrl.text.trim();
    final quarterly = _stripeCheckoutQuarterlyCtrl.text.trim();
    final annual = _stripeCheckoutAnnualCtrl.text.trim();
    final pk = _stripePublishableKeyCtrl.text.trim();
    final sk = _stripeSecretKeyCtrl.text.trim();
    for (final entry in [
      ('Mensuel', monthly),
      ('Trimestriel', quarterly),
      ('Annuel', annual),
    ]) {
      if (!_isHttpsCheckoutUrl(entry.$2)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lien ${entry.$1} : doit commencer par https://',
              ),
            ),
          );
        }
        return;
      }
    }
    if (_stripeBillingEnabled &&
        monthly.isEmpty &&
        quarterly.isEmpty &&
        annual.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Renseigne au moins un Payment Link Stripe (mensuel, '
              'trimestriel ou annuel).',
            ),
          ),
        );
      }
      return;
    }
    if (!_isStripePublishableKey(pk)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clé publique : format pk_test_… ou pk_live_…'),
          ),
        );
      }
      return;
    }
    if (!_isStripeSecretKey(sk)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clé secrète : format sk_test_… ou sk_live_…'),
          ),
        );
      }
      return;
    }
    setState(() => _stripeBillingSaving = true);
    try {
      final col = FirebaseFirestore.instance.collection(
        kPaychekAppConfigCollection,
      );
      final now = Timestamp.now();
      await Future.wait([
        col.doc(kPaychekBillingDocId).set(
          {
            kFieldStripeCheckoutUrlMonthly: monthly,
            kFieldStripeCheckoutUrlQuarterly: quarterly,
            kFieldStripeCheckoutUrlAnnual: annual,
            kFieldStripeCheckoutUrl: annual,
            kFieldStripeBillingEnabled: _stripeBillingEnabled,
            'updatedAt': now,
          },
          SetOptions(merge: true),
        ),
        col.doc(kPaychekStripeKeysDocId).set(
          {
            kFieldStripePublishableKey: pk,
            kFieldStripeSecretKey: sk,
            'updatedAt': now,
          },
          SetOptions(merge: true),
        ),
      ]);
      PaychekBillingRemote.invalidateCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stripe / paywall : configuration enregistrée.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur enregistrement : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _stripeBillingSaving = false);
    }
  }

  Future<void> _refreshStripeCheckoutHistory() async {
    setState(() {
      _stripeHistoryLoading = true;
      _stripeHistoryError = null;
    });
    final result = await paychekAdminListStripeCheckoutSessions(limit: 25);
    if (!mounted) return;
    setState(() {
      _stripeHistoryLoading = false;
      _stripeHistoryLoaded = true;
      _stripeHistoryRows = result.sessions;
      _stripeHistoryError = result.errorMessage;
    });
  }

  TextStyle _labelMicro(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: color,
      );

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      );

  InputDecoration _monoFieldDecoration({String? hint}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    );
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.4),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _emerald.withValues(alpha: 0.4)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.42),
      ),
    );
  }

  Widget _pillToggle({
    required bool value,
    required ValueChanged<bool>? onChanged,
    required Color activeColor,
  }) {
    final enabled = onChanged != null;
    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: value
              ? activeColor
              : const Color(0xFF1E293B),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _webhookBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _emerald.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _emerald.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_outlined, size: 14, color: _emerald),
          const SizedBox(width: 6),
          Text(
            'WEBHOOK',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: _emerald,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stripePaymentLinkField({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String hint,
  }) {
    return _StripePaymentLinkField(
      title: title,
      subtitle: subtitle,
      controller: controller,
      hint: hint,
      enabled: !_stripeBillingSaving,
      decoration: _monoFieldDecoration,
    );
  }

  Widget _billingCard({
    required DateFormat dfPay,
  }) {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _stripePurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.credit_card_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Facturation',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Dashboard Stripe',
                  onPressed: _openStripeDashboard,
                  icon: Icon(Icons.open_in_new_rounded,
                      color: Colors.white.withValues(alpha: 0.65), size: 20),
                ),
                IconButton(
                  tooltip: 'Documentation webhooks',
                  onPressed: _openStripeWebhookDocs,
                  icon: Icon(Icons.description_outlined,
                      color: Colors.white.withValues(alpha: 0.65), size: 20),
                ),
                _webhookBadge(),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'ENDPOINT HTTPS',
              style: _labelMicro(Colors.white.withValues(alpha: 0.72)),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _stripeWebhookEndpoint,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                height: 1.45,
                color: _emerald,
              ),
            ),
            const SizedBox(height: 22),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 22),
            Text(
              'Clé publique Stripe',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'pk_test_… ou pk_live_… — stockée dans Firestore (accès admin).',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            if (_stripeBillingLoading)
              const SizedBox(height: 48)
            else
              TextField(
                controller: _stripePublishableKeyCtrl,
                enabled: !_stripeBillingSaving,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: const Color(0xFFCBD5E1),
                ),
                decoration: _monoFieldDecoration(
                  hint: 'pk_live_xxxxxxxxxxxxxxxxxxxxxxxx',
                ),
              ),
            const SizedBox(height: 18),
            Text(
              'Clé secrète Stripe',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'sk_test_… ou sk_live_… — document admin uniquement. '
              'Pour les webhooks, copiez aussi dans le secret Firebase '
              'PAYCHEK_STRIPE_SECRET_KEY.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            if (_stripeBillingLoading)
              const SizedBox(height: 48)
            else
              TextField(
                controller: _stripeSecretKeyCtrl,
                enabled: !_stripeBillingSaving,
                obscureText: _stripeSecretObscured,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: const Color(0xFFCBD5E1),
                ),
                decoration: _monoFieldDecoration(
                  hint: 'Coller la clé secrète Stripe (sk_test_… ou sk_live_…)',
                ).copyWith(
                  suffixIcon: IconButton(
                    tooltip: _stripeSecretObscured
                        ? 'Afficher'
                        : 'Masquer',
                    onPressed: () => setState(
                      () => _stripeSecretObscured = !_stripeSecretObscured,
                    ),
                    icon: Icon(
                      _stripeSecretObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white.withValues(alpha: 0.45),
                      size: 20,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 22),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 22),
            Text(
              'Payment Links Stripe',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Un lien buy.stripe.com par tarif (mensuel 8,99 \$ · '
              'trimestriel 20,97 \$ · annuel 59,99 \$).',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 14),
            if (_stripeBillingLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _emerald,
                    ),
                  ),
                ),
              )
            else ...[
              _stripePaymentLinkField(
                title: 'Mensuel',
                subtitle: '8,99 \$ / mois',
                controller: _stripeCheckoutMonthlyCtrl,
                hint: 'https://buy.stripe.com/…',
              ),
              const SizedBox(height: 14),
              _stripePaymentLinkField(
                title: 'Trimestriel',
                subtitle: '20,97 \$ / 3 mois',
                controller: _stripeCheckoutQuarterlyCtrl,
                hint: 'https://buy.stripe.com/…',
              ),
              const SizedBox(height: 14),
              _stripePaymentLinkField(
                title: 'Annuel',
                subtitle: '59,99 \$ / an',
                controller: _stripeCheckoutAnnualCtrl,
                hint: 'https://buy.stripe.com/…',
              ),
              const SizedBox(height: 18),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Paiement activé',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _pillToggle(
                    value: _stripeBillingEnabled,
                    onChanged: _stripeBillingSaving
                        ? null
                        : (v) => setState(() => _stripeBillingEnabled = v),
                    activeColor: _emerald,
                  ),
                ],
              ),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton(
                    onPressed: _stripeBillingSaving
                        ? null
                        : () => unawaited(_saveStripeBilling()),
                    style: FilledButton.styleFrom(
                      backgroundColor: _emerald,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _stripeBillingSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'Enregistrer dans Firestore',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_stripeBillingLoading || _stripeBillingSaving)
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _emerald.withValues(alpha: 0.55),
                            ),
                          )
                        else
                          RotationTransition(
                            turns: _syncSpinCtrl,
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: _emerald.withValues(alpha: 0.55),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _stripeBillingSaving
                              ? 'Enregistrement…'
                              : (_stripeBillingLoading
                                  ? 'Chargement…'
                                  : 'Synchronisé'),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: _emerald.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(
                  'Référence secrets & déploiement',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                iconColor: Colors.white.withValues(alpha: 0.45),
                collapsedIconColor: Colors.white.withValues(alpha: 0.45),
                children: [
                  const SizedBox(height: 8),
                  _ConfigStripeRow(
                    label: 'Clés Firestore',
                    value:
                        'paychek_app_config/stripe_keys (champs ci-dessus).',
                  ),
                  const SizedBox(height: 8),
                  _ConfigStripeRow(
                    label: 'Secret Functions',
                    value:
                        'firebase functions:secrets:set PAYCHEK_STRIPE_SECRET_KEY '
                        '(même sk que ci-dessus pour les webhooks).',
                  ),
                  const SizedBox(height: 8),
                  _ConfigStripeRow(
                    label: 'Webhook signing secret',
                    value:
                        'Secret PAYCHEK_STRIPE_WEBHOOK_SECRET (whsec_… du endpoint).',
                  ),
                  const SizedBox(height: 8),
                  _ConfigStripeRow(
                    label: 'URL checkout (priorités)',
                    value:
                        '1) dart-define PAYCHEK_STRIPE_CHECKOUT_URL_*  '
                        '2) Firestore stripeCheckoutUrlMonthly|Quarterly|Annual.',
                  ),
                  const SizedBox(height: 8),
                  _ConfigStripeRow(
                    label: 'Deploy Functions',
                    value:
                        'firebase deploy --only functions:sendStaffSupportEmail,'
                        'functions:notifyStaffOnSupportTicketCreated,functions:paychekStripeWebhook,'
                        'functions:syncPaychekStripeEntitlement,functions:adminSyncPaychekStripeEntitlement,'
                        'functions:adminListStripeCheckoutSessions',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Icon(Icons.insights_outlined,
                    size: 16, color: Colors.white.withValues(alpha: 0.55)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'HISTORIQUE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Actualiser depuis Stripe',
                  onPressed:
                      _stripeHistoryLoading ? null : _refreshStripeCheckoutHistory,
                  icon: _stripeHistoryLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _emerald,
                          ),
                        )
                      : Icon(Icons.refresh_rounded,
                          color: Colors.white.withValues(alpha: 0.65)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_stripeHistoryError != null &&
                _stripeHistoryError!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SelectableText(
                  _stripeHistoryError!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    height: 1.35,
                    color: _rose,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.all(8),
              child: Builder(
                builder: (context) {
                  if (_stripeHistoryLoading && !_stripeHistoryLoaded) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _emerald,
                          ),
                        ),
                      ),
                    );
                  }
                  if (_stripeHistoryRows.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 8,
                      ),
                      child: Text(
                        _stripeHistoryError != null &&
                                _stripeHistoryError!.trim().isNotEmpty
                            ? 'Corrige l’erreur ci-dessus puis réessaie.'
                            : 'Aucune session dans cette liste.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                    );
                  }

                  Color rowStatusColor(String label) {
                    final t = label.trim().toLowerCase();
                    if (t == 'réussi') return _emerald;
                    if (t.contains('non pay') || t == 'expirée') return _rose;
                    return Colors.white.withValues(alpha: 0.62);
                  }

                  return Column(
                    children: [
                      for (var i = 0; i < _stripeHistoryRows.length; i++)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            hoverColor: Colors.white.withValues(alpha: 0.05),
                            onTap: _openStripeDashboard,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _stripeHistoryRows[i].idDisplay,
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 11,
                                            color:
                                                Colors.white.withValues(alpha: 0.62),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (_stripeHistoryRows[i]
                                            .email
                                            .trim()
                                            .isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              _stripeHistoryRows[i].email,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                color: Colors.white
                                                    .withValues(alpha: 0.55),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      formatStripeMajorCurrency(
                                        _stripeHistoryRows[i].amountMajor,
                                        _stripeHistoryRows[i].currencyCode,
                                      ),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _stripeHistoryRows[i].statusLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: rowStatusColor(
                                          _stripeHistoryRows[i].statusLabel,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      dfPay.format(_stripeHistoryRows[i]
                                          .createdAtUtc
                                          .toLocal()),
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.62),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailSupportCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: _emerald.withValues(alpha: 0.12)),
                  ),
                  child:
                      Icon(Icons.mail_outline_rounded, color: _emerald, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  'E-mail support',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                iconColor: Colors.white.withValues(alpha: 0.65),
                collapsedIconColor: Colors.white.withValues(alpha: 0.5),
                title: Text(
                  'Configuration e-mail & Functions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    kPaychekSupportStaffInboxEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
                childrenPadding: const EdgeInsets.only(top: 4, bottom: 2),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    alignment: Alignment.center,
                    child: SelectableText(
                      kPaychekSupportStaffInboxEmail,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => unawaited(_copyStaffInboxEmail()),
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        label: Text(
                          'Copier l’adresse',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFCBD5E1),
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            unawaited(_openUrl('https://resend.com/docs')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFCBD5E1),
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Docs Resend',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            unawaited(_openUrl('https://resend.com/domains')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFCBD5E1),
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Domaines',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            unawaited(_openUrl('https://resend.com/api-keys')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFCBD5E1),
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Clés API',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => unawaited(_openUrl(
                            'https://firebase.google.com/docs/functions/config-env')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFCBD5E1),
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Secrets / env Firebase',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'CLOUD FUNCTIONS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _emailSupportKvRow('Région', kPaychekSupportFunctionsRegion),
                  _emailSupportKvRow(
                    'Callables',
                    'sendStaffSupportEmail · '
                        'notifyStaffOnSupportTicketCreated',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'À COORDONNER',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _emailSupportBullet(
                    '`staffNotifyEmail` et `PAYCHEK_MAIL_BCC` : même adresse '
                    'que la boîte ci‑dessus (cf. `firestore.rules`).',
                  ),
                  _emailSupportBullet(
                    '`PAYCHEK_MAIL_FROM` : expéditeur sur un domaine '
                    'vérifié dans Resend.',
                  ),
                  _emailSupportBullet(
                    '`PAYCHEK_RESEND_API_KEY` : envoi principal si vous passez '
                    'par l’API Resend.',
                  ),
                  _emailSupportBullet(
                    '`PAYCHEK_SMTP_PASSWORD` : secours SMTP si configuré côté '
                    'Functions.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _maintenanceCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _rose.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _rose.withValues(alpha: 0.12)),
                  ),
                  child: Icon(Icons.power_settings_new_rounded,
                      color: _rose, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  'Maintenance',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: _maintenance
                            ? _rose
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                      child: Text(_maintenance ? 'ACTIVÉ' : 'DÉSACTIVÉ'),
                    ),
                  ),
                  _pillToggle(
                    value: _maintenance,
                    onChanged: (v) {
                      setState(() => _maintenance = v);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            v
                                ? 'Maintenance ON (stub — Remote Config / Firestore)'
                                : 'Maintenance OFF',
                          ),
                        ),
                      );
                    },
                    activeColor: _rose,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dfPay = DateFormat.yMMMd('fr_FR');

    return ColoredBox(
      color: _canvas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1024;
                final billing = _billingCard(
                  dfPay: dfPay,
                );
                final rightColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _emailSupportCard(),
                    const SizedBox(height: 22),
                    _maintenanceCard(),
                  ],
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: billing),
                          const SizedBox(width: 22),
                          Expanded(flex: 5, child: rightColumn),
                        ],
                      )
                    else ...[
                      billing,
                      const SizedBox(height: 22),
                      rightColumn,
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StripePaymentLinkField extends StatelessWidget {
  const _StripePaymentLinkField({
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.hint,
    required this.enabled,
    required this.decoration,
  });

  final String title;
  final String subtitle;
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final InputDecoration Function({String? hint}) decoration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: const Color(0xFFCBD5E1),
          ),
          maxLines: 2,
          decoration: decoration(hint: hint),
        ),
      ],
    );
  }
}

class _ConfigStripeRow extends StatelessWidget {
  const _ConfigStripeRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 148,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
      ],
    );
  }
}
