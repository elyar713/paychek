import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'web_landing_auth_dialogs.dart';
import 'web_return_to_landing_stub.dart'
    if (dart.library.html) 'web_return_to_landing_web.dart';

bool paychekIsAuthOverlayFrame() {
  try {
    return Uri.base.queryParameters['overlay'] == '1';
  } catch (_) {
    return false;
  }
}

/// Connexion / inscription pour `/?auth=login|signup`.
class WebLandingAuthQueryHost extends StatelessWidget {
  const WebLandingAuthQueryHost({
    super.key,
    required this.signup,
    this.oauthError,
  });

  final bool signup;
  final String? oauthError;

  @override
  Widget build(BuildContext context) {
    final overlay = paychekIsAuthOverlayFrame();
    return Scaffold(
      backgroundColor: overlay ? Colors.transparent : Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (oauthError != null && oauthError!.trim().isNotEmpty)
            Material(
              color: const Color(0xFF3F1010),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text(
                  oauthError!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.4,
                    color: const Color(0xFFFFB4B4),
                  ),
                ),
              ),
            ),
          Expanded(
            child: WebLandingAuthShell(
              signup: signup,
              transparentBackground: overlay,
              onClose: overlay
                  ? paychekCloseAuthOverlay
                  : paychekReturnToLandingIfAuthCancelled,
              onAuthSuccess: overlay
                  ? paychekCompleteAuthOverlaySuccess
                  : paychekReturnToLandingAfterLogin,
            ),
          ),
        ],
      ),
    );
  }
}
