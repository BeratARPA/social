import 'package:flutter/material.dart';
import 'package:social/enums/app_theme_mode.dart';
import 'package:social/helpers/app_storage.dart';
import 'package:social/view_models/general/base_viewmodel.dart';

class ThemeService extends BaseViewModel {
  static AppThemeMode currentThemeMode = AppThemeMode.system;

  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> loadTheme() async {
    final saved = AppStorage.getString(AppStorage.themeKey) ?? 'system';

    _themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppThemeMode.system,
    );

    currentThemeMode = _themeMode;

    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    currentThemeMode = mode;
    await AppStorage.setString(AppStorage.themeKey, mode.name);
    notifyListeners();
  }
}
