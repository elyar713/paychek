import 'dart:async' show unawaited;



import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';



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



/// Modale auth pour `/?auth=login|signup` — sans recharger la landing en iframe.

class WebLandingAuthQueryHost extends StatefulWidget {

  const WebLandingAuthQueryHost({super.key, required this.signup});



  final bool signup;



  @override

  State<WebLandingAuthQueryHost> createState() => _WebLandingAuthQueryHostState();

}



class _WebLandingAuthQueryHostState extends State<WebLandingAuthQueryHost> {

  bool _authDialogStarted = false;



  @override

  void initState() {

    super.initState();

    if (!paychekIsAuthOverlayFrame()) {

      WidgetsBinding.instance.addPostFrameCallback((_) {

        unawaited(_openAuthDialog());

      });

    }

  }



  Future<void> _openAuthDialog() async {

    if (!mounted || _authDialogStarted) return;

    _authDialogStarted = true;

    final host = context;

    if (!host.mounted) return;

    if (widget.signup) {

      await showWebLandingSignupDialog(

        host,

        onAuthSuccessBeforePop: paychekStripAuthQueryFromUrl,

      );

    } else {

      await showWebLandingLoginDialog(

        host,

        onAuthSuccessBeforePop: paychekStripAuthQueryFromUrl,

      );

    }

    if (!host.mounted) return;

    if (FirebaseAuth.instance.currentUser == null) {

      paychekReturnToLandingIfAuthCancelled();

    }

  }



  @override

  Widget build(BuildContext context) {

    if (paychekIsAuthOverlayFrame()) {

      return WebLandingAuthShell(

        signup: widget.signup,

        transparentBackground: true,

        onClose: paychekCloseAuthOverlay,

        onAuthSuccess: paychekCompleteAuthOverlaySuccess,

      );

    }

    return const Scaffold(

      backgroundColor: Colors.transparent,

      body: SizedBox.shrink(),

    );

  }

}


