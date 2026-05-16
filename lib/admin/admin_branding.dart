import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'admin_theme.dart';

/// Identité alignée sur l’app web Paychek (nom + visuel proche du rail).
abstract final class AdminBranding {
  AdminBranding._();

  static const String appName = 'PAYCHEK';
  static const String adminSubtitle = 'Console admin';

  /// Logo vectoriel (branding Paychek).
  static const String logoAssetSvg = 'assets/branding/app_icon.svg';
}

/// Rangée logo + titres pour la barre latérale et l’écran de connexion.
class PaychekAdminLogoRow extends StatelessWidget {
  const PaychekAdminLogoRow({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 36.0 : 44.0;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: logoSize,
            height: logoSize,
            child: SvgPicture.asset(
              AdminBranding.logoAssetSvg,
              fit: BoxFit.contain,
              placeholderBuilder: (context) =>
                  _FallbackMark(size: logoSize),
            ),
          ),
        ),
        SizedBox(width: compact ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AdminBranding.appName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: compact ? 0.8 : 1.0,
                      fontSize: compact ? 14 : 16,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                AdminBranding.adminSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.textDim,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 0.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FallbackMark extends StatelessWidget {
  const _FallbackMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AdminTheme.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.trending_up_rounded, size: size * 0.45, color: Colors.black87),
    );
  }
}
