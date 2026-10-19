import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // PLN Electric Blue & Cyan brand palette (As seen in PLN Mobile & Modern SaaS apps)
  static const Color primary = Color(0xFF0096D6); // PLN Vibrant Cyan Blue
  static const Color primaryDark = Color(0xFF004F8A); // Deep PLN Corporate Navy
  static const Color primaryDeep = Color(0xFF002F55); // Rich Midnight Navy
  static const Color primaryContainer = Color(0xFF0077B6);
  static const Color onPrimaryContainer = Color(0xFFE0F2FE);
  
  // PLN Lightning Yellow & Accents
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryContainer = Color(0xFFFFD000); // PLN Lightning Yellow
  static const Color onSecondaryContainer = Color(0xFF1E293B);
  static const Color accentCyan = Color(0xFF00C0F3);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF8B5CF6);
  
  // Neutral slate backgrounds & surfaces
  static const Color background = Color(0xFFF4F7FB); // Modern soft cool background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);
  static const Color surfaceContainerHighest = Color(0xFFCBD5E1);
  
  // Outlines & Typography
  static const Color outline = Color(0xFF64748B); // Slate 500
  static const Color outlineVariant = Color(0xFFE2E8F0); // Slate 200
  static const Color textDark = Color(0xFF0F172A); // Slate 900
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color error = Color(0xFFEF4444);

  // Signature Gradients
  static const LinearGradient plnHeroGradient = LinearGradient(
    colors: [Color(0xFF00437A), Color(0xFF0072B5), Color(0xFF00A2E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient plnElectricGradient = LinearGradient(
    colors: [Color(0xFF0096D6), Color(0xFF00C2FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient yellowLightningGradient = LinearGradient(
    colors: [Color(0xFFFFD500), Color(0xFFFFAB00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF003865), Color(0xFF005A9C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft modern shadows (Tasktugas & PLN Mobile style)
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF003B66).withValues(alpha: 0.07),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme();

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
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textDark,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: outline,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        iconTheme: const IconThemeData(color: primaryDark),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textDark,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
