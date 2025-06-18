import 'package:social/view_models/base_viewmodel.dart';

class SplashScreenViewModel extends BaseViewModel {
  SplashScreenViewModel() {
    // Initialize any necessary data or state here
  }

  Future<void> initialize() async {
    // Simulate some initialization work
    await Future.delayed(Duration(seconds: 2));
    // After initialization, you can navigate to the next screen or perform other actions
    // For example, you might want to notify listeners that initialization is complete
    safeNotifyListeners();
  }
}