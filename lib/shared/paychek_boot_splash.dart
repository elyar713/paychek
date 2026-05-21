import 'package:flutter/material.dart';

/// Écran neutre pendant la résolution auth / gate (évite flash landing ↔ app).
class PaychekBootSplash extends StatelessWidget {
  const PaychekBootSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.shrink(),
    );
  }
}
