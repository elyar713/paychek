import 'package:flutter/material.dart';

/// Vert mat PAYCHEK (identique au winrate / anneau EM Dashboard).
const Color kMentalStateRingGreen = Color(0xFF1eb48a);
const Color kMentalStateMatteRed = Color(0xFFFF4D4D);

/// Métrique curseur 0–100 (routines, état du moment).
class MentalStateMetric {
  MentalStateMetric({
    required this.id,
    required this.label,
    required this.value,
    required this.weight,
    required this.inverse,
    required this.barColor,
    this.isMainSlider = false,
  });

  final String id;
  String label;
  double value;
  double weight;
  bool inverse;
  Color barColor;
  final bool isMainSlider;

  double normalizedForScore() => inverse ? (100 - value) : value;
}

/// Pastille émotion dominante (`data-value` + `data-weight` par bouton, comme le HTML).
class MentalStateEmotion {
  MentalStateEmotion({
    required this.id,
    required this.label,
    required this.value,
    this.weight = 50,
    this.inverse = false,
  });

  final String id;
  String label;
  final double value;
  double weight;
  /// Comme les autres facteurs : si `true`, une valeur élevée **réduit** le score (affichage % en rouge).
  bool inverse;

  double normalizedForScore() => inverse ? (100 - value) : value;
}
