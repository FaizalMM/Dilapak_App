import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Splash / Dilapak brand
  static const Color dilapakTeal = Color(0xFF2BBDB4);
  static const Color dilapakBackground = Color(0xFFEEF3F9);

  // Green theme (Register/Kependudukan)
  static const Color greenPrimary = Color(0xFF1A6B55);
  static const Color greenDark = Color(0xFF145244);
  static const Color greenAccent = Color(0xFF2ECC8E);

  // Blue theme (Onboarding / Login)
  static const Color bluePrimary = Color(0xFF1A4FA0);
  static const Color blueDark = Color(0xFF133A7A);
  static const Color blueAccent = Color(0xFF2D7DD2);
  static const Color blueLight = Color(0xFFEBF3FF);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF7F9FC);
  static const Color textPrimary = Color(0xFF1A1D23);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color inputBackground = Color(0xFFF9FAFB);
}

class AppTextStyles {
  static TextStyle headline1(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.25,
      );

  static TextStyle headline2(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle headline3(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle body(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.6,
      );

  static TextStyle bodyMedium(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodySmall(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle label(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle button(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.3,
      );

  static TextStyle appName(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle caption(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 1.2,
      );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.dilapakTeal,
          surface: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.white,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      );
}
