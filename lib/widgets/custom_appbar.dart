import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_constant.dart';
import 'package:social/helpers/app_navigator.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppConstant.brandName),
      backgroundColor: context.themeValue(
        light: AppColors.lightBackground,
        dark: AppColors.darkBackground,
      ),
      actions: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.heart),
          onPressed: () {
            AppNavigator.showSnack("Liked!");
          },
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.message),
          onPressed: () {
            AppNavigator.showDialog(
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text("New Message"),
                  content: const Text("You have a new message."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        AppNavigator.pop();
                      },
                      child: const Text("Close"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
