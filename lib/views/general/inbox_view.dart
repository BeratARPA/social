import 'package:flutter/material.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_appbar.dart';
import 'package:social/widgets/custom_profile.dart';
import 'package:social/widgets/custom_text_field.dart';

class InboxView extends StatefulWidget {
  const InboxView({super.key});

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      showNavbar: false,
      appBar: CustomAppbar(title: "Gelen Kutusu"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              hintText: "Ara",
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              prefixIcon: Icons.search,
              onChanged: (value) {
                // Handle search
              },
            ),
            const SizedBox(height: 32.0),
            Row(
              children: [
                Text(
                  "Mesajlar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Spacer(),
                Text(
                  "İstekler",
                  style: TextStyle(fontSize: 16, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ListTile(
              leading: CustomProfile(
                displayName: "Berat ARPA",
                profilePicture: "assets/images/app_logo.png",
                layout: ProfileLayout.minimal,
                displayMode: ProfileDisplayMode.avatarOnly,
                avatarRadius: 30,
                padding: EdgeInsets.zero,
              ),
              title: const Text("Message 1"),
              subtitle: const Text("This is the first message."),
              trailing: Text("5m"),
              onTap: () {
                // Handle message tap
              },
            ),
            ListTile(
              leading: CustomProfile(
                displayName: "Berat ARPA",
                profilePicture: "assets/images/app_logo.png",
                layout: ProfileLayout.minimal,
                displayMode: ProfileDisplayMode.avatarOnly,
                avatarRadius: 30,
                padding: EdgeInsets.zero,
              ),
              title: const Text("Message 2"),
              subtitle: const Text("This is the second message."),
              trailing: Text("2m"),
              onTap: () {
                // Handle message tap
              },
            ),
          ],
        ),
      ),
    );
  }
}
