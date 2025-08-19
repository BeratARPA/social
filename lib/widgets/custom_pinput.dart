import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/extensions/theme_extension.dart';

class CustomPinput extends StatefulWidget {
  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool showCursor;
  final bool obscureText;

  const CustomPinput({
    super.key,
    this.length = 6,
    this.controller,
    this.focusNode,
    this.onCompleted,
    this.onChanged,
    this.validator,
    this.showCursor = true,
    this.obscureText = false,
  });

  @override
  State<CustomPinput> createState() => _CustomPinputState();
}

class _CustomPinputState extends State<CustomPinput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: context.themeValue(
          light: AppColors.lightText,
          dark: AppColors.darkText,
        ),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightSurface,
          dark: AppColors.darkSurface,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.themeValue(
            light: AppColors.lightBorder,
            dark: AppColors.darkBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.themeValue(
              light: AppColors.lightShadow.withOpacity(0.3),
              dark: Colors.black.withOpacity(0.4),
            ),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );

    // Focused theme
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    // Submitted theme
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primary.withOpacity(0.1),
      ),
    );

    return Pinput(
      length: widget.length,
      controller: _controller,
      focusNode: _focusNode,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      showCursor: widget.showCursor,
      obscureText: widget.obscureText,
      onCompleted: widget.onCompleted,
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}
