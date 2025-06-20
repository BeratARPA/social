import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/l10n/app_localizations.dart';
import 'package:social/view_models/auth/auth_viewmodel.dart';
import 'package:social/widgets/custom_elevated_button.dart';
import 'package:social/widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: emailController,
              labelText: AppLocalizations.of(context)!.email,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: passwordController,
              labelText: AppLocalizations.of(context)!.password,
              isPassword: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value ?? false;
                    });
                  },
                ),
                Text(AppLocalizations.of(context)!.rememberMe),
              ],
            ),
            const SizedBox(height: 16),
            CustomElevatedButton(
              onPressed: () {
                viewModel.isLoading
                    ? null
                    : () async {
                      await viewModel.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                      if (viewModel.isAuthenticated) {}
                    };
              },
              buttonText: AppLocalizations.of(context)!.login,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: Text(AppLocalizations.of(context)!.dontHaveAnAccount),
            ),
          ],
        ),
      ),
    );
  }
}
