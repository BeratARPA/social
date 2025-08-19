import 'package:flutter/material.dart';
import 'package:social/helpers/app_color.dart';

class AppThemes {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    fontFamily: "Montserrat",
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.primary,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      onPrimary: AppColors.white,
      onSecondary: AppColors.lightText,
      onBackground: AppColors.lightText,
      onSurface: AppColors.lightText,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightSecondaryText),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightBackground,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
      labelStyle: TextStyle(color: AppColors.lightSecondaryText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    dividerColor: AppColors.lightDivider,
    cardColor: AppColors.lightSurface,
    dialogBackgroundColor: AppColors.lightSurface,
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: "Montserrat",
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.darkText),
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.white,
      onSecondary: AppColors.darkText,
      onBackground: AppColors.darkText,
      onSurface: AppColors.darkText,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkSecondaryText),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
      labelStyle: TextStyle(color: AppColors.darkSecondaryText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    dividerColor: AppColors.darkDivider,
    cardColor: AppColors.darkSurface,
    dialogBackgroundColor: AppColors.darkSurface,
  );
}
