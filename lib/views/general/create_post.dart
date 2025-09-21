import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_appbar.dart';
import 'package:social/widgets/custom_create_poll.dart';
import 'package:social/widgets/custom_poll.dart';
import 'package:social/widgets/custom_post_card.dart';
import 'package:social/widgets/custom_video_player.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> with TickerProviderStateMixin {
  final List<PostMedia> _mediaList = [];

  late TextEditingController _textController;
  late PageController _pageController;
  late TabController? _tabController;
  late ImagePicker _imagePicker;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _pageController = PageController();
    _tabController = TabController(length: _mediaList.length, vsync: this);
    _imagePicker = ImagePicker();
  }

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      showNavbar: false,
      appBar: CustomAppbar(
        title: Text(
          "Yeni Gönderi",
          style: TextStyle(
            color: context.themeValue(
              light: AppColors.lightText,
              dark: AppColors.darkText,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: context.themeValue(
              light: AppColors.lightText,
              dark: AppColors.darkText,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {},
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
          TextField(
            decoration: InputDecoration(
              hintText: 'Ne düşünüyorsun?',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
              fillColor: context.themeValue(
                light: AppColors.lightSurface,
                dark: AppColors.darkSurface,
              ),
            ),
            style: const TextStyle(fontSize: 18),
          ),
          _mediaList.isEmpty
              ? const SizedBox.shrink()
              : Expanded(
                child: PageView.builder(
                  onPageChanged: _onMediaPageChanged,
                  controller: _pageController,
                  itemCount: _mediaList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: context.themeValue(
                            light: AppColors.lightSurface,
                            dark: AppColors.darkSurface,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _buildMediaPreview(_mediaList[index]),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap:
                                    () => setState(() {
                                      _mediaList.removeAt(index);
                                      _updateTabController();
                                      _onMediaPageChanged(
                                        _mediaList.length - 1,
                                      );
                                    }),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          _mediaList.isEmpty
              ? const SizedBox.shrink()
              : TabPageSelector(
                controller: _tabController,
                selectedColor: AppColors.primary,
                color: Colors.grey,
                indicatorSize: 8,
              ),
          if (_mediaList.isEmpty) Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () => _selectMedia(),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(PostMedia media) {
    switch (media.type) {
      case MediaType.image:
        return Image.file(File(media.url!), fit: BoxFit.cover);
      case MediaType.video:
        return CustomVideoPlayer(url: media.url!, autoPlay: false);
      case MediaType.poll:
        return CustomPoll(pollData: media.pollData!);
    }
  }

  void _selectMedia() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Medya Türü Seç',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Resim"),
                onTap: () {
                  _addMedia(MediaType.image);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Video"),
                onTap: () {
                  _addMedia(MediaType.video);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.poll),
                title: const Text("Anket"),
                onTap: () {
                  _addMedia(MediaType.poll);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addMedia(MediaType mediaType) async {
    if (mediaType == MediaType.image) {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _mediaList.add(PostMedia(type: mediaType, url: image.path));
          _updateTabController();
          _onMediaPageChanged(_mediaList.length - 1);
        });
      }
    } else if (mediaType == MediaType.video) {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        setState(() {
          _mediaList.add(PostMedia(type: mediaType, url: video.path));
          _updateTabController();
          _onMediaPageChanged(_mediaList.length - 1);
        });
      }
    } else if (mediaType == MediaType.poll) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return CustomCreatePoll(
            onCreated: (pollData) {
              setState(() {
                _mediaList.add(PostMedia(type: mediaType, pollData: pollData));
                _updateTabController();
                _onMediaPageChanged(_mediaList.length - 1);
                Navigator.pop(context);
              });
            },
          );
        },
      );
    }
  }

  void _updateTabController() {
    _tabController?.dispose();
    _tabController = TabController(length: _mediaList.length, vsync: this);
  }

  void _onMediaPageChanged(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _tabController == null || _mediaList.isEmpty) return;

      _tabController!.index = index;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.ease,
        );
      }
    });
  }
}
