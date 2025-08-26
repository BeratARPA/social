import 'package:flutter/material.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_story_viewer.dart';

class StoryViewerView extends StatefulWidget {
  const StoryViewerView({super.key});

  @override
  State<StoryViewerView> createState() => _StoryViewerViewState();
}

class _StoryViewerViewState extends State<StoryViewerView> {
  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      showAppBar: false,
      showNavbar: false,
      body: CustomStoryViewer(),
    );
  }
}
