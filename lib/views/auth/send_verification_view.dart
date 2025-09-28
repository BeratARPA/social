import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/enums/verification_channel.dart';
import 'package:social/enums/verification_type.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_constant.dart';
import 'package:social/l10n/app_localizations.dart';
import 'package:social/view_models/auth/auth_viewmodel.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_elevated_button.dart';
import 'package:social/widgets/custom_text_field.dart';

class SendVerificationView extends StatefulWidget {
  const SendVerificationView({super.key});

  @override
  State<SendVerificationView> createState() => _SendVerificationViewState();
}

class _SendVerificationViewState extends State<SendVerificationView> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    final args = ModalRoute.of(context)!.settings.arguments as Map;
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
                            await viewModel.sendVerification(
                              verificationChannel,
                              verificationType,
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
    );
  }
}
