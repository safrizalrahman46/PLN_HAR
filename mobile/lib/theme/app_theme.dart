import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF004581);
  static const Color primaryContainer = Color(0xFF005DAA);
  static const Color onPrimaryContainer = Color(0xFFBED7FF);
  static const Color secondary = Color(0xFF725C00);
  static const Color secondaryContainer = Color(0xFFFED000);
  static const Color onSecondaryContainer = Color(0xFF231B00);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceContainerLow = Color(0xFFF1F5F9);
  static const Color surfaceContainer = Color(0xFFE2E8F0);
  static const Color surfaceContainerHigh = Color(0xFFCBD5E1);
  static const Color surfaceContainerHighest = Color(0xFF94A3B8);
  static const Color outline = Color(0xFF64748B);
  static const Color outlineVariant = Color(0xFFCBD5E1);
  static const Color error = Color(0xFFDC2626);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
