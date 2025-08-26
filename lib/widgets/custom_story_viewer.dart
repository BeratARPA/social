import 'package:flutter/material.dart';
import 'package:social/helpers/app_navigator.dart';
import 'package:social/widgets/custom_profile.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

class CustomStoryViewer extends StatefulWidget {
  const CustomStoryViewer({super.key});

  @override
  State<CustomStoryViewer> createState() => _CustomStoryViewerState();
}

class _CustomStoryViewerState extends State<CustomStoryViewer> {
  final controller = StoryController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildProfileView() {
    return CustomProfile(
      displayName: "Berat ARPA",
      username: "BeratARPA",
      profilePicture: "assets/images/app_logo.png",
      isVerified: true,
      showMoreButton: true,
      createdAt: DateTime(2025, 8, 26),
      displayMode: ProfileDisplayMode.full,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<StoryItem> storyItems = [
      StoryItem.text(title: "BERAT", backgroundColor: Colors.red),
      StoryItem.text(title: "ARPA", backgroundColor: Colors.blue),
      StoryItem.text(title: "SOCIAL", backgroundColor: Colors.green),
      StoryItem.text(title: "MEDIA", backgroundColor: Colors.yellow),
      StoryItem.text(title: "APPLICATION", backgroundColor: Colors.purple),
    ]; // your list of stories

    return SafeArea(
      child: Stack(
        children: [
          StoryView(
            storyItems: storyItems,
            controller: controller, // pass controller here too
            repeat: true, // should the stories be slid forever
            onStoryShow:
                (storyItem, index) => print("Showing story $index: $storyItem"),
            // onComplete: () => AppNavigator.pop(context),
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                AppNavigator.pop(context);
              }
            },
          ),
          Container(
            padding: EdgeInsets.only(top: 32, left: 16),
            child: _buildProfileView(),
          ),
        ],
      ),
    );
  }
}
