import 'package:flutter/material.dart';
import 'package:vs_story_designer/vs_story_designer.dart';

class CustomStoryDesigner extends StatefulWidget {
  const CustomStoryDesigner({super.key});

  @override
  State<CustomStoryDesigner> createState() => _CustomStoryDesignerState();
}

class _CustomStoryDesignerState extends State<CustomStoryDesigner> {
  @override
  Widget build(BuildContext context) {
    return VSStoryDesigner(
      giphyKey: "A3GLzkuYUMXePccALGyKe4eMra2i6NNL",
      middleBottomWidget: Icon(Icons.arrow_upward, color: Colors.white),
      onDoneButtonStyle: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(blurRadius: 4, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.none,
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.all(16),
        child: Icon(Icons.send),
      ),
      centerText: "Tasarlamaya Başla",
      onDone: (String uri) {
        /// uri is the local path of final render Uint8List
        /// here your code
      },
    );
  }
}
