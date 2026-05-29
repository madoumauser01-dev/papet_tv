import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme(int index) {
    Color primaryColor;
    Color secondaryColor;
    Color backgroundColor;
    Color surfaceColor;

    switch (index) {
      case 1: // Deep Purple Theme
        primaryColor = const Color(0xFF8B5CF6);
        secondaryColor = const Color(0xFF10B981);
        backgroundColor = const Color(0xFF0C0A0F);
        surfaceColor = const Color(0xFF161320);
        break;
      case 2: // Dark Charcoal Theme
        primaryColor = const Color(0xFF94A3B8);
        secondaryColor = const Color(0xFF3B82F6);
        backgroundColor = const Color(0xFF0B0F19);
        surfaceColor = const Color(0xFF171F30);
        break;
      default: // Theme 0: Dark Blue / Indigo (Default)
        primaryColor = const Color(0xFF6366F1);
        secondaryColor = const Color(0xFFEC4899);
        backgroundColor = const Color(0xFF090A0F);
        surfaceColor = const Color(0xFF131520);
        break;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: const Color(0xFFEF4444),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        TextTheme(
          displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
          titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: const TextStyle(fontSize: 16, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          bodySmall: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade400, fontFamily: GoogleFonts.inter().fontFamily),
        hintStyle: TextStyle(color: Colors.grey.shade600, fontFamily: GoogleFonts.inter().fontFamily),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        buttonColor: primaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: index == 2 ? Colors.black : Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
    );
  }
}
