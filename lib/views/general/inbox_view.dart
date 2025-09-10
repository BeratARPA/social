import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_navigator.dart';
import 'package:social/views/general/main_layout_view.dart';
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
      title: Text(
        "Gelen Kutusu",
        style: TextStyle(
          color: context.themeValue(
            light: AppColors.lightText,
            dark: AppColors.darkText,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CustomProfile(
                    displayName: "Berat ARPA",
                    profilePicture: "assets/images/app_logo.png",
                    layout: ProfileLayout.minimal,
                    displayMode: ProfileDisplayMode.avatarOnly,
                    avatarRadius: 30,
                    padding: EdgeInsets.zero,
                  ),
                  title: Text("Message ${index + 1}"),
                  subtitle: Text("This is message number ${index + 1}."),
                  trailing: Text("${(index + 1) * 5}m"),
                  onTap: () {
                    AppNavigator.pushNamed("/chat");
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
