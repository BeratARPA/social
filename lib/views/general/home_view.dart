import 'package:flutter/material.dart';
import 'package:social/widgets/custom_appbar.dart';
import 'package:social/widgets/custom_navbar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(),
      body: Center(child: Text('Welcome to the Home View!')),
      bottomNavigationBar: CustomNavbar(),
    );
  }
}
