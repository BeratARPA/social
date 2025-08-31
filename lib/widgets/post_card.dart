import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/widgets/custom_poll.dart';
import 'package:social/widgets/custom_profile.dart';
import 'package:social/widgets/custom_video_player.dart';

enum MediaType { image, video, poll }

class PostMedia {
  final MediaType type;
  final String? url; // image veya video için
  final Map<String, dynamic>? pollData; // poll için

  PostMedia({required this.type, this.url, this.pollData});
}

class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String? profilePicture;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.profilePicture,
    this.isVerified = false,
  });
}

class PostModel {
  final String id;
  final UserModel user;
  final String content;
  final List<PostMedia> media;
  final DateTime createdAt;
  int likeCount;
  int commentCount;
  int shareCount;
  bool isLiked;
  bool isSaved;

  PostModel({
    required this.id,
    required this.user,
    required this.content,
    required this.media,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isSaved = false,
  });
}

class PostCard extends StatefulWidget {
  final PostModel post;
  final Function(String postId)? onLike;
  final Function(String postId)? onComment;
  final Function(String postId)? onShare;
  final Function(String postId)? onSave;
  final Function(String userId)? onUserTap;
  final Function(String postId)? onPostTap;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onUserTap,
    this.onPostTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}B';
    }
    return count.toString();
  }

  void _handleLike() {
    setState(() {
      widget.post.isLiked = !widget.post.isLiked;
      if (widget.post.isLiked) {
        widget.post.likeCount++;
        _likeAnimationController.forward().then((_) {
          _likeAnimationController.reverse();
        });
      } else {
        widget.post.likeCount--;
      }
    });
    widget.onLike?.call(widget.post.id);
  }

  void _handleSave() {
    setState(() {
      widget.post.isSaved = !widget.post.isSaved;
    });
    widget.onSave?.call(widget.post.id);
  }

  Widget _buildHeader() {
    return CustomProfile(
      displayName: widget.post.user.displayName,
      username: widget.post.user.username,
      profilePicture: widget.post.user.profilePicture,
      isVerified: widget.post.user.isVerified,
      createdAt: widget.post.createdAt,
      layout: ProfileLayout.horizontal,
      displayMode: ProfileDisplayMode.full,
      showMoreButton: true,
      onTap: () => print("User tapped"),
      onMoreTap: () => _showMoreOptions(context),
    );
  }

  Widget _buildContent() {
    if (widget.post.content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        widget.post.content,
        style: TextStyle(
          fontSize: 14,
          color: context.themeValue(
            light: AppColors.lightText,
            dark: AppColors.darkText,
          ),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildMediaCarousel() {
    final mediaList = widget.post.media;
    if (mediaList.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: mediaList.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final media = mediaList[index];
                return GestureDetector(
                  onTap: () => widget.onPostTap?.call(widget.post.id),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: _buildMediaItem(media, index),
                  ),
                );
              },
            ),
            // Page indicators
            if (mediaList.length > 1)
              Positioned(
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(mediaList.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: _currentPage == index ? 8 : 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaItem(PostMedia media, int index) {
    switch (media.type) {
      case MediaType.image:
        return Image.asset(
          media.url!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );

      case MediaType.video:
        return CustomVideoPlayer(
          url: media.url!,
          sourceType: VideoSourceType.asset,
          autoPlay: true,
          showControls: true,
          allowFullscreen: true,
          primaryColor: AppColors.primary,
          enableDoubleTapToSeek: true,
          onPositionChanged: (position) => print('Position: $position'),
          onVideoEnd: () => print('Video ended'),
        );

      case MediaType.poll:
        return CustomPoll(
          pollData: media.pollData!,
          showResults: true,
          canVote: true,
          onVote: (optionIndex) {
            // Handle poll vote
            print('Poll vote: option $optionIndex');
          },
        );      
    }
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: _handleLike,
            child: AnimatedBuilder(
              animation: _likeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _likeAnimation.value,
                  child: Icon(
                    widget.post.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 24,
                    color:
                        widget.post.isLiked
                            ? Colors.red.shade500
                            : context.themeValue(
                              light: AppColors.lightText,
                              dark: AppColors.darkText,
                            ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Comment button
          GestureDetector(
            onTap: () => widget.onComment?.call(widget.post.id),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 24,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Share button
          GestureDetector(
            onTap: () => widget.onShare?.call(widget.post.id),
            child: Icon(
              Icons.share_outlined,
              size: 24,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
          ),
          const Spacer(),
          // Save button
          GestureDetector(
            onTap: _handleSave,
            child: Icon(
              widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 24,
              color:
                  widget.post.isSaved
                      ? Colors.amber.shade600
                      : context.themeValue(
                        light: AppColors.lightText,
                        dark: AppColors.darkText,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    bool hasInteractions =
        widget.post.likeCount > 0 ||
        widget.post.commentCount > 0 ||
        widget.post.shareCount > 0;

    if (!hasInteractions) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.likeCount > 0)
            GestureDetector(
              onTap: () {
                // Show likes list
                _showLikesList(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: context.themeValue(
                        light: AppColors.lightText,
                        dark: AppColors.darkText,
                      ),
                    ),
                    children: [
                      TextSpan(
                        text: _formatCount(widget.post.likeCount),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' beğeni'),
                    ],
                  ),
                ),
              ),
            ),
          if (widget.post.commentCount > 0)
            GestureDetector(
              onTap: () => widget.onComment?.call(widget.post.id),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${_formatCount(widget.post.commentCount)} yorumu gör',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.themeValue(
                      light: AppColors.lightSecondaryText,
                      dark: AppColors.darkSecondaryText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: context.themeValue(
                light: AppColors.lightBackground,
                dark: AppColors.darkBackground,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: context.themeValue(
                        light: AppColors.lightDivider,
                        dark: AppColors.darkDivider,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.link,
                      color: context.themeValue(
                        light: AppColors.lightText,
                        dark: AppColors.darkText,
                      ),
                    ),
                    title: const Text('Bağlantıyı kopyala'),
                    onTap: () {
                      Navigator.pop(context);
                      // Copy link functionality
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.report_outlined,
                      color: Colors.red.shade600,
                    ),
                    title: Text(
                      'Bildir',
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Report functionality
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
    );
  }

  void _showLikesList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: context.themeValue(
                light: AppColors.lightBackground,
                dark: AppColors.darkBackground,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: context.themeValue(
                      light: AppColors.lightDivider,
                      dark: AppColors.darkDivider,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Beğeniler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.themeValue(
                        light: AppColors.lightText,
                        dark: AppColors.darkText,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Beğeni listesi burada görünecek',
                      style: TextStyle(
                        color: context.themeValue(
                          light: AppColors.lightText,
                          dark: AppColors.darkText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildContent(),
        _buildMediaCarousel(),
        _buildActionBar(),
        _buildStats(),
        const SizedBox(height: 8),
      ],
    );
  }
}
