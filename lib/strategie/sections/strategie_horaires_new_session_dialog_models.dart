import 'package:flutter/material.dart';

/// Résultat du dialogue **Nouvelle session** (section Stratégie).
///
/// Constructeur **non-const** : avec `const`, le hot reload refuse souvent toute
/// modification des champs (« Const class cannot remove fields »).
class StrategieNewSessionDialogResult {
  // ignore: prefer_const_constructors_in_immutables
  StrategieNewSessionDialogResult({
    required this.title,
    required this.description,
    this.startTime,
    this.endTime,
    required this.isNoTradeZone,
  });

  final String title;
  final String description;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  /// `true` = option **No Trade** sélectionnée.
  final bool isNoTradeZone;
}

/// Valeurs initiales pour **édition** (même dialogue que nouvelle session).
class StrategieNewSessionDialogInitial {
  const StrategieNewSessionDialogInitial({
    required this.title,
    required this.description,
    this.startTime,
    this.endTime,
    this.isNoTradeZone = false,
  });

  final String title;
  final String description;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isNoTradeZone;
}
