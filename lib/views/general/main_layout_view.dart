import 'package:flutter/material.dart';
import 'package:social/widgets/custom_appbar.dart';
import 'package:social/widgets/custom_navbar.dart';

class MainLayoutView extends StatelessWidget {
  final Widget body;
  final String? title;
  final CustomAppbar? appBar;
  final bool showAppBar;
  final bool showNavbar;
  final int currentIndex;
  final Function(int)? onTabChanged;

  const MainLayoutView({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.showAppBar = true,
    this.showNavbar = true,
    this.currentIndex = 0,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? (appBar ?? CustomAppbar(title: title)) : null,
      body: SafeArea(child: body),
      bottomNavigationBar:
          showNavbar
              ? CustomNavbar(
                currentIndex: currentIndex,
                onTabChanged: onTabChanged ?? (_) {},
              )
              : null,
    );
  }
}
