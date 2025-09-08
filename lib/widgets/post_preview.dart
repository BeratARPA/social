import 'dart:io';
import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/services/format_service.dart';
import 'package:social/widgets/post_card.dart';
import 'package:social/services/thumbnail_service.dart';

enum PreviewLayout {
  square, // 1:1 - Grid için
  portrait, // 9:16 - Videolar için
  landscape, // 16:9 - Yatay videolar için
  adaptive, // İçeriğe göre adapte olur
}

enum PreviewSize {
  small, // Küçük önizlemeler
  medium, // Normal boyut
  large, // Büyük önizlemeler
}

class PostPreview extends StatelessWidget {
  final PostModel post;
  final PreviewLayout layout;
  final PreviewSize size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showStats;
  final bool showOverlay;
  final bool showMultipleIndicator;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const PostPreview({
    super.key,
    required this.post,
    this.layout = PreviewLayout.adaptive,
    this.size = PreviewSize.medium,
    this.onTap,
    this.onLongPress,
    this.showStats = true,
    this.showOverlay = true,
    this.showMultipleIndicator = true,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        child: _buildPreviewContent(context),
      ),
    );
  }

  Widget _buildPreviewContent(BuildContext context) {
    final media = post.media.isNotEmpty ? post.media.first : null;

    if (media == null) {
      return _buildTextPreview(context);
    }

    switch (media.type) {
      case MediaType.image:
        return _buildImagePreview(context, media.url!);
      case MediaType.video:
        return _buildVideoPreview(context, media.url!);
      case MediaType.poll:
        return _buildPollPreview(context, media.pollData!);
    }
  }

  Widget _buildImagePreview(BuildContext context, String imageUrl) {
    return _buildContainer(
      context,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImageWidget(imageUrl),
          if (showOverlay) _buildOverlay(context),
          if (showMultipleIndicator && post.media.length > 1)
            _buildMultipleIndicator(),
          if (showStats) _buildImageStats(),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(BuildContext context, String videoUrl) {
    return _buildContainer(
      context,
      child: FutureBuilder<String?>(
        future: ThumbnailService.getThumbnail(videoUrl),
        builder: (context, snapshot) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildVideoBackground(context, snapshot),
              if (showOverlay) _buildOverlay(context),
              _buildPlayButton(),
              if (showStats) _buildVideoStats(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPollPreview(
    BuildContext context,
    Map<String, dynamic> pollData,
  ) {
    return _buildContainer(
      context,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withOpacity(0.1),
              AppColors.primary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(_getPadding()),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.poll_rounded,
                      size: _getIconSize(),
                      color: AppColors.accent,
                    ),
                    SizedBox(height: _getSpacing()),
                    Text(
                      pollData['question'] as String? ?? 'Anket',
                      style: TextStyle(
                        fontSize: _getTextSize(),
                        fontWeight: FontWeight.w600,
                        color: context.themeValue(
                          light: AppColors.lightText,
                          dark: AppColors.darkText,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: _getMaxLines(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: _getSpacing() / 2),
                    Text(
                      '${(pollData['options'] as List?)?.length ?? 0} seçenek',
                      style: TextStyle(
                        fontSize: _getSmallTextSize(),
                        color: context.themeValue(
                          light: AppColors.lightSecondaryText,
                          dark: AppColors.darkSecondaryText,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (showStats) _buildPollStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextPreview(BuildContext context) {
    return _buildContainer(
      context,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(_getPadding()),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_rounded,
                      size: _getIconSize(),
                      color: AppColors.primary,
                    ),
                    SizedBox(height: _getSpacing()),
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: _getTextSize(),
                        color: context.themeValue(
                          light: AppColors.lightText,
                          dark: AppColors.darkText,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: _getMaxLines(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (showStats) _buildTextStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer(BuildContext context, {required Widget child}) {
    return Container(
      width: width,
      height: height ?? _getDefaultHeight(context),
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightSurface,
          dark: AppColors.darkSurface,
        ),
        border: Border.all(
          color: context.themeValue(
            light: AppColors.lightBorder,
            dark: AppColors.darkBorder,
          ),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }
  }

  Widget _buildVideoBackground(
    BuildContext context,
    AsyncSnapshot<String?> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingPlaceholder();
    }

    if (!snapshot.hasData || snapshot.data == null) {
      return _buildVideoPlaceholder();
    }

    return Image.file(
      File(snapshot.data!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildVideoPlaceholder(),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
        ),
      ),
    );
  }

  Widget _buildMultipleIndicator() {
    return Positioned(
      top: _getIndicatorPosition(),
      right: _getIndicatorPosition(),
      child: Container(
        padding: EdgeInsets.all(_getIndicatorPadding()),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(_getIndicatorRadius()),
        ),
        child: Icon(
          Icons.collections_rounded,
          color: Colors.white,
          size: _getIndicatorSize(),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(_getPlayButtonPadding()),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: _getPlayButtonSize(),
        ),
      ),
    );
  }

  Widget _buildImageStats() {
    return Positioned(
      bottom: _getStatsPosition(),
      left: _getStatsPosition(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _getStatsPadding(),
          vertical: _getStatsPadding() / 2,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(_getStatsRadius()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite,
              color: Colors.white,
              size: _getStatsIconSize(),
            ),
            SizedBox(width: 2),
            Text(
              FormatService.formatCount(post.likeCount),
              style: TextStyle(
                color: Colors.white,
                fontSize: _getStatsTextSize(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoStats(BuildContext context) {
    return Positioned(
      bottom: _getStatsPosition(),
      left: _getStatsPosition(),
      right: _getStatsPosition(),
      child: Container(
        padding: EdgeInsets.all(_getStatsPadding()),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(_getStatsRadius()),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: _getStatsIconSize(),
                ),
                SizedBox(width: 4),
                Text(
                  FormatService.formatCount(post.likeCount),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getStatsTextSize(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (size != PreviewSize.small && post.content.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(
                post.content.length > 30
                    ? '${post.content.substring(0, 30)}...'
                    : post.content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getSmallStatsTextSize(),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPollStats(BuildContext context) {
    return Positioned(
      bottom: _getStatsPosition(),
      right: _getStatsPosition(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _getStatsPadding(),
          vertical: _getStatsPadding() / 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.9),
          borderRadius: BorderRadius.circular(_getStatsRadius()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.poll_rounded,
              color: Colors.white,
              size: _getStatsIconSize(),
            ),
            SizedBox(width: 2),
            Text(
              FormatService.formatCount(post.likeCount),
              style: TextStyle(
                color: Colors.white,
                fontSize: _getStatsTextSize(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextStats(BuildContext context) {
    return Positioned(
      bottom: _getStatsPosition(),
      left: _getStatsPosition(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _getStatsPadding(),
          vertical: _getStatsPadding() / 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(_getStatsRadius()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: _getStatsIconSize(),
            ),
            SizedBox(width: 2),
            Text(
              FormatService.formatCount(post.likeCount),
              style: TextStyle(
                color: Colors.white,
                fontSize: _getStatsTextSize(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.lightDivider.withOpacity(0.3),
      child: Center(
        child: SizedBox(
          width: _getLoadingSize(),
          height: _getLoadingSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: AppColors.darkSurface.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off_rounded,
              color: Colors.white,
              size: _getPlaceholderIconSize(),
            ),
            SizedBox(height: _getSpacing() / 2),
            Text(
              'Video',
              style: TextStyle(
                color: Colors.white,
                fontSize: _getSmallTextSize(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColors.darkSurface.withOpacity(0.8),
      child: Center(
        child: Icon(
          Icons.error_outline_rounded,
          color: Colors.white,
          size: _getPlaceholderIconSize(),
        ),
      ),
    );
  }

  // Size & Dimension Helpers
  double _getDefaultHeight(BuildContext context) {
    switch (layout) {
      case PreviewLayout.square:
        return width ?? (MediaQuery.of(context).size.width / 3);
      case PreviewLayout.portrait:
        return (width ?? (MediaQuery.of(context).size.width / 2)) * (16 / 9);
      case PreviewLayout.landscape:
        return (width ?? MediaQuery.of(context).size.width) * (9 / 16);
      case PreviewLayout.adaptive:
        final media = post.media.isNotEmpty ? post.media.first : null;
        if (media?.type == MediaType.video) {
          return (width ?? (MediaQuery.of(context).size.width / 2)) * (16 / 9);
        }
        return width ?? 120;
    }
  }

  double _getPadding() {
    switch (size) {
      case PreviewSize.small:
        return 6;
      case PreviewSize.medium:
        return 8;
      case PreviewSize.large:
        return 12;
    }
  }

  double _getSpacing() {
    switch (size) {
      case PreviewSize.small:
        return 4;
      case PreviewSize.medium:
        return 6;
      case PreviewSize.large:
        return 8;
    }
  }

  double _getIconSize() {
    switch (size) {
      case PreviewSize.small:
        return 16;
      case PreviewSize.medium:
        return 24;
      case PreviewSize.large:
        return 32;
    }
  }

  double _getTextSize() {
    switch (size) {
      case PreviewSize.small:
        return 10;
      case PreviewSize.medium:
        return 12;
      case PreviewSize.large:
        return 14;
    }
  }

  double _getSmallTextSize() {
    switch (size) {
      case PreviewSize.small:
        return 8;
      case PreviewSize.medium:
        return 10;
      case PreviewSize.large:
        return 12;
    }
  }

  int _getMaxLines() {
    switch (size) {
      case PreviewSize.small:
        return 2;
      case PreviewSize.medium:
        return 3;
      case PreviewSize.large:
        return 4;
    }
  }

  // Stats & Indicators
  double _getStatsPosition() {
    switch (size) {
      case PreviewSize.small:
        return 4;
      case PreviewSize.medium:
        return 6;
      case PreviewSize.large:
        return 8;
    }
  }

  double _getStatsPadding() {
    switch (size) {
      case PreviewSize.small:
        return 4;
      case PreviewSize.medium:
        return 6;
      case PreviewSize.large:
        return 8;
    }
  }

  double _getStatsRadius() {
    switch (size) {
      case PreviewSize.small:
        return 6;
      case PreviewSize.medium:
        return 8;
      case PreviewSize.large:
        return 10;
    }
  }

  double _getStatsIconSize() {
    switch (size) {
      case PreviewSize.small:
        return 10;
      case PreviewSize.medium:
        return 12;
      case PreviewSize.large:
        return 14;
    }
  }

  double _getStatsTextSize() {
    switch (size) {
      case PreviewSize.small:
        return 8;
      case PreviewSize.medium:
        return 10;
      case PreviewSize.large:
        return 12;
    }
  }

  double _getSmallStatsTextSize() {
    switch (size) {
      case PreviewSize.small:
        return 7;
      case PreviewSize.medium:
        return 8;
      case PreviewSize.large:
        return 10;
    }
  }

  // Indicators
  double _getIndicatorPosition() {
    switch (size) {
      case PreviewSize.small:
        return 4;
      case PreviewSize.medium:
        return 6;
      case PreviewSize.large:
        return 8;
    }
  }

  double _getIndicatorPadding() {
    switch (size) {
      case PreviewSize.small:
        return 2;
      case PreviewSize.medium:
        return 3;
      case PreviewSize.large:
        return 4;
    }
  }

  double _getIndicatorRadius() {
    switch (size) {
      case PreviewSize.small:
        return 4;
      case PreviewSize.medium:
        return 6;
      case PreviewSize.large:
        return 8;
    }
  }

  double _getIndicatorSize() {
    switch (size) {
      case PreviewSize.small:
        return 8;
      case PreviewSize.medium:
        return 12;
      case PreviewSize.large:
        return 16;
    }
  }

  // Play Button
  double _getPlayButtonPadding() {
    switch (size) {
      case PreviewSize.small:
        return 6;
      case PreviewSize.medium:
        return 8;
      case PreviewSize.large:
        return 12;
    }
  }

  double _getPlayButtonSize() {
    switch (size) {
      case PreviewSize.small:
        return 16;
      case PreviewSize.medium:
        return 24;
      case PreviewSize.large:
        return 32;
    }
  }

  // Placeholder
  double _getPlaceholderIconSize() {
    switch (size) {
      case PreviewSize.small:
        return 16;
      case PreviewSize.medium:
        return 24;
      case PreviewSize.large:
        return 32;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case PreviewSize.small:
        return 16;
      case PreviewSize.medium:
        return 20;
      case PreviewSize.large:
        return 24;
    }
  }
}
