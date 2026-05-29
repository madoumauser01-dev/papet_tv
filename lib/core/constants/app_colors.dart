import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF090A0F);
  static const Color surface = Color(0xFF131520);
  static const Color surfaceLight = Color(0xFF1E2235);
  
  // Accents
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryGlow = Color(0xFF818CF8);
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color accent = Color(0xFFF59E0B); // Amber/Gold
  
  // Neutrals
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFF2E334D);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white10, Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient playerOverlayGradient = LinearGradient(
    colors: [Colors.black87, Colors.transparent, Colors.black87],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
