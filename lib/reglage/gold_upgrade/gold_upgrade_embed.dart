import 'package:flutter/material.dart';

import 'gold_upgrade_flutter_paywall.dart';

/// Paywall Gold **100 % Flutter** (toutes plateformes, y compris mobile — pas de HTML embarqué).
Widget buildGoldUpgradeEmbed(
  BuildContext context, {
  required Future<void> Function() onSubscribe,
}) {
  return GoldUpgradeFlutterPaywall(onSubscribe: onSubscribe);
}
