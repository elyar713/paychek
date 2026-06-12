import 'package:flutter/material.dart';

/// Écran neutre pendant la résolution auth / gate (évite flash landing ↔ app).
class PaychekBootSplash extends StatelessWidget {
  const PaychekBootSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF34D399),
          ),
        ),
      ),
    );
  }
}
