import 'package:flutter/material.dart';

import '../paychek_billing_plan.dart';
import '../paywall/mobile/paychek_mobile_upgrade_paywall.dart';

/// Paywall marketing Gold — mobile & web : plans + tableau comparatif unifié or.
class GoldUpgradeFlutterPaywall extends StatelessWidget {
  const GoldUpgradeFlutterPaywall({
    super.key,
    required this.onSubscribe,
    this.onClose,
    this.showTopClose = false,
  });

  final Future<void> Function(PaychekBillingCycle cycle) onSubscribe;
  final VoidCallback? onClose;
  final bool showTopClose;

  @override
  Widget build(BuildContext context) {
    return PaychekMobileUpgradePaywall(
      showTopClose: showTopClose,
      onClose: onClose,
      onSubscribe: onSubscribe,
    );
  }
}
