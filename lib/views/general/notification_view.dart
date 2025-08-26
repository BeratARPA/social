import 'package:flutter/material.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_appbar.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      appBar: CustomAppbar(title: "Bildirimler"),
      body: const Center(child: Text("Bildirimler sayfası")),
    );
  }
}
