import 'package:flutter/material.dart';
import 'package:social/widgets/custom_appbar.dart';
import 'package:social/widgets/custom_navbar.dart';

class MainLayoutView extends StatefulWidget {
  final Widget body;
  final Widget? title;
  final CustomAppbar? appBar;
  final bool showAppBar;
  final bool showNavbar;
  final int currentIndex;

  const MainLayoutView({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.showAppBar = true,
    this.showNavbar = true,
    this.currentIndex = 0,
  });

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          widget.showAppBar
              ? (widget.appBar ?? CustomAppbar(title: widget.title))
              : null,
      body: SafeArea(child: widget.body),
      bottomNavigationBar:
          widget.showNavbar
              ? CustomNavbar(currentIndex: widget.currentIndex)
              : null,
    );
  }
}
