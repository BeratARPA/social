import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_navigator.dart';
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
  final List<PostModel> posts = [
    PostModel(
      id: '1',
      user: UserModel(
        id: 'user1',
        username: 'johndoe',
        displayName: 'John Doe',
        profilePicture: 'assets/images/app_logo.png',
        isVerified: true,
      ),
      content:
          'Flutter ile harika bir uygulama geliştirdik! 🚀 Ne düşünüyorsunuz?',
      media: [
        PostMedia(type: MediaType.image, url: "assets/images/app_logo.png"),
        PostMedia(type: MediaType.video, url: "assets/videos/video1.mp4"),
        PostMedia(
          type: MediaType.poll,
          pollData: {
            "question": "En sevdiğiniz framework hangisi?",
            "options": ["Flutter", "React Native", "Native"],
            "votes": [45, 23, 18],
          },
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 124,
      commentCount: 18,
      shareCount: 5,
      isLiked: false,
      isSaved: false,
    ),
    PostModel(
      id: '1',
      user: UserModel(
        id: 'user1',
        username: 'johndoe',
        displayName: 'John Doe',
        profilePicture: 'assets/images/app_logo.png',
        isVerified: true,
      ),
      content: 'Uygulama simgemiz!',
      media: [
        PostMedia(type: MediaType.image, url: "assets/images/app_logo.png"),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 124,
      commentCount: 18,
      shareCount: 5,
      isLiked: true,
      isSaved: false,
    ),
    PostModel(
      id: '1',
      user: UserModel(
        id: 'user1',
        username: 'johndoe',
        displayName: 'John Doe',
        profilePicture: 'assets/images/app_logo.png',
        isVerified: true,
      ),
      content: 'Father of the Turks',
      media: [
        PostMedia(type: MediaType.video, url: "assets/videos/video1.mp4"),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 99999999,
      commentCount: 99999999,
      shareCount: 9999999,
      isLiked: true,
      isSaved: true,
    ),
    PostModel(
      id: '1',
      user: UserModel(
        id: 'user1',
        username: 'johndoe',
        displayName: 'John Doe',
        profilePicture: 'assets/images/app_logo.png',
        isVerified: true,
      ),
      content: 'Oy vermeye son 24 saat!',
      media: [
        PostMedia(
          type: MediaType.poll,
          pollData: {
            "question": "Hangi framework daha iyi?",
            "options": ["Flutter", "React Native", "SwiftUI"],
            "votes": [30, 15, 10],
          },
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 124,
      commentCount: 18,
      shareCount: 5,
      isLiked: false,
      isSaved: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      currentIndex: 0,
      appBar: CustomAppbar(
        showLeading: false,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.heart),
            color: context.themeValue(
              light: AppColors.lightText,
              dark: AppColors.darkText,
            ),
            onPressed: () {
              AppNavigator.pushNamed("/notification");
            },
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.envelope),
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

          ...posts.map((post) => PostCard(post: post)),
        ],
      ),
    );
  }
}
