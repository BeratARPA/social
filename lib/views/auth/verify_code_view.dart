import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/enums/verification_channel.dart';
import 'package:social/enums/verification_type.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_constant.dart';
import 'package:social/view_models/auth/auth_viewmodel.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_elevated_button.dart';
import 'package:social/widgets/custom_pinput.dart';

class VerifyCodeView extends StatefulWidget {
  const VerifyCodeView({super.key});

  @override
  State<VerifyCodeView> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<VerifyCodeView> {
  final codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final target = args["target"];
    final verificationType = args["verificationType"] as VerificationType;
    final verificationChannel =
        args["verificationChannel"] as VerificationChannel;

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
                            await viewModel.verifyCode(
                              verificationChannel,
                              verificationType,
                              target!,
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
                              viewModel.resendVerification(
                                verificationChannel,
                                verificationType,
                                target!,
                              );
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
    );
  }
}
