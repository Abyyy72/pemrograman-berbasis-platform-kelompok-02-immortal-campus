import 'package:flutter/material.dart';

class AppDimens {
  static const double radiusButton = 12.0;
  static const double radiusCard = 16.0;
  static const double radiusSheet = 24.0;
  static const double pagePadding = 16.0;

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> bottomNavShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];
}
