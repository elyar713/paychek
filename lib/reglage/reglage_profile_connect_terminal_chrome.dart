import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'reglage_profile_connect_branding.dart';

/// Couleurs alignées sur la maquette HTML « Premium Terminal ».
abstract final class PaychekTerminalAuthColors {
  static const Color bg = Color(0xFF000000);
  static const Color emerald = Color(0xFF10B981);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color glassFill = Color(0x6618181B);
  static const Color glassBorder = Color(0x0DFFFFFF);
}

/// Grille + halos verts (fond écran connexion).
class TerminalAuthBackdrop extends StatelessWidget {
  const TerminalAuthBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _TerminalGridPainter()),
        Positioned(
          top: -150,
          right: -100,
          child: IgnorePointer(
            child: _GlowOrb(
              size: 400,
              color: PaychekTerminalAuthColors.emerald.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: IgnorePointer(
            child: _GlowOrb(
              size: 400,
              color: PaychekTerminalAuthColors.emerald.withValues(alpha: 0.08),
            ),
          ),
        ),
      ],
    );
  }
}

class _TerminalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 30.0;
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var y = 0.0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}

/// Logo Paychek + tagline (écran connexion / inscription mobile).
class PaychekTerminalLogoHeader extends StatelessWidget {
  const PaychekTerminalLogoHeader({super.key, required this.tagline});

  final String tagline;

  @override
  Widget build(BuildContext context) {
    final inter = GoogleFonts.inter;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        children: [
          const PaychekBrandLogoMark(height: 60),
          const SizedBox(height: 14),
          Text(
            tagline.toUpperCase(),
            style: inter(
              fontSize: 10,
              height: 1.35,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.6,
              color: PaychekTerminalAuthColors.zinc500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Onglets Login / Sign up : soulignement émeraude actif.
class PaychekTerminalAuthTabBar extends StatelessWidget {
  const PaychekTerminalAuthTabBar({
    super.key,
    required this.tabLoginLabel,
    required this.tabSignupLabel,
    required this.loginSelected,
    required this.onLoginTap,
    required this.onSignupTap,
  });

  final String tabLoginLabel;
  final String tabSignupLabel;
  final bool loginSelected;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;

  @override
  Widget build(BuildContext context) {
    final inter = GoogleFonts.inter;
    Widget cell({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white10,
            highlightColor: Colors.white10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected
                        ? PaychekTerminalAuthColors.emerald
                        : PaychekTerminalAuthColors.zinc900,
                    width: selected ? 2 : 1,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label.toUpperCase(),
                style: inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.4,
                  color: selected
                      ? Colors.white
                      : PaychekTerminalAuthColors.zinc500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        cell(
          label: tabLoginLabel,
          selected: loginSelected,
          onTap: onLoginTap,
        ),
        cell(
          label: tabSignupLabel,
          selected: !loginSelected,
          onTap: onSignupTap,
        ),
      ],
    );
  }
}

/// Champ type « glass » + label uppercase (maquette).
class PaychekTerminalGlassTextField extends StatefulWidget {
  const PaychekTerminalGlassTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final IconData? prefixIcon;

  @override
  State<PaychekTerminalGlassTextField> createState() =>
      _PaychekTerminalGlassTextFieldState();
}

class _PaychekTerminalGlassTextFieldState extends State<PaychekTerminalGlassTextField> {
  late final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inter = GoogleFonts.inter;
    final focused = _focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            widget.label.toUpperCase(),
            style: inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: PaychekTerminalAuthColors.zinc600,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: focused
                    ? const Color(0xCC18181B)
                    : PaychekTerminalAuthColors.glassFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: focused
                      ? PaychekTerminalAuthColors.emerald.withValues(alpha: 0.55)
                      : PaychekTerminalAuthColors.glassBorder,
                  width: 1,
                ),
                boxShadow: focused
                    ? [
                        BoxShadow(
                          color: PaychekTerminalAuthColors.emerald.withValues(
                            alpha: 0.12,
                          ),
                          blurRadius: 14,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                autocorrect: widget.autocorrect,
                enableSuggestions: widget.enableSuggestions,
                autofillHints: widget.autofillHints,
                textCapitalization: widget.textCapitalization,
                style: inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: PaychekTerminalAuthColors.emerald,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: inter(
                    color: PaychekTerminalAuthColors.zinc500,
                    fontSize: 12,
                  ),
                  prefixIcon: widget.prefixIcon == null
                      ? null
                      : Icon(
                          widget.prefixIcon,
                          size: 16,
                          color: PaychekTerminalAuthColors.zinc500,
                        ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bouton réseau (bord zinc, fond très sombre).
class PaychekTerminalSocialTile extends StatelessWidget {
  const PaychekTerminalSocialTile({
    super.key,
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: const Color(0x7F0A0A0B),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white12,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PaychekTerminalAuthColors.zinc800),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
