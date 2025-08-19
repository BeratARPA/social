import 'package:social/helpers/app_navigator.dart';
import 'package:social/services/social_api_service.dart';
import 'package:social/view_models/general/base_viewmodel.dart';

class AuthViewModel extends BaseViewModel {
  final SocialApiService _socialApiService;

  AuthViewModel(this._socialApiService) {
    initConnectivityListener(); // internet dinleyici başlat
  }

  Future<void> login(String username, String password) async {
    await runWithInternetCheck(() async {
      if (username.isEmpty || password.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        return;
      }

      var result = await _socialApiService.login(username, password);
      if (!result.isSuccess) {
        AppNavigator.showSnack(result.errorCode!);

        if (result.errorCode == "EmailNotConfirmed") {
          await AppNavigator.pushNamed("/send-email-verification");
        }
        return;
      }

      clearError();
      AppNavigator.showSnack("Giriş başarılı");
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

      var result = await _socialApiService.register(username, email, password);
      if (!result.isSuccess) {
        AppNavigator.showSnack(result.errorCode!);

        if (result.errorCode == "EmailNotConfirmed") {
          // Özel handling burada
        }
        return;
      }

      clearError();
      AppNavigator.showSnack("Kayıt başarılı");
    });
  }

  bool canResend = true;
  Future<void> sendEmailVerification(String email) async {
    await runWithInternetCheck(() async {
      if (email.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        canResend = true;
        return;
      }

      if (!canResend) return;
      canResend = false;

      var result = await _socialApiService.sendEmailVerification(email);
      if (!result.isSuccess) {
        AppNavigator.showSnack(result.errorCode!);

        return;
      }

      clearError();
      AppNavigator.showSnack("E-posta doğrulama bağlantısı gönderildi");
      await AppNavigator.pushNamed("/verify-email", arguments: email);

      // 30 saniye sonra tekrar aktif et
      Future.delayed(const Duration(seconds: 30), () {
        canResend = true;
      });
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
