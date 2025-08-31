import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_seed_data.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_text_field.dart';
import 'package:social/widgets/post_card.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final Map<String, String?> _thumbnailCache = {};

  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      currentIndex: 1,
      showAppBar: false,
      body: CustomScrollView(
        slivers: [
          // 🔹 Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomTextField(
                hintText: "Ara",
                prefixIcon: Icons.search,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Masonry Grid
          SliverPadding(
            padding: const EdgeInsets.all(2),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childCount: AppSeedData.posts.length,
              itemBuilder: (context, index) {
                final post = AppSeedData.posts[index];
                return GestureDetector(
                  onLongPress: () => _showPreview(post),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MainLayoutView(
                              showNavbar: false,
                              body: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [PostCard(post: post)],
                              ),
                            ),
                      ),
                    );
                  },
                  child: _buildPreview(post),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future _showPreview(PostModel post) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Kapat",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Material(
            color: context.themeValue(
              light: AppColors.lightSurface.withOpacity(0.9),
              dark: AppColors.darkSurface.withOpacity(0.9),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Hero(tag: post.id, child: PostCard(post: post))),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Hem asset hem de URL'ler için thumbnail oluşturur
  Future<String?> _generateThumbnail(String videoPath) async {
    // Cache kontrolü
    if (_thumbnailCache.containsKey(videoPath)) {
      return _thumbnailCache[videoPath];
    }

    try {
      String? thumbnailPath;

      if (_isAssetPath(videoPath)) {
        // Asset video için thumbnail oluştur
        thumbnailPath = await _generateThumbnailFromAsset(videoPath);
      } else {
        // URL video için thumbnail oluştur
        thumbnailPath = await _generateThumbnailFromUrl(videoPath);
      }

      // Cache'e kaydet
      _thumbnailCache[videoPath] = thumbnailPath;
      return thumbnailPath;
    } catch (e) {
      print('Thumbnail oluşturma hatası ($videoPath): $e');
      _thumbnailCache[videoPath] = null;
      return null;
    }
  }

  /// Asset'ten thumbnail oluşturur
  Future<String?> _generateThumbnailFromAsset(String assetPath) async {
    try {
      // 1️⃣ Asset'i yükle
      final byteData = await rootBundle.load(assetPath);

      // 2️⃣ Geçici dosyaya yaz
      final tempDir = await getTemporaryDirectory();
      final tempVideo = File(
        '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      await tempVideo.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      // 3️⃣ Thumbnail oluştur
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: tempVideo.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );

      // 4️⃣ Geçici video dosyasını sil
      await tempVideo.delete().catchError((_) => {}); // Sessizce hata ignore et

      return thumbnailPath;
    } catch (e) {
      print('Asset thumbnail hatası: $e');
      return null;
    }
  }

  /// URL'den thumbnail oluşturur
  Future<String?> _generateThumbnailFromUrl(String videoUrl) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );

      return thumbnailPath;
    } catch (e) {
      print('URL thumbnail hatası: $e');
      return null;
    }
  }

  bool _isAssetPath(String path) {
    return path.startsWith('assets/') || !path.contains('http');
  }

  Widget _buildPreview(PostModel post) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth / 3) - 2; // her item genişliği
    final media = post.media.isNotEmpty ? post.media.first : null;

    if (media == null) {
      // Sadece text
      return Container(
        width: itemWidth,
        height: 130,
        color: context.themeValue(
          light: AppColors.lightDivider,
          dark: AppColors.darkSurface,
        ),
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            post.content,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
          ),
        ),
      );
    }

    switch (media.type) {
      case MediaType.image:
        return AspectRatio(
          aspectRatio: 1, // kare görünüm
          child: Image.asset(media.url!, fit: BoxFit.cover),
        );

      case MediaType.video:
        return AspectRatio(
          aspectRatio: 9 / 16,
          child: FutureBuilder<String?>(
            future: _generateThumbnail(media.url!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
        
              if (!snapshot.hasData || snapshot.data == null) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_off,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Video',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              }
        
              return Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(
                    File(snapshot.data!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(Icons.error, color: Colors.white),
                        ),
                      );
                    },
                  ),
                  // Play button overlay
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        );

      case MediaType.poll:
        return Container(
          width: itemWidth,
          height: 130,
          color: context.themeValue(
            light: AppColors.lightDivider,
            dark: AppColors.darkSurface,
          ),
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              post.content,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: context.themeValue(
                  light: AppColors.lightText,
                  dark: AppColors.darkText,
                ),
              ),
            ),
          ),
        );
    }
  }
}
