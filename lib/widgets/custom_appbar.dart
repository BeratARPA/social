import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_constant.dart';
import 'package:social/helpers/app_navigator.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool? showTitle;
  final String? title;
  final bool? centerTitle;
  final bool? showActions;
  final List<Widget>? actions;
  final bool? showLeading;
  final Widget? leading;

  const CustomAppbar({
    super.key,
    this.showTitle = true,
    this.title,
    this.centerTitle,
    this.showActions = true,
    this.actions,
    this.showLeading = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:
          showTitle == true
              ? Text(
                title ?? AppConstant.brandName,
                style: TextStyle(
                  color: context.themeValue(
                    light: AppColors.lightText,
                    dark: AppColors.darkText,
                  ),
                ),
              )
              : null,
      centerTitle: centerTitle ?? false,
      backgroundColor: context.themeValue(
        light: AppColors.lightBackground,
        dark: AppColors.darkBackground,
      ),
      leading:
          showLeading == true
              ? leading ??
                  IconButton(
                    onPressed: AppNavigator.pop,
                    icon: Icon(
                      Icons.arrow_back,
                      color: context.themeValue(
                        light: AppColors.lightText,
                        dark: AppColors.darkText,
                      ),
                    ),
                  )
              : null,
      actions: showActions == true ? actions : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
