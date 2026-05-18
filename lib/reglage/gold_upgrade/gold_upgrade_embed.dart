import 'package:flutter/material.dart';

import '../paychek_billing_plan.dart';
import 'gold_upgrade_flutter_paywall.dart';

/// Paywall Gold **100 % Flutter** (mobile : maquette 3 plans ; web : legacy).
Widget buildGoldUpgradeEmbed(
  BuildContext context, {
  required Future<void> Function(PaychekBillingCycle cycle) onSubscribe,
  VoidCallback? onClose,
  bool showTopClose = false,
}) {
  return GoldUpgradeFlutterPaywall(
    onSubscribe: onSubscribe,
    onClose: onClose,
    showTopClose: showTopClose,
  );
}
