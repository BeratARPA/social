import 'package:social/enums/verification_channel.dart';
import 'package:social/enums/verification_type.dart';
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
          await AppNavigator.pushNamed(
            "/send-verification",
            arguments: {
              "verificationType": VerificationType.verifyEmail,
              "verificationChannel": VerificationChannel.email,
            },
          );
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
      AppNavigator.pushReplacementNamed("/home");
    });
  }

  Future<void> verifyCode(
    VerificationChannel verificationChannel,
    VerificationType verificationType,
    String target,
    String code,
  ) async {
    await runWithInternetCheck(() async {
      if (target.isEmpty || code.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        return;
      }

      var result = await _socialApiService.verifyCode(
        verificationChannel,
        verificationType,
        target,
        code,
      );
      if (!result.isSuccess) {
        if (result.errorCode == "ConfirmationCodeExpired") {
          AppNavigator.showSnack("Onay Kodu Süresi Doldu");
          return;
        }

        AppNavigator.showSnack(result.errorCode!);
        return;
      }

      clearError();
      if (verificationType == VerificationType.resetPassword) {
        AppNavigator.pushNamed(
          "/reset-password",
          arguments: {
            "actionToken": result.data!.actionToken,
            "target": target,
          },
        );
      } else {
        AppNavigator.showSnack("Doğrulama başarılı");
        AppNavigator.popUntil((route) => route.isFirst);
      }
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
      await sendVerification(
        VerificationChannel.email,
        VerificationType.verifyEmail,
        email,
      );
    });
  }

  Future<void> resendVerification(
    VerificationChannel verificationChannel,
    VerificationType verificationType,
    String target,
  ) async {
    await runWithInternetCheck(() async {
      if (target.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        return;
      }

      if (!_canResend) {
        AppNavigator.showSnack("30 saniye sonra tekrar deneyin");
        return;
      }

      _startResendTimer(); // Timer'ı başlat

      var result = await _socialApiService.sendVerification(
        verificationChannel,
        verificationType,
        target,
      );
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

  Future<void> sendVerification(
    VerificationChannel verificationChannel,
    VerificationType verificationType,
    String target,
  ) async {
    await runWithInternetCheck(() async {
      if (target.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        return;
      }

      if (!_canResend) {
        AppNavigator.showSnack("30 saniye sonra tekrar deneyin");
        return;
      }

      _startResendTimer(); // Timer'ı başlat

      var result = await _socialApiService.sendVerification(
        verificationChannel,
        verificationType,
        target,
      );
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
      await AppNavigator.pushNamed(
        "/verify-code",
        arguments: {
          "target": target,
          "verificationType": verificationType,
          "verificationChannel": verificationChannel,
        },
      );
    });
  }

  Future<void> resetPassword(
    String actionToken,
    String email,
    String newPassword,
    String confirmNewPassword,
  ) async {
    await runWithInternetCheck(() async {
      if (email.isEmpty ||
          actionToken.isEmpty ||
          newPassword.isEmpty ||
          confirmNewPassword.isEmpty) {
        AppNavigator.showSnack("Lütfen tüm alanları doldurun");
        return;
      }

      if (newPassword != confirmNewPassword) {
        AppNavigator.showSnack("Şifreler uyuşmuyor");
        return;
      }

      var result = await _socialApiService.forgotPassword(
        actionToken,
        email,
        newPassword,
        confirmNewPassword,
      );
      if (!result.isSuccess) {
        if (result.errorCode == "InvalidCode") {
          AppNavigator.showSnack("Geçersiz kod");
          return;
        }

        if (result.errorCode == "ConfirmationCodeExpired") {
          AppNavigator.showSnack("Onay Kodu Süresi Doldu");
          return;
        }

        AppNavigator.showSnack(result.errorCode!);
        return;
      }

      clearError();
      AppNavigator.showSnack("Şifre sıfırlama başarılı");
      AppNavigator.popUntil((route) => route.isFirst);
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
