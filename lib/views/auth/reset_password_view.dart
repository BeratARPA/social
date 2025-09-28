import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_constant.dart';
import 'package:social/l10n/app_localizations.dart';
import 'package:social/view_models/auth/auth_viewmodel.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_elevated_button.dart';
import 'package:social/widgets/custom_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final actionToken = args["actionToken"];
    final target = args["target"];

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
        child: Column(
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
                      const Text(
                        "Lütfen yeni şifrenizi girin",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: newPasswordController,
                        hintText: AppLocalizations.of(context)!.password,
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
                      CustomTextField(
                        controller: confirmPasswordController,
                        hintText: AppLocalizations.of(context)!.confirmPassword,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: CustomElevatedButton(
                          buttonText: "Şifreyi Sıfırla",
                          onPressed: () async {
                            await viewModel.resetPassword(
                              actionToken,
                              target,
                              newPasswordController.text.trim(),
                              confirmPasswordController.text.trim(),
                            );
                          },
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
      ),
    );
  }
}
