import 'package:flutter/material.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_story_designer.dart';

class CreateStoryView extends StatefulWidget {
  const CreateStoryView({super.key});

  @override
  State<CreateStoryView> createState() => _CreateStoryViewState();
}

class _CreateStoryViewState extends State<CreateStoryView> {
  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      showAppBar: false,
      showNavbar: false,
      body: CustomStoryDesigner(),
    );
  }
}
