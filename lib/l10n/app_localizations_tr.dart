// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get email => 'E-Posta';

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

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get register => 'Kayıt ol';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get confirmPassword => 'Şifreyi Onayla';
}
