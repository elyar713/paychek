import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'l10n/app_localizations.dart';
import 'onboarding_language_page.dart';

/// Reproduction Flutter des animations CSS (lueur, icÃ´ne cible Lucide, texte
/// mÃ©tallique + shine, sous-titre, barre de chargement, fondu de sortie).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onFinished});

  /// Si non null, appelé à la fin de l’animation au lieu de naviguer vers la langue.
  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const _matteGreen = Color(0xFF1EB48A);
  static const _darkBg = Color(0xFF000000);
  static const _totalMs = 2500;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    )..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          if (widget.onFinished != null) {
            widget.onFinished!();
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const OnboardingLanguagePage(),
              ),
            );
          }
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _ms => _controller.value * _totalMs;

  /// pulseGlow 3.5s cubic-bezier(0.4, 0, 0.2, 1)
  double get _glowT => (_ms / 3500).clamp(0.0, 1.0);

  double get _glowCurved => const Cubic(0.4, 0, 0.2, 1).transform(_glowT);

  double get _glowScale {
    final c = _glowCurved;
    if (c < 0.5) return lerpDouble(0.7, 1.1, c / 0.5)!;
    return lerpDouble(1.1, 1.0, (c - 0.5) / 0.5)!;
  }

  double get _glowOpacity {
    final c = _glowCurved;
    if (c < 0.5) return lerpDouble(0, 1, c / 0.5)!;
    return lerpDouble(1, 0.8, (c - 0.5) / 0.5)!;
  }

  /// iconReveal 1s cubic-bezier(0.16, 1, 0.3, 1) delay 0.2s
  double get _iconT {
    if (_ms < 200) return 0;
    return const Cubic(0.16, 1, 0.3, 1).transform(((_ms - 200) / 1000).clamp(0.0, 1.0));
  }

  /// textReveal 1.2s cubic-bezier(0.16, 1, 0.3, 1) delay 0.5s
  double get _textRevealT {
    if (_ms < 500) return 0;
    return const Cubic(0.16, 1, 0.3, 1).transform(((_ms - 500) / 1200).clamp(0.0, 1.0));
  }

  /// shine 3.5s linear infinite delay 1.7s
  double get _shinePhase {
    if (_ms < 1700) return 0;
    return ((_ms - 1700) % 3500) / 3500;
  }

  /// fadeUp subtitle 1s ease delay 1.2s
  double get _subtitleT {
    if (_ms < 1200) return 0;
    return Curves.ease.transform(((_ms - 1200) / 1000).clamp(0.0, 1.0));
  }

  /// loading bar container fadeUp 0.5s ease delay 1.5s
  double get _loadBarContT {
    if (_ms < 1500) return 0;
    return Curves.ease.transform(((_ms - 1500) / 500).clamp(0.0, 1.0));
  }

  /// loadProgress 2s cubic-bezier(0.4, 0, 0.2, 1) delay 1.5s
  double get _loadFillRaw {
    if (_ms < 1500) return 0;
    final t = ((_ms - 1500) / 2000).clamp(0.0, 1.0);
    return const Cubic(0.4, 0, 0.2, 1).transform(t);
  }

  double get _loadWidthFraction {
    final t = _loadFillRaw;
    if (t <= 0.3) return lerpDouble(0, 0.4, t / 0.3)!;
    if (t <= 0.7) return lerpDouble(0.4, 0.6, (t - 0.3) / 0.4)!;
    return lerpDouble(0.6, 1.0, (t - 0.7) / 0.3)!;
  }

  /// pageFadeOut 0.5s ease delay 4.2s
  double get _pageOpacity {
    if (_ms < 4200) return 1;
    return 1 - Curves.ease.transform(((_ms - 4200) / 500).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const fontTitle = 45.0;
    final letterTitle = lerpDouble(0.1 * fontTitle, 0.25 * fontTitle, _textRevealT)!;
    final iconScale = lerpDouble(0.8, 1.0, _iconT)!;
    final iconDy = lerpDouble(20, 0, _iconT)!;

    return Scaffold(
      backgroundColor: _darkBg,
      body: Opacity(
        opacity: _pageOpacity,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            _buildGlow(context),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(0, iconDy),
                    child: Opacity(
                      opacity: _iconT,
                      child: Transform.scale(
                        scale: iconScale,
                        child: Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x991EB48A),
                                blurRadius: 15,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            LucideIcons.target,
                            size: 64,
                            color: _matteGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTitle(fontTitle, letterTitle),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: _subtitleT,
                    child: Transform.translate(
                      offset: Offset(0, lerpDouble(10, 0, _subtitleT)!),
                      child: Text(
                        l10n.splashTagline,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF888888),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: Opacity(
                opacity: _loadBarContT,
                child: Center(
                  child: Container(
                    width: 180,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    clipBehavior: Clip.hardEdge,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 180 * _loadWidthFraction,
                      height: 2,
                      decoration: BoxDecoration(
                        color: _matteGreen,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCC1EB48A),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final side = math.min(800.0, math.max(mq.width, mq.height) * 1.5);

    return IgnorePointer(
      child: Opacity(
        opacity: _glowOpacity,
        child: Transform.scale(
          scale: _glowScale,
          child: SizedBox(
            width: side,
            height: side,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.65,
                  colors: [
                    Color.fromRGBO(30, 180, 138, 0.2),
                    Color(0x00000000),
                  ],
                  stops: [0.0, 0.65],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(double fontSize, double letterSpacing) {
    final blur = lerpDouble(8, 0, _textRevealT)!;
    final dy = lerpDouble(20, 0, _textRevealT)!;
    final scale = lerpDouble(0.95, 1.0, _textRevealT)!;
    final textOpacity = _textRevealT;

    final baseStyle = GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: letterSpacing,
      height: 1.0,
    );

    final shift = -2.0 * _shinePhase;
    final gradient = LinearGradient(
      begin: Alignment(shift, 0),
      end: Alignment(shift + 2, 0),
      colors: const [
        Colors.white,
        Color(0xFF999999),
        _matteGreen,
        Color(0xFF999999),
        Colors.white,
      ],
      stops: const [0.0, 0.2, 0.5, 0.6, 1.0],
    );

    Widget textLayer = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        'PAYCHEK',
        textAlign: TextAlign.center,
        style: baseStyle.copyWith(color: Colors.white),
      ),
    );

    if (blur > 0.1) {
      textLayer = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: textLayer,
      );
    }

    return Opacity(
      opacity: textOpacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Transform.scale(
          scale: scale,
          child: textLayer,
        ),
      ),
    );
  }
}



