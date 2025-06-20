import 'package:firebase_auth/firebase_auth.dart';
import 'package:social/helpers/app_navigator.dart';
import 'package:social/services/auth_service.dart';
import 'package:social/view_models/general/base_viewmodel.dart';

class AuthViewModel extends BaseViewModel {
  final AuthService _authService;

  User? user;

  AuthViewModel(this._authService) {
    // Kullanıcı durumunu dinle
    _authService.userChanges.listen((value) {
      user = value;
      notifyListeners();
    });

    initConnectivityListener(); // internet dinleyici başlat
  }

  Future<void> login(String email, String password) async {
    await runWithInternetCheck(() async {
      await runAsync(() async {
        user = await _authService.signIn(email, password);
        clearError();
        AppNavigator.showSnack("Giriş başarılı");
      });
    });
  }

  Future<void> register(String email, String password) async {
    await runWithInternetCheck(() async {
      await runAsync(() async {
        user = await _authService.register(email, password);
        clearError();
        AppNavigator.showSnack("Kayıt başarılı");
      });
    });
  }

  Future<void> logout() async {
    await runAsync(() async {
      await _authService.signOut();
      user = null;
      AppNavigator.showSnack("Çıkış yapıldı");
    });
  }

  bool get isAuthenticated => user != null;
}
