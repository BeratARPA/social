import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: context.themeValue(
                      light: AppColors.lightBorder,
                      dark: AppColors.darkBorder,
                    ),
                  ),
                  color: context.themeValue(
                    light: AppColors.lightBackground,
                    dark: AppColors.darkBackground,
                  ),
                ),
                child: Icon(
                  Icons.person_add,
                  color: context.themeValue(
                    light: AppColors.lightSecondaryText,
                    dark: AppColors.darkSecondaryText,
                  ),
                ),
              ),
              title: Text(
                "Takip İstekleri",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("İstekleri onayla veya yok say"),
              onTap: () {
                // Handle notification tap
              },
            ),
            const SizedBox(height: 16),
            Text(
              "Etkinlikler",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text("Bildirim 1"),
              subtitle: Text("Bu birinci bildirim."),
              trailing: Text("5m"),
              onTap: () {
                // Handle notification tap
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text("Bildirim 2"),
              subtitle: Text("Bu ikinci bildirim."),
              trailing: Text("2m"),
              onTap: () {
                // Handle notification tap
              },
            ),
          ],
        ),
      ),
    );
  }
}
