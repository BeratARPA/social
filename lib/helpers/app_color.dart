import 'package:flutter/material.dart';

class AppColors {
  // Ortak (her iki tema için de geçerli)
  static const Color primary = Color(0xFF5DB5F0);
  static const Color secondary = Color(0xFFA5D9F9);
  static const Color accent = Color(0xFF38BDF8);
  static const Color white = Color(0xFFFFFFFF);

  // Light Theme
  static const Color lightBackground = Color(0xFFF5F9FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1C1C1C);
  static const Color lightSecondaryText = Color(0xFF4F4F4F);
  static const Color lightDivider = Color(0xFFE0E7F0);
  static const Color lightBorder = Color(0xFFD6E4F0);
  static const Color lightShadow = Color(0xFFC9D8E8);
  static const Color lightDisabled = Color(0xFFBFDFF2);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkSecondaryText = Color(0xFF94A3B8);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF3A4B63);
  static const Color darkShadow = Color(0xFF000000);
  static const Color darkDisabled = Color(0xFF1E3A5F);

  // Gradients
  static const Gradient lightGradient = LinearGradient(
    colors: [Color(0xFFEAF6FF), Color(0xFFC6E4F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
