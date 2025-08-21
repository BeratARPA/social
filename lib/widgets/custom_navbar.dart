import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key});

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  int _selectedIndex = 0;

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CrystalNavigationBar(
        margin: EdgeInsets.all(0),
        marginR: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        borderRadius: 20,
        currentIndex: _selectedIndex,
        indicatorColor: context.themeValue(
          light: AppColors.lightText,
          dark: AppColors.darkText,
        ),
        backgroundColor: context.themeValue(
          light: AppColors.lightSurface,
          dark: AppColors.darkSurface,
        ),
        outlineBorderColor: context.themeValue(
          light: AppColors.lightBorder,
          dark: AppColors.darkBorder,
        ),      
        borderWidth: 2,
        boxShadow: [
          BoxShadow(
            color: context.themeValue(
              light: AppColors.lightShadow,
              dark: AppColors.darkShadow,
            ),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
        onTap: changeTab,
        items: [
          /// Home
          CrystalNavigationBarItem(icon: FontAwesomeIcons.house),

          /// Search
          CrystalNavigationBarItem(icon: FontAwesomeIcons.magnifyingGlass),

          /// Add
          CrystalNavigationBarItem(icon: FontAwesomeIcons.plus),

          /// Favourite
          CrystalNavigationBarItem(icon: FontAwesomeIcons.heart),

          /// Profile
          CrystalNavigationBarItem(icon: FontAwesomeIcons.user),
        ],
      ),
    );
  }
}
