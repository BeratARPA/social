import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/firebase_options.dart';
import 'package:social/helpers/app_navigator.dart';
import 'package:social/services/auth_service.dart';
import 'package:social/view_models/auth/auth_viewmodel.dart';
import 'package:social/views/auth/login_view.dart';
import 'package:social/views/general/splash_screen_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => AuthService()),

        ChangeNotifierProvider(
          create: (context) => AuthViewModel(context.read<AuthService>()),
        ),
      ],

      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.navigatorKey,
      initialRoute: "/splashScreen",
      routes: {
        "/splashScreen": (context) => const SplashScreenView(),
        "/login": (context) => const LoginView(),
      },
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
