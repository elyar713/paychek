import 'dart:async' show TimeoutException, unawaited;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dashboard/dashboard_tokens.dart';
import '../help_center/help_center_page.dart';
import '../l10n/app_localizations.dart';
import '../web/paychek_web_tokens.dart';
import 'paychek_support_ticket_submit.dart';
import 'support_feedback_config.dart';

enum _SupportFormKind { account, billing, feature, other }

/// Page « Support & Feedback » — contact + docs (sans communauté ni FAQ pour l’instant).
class SupportFeedbackPage extends StatefulWidget {
  const SupportFeedbackPage({
    super.key,
    this.onOpenHelpCenterInShell,
    /// Dashboard mobile : fermeture sans route (overlay [IndexedStack]).
    this.onCloseInShell,
  });

  /// Mobile shell : ouvre le centre d’aide sans empiler une seconde route plein écran.
  final VoidCallback? onOpenHelpCenterInShell;

  /// Quand la page est affichée en overlay (pas de [Navigator.push]), fermer ici.
  final VoidCallback? onCloseInShell;

  @override
  State<SupportFeedbackPage> createState() => _SupportFeedbackPageState();
}

class _SupportFeedbackPageState extends State<SupportFeedbackPage> {
  final _emailCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  _SupportFormKind _kind = _SupportFormKind.account;

  PlatformFile? _attachment;
  Uint8List? _attachmentBytes;
  bool _submitting = false;
  String? _inlineSubmitStatus;

  void _clearInlineSubmitStatus() {
    if (_inlineSubmitStatus == null) return;
    setState(() => _inlineSubmitStatus = null);
  }

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser;
    final addr = u?.email?.trim();
    if (addr != null && addr.isNotEmpty) {
      _emailCtrl.text = addr;
    }
    _emailCtrl.addListener(_clearInlineSubmitStatus);
    _descCtrl.addListener(_clearInlineSubmitStatus);
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_clearInlineSubmitStatus);
    _descCtrl.removeListener(_clearInlineSubmitStatus);
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _kindFirestoreLabel(_SupportFormKind k) {
    switch (k) {
      case _SupportFormKind.account:
        return 'account';
      case _SupportFormKind.billing:
        return 'billing';
      case _SupportFormKind.feature:
        return 'feature';
      case _SupportFormKind.other:
        return 'other';
    }
  }

  Future<void> _launchMailto(String subject, String body) async {
    final uri = Uri.parse(
      'mailto:${SupportFeedbackConfig.supportEmail}'
      '?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    );
    final mode = kIsWeb
        ? LaunchMode.platformDefault
        : LaunchMode.externalApplication;
    try {
      final ok = await launchUrl(uri, mode: mode);
      if (!ok && mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible d’ouvrir l’app e-mail. Vérifie qu’une messagerie est installée.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Ouverture e-mail impossible : $e')),
        );
      }
    }
  }

  Future<void> _launchSimpleMailto() async {
    final uri = Uri.parse('mailto:${SupportFeedbackConfig.supportEmail}');
    final mode = kIsWeb
        ? LaunchMode.platformDefault
        : LaunchMode.externalApplication;
    try {
      final ok = await launchUrl(uri, mode: mode);
      if (!ok && mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible d’ouvrir l’app e-mail. Vérifie qu’une messagerie est installée.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Ouverture e-mail impossible : $e')),
        );
      }
    }
  }

  void _openDocs(BuildContext context) {
    if (widget.onOpenHelpCenterInShell != null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      widget.onOpenHelpCenterInShell!();
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const HelpCenterPage(),
      ),
    );
  }

  String _kindLabel(AppLocalizations l10n, _SupportFormKind k) {
    switch (k) {
      case _SupportFormKind.account:
        return l10n.supportFormKindAccount;
      case _SupportFormKind.billing:
        return l10n.supportFormKindBilling;
      case _SupportFormKind.feature:
        return l10n.supportFormKindFeature;
      case _SupportFormKind.other:
        return l10n.supportFormKindOther;
    }
  }

  Future<void> _pickAttachment(AppLocalizations l10n) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.supportFormAttachmentSignInHint)),
      );
      return;
    }
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: kPaychekSupportAttachmentExtensions
          .map((e) => e.toLowerCase())
          .toList(),
      allowMultiple: false,
      withData: true,
    );
    if (!mounted || r == null || r.files.isEmpty) return;
    final f = r.files.single;
    final ext = _extensionBare(f.name);
    if (!kPaychekSupportAttachmentExtensions.contains(ext)) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.supportFormAttachmentInvalidExtension)),
      );
      return;
    }
    final bytes = await paychekSupportReadPlatformFileBytes(f);
    if (!mounted) return;
    if (bytes == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.supportFormAttachmentReadFailed)),
      );
      return;
    }
    if (bytes.length > kPaychekSupportAttachmentMaxBytes) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.supportFormAttachmentTooLarge)),
      );
      return;
    }
    setState(() {
      _attachment = f;
      _attachmentBytes = bytes;
    });
  }

  static String _extensionBare(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot >= fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final email = _emailCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.supportFormErrorEmail)),
      );
      return;
    }
    if (desc.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.supportFormErrorDescription)),
      );
      return;
    }
    final signedIn = FirebaseAuth.instance.currentUser != null;

    if (signedIn) {
      if (_submitting) return;
      setState(() => _submitting = true);
      try {
        final attachmentUploaded = await submitPaychekSupportTicket(
          replyEmail: email,
          kind: _kindFirestoreLabel(_kind),
          description: desc,
          attachment: _attachment,
          attachmentBytes: _attachmentBytes,
        );
        if (!mounted) return;
        final hadFile = _attachment != null;
        if (hadFile && !attachmentUploaded) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text(l10n.supportFormSubmitSavedPartialAttachment)),
          );
          setState(() {
            _inlineSubmitStatus = l10n.supportFormSubmitSuccessPartial;
          });
        } else {
          setState(() {
            _inlineSubmitStatus = l10n.supportFormSubmitSuccess;
          });
        }
        _descCtrl.clear();
        setState(() {
          _attachment = null;
          _attachmentBytes = null;
        });
      } on ArgumentError catch (_) {
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text(l10n.supportFormAttachmentTooLarge)),
          );
        }
      } on FormatException catch (_) {
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text(l10n.supportFormAttachmentInvalidExtension)),
          );
        }
      } on TimeoutException catch (e, st) {
        debugPrint('[Paychek] support submit deadline: $e\n$st');
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 6),
              content: Text(l10n.supportFormSubmitError),
            ),
          );
        }
      } on FirebaseException catch (e) {
        debugPrint(
          '[Paychek] support submit Firestore/Storage ${e.code}: ${e.message} '
          '(plugin: ${e.plugin})',
        );
        if (mounted) {
          final codeSuffix = e.code.isNotEmpty ? ' (${e.code})' : '';
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 5),
              content: Text('${l10n.supportFormSubmitError}$codeSuffix'),
            ),
          );
        }
      } catch (e, st) {
        debugPrint('[Paychek] support submit: $e\n$st');
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text(l10n.supportFormSubmitError)),
          );
        }
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
      return;
    }

    // Non connecté : pas de fichier (Storage + règles dédiées à un utilisateur).
    if (_attachment != null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.supportFormAttachmentSignInHint)),
      );
      return;
    }
    final subject = '${l10n.supportFormMailSubjectPrefix} · ${_kindLabel(l10n, _kind)}';
    final body = '${l10n.supportFormMailBodyIntro}\n\n'
        '${l10n.supportFormKindLabel}: ${_kindLabel(l10n, _kind)}\n'
        '${l10n.supportFormEmailLabel}: $email\n\n'
        '$desc';

    await _launchMailto(subject, body);
    if (mounted) {
      setState(() {
        _inlineSubmitStatus = l10n.supportFormSubmitSuccess;
      });
    }
  }

  static const Color _accentBlue = Color(0xFF3B82F6);
  static const Gradient _feedbackGradient = LinearGradient(
    colors: [Color(0xFF818CF8), Color(0xFF38BDF8)],
  );

  /// Largeur max du bloc formulaire sur grand écran.
  static const double _formMaxWidth = 560;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final web = kIsWeb;
    final bg = web ? PaychekWebTokens.scaffoldBg : Colors.black;
    final cardBg = web ? PaychekWebTokens.cardBg : const Color(0xFF111111);
    final border = web ? PaychekWebTokens.borderGray800 : const Color(0xFF232326);
    final maxContentW = web ? 960.0 : double.infinity;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentW),
            child: ListView(
              padding: EdgeInsets.fromLTRB(web ? 24 : 16, web ? 16 : 8, web ? 24 : 16, 24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      if (widget.onCloseInShell != null) {
                        widget.onCloseInShell!();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: web ? 26 : 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.supportFeedbackBack,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: web ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.supportFeedbackTitleLead,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: web ? 28 : 24,
                          fontWeight: FontWeight.w800,
                          color: DashboardTokens.onMatteEmphasis,
                          height: 1.15,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              _feedbackGradient.createShader(bounds),
                          child: Text(
                            l10n.supportFeedbackTitleAccent,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: web ? 28 : 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.supportFeedbackSubtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: web ? 15 : 14,
                    fontWeight: FontWeight.w400,
                    color: web ? PaychekWebTokens.textGray500 : DashboardTokens.labelGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _formMaxWidth),
                    child: _DualQuickActionsRow(
                      web: web,
                      cardBg: cardBg,
                      border: border,
                      l10n: l10n,
                      onEmailTap: () => unawaited(_launchSimpleMailto()),
                      onDocsTap: () => _openDocs(context),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _formMaxWidth),
                    child: StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      initialData: FirebaseAuth.instance.currentUser,
                      builder: (context, _) {
                        return _formCard(web, cardBg, l10n);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formCard(bool web, Color cardBg, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentBlue, width: 1.2),
        boxShadow: web
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.supportFormNewMessage,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: DashboardTokens.onMatteEmphasis,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.supportFormKindLabel.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: PaychekWebTokens.textGray600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: web ? PaychekWebTokens.pillTrackBg : const Color(0xFF0A0A0B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: web ? PaychekWebTokens.borderGray800 : const Color(0xFF232326)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_SupportFormKind>(
                value: _kind,
                isExpanded: true,
                dropdownColor: cardBg,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: DashboardTokens.onMatteEmphasis,
                ),
                items: [
                  DropdownMenuItem(
                    value: _SupportFormKind.account,
                    child: Text(l10n.supportFormKindAccount),
                  ),
                  DropdownMenuItem(
                    value: _SupportFormKind.billing,
                    child: Text(l10n.supportFormKindBilling),
                  ),
                  DropdownMenuItem(
                    value: _SupportFormKind.feature,
                    child: Text(l10n.supportFormKindFeature),
                  ),
                  DropdownMenuItem(
                    value: _SupportFormKind.other,
                    child: Text(l10n.supportFormKindOther),
                  ),
                ],
                onChanged: (v) => setState(() {
                  _kind = v ?? _SupportFormKind.account;
                  _inlineSubmitStatus = null;
                }),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.supportFormEmailLabel.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: PaychekWebTokens.textGray600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: DashboardTokens.onMatteEmphasis,
            ),
            decoration: InputDecoration(
              hintText: l10n.supportFormEmailHint,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: DashboardTokens.labelGrey,
                fontSize: 14,
              ),
              filled: true,
              fillColor: web ? PaychekWebTokens.pillTrackBg : const Color(0xFF0A0A0B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: web ? PaychekWebTokens.borderGray800 : const Color(0xFF232326),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: web ? PaychekWebTokens.borderGray800 : const Color(0xFF232326),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.supportFormDescriptionLabel.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: PaychekWebTokens.textGray600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            minLines: 4,
            maxLines: 8,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: DashboardTokens.onMatteEmphasis,
            ),
            decoration: InputDecoration(
              hintText: l10n.supportFormDescriptionHint,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: DashboardTokens.labelGrey,
                fontSize: 14,
              ),
              filled: true,
              fillColor: web ? PaychekWebTokens.pillTrackBg : const Color(0xFF0A0A0B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: web ? PaychekWebTokens.borderGray800 : const Color(0xFF232326),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: web ? PaychekWebTokens.borderGray800 : const Color(0xFF232326),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.supportFormAttachmentLabel.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: PaychekWebTokens.textGray600,
            ),
          ),
          const SizedBox(height: 8),
          if (FirebaseAuth.instance.currentUser == null)
            Text(
              l10n.supportFormAttachmentSignInHint,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.35,
                color: DashboardTokens.labelGrey,
              ),
            )
          else
            Text(
              l10n.supportFormAttachmentHint,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.35,
                color: DashboardTokens.labelGrey,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _submitting
                    ? null
                    : () => unawaited(_pickAttachment(l10n)),
                icon: Icon(
                  Icons.attach_file_rounded,
                  color: FirebaseAuth.instance.currentUser == null
                      ? DashboardTokens.labelGrey
                      : DashboardTokens.onMatteEmphasis,
                  size: 20,
                ),
                label: Text(
                  l10n.supportFormAttachmentPick,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (_attachment != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _attachment!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: DashboardTokens.onMatteEmphasis,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.supportFormAttachmentRemove,
                  onPressed: _submitting
                      ? null
                      : () => setState(() {
                            _attachment = null;
                            _attachmentBytes = null;
                            _inlineSubmitStatus = null;
                          }),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : () => unawaited(_submit(l10n)),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black.withValues(alpha: 0.75),
                      ),
                    )
                  : Text(
                      l10n.supportFormSubmit,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          if (_inlineSubmitStatus != null) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: web
                      ? PaychekWebTokens.accentEmerald
                      : const Color(0xFF10B981),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _inlineSubmitStatus!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: web
                          ? PaychekWebTokens.accentEmeraldLight
                          : const Color(0xFF34D399),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DualQuickActionsRow extends StatelessWidget {
  const _DualQuickActionsRow({
    required this.web,
    required this.cardBg,
    required this.border,
    required this.l10n,
    required this.onEmailTap,
    required this.onDocsTap,
  });

  final bool web;
  final Color cardBg;
  final Color border;
  final AppLocalizations l10n;
  final VoidCallback onEmailTap;
  final VoidCallback onDocsTap;

  @override
  Widget build(BuildContext context) {
    final email = _ActionCard(
      cardBg: cardBg,
      border: border,
      icon: Icons.mail_outline_rounded,
      iconBg: const Color(0xFF3B82F6),
      title: l10n.supportActionEmailLabel,
      hint: l10n.supportActionEmailHint,
      onTap: onEmailTap,
    );
    final docs = _ActionCard(
      cardBg: cardBg,
      border: border,
      icon: Icons.menu_book_rounded,
      iconBg: web ? PaychekWebTokens.pillTrackBg : const Color(0xFF1A1A1C),
      title: l10n.supportActionDocsLabel,
      hint: l10n.supportActionDocsHint,
      onTap: onDocsTap,
    );

    final narrow = MediaQuery.sizeOf(context).width < 400;
    if (narrow || !web && MediaQuery.sizeOf(context).width < 420) {
      return Column(
        children: [
          email,
          const SizedBox(height: 10),
          docs,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: email),
        const SizedBox(width: 10),
        Expanded(child: docs),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.cardBg,
    required this.border,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final Color cardBg;
  final Color border;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DashboardTokens.onMatteEmphasis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: PaychekWebTokens.textGray600,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
