// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get login => 'Log in';

  @override
  String get or => 'OR';

  @override
  String get createNewAccount => 'Create new account';

  @override
  String get alreadyHaveAccount => 'Do you already have an account?';

  @override
  String get register => 'Register';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get confirmPassword => 'Confirm Password';
}
