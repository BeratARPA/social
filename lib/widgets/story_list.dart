import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';

class StoryList extends StatelessWidget {
  final List<String> users;
  final void Function(String userId)? onStoryTap;
  final VoidCallback? onAddStory;

  const StoryList({
    super.key,
    required this.users,
    this.onStoryTap,
    this.onAddStory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: users.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryItem(context);
          }

          final user = users[index - 1];
          return _buildStoryItem(context, user);
        },
      ),
    );
  }

  Widget _buildAddStoryItem(BuildContext context) {
    return GestureDetector(
      onTap: onAddStory,
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage("assets/images/app_logo.png"),
                  radius: 35,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(
                        color: context.themeValue(
                          light: AppColors.lightBackground,
                          dark: AppColors.darkBackground,
                        ),
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Hikayem",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.themeValue(
                  light: AppColors.lightText,
                  dark: AppColors.darkText,
                ),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, String user) {
    return GestureDetector(
      onTap: () => onStoryTap?.call(user),
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Story border effekti için Container
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.accent,
                    AppColors.darkDisabled,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/app_logo.png"),
                  radius: 35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.themeValue(
                  light: AppColors.lightText,
                  dark: AppColors.darkText,
                ),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
