import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_constant.dart';
import 'package:social/helpers/app_navigator.dart';
import 'package:social/l10n/app_localizations.dart';
import 'package:social/view_models/auth/auth_viewmodel.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    return MainLayoutView(
      showAppBar: false,
      showNavbar: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: context.themeValue(
            light: AppColors.lightGradient,
            dark: AppColors.darkGradient,
          ),
        ),
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                AppLocalizations.of(context)!.forgotPassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                await viewModel.login(
                                  usernameController.text.trim(),
                                  passwordController.text.trim(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                // Marka ana tonu
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.login,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Divider(thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(AppLocalizations.of(context)!.or),
                              ),
                              Expanded(child: Divider(thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () async {
                              AppNavigator.pushNamed('/register');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 24,
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.createNewAccount,
                              style: TextStyle(fontSize: 16),
                            ),
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
    );
  }
}
