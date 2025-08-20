import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/view_models/auth/auth_viewmodel.dart';
import 'package:social/widgets/custom_elevated_button.dart';
import 'package:social/widgets/custom_pinput.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    final args = ModalRoute.of(context)!.settings.arguments;
    final email = args is String ? args : null;

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
                          "E-Posta adresine gönderilen 6 haneli kodu giriniz.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                        CustomPinput(
                          controller: codeController,
                          length: 6,
                          showCursor: false,
                          obscureText: false,
                          onCompleted: (pin) {},
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: CustomElevatedButton(
                            buttonText: "Doğrula",
                            onPressed: () async {
                              viewModel.verifyEmail(
                                email!,
                                codeController.text.trim(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Bir kod almadınız mı?"),
                            TextButton(
                              onPressed: () async {
                                viewModel.resendEmailVerification(email!);
                              },
                              child: Text("Tekrar Gönder"),
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
        ),
      ),
    );
  }
}
