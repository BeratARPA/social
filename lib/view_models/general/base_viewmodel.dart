import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  bool _disposed = false;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _darkMode = false;
  bool get isDarkMode => _darkMode;

  void log(String message) {
    debugPrint('[${runtimeType.toString()}]: $message');
  }

  Future<void> retry(
    Function action, {
    int retryCount = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < retryCount; i++) {
      try {
        await action();
        return;
      } catch (e) {
        if (i == retryCount - 1) setError(e.toString());
        await Future.delayed(delay);
      }
    }
  }

  void initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((status) {
      _isConnected = status != ConnectivityResult.none;
      safeNotifyListeners();
    });
  }

  Future<void> runWithInternetCheck(Future<void> Function() operation) async {
    if (!isConnected) {
      setError("İnternet bağlantısı yok.");
      return;
    }
    await runAsync(operation);
  }

  void setLoading(bool value) {
    _isLoading = value;
    safeNotifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    safeNotifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    safeNotifyListeners();
  }

  Future<void> runAsync(
    Future<void> Function() operation, {
    bool showLoading = true,
  }) async {
    if (showLoading) setLoading(true);
    try {
      await operation();
    } catch (e) {
      setError(e.toString());
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  void safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void toggleTheme() {
    _darkMode = !_darkMode;
    safeNotifyListeners();
  }

  void resetAll() {
    _isLoading = false;
    _errorMessage = null;
    safeNotifyListeners();
  }
}
