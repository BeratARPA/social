import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';

class CustomNavbar extends StatelessWidget {
  final Function(int) onTabChanged;
  final int currentIndex;

  const CustomNavbar({
    super.key,
    required this.onTabChanged,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: context.themeValue(
            light: AppColors.lightBackground,
            dark: AppColors.darkBackground,
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CustomNavItem(
                icon: FontAwesomeIcons.house,
                isSelected: currentIndex == 0,
                onTap: () => onTabChanged(0),
              ),
              _CustomNavItem(
                icon: FontAwesomeIcons.magnifyingGlass,
                isSelected: currentIndex == 1,
                onTap: () => onTabChanged(1),
              ),
              _CustomNavItem(
                icon: FontAwesomeIcons.squarePlus,
                isSelected: currentIndex == 2,
                onTap: () => onTabChanged(2),
              ),
              _CustomNavItem(
                icon: FontAwesomeIcons.circlePlay,
                isSelected: currentIndex == 3,
                onTap: () => onTabChanged(3),
              ),
              _CustomNavItem(
                icon: FontAwesomeIcons.user,
                isSelected: currentIndex == 4,
                onTap: () => onTabChanged(4),
              ),
            ],
          ),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FaIcon(
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
