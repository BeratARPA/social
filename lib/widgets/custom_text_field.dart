import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final bool isPassword;
  final bool enableClearButton;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;
  final TextStyle? style;
  final InputDecoration? decoration;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    this.controller,
    this.isPassword = false,
    this.enableClearButton = true,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.style,
    this.decoration,
    this.prefixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late bool _obscureText;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _controller = widget.controller ?? TextEditingController();
    _updateContentStatus(); // ilk durum güncellemesi

    _controller.addListener(() {
      setState(() {
        _hasContent = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _clearText() {
    _controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _updateContentStatus() {
    _hasContent = _controller.text.isNotEmpty;
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon == null) return null;

    return Icon(widget.prefixIcon);
  }

  Widget? _buildSuffixIcon() {
    // Eğer input boşsa hiçbir ikon gösterme.
    if (!_hasContent) return null;

    List<Widget> icons = [];
    if (widget.enableClearButton) {
      icons.add(
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearText,
          splashRadius: 20,
        ),
      );
    }
    if (widget.isPassword) {
      icons.add(
        IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: _togglePasswordVisibility,
          splashRadius: 20,
        ),
      );
    }
    if (icons.isEmpty) return null;
    if (icons.length == 1) return icons.first;
    return Row(mainAxisSize: MainAxisSize.min, children: icons);
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration effectiveDecoration =
        widget.decoration ?? const InputDecoration();
    if (widget.labelText != null && effectiveDecoration.labelText == null) {
      effectiveDecoration = effectiveDecoration.copyWith(
        labelText: widget.labelText,
      );
    }
    if (widget.hintText != null && effectiveDecoration.hintText == null) {
      effectiveDecoration = effectiveDecoration.copyWith(
        hintText: widget.hintText,
      );
    }
    effectiveDecoration = effectiveDecoration.copyWith(
      prefixIcon: _buildPrefixIcon(),
      suffixIcon: _buildSuffixIcon(),
    );

    return TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      style: widget.style,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: effectiveDecoration,
      obscureText: widget.isPassword ? _obscureText : false,
    );
  }
}
