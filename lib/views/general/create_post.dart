import 'package:flutter/material.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_appbar.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      showNavbar: false,
      appBar: CustomAppbar(
        title: Text("Yeni Gönderi"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Gönderi paylaşma işlemi burada yapılacak
            },
            child: Text(
              "Paylaş",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          PageView(
            controller: _pageController,
            children: [Text("Sayfa 1"), Text("Sayfa 2"), Text("Sayfa 3")],
          ),
        ],
      ),
    );
  }
}
