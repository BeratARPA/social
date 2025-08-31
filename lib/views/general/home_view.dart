import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_navigator.dart';
import 'package:social/helpers/app_seed_data.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_appbar.dart';
import 'package:social/widgets/post_card.dart';
import 'package:social/widgets/story_list.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      currentIndex: 0,
      appBar: CustomAppbar(
        showLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            color: context.themeValue(
              light: AppColors.lightText,
              dark: AppColors.darkText,
            ),
            onPressed: () {
              AppNavigator.pushNamed("/notification");
            },
          ),
          IconButton(
            icon: const Icon(Icons.mail_outline, size: 28),
            color: context.themeValue(
              light: AppColors.lightText,
              dark: AppColors.darkText,
            ),
            onPressed: () {
              AppNavigator.pushNamed("/inbox");
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          StoryList(
            users: [
              "BeratARPA",
              "Emma",
              "Alex",
              "Lisa",
              "Michael",
              "Sophia",
              "David",
            ],
            onAddStory: () {
              AppNavigator.pushNamed("/create-story");
            },
            onStoryTap: (userId) {
              AppNavigator.pushNamed("/story-viewer", arguments: userId);
            },
          ),

          ...AppSeedData.posts.map((post) => PostCard(post: post)),
        ],
      ),
    );
  }
}
