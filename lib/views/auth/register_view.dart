import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_constant.dart';
import 'package:social/helpers/app_navigator.dart';
import 'package:social/l10n/app_localizations.dart';
import 'package:social/view_models/auth/auth_viewmodel.dart';
import 'package:social/widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.themeValue(
            light: AppColors.lightGradient,
            dark: AppColors.darkGradient,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 32),
                  Image.asset(
                    AppConstant.brandLogoPath,
                    width: 150,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                  Text(
                    AppConstant.brandName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: usernameController,
                              hintText: AppLocalizations.of(context)!.username,
                              prefixIcon: Icons.person,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: emailController,
                              hintText: AppLocalizations.of(context)!.email,
                              prefixIcon: Icons.email,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: passwordController,
                              hintText: AppLocalizations.of(context)!.password,
                              prefixIcon: Icons.lock,
                              isPassword: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: confirmPasswordController,
                              hintText:
                                  AppLocalizations.of(context)!.confirmPassword,
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await viewModel.register(
                                    usernameController.text.trim(),
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                    confirmPasswordController.text.trim(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.register,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.alreadyHaveAccount,
                                ),
                                TextButton(
                                  onPressed: () {
                                    AppNavigator.pop(); // veya pushNamed('/login');
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.login,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Text('© ISC'),
                  const SizedBox(height: 8),
                ],
              ),
              if (viewModel.isLoading)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
