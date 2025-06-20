// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get emailOrUsername => 'E-Posta veya kullanıcı adı';

  @override
  String get password => 'Şifre';

  @override
  String get forgotPassword => 'Şifreni mi unuttun?';

  @override
  String get login => 'Giriş yap';

  @override
  String get or => 'YA DA';

  @override
  String get createNewAccount => 'Yeni hesap oluştur';
}
