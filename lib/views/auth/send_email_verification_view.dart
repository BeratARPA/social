import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/l10n/app_localizations.dart';
import 'package:social/view_models/auth/auth_viewmodel.dart';
import 'package:social/widgets/custom_elevated_button.dart';
import 'package:social/widgets/custom_text_field.dart';

class SendEmailVerificationView extends StatefulWidget {
  const SendEmailVerificationView({super.key});

  @override
  State<SendEmailVerificationView> createState() =>
      _SendEmailVerificationViewState();
}

class _SendEmailVerificationViewState extends State<SendEmailVerificationView> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
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
          child: Column(
            children: [
              const SizedBox(height: 32),
              Image.asset(
                'assets/images/app_logo_foreground.png',
                width: 150,
                height: 150,
                fit: BoxFit.fill,
              ),
              const Text(
                'SOCIAL',
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
                          "E-Posta adresinizi girin, kod göndereceğiz.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 24),
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
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: CustomElevatedButton(
                            buttonText: "Gönder",
                            onPressed: () async {
                              await viewModel.sendEmailVerification(
                                emailController.text.trim(),
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
      ),
    );
  }
}
