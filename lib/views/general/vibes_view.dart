import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/view_models/general/vibes_viewmodel.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/widgets/custom_profile.dart';
import 'package:social/widgets/custom_video_player.dart';
import 'package:social/services/format_service.dart';
import 'package:social/widgets/post_card.dart';

class VibesView extends StatefulWidget {
  const VibesView({super.key});

  @override
  State<VibesView> createState() => _VibesViewState();
}

class _VibesViewState extends State<VibesView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VibesViewModel>(context, listen: false).loadVideos();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VibesViewModel>(context);
    return MainLayoutView(
      currentIndex: 3,
      showAppBar: false,
      body:
          viewModel.videos.isNotEmpty
              ? PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: viewModel.videos.length,
                onPageChanged: viewModel.setCurrentIndex,
                itemBuilder: (context, index) {
                  final video = viewModel.videos[index];
                  final isActive = index == viewModel.currentIndex;

                  return _buildVideoPage(viewModel, video, isActive);
                },
              )
              : viewModel.errorMessage != null
              ? _buildErrorState(viewModel)
              : _buildEmptyState(),
    );
  }

  Widget _buildVideoPage(
    VibesViewModel viewModel,
    PostModel video,
    bool isActive,
  ) {
    final videoMedia = video.media.firstWhere(
      (media) => media.type == MediaType.video,
      orElse: () => video.media.first,
    );

    return CustomVideoPlayer(
      url: videoMedia.url!,
      sourceType: VideoSourceType.asset,
      mode: VideoPlayerMode.reels,
      autoPlay: isActive,
      reelsActionButtons: _buildActionButtons(viewModel, video),
      reelsBottomInfo: _buildVideoInfo(viewModel, video),
      reelsTopInfo: _buildTopInfo(),
    );
  }

  Widget _buildActionButtons(VibesViewModel viewModel, PostModel video) {
    final isLiked = viewModel.isVideoLiked(video.id);
    final isSaved = viewModel.isVideoSaved(video.id);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Action buttons
        _buildActionButton(
          isLiked ? Icons.favorite : Icons.favorite_border,
          isLiked ? Colors.red : Colors.white,
          FormatService.formatCount(video.likeCount),
          () => viewModel.toggleLike(video.id),
        ),
        const SizedBox(height: 20),

        _buildActionButton(
          Icons.chat_bubble_outline,
          Colors.white,
          FormatService.formatCount(video.commentCount),
          () => viewModel.openComments(video.id),
        ),
        const SizedBox(height: 20),

        _buildActionButton(
          Icons.share_rounded,
          Colors.white,
          FormatService.formatCount(video.shareCount),
          () => viewModel.shareVideo(video.id),
        ),
        const SizedBox(height: 20),

        _buildActionButton(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          isSaved
              ? Colors.amber.shade600
              : context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
          null,
          () => viewModel.toggleSave(video.id),
        ),
        const SizedBox(height: 20),

        _buildActionButton(
          Icons.more_horiz,
          Colors.white,
          null,
          () => _showMoreOptions(),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String? label,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoInfo(VibesViewModel viewModel, PostModel video) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomProfile(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          timeTextColor: Colors.white,
          usernameTextColor: Colors.white,
          nameTextColor: Colors.white,
          displayName: video.user.displayName,
          username: video.user.username,
          profilePicture: video.user.profilePicture,
          isVerified: video.user.isVerified,
          createdAt: video.createdAt,
          hasStory: true, // Story gradient'ini aktif eder
          storyGradientColors: [
            AppColors.primary,
            AppColors.accent,
            AppColors.darkDisabled,
          ],
          layout: ProfileLayout.horizontal,
          displayMode: ProfileDisplayMode.full,
          onTap: () => viewModel.openUserProfile(video.user.id),
        ),
        if (video.content.isNotEmpty) ...[
          Text(
            video.content,
            style: const TextStyle(fontSize: 15, color: Colors.white),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTopInfo() {
    return SafeArea(
      child: Row(
        children: [
          const Text(
            'Vibes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildErrorState(VibesViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: context.themeValue(
              light: AppColors.lightSecondaryText,
              dark: AppColors.darkSecondaryText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.refreshVideos,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off_rounded,
            size: 64,
            color: context.themeValue(
              light: AppColors.lightSecondaryText,
              dark: AppColors.darkSecondaryText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz video yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Video içerikleri burada görünecek',
            style: TextStyle(
              fontSize: 16,
              color: context.themeValue(
                light: AppColors.lightSecondaryText,
                dark: AppColors.darkSecondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
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
}
