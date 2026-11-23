import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Headings & Display
  static TextStyle displayBold({double size = 20, Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle headingBold({double size = 16, Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: color,
    );
  }

  static TextStyle headingSemiBold({double size = 14, Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  // UI & Body
  static TextStyle bodyMedium({double size = 13, Color color = AppColors.textSecondary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.45,
    );
  }

  static TextStyle bodyRegular({double size = 13, Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  static TextStyle labelBold({double size = 11, Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: color,
    );
  }

  static TextStyle caption({double size = 11, Color color = AppColors.textMuted}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
}
