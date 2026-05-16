import 'dart:async' show StreamSubscription, Timer, unawaited;
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../widgets/paychek_page_header.dart';
import '../widgets/paychek_minimal_upgrade_button.dart';
import '../web/paychek_web_tokens.dart';
import 'paychek_gold_upgrade_sheet.dart';
import 'paychek_user_firestore.dart';
import 'reglage_profile_prefs.dart';
import 'subscription_launch_helper.dart';
import 'trial_access_prefs.dart'
    show
        AccountEntitlementSnapshot,
        TrialAccessPrefs,
        kPaychekSubscriberEntitlementsCollection,
        kPaychekTrialDuration;
import 'user_profile_scope.dart';

const Color _kBrandTeal = Color(0xFF1EB48A);
const Color _kMobileCardSurface = Color(0xFF161618);
const Color _kMobileFieldBorder = Color(0xFF2C2C30);

/// Largeur utile centrée pour la maquette « Compte » web.
const double _kWebAccountMaxWidth = 440;
const Color _kMonoBg = Color(0xFF000000);
const Color _kMonoMuted = Color(0xFF9E9E9E);

/// Bouton souscription une fois client **Pro** (neutre, moins voyant que le CTA teal).
const Color _kSubscribeButtonProBg = Color(0xFF2E2E32);
const Color _kSubscribeButtonProFg = Color(0xFFB0B0B4);

/// Compte inscrit : affichage du profil (sans onglets connexion / inscription).
class ReglageProfileViewPage extends StatefulWidget {
  const ReglageProfileViewPage({
    super.key,
    required this.profile,
    this.embeddedInReglageOverlay = false,
    this.onBack,
    this.initialEntitlement,
  });

  final ReglageProfileData profile;
  final bool embeddedInReglageOverlay;
  final VoidCallback? onBack;

  /// Données déjà connues (ex. depuis [ReglagePage]) pour afficher le statut sans attendre le réseau.
  final AccountEntitlementSnapshot? initialEntitlement;

  @override
  State<ReglageProfileViewPage> createState() => _ReglageProfileViewPageState();
}

bool _looksLikeEmail(String s) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s.trim());

class _ReglageProfileViewPageState extends State<ReglageProfileViewPage>
    with WidgetsBindingObserver {
  AccountEntitlementSnapshot? _entitlement;
  bool _saveBusy = false;
  bool _editing = false;

  Timer? _entitlementReloadDebounce;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _subscriberEntitlementsSub;

  late ReglageProfileData _profile;

  late final TextEditingController _ctrlPrenom;
  late final TextEditingController _ctrlNom;
  late final TextEditingController _ctrlEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _profile = widget.profile;
    _entitlement = widget.initialEntitlement;
    _ctrlPrenom = TextEditingController(text: _profile.prenom);
    _ctrlNom = TextEditingController(text: _profile.nom);
    _ctrlEmail = TextEditingController(text: _profile.email.trim());
    _loadEntitlement();
    _subscribeToRemoteEntitlementChanges();
  }

  @override
  void didUpdateWidget(covariant ReglageProfileViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialEntitlement != oldWidget.initialEntitlement) {
      setState(() => _entitlement = widget.initialEntitlement);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entitlementReloadDebounce?.cancel();
    unawaited(_subscriberEntitlementsSub?.cancel());
    _ctrlPrenom.dispose();
    _ctrlNom.dispose();
    _ctrlEmail.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      unawaited(_loadEntitlement());
    }
  }

  /// Quand Stripe / Functions met à jour `subscriber_entitlements`, l’UI suit sans quitter la page.
  void _subscribeToRemoteEntitlementChanges() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    unawaited(_subscriberEntitlementsSub?.cancel());
    _subscriberEntitlementsSub = FirebaseFirestore.instance
        .collection(kPaychekSubscriberEntitlementsCollection)
        .doc(u.uid)
        .snapshots()
        .listen((_) => _scheduleEntitlementReload());
  }

  void _scheduleEntitlementReload() {
    if (!mounted) return;
    _entitlementReloadDebounce?.cancel();
    _entitlementReloadDebounce = Timer(const Duration(milliseconds: 450), () {
      _entitlementReloadDebounce = null;
      if (!mounted) return;
      unawaited(_loadEntitlement());
    });
  }

  Future<bool> _onSaveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final p = _ctrlPrenom.text.trim();
    final n = _ctrlNom.text.trim();
    final e = _ctrlEmail.text.trim();
    if (p.isEmpty || n.isEmpty || e.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.profileEditIncompleteFieldsSnack),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A2A2A),
        ),
      );
      return false;
    }
    if (!_looksLikeEmail(e)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.profileEditInvalidEmailSnack),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A2A2A),
        ),
      );
      return false;
    }
    setState(() => _saveBusy = true);
    try {
      await ReglageProfilePrefs.save(
        inscrit: true,
        prenom: p,
        nom: n,
        email: e,
      );
      final data = await ReglageProfilePrefs.load();
      if (!mounted) return false;
      UserProfileScope.of(context).setProfile(data);
      setState(() => _profile = data);

      final u = FirebaseAuth.instance.currentUser;
      if (u != null) {
        try {
          await u.updateDisplayName('$p $n'.trim());
        } catch (_) {
          // Profil local appliqué ; Firebase displayName optionnel
        }
        try {
          await syncPaychekUserDocument(u, firstName: p, lastName: n);
        } catch (_) {
          // Prénom/nom locaux + Auth ; Firestore optionnel
        }
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.profileEditSavedSnack),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A2A2A),
        ),
      );
      return true;
    } finally {
      if (mounted) setState(() => _saveBusy = false);
    }
  }

  void _enterEditMode() {
    setState(() => _editing = true);
  }

  void _cancelEditMode() {
    final p = _profile;
    _ctrlPrenom.text = p.prenom;
    _ctrlNom.text = p.nom;
    _ctrlEmail.text = p.email.trim();
    setState(() => _editing = false);
  }

  InputDecoration _profileFieldDecoration(
    String label, {
    required bool isWebUi,
  }) {
    final muted =
        isWebUi ? PaychekWebTokens.textGray500 : _kMonoMuted;
    final surface =
        isWebUi ? PaychekWebTokens.pillTrackBg : const Color(0xFF121214);
    final borderClr =
        isWebUi ? PaychekWebTokens.borderGray800 : _kMobileFieldBorder;
    final focusClr =
        isWebUi ? PaychekWebTokens.accentEmerald : _kBrandTeal;
    const radius = 14.0;
    final labelText = label.toUpperCase();
    OutlineInputBorder br(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: c),
        );
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: muted,
      ),
      floatingLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: muted,
      ),
      filled: true,
      fillColor: surface,
      border: br(borderClr),
      enabledBorder: br(borderClr),
      focusedBorder: br(focusClr),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
    );
  }

  Future<void> _loadEntitlement() async {
    final s = await TrialAccessPrefs.loadAccountEntitlement();
    if (!mounted) return;
    setState(() => _entitlement = s);
  }

  Future<void> _openSubscriptionCheckout() async {
    if (!mounted) return;
    await showPaychekGoldUpgradeSheet(context: context);
    if (!mounted) return;
    await _loadEntitlement();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final profile = _profile;
    final e = profile.email.trim();
    final isWebUi = kIsWeb;
    final scaffoldBg =
        isWebUi ? PaychekWebTokens.scaffoldBg : _kMonoBg;

    Widget scrollContent() => RefreshIndicator(
          onRefresh: _loadEntitlement,
          color: isWebUi ? PaychekWebTokens.accentEmerald : _kBrandTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              isWebUi ? 32 : 22,
              isWebUi ? 24 : 20,
              isWebUi ? 32 : 22,
              isWebUi ? 40 : 36,
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _ProfileAvatar(
                  initials: profile.initials,
                  accentColor: isWebUi
                      ? PaychekWebTokens.accentEmerald
                      : _kBrandTeal,
                ),
              ),
              SizedBox(height: 24),
              Text(
                profile.displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isWebUi ? 24 : 22,
                  fontWeight: FontWeight.w800,
                  color: DashboardTokens.onMatteEmphasis,
                  height: 1.2,
                ),
              ),
              if (_entitlement != null && !_entitlement!.isPro) ...[
                SizedBox(height: isWebUi ? 10 : 8),
                Center(
                  child: Semantics(
                    button: true,
                    label: l10n.profileUpgradeLabel,
                    child: PaychekMinimalUpgradeButton(
                      label: l10n.profileUpgradeLabel,
                      onTap: () => unawaited(_openSubscriptionCheckout()),
                    ),
                  ),
                ),
              ],
              if (e.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  e,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isWebUi ? 15 : 14,
                    fontWeight: FontWeight.w500,
                    color: isWebUi
                        ? PaychekWebTokens.textGray500
                        : DashboardTokens.labelGrey,
                  ),
                ),
              ],
              SizedBox(height: isWebUi ? 32 : 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _SectionHeading(
                      text: l10n.profileViewDetailsSection,
                      isWebUi: isWebUi,
                    ),
                  ),
                  if (!_editing)
                    TextButton.icon(
                      onPressed: _saveBusy ? null : _enterEditMode,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: isWebUi
                            ? PaychekWebTokens.accentEmerald
                            : _kBrandTeal,
                      ),
                      label: Text(
                        l10n.tradeEditMenu,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isWebUi
                              ? PaychekWebTokens.accentEmerald
                              : _kBrandTeal,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: isWebUi
                            ? PaychekWebTokens.accentEmerald
                            : _kBrandTeal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _ProfileEditCard(
                isWebUi: isWebUi,
                enabledNameFields: _editing && !_saveBusy,
                enabledEmailField: false,
                prenomController: _ctrlPrenom,
                nomController: _ctrlNom,
                emailController: _ctrlEmail,
                fieldDecoration: (label) =>
                    _profileFieldDecoration(label, isWebUi: isWebUi),
              ),
              SizedBox(height: isWebUi ? 16 : 14),
              if (_editing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saveBusy ? null : _cancelEditMode,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(
                            color: isWebUi
                                ? PaychekWebTokens.borderGray800
                                : const Color(0xFF2A2A2A),
                          ),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveBusy
                            ? null
                            : () async {
                                final ok = await _onSaveProfile();
                                if (!mounted) return;
                                if (ok) setState(() => _editing = false);
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: isWebUi
                              ? PaychekWebTokens.accentEmerald
                              : _kBrandTeal,
                          foregroundColor: Colors.black87,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _saveBusy
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.black87.withValues(alpha: 0.7),
                                ),
                              )
                            : Text(
                                l10n.save,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: isWebUi ? 28 : 20),
              _SectionHeading(
                text: l10n.profileAccountStatusTitle,
                isWebUi: isWebUi,
              ),
              const SizedBox(height: 14),
              _AccountStatusCard(
                entitlement: _entitlement,
                l10n: l10n,
                isWebUi: isWebUi,
              ),
              const SizedBox(height: 14),
              _SubscriptionActionButton(
                entitlement: _entitlement,
                l10n: l10n,
                isWebUi: isWebUi,
                onNonProSubscribe: _openSubscriptionCheckout,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        );

    final back = widget.onBack ?? () => Navigator.of(context).pop();

    final body = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isWebUi)
            PaychekPageHeader(
              title: l10n.accountPageTitle,
              subtitle: l10n.profileViewDetailsSection,
              onBack: widget.embeddedInReglageOverlay ? back : back,
              maxContentWidth: _kWebAccountMaxWidth,
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: back,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.accountPageTitle,
                          style: t.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ) ??
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: isWebUi
                ? Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _kWebAccountMaxWidth,
                      ),
                      child: scrollContent(),
                    ),
                  )
                : scrollContent(),
          ),
        ],
      ),
    );

    if (widget.embeddedInReglageOverlay) {
      // Pas de Scaffold additionnel: on s'insère dans l'overlay Réglages (web) pour garder le rail visible.
      return ColoredBox(color: scaffoldBg, child: body);
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: body,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text, required this.isWebUi});

  final String text;
  final bool isWebUi;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.65,
        color: isWebUi
            ? PaychekWebTokens.textGray600
            : DashboardTokens.labelGrey,
      ),
    );
  }
}

/// Glyphe **uniquement** pour la carte « Account status » (page Compte) — pas d’[Icon] Material, pas de réutilisation ailleurs.
class _AccountStatusTierGlyph extends StatelessWidget {
  const _AccountStatusTierGlyph({super.key, required this.isPro, required this.isWebUi});

  final bool isPro;
  final bool isWebUi;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        size: const Size(44, 44),
        painter: _AccountStatusTierGlyphPainter(
          isPro: isPro,
          isWebUi: isWebUi,
        ),
      ),
    );
  }
}

class _AccountStatusTierGlyphPainter extends CustomPainter {
  _AccountStatusTierGlyphPainter({
    required this.isPro,
    required this.isWebUi,
  });

  final bool isPro;
  final bool isWebUi;

  static const Color _gold = Color(0xFFF59E0B);

  Color get _liteAccent =>
      isWebUi ? PaychekWebTokens.accentEmerald : _kBrandTeal;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final w = size.width;

    if (isPro) {
      final vignette = Paint()
        ..shader = RadialGradient(
          colors: [
            _gold.withValues(alpha: 0.2),
            _gold.withValues(alpha: 0.02),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
          center: Alignment.center,
          radius: w * 0.58,
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, vignette);

      final ring = Paint()
        ..color = _gold.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.65;
      canvas.drawCircle(c, w * 0.31, ring);

      canvas.drawCircle(
        c,
        w * 0.19,
        Paint()..color = _gold.withValues(alpha: 0.14),
      );

      final arc = Paint()
        ..color = _gold.withValues(alpha: 0.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.1
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: w * 0.255),
        -math.pi * 0.92,
        math.pi * 0.5,
        false,
        arc,
      );

      canvas.drawCircle(c, w * 0.085, Paint()..color = _gold);
      canvas.drawCircle(
        c + Offset(-w * 0.022, -w * 0.02),
        w * 0.028,
        Paint()..color = Colors.white.withValues(alpha: 0.72),
      );
    } else {
      final em = _liteAccent;
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            em.withValues(alpha: 0.22),
            em.withValues(alpha: 0.04),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 1.0],
          center: Alignment.center,
          radius: w * 0.55,
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, glow);

      final r = w * 0.21;
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final a = -math.pi / 2 + i * math.pi / 3;
        final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = em.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.75,
      );
      canvas.drawCircle(
        c,
        w * 0.08,
        Paint()..color = em.withValues(alpha: 0.22),
      );
      canvas.drawCircle(c, w * 0.046, Paint()..color = em);
    }
  }

  @override
  bool shouldRepaint(covariant _AccountStatusTierGlyphPainter oldDelegate) =>
      oldDelegate.isPro != isPro || oldDelegate.isWebUi != isWebUi;
}

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard({
    required this.entitlement,
    required this.l10n,
    required this.isWebUi,
  });

  final AccountEntitlementSnapshot? entitlement;
  final AppLocalizations l10n;
  final bool isWebUi;

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(16);
    final cardBg =
        isWebUi ? PaychekWebTokens.cardBg : _kMobileCardSurface;
    final outerBorder = isWebUi
        ? PaychekWebTokens.borderGray800
        : const Color(0xFF26262A);
    final iconBoxBg =
        isWebUi ? PaychekWebTokens.pillTrackBg : const Color(0xFF0E0E10);
    final iconBoxBorder = isWebUi
        ? PaychekWebTokens.borderGray800
        : const Color(0xFF2A2A30);
    final accent =
        isWebUi ? PaychekWebTokens.accentEmerald : _kBrandTeal;
    final textMuted =
        isWebUi ? PaychekWebTokens.textGray500 : _kMonoMuted;
    final trialPillBg =
        isWebUi ? PaychekWebTokens.pillTrackBg : const Color(0xFF222226);
    final trialPillBorder = isWebUi
        ? PaychekWebTokens.borderGray800
        : const Color(0xFF3A3A40);
    final progressTrack =
        isWebUi ? const Color(0xFF1F2937) : const Color(0xFF2A2A2E);

    if (entitlement == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: cardRadius,
          border: Border.all(color: outerBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accent,
              ),
            ),
          ),
        ),
      );
    }

    final s = entitlement!;
    final isPro = s.isPro;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    String? trialEndFormatted;
    if (!isPro && s.trialActive && s.trialEndUtc != null) {
      trialEndFormatted = DateFormat.yMMMd(
        localeTag,
      ).format(s.trialEndUtc!.toLocal());
    }

    String? expiredTrialEndFormatted;
    if (!isPro && !s.trialActive && s.trialEndUtc != null) {
      expiredTrialEndFormatted = DateFormat.yMMMd(
        localeTag,
      ).format(s.trialEndUtc!.toLocal());
    }

    String? proPeriodFooterLine;
    if (isPro) {
      final DateTime? proEndForUi =
          TrialAccessPrefs.proSubscriptionDisplayEndUtc(
        isWebUi: isWebUi,
        proSinceUtc: s.proSinceUtc,
        subscriptionPeriodEndUtc: s.subscriptionPeriodEndUtc,
      );
      if (proEndForUi != null) {
        proPeriodFooterLine = l10n.profileProPeriodEndsOn(
          DateFormat.yMMMd(localeTag).format(
            proEndForUi.toLocal(),
          ),
        );
      } else if (s.trialEndUtc != null) {
        proPeriodFooterLine = l10n.profileTrialEndsOn(
          DateFormat.yMMMd(localeTag).format(s.trialEndUtc!.toLocal()),
        );
      }
    }

    final trialProgress = (!isPro &&
            s.trialActive &&
            s.daysLeftInTrial > 0)
        ? ((kPaychekTrialDuration.inDays - s.daysLeftInTrial) /
                kPaychekTrialDuration.inDays)
            .clamp(0.0, 1.0)
        : 0.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: cardRadius,
        border: Border.all(color: outerBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: iconBoxBg,
                border: Border.all(color: iconBoxBorder),
              ),
              alignment: Alignment.center,
              child: _AccountStatusTierGlyph(
                key: ValueKey(isPro),
                isPro: isPro,
                isWebUi: isWebUi,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isPro && s.trialActive)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: trialPillBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: trialPillBorder),
                          ),
                          child: Text(
                            l10n.profileTrialBadge.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (!isPro && s.trialActive) ...[
                    const SizedBox(height: 10),
                    if (s.daysLeftInTrial > 0)
                      Text(
                        l10n.profileTrialDaysLeft(s.daysLeftInTrial),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: textMuted,
                        ),
                      ),
                    if (s.daysLeftInTrial > 0) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: trialProgress,
                          minHeight: 6,
                          backgroundColor: progressTrack,
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                    ],
                    if (trialEndFormatted != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        l10n.profileTrialEndsOn(trialEndFormatted),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: textMuted.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                  if (!isPro && !s.trialActive) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: trialPillBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: trialPillBorder),
                          ),
                          child: Text(
                            l10n.profileAccountStatusLite.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (expiredTrialEndFormatted != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        l10n.profileTrialEndedOn(expiredTrialEndFormatted),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ],
                  if (proPeriodFooterLine != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      proPeriodFooterLine,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: textMuted.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionActionButton extends StatelessWidget {
  const _SubscriptionActionButton({
    required this.entitlement,
    required this.l10n,
    required this.isWebUi,
    required this.onNonProSubscribe,
  });

  final AccountEntitlementSnapshot? entitlement;
  final AppLocalizations l10n;
  final bool isWebUi;
  final Future<void> Function() onNonProSubscribe;

  @override
  Widget build(BuildContext context) {
    if (entitlement == null) {
      return const SizedBox.shrink();
    }

    final isPro = entitlement!.isPro;
    final label = isPro
        ? l10n.profileManageSubscriptionButton
        : l10n.profileSubscribeButton;

    final ctaBg = isPro
        ? _kSubscribeButtonProBg
        : (isWebUi ? PaychekWebTokens.accentEmerald : _kBrandTeal);
    final ctaFg = isPro ? _kSubscribeButtonProFg : Colors.white;

    return FilledButton(
      onPressed: () async {
        if (isPro) {
          final ok = await openPaychekSubscriptionFlow();
          if (!context.mounted) return;
          if (!ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.paywallStoreNotConfigured),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF2A2A2A),
              ),
            );
          }
          return;
        }
        await onNonProSubscribe();
      },
      style: FilledButton.styleFrom(
        backgroundColor: ctaBg,
        foregroundColor: ctaFg,
        disabledBackgroundColor: _kSubscribeButtonProBg,
        disabledForegroundColor: _kSubscribeButtonProFg,
        minimumSize: const Size.fromHeight(52),
        padding: EdgeInsets.symmetric(
          vertical: isWebUi ? 18 : 16,
          horizontal: isWebUi ? 20 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: isWebUi ? 3 : 2,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: isWebUi ? 14 : 14,
          height: 1.3,
          color: ctaFg,
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.initials,
    required this.accentColor,
  });

  final String initials;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    const side = 96.0;
    const fontSize = 30.0;
    final avatar = Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF151518),
        border: Border.all(color: const Color(0xFF2C2C32)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.22),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: DashboardTokens.onMatteEmphasis,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF121214),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1A1A1C), width: 2),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileEditCard extends StatelessWidget {
  const _ProfileEditCard({
    required this.isWebUi,
    required this.enabledNameFields,
    required this.enabledEmailField,
    required this.prenomController,
    required this.nomController,
    required this.emailController,
    required this.fieldDecoration,
  });

  final bool isWebUi;
  final bool enabledNameFields;
  final bool enabledEmailField;
  final TextEditingController prenomController;
  final TextEditingController nomController;
  final TextEditingController emailController;
  final InputDecoration Function(String label) fieldDecoration;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textStyle = GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: DashboardTokens.onMatteEmphasis,
    );

    Widget field(TextEditingController c, String label,
        {TextInputType? keyboardType,
        TextCapitalization caps = TextCapitalization.none,
        List<String>? autofillHints,
        required bool enabled}) {
      final disabledTextColor =
          isWebUi ? PaychekWebTokens.textGray500 : _kMonoMuted;
      final disabledFill =
          isWebUi ? const Color(0xFF101010) : const Color(0xFF0A0A0A);
      return TextField(
        controller: c,
        readOnly: !enabled,
        keyboardType: keyboardType,
        textCapitalization: caps,
        autofillHints: autofillHints,
        style: enabled ? textStyle : textStyle.copyWith(color: disabledTextColor),
        enableInteractiveSelection: enabled,
        cursorColor:
            isWebUi ? PaychekWebTokens.accentEmerald : _kBrandTeal,
        decoration: enabled
            ? fieldDecoration(label)
            : fieldDecoration(label).copyWith(
                fillColor: disabledFill,
              ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isWebUi ? PaychekWebTokens.cardBg : _kMobileCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWebUi
              ? PaychekWebTokens.borderGray800
              : const Color(0xFF26262A),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWebUi ? 16 : 16,
          vertical: isWebUi ? 16 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            field(
              prenomController,
              l10n.accountFieldFirstName,
              caps: TextCapitalization.words,
              autofillHints: const [AutofillHints.givenName],
              enabled: enabledNameFields,
            ),
            SizedBox(height: isWebUi ? 14 : 12),
            field(
              nomController,
              l10n.accountFieldLastName,
              caps: TextCapitalization.words,
              autofillHints: const [AutofillHints.familyName],
              enabled: enabledNameFields,
            ),
            SizedBox(height: isWebUi ? 14 : 12),
            field(
              emailController,
              l10n.accountFieldEmail,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              enabled: enabledEmailField,
            ),
          ],
        ),
      ),
    );
  }
}
