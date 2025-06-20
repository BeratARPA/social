import 'package:flutter/material.dart';
import 'package:social/enums/app_theme_mode.dart';
import 'package:social/services/theme_service.dart';

extension ThemeExtension on BuildContext {
  Brightness get brightness => Theme.of(this).brightness;

  T themeValue<T>({required T light, required T dark}) {
    if (ThemeService.currentThemeMode == AppThemeMode.system) {
      return brightness == Brightness.dark ? dark : light;
    } else if (ThemeService.currentThemeMode == AppThemeMode.dark) {
      return dark;
    } else {
      return light;
    }
  }
}
