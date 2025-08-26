import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_constant.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? centerTitle;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppbar({
    super.key,
    this.title,
    this.centerTitle,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title ?? AppConstant.brandName),
      centerTitle: centerTitle ?? false,
      backgroundColor: context.themeValue(
        light: AppColors.lightBackground,
        dark: AppColors.darkBackground,
      ),
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
