import 'package:flutter/material.dart';
import 'package:social/helpers/app_navigator.dart';
import 'package:social/widgets/custom_appbar.dart';
import 'package:social/widgets/custom_navbar.dart';
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

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(),
      body: SafeArea(
        child: ListView(
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
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: currentIndex,
        onTabChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
