import 'package:flutter/material.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_navigator.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

class CustomStoryViewer extends StatefulWidget {
  CustomStoryViewer({super.key});

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
    return Row(
      children: [
        GestureDetector(
          onTap: () => print("Profile tapped"),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage("assets/images/app_logo.png"),
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 10),
              Text(
                "BeratARPA",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(width: 5),
              Icon(Icons.verified, size: 14, color: Colors.blue.shade600),
              const SizedBox(width: 10),
              Text(
                "35d",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.lightSecondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
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
