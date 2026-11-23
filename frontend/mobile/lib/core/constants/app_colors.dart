import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents
  static const Color primary = Color(0xFF0066FF); // Electric Blue Brand
  static const Color primaryDark = Color(0xFF004EC2);
  static const Color primaryLight = Color(0xFFEFF4FF);
  
  // Neutral & Surfaces
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status & Badges (Semantik PRD 5.1)
  static const Color success = Color(0xFF10B981); // Diterbitkan / Valid
  static const Color successBg = Color(0xFFECFDF5);
  static const Color successText = Color(0xFF047857);

  static const Color warning = Color(0xFFF59E0B); // Perlu Revisi / Menunggu
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningText = Color(0xFFB45309);

  static const Color review = Color(0xFF0284C7); // Dalam Review / Diajukan
  static const Color reviewBg = Color(0xFFF0F9FF);
  static const Color reviewText = Color(0xFF0369A1);

  static const Color error = Color(0xFFEF4444); // Ditolak
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorText = Color(0xFFB91C1C);

  static const Color draft = Color(0xFF64748B); // Draft
  static const Color draftBg = Color(0xFFF1F5F9);
  static const Color draftText = Color(0xFF475569);
}
