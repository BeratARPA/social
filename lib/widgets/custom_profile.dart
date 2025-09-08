import 'package:flutter/material.dart';

// Profil widget'ının nasıl görünmesi gerektiğini belirleyen enum
enum ProfileLayout {
  horizontal, // Yatay sıralama (profil resmi - isim - username yan yana)
  vertical, // Dikey sıralama (profil resmi üstte, isim-username altta)
  compact, // Kompakt görünüm (sadece profil resmi + isim)
  minimal, // Minimal görünüm (sadece profil resmi)
}

// Hangi bilgilerin gösterileceğini belirleyen enum
enum ProfileDisplayMode {
  full, // Tüm bilgiler (profil resmi, isim, username, doğrulama, zaman)
  nameOnly, // Sadece isim ve profil resmi
  avatarOnly, // Sadece profil resmi
  noAvatar, // Profil resmi hariç her şey
  nameAndTime, // İsim, profil resmi ve zaman
  minimal, // İsim ve profil resmi (doğrulama dahil)
}

class CustomProfile extends StatelessWidget {
  // Kullanıcı bilgileri
  final String displayName;
  final String? username;
  final String? profilePicture;
  final bool isVerified;
  final String? userId;

  // Zaman bilgisi
  final DateTime? createdAt;
  final String? customTimeText;

  // Story özelliği
  final bool hasStory;
  final List<Color>? storyGradientColors;

  // Görünüm ayarları
  final ProfileLayout layout;
  final ProfileDisplayMode displayMode;

  // Boyut ayarları
  final double? avatarRadius;
  final double? nameTextSize;
  final double? usernameTextSize;
  final double? timeTextSize;

  // Renk ayarları
  final Color? nameTextColor;
  final Color? usernameTextColor;
  final Color? timeTextColor;
  final Color? avatarBackgroundColor;
  final Color? verificationIconColor;

  // Callback fonksiyonları
  final VoidCallback? onTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNameTap;
  final VoidCallback? onMoreTap;
  final Function(String?)? onUserTap;

  // Ek özellikler
  final bool showMoreButton;
  final bool showTime;
  final bool enableTap;
  final EdgeInsets? padding;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final Widget? customTrailing;
  final Widget? customLeading;
  final int? maxLines;

  const CustomProfile({
    super.key,
    required this.displayName,
    this.username,
    this.profilePicture,
    this.isVerified = false,
    this.userId,
    this.createdAt,
    this.customTimeText,
    this.hasStory = false,
    this.storyGradientColors,
    this.layout = ProfileLayout.horizontal,
    this.displayMode = ProfileDisplayMode.full,
    this.avatarRadius = 18,
    this.nameTextSize = 14,
    this.usernameTextSize = 12,
    this.timeTextSize = 12,
    this.nameTextColor,
    this.usernameTextColor,
    this.timeTextColor,
    this.avatarBackgroundColor,
    this.verificationIconColor,
    this.onTap,
    this.onAvatarTap,
    this.onNameTap,
    this.onMoreTap,
    this.onUserTap,
    this.showMoreButton = false,
    this.showTime = true,
    this.enableTap = true,
    this.padding,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.customTrailing,
    this.customLeading,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(12.0),
      child: _buildLayout(context),
    );
  }

  Widget _buildLayout(BuildContext context) {
    switch (layout) {
      case ProfileLayout.horizontal:
        return _buildHorizontalLayout(context);
      case ProfileLayout.vertical:
        return _buildVerticalLayout(context);
      case ProfileLayout.compact:
        return _buildCompactLayout(context);
      case ProfileLayout.minimal:
        return _buildMinimalLayout(context);
    }
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: [
        if (customLeading != null) ...[
          customLeading!,
          const SizedBox(width: 8),
        ],
        if (_shouldShowAvatar()) ...[
          _buildAvatar(context),
          const SizedBox(width: 10),
        ],
        if (_shouldShowNameInfo()) ...[
          Expanded(child: _buildNameSection(context)),
        ],
        if (_shouldShowTime() && showTime) ...[
          const SizedBox(width: 8),
          _buildTimeSection(context),
        ],
        if (customTrailing != null) ...[
          const SizedBox(width: 8),
          customTrailing!,
        ],
        if (showMoreButton) ...[
          const SizedBox(width: 8),
          _buildMoreButton(context),
        ],
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: [
        if (_shouldShowAvatar()) ...[
          _buildAvatar(context),
          const SizedBox(height: 8),
        ],
        if (_shouldShowNameInfo()) _buildNameSection(context),
        if (_shouldShowTime() && showTime) ...[
          const SizedBox(height: 4),
          _buildTimeSection(context),
        ],
        if (showMoreButton) ...[
          const SizedBox(height: 8),
          _buildMoreButton(context),
        ],
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: [
        if (_shouldShowAvatar()) ...[
          _buildAvatar(context),
          const SizedBox(width: 8),
        ],
        Flexible(child: _buildNameOnly(context)),
        if (isVerified && _shouldShowVerification()) ...[
          const SizedBox(width: 4),
          _buildVerificationIcon(),
        ],
      ],
    );
  }

  Widget _buildMinimalLayout(BuildContext context) {
    return GestureDetector(
      onTap: enableTap ? (onTap ?? () => onUserTap?.call(userId)) : null,
      child: _buildAvatar(context),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final avatar = CircleAvatar(
      radius: avatarRadius,
      backgroundImage:
          profilePicture != null ? AssetImage(profilePicture!) : null,
      backgroundColor: avatarBackgroundColor ?? Colors.grey.shade300,
      child:
          profilePicture == null
              ? Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      nameTextColor ??
                      Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: (avatarRadius ?? 18) * 0.6,
                ),
              )
              : null,
    );

    final avatarWidget =
        hasStory
            ? Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors:
                      storyGradientColors ??
                      [Colors.purple, Colors.pink, Colors.orange],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: avatar,
              ),
            )
            : avatar;

    return GestureDetector(
      onTap:
          enableTap
              ? (onAvatarTap ?? onTap ?? () => onUserTap?.call(userId))
              : null,
      child: avatarWidget,
    );
  }

  Widget _buildNameSection(BuildContext context) {
    return GestureDetector(
      onTap:
          enableTap
              ? (onNameTap ?? onTap ?? () => onUserTap?.call(userId))
              : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            layout == ProfileLayout.vertical
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
        children: [
          _buildNameRow(context),
          if (_shouldShowUsername() && username != null) ...[
            const SizedBox(height: 2),
            _buildUsernameText(context),
          ],
        ],
      ),
    );
  }

  Widget _buildNameRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          layout == ProfileLayout.vertical
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            displayName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: nameTextSize,
              color:
                  nameTextColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign:
                layout == ProfileLayout.vertical
                    ? TextAlign.center
                    : TextAlign.start,
          ),
        ),
        if (isVerified && _shouldShowVerification()) ...[
          const SizedBox(width: 4),
          _buildVerificationIcon(),
        ],
      ],
    );
  }

  Widget _buildNameOnly(BuildContext context) {
    return Text(
      displayName,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: nameTextSize,
        color: nameTextColor ?? Theme.of(context).textTheme.bodyLarge?.color,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign:
          layout == ProfileLayout.vertical ? TextAlign.center : TextAlign.start,
    );
  }

  Widget _buildUsernameText(BuildContext context) {
    return Text(
      '@$username',
      style: TextStyle(
        fontSize: usernameTextSize,
        color:
            usernameTextColor ??
            Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign:
          layout == ProfileLayout.vertical ? TextAlign.center : TextAlign.start,
    );
  }

  Widget _buildVerificationIcon() {
    return Icon(
      Icons.verified,
      size: (nameTextSize ?? 14) + 2,
      color: verificationIconColor ?? Colors.blue.shade600,
    );
  }

  Widget _buildTimeSection(BuildContext context) {
    final timeText = customTimeText ?? _getTimeAgo(createdAt);
    return Text(
      timeText,
      style: TextStyle(
        fontSize: timeTextSize,
        color:
            timeTextColor ??
            Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: onMoreTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.more_vert,
          size: 18,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  // Hangi öğelerin gösterileceğini belirleyen yardımcı metodlar
  bool _shouldShowAvatar() {
    return displayMode != ProfileDisplayMode.noAvatar &&
        displayMode != ProfileDisplayMode.avatarOnly;
  }

  bool _shouldShowNameInfo() {
    return displayMode != ProfileDisplayMode.avatarOnly &&
        displayMode != ProfileDisplayMode.minimal;
  }

  bool _shouldShowUsername() {
    return displayMode == ProfileDisplayMode.full ||
        displayMode == ProfileDisplayMode.noAvatar;
  }

  bool _shouldShowVerification() {
    return displayMode != ProfileDisplayMode.nameOnly ||
        displayMode == ProfileDisplayMode.minimal ||
        displayMode == ProfileDisplayMode.full;
  }

  bool _shouldShowTime() {
    return displayMode == ProfileDisplayMode.full ||
        displayMode == ProfileDisplayMode.nameAndTime;
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
