import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_navigator.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;

  const CustomNavbar({super.key, this.currentIndex = 0});

  void _navigate(int index) {
    switch (index) {
      case 0:
        AppNavigator.pushReplacementNamed("/home");
        break;
      case 1:
        AppNavigator.pushReplacementNamed("/explore");
        break;
      case 2:
        AppNavigator.pushNamed("/create-post");
        break;
      case 3:
        AppNavigator.pushReplacementNamed("/vibes");
        break;
      case 4:
        AppNavigator.pushReplacementNamed("/profile");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 55,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CustomNavItem(
              icon: Icons.home_outlined,
              isSelected: currentIndex == 0,
              onTap: () => _navigate(0),
            ),
            _CustomNavItem(
              icon: Icons.explore_outlined,
              isSelected: currentIndex == 1,
              onTap: () => _navigate(1),
            ),
            _CustomNavItem(
              icon: Icons.add_box_outlined,
              isSelected: currentIndex == 2,
              onTap: () => _navigate(2),
            ),
            _CustomNavItem(
              icon: Icons.play_circle_outline,
              isSelected: currentIndex == 3,
              onTap: () => _navigate(3),
            ),
            _CustomNavItem(
              icon: Icons.person_outline,
              isSelected: currentIndex == 4,
              onTap: () => _navigate(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomNavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          size: 28,
          icon,
          color:
              isSelected
                  ? context.themeValue(
                    light: AppColors.lightText,
                    dark: AppColors.darkText,
                  )
                  : context.themeValue(
                    light: AppColors.lightSecondaryText,
                    dark: AppColors.darkSecondaryText,
                  ),
        ),
      ),
    );
  }
}
