import 'package:flutter/material.dart';
import 'package:social/helpers/app_storage.dart';
import 'package:social/view_models/general/base_viewmodel.dart';

class LocalizationService extends BaseViewModel {
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> loadLocale() async {
    final code = AppStorage.getString(AppStorage.localeKey);
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await AppStorage.setString(AppStorage.localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = null;
    await AppStorage.remove(AppStorage.localeKey);
    notifyListeners();
  }
}
