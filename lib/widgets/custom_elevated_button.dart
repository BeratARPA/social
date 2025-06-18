import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Widget? leadingIcon; // Butonun başına eklenmek üzere icon (opsiyonel)
  final Widget? trailingIcon; // Butonun sonuna eklenmek üzere icon (opsiyonel)
  final Color? backgroundColor; // Buton arka plan rengi (opsiyonel)
  final Color? foregroundColor; // Buton yazı ve icon rengi (opsiyonel)
  final double? width; // Buton genişliği (opsiyonel)
  final double? height; // Buton yüksekliği (opsiyonel)
  final bool enabled; // Butonun aktif/pasif durumu (opsiyonel)

  const CustomElevatedButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Varsayılan olarak Theme üzerinden değerleri atıyoruz, opsiyonel verilmiş ise onları kullanıyoruz.
    final Color resolvedBackgroundColor =
        backgroundColor ?? Theme.of(context).colorScheme.primary;
    final Color resolvedForegroundColor =
        foregroundColor ?? Theme.of(context).colorScheme.onPrimary;

    // Row içerisinde başındaki icon, buttonText ve sonundaki icon yer alıyor.
    Widget childContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 8.0)],
        Text(buttonText),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8.0),
          trailingIcon!,
        ],
      ],
    );

    Widget button = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(resolvedBackgroundColor),
        foregroundColor: WidgetStateProperty.all(resolvedForegroundColor),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
      onPressed: enabled ? onPressed : null,
      child: childContent,
    );

    // Opsiyonel genişlik ve yükseklik ayarlaması
    if (width != null || height != null) {
      button = SizedBox(width: width, height: height, child: button);
    }

    return button;
  }
}
