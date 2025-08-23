import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_constant.dart';

class StoryList extends StatelessWidget {
  final List<String> users;

  // 📌 Callback’ler
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: users.length + 1, // +1 kendi hikayemiz için
        itemBuilder: (context, index) {
          if (index == 0) {
            // 📌 İlk item: Your Story
            return GestureDetector(
              onTap: onAddStory,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(
                            AppConstant.brandLogoPath,
                          ),
                          radius: 40,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 70,
                      child: Text(
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 📌 Diğer story’ler
          final user = users[index - 1];
          return GestureDetector(
            onTap: () => onStoryTap?.call(user), // Story tap event
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2), // Story halkası efekti
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.red, Colors.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(AppConstant.brandLogoPath),
                      radius: 40,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 70,
                    child: Text(
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
