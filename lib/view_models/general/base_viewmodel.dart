import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
      notifyListeners();
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
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
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

  @override
  void dispose() {
    super.dispose();
  }

  void resetAll() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
