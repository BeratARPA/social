import 'package:social/helpers/app_navigator.dart';
import 'package:social/services/social_api_service.dart';
import 'package:social/view_models/general/base_viewmodel.dart';

class AuthViewModel extends BaseViewModel {
  final SocialApiService _socialApiService;

  bool _canResend = true;
  bool get canResend => _canResend;

  AuthViewModel(this._socialApiService) {
    initConnectivityListener(); // internet dinleyici başlat
  }

  void _startResendTimer() {
    _canResend = false;
    notifyListeners();

    Future.delayed(const Duration(seconds: 30), () {
      _canResend = true;
      notifyListeners();
    });
  }

  Future<void> login(String username, String password) async {
    await runWithInternetCheck(() async {
      if (username.isEmpty || password.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        return;
      }

      var result = await _socialApiService.login(username, password);
      if (!result.isSuccess) {
        if (result.errorCode == "EmailNotConfirmed") {
          await AppNavigator.pushNamed("/send-email-verification");
          return;
        }

        if (result.errorCode == "UserNotFound") {
          AppNavigator.showSnack("Kullanıcı Bulunamadı");
          return;
        }

        AppNavigator.showSnack(result.errorCode!);
        return;
      }

      clearError();
      AppNavigator.showSnack("Giriş başarılı");
      AppNavigator.pushReplacementNamed("/home");
    });
  }

  Future<void> verifyEmail(String email, String code) async {
    await runWithInternetCheck(() async {
      if (email.isEmpty || code.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        return;
      }

      var result = await _socialApiService.verifyEmail(email, code);
      if (!result.isSuccess) {
        if (result.errorCode == "ConfirmationCodeExpired") {
          AppNavigator.showSnack("Onay Kodu Süresi Doldu");
          return;
        }

        AppNavigator.showSnack(result.errorCode!);
        return;
      }

      clearError();
      AppNavigator.showSnack("Email doğrulama başarılı");
      AppNavigator.popUntil((route) => route.isFirst);
    });
  }

  Future<void> register(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    await runWithInternetCheck(() async {
      if (username.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        return;
      }

      if (password != confirmPassword) {
        AppNavigator.showSnack("Şifreler uyuşmuyor");
        return;
      }

      var result = await _socialApiService.register(username, email, password);
      if (!result.isSuccess) {
        if (result.errorCode == "UsernameAlreadyExists") {
          AppNavigator.showSnack("Kullanıcı adı zaten mevcut");
          return;
        }

        if (result.errorCode == "EmailAlreadyExists") {
          AppNavigator.showSnack("Bu e-posta zaten kayıtlı");
          return;
        }

        AppNavigator.showSnack(result.errorCode!);
        return;
      }

      clearError();
      await sendEmailVerification(email);
    });
  }

  Future<void> resendEmailVerification(String email) async {
    await runWithInternetCheck(() async {
      if (email.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        return;
      }

      if (!_canResend) {
        AppNavigator.showSnack("30 saniye sonra tekrar deneyin");
        return;
      }

      _startResendTimer(); // Timer'ı başlat

      var result = await _socialApiService.sendEmailVerification(email);
      if (!result.isSuccess) {
        // Hata durumunda timer'ı sıfırla
        _canResend = true;
        notifyListeners();

        if (result.errorCode == "UserNotFound") {
          AppNavigator.showSnack("Kullanıcı Bulunamadı");
          return;
        }

        AppNavigator.showSnack(result.errorCode!);
        return;
      }

      clearError();
      AppNavigator.showSnack("E-posta doğrulama kodu gönderildi");
    });
  }

  Future<void> sendEmailVerification(String email) async {
    await runWithInternetCheck(() async {
      if (email.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        return;
      }

      if (!_canResend) {
        AppNavigator.showSnack("30 saniye sonra tekrar deneyin");
        return;
      }

      _startResendTimer(); // Timer'ı başlat

      var result = await _socialApiService.sendEmailVerification(email);
      if (!result.isSuccess) {
        // Hata durumunda timer'ı sıfırla
        _canResend = true;
        notifyListeners();

        if (result.errorCode == "UserNotFound") {
          AppNavigator.showSnack("Kullanıcı Bulunamadı");
          return;
        }

        AppNavigator.showSnack(result.errorCode!);
        return;
      }

      clearError();
      AppNavigator.showSnack("E-posta doğrulama kodu gönderildi");
      await AppNavigator.pushNamed("/verify-email", arguments: email);
    });
  }

  Future<void> logout() async {
    await runWithInternetCheck(() async {
      var result = await _socialApiService.logout();
      if (!result.isSuccess) {
        AppNavigator.showSnack(result.errorCode!);
        return;
      }

      AppNavigator.showSnack("Çıkış yapıldı");
    });
  }
}
