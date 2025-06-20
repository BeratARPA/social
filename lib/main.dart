import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:social/firebase_options.dart';
import 'package:social/helpers/app_navigator.dart';
import 'package:social/helpers/app_storage.dart';
import 'package:social/helpers/app_themes.dart';
import 'package:social/l10n/app_localizations.dart';
import 'package:social/l10n/l10n.dart';
import 'package:social/services/auth_service.dart';
import 'package:social/services/localization_service.dart';
import 'package:social/services/theme_service.dart';
import 'package:social/view_models/auth/auth_viewmodel.dart';
import 'package:social/views/auth/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppStorage.init();

  final themeService = ThemeService();
  await themeService.loadTheme();

  final localizationService = LocalizationService();
  await localizationService.loadLocale();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => AuthService()),

        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: localizationService),
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
    final themeService = Provider.of<ThemeService>(context, listen: true);
    final localizationService = Provider.of<LocalizationService>(
      context,
      listen: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      supportedLocales: l10n.all,
      locale: localizationService.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeService.materialThemeMode,

      navigatorKey: AppNavigator.navigatorKey,
      initialRoute: "/login",
      routes: {"/login": (context) => const LoginView()},
    );
  }
}
