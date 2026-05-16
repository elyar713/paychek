import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../firebase_options.dart';
import 'admin_auth_gate.dart';
import 'admin_theme.dart';

/// Point d’entrée web/desktop pour le back-office admin.
/// Ex. : `flutter run -d chrome -t lib/admin/main_admin.dart`
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Obligatoire sur Web pour DateFormat(..., 'fr_FR') dans les pages admin.
  await initializeDateFormatting('fr_FR');

  runApp(
    MaterialApp(
      title: 'Paychek • Console admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.theme(),
      home: const AdminAuthGate(),
    ),
  );
}
